function NeoSpoolPlayer(fn)

nBin = 128; %histogram bins

[data tick64 nFrame] = NeoSpoolReader(fn);

figure(1)
h.img = imagesc(data(:,:,1));
h.t = title(['FPGA tick #',int2str(tick64(1))]);
colormap('gray')

figure(2)
hist(single(data(:)),128),set(gca,'yscale','log')
title(['Histogram of ',fn,' ',int2str(nBin),' bins'])
xlabel('data number'), ylabel('occurences')

for i = 2:nFrame
    set(h.img,'cdata',data(:,:,i))
    set(h.t,'string',['FPGA tick #',int2str(tick64(i))])
    pause(0.25)
end


end