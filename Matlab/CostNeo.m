neo.xpix=400; neo.ypix = 400;
neo.fps=40; neo.name = "Andor Neo";

ultra.xpix=512; ultra.ypix=512;
ultra.fps=52; ultra.name='Andor Ultra 897';

for c = [neo ultra]
    disp(['cost in Bytes for ',c.name])
    sec = c.xpix*c.ypix*2*c.fps
    hour = sec*3600
    night = 12*hour
    month=30*night
    disp(['nightly ',num2str(night/1e9),' GB.   Monthly ',num2str(month/1e12),'  TB'])
    disp('')
endfor