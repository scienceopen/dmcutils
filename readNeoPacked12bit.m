function data = readNeoPacked12bit(datafile,imsize)
%% Reading of "damaged" 12-bit packed Neo files from 2008 beta version of Andor Solis
% endian-flipping by Bob Marshall, Stanford U.
% requires Matlab -- does not work in GNU Octave 4.0.
% Michael Hirsch

fs = dir(datafile);
fs = fs.bytes;

bytesperframe = prod(imsize)*12/8;
nframe = fix(fs/bytesperframe);

f = fopen(datafile,'rb');
data = zeros([imsize,nframe],'uint16');


for i = 1:nframe 
cf = ftell(f);
%%read big-endian odd rows
dataBE = fread(f,imsize,'ubit12=>uint16','ieee-be'); % *ubit12 is equivalent
fseek(f,cf,'bof'); %go back so we can read it again (inefficient)
% read little-endian even rows
dataLE = fread(f,imsize,'ubit12=>uint16','ieee-le'); 
%% combine the appropriate rows
data(1:2:end,:,i) = dataBE(1:2:end,:);
data(2:2:end,:,i) = dataLE(2:2:end,:);

end %for

fclose(f);
end

%% 2x2 binning (untested)
%data2 = 0.25 * ( data(1:2:end,1:2:end) + data(1:2:end,2:2:end) ...
%    + data(2:2:end,1:2:end) + data(2:2:end,2:2:end) );
%data2 = data;