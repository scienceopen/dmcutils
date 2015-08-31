function angdistdeg = angledist(az1,el1,az2,el2)
%%
% computes angular distance for a pair of points given the azimuth, elevation of each
% point. 
% A demonstration of calling Python functions from Matlab R2014b or newer
%
% Assumes https://github.com/scienceopen/pymap3d is in adjacent directory ../pymap3d
%
% Michael Hirsch

try
    angdistdeg = py.haversine.angledist(az1,el1,az2,el2);
catch
    if verLessThan('matlab','8.4')
        error('Python is not in Matlab older than R2014b')
    end
    
    % add the path to the https://github.com/scienceopen/pymap3d package
    P = py.sys.path;
    P.append('../pymap3d')
    angdistdeg = py.haversine.angledist(az1,el1,az2,el2);
end
