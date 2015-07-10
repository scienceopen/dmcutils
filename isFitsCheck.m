function [xPixels yPixels xBin yBin nFrame startTime] =...
     isFitsCheck(BigFN)

    %now get parameters from FITS file header
    fitsHeader = fitsinfo(BigFN); fitsHeader = fitsHeader.PrimaryData.Keywords;
    xPixels = fitsHeader{find(~cellfun(@isempty,strfind(fitsHeader(:,1),'NAXIS1'))),2};

    yPixels = fitsHeader{find(~cellfun(@isempty,strfind(fitsHeader(:,1),'NAXIS2'))),2};

    xBin    = fitsHeader{find(~cellfun(@isempty,strfind(fitsHeader(:,1),'HBIN'))),2};

    yBin    = fitsHeader{find(~cellfun(@isempty,strfind(fitsHeader(:,1),'VBIN'))),2};

    %nFrame  = fitsHeader{find(~cellfun(@isempty,strfind(fitsHeader(:,1),'FRMCNT'))),2} %wrong

    nFrame  = fitsHeader{find(~cellfun(@isempty,strfind(fitsHeader(:,1),'NAXIS3'))),2};

    startTime = fitsHeader{find(~cellfun(@isempty,strfind(fitsHeader(:,1),'FRAME'))),2}; %time of first exposure


end
