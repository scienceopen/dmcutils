function NeoKeogramExtraction(DataDir,varargin)
%This progam is the Neo version of the KeogramExtraction.m program.
% this program makes keogram of data files in ONE directory
% data files may be FITS or multipage TIFF
% program relies on ImageJ to extract frames from FITS and TIFF
%
% Designed for Cygwin on Windows 7 with Octave and ImageJ
% Michael Hirsch Dec 2012
%
% INPUTS:
% -----------
% DataDir: where TIFF/FITS camera files reside
% TempDir: where to put temp files (e.g. /dev/shm/temp)
warning('this program not complete, not functional')

P = length(varargin);
if P>0 && ~isempty(varargin{1}), TempDir = varargin{1}; else TempDir = '/dev/shm/temp'; end


data.keogramColumnWidth = 5;
data.displayKeo = true; %usually false

%% preprocessing
% we use ImageJ to make a temporary folder with selected frame from the many FITS files
% (1) list all FITS/TIFF files in main directory
% (2) for each of these files, extract temporary single TIFF slices, put in temp dir, using ImageJ
% (3) run displayKeogram.m on the slices
% (4) delete slices, move on to next FITS/TIFF file
% (5) display grand keogram
% 

% (1) list all files
 AllFN = dir(DataDir);
 

% (3) make keogram
displayKeogram2(DataDir,data)

% (4) delete slices
 


end