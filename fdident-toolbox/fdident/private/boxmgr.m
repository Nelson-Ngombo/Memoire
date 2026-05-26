function permission=boxmgr(command, window, p3)
%BOXMGR Box and arrow manager for fdident GUI
%       handles colors of the flowcharts in fdtool_main and gettime_main windows
%
%       Data structure:
%       BOXMGR uprop is an array of structure:  
%         name:   object name (e.g. rect_gettime)
%         level:  number from 1 to 7 (fdtool_main) or to 4 (gettime_main)
%         status: 's'electable, 'd'one or 'u'nselectable, and may temporarily 
%            be in busy state ('sb' or 'db')
%       ARRMGR uprop is an array of chars (one for each arrow-piece):  
%         a: active data, p: passive data, -: no data on the arrow
%         A: loaded active data, P: loaded passive data
%
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 20-Sep-2001, GYS

if nargin<2, window=''; end
switch window
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   %
   %   MAIN WINDOW
   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'fdtool_main'
   % read state variables  
   boxstr=guidtard('fdtool_main', 'BOXMGR');
   arrowstr=guidtard('fdtool_main', 'ARRMGR');
   
   
   if findstr('click_on_',command)
      objname=command(10:length(command));
      index=indexofobject(objname, boxstr);
      act_status=boxstr(index).status;
      
      busy=0;
      for ix=1:length(boxstr)
         if findstr(boxstr(ix).status, 'b')
            busy=ix;
         elseif findstr(boxstr(ix).status, 's')&strcmp(boxstr(ix).name,'rect_average')&...
             (length(findall(0,'type','figure','tag','average_main','visible','off'))>0)
           busy=ix; %agv is hidden because of signal type all
         end
         
      end
      
      if (strcmp(act_status, 's') | strcmp(act_status, 'd')) & ~busy
         permission=1;
      else
         permission = 0;
         if strcmp(act_status, 'u')
            if strcmp(objname,'excitation')
               msg='$yThis block cannot be opened when UserLevel is Automatic.';
            else
               msg='$yThis block cannot be opened since there is no valid data on its input arrow.';
            end
            fdtool('status', msg);
         elseif findstr(act_status, 'b')
            h=findall(0,'tag',[objname '_main'], 'visible', 'on');
            if ~isempty(h)
               fdtool('status', 'This block is already open. Bringing to front...');
               figure(h)
            else 
               permission=1;
            end
%            fdtool('status', 'Done.');
         elseif busy
            name=[boxstr(busy).name(6:end) '_main'];
            fdtool('status', ['Another block is already open']);
            if guiinfos('isrecorderplayback')
               answer='Continue';
            else
               answer=questdlg(sprintf...
                  (['Another block is already open. \nIf you proceed, it will be closed, '...
                     'and you will lose all unsaved changes in it. '...
                     'Do you wish to continue ?']), ...
                  'Open a new box', 'Continue', 'Cancel', 'Continue');
            end
            if strcmp(answer, 'Continue')
               h=findall(0, 'tag', name);
               
               %%%%%%%%%%%%%% Matlab suggests delete instead%%%%%%%%%%%%%%%%
               close(h)
               %delete(h)
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               permission=1;
               boxstr(busy).status=boxstr(busy).status(1);
               % for safety reasons.  Recover from breakdown
               switch boxstr(busy).status
               case 's'
                  fdtool('setbox',boxstr(busy).name, guicolor('BOX_COLOR_SELECTABLE')); drawnow
               case 'd'
                  fdtool('setbox',boxstr(busy).name, guicolor('BOX_COLOR_DONE')); drawnow
               otherwise
                  fdtool('setbox',boxstr(busy).name,guicolor('BOX_COLOR_UNSELECTABLE')); drawnow
               end
            end
         end
      end
      if permission
         boxstr(index).status=[act_status 'b'];
         fdtool('setbox',['rect_' objname],guicolor('BOX_COLOR_BUSY'));drawnow
      end
%      fdtool('status', 'Ready.');
      %      switch objname
      %      case 'excitation'
      %      case 'gettime'
      %      case 'getfreq'
      %      case 'average'
      %      case 'select'
      %      case 'aided'
      %      case 'compare'
      %      end  %objname
      
   elseif findstr('end_of_',command)
      % p3 is updatemode:
      % NEWDATA: new data arrived from the previous block
      % UPDATE: the arrow is only activated
      % LOADEDDATA
      
      updatemode=p3;
      
      objname=command(8:length(command));
      index=indexofobject(objname, boxstr);
      
%      if strcmp(updatemode, 'NEWDATA') | strcmp(updatemode, 'LOADEDDATA')
         % next block is selectable (in case of UPDATE it is already OK)
         actlevel=boxstr(index).level;
         for ix=1:length(boxstr)
            if boxstr(ix).level == 1 + actlevel
               boxstr(ix).status='s';
               fdtool('setbox',boxstr(ix).name, guicolor('BOX_COLOR_SELECTABLE'))
            end
         end
%      end
     
      if strcmp(updatemode, 'NEWDATA')
         % actual block becomes 'done'
         boxstr(index).status='d';
         fdtool('setbox',boxstr(index).name, guicolor('BOX_COLOR_DONE'))
         
      elseif strcmp(updatemode, 'LOADEDDATA')
         % actual block becomes selectable if it was done
         if strcmp(boxstr(index).status, 'd')
            boxstr(index).status='s';
            fdtool('setbox',boxstr(index).name, guicolor('BOX_COLOR_SELECTABLE'))
         end
      end
      
      pair=0;
      switch objname
      case 'excitation'
        if strcmp(guiinfos('UserLevel'),'Automatic')|~guiinfos('ismeasurement')
          active=[1];
        else
          active=[1:3];
        end
      case 'gettime'
         active=4;
         pair=5;
      case 'getfreq'
         active=5;
         pair=4;
      case 'average'
         active=[6:8];
      case 'select'
         active=9;
         pair=10;
      case 'aided'
         active=[10];
         pair=9;
      case 'compare'
         active=[11];
      end  %objname
      
      actstr1='aaa'; actstr2='AAA';
      if strcmp(updatemode, 'UPDATE')
         if strcmp(arrowstr(active(1)), 'P') 
            % it is a previously loaded data, in update mode this property is preserved
            arrowstr(active)=actstr2(1:length(active));   
            fdtool('setline', active, guicolor('COLOR_ARR_ACTIVE_LOADED_DATA'))
         else
            arrowstr(active)=actstr1(1:length(active));   
            fdtool('setline', active, guicolor('COLOR_ARR_ACTIVE_DATA'))
         end            
      elseif strcmp(updatemode, 'NEWDATA')
         % forget old data on arrow
         arrowstr(active)=actstr1(1:length(active));   
         fdtool('setline', active, guicolor('COLOR_ARR_ACTIVE_DATA'))
      elseif strcmp(updatemode, 'LOADEDDATA')
         arrowstr(active)=actstr2(1:length(active));   
         fdtool('setline', active, guicolor('COLOR_ARR_ACTIVE_LOADED_DATA'))
      else
         error('BOXMGR internal error: Bad update mode.')
      end
      
      if pair % set parallel active line to passive, if necessary
         if strcmp(arrowstr(pair), 'a') 
            arrowstr(pair)='p';
            fdtool('setline', pair, guicolor('COLOR_ARR_PASSIVE_DATA'))
         elseif strcmp(arrowstr(pair), 'A')  % loaded data gets 'P' passive flag
            arrowstr(pair)='P';

            fdtool('setline', pair, guicolor('COLOR_ARR_PASSIVE_DATA'))
         end
      end
      guidtawr(window, 'BOXMGR', 'direct', boxstr)
      guidtawr(window, 'ARRMGR', 'direct', arrowstr)
      
      
      
      
   elseif findstr('cancel_of_',command)
      
      objname=command(11:length(command));
      index=indexofobject(objname, boxstr);
      if index
         boxstr(index).status=boxstr(index).status(1);
         switch boxstr(index).status
         case 'd'
            fdtool('setbox',['rect_' objname],guicolor('BOX_COLOR_DONE'));
         case 's'
            fdtool('setbox',['rect_' objname],guicolor('BOX_COLOR_SELECTABLE'));
         case 'b'
            fdtool('setbox',['rect_' objname],guicolor('BOX_COLOR_BUSY'));
         otherwise
            fdtool('setbox',['rect_' objname],guicolor('BOX_COLOR_UNSELECTABLE'));
         end
      else
         error(['Box manager cannot find item ' objname '.'])
      end  
      
   elseif findstr('delete_arrow_',command)  % delete arrow, and the previous box as well
      arrnumstr=command(14:end);
      arrnum=str2num(arrnumstr);
      prevbox_ix=0;
      for ixx=1:length(boxstr)
         if any(boxstr(ixx).outarr==arrnum)
            prevbox_ix=ixx;
         end
      end
      if prevbox_ix==0
         error(['Box manager cannot find item before arrow #' arrnumstr '.'])
      end
      nullstr='---';
      arrsnum=boxstr(prevbox_ix).arrownum;
      arrsix=boxstr(prevbox_ix).outarr(1:arrsnum);
      arrowstr(arrsix)=nullstr(arrsnum);
      
      fdtool('setline', arrsix, guicolor('COLOR_ARR_NODATA')); % set arrow color
      
      objname=boxstr(prevbox_ix).name;
      guidtawr(window, ['OUTPUT_' objname(6:end)], 'direct', ''); % clear arrow data
      guidtawr(window, ['STATUS_' objname(6:end)], 'direct', ''); % clear prev box's status data
      
      % find correct status of previous box
      input_prev_box=guidtard(window, ['INPUT_' objname(6:end)]);
      prev_prev_box=input_prev_box.from;
      prev_arrow_data=guidtard(window, ['OUTPUT_' prev_prev_box]);
      if isempty(prev_arrow_data) % if there is input data -> selectable, otherwise not
         status_prev='u';
      else
         status_prev='s';
      end
      if boxstr(prevbox_ix).level<=2  % exception: first three boxes are always selectable
         status_prev='s';
      end
      boxstr(prevbox_ix).status=status_prev;
      switch boxstr(prevbox_ix).status  % set box color
      case 'd'
         fdtool('setbox', objname, guicolor('BOX_COLOR_DONE'));
      case 's'
         fdtool('setbox', objname, guicolor('BOX_COLOR_SELECTABLE'));
      case 'b'
         fdtool('setbox', objname, guicolor('BOX_COLOR_BUSY'));
      otherwise
         fdtool('setbox', objname, guicolor('BOX_COLOR_UNSELECTABLE'));
      end
      
      % find correct status of the next box: if status=='s' -> status='u'
      if prevbox_ix>1  % first 3 boxes are always selectable
         next_boxes={input_prev_box.next1, input_prev_box.next2};
         for ixx=1:2
            next_box=next_boxes{ixx};
            if ~strcmp(next_box, '-')
               nextbox_ix=indexofobject(next_box, boxstr);
               
               input_next_box=guidtard(window, ['INPUT_' boxstr(nextbox_ix).name(6:end)]);
               source_of_nextbox=input_next_box.from;
               name_of_prev_box=objname(6:end);
               if any(findstr(boxstr(nextbox_ix).status, 's'))...
                   & strcmp(source_of_nextbox, name_of_prev_box)
                  boxstr(nextbox_ix).status='u';
                  fdtool('setbox', boxstr(nextbox_ix).name, guicolor('BOX_COLOR_UNSELECTABLE'));
               end
            end
         end
      end
      guidtawr(window, 'ARRMGR', 'direct', arrowstr)      % write back arrow status data
      fdtool('status', 'Arrow data deleted');
      
   elseif strcmp('excitmode',command)
      if strcmp(p3, 'off') & ~strcmp(boxstr(1).status, 'u')
         boxstr(1).status='u';
         fdtool('setbox',['rect_excitation'],guicolor('BOX_COLOR_UNSELECTABLE'));
      elseif strcmp(p3, 'on') & strcmp(boxstr(1).status, 'u')
         boxstr(1).status='s';
         fdtool('setbox',['rect_excitation'],guicolor('BOX_COLOR_SELECTABLE'));
      end

   elseif strcmp('freqmode',command)
      if strcmp(p3, 'off') & ~strcmp(boxstr(3).status, 'u')
         boxstr(3).status='u';
         fdtool('setbox',['rect_getfreq'],guicolor('BOX_COLOR_UNSELECTABLE'));
      elseif strcmp(p3, 'on') & strcmp(boxstr(3).status, 'u')
         boxstr(3).status='s';
         fdtool('setbox',['rect_getfreq'],guicolor('BOX_COLOR_SELECTABLE'));
      end

   elseif strcmp('init',command)
      names=strvcat(...
         'rect_excitation',...
         'rect_gettime',...
         'rect_getfreq',...
         'rect_average',...
         'rect_select',...
         'rect_aided',...
         'rect_compare');
      if strcmp(lower(guiinfos('userlevel')), 'automatic')
         statusvect='sssuuuu';
      else
         statusvect='sssuuuu';
      end
      levelvect=[1 2 2 3 4 4 5];
      arrownum =[3 1 1 3 1 1 1];
      outarrows=...
         [1 2 3;
         4, 0, 0;
         5, 0, 0; 
         6, 7, 8;
         9, 0, 0;
         10, 0, 0; 
         11, 0, 0];
      for ix=1:7
         initstruct(ix)=struct('name', deblank(names(ix,:)),...
            'status', statusvect(ix),...
            'arrownum', arrownum(ix),...
            'outarr', outarrows(ix,:),...
            'level', levelvect(ix));
      end
      
      guidtawr(window, 'BOXMGR', 'direct', initstruct)
      boxstr=initstruct;
      
      arrowstatus=['-' '-' '-' '-' '-' '-' '-' '-' '-' '-' '-'];
      guidtawr(window, 'ARRMGR', 'direct', arrowstatus)
      % clear output data if any
      guidtawr('fdtool_main', 'OUTPUT_excitation', 'direct', '')
      guidtawr('fdtool_main', 'OUTPUT_gettime',    'direct', '')
      guidtawr('fdtool_main', 'OUTPUT_getfreq',    'direct', '')
      guidtawr('fdtool_main', 'OUTPUT_average',    'direct', '')
      guidtawr('fdtool_main', 'OUTPUT_select',     'direct', '')
      guidtawr('fdtool_main', 'OUTPUT_aided',      'direct', '')
      guidtawr('fdtool_main', 'OUTPUT_compare',    'direct', '')
      
      % now set colors
      boxmgr('updatecolors', window)
      
   elseif strcmp('updatecolors',command)
      for ix=1:length(boxstr)
         switch boxstr(ix).status
         case 's'
            fdtool('setbox',boxstr(ix).name, guicolor('BOX_COLOR_SELECTABLE'))
         case 'u'
            fdtool('setbox',boxstr(ix).name, guicolor('BOX_COLOR_UNSELECTABLE'))
         case 'd'
            fdtool('setbox',boxstr(ix).name, guicolor('BOX_COLOR_DONE'))
         otherwise % busy
            fdtool('setbox',boxstr(ix).name, guicolor('BOX_COLOR_BUSY'))
         end %switch
      end %for boxstr
      
      fdtool('setline', findstr(arrowstr,'-'), guicolor('COLOR_ARR_NODATA'))
      fdtool('setline', findstr(arrowstr,'a'), guicolor('COLOR_ARR_ACTIVE_DATA'))
      fdtool('setline', findstr(arrowstr,'p'), guicolor('COLOR_ARR_PASSIVE_DATA'))
      fdtool('setline', findstr(arrowstr,'A'), guicolor('COLOR_ARR_ACTIVE_LOADED_DATA'))
      fdtool('setline', findstr(arrowstr,'P'), guicolor('COLOR_ARR_PASSIVE_DATA'))
   end  %if
   
   % write back state variables  
   if ~isempty(boxstr), guidtawr(window, 'BOXMGR', 'direct', boxstr), end
   
   
   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   %
   %   GETTIME WINDOW
   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
case 'gettime_main'
   
   boxstr=guidtard('gettime_main', 'BOXMGR');
   arrowstatus=guidtard('gettime_main', 'ARRMGR');

   
   
   if findstr('click_on_',command)
      objname=command(10:length(command));
      index=indexofobject(objname, boxstr);
      act_status=boxstr(index).status;
      
      busy=0;
      for ix=1:length(boxstr)
         if findstr(boxstr(ix).status, 'b')
            busy=ix;
         end
         
      end
      
      if (strcmp(act_status, 's') | strcmp(act_status, 'd')) & ~busy
         permission=1;
      else
         permission = 0;
         if strcmp(act_status, 'u'),
            gettime('status', 'This block cannot be opened.');
         elseif findstr(act_status, 'b')
            gettime('status', 'This block is already open. Bringing to front...');
            h=findall(0,'tag',[objname 'fig'], 'visible', 'on');
            if ~isempty(h)
               figure(h)
            else 
               permission=1;
            end
            gettime('status', ''); 
         else
            name=[boxstr(busy).name(6:end) 'fig'];
            gettime('status', ['Another block is already open: ' name]);
            if guiinfos('isrecorderPlayback')
               answer='Continue';
            else
               answer=questdlg(sprintf...
                  (['Another block is already open. \nIf you proceed, it will be closed, '...
                     'and you will lose all unsaved changes in it. '...
                     'Do you wish to continue ?']), ...
                  'Open a new box', 'Continue', 'Cancel', 'Continue');
            end
            if strcmp(answer, 'Continue')
               h=findall(0, 'tag', name);
               close(h)
               permission=1;
               boxstr(busy).status=boxstr(busy).status(1);
               % for safety reasons.  Recover from breakdown
               switch boxstr(busy).status
               case 's'
                  gettime('setbox',boxstr(busy).name, guicolor('BOX_COLOR_SELECTABLE')); drawnow
               case 'd'
                  gettime('setbox',boxstr(busy).name, guicolor('BOX_COLOR_DONE')); drawnow
               otherwise
                  gettime('setbox',boxstr(busy).name,guicolor('BOX_COLOR_UNSELECTABLE')); drawnow
               end
            end
         end
      end
      if permission
         boxstr(index).status=[act_status 'b'];
         gettime('setbox',['rect_' objname],guicolor('BOX_COLOR_BUSY')); drawnow
      end

      gettime('status', 'Ready.');

      
   elseif findstr('end_of_',command)
      % p3 is updatemode:
      % NEWDATA: new data arrived from the previous block
      % LOADEDDATA
      
      updatemode=p3;
      
      objname=command(8:length(command));
      index=indexofobject(objname, boxstr);
      

      if strcmp(updatemode, 'NEWDATA')
         boxstr(index).status='d';
         arrowstatus(index)='a';
      
         gettime('setbox',boxstr(index).name, guicolor('BOX_COLOR_DONE'))
         gettime('setline',index, guicolor('COLOR_ARR_ACTIVE_DATA'))
      else %LOADEDDATA

         if boxstr(index).status ~= 'u'
            boxstr(index).status='s';
            gettime('setbox',boxstr(index).name, guicolor('BOX_COLOR_SELECTABLE'))
         end
         arrowstatus(index)='A';
         gettime('setline',index, guicolor('COLOR_ARR_ACTIVE_LOADED_DATA'))
      end
      
      indmod=0;
      if index <4
        if strcmp(get(findobj(findall(0,'type','figure','tag','gettime_main'),'tag','arr12'),...
            'visible'),'on')&(index==1)
          %simplified block diagram: arr12 is seen
          indmod=1;
        end
        boxstr(index+1+indmod).status='s';
        gettime('setbox',boxstr(index+1+indmod).name, guicolor('BOX_COLOR_SELECTABLE'))
      end
      
      % next boxes and arrows will be deleted
      for ii=index+2+indmod:4
         if boxstr(ii).status ~= 'u'
            boxstr(ii).status = 'u';
            gettime('setbox', boxstr(ii).name, guicolor('BOX_COLOR_UNSELECTABLE'))
         end
      end
      
      gettime('setline', index+find(arrowstatus(index+1+indmod:4)~='-'), guicolor('COLOR_ARR_NODATA'))
      for ii=index+1+indmod:4
         arrowstatus(ii)='-';
      end
      guidtawr(window, 'BOXMGR', 'direct', boxstr)
      guidtawr(window, 'ARRMGR', 'direct', arrowstatus)
      
      
   elseif findstr('cancel_of_',command)
   
      objname=command(11:length(command));
      index=indexofobject(objname, boxstr);
      if index
         boxstr(index).status=boxstr(index).status(1);
         switch boxstr(index).status
         case 'd'
            gettime('setbox',['rect_' objname],guicolor('BOX_COLOR_DONE'));
         case 's'
            gettime('setbox',['rect_' objname],guicolor('BOX_COLOR_SELECTABLE'));
         otherwise
            gettime('setbox',['rect_' objname],guicolor('BOX_COLOR_UNSELECTABLE'));
         end
      else
         error(['Box manager cannot find item ' objname '.'])
      end  
      
      
   elseif findstr('delete_arrow_',command)  % delete arrow, and the previous box as well
      arrnumstr=command(14:end);
      arrnum=str2num(arrnumstr);
      prevbox_ix=0;
      for ixx=1:length(boxstr)
         if any(boxstr(ixx).outarr==arrnum)
            prevbox_ix=ixx;
         end
      end
      if prevbox_ix==0
         error(['Box manager cannot find item before arrow #' arrnumstr '.'])
      end
      arrowstatus(arrnum)='-';
      
      gettime('setline', arrnum, guicolor('COLOR_ARR_NODATA')); % set arrow color
      
      objname=boxstr(prevbox_ix).name;
      datanames={'DATA_gotdata', 'DATA_segmenteddata', 'DATA_converteddata', 'DATA_selecteddata'};
      
      guidtawr(window, datanames{prevbox_ix}, 'direct', ''); % clear arrow data
      
      % find correct status of previous box
      if arrnum==1
         status_prev='s';
      else
         prev_arrow_data=guidtard(window, datanames{prevbox_ix-1});
         if isempty(prev_arrow_data) % if there is input data -> selectable, otherwise not
            status_prev='u';
         else
            status_prev='s';
         end
      end
      boxstr(prevbox_ix).status=status_prev;
      switch boxstr(prevbox_ix).status  % set box color
      case 'd'
         gettime('setbox', objname, guicolor('BOX_COLOR_DONE'));
      case 's'
         gettime('setbox', objname, guicolor('BOX_COLOR_SELECTABLE'));
      case 'b'
         gettime('setbox', objname, guicolor('BOX_COLOR_BUSY'));
      otherwise
         gettime('setbox', objname, guicolor('BOX_COLOR_UNSELECTABLE'));
      end
      
      % set next box's status to 'u'
      nextbox_ix=prevbox_ix+1;
      if nextbox_ix<=4 % last box has no succesor
         boxstr(nextbox_ix).status='u';
         gettime('setbox', boxstr(nextbox_ix).name, guicolor('BOX_COLOR_UNSELECTABLE'));
      end
      guidtawr(window, 'ARRMGR', 'direct', arrowstatus)      % write back arrow status data
      gettime('arrow_deleted', boxstr(prevbox_ix).name);
      gettime('status', 'Arrow data deleted');
      
      
      
   elseif strcmp('init',command)
      names=strvcat(...
         'rect_gettdata',...
         'rect_segment',...
         'rect_convert',...
         'rect_freqsel');
      statusvect='suuu';
      levelvect=[1 2 3 4];
      arrownum =[1 1 1 1];
      outarrows=...
         [1;2;3;4];
      for ix=1:4
         initstruct(ix)=struct('name', deblank(names(ix,:)),...
            'status', statusvect(ix),...
            'arrownum', arrownum(ix),...
            'outarr', outarrows(ix,:),...
            'level', levelvect(ix));
      end
      
      guidtawr(window, 'BOXMGR', 'direct', initstruct)
      boxstr=initstruct;
      arrowstatus='----';
      guidtawr(window, 'ARRMGR', 'direct', arrowstatus)
      % clear arrow data if any
      guidtawr('gettime_main', 'DATA_gotdata',       'direct', '')
      guidtawr('gettime_main', 'DATA_segmenteddata', 'direct', '')
      guidtawr('gettime_main', 'DATA_converteddata', 'direct', '')
      guidtawr('gettime_main', 'DATA_selecteddata',  'direct', '')
      
      % now set colors
      boxmgr('updatecolors', window)
      
      
      %case 'click_on_gettdata'
      
      %case 'click_on_segment'
      
      %case 'click_on_convert'
      
      %case 'click_on_freqsel'
      
      
      
   elseif strcmp('updatecolors',command)
      for ix=1:length(boxstr)
         switch boxstr(ix).status
         case 's'
            gettime('setbox',boxstr(ix).name, guicolor('BOX_COLOR_SELECTABLE'))
         case 'u'
            gettime('setbox',boxstr(ix).name, guicolor('BOX_COLOR_UNSELECTABLE'))
         case 'd'
            gettime('setbox',boxstr(ix).name, guicolor('BOX_COLOR_DONE'))
         otherwise % busy
            gettime('setbox',boxstr(ix).name, guicolor('BOX_COLOR_BUSY'))
         end %switch
      end %for boxstr
      gettime('setline', findstr(arrowstatus,'-'), guicolor('COLOR_ARR_NODATA'))
      gettime('setline', findstr(arrowstatus,'a'), guicolor('COLOR_ARR_ACTIVE_DATA'))
      gettime('setline', findstr(arrowstatus,'p'), guicolor('COLOR_ARR_PASSIVE_DATA'))
      gettime('setline', findstr(arrowstatus,'A'), guicolor('COLOR_ARR_ACTIVE_LOADED_DATA'))
      gettime('setline', findstr(arrowstatus,'P'), guicolor('COLOR_ARR_PASSIVE_DATA'))
   end   %if
   
   % write back state variables  
   if ~isempty(boxstr), guidtawr(window, 'BOXMGR', 'direct', boxstr), end
   
   
otherwise 
   if strcmp(command,'preload')
     % preload, nothing to do
     return
   end
   error(['Box mgr Bad window tag: ' window])
end

if strcmp(command, 'enquirebox')
   % returns status of block p3
   boxstr=guidtard(window, 'BOXMGR');
   index=indexofobject(p3, boxstr);
   if index
      permission=boxstr(index).status;
   else % not box, but e.g. input window
      permission=[];
   end
end

if strcmp(command, 'enquirearrow')
   % returns status of arrow with index p3
   index=p3;
   arrstr=guidtard(window, 'ARRMGR');
   permission=arrstr(index);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%
% Local function to find index of a rect object known by name 
% in the BOXMGR structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
function ind=indexofobject(objectname, boxstr);
ind=0;
for ix=1:length(boxstr)
   if strcmp(boxstr(ix).name, ['rect_' objectname])
      ind=ix;
      return
   end
end
%
%End of file
