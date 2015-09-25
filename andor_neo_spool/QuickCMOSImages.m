% this program is somewhat non-sensical,
%  Just use ../NeoPacked12bitToFITS.m

% quickly try to read CMOS data

clear

datadir = '~/data/CMOS/110301_1009/';
fn = '110301_1009';
cutcorners=false;
choosefile = 250;
dodenoise=false;
%%
starttime = fn2time(fn);

d = dir([datadir '*.dat']);

imsize = [2544 2160];
darkfn = [datadir,'../flats_and_darks/dark_1s_fullframe_280MHz_hix30.dat'];
flatfn = [datadir,'../flats_and_darks/flat_5ms_fullframe_280MHz_hix30_diffuser.dat'];
framesize = 'full';

%% process flat and dark
[flatnorm,dark] = flatdark(flatfn,darkfn,imsize);
%% screen to cut off corners 
% is this just setting to zero regions outside of the optical field presented by
% the lens?
screen = cornerzero(imsize,cutcorners);
%% read spool files
datafile = [datadir d(choosefile).name];
dataraw = readCMOSdata(datafile,imsize);
%% de-noising
% very slow if I denoise then bin; faster if I bin
% first, but I think it's better to denoise the original data.
if dodenoise
    [thr,sorh,keepapp] = ddencmp('den','wv',dataraw);
    xd = wdencmp('gbl',dataraw,'sym8',2,thr,sorh,keepapp);
    datasc = (xd - dark) ./ flatnorm; % .* screen
else
    datasc = (dataraw-dark); %TODO: no flat field yet
end

%data1a = (data1 - dark) ./ flatnorm;

%% plot results
close('all')

h1 = figure(1);
set(h1,'position',[200 200 800 600]);
ax = axes;
imagesc(datasc,'parent',ax); axis(ax,'xy');
xlabel(ax,'Pixels x');
ylabel(ax,'Pixels y');
title('debiased data')
%title(ax,'Denoised, calibrated, masked data');

%{
c = colormap(hot);
cb = [c(:,2), c(:,1), c(:,3)];      % blue version!
c2 = brighten(cb,0.5);
colormap(ax,c2);
caxis(ax,[0 300]);

set(ax,'ylim',[2480 2542]);
%}