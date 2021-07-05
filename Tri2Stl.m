function Tri2Stl(name,Tri,Verts)

%% Write STLfile
TR = triangulation(Tri,Verts); 
fn = faceNormal(TR); % Calculate normals
filename = [name, '.stl'];
permissions = {'w','wb+'};
fid = fopen(filename, permissions{1+1});
options.title = name;
fprintf(fid,'solid %s\r\n',options.title);
[row, ~] = size(fn);
for k = 1:row
    facets = [];
    facets(1,1:3) = fn(k,:);
    trian = TR.Points(TR.ConnectivityList(k,:),:);
    facets(2,1:3) = trian(1,:);
    facets(3,1:3) = trian(2,:);
    facets(4,1:3) = trian(3,:);
    fprintf(fid,'facet normal %.7E %.7E %.7E\r\n', facets(1,:));
    fprintf(fid,'outer loop\r\n');
    fprintf(fid,'vertex %.7E %.7E %.7E\r\n', facets(2,:));
    fprintf(fid,'vertex %.7E %.7E %.7E\r\n', facets(3,:));
    fprintf(fid,'vertex %.7E %.7E %.7E\r\n', facets(4,:));
    fprintf(fid,'endloop\r\n');
    fprintf(fid,'endfacet\r\n');
end
fprintf(fid,'endsolid %s\r\n',options.title);
fclose(fid);