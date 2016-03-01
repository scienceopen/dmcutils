function oct = isoctave()
%Michael Hirsch
% tested with Octave 3.6-4.0 and Matlab R2012a-R2016a

oct = exist('OCTAVE_VERSION', 'builtin') == 5;

end
