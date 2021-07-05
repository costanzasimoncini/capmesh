## capmesh - generate caps to close a vtk mesh

capmesh reads a vtk mesh of an open surface and automatically generates the caps to close it. The code reads a vtk mesh that has been clipped at the input and outputs (for example in ITK or Paraview). The code automatically detects the nodes where the mesh has been clipped, group all the nodes corresponding to one cap (through k-means clustering) and then generates the caps by ordering the nodes in a clock-wise order and generating triangles. The generated outputs must then be correctly remeshed in CFD softwares. 

This code can tipically be used in a pipeline where you want to run CFD blood flow simulations on a mesh describing segmented blood vessels. More details can be found in our paper "Simoncini et al. Blood Flow Simulation in Patient-Specific Segmented Hepatic Arterial Tree. IRBM, 38(3), 120-126. 2017." If the code contributes to your work, please cite our paper (available here): http://aragorn.pb.bialystok.pl/~mkret/docs/irbm2017.pdf



# Depencencies
	Tested on Matlab 2016b


# Usage

In the `main.m` define the folder containing the vtk mesh. The mesh file should be called `OpenMeshN.vtk` where `N` is the number of open surfaces to be capped. 