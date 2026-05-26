function msg=fitinfodiff(fit1,fit2)
%FITINFODIFF Compare fitinfo values

msg='';
f1=fieldnames(fit1);
f2=fieldnames(fit2);
if ~isequal(f1,f2), msg='fields differ'; return, end
for ii=1:length(f1)
  v1=getfield(fit1,f1{ii}); v2=getfield(fit2,f2{ii});
  if ~isequal(v1,v2) & (~isnumeric(v1)|~isnumeric(v2)|~isnan(v1)|~isnan(v2))
    disp(['fit1.',f1{ii}]), eval(['fit1.',f1{ii}])
    disp(['fit2.',f2{ii}]), eval(['fit2.',f2{ii}])
    return
  end
end
