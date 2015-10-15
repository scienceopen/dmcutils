function expanded = expanduser(p)
%
% For now, handles only a leading tilde, does not currently handle specifying ~otheruser
% example:
% expanduser('~/Downloads/foo')
% ans = /home/joespc/Downloads/foo
%
if ischar(p) && size(p,1) == 1
    if strcmp(p(1),'~')
        expanded = [getenv('HOME'),p(2:end)];
    end
else
    error('i only handle non-arrays strings for now')
end
end
