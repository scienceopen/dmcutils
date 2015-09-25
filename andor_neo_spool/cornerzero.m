function screen = cornerzero(imsize)      
% screen to cut off corners
        
        mi = imsize/2;
        hyp = hypot(mi(1),mi(2));
        
        screen = ones(imsize);
        
        if imsize(1) == 2544,
            for ii = 1:imsize(1),
                for jj = 1:imsize(2),
                    dist = hypot(mi(1)-ii,mi(2)-jj);
                    if dist > (hyp - 270),
                        screen(ii,jj) = 0;
                    end
                end
            end
        end
end