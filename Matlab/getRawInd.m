function [firstRawIndex,lastRawIndex] = getRawInd(BigFN,BytesPerImage,nHeadBytes)
% Michael Hirsch 2014
% gets first and last raw indicies from a big .DMCdata file

Nmetadata = nHeadBytes/2; %number of 16-bit words
fid = fopen(BigFN,'r');
%% get first raw frame index
fseek(fid,BytesPerImage,'bof');
metadata = fread(fid,Nmetadata,'uint16=>uint16',0,'l');
%typecast those 16-bit metadata words into frame #'s
firstRawIndex = typecast([metadata(2) metadata(1)],'uint32');
firstRawIndex = double(firstRawIndex); %to do expected math operations
%% get last raw frame index
fseek(fid, -nHeadBytes, 'eof');
metadata = fread(fid,Nmetadata,'uint16=>uint16',0,'l');
lastRawIndex = typecast([metadata(2) metadata(1)],'uint32');
lastRawIndex = double(lastRawIndex);
%%
fclose(fid);
end %function
