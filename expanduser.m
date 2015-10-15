function expanded = expanduser(p)
%%
% For now, handles only a leading tilde, does not currently handle specifying ~otheruser
% example:
% expanduser('~/Downloads/foo')
% ans = /home/joespc/Downloads/foo
%
% Useful for Matlab functions like h5read() and some Computer Vision toolbox functions
% that can't handle ~ and Matlab does not consider it a bug per conversations with 
% Mathworks staff
%
% Michael Hirsch
%

home = getenv('HOME');
if isempty(home)
    warning('empty HOME environment variable, returning unmodified path')
    expanded =p;
    return
end %if

if ischar(p) && size(p,1) == 1
    if strcmp(p(1:2),'~/') || strcmp(p(1:2),'~\')
        expanded = [getenv('HOME'),p(2:end)];
    elseif ~isempty(regexp(p,'~.*/')) || ~isempty(regexp(p,'~.*\\'))
        warning('the ~otheruser case is not handled yet')
        expanded = p;
    else
        expanded = p; 
    end %if
else
    warning('i only handle non-arrays strings for now')
    expanded = p;
end %if

end %function
