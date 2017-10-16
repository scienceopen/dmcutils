function NeoImageJmontage(DataDir)
% makes montages using ImageJ macros -- quick and easy
% easiest way to use: copy ImageJmontage.txt to image directory, and execute from that directory

origDir = pwd;
copyfile('ImageJmontage.txt',[DataDir,'/']);


if ~ismatlab
    pkg load image
    page_screen_output(0);
    page_output_immediately(1);
end

% get directory listing
display(['listing directory ',DataDir])
tic
[err,DataFN] = unix(['ls ',DataDir]);
if err, error(['Could not stat ',DataDir]), end
DataFN = textscan(DataFN,'%s'); 
DataFN = DataFN{1};
nDataFile = length(DataFN);
display(['Retrieved list of ',int2str(nDataFile),' spool files in ',...
		num2str(toc,'%0.1f'),' seconds'])

% do montages one by one
cd(DataDir)
tmpFN = 'MontTmp.png';
 delete(tmpFN);
for j = 1:nDataFile
currFile = DataFN{j}
[~,head,ext] = fileparts(currFile);
if ~strcmpi('.fits',ext), continue, end
% (1) ImageJ: open file, make montage, save MontTmp.png
 ijc = ['/cygdrive/c/"Program Files"/ImageJ/ImageJ.exe ',currFile,' -macro ImageJmontage.txt'];
  display(ijc)
 err = unix(ijc);
 pause(30)
 if err, error(err), end

 % (2) rename MontTmp.png
 ej = 0; err=1;
 while err
 ej = ej+1;
 if mod(ej,20)==0, display(['File ',currFile,' is taking an excessive time to process']), end
  pause(1)
 err = unix(['mv MontTmp.png ',['montage-',head,'.png'],' > /dev/null 2>&1']);
 if ej>30, 
 warning('skipping this file ',currFile,', moving on'), 
 err=0; 
 unix(['/cygdrive/c/"Program Files"/ImageJ/ImageJ.exe -eval ''close(); close(); close(); close();'])
 end
 end %while

 end %for j = 1:nDataFIle
cd(origDir)
end