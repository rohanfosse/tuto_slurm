#!/bin/bash

#SBATCH -J JOBNAME // nom du job
#SBATCH -t 12:00:00 // temps max d'execution
#SBATCH --ntasks-per-node=// une seule tache par noeud en meme temps
#SBATCH --chdir=output/ // chemin de sortie
#SBATCH --cpus-per-task=12 //pour parallèle
#SBATCH --mem 500 // mémoire max en Mo


echo "c SLURM Launched script started at "`date`
RACINEALGO="/gpfs/home/name/" # ou est ton programme ?
LISTADATA="/gpfs/home/name/list.txt" # utiliser realpath pour ça, liste des données que l'on veut parser
THISRACINE=`pwd`


if test "${SLURM_ARRAY_TASK_ID+set}" != set; then
    echo "c SLURM *WARNING* SLURM_ARRAYID is not set (assigned to 0 by default)"
    SLURM_ARRAY_ID=0
fi


exec 10<&0 # Link filedescriptor 10 with stdin
exec < "$LISTDATA" #stdin replaced by the file
while read LINE; do
    DATAS[$count]=$LINE
    ((count++))
done


echo "c data = ${DATAS[$SLURM_ARRAY_TASK_ID]}" # ca écrit la ligne :)
MYDATA="${DATAS[$SLURM_ARRAY_TASK_ID]}"
echo "c SLURM launch $SLURM_ARRAY_TASK_ID of job $SLURM_JOB_NAME on $MYDATA"

python -m venv 
cd $RACINEALGO
sh programme.sh $MYDATA #le programme à executer
