function value = guidtard(Fig, destname)

% Reads data from an FDIdent GUI figure with Tag Fig.
% The data is stored in the userprop destname. 

v=version;

hFig=findall(0, 'tag', Fig);
if isempty(hFig)
   value='';
else
  if str2num(v(1:3))<6.0
    value=getuprop(hFig, destname);
  else
    value=getappdata(hFig, destname);
  end
end

