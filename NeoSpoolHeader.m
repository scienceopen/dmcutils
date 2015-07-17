function tick64 = NeoSpoolHeader(fid,nRowRaw)    

%the header is actually not 16-bit--will be parsed next
    hdr = fread(fid,nRowRaw, 'uint16=>uint16',0,'l');

    %parse header
    %ticklength = typecast(hdr(end-1 :end-0, i),'uint32'); %4 bytes
    %tickCID =    typecast(hdr(end-3 :end-2, i),'uint32'); %4 bytes
    tick64 =     typecast(hdr(end-7 :end-4),'uint64'); %8 bytes
    %frmLngth =   typecast(hdr(end-9 :end-8, i),'uint32'); %4 bytes
    %frameCID =   typecast(hdr(end-11:end-10,i),'uint32'); %4 bytes
end