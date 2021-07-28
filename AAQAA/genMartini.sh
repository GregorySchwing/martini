#!/usr/bin/env bash

python2 pdb2dssp.py AAQAA-Helix.pdb https://www3.cmbi.umcn.nl/xssp/ > AAQAA-Helix.dssp
python2 pdb2dssp.py AAQAA.pdb https://www3.cmbi.umcn.nl/xssp/ > AAQAA.dssp

python2 martinize.py -f AAQAA-Helix.pdb -o AAQAA-Helix-CG.top -x AAQAA-Helix-CG.pdb -ss AAQAA.dssp -p backbone -ff martini22

sed -i 's/#include "Protein.itp"/#include "AAQAA-Helix-CG.itp"/g' Protein.itp
mv Protein.itp AAQAA-Helix-CG.itp
sed -i 's/martini.itp/martini_v2.2_aminoacids.itp/g' AAQAA-CG.itp
sed -i 's/Protein.itp/AAQAA-Helix-CG.itp/g' AAQAA-Helix-CG.top
python2 martinize.py -f AAQAA.pdb -o AAQAA-CG.top -x AAQAA-CG.pdb -ss AAQAA.dssp -p backbone -ff martini22
sed -i 's/martini.itp/martini_v2.2_aminoacids.itp/g' AAQAA-CG.itp
sed -i 's/Protein.itp/AAQAA-CG.itp/g' AAQAA-CG.itp
mv Protein.itp AAQAA-CG.itp

wget http://cgmartini.nl/images/parameters/ITP/martini_v2.2_aminoacids.itp

wget http://www.ks.uiuc.edu/Training/Tutorials/martini/files.tar.gz

tar xzfv files.tar.gz
