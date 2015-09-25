function [flatnorm,dark] = flatdark(flatfn,darkfn)
%% dark
fid = fopen(darkfn,'rb');
darkraw = fread(fid,imsize,'uint16');
fclose(fid);
dark = mean(darkraw(:));
%% flat
fid = fopen(flatfn,'rb');
flatraw = fread(fid,imsize,'uint16');
fclose(fid);

flat = flatraw - dark;
flatnorm = flat / max(flat(:));
end