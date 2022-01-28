REM objetctif : exporter les sommets d'une maquette au format ifc pour en controler le georeferencement

REM ----------STAGE 1----------
REM conversion ifc -> obj
REM cette etape fonctionne mais semble ne pas supporter l'intergration dans un bat... a verifier

D:\applications\fme\2020_2_1\fme.exe D:\applications\nettoyeur\ifc2obj.fmw --SourceDataset_IFC "path\input.ifc" --DestDataset_OBJ "path\output_folder"

REM ----------STAGE 2----------
REM extraction des sommets des obj

Disk:
cd path\output_folder
find -type f -name "*.obj" | D:\applications\rush.exe --jobs 20 "D:\applications\cloudcompare\2_12_alpha\CloudCompare.exe -SILENT -o -GLOBAL_SHIFT AUTO {} -EXTRACT_VERTICES -C_EXPORT_FMT LAS -AUTO_SAVE OFF -SAVE_CLOUDS

REM ----------STAGE 3----------
REM fusion des sommets contenus dans les fichiers laz

pdal pipeline D:\applications\nettoyeur\pdal_las_merge_laz.json --writers.las.filename=path\result.laz

REM ----------STAGE X----------
REM suppression des doublons
REM cette etape vise a supprimer les sommets identiques présents dans differents types de constituants, le resultat a ecrit avec le suffixe "_1"

D:\applications\lastools\bin\lasduplicate.exe -i path\result.laz -unique_xyz

DEL path\result.laz
