% This program is somewhat non-sensical, just use
% ../NeoPacked12bitToFITS.m 

% quickly try to read CMOS data (12 bits packed)
% inputs
% -------
% topdir: directory to scan for spool files 

function sCMOScreatemovie(topdir)

d0 = dir([topdir,filesep, '1103*']);

denoise = true; 

fps = [1 1 5 5 1 50 1 1 2 2 10 10 10 10 10 10 10 ...        % 01 MAR 2011 experiment
    6.667 0 0 0 0 7 7 6.2];                                   % 02 MAR 2011 experiment
cmax = [1000 1000 300 300 1000 200 2000 2000 1000 1000 ...
    150 250 250 20 220 250 250 200 300 1 ...
    1 1 300 300 250 ];

for j = 6, %:length(d0),
    
    if d0(j).isdir,
        
        datadir = [topdir d0(j).name '/'];
        
        starttime = fn2time(d0(j).name);
        
        d = dir([datadir '*.dat']);
        
        %         if exist(sprintf('%sImage_%04d.jpg',datadir,length(d)),'file'),
        %             fprintf('Folder %s seems to be done already - skipping\n',datadir);
        %             continue;
        %         end
        
        % image sizes:
        
        if j < 12,
            imsize = [2544 2160];
            darkfn = '../CMOS/flats_and_darks/dark_1s_fullframe_280MHz_hix30.dat';
            flatfn = '../CMOS/flats_and_darks/flat_5ms_fullframe_280MHz_hix30_diffuser.dat';
        elseif j<=22
            imsize = [1776 1760];
            darkfn = '../CMOS/flats_and_darks/dark_1s_1776x1760_280MHz_hix30.dat';
            flatfn = '../CMOS/flats_and_darks/flat_5ms_1776x1760_280MHz_hix30_diffuser.dat';
        elseif j > 22,
            imsize = [2544 2160];
            darkfn = '../CMOS/flats_and_darks/dark_1s_fullframe_280MHz_hix30.dat';
            flatfn = '../CMOS/flats_and_darks/flat_5ms_fullframe_280MHz_hix30_diffuser.dat';
        end %if
        data2 = zeros(imsize);
        data3 = bin2x2(data2);
        
%% figure set up
        h1 = figure(1);
        set(h1,'units','normalized','position',[0.1 0.1 0.8 0.8],'Paperposition',[1 1 9 6]);
        set(h1,'color',[1 1 1]);
        ax = axes;
        set(ax,'fontname','arial','fontsize',16);
        im1 = imagesc(data3','parent',ax);
        set(ax,'xticklabel',[],'yticklabel',[]);
        cax = colorbar('peer',ax);
        set(cax,'fontname','arial','fontsize',14);
        c = colormap('bone');
        c2 = brighten(c,0.3);
        colormap(ax,c2);
        axis(ax,'xy');
        ti1 = title(ax,datestr(starttime,'yyyy/mm/dd, HH:MM:SS.FFF'));
        
        %% plot zeniths and circles
        fiducial(ax)
        %% process flat and dark
        [flat,dark] = flatdark(flatfn,darkfn);

        %flat = 0.25 * (flat0(1:2:end,1:2:end) + flat0(1:2:end,2:2:end) + flat0(2:2:end,1:2:end) + flat0(2:2:end,2:2:end));
                
        % giffile = [datadir 'CMOS_' d0(j).name '.gif'];
       
        %%
        screen = cornerzero(imsize);
       
        caxis(ax,[10 cmax(j)]);

        
        for m = 1:length(d),
            
            datafile = [datadir d(m).name];
            
            data1 = readCMOSdata(datafile,imsize);
            
            % de-noising! very slow if I denoise then bin; faster if I bin
            % first, but I think it's better to denoise the original data.
            
            if denoise
                [thr,sorh,keepapp] = ddencmp('den','wv',data1);
                xd = wdencmp('gbl',data1,'sym8',2,thr,sorh,keepapp);
                
                %xd = medfilt2(data1,[10 10]);
            end
            
            data2 = (double(xd) - dark) .* screen ./ flat;
             
            newtime = starttime + 1/fps(j)/86400; %TODO is this correct?
            
            data3 = bin2x2(data2);
            set(im1,'CData',data3');
            
            set(ti1,'string',datestr(newtime,'yyyy/mm/dd, HH:MM:SS.FFF'));
            
            drawnow;
            
            %print(h1,'-djpeg',sprintf('%sImage_%04d.jpg',datadir,m));
            
        end
        
        close(h1);
        
    end
    
end %for
end %function
