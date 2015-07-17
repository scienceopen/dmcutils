% reader of Neo spool files
function [data tick64 nFrame hdr] = NeoSpoolReader(fn,varargin)

P = length(varargin);
if P>0, nRow = varargin{1}; nCol = varargin{2}; else nRow = 640, nCol = 540, end
if P>2, nFrame = varargin{3}; else nFrame = 11, end
if P>3, AOIstride = varargin{4}; else AOIstride = 8, end

nRowRaw = nRow + AOIstride;

data = zeros(nRowRaw,nCol,nFrame,'uint16'); %preallocate
hdr = zeros(nRowRaw,nFrame,'uint16');

fid = fopen(fn);
%for j = 0:length(fn)-1
for i = 1:nFrame
    data(:,:,i) = fread(fid,[nRowRaw nCol],'uint16=>uint16',0,'l');
    %get FPGA tick index
    tick64 = NeoSpoolHeader(fid,nRowRaw);
end
%end
%clean zeros out of data
data = data(1:nRow,:,:);



fclose(fid);

end %function
