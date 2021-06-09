#!/bin/bash

#SBATCH -J JOBNAME // nom du job
#SBATCH -t 12:00:00 // temps max d'execution
#SBATCH --ntasks-per-node=// une seule tache par noeud en meme temps
#SBATCH --chdir=output/ // chemin de sortie
#SBATCH --cpus-per-task=12 //pour parallèle
#SBATCH --mem 500 // mémoire max en Mo


echo "c SLURM Launched script started at "`date`
RACINEALGO="/gpfs/home/name/" # ou est ton programme ?

cd $RACINEALGO
sh programme.sh $MYDATA #le programme à executer

