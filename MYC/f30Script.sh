#!/usr/bin/env bash


# This web tool relies on the pdb headers
# So vmd breaks so leave as un aliased pdb
#vmd < aliasPDB.tcl
cp Protein_A.itp myc_aa_CG.itp
sed -i 's/martini.itp/martini_v2.2_aminoacids.itp/g' myc_aa_CG.itp
sed -i 's/Protein_A.itp/myc_aa_CG.itp/g' myc_aa_CG.top
sed -i 's/martini.itp/martini_v2.2.itp/g' myc_aa_CG.top

# N = 100

mkdir invacuo

cp martini_v2.2.itp invacuo
cp martini_v2.0_ions.itp invacuo
cp myc_aa_CG.itp invacuo
cp myc_box.gro invacuo
cp tripep_water_min.mdp invacuo/minimization.mdp
cp myc_aa_CG.top invacuo/system.top

cd invacuo

sed -i 's/1/6\n/g' system.top

gmx grompp -p system.top -c myc_box.gro -f minimization.mdp -o invacuo.tpr
gmx mdrun -deffnm invacuo -v

cd ..

mkdir solvate

cp martini_v2.2.itp solvate
cp martini_v2.0_ions.itp solvate
cp myc_aa_CG.itp solvate
cp invacuo/invacuo.gro solvate/myc_box.gro
cp waterbox_25nm.gro solvate/water.gro
cp tripep_water_min.mdp solvate/minimization.mdp
cp tripep_water_eq.mdp solvate/equilibration.mdp
cp invacuo/system.top solvate/system.top

cd solvate 

sed -i 's/#include "martini_v2.2.itp"/#include "martini_v2.2.itp"\n#include "martini_v2.0_ions.itp"/g' system.top

gmx solvate -p system.top -cp myc_box.gro -cs water.gro -o solvated.gro -radius 0.21 
# get num waters added)
#numWaters="$(grep -c 'W' solvated.gro)"
#printf "\n" >> system.top
#echo "W           $numWaters" >> system.top

gmx grompp -p system.top -c solvated.gro -f minimization.mdp -o genion.tpr
gmx genion -s genion.tpr -p system.top -pname NA+ -nname CL- -neutral -o solvated.gro <<EOF
13
EOF

#Modify system.top for ionization


gmx grompp -p system.top -c solvated.gro -f minimization.mdp -o minimization.tpr -maxwarn 1
gmx mdrun -deffnm minimization -v

gmx grompp -f equilibration.mdp -p system.top -c solvated.gro -o equilibration.tpr -maxwarn 2
gmx mdrun -deffnm equilibration -v






