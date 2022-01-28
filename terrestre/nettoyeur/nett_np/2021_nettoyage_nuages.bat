REM ----------STAGE 1----------

mkdir path\nett_np\stage1_lt
path\nett_np\util\e572las.exe -v -i path\nett_np\input.e57 -o path\nett_np\stage1_lt\split.laz -split_scans

REM	----------STAGE 2----------

path\nett_np
cd path\nett_np\stage1_lt
find -type f -name "*.laz" | path\util\rush.exe --jobs 20 "path_install\CloudCompare.exe -SILENT -o -GLOBAL_SHIFT AUTO {} -EXTRACT_CC 8 10000 -C_EXPORT_FMT LAS -AUTO_SAVE OFF -SAVE_CLOUDS

python path\nett_np\util\filtre.py 20 path\nett_np\stage1_lt

REM	----------STAGE 3----------

mkdir path\nett_np\stage3_pdal
cd path\nett_np\stage1_lt
find -type f -name "*.las" | path\nett_np\util\rush.exe --jobs 20 "pdal pipeline path\nett_np\util\pdal_las_voxelcnb.json --readers.las.filename={} --filters.reprojection.in_srs=EPSG:2154 --filters.reprojection.out_srs=EPSG:3950 --filters.crop.polygon=Polygon ((705410.79475611192174256 7060302.68646958097815514, 705363.96418118139263242 7060275.76768366247415543, 705389.79145061562303454 7060232.32739428803324699, 705436.21982787526212633 7060259.78166098054498434, 705410.79475611192174256 7060302.68646958097815514)) --filters.voxelcentroidnearestneighbor.cell=0.005 --writers.las.filename=path\stage3_pdal\{.}.laz"

REM suppression fichiers intermediaires
rmdir /s /q path\nett_np\stage1_lt

REM ----------STAGE 4----------

cd path\nett_np\stage3_pdal
pdal pipeline path\nett_np\util\pdal_merge_laz.json --writers.las.filename=path\nett_np\output_cc50.laz

REM suppression fichiers intermediaires
rmdir /s /q path\nett_np\stage3_pdal

REM ----------STAGE 5----------
REM production d'un projet Potree avec index pour utilisation sur webimaging

path\nett_np\util\PotreeConverter.exe "path\nett_np\output.laz" -o "path\nett_np\potree" -m poisson -p --title "titre" --encoding BROTLI --generate-page "index"
