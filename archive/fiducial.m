function fiducial(ax)
hold(ax,'on')
        
        mz = [1290 1080]/2;
        gz = [1270 1920]/2;
        azshift = 19.7;
        ppd = 69/2;
        
        plot(ax,mz(1),mz(2),'ro','MarkerFaceColor','r');
        plot(ax,gz(1),gz(2),'go','MarkerFaceColor','g');
        
        % plot circles of geographic zenith
        els = [85 80 75 70 65 60];
        azs = [30 60 90 120 150 180 210 240 270 300 330 360];
        
        for n = 1:length(els),
            degs = 90 -  els(n);
            pix = degs * ppd;
            rx = zeros(1,360);
            ry = zeros(1,360);
            for nn = 1:360,
                rx(nn) = gz(1) + pix*sind(nn);
                ry(nn) = gz(2) + pix*cosd(nn);
            end
            plot(ax,rx,ry,'w:');
            text(rx(150),ry(150)+30,sprintf('%02d^o',els(n)),'Color','w','FontSize',12);
        end
        
        for n = 1:length(azs),
            rx = zeros(1,50);
            ry = zeros(1,50);
            for nn = 1:50,
                rx(nn) = gz(1) - (nn-1)*25*sind(azs(n)-azshift);
                ry(nn) = gz(2) + (nn-1)*25*cosd(azs(n)-azshift);
            end
            plot(ax,rx,ry,'w:');
            text(rx(32)+5,ry(32),sprintf('%d^o',azs(n)),'Color','w','FontSize',12);
            
        end
end