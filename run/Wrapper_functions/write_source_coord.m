% Writing source coordinates 

fid = fopen('sources.txt', 'wt');

for is = 1:ns
    fprintf(fid,'%5d %15.3f %15.3f %15.3f\n',sources(is,1),sources(is,3),sources(is,2),sources(is,4));
end
fclose(fid);
