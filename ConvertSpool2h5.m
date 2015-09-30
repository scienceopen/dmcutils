function ConvertSpool2h5(spooldir,nx,ny,startutc,kineticsec)
% given a Neo 12bit packed spool directory (with the corrupted 2008 Andor Solis
% beta files) read all the images in that directory and convert to FITS
% That is, very many .dat spool files from a single directory are converted to
% one big FITS file, readable in ImageJ, etc.
% Michael Hirsch

datlist = dir([spooldir,'/*.dat']);
datfn = {datlist.name};
disp(['I found ',int2str(length(datfn)),' .dat files in ',spooldir])
%% auto output filename
if spooldir(end) == pathsep
    full = spooldir(1:end-1);
else
    full = spooldir;
end
[~,basename] = fileparts(full);
outfn = expanduser([spooldir,'/',basename,'.h5']);
disp(['writing to ',outfn])
%% read
nfiles = length(datfn);
%data = zeros([ny,nx,nfiles],'uint16');

h5create(outfn,'/rawimg',[ny,nx,nfiles],'Datatype','uint16',...
         'Deflate',6,'Chunksize',[ny,nx,1])
for i = 1:nfiles
    data = readNeoPacked12bit([spooldir,'/',datfn{i}],nx,ny);
    fprintf(' %.0f%%',i/length(datfn)*100)   
    
    h5write(outfn,'/rawimg',data,[i,i,1],[1,ny,nx])
end
%% output hdf5

h5writeatt(outfn,'/rawimg','CLASS',        'IMAGE')
h5writeatt(outfn,'/rawimg','IMAGE_VERSION','1.2')
h5writeatt(outfn,'/rawimg','IMAGE_SUBCLASS','IMAGE_GRAYSCALE')
h5writeatt(outfn,'/rawimg','DISPLAY_ORIGIN','LL')
h5writeatt(outfn,'/rawimg','IMAGE_WHITE_IS_ZERO',uint8(0))

h5create(outfn,'/rawind',nfiles,'Datatype','int64')
h5write(outfn,'/rawind',0:(nfiles-1))

t0 = datetime(startutc);
epoch = datetime(1970,1,1,0,0,0);
t= seconds(t0-epoch) + (0:(nfiles-1))*kineticsec;

h5create(outfn,'/ut1_unix',nfiles)
h5write(outfn,'/ut1_unix',t)


end
