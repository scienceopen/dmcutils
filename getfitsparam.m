function [xPixels, yPixels, xBin, yBin, nFrame, startTime] =  getfitsparam(BigFN)

    %now get parameters from FITS file header
    h = fitsinfo(BigFN); 
    h = h.PrimaryData.Keywords;
    
    xPixels   = h{~cellfun(@isempty,strfind(h(:,1),'NAXIS1')),2};

    yPixels   = h{~cellfun(@isempty,strfind(h(:,1),'NAXIS2')),2};

    xBin      = h{~cellfun(@isempty,strfind(h(:,1),'HBIN')),2};

    yBin      = h{~cellfun(@isempty,strfind(h(:,1),'VBIN')),2};

    %nFrame   = h{~cellfun(@isempty,strfind(h(:,1),'FRMCNT')),2} %wrong

    nFrame    = h{~cellfun(@isempty,strfind(h(:,1),'NAXIS3')),2};

    startTime = h{~cellfun(@isempty,strfind(h(:,1),'FRAME')),2}; %time of first exposure


end
