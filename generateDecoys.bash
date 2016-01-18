#!/bin/bash
if [[ $# -ne 1 ]]
then
	echo "Script to generate atomistic decoy of RNA downloaded from the PDB"
	echo "usage $0: < PDBID >"
else
	source ~/.bashrc
	mkdir coors/${PDB}
	split_pdb.bash ${PDB} coors/${PDB}/model 0
	grep ATOM coors/${PDB}/model_1.pdb | grep -v HETATOM > coors/${PDB}/reference.pdb

	awk '{ if($3=="P") print $6}' coors/${PDB}/reference.pdb > coors/${PDB}/info.${PDB}.txt
	awk '{ if($3=="P") print tolower($4)}' coors/${PDB}/reference.pdb  | tr '\n' ' ' | sed 's/ //g' > coors/${PDB}/info.${PDB}.seq.txt
	
	rm -f coors/${PDB}/reference_fixed.pdb
	for i in `cat coors/${PDB}/info.${PDB}.txt`
	do
		awk -v resid=${i} '{ if ($6==resid) print}' coors/${PDB}/reference.pdb >> coors/${PDB}/reference_fixed.pdb
	done

	cd coors/${PDB}
	ln -s ${SimRNA}/data/ data
	SimRNA -o cycle_1 -c ../../config.txt -p reference_fixed.pdb
	SimRNA_trafl2pdbs reference_fixed.pdb cycle_1.trafl : AA 
	cd ../../	
fi
