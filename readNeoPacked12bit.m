function data = readNeoPacked12bit(datafile,nx,ny)
%% Reading of "damaged" 12-bit packed Neo files from 2008 beta version of Andor Solis
% endian-flipping by Bob Marshall, Stanford U.
% requires Matlab -- does not work in GNU Octave 4.0.
%
% NOTE: assumes one frame per file
%
% Michael Hirsch

fs = dir(datafile);
fs = fs.bytes;

bytesperframe = nx*ny*12/8;
nframe = fix(fs/bytesperframe);
assert(nframe==1,'see comments to allow more than 1 frame per file')

f = fopen(datafile,'rb');
%data = zeros([nx,ny,nframe],'uint16');
data = zeros([nx,ny],'uint16');

%for i = 1:nframe 
    cf = ftell(f);
%% read big-endian odd rows
    dataBE = fread(f,[nx,ny],'ubit12=>uint16','ieee-be'); % *ubit12 is equivalent
    fseek(f,cf,'bof'); %go back so we can read it again (inefficient)
%% read little-endian even row
    dataLE = fread(f,[nx,ny],'ubit12=>uint16','ieee-le'); 
%% combine the appropriate rows
    data(1:2:end,:) = dataBE(1:2:end,:);
    data(2:2:end,:) = dataLE(2:2:end,:);

%end %for

fclose(f);

data = data.';
end

