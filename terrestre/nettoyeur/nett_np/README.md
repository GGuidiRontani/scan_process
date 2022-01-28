# Présentation

L'outils de nettoyage des nuages de points a pour objetif de traiter des données brutes issues de scans terrestres.

## Produit en entrée attendu :

Un fichier e57 structuré

## Produits en sortie :

* Un fichier laz
* Un projet Potree

Il exploite, par ordre d'utilisation :

* e572las de Lastools (fourni)
* CloudCompare (à installer)
* rush (fourni)
* Python (à installer)
* PDAL dans Conda (à installer)
* Potree (fourni)

# Description :

Cet outils est codé sous la forme d'un fichiet bat. Pour l'utiliser facilement, il est conseillé de déposer ce répertoire à la racine du disque utilisé pour le traitement.

* Dans le ficher nett_np.bat
1. remplacer path_install par le répertoire d'installation de CloudCompare
2. remplacer path par le nom du disque utilisé (ex. E:)

## Stage 1

La première étape permet d'extraire les scans d'un fichier e57 structuré et de les enregistrer individuellement dans des fichiers laz. 

L'outils e572las permet de conserver les valeurs d'intensité.

## Stage 2

Cette étape est parallélisée grâce à l'outils rush. Le nombre de threads alloué à cette étape est paramétrable avec l'option --jobs XX.

Une première phase de nettoyage utilise l'outils Connected Components de CloudCompare pour segmenter les laz. L'option -EXTRACT_CC permet de paramètrer le niveau d'octree pour la recherche des composants connectés et le nombre minimum de points pour chacun de ces composants.

Si vous utilisez un nombre de points par composants faible, de nombreux composants produits pourra être important. L'outils filtre.py permettra de les supprimer selon un seuil (ligne 12).

## Stage 3

Cette étape est parallélisée grâce à l'outils rush. Le nombre de threads alloué à cette étape est paramétrable avec l'option --jobs XX.

L'étape 3 regroupe plusieures fonctions :

* reprojection des données dans un autre système avec l'option --filters.reprojection.in_srs=EPSG:XXXX pour le système en entrée et --filters.reprojection.out_srs=EPSG:XXXX pour le système en sortie. Si aucune reprojection n'est nécessaire, il suffit de supprimer ces options du fichier bat.

* supprimer les donneés hors emprise en renseignant la géométrie de découpe au format WKT dans l'option --filters.crop.polygon=XXX. Attention au système de projection utilisé s'il y a eu une reprojection.

* sous-échantillonner les nuages en ne retenant que le centroïde de voxels dont le pas est paramétrable grâce à l'option filters.voxelcentroidnearestneighbor.cell=XXX.

## Stage 4

Cette étape permet de fusionner l'ensemble des laz en un seul fichier directement exploitable.

La chaîne de traitements inclue la suppression régulière des répertoires temporaire pour ne pas saturer la mémoire. Vous pouvez néanmoins déactiver ces phases, pour contrôler chaque étapes par exemple, en les passant en commentaire (rmdir -> REM rmdir)

## Stage 5

Cette dernière étape permet de produire un projet Potree. L'option --generate-page crée un index exploitable pour une diffusion sur un serveur web.

# Exploitation :

* Ouvrir une invt de commande
* Activer l'environnement PDAL
* Executer le script nett_np.bat
