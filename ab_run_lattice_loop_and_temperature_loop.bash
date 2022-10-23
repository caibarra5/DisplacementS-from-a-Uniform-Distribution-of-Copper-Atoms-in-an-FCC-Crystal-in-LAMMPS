./xa_parameters_computed_for_xb.bash
SECONDS=0

mapfile -t parameters < xb_parameters_for_ab.txt

steps_per_run=${parameters[0]}
dump_freq=${parameters[1]}        # Dump every dump_freq time steps
data_points_freq=${parameters[2]} # Output data points every data_points_freq time steps

num_of_dumps=$(($steps_per_run / $dump_freq))
steps_per_dump=$(($steps_per_run / $num_of_dumps))

num_of_data=$(($steps_per_run / $data_points_freq))
steps_per_data_point=$(($steps_per_run / $num_of_data))

mapfile -t latts < ca_lattice_constants.txt
let "array_ca_len = ${#latts[@]}"
let "len_ca = ${#latts[@]} - 1"

mapfile -t disp < cc_displacements.txt
let "array_cc_len = ${#disp[@]}"
let "len_cc = ${#disp[@]} - 1"

total_time=$SECONDS
# First loop is the lattice constants
# Lattice Constants
for((i=0;i<$array_ca_len;i++))
do

  mapfile -t temps < ${latts[i]}A_temps.txt
  let "array_temps_len = ${#temps[@]}"
  let "len_temps = ${#temps[@]} - 1"
# Temperature
for((j=0;j<$array_temps_len;j++))
do

# Displacements
for((k=0;k<$array_cc_len;k++))
do

# Second loop is the temperatures
  
  SECONDS=0
# First do the in.*0*
  mpirun -np 4\
    lmp\
    -var temp ${temps[j]}\
    -var a ${latts[i]}\
    -var n $steps_per_run\
    -var k $steps_per_data_point\
    -var l $steps_per_dump\
    -var dis ${disp[k]}\
    -i in.melt_Cu.0.velRes

./ba_run_fa_to_make_displacements.bash ${disp[k]} > zy*.txt
cp zy_*.txt dump_0_*
  
# Now do the in.*iterate*
  mpirun -np 4\
    lmp\
    -var temp ${temps[j]}\
    -var a ${latts[i]}\
    -var n $steps_per_run\
    -var k $steps_per_data_point\
    -var l $steps_per_dump\
    -var dis ${disp[k]}\
    -i in.melt_Cu.iterate.velRes

cp zz_*.txt dump_0_*
  
  d=$SECONDS

  total_time=$(($total_time + $SECONDS))

initT=`over_row_range_avg.bash thermo_info_0_dis_${disp[k]}* 5 402 502`
finalT=`over_row_range_avg.bash thermo_info_iterate_dis_${disp[k]}* 5 402 502`

initE=`over_row_range_avg.bash thermo_info_0_dis_${disp[k]}* 2 402 502`
finalE=`over_row_range_avg.bash thermo_info_iterate_dis_${disp[k]}* 2 402 502`

#initT=`over_row_range_avg.bash thermo_info_0_dis_${disp[k]}* 5 4002 5002`
#finalT=`over_row_range_avg.bash thermo_info_iterate_dis_${disp[k]}* 5 4002 5002`

diffT=`c_summation $finalT -${initT}`
diffE=`c_summation $finalE -${initE}`
#echo $initT
#echo $finalT 
#echo $diffT

echo "${disp[k]} $initT $finalT $diffT $initE $finalE $diffE" >> \
disp_vs_temp_${disp[0]}_${disp[$len_cc]}_starting_at_${temps[j]}.dat
rm thermo_info_0*
rm thermo_info_iterate*
done
mv disp* yz*
./da*
done


f=$total_time

txt2=tb_${latts[0]}A_${latts[$len_ca]}A_${array_ca_len}_temp_custom_n_${steps_per_run}.txt

echo "Sum of wall-clock times for each run: " >> $txt2

  echo "$(($f / 3600)) hours, $(($(($f % 3600)) / 60)) minutes and $(($(($f % 3600)) % 60))\
    seconds" >> $txt2


#/bb_combine_both_thermo_info_files_together_with_cat_and_use_awk_to_displace_time_of_iterate_thermo_info.bash \
# ${disp[k]}A_thermo_info_data_combined
#ed -i '1d' ${disp[k]}A_thermo_info_data_combined

#mv ${disp[k]}A_thermo_info_data_combined yz_data_for_displacements
cd yz_data_for_displacements 
#cat ${disp[k]}A_thermo_info_data_combined >> zz_all_data.txt
initial_temp=
#rm ${disp[k]}_thermo_info_data_combined
cd ..

done



#cd yz_data_for_displacements
#max=`find_max_awk.bash 4 -1000 zz_all_data.txt`
#min=`find_min_awk.bash 3 1000 zz_all_data.txt`
#
#for file in *_thermo_info*
#do
#../bc_plot_kinetic_potential_and_total_energy_in_same_graph.R \
#$file $min $max "${file::(-26)} Max Amplitude Discplacement"
#rm $file
#done
#../xc_make_video.bash
##vlc out.mp4
#cd ..

spd-say "done"
