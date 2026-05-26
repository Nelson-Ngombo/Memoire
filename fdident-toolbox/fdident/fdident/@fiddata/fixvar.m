function fixvar(dat)
%FIXVAR make complex variance from real ones

date=dat.date;
varu=get(dat,'inputvariance');
if isnumeric(varu), varu=varu*2;
else
  for ii=1:length(varu), varu{ii}=varu{ii}*2; end
end
set(dat,'inputvariance',varu)
%
vary=get(dat,'outputvariance');
if isnumeric(vary), vary=vary*2;
else
  for ii=1:length(vary), vary{ii}=vary{ii}*2; end
end
set(dat,'outputvariance',vary)
cuy=get(dat,'covvect');
if isnumeric(cuy), set(dat,'covvect',cuy*2), end
dat.SisoVariance;
dat.date=date;
assignin('caller',inputname(1),dat)