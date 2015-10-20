function tick64 = parseNeoHeader(fid,hdrlen)    
%Michael Hirsch Sept 2012
%the header is actually not 16-bit--will be parsed next
hdr = fread(fid,hdrlen, 'uint16=>uint16',0,'l');

% all other header entries "should" be zero

%parse header
%ticklength = typecast(hdr(end-1 :end-0),'uint32'); %4 bytes  example: 12
%tickCID =    typecast(hdr(end-3 :end-2),'uint32'); %4 bytes  example: 1
tick64 =     typecast(hdr(end-7 :end-4),'uint64'); %8 bytes
%frmLngth =   typecast(hdr(end-9 :end-8),'uint32'); %4 bytes  
% == nx/xbin * ny/ybin + AOIstride*hdrlen ? approx?

%frameCID =   typecast(hdr(end-11:end-10),'uint32'); %4 bytes  example:0
end