function starttime = fn2time(fn)

yy = 2000 + str2double(fn(1:2));
mm = str2double(fn(3:4));
dd = str2double(fn(5:6));
hh = str2double(fn(8:9));
mn = str2double(fn(10:11));
ss = 0;
if length(path) > 11,
    second = 30;
end

starttime = datenum(yy,mm,dd,hh,mn,ss);