function angdistdeg = angledist(az1,el1,az2,el2)
%%
% computes angular distance for a pair of points given the azimuth, elevation of each
% point.  
% A demonstration of calling Python functions from Matlab R2014b or newer
%
% input and output are in DEGREES
%
% Michael Hirsch

try
    ud = py.astropy.units.deg;
    angdist = py.astropy.coordinates.angle_utilities.angular_separation(az1*ud,el1*ud,az2*ud,el2*ud);
    angdistdeg = angdist.to(ud).value;
catch e
    if verLessThan('matlab','8.4')
        error('Python is not available in Matlab older than R2014b')
    elseif strcmp(e.identifier,'MATLAB:undefinedVarOrClass')
        disp('do you have AstroPy installed in your Python path?')
        disp(py.sys.path)
        rethrow(e)
    else
        rethrow(e)
    end   
end
