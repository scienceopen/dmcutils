function NeoSpoolPlayer(spoolfn,nx,ny)
showhist = false;
nBin = 128; %histogram bins
%% get data
[data, tick64] = readNeoSpool(spoolfn,nx,ny);
nFrame = size(data,3);
%% histogram
if showhist
    figure(2),clf(2)
    hist(single(data(:)),nBin),set(gca,'yscale','log')
    title(['Histogram of ',spoolfn,' ',int2str(nBin),' bins'])
    xlabel('data number'), ylabel('occurences')
end
%% video
figure(2),clf(2)
hi=imagesc(data(:,:,1));
ht=title(['FPGA tick #',int2str(tick64(1))]);
colormap('gray')
clim = prctile(single(data(:)),[1,99.9]); % single() needed for Matlab R2015b et al
set(gca,'clim',clim)
colorbar

for i = 1:nFrame
    set(hi,'cdata',data(:,:,i))
    set(ht,'string',['FPGA tick #',int2str(tick64(i))])
    pause(0.25)
end


end