function data2 = readCMOSdata(datafile,imsize)

% read once as big-endian
fid = fopen(datafile,'r','b');
A1 = fread(fid,imsize,'ubit12=>uint16');
fclose(fid);
% replace every second row (starting from 2) with 0
A1(2:2:end) = 0;

% read again as little-endian
fid = fopen(datafile,'r','l');
A2 = fread(fid,imsize,'ubit12=>uint16');
fclose(fid);
% replace every second row (starting from 1) with 0
A2(1:2:end) = 0;

% add them together!
data = A1 + A2;
%data2 = 0.25 * ( data(1:2:end,1:2:end) + data(1:2:end,2:2:end) ...
%    + data(2:2:end,1:2:end) + data(2:2:end,2:2:end) );
data2 = data;

% note that data returned by this function is BINNED 2 x 2 with respect to
% the data taken in.
