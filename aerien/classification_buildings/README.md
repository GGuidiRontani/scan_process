# Objective
Classify buildings

# General presentation

### Tool
[PDAL 2.5.2](https://github.com/PDAL/PDAL)
[pdal-parallelizer](https://github.com/meldig/pdal-parallelizer)

### Datas
The dataset covers the all SCoT (administrative subdivision for urban management) of Lille Metropole. Its density is about 100pts/km².
Transmitted as flightlines in las format, it has been compressed in squarred tiles of 500m with a 20m buffer in laz format 1.4 dataformat 8.

# Methodology
Based on the [ground/non-ground classification](https://github.com/GGuidiRontani/scan_process/tree/main/aerien/classification_ground_nonground) performed earlier, the next step is to classify regular geometries such as buildings.

#### Choises
It was decided to find a way to classify these geometries without the help of third-party features. In this experiment, only the analysis based on covariance features is performed.

#### Processing chain
