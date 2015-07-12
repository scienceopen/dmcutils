function NeoPacked12bitToFITS(spooldir,imsize)
% given a Neo 12bit packed spool directory (with the corrupted 2008 Andor Solis
% beta files) read all the images in that directory and convert to FITS
% That is, very many .dat spool files from a single directory are converted to
% one big FITS file, readable in ImageJ, etc.

datlist = dir([spooldir,'/*.dat']);
datfn = {datlist.name};
disp(['I found ',int2str(length(datfn)),' .dat files in ',spooldir])

%too lazy for regexp
if spooldir(end) == '/' || spooldir(end) == '\'
    full = spooldir(1:end-1);
else
    full = spooldir;
end
[~,basename] = fileparts(full);

fitsfn = [spooldir,'../',basename,'.fits'];
nfiles = length(datfn);

data = zeros([imsize,nfiles],'uint16');

for i = 1:nfiles
    data(:,:,i) = readNeoPacked12bit([spooldir,'/',datfn{i}],imsize);
    fprintf(' %.0f%%',i/length(datfn)*100)
    %note, many FITS readers trip up on compression. You can just 7zip the bunch
    % of FITS files you create.
    fitswrite(int32(data),fitsfn,'Compression','none')    
end

end
