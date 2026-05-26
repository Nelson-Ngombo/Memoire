function fdtstplt(modestr, data)
%FDTSTPLT Test plots for automatic tests
% fdtstplt(modestr, data)
% modestr: 'before', 'after' or 'in'
% print if performed in the following cases:
% modestr='before' & the recorder is in test plot mode & the object described in data
%    is in the BeforeData list
% modestr='after' & the recorder is in test plot mode & the object described in data
%    is in the AfterData list
% modestr='in' & the recorder is in test plot mode. In this case the data contains
%    the window tag.
% modestr='print'. Unconditional print. The tag of the figure is input var data.
% NB: Only visible windows are printed.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 11-Jun-1999, GYS

PlotNeed=0;
if guiinfos('isrecorderplayback') & guirecrd('GetTestPlotMode')      
   % data stuct: cell array of struct with fields Win (wintag) and Obj (objtag)
   % if the Win field is '*', all the windows are considered
   
   % BeforeData contains ID's of objects. Print is performed BEFORE activating an obj in the list
   BeforeData={...
         struct('Win', 'excitation_main', 'Obj', 'essd_uic_donepb');
      struct('Win', 'getfreq_main', 'Obj', 'gfdd_uic_donepb');
      struct('Win', 'average_main', 'Obj', 'agv_uic_donepb');
      struct('Win', 'select_main', 'Obj', 'sme_uic_donepb');
      struct('Win', 'aided_main', 'Obj', 'sme_uic_donepb');
      struct('Win', 'compare_main', 'Obj', 'caem_uic_donepb');
      struct('Win', 'segmentfig', 'Obj', 'segmentdone');
      struct('Win', 'freqselfig', 'Obj', 'freqsel_uic_donepb');
      struct('Win', 'freqsel2fig', 'Obj', 'freqsel_uic_donepb');
      struct('Win', 'fdsimulation_main', 'Obj', 'fdsimul_uic_donepb')
   };
   %  struct('Win', '*', 'Obj', 'fdtool_dismiss_pb'); removed
   %  because auto test plot mode is implemented for windows with dismiss_pb
   
   
   %struct('Win', 'gettime_main', 'Obj', 'gettime_button_done');
   %struct('Win', 'fdtool_importfig', 'Obj', 'import_pb');
   AfterData={...
         struct('Win', 'getfreq_main', 'Obj', 'gfdd_uic_linloghpop') ...
      };  % ez csak mintanak van itt a teszthez
   
   switch modestr
   case 'before'
      if InData(BeforeData, data)
         PlotNeed=1;
      end
   case 'after'
      if InData(AfterData, data)
         PlotNeed=1;
      end
   case 'in'
      data.Win=data; % input is wintag now, make similar struct for the rest
      PlotNeed=1;
   end
end

if strcmpi(modestr, 'print')
   data.Win=data; % input is wintag now, make similar struct for the rest
   PlotNeed=2;
end


if PlotNeed
   hWin=findobj(allchild(0), 'flat', 'tag', data.Win);
   if ishandle(hWin)
      if strcmpi(get(hWin, 'visible'), 'on')
         figure(hWin)
         disp(['Test Plotting Window ''' get(hWin, 'name') ''''])
         guirecrd('status', '$cTest plot in progress...');
         
         % add extra info on plot
         histdata=guirecrd('GetHistData');
         if PlotNeed==2 % unconditional plot
            PlotText=['Title: ' get(hWin, 'Name'), ', ', ...
                  'Date: ', datestr(now) '.'];        
         else % test plot with recorder
            PlotText=['HistFile: ' guirecrd('GetSourceName'), ', ' ...
                  modestr, ' step ', num2str(histdata.index), ...
                  '/', num2str(length(histdata.history)), ', ', ...
                  'Title: ' get(hWin, 'Name'), ', ', ...
                  'Date: ', datestr(now) '.'];        
         end
         hPlotInfo=uicontrol('parent', hWin, ...
            'style', 'text', 'position', [1 1 100 20], ...
            'backgroundcolor', [1 1 1], 'foregroundcolor', [1 0 0], ...
            'string', PlotText);
         
         set(hPlotInfo, 'position', get(hPlotInfo, 'extent'))
         
         fdgprint(data.Win, 'psc','-append')
         delete(hPlotInfo) % remove plot info
         guirecrd('status', 'Test plot ready');
      else
         % invisible windows are not printed
      end
   else
      disp(['Test Plot of Window ''' get(hWin, 'name') ''' failed. Problem: missing window.'])
   end
end


function out=InData(list, item)
out=0;
for ii=1:length(list)
   if (strcmp(list{ii}.Win, item.Win) | strcmp(list{ii}.Win, '*'))& ...
         strcmp(list{ii}.Obj, item.CurObj)
      out=1;
      return
   end
end
%
