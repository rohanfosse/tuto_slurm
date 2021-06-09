# Courte présentation de slurm 

## Header du fichier

```bash
#!/bin/bash

#SBATCH -J JOBNAME // nom du job
#SBATCH -t 12:00:00 // temps max d'execution
#SBATCH --ntasks-per-node=1 // une seule tache par noeud en meme temps
#SBATCH --chdir=output/  // chemin de sortie
#SBATCH --cpus-per-task=12 //nombre de cpu pour une tache
#SBATCH --mem 500 // mémoire max en Mo

```

Pour rappel, il ne faut rien mettre avant ce header. J'ai mis ici les commandes les plus courantes, vous pouvez trouver les autres dans ce [tableau récapitulatif](http://https://slurm.schedmd.com/pdfs/summary.pdf "tableau récapitulatif").



## Fichier pour une seule instance

Dans le cas où vous souhaitez lancer un programme sur une seule instance, le fichier minimal ressemblera donc à ça :

```bash
#!/bin/bash

#SBATCH -J JOBNAME // nom du job
#SBATCH -t 12:00:00 // temps max d'execution
#SBATCH --ntasks-per-node=// une seule tache par noeud en meme temps
#SBATCH --chdir=output/ // chemin de sortie
#SBATCH --cpus-per-task=12 //pour parallèle
#SBATCH --mem 500 // mémoire max en Mo

./programme arg1 arg2 #le programme à executer
```

Voir le fichier `slurm-example1.slurm` pour plus d'informations.

## Fichier pour plusieurs instances

Dans le cas où vous souhaitez lancer plusieurs instances en meme temps, il faut rajouter ce bout de code en plus:
```bash
echo "c SLURM Launched script started at "`date` #permet de savoir quand on a lancé le code
RACINEALGO="/gpfs/home/name/" # ou est ton programme ?
LISTADATA="/gpfs/home/name/list.txt" #liste des chemins absolus de toutes les instances

exec 10<&0 # Link filedescriptor 10 with stdin
exec < "$LISTDATA" #On remplace stdin par le fichier
while read LINE; do #on stocke les fichiers dans un tableau
    DATAS[$count]=$LINE
    ((count++))
done
```

Pour rappel, le moyen le plus rapide de générer les chemins absolus de tous les fichiers du dossier courant et de les stocker dans un fichier *list.txt* est:

```bash
realpath * . > list.txt
```

Par la suite, on a besoin de récupérer l'instance sur laquelle chaque noeud va travailler. Pour cela, il existe une variable `$SLURM_ARRAY_TASK_ID` qui est gérer automatiquement par l'ordonnanceur. Cette variable est correspond au numéro de ligne de ton fichier `list.txt`.

Le code pour récupérer cette instance et exécuter le programme est le suivant :

```bash
echo "c data = ${DATAS[$SLURM_ARRAY_TASK_ID]}" # On écrit sur quelle instance on est en train de travailler
MYDATA="${DATAS[$SLURM_ARRAY_TASK_ID]}" #On stocke cette instance dans la variable MYDATA
echo "c SLURM launch $SLURM_ARRAY_TASK_ID of job $SLURM_JOB_NAME on $MYDATA"

cd $RACINEALGO # on se rend dans le répertoire du programme
programme.sh $MYDATA # on execute le programme
```
Le code final ressemblera donc à ça :

```bash
#!/bin/bash

#SBATCH -J JOBNAME // nom du job
#SBATCH -t 12:00:00 // temps max d'execution
#SBATCH --ntasks-per-node=// une seule tache par noeud en meme temps
#SBATCH --chdir=output/ // chemin de sortie
#SBATCH --cpus-per-task=12 //pour parallèle
#SBATCH --mem 500 // mémoire max en Mo


echo "c SLURM Launched script started at "`date` #permet de savoir quand on a lancé le code
RACINEALGO="/gpfs/home/name/" # ou est ton programme ?
LISTADATA="/gpfs/home/name/list.txt" # utiliser realpath pour ça, liste des données que l'on veut parser


exec 10<&0 # Link filedescriptor 10 with stdin
exec < "$LISTDATA" #stdin replaced by the file
while read LINE; do
    DATAS[$count]=$LINE
    ((count++))
done


echo "c data = ${DATAS[$SLURM_ARRAY_TASK_ID]}" # On écrit sur quelle instance on est en train de travailler
MYDATA="${DATAS[$SLURM_ARRAY_TASK_ID]}" #On stocke cette instance dans la variable MYDATA
echo "c SLURM launch $SLURM_ARRAY_TASK_ID of job $SLURM_JOB_NAME on $MYDATA"

cd $RACINEALGO
./programme. $MYDATA #le programme à executer


```

Voir le fichier `slurm-example2.slurm` pour plus d'informations.

## Informations Utiles

### Liés à slurm
#### Lancer le slurm
- Si on a 50 instances à lancer en meme temps, la commande sera : `sbatch --array=1-50 my-slurm.slurm`
- S'il n'y a qu'une seune instance, la commande sera : `sbatch my-slurm.slurm`

On appelle job un slurm qui a été lancé sur curta.

#### Voir les informations
- La façon la plus simple est de faire : `squeue -u USERNAME`

- Il est aussi possible de ne voir les infos que d'un job en particulier : `squeue --job JOBID`

#### Anuler un job

- Pour supprimer tous les jobs que l'on a lancé : `scancel -u USERNAME`
- Pour supprimer un seul job : `scancel JOBID`

### Autres
#### Stockage des données
- Il faut créer un dossier à son nom dans `/scratch/`. C'est un espace de stockage qui permet de garder plusieurs To pendant un bon moment, assez pratique.
- Dans l'espace /gfps/home/USERNAME, on a le droit à 128 Go.
- Pour connaitre la taille du dossier courant : `du -sh .`

#### Récupérer kissat
`git clone https://github.com/arminbiere/kissat.git`

#### Plus d'info 

`https://redmine.mcia.fr/projects/cluster-curta/wiki/Slurm`


