% Writing source coordinates 

fstats = fopen('stations.txt', 'wt');

for irec = 1:nr
    fprintf(fstats,'%5d %15.3f %15.3f %15.3f\n',stats(irec,1),stats(irec,3),stats(irec,2),stats(irec,4));
end
fclose(fstats);