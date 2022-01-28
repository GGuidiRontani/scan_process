REM ----------STAGE 1----------
REM extraction des differents scans d'un e57 structure (si besoin) et conversion en laz
REM a la difference de CloudCompare, cet outils permet de convertir en laz tout en concervant les valeurs d'intensite

mkdir E:\stage1_lt
D:\applications\lastools\bin\e572las.exe -v -i E:\2021_lille_station_grand_palais\nuages\e57_natifs\2021_lille_station_grand_palais_global_l93.e57 -o E:\stage1_lt\2021_lgp.laz -split_scans

REM ----------STAGE 2----------
REM utiliser l'outils connected components
REM les composants exploitables sont superieurs a 10Mo, voire 30Mo, une brique permettant de deplacer les las sup a 10 pou 30Mo vers un nouveau repertoire est a mettre en place

E:
cd E:\stage1_lt
find -type f -name "*.laz" | D:\applications\rush.exe --jobs 20 "D:\applications\cloudcompare\2_12_alpha\CloudCompare.exe -SILENT -o -GLOBAL_SHIFT AUTO {} -EXTRACT_CC 8 10 -C_EXPORT_FMT LAS -AUTO_SAVE OFF -SAVE_CLOUDS

python D:\applications\nettoyeur\filtre.py 20 E:\stage1_lt

REM	----------STAGE 3----------
REM supprimer les donnees hors emprise et export laz avec offset 0.001, possibilite de reprojeter les donnees

mkdir E:\stage3_pdal
cd E:\stage1_lt
find -type f -name "*.las" | D:\applications\rush.exe --jobs 20 "pdal pipeline D:\applications\nettoyeur\pdal_las_voxelcnb.json --readers.las.filename={} --filters.reprojection.in_srs=EPSG:2154 --filters.reprojection.out_srs=EPSG:3950 --writers.las.filename=E:\stage3_pdal\{.}.laz"

REM suppression fichiers intermediaires
rmdir /s /q E:\stage1_lt

REM ----------------------------------------------------------------------

REM ----------STAGE 4----------
REM filters.python ne fonctionne pas

REM mkdir E:\stage4_pdal
REM cd E:\stage4_pdal
REM find -type f -name "*.laz" | D:\applications\rush.exe --jobs 20 "pdal pipeline E:\codes\benne\open_las_create_OriginID_dimension.json --readers.las.filename={} --filters.python.script=E:\codes\benne\marquage_obj_mobiles.py --writers.las.filename=E:\stage4_pdal\{.}.laz"

REM suppression fichiers intermediaires
REM DEL E:\stage3_pdal

REM ----------STAGE 5----------
REM tuilage avec buffer
REM l'outil tile ne permet pas de determiner un nomber de points (comme filters.divider ou chipper), penser a definir une taille de tuiles inf a 10 millions de points pour que lastools n'ecrase pas les valeurs d'intensity et de point_source_ID

mkdir E:\stage5_pdal
cd E:\stage3_pdal
find -type f -name "*.laz" | D:\applications\rush.exe --jobs 20 "pdal pipeline D:\applications\nettoyeur\pdal_las_splitter_laz.json --readers.las.filename={} --writers.las.filename=E:\stage5_pdal\{.}_#.laz"

REM suppression fichiers intermediaires
rmdir /s /q E:\stage3_pdal

REM ----------STAGE 6----------
REM les composants exploitables sont superieurs a 10Mo, voire 30Mo, une brique permettant de deplacer les las sup a 10 pou 30Mo vers un nouveau repertoire est a mettre en place

REM D:\applications\lastools\bin\lassort.exe -cpu64 -bucket 5 -remain_buffered -olaz -i "E:\stage4_tile\*.laz" -odir E:\stage5_lt_lassort -odix _sort

REM ----------STAGE 7----------
REM sous-echantillonage en fonction de la planearite par tuile
REM un sous-echantillonnage par voxel de 0.001 est applique en debut de pipeline

mkdir E:\stage7_pdal
cd E:\stage5_pdal
find -type f -name "*.laz" | D:\applications\rush.exe --jobs 20 "pdal pipeline D:\applications\nettoyeur\pdal_subsampling_coplanarity.json --readers.las.filename={} --writers.las.filename=E:\stage7_pdal\{.}.laz"

REM suppression fichiers intermediaires
rmdir /s /q E:\stage5_pdal

REM ----------STAGE 8----------
REM fusion des laz
REM l'option filename du readers las du pipeline permet de lire tous les laz contenu dans le repertoire pointe par cd, l'input est modifiable par cd, l'ouput par --writers.las.filename=

cd E:\stage7_pdal
pdal pipeline D:\applications\nettoyeur\merge_in_one_las.json  --writers.las.filename=E:\output_ss_cc50.laz

REM suppression fichiers intermediaires
rmdir /s /q E:\stage7_pdal

REM ----------STAGE 9----------
REM production d'un projet Potree avec index pour utilisation sur webimaging

REM D:\applications\potreeconverter\2_0_2\PotreeConverter.exe "E:\2021_lille_grand_palais_nuage_50m_l93.laz" -o "E:\test_potree" -m poisson -p --title "lille_station_grand_palais_nuage_sous_echantillonne" --encoding BROTLI --generate-page "lille_station_grand_palais_sous_echantillonne"

REM ----------STAGE 10----------
REM conversion du nuage au format rcp
REM le nuage doit être divise en tuiles de 20000 points max donc utilisation du filters.divider avec l'option capacity a 19000

REM pdal pipeline E:\codes\pdal_las_divider_laz.json
REM D:\applications\fme\2020_2_1\fme.exe C:\Users\GGUIDI~1\AppData\Local\Temp\wb-xlate-1635841474260_1692 --SourceDataset_LAS "E:\2021_lille_grand_palais_nuage_50m_l93.laz" --DestDataset_RECAP "E:\usine"