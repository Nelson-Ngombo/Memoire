function guidtawr(Fig, destname, fromType, varname)

% Stores data to an FDIdent GUI figure with Tag Fig.
% The data is stored to the userprop destname. The data
% can either be loaded from workspace ('wp'), file ('file'), 
% or can be a direct value ('direct') indicated by the fromType 
% string. The name of the variable or file is contained by varname.

v=version;
hFig=findall(0, 'tag', Fig);

switch lower(fromType) 
case 'wp'
  if str2num(v(1:3))<6.0
    evalin('base',['setuprop(' sprintf('%3.10f',hFig) ', ''' destname ''', ' varname ')'] )
  else
    evalin('base',['setappdata(' sprintf('%3.10f',hFig) ', ''' destname ''', ' varname ')'] )
  end
case 'file'
  
case 'direct'
  
  if str2num(v(1:3))<6.0
    setuprop(hFig, destname, varname);
  else
    setappdata(hFig, destname, varname);
  end    
  
otherwise
  errordlg('Unknown data type', 'Error','replace')
  
end %switch
