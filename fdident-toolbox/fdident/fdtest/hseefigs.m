%HSEEFIGS
%Show fig results of hinittest

pause on
if exist('d'), dmin=d; else dmin=1; end
%if dmin>15, dmin=1; end
for d=dmin:15
  hgload(sprintf('fig%.0f',d));
  pause
  %print
  if ~exist(sprintf('fig%.0f.fig',d+1)), break, end
end
