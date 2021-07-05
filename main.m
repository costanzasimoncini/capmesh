clear variables
close all

folder_data = 'DATA/Example/'; % folder with VTK open surface mesh
folder_stl = [folder_data 'STL/']; % folder with output STL caps ans surface
if ~isfolder(folder_stl)
    mkdir(folder_stl)
end

NbOfSurfaces = 51; % Total number of open surfaces to be capped  
[Verts,Tri,Quadri] = read_vtk_TriQuad([folder_data 'OpenMesh' num2str(NbOfSurfaces) '.vtk']);

NbOfPoints = size(Verts,1); % size(Verts) = N x 3 ; where N is the number of Points
NbOfFaces = zeros(NbOfPoints,1); % NbOfFaces is the number of faces per point, so it has the same size as NbOfPoints

for i = 1 : length(Quadri(:))
	NbOfFaces(Quadri(i)) = NbOfFaces(Quadri(i)) + 1;
end
for i = 1 : length(Tri(:))
	NbOfFaces(Tri(i)) = NbOfFaces(Tri(i)) + 1;
end

PointsOfTheOpenSurface = find(NbOfFaces<=3); % Finds the nodes where the mesh was cut (=>Open Surface). It supposes that the nodes where the mesh was cut are connected to 3 or less faces
% test2 = find(NbOfFaces<=2); % check how many points are connected to less than 2 faces
% test22 = find(NbOfFaces==2); % test to understand the mesh
% test33 = find(NbOfFaces==3); % normally there shouldn't be any point here
% test44 = find(NbOfFaces==4); % and here neither

VertsOfTheSurface = Verts(PointsOfTheOpenSurface,:); 

figure;
plot3(VertsOfTheSurface(:,1),VertsOfTheSurface(:,2),VertsOfTheSurface(:,3),'*m');
hold on;

%   K-means to distinguish the nodes of a same cap
[idxClust,C] = kmeans(VertsOfTheSurface(:,1:3), NbOfSurfaces, 'replicates',500, 'MaxIter',1000); %, 'Distance', 'hamming');
% idxClust = vector of the same size of the vector "PointsOfTheOpenSurface"
% it contains the cluster index for every point
% Ex. [1 2 1] means that the elements 1 and 3 belong to the cluster 1, and the element 2 to the cluster 2.
% C = the centres of every cluster
plot3(C(:,1),C(:,2),C(:,3),'kx','MarkerSize',15,'LineWidth',3) %Verify K-means. It plots C, the Centres of every cluster
hold off; 
title('Nodes of every output surface and k-means clusters centers')

% figure, % Plot all vertex of the surface mesh
% plot3(Verts(:,1),Verts(:,2),Verts(:,3),'*g');
% title('All vertex of the surface mesh')

% cycle on every cap (Surface) k
for k = 1 : NbOfSurfaces
	idxCurSurf = find(idxClust==k); % finds the index of the elements belonging to the cluster k
	VertsOfTheCurrentSurface = VertsOfTheSurface(idxCurSurf,:); % takes only the vertex belonging to the cap k
	
% 	isCoplanar(VertsOfTheCurrentSurface, 0.001) % check if vertex are coplanar
	
	%barycentre
	Bary = mean(VertsOfTheCurrentSurface,1); % compute the barycenter
	figure;
	plot3(Bary(1),Bary(2),Bary(3),'*g') %plot the barycenter
	hold on;
	plot3(VertsOfTheCurrentSurface(1,1),VertsOfTheCurrentSurface(1,2),VertsOfTheCurrentSurface(1,3),'.k','MarkerSize',45) % plots the first node of the cap k bigger in black
	hold on;
	plot3(VertsOfTheCurrentSurface(:,1),VertsOfTheCurrentSurface(:,2),VertsOfTheCurrentSurface(:,3),'*m'); % plots all the nodes of the cap k
	hold on;
	cameramenu
	
	%Create the pizza starting from the first node and going in clockwise order
	Ref = VertsOfTheCurrentSurface(1,:)-Bary; % Reference vector
	Ref = Ref/sqrt(sum(Ref.^2)); % normalise
	angles = zeros(size(VertsOfTheCurrentSurface,1),1); % vector containig the angles of every face of the pizza from the reference vector
	for i = 2 : length(angles) % for i=1 it equals 0
		currVect = VertsOfTheCurrentSurface(i,:) - Bary;
		currVect = currVect/sqrt(sum(currVect.^2)); % normalise
		if i == 2
			PlaneNormal = cross(currVect,Ref);
		end
		if sign(dot(currVect,PlaneNormal)) > 0
			angles(i) = acos(Ref*currVect');
		else
			angles(i) = 2*pi - acos(Ref*currVect');
		end
	end
	[~,idxTri] = sort(angles); % idxTri has the indexes of the nodes, ordered by the angles (used to pass from the order of the nodes to the order of the angles)
	VertsOfTheCurrentSurface = [VertsOfTheCurrentSurface; Bary];
	TriOpenSurface = [repmat(size(VertsOfTheCurrentSurface,1),size(angles,1),1) idxTri [idxTri(2:end) ;idxTri(1)]]; % create the new cap (pizza)
	
	trisurf(TriOpenSurface,VertsOfTheCurrentSurface(:,1),VertsOfTheCurrentSurface(:,2),VertsOfTheCurrentSurface(:,3)); % plot the pizza
	cameramenu;
	title(['Cap n. ' num2str(k)]);
	hold off;
	
	Tri2Stl([folder_stl 'ClosingSurface' num2str(k)],TriOpenSurface,VertsOfTheCurrentSurface); %save cap k in stl format
end

% Creates new Triangles from the Quadrilaterals
TriQuadri = [];
for i = 1 : size(Quadri,1)  
	TriQuadri = [TriQuadri; Quadri(i,1:3)];
	TriQuadri = [TriQuadri; Quadri(i,3:4),Quadri(i,1)];
end
Tri2Stl([folder_stl 'wall' num2str(k) 'Surfaces'],[Tri;TriQuadri],Verts); % save the open surface in stl format

