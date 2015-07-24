function angdistdeg = angledist(az1,el1,az2,el2)
%%
% computes angular distance for a pair of points given the azimuth, elevation of each
% point. 
% A demonstration of calling Python functions from Matlab R2014b or newer
% Michael Hirsch

try
    angdistdeg = py.haversine.angledist(az1,el1,az2,el2);
catch
    % add the path to the https://github.com/scienceopen/pymap3d package
    P = py.sys.path;
    P.append('../pymap3d')
    angdistdeg = py.haversine.angledist(az1,el1,az2,el2);
end