function fixpopups(hWin)

if strncmp(version,'7.0.4',5)
  hpopups=findall(hWin,'type','uicontrol','style','popupmenu');
  for hpopup=hpopups(:)'
    if ishandle(hpopup)&strcmp(get(hpopup,'enable'),'on')
      %bypass inactive popup menu problem in Matlab 7.0.4
      %if strcmp(get(hpopup,'tag'),'gfdd_uic_linloghpop')
      set(hpopup,'enable','inactive'), drawnow %unfortunately, this is necessary!
      set(hpopup,'enable','on'), drawnow
    end
  end
end
