cp dump_0_* zz_temp.txt

# This is for 1000 timesteps
lower=132510
upper=132765

# This is for 10000 timesteps
#lower=1325010
#upper=1325265

awk -v low=$lower 'NR<low{print $0}' zz_temp.txt

displacements=(`./fb_displace_atom_positions_by_some_amplitude 256 $1`)
for((i=$lower; i<=$upper; i++))
do
# Look at columnvs 5,6 and 7 for the positions
awk -v i=$i -v dx=${displacements[3*(i-$lower)+0]} -v dy=${displacements[3*(i-$lower)+1]} -v \
dz=${displacements[3*(i-$lower)+2]} 'NR == i {print $1 " " $2+dx " " $3+dy \
" " $4+dz " " $5 " " $6 " " $7 " " $8 " " $9 " " $10}' zz_temp.txt
done
