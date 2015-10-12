function ConvertSpool2h5(varargin)
% given a Neo 12bit packed spool directory (with the corrupted 2008 Andor Solis
% beta files) read all the images in that directory and convert to FITS
% That is, very many .dat spool files from a single directory are converted to
% one big FITS file, readable in ImageJ, etc.
% Michael Hirsch
%
% CAVEAT: h5create() does not allow for compound dataset create, you have
% to use low-level commands

p = inputParser;
addRequired(p,'spooldir')
addOptional(p,'outfn',[])
addRequired(p,'startutc')
addRequired(p,'kineticsec')
addOptional(p,'nx',2544)
addOptional(p,'ny',2160)
addOptional(p,'lla',[65.1186367, -147.432975, 500.])
parse(p,varargin{:})
U = p.Results;

datlist = dir([U.spooldir,'/*.dat']);
datfn = sort({datlist.name});
disp(['I found ',int2str(length(datfn)),' .dat files in ',U.spooldir])
%% auto output filename
if U.spooldir(end) == pathsep
    full = U.spooldir(1:end-1);
else
    full = U.spooldir;
end
[~,basename] = fileparts(full);
if isempty(U.outfn)
    outfn = expanduser([U.spooldir,'/',basename,'.h5']);
else
    outfn = expanduser(U.outfn);
end
disp(['writing to ',outfn])
%% read
nfiles = length(datfn);
%data = zeros([ny,nx,nfiles],'uint16');

h5create(outfn,'/rawimg',[U.nx,U.ny,nfiles],'Datatype','uint16',...
         'Deflate',6,'Chunksize',[U.nx,U.ny,1],'shuffle',true)
for i = 1:nfiles
    data = readNeoPacked12bit([U.spooldir,'/',datfn{i}],U.nx,U.ny);
    disp([int2str(i),' / ',int2str(nfiles)])  
    
    h5write(outfn,'/rawimg',transpose(data),[1,1,i],[U.nx,U.ny,1])
end
%% output hdf5

h5writeatt(outfn,'/rawimg','CLASS',        'IMAGE')
h5writeatt(outfn,'/rawimg','IMAGE_VERSION','1.2')
h5writeatt(outfn,'/rawimg','IMAGE_SUBCLASS','IMAGE_GRAYSCALE')
h5writeatt(outfn,'/rawimg','DISPLAY_ORIGIN','LL')
h5writeatt(outfn,'/rawimg','IMAGE_WHITE_IS_ZERO',uint8(0))
%
h5create(outfn,'/rawind',nfiles,'Datatype','int64')
h5write(outfn,'/rawind',int64(1:nfiles))

t0 = datetime(U.startutc);
epoch = datetime(1970,1,1,0,0,0);
t= seconds(t0-epoch) + (0:(nfiles-1))*U.kineticsec;

h5create(outfn,'/ut1_unix',nfiles)
h5write(outfn,'/ut1_unix',t)
%
h5create(outfn,'/sensorloc/glat',1,'Datatype','double')
h5write(outfn,'/sensorloc/glat',U.lla(1))
h5create(outfn,'/sensorloc/glon',1,'Datatype','double')
h5write(outfn,'/sensorloc/glon',U.lla(2))
h5create(outfn,'/sensorloc/alt_m',1,'Datatype','double')
h5write(outfn,'/sensorloc/alt_m',U.lla(3))
%
h5create(outfn,'/params/kineticsec',1,'Datatype','double')
h5write(outfn,'/params/kineticsec',U.kineticsec)

end
