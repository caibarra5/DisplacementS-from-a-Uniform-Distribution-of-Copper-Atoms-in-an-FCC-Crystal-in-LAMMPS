cat thermo_info_0_* > $1
awk 'NR>1{print $1+1 " " $2 " " $3 " " $4 " " $5 " " $6}' \
thermo_info_iterate_* >> $1
