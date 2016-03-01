% reader of Neo spool files, 16 bit only (not 12-bit pack)
function [data, tick64] = readNeoSpool(spoolfn,nx,ny,varargin)

p = inputParser;
addOptional(p,'nFrame',12) % for 2012-2013 Solis, was 11 ...
addOptional(p,'AOIstride',8) %always 8?
addOptional(p,'colfirst',true) %false for 2012-2013 Solis?, true for 2015 Solis
parse(p,varargin{:})
U = p.Results;

finf = dir(spoolfn);

if U.colfirst
    freadshape = [nx+U.AOIstride, ny];
else
    freadshape = [ny+U.AOIstride,nx];
end

data = zeros(ny,nx, U.nFrame,'uint16'); %preallocate
tick64 = zeros(U.nFrame,1,'uint64');

fid = fopen(spoolfn);
for i = 1:U.nFrame

    frame = fread(fid,freadshape,'uint16=>uint16',0,'l');
    assert(all(size(frame)==freadshape),'wrong image size, did you read past end of data file (wrong nx,ny)?')
    
    if U.colfirst
        data(:,:,i) = transpose(frame(1:end-U.AOIstride,:));
    else
        data(:,:,i) = frame(1:end-U.AOIstride,:);
    end
    
    %get FPGA tick index
    tick64(i) = parseNeoHeader(fid,freadshape(1));
end %for i


assert(ftell(fid)==finf.bytes,'did you read the whole file?')
assert(all(diff(tick64)>0),'are frames out of order?')

fclose(fid);

end %function
