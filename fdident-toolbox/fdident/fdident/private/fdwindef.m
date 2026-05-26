function fdwindef(hWin)
% set FDTool windows' default properties 
% helper file of fdtool

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 23-Feb-2001

hMainFig=findobj(allchild(0), 'flat', 'tag', 'fdtool_main');

if nargin == 0  % INIT
   if strcmp(computer, 'PCWIN')
      FONTNAME='arial';
   else
      FONTNAME='helvetica';
   end
   dx=105;
   hTestUi=uicontrol('parent', hMainFig, ...
      'string', 'Deselect improper', ...
      'fontname', FONTNAME, ...
      'unit', 'pixel', ...
      'position',  [10, 10, dx, 20],...
      'style', 'pushbutton', ...
      'tag', 'test');
   
   fsize=get(hTestUi, 'fontsize')+2;
   set(hTestUi, 'fontsize', fsize)
   ext=get(hTestUi, 'extent');
   % find aproppriate fontsize for the Test Ui
   MIN_FONTSIZE=7;
   if strncmp(computer, 'MAC', 3)
      fsize=9; % this is the setting for mac: extent doesn't work properly, we can't measure
   else
      while (ext(3)>dx) & (fsize >= MIN_FONTSIZE+1)
         fsize=fsize-1;
         set(hTestUi, 'fontsize', fsize)
         pause(0)
         ext=get(hTestUi, 'extent');
      end
   end
   set(hMainFig, 'defaultuicontrolfontsize', fsize)
   set(hMainFig, 'defaultuicontrolfontname', FONTNAME)
   set(hMainFig, 'defaulttextfontsize', fsize)
   set(hMainFig, 'defaulttextfontname', FONTNAME)
   set(hMainFig, 'defaultaxesfontsize', fsize)
   set(hMainFig, 'defaultaxesfontname', FONTNAME)
   %
   delete(hTestUi)
else
   if ishandle(hMainFig)
      fields={...
            'defaultuicontrolfontsize',...
            'defaultuicontrolfontname', ...
            'defaulttextfontsize', ...
            'defaulttextfontname', ...
            'defaultaxesfontsize', ...
            'defaultaxesfontname', ...
         };
      for ii=1:length(fields)
         act_prop=fields{ii};
         set(hWin, act_prop, get(hMainFig, act_prop)) 
      end
      %
      fsize=get(hMainFig,'defaulttextfontsize');
      FONTNAME=get(hMainFig,'defaulttextfontname');
      hax=findall(hWin,'type','axes');
      set(hax,'fontsize', fsize,'fontname', FONTNAME)
      htxt=findall(hWin,'type','text');
      set(htxt,'fontsize', fsize,'fontname', FONTNAME)
      %
      
    else
      if guiinfos('isdevelopment')   
         warning('Fdwindef: missing fdtool main window.')
      end
   end
end
