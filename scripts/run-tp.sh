#!/bin/bash

main() {
	# Gromacs VERSION
	#source /usr/local/gromacs5-1-5/bin/GMXRC
	#source /usr/local/gromacs2016-3/bin/GMXRC
	source /usr/local/gromacs/bin/GMXRC

	run-folders
}

run-folders() {
	for preffix in {1..4}
	do
	  folder=$preffix*
	  echo "going into" $folder
	  cd $folder
		echo "currently in"
		pwd
			# All iterations
			#for p in {1..100}
			# Just 2 iterations
			for p in {1..2}
			do
				# All iterations
				#for t in {200..800..6}
				# Just 2 iterations
				for t in {200..206..6}
				do
					# UNCOMMENT WHEN DONE WITH TESTING
					mkdir OUT/p$p-t$t

					# Modify 0_md file
					# remove last two lines from 0_md file
					echo -e '$d\nw\nq'| ed MDP/0_md.mdp
					echo -e '$d\nw\nq'| ed MDP/0_md.mdp

					# write pressure and temperature iterations
					echo "ref_p 		=" $p>>MDP/0_md.mdp
					echo "ref_t 		=" $t>>MDP/0_md.mdp

					# Modify 0_npt file
					# remove last two lines from 0_npt file
					echo -e '$d\nw\nq'| ed MDP/0_npt.mdp
					echo -e '$d\nw\nq'| ed MDP/0_npt.mdp

					# write pressure and temperature iterations
					echo "ref_p 		=" $p>>MDP/0_npt.mdp
					echo "ref_t 		=" $t>>MDP/0_npt.mdp

					# Modify 0_nvt file
					# remove last lines from 0_nvt file
					echo -e '$d\nw\nq'| ed MDP/0_nvt.mdp

					# write temperature iterations
					echo "ref_t 		=" $t>>MDP/0_nvt.mdp

					run-commands
				done
			done
			cd ..
	done
}

run-commands() {
	gmx grompp -f MDP/0_minim.mdp -c OUT/solv2.gro -p FF/topol.top -o OUT/p$p-t$t/0-em.tpr
	gmx mdrun -v -deffnm OUT/p$p-t$t/0-em
	echo "saving to" OUT/p$p-t$t-0-em
	gmx grompp -f MDP/0_nvt.mdp -c OUT/0-em.gro -p FF/topol.top -o OUT/p$p-t$t/1-nvt.tpr
	gmx mdrun -v -deffnm OUT/p$p-t$t/1-nvt
	echo "saving to" OUT/p$p-t$t/1-nvt
	gmx grompp -f MDP/0_npt.mdp -c OUT/1-nvt.gro -p FF/topol.top -o OUT/p$p-t$t/2-npt.tpr
	gmx mdrun -v -deffnm OUT/p$p-t$t/2-npt
	echo "saving to" OUT/p$p-t$t/2-npt
	gmx grompp -f MDP/0_md.mdp -c OUT/2-npt.gro -p FF/topol.top -o OUT/p$p-t$t/3-md.tpr -maxwarn 1
	gmx mdrun -v -deffnm OUT/p$p-t$t/3-md
	echo "saving to" OUT/p$p-t$t-3-md
}

main "$@"; exit
