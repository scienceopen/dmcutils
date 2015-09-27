% obsolete not correct program

function [flatnorm,dark] = flatdark(flatfn,darkfn,imsize)
%% dark
fid = fopen(darkfn,'rb');
darkraw = fread(fid,imsize,'uint16=>uint16');
fclose(fid);
dark = mean(darkraw(:),'native'); %TODO do we agree with this definition
%% flat
fid = fopen(flatfn,'rb');
flatraw = fread(fid,imsize,'uint16=>uint16');
fclose(fid);

flat = flatraw - dark; %uint16 clips to 0, different behavior than Python/Numpy !
flatnorm = double(flat) / double(max(flat(:))); %TODO this is probably wrong
end
