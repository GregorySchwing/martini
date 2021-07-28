#!/usr/bin/env bash


# This web tool relies on the pdb headers
# So vmd breaks so leave as un aliased pdb
#vmd < aliasPDB.tcl

cp myc_aa_bak.pdb myc_aa_aliased.pdb

python2 pdb2dssp.py myc_aa_aliased.pdb https://www3.cmbi.umcn.nl/xssp/ > myc_aa.dssp

python2 martinize.py -f myc_aa_aliased.pdb -o myc_aa_CG.top -x myc_aa_CG.pdb -ss myc_aa.dssp -p backbone -ff martini22

python2 insane.py -x 30 -y 30 -z 30 -d 0 -pbc cubic -excl -0.5 -sol W -o water.gro

cp Protein_A.itp myc_aa_CG.itp
sed -i 's/martini.itp/martini_v2.2_aminoacids.itp/g' myc_aa_CG.itp
sed -i 's/Protein_A.itp/myc_aa_CG.itp/g' myc_aa_CG.top
sed -i 's/martini.itp/martini_v2.2.itp/g' myc_aa_CG.top

# N = 100
gmx insert-molecules -box 10 10 10 -nmol 6 -ci myc_aa_CG.pdb -radius 0.1 -o myc_box.gro
gmx editconf -f myc_box.gro -o newbox.gro -bt cubic -d 10 -c

#gmx editconf -f myc_box.gro -translate 10 10 10 -o tranlated_myc.gro -pbc no
#gmx editconf -f water.gro -translate -10 -10 -10 -o newbox.gro
#mkdir invacuo

#cp martini_v2.2.itp invacuo
#cp martini_v2.0_ions.itp invacuo
#cp myc_aa_CG.itp invacuo
#cp myc_box.gro invacuo
#cp tripep_water_min.mdp invacuo/minimization.mdp
#cp myc_aa_CG.top invacuo/system.top

#cd invacuo

#sed -i 's/1/6\n/g' system.top

#gmx grompp -p system.top -c myc_box.gro -f minimization.mdp -o invacuo.tpr
#gmx mdrun -deffnm invacuo -v

#cd ..

mkdir solvate

cp myc_aa_CG.top solvate/system.top
cp martini_v2.2.itp solvate
cp martini_v2.0_ions.itp solvate
cp myc_aa_CG.itp solvate
cp newbox.gro solvate
cp water.gro solvate
cp tripep_water_min.mdp solvate/minimization.mdp
cp tripep_water_eq.mdp solvate/equilibration.mdp
#cp invacuo/system.top solvate/system.top

cd solvate 

sed -i 's/1/6\n/g' system.top
sed -i 's/#include "martini_v2.2.itp"/#include "martini_v2.2.itp"\n#include "martini_v2.0_ions.itp"/g' system.top

#gmx insert-molecules -f water.gro -nmol 1 -ci myc_box.gro -radius 0.01 -o solvated.gro -replace <<EOF
#2
#EOF

gmx solvate -p system.top -cp newbox.gro -cs water.gro -o solvated.gro -radius 0.21 
# get num waters added)
#numWaters="$(grep -c 'W' solvated.gro)";
#printf "\n" >> system.top;
#echo "W           $numWaters" >> system.top;

gmx grompp -p system.top -c solvated.gro -f minimization.mdp -o genion.tpr -maxwarn 1
gmx genion -s genion.tpr -p system.top -pname NA+ -nname CL- -neutral -o solvated.gro <<EOF
13
EOF

#Modify system.top for ionization


gmx grompp -p system.top -c solvated.gro -f minimization.mdp -o minimization.tpr -maxwarn 1
#gmx mdrun -deffnm minimization -v

#gmx grompp -f equilibration.mdp -p system.top -c solvated.gro -o equilibration.tpr -maxwarn 2
#gmx mdrun -deffnm equilibration -v






