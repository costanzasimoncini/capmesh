function [vertex, tri, quadri] = read_vtk_TriQuad(filename)
% filename='../../../ExportAnsys/OpenCatheter.vtk';
% read_vtk - read data from VTK file.
%
%   [vertex,face] = read_vtk(filename, verbose);
%
%   'vertex' is a 'nb.vert x 3' array specifying the position of the vertices.
%   'face' is a 'nb.face x 3' array specifying the connectivity of the mesh.
%
%   Copyright (c) Mario Richtsfeld

fid = fopen(filename,'r');
if( fid==-1 )
    error('Can''t open the file.');
    return;
end

str = fgets(fid);   % -1 if eof
if ~strcmp(str(3:5), 'vtk')
    error('The file is not a valid VTK one.');    
end

%%% read header %%%
str = fgets(fid);
str = fgets(fid);
str = fgets(fid);
str = fgets(fid);
nvert = sscanf(str,'%*s %d %*s', 1);

% read vertices
[A,cnt] = fscanf(fid,'%f %f %f', 3*nvert);
if cnt~=3*nvert
    warning('Problem in reading vertices.');
end
A = reshape(A, 3, cnt/3);
vertex = A;

% read polygons
str = fgets(fid);
str = fgets(fid);

info = sscanf(str,'%c %*s %*s', 1);

if info ~= 'C'
    str = fgets(fid);    
    info = sscanf(str,'%c %*s %*s', 1);
end

if(info == 'C')
    str = fgets(fid);
    type = sscanf(str,'%d', 1);
    tri=[];
    quadri=[];
    while type==4
        idxFace = sscanf(str,'%*d %d %d %d %d\n', 4);
        quadri=[quadri,idxFace];
        str = fgets(fid);
        type = sscanf(str,'%d', 1);
    end
    while type==3
        idxFace = sscanf(str,'%*d %d %d %d\n', 3);
        tri=[tri,idxFace];
        str = fgets(fid);
        type = sscanf(str,'%d', 1);
    end        
end

fclose(fid);
vertex=vertex';
tri=(tri+1)';
quadri=(quadri+1)';
return
