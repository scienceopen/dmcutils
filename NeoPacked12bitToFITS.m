function NeoPacked12bitToFITS(spooldir,imsize)
% given a Neo 12bit packed spool directory (with the corrupted 2008 Andor Solis
% beta files) read all the images in that directory and convert to FITS

datlist = dir([spooldir,'/*.dat']);
datfn = {datlist.name};
disp(['I found ',int2str(length(datfn)),' .dat files in ',spooldir])

fitsfn = [spooldir,'/out.fits'];

for i = 1:length(datfn)
    data = readNeoPacked12bit([spooldir,'/',datfn{i}],imsize);
    if ~exist(fitsfn,'file')
        writemode='overwrite';
    else
        writemode='append'; %stupid fitswrite api crashes if no fits already there
    end
    fitswrite(int32(data),fitsfn,'WriteMode',writemode,'Compression','gzip')    
end

end