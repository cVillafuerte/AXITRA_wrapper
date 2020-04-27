% Script to generate axi.data file

fid1 = fopen('axi.data', 'wt');
fprintf(fid1,'&input\n');
fprintf(fid1,'nc=%d                               ! Number of layers \n', nc);
fprintf(fid1,'nfreq=%d                            ! Number of frequencies \n', nfreq);
fprintf(fid1,'tl=%d                               ! Length of the synthetic seismograms \n', tl);
fprintf(fid1,'aw=%d                               ! Coefficient for frequency imaginary part \n', aw);
fprintf(fid1,'nr=%d                               ! Number of stations \n', nr);
fprintf(fid1,'ns=%d                               ! Number of sources \n', ns);
fprintf(fid1,'xl=%d                               ! Medium periodicity \n', xl);
fprintf(fid1,'ikmax=%d                            ! Max number of iterations \n', ikmax);
fprintf(fid1,'latlon=%s                           ! Distance given in (lat,lon) \n', latlon);
fprintf(fid1,'freesurface=%s                      ! Free surface is set at Z=0? \n', freesurface);
fprintf(fid1,'source_opt=%d                        ! Source time function option \n', source_opt);
fprintf(fid1,'t0=%5.3f                            ! Rise time \n', t0);
fprintf(fid1,'t1=%5.3f                            ! Source procces time (only if source_opt == 8 \n', t1);
fprintf(fid1,'sourcefile="sources.txt"               ! Source file \n');
fprintf(fid1,'statfile="stations.txt"            ! Station file \n');
fprintf(fid1,'seism_opt=%d                        ! Seismograms in (1) disp (2) vel (3) acce \n', seism_opt);
fprintf(fid1,'dirout="%s"                           ! Output directory \n',dirout);
fprintf(fid1,'// \n');

for ilay = 1:nc
    fprintf(fid1,'%10.3f %10.3f %10.3f %10.3f %10.3f %10.3f\n',H(ilay),Vp(ilay),Vs(ilay),rho(ilay),Qp(ilay),Qs(ilay));
end

fclose(fid1);
