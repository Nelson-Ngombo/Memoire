function guiready(hFig, fcn)
% fdtool statusbar clear if timeout reached

lastupdate=get(hFig,'userdata');  
if isempty(lastupdate), return, end
if isstr(lastupdate) & findstr(lastupdate, 'hold')
   return
end
if strncmp(version,'5.2',3), v='5_2'+0; else v=''; end
if eval('etime(clock,lastupdate) > 3', '0')
   pointersh=get(hFig,'pointer');
   if strcmp(pointersh, 'arrow')
      feval(fcn, 'status', 'Ready.')
      msg=fdident('private',[102 100 99 102 115, v],fcn);   
   end
end