function frame = readFrame(fn,frameInd)
%
% inputs:
% -------
% fn: filename to load
% frameInd: [start,step,stop] or [start,stop]
%
% output:
% -------
% frame: data frame(s) loaded, XxYxP frames 

[~,~,ext] = fileparts(fn);
%%
switch lower(ext)
	case {'.tif','.tiff'}
      frame = imread(fn,'Index',frameInd);
  case '.dmcdata'
      frame = rawDMCreader(fn,'framereq',frameInd);
	case '.fits'
      if length(frameInd)==3
          octind = [int2str(frameInd(1)),':',int2str(3),':',int2str(frameInd(2))]; %1,3,2
          matind = [frameInd(1),frameInd(2),frameInd(3)]; %1,2,3
      elseif length(frameInd)==1 %skip only specified
          octind = ['*:',int2str(frameInd)];
          matind = [];
      else
          octind = [int2str(frameInd(1)),':',int2str(frameInd(end))];
          matind = [frameInd(1), frameInd(end)];
      end

      if isoctave
          ffn = [fn,'[*,*,',octind,']'];
          try
              frame = permute(read_fits_image(ffn),[2,1,3]);
          catch
              pkg load fits
              frame = permute(read_fits_image(ffn),[2,1,3]);
          end
      else
          pinf = fitsinfo(fn);
          ps = pinf.PrimaryData.Size;
          if isempty(matind) && length(frameInd)==1 
              matind = [1, frameInd, ps(3)];
          end
          frame = fitsread(fn,'primary','PixelRegion',{[1 ps(1)],[1 ps(2)],matind});
      end
end %switch

end %function