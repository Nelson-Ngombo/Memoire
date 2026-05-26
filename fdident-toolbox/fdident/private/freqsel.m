function freqsel(p1,p2,p3,p4,p5,seltype) 
%FREQSEL fdtool Frequency Selection window
%
% calling conventions
% init: freqsel('init', caller_fcn , caller_ID, init_var)
% when ready, calls caller_fcn with: 
%             caller_fcn('freqsel_ready', status, caller_ID, freqs),
% where status may be 'done' or 'cancel', freqs contains the selected 
% frequencies, if status = 'done'

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $a
%       Written by Gy. Simon and Gy. Roman
%       Last modified: 14-Jun-2001

mainfig=findall(0, 'tag','fdtool_main');
myfcn='freqsel';
myname='freqsel';

if ~strcmp(p1,'init'),
   
   Me='freqselfig';
   myfig=findall(0, 'tag',Me);
   if isempty(myfig)
      Me='freqsel2fig';
      myfig=findall(0, 'tag',Me);
   end
   if isempty(myfig)
      Me='freqsel3fig';
      myfig=findall(0, 'tag',Me);
   end
   
   if nargin == 6
      sender=p5;
   else
      seltype=get(myfig,'selectiontype');
      eval(['sender=p', num2str(nargin) ';']);
   end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                 INITIALIZATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(p1,'init')
   tmp=findall(0, 'tag','freqselfig');
   if ~isempty(tmp) 
      guiclose('freqsel')         
   end
   tmp=findall(0, 'tag','freqsel2fig');
   if ~isempty(tmp) 
      guiclose('freqsel')         
   end
   tmp=findall(0, 'tag','freqsel3fig');
   if ~isempty(tmp) 
      guiclose('freqsel')         
   end
   if nargin==2 % freqsel('init', initvar) when session is loaded
      session_load=1;
      p4=p2; %initvar
      Me=p4.figuretag;
      if findstr(Me, '2') % agv call
         p2='agv'; % caller_fcn 
         p3='AVERAGE'; % caller_ID
      elseif findstr(Me, '3') % gfdd call
         p2='gfdd'; % caller_fcn 
         p3='GFDD'; % caller_ID
      else   
         p2='gettime'; % caller_fcn 
         p3='GETTIME'; % caller_ID
      end
   else % not session load
      session_load=0;
      if strcmp(p2, 'gettime')
         Me='freqselfig';
      elseif strcmp(p2, 'gfdd')
         Me='freqsel3fig';
      else % agv 
         Me='freqsel2fig';
      end
   end
   freqsdef
   
   fig = figure(...
      'Units','pixels',...
      'Position',[ fig_offsx fig_offsy fig_dx fig_dy ],... 
      'resize','on',...
      'resizefcn','fdtool(''callback'',''freqsel'',''resize'')',...
      'tag', Me,...
      'IntegerHandle', 'off', ...
      'Handlevisibility', 'off',...
      'Name','Select frequencies',... 
      'NumberTitle','off',...
      'Closerequestfcn','fdtool(''callback'',''freqsel'',''freqsel_uic_cancelpb'');',... 
      'windowbuttonmotionfcn', 'fdtool(''callback'',''freqsel'',''mousemotion'')',...
      'visible','off'); 
   
   %      'windowbuttondownfcn', 'fdtool(''callback'',''freqsel'',''buttondown'')',...
   myfig=fig;
   fdwindef(myfig);  % set default window properties
   %  Uicontrol Object Creation 
   
   freqsel_uic_donepb = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''freqsel'',''freqsel_uic_donepb'');',... 
      'Units','pixels',... 
      'Position',[ donepb_offsx donepb_offsy donepb_dx donepb_dy ],... 
      'BackgroundColor',pushb_bgr_col,... 
      'ForegroundColor',pushb_fg_col,...
      'HorizontalAlignment','center',... 
      'String','Close',... 
      'tooltipstring','Close window, return selected frequencies',...
      'Style','pushbutton',... 
      'Tag','freqsel_uic_donepb',... 
      'UserData',''); 
   freqsel_uic_cancelpb = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''freqsel'',''freqsel_uic_cancelpb'');',... 
      'Units','pixels',... 
      'Position',[ cancelpb_offsx cancelpb_offsy cancelpb_dx cancelpb_dy ],... 
      'BackgroundColor',pushb_bgr_col,... 
      'ForegroundColor',pushb_fg_col,...
      'HorizontalAlignment','center',... 
      'String','Cancel',... 
      'tooltipstring','Close window, return all frequencies',...
      'Style','pushbutton',... 
      'Tag','freqsel_uic_cancelpb',... 
      'UserData',''); 
   freqsel_uic_callpb = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''freqsel'',''freqsel_uic_callpb'');',... 
      'Units','pixels',... 
      'Position',[ callpb_offsx callpb_offsy callpb_dx callpb_dy ],... 
      'BackgroundColor',pushb_bgr_col,... 
      'ForegroundColor',pushb_fg_col,...
      'HorizontalAlignment','center',... 
      'String','Deselect All',...
      'tooltipstring','Deselect all frequencies',...
      'Style','pushbutton',... 
      'Tag','freqsel_uic_callpb',... 
      'UserData',''); 
   freqsel_uic_sallpb = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''freqsel'',''freqsel_uic_sallpb'');',... 
      'Units','pixels',... 
      'Position',[ sallpb_offsx sallpb_offsy sallpb_dx sallpb_dy ],... 
      'BackgroundColor',pushb_bgr_col,... 
      'ForegroundColor',pushb_fg_col,...
      'HorizontalAlignment','center',... 
      'String','Select All',... 
      'tooltipstring','Select all frequencies',...
      'Style','pushbutton',... 
      'Tag','freqsel_uic_sallpb',... 
      'UserData',''); 
   freqsel_uic_excpop = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'', ''freqsel'', ''freqsel_uic_excpop'', ''freqsel_uic_excpop'')',...
      'Units','pixels',... 
      'Position',[ excpop_offsx excpop_offsy excpop_dx excpop_dy ],... 
      'BackgroundColor',popup_bgr_col,... 
      'ForegroundColor',popup_fg_col,...
      'HorizontalAlignment','right',... 
      'String',{'frequencies','excit. freqs'},... 
      'tooltipstring','Select frequencies or excitation frequencies',...
      'Style','popup',... 
      'Tag','freqsel_uic_excpop',... 
      'UserData','',...
      'visible','off',...
      'Value',2); 
   freqsel_uic_zsdspop = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'', ''freqsel'', ''freqsel_uic_zsdspop'', ''freqsel_uic_zsdspop'')',...
      'Units','pixels',... 
      'Position',[ zsdspop_offsx zsdspop_offsy zsdspop_dx zsdspop_dy ],... 
      'BackgroundColor',popup_bgr_col,... 
      'ForegroundColor',popup_fg_col,...
      'HorizontalAlignment','right',... 
      'String',{'zoom','select','deselect'},... 
      'tooltipstring','Mouse action: select/deselect/zoom',...
      'Style','popup',... 
      'Tag','freqsel_uic_zsdspop',... 
      'UserData','',...
      'Value',2); 
   freqsel_uic_frffxfypop = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'', ''freqsel'', ''freqsel_uic_frffxfypop'', ''freqsel_uic_frffxfypop'')',...
      'Units','pixels',... 
      'Position',[ frffxfypop_offsx frffxfypop_offsy frffxfypop_dx frffxfypop_dy ],... 
      'BackgroundColor',popup_bgr_col,... 
      'ForegroundColor',popup_fg_col,...
      'HorizontalAlignment','right',... 
      'String',{'frf','frf + std','output-input','output-input + std'},... 
      'tooltipstring','Type of plot',...
      'Style','popup',... 
      'value',2,...
      'Tag','freqsel_uic_frffxfypop',... 
      'UserData',''); 
   %if strcmp(guiinfos('userlevel'),'Advanced')
     set(freqsel_uic_frffxfypop,'String',{'frf','frf + std','output-input',...
         'output-input + std','SNR + frf','NSR + frf'}) 
   %end
   if strcmp(Me,'freqselfig')
     %set(freqsel_uic_frffxfypop,'string',{'frf','output-input'}); 
   end
   %
   freqsel_uic_linloghpop = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'', ''freqsel'', ''freqsel_uic_linloghpop'', ''freqsel_uic_linloghpop'')',...
      'Units','pixels',... 
      'Position',[ linloghpop_offsx linloghpop_offsy linloghpop_dx linloghpop_dy ],... 
      'BackgroundColor',popup_bgr_col,... 
      'ForegroundColor',popup_fg_col,...
      'HorizontalAlignment','right',... 
      'String',{'lin freq','log freq'},...
      'tooltipstring','Linear/logarithmic frequency axis',...
      'Style','popup',... 
      'Tag','freqsel_uic_linloghpop',... 
      'UserData',''); 
   freqsel_uic_statusframe = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ statusframe_offsx statusframe_offsy ...
         statusframe_dx statusframe_dy ],... 
      'BackgroundColor',frame_bgr_col,...
      'ForegroundColor',frame_fg_col,...
      'String','',... 
      'HorizontalAlignment','left',... 
      'Style','frame',... 
      'Enable','off',... 
      'Tag','freqsel_uic_statusframe',... 
      'UserData',''); 
   freqsel_uic_statustext = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ statustext_offsx statustext_offsy ...
         statustext_dx statustext_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','',... 
      'HorizontalAlignment','left',... 
      'Style','text',... 
      'Tag','freqsel_uic_statustext',... 
      'UserData',''); 
   
   
   %  Menu Object Creation 
   
   
   %  Axes and Text Object Creation 
   
   freqsel_axes_uaxes = axes( ...
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ uaxes_offsx uaxes_offsy uaxes_dx uaxes_dy ],...
      'Color',[1 1 1],...
      'Fontname',axes_font_name,...
      'Xgrid','off', ...
      'Ygrid','off', ...
      'Xlim',[ 0 1 ],...
      'Ylim',[ 0 1 ],...
      'XLimMode','auto',...   
      'YLimMode','auto',...   
      'Clipping','on',...
      'buttondownfcn', 'fdtool(''callback'',''freqsel'',''buttondown'', ''freqsel_axes_uaxes'')',...
      'visible','off',...
      'Tag','freqsel_axes_uaxes',...
      'UserData','',...
      'nextplot', 'replacechildren',...
      'defaultlinehittest', 'off'); 
   freqsel_axes_laxes = axes( ...
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ laxes_offsx laxes_offsy laxes_dx laxes_dy ],...
      'Color',[1 1 1],...
      'Fontname',axes_font_name,...
      'Xgrid','off', ...
      'Ygrid','off', ...
      'Xlim',[ 0 1 ],...
      'Ylim',[ 0 1 ],...
      'XLimMode','auto',...   
      'YLimMode','auto',...   
      'Clipping','on',...
      'buttondownfcn', 'fdtool(''callback'',''freqsel'',''buttondown'', ''freqsel_axes_laxes'')',...
      'visible','on',...
      'Tag','freqsel_axes_laxes',...
      'UserData','',...
      'nextplot', 'replacechildren',...
      'defaultlinehittest', 'off'); 
   
   % load input 

   switch p2  % caller name
   case 'gettime'
      inp=guidtard('gettime_main', 'DATA_converteddata');
   case 'agv'
     %First try to read already selected data
     inp=guidtard('average_main','FINAL_DATA'); 
     if isempty(inp)
       inp=guidtard('average_main', 'FV_DATA');
     end
   case 'gfdd'
     %First try to read already selected data ***
     inp=guidtard('getfreq_main', 'OUTPUT_getfreq');
     if isempty(inp)
       inp=guidtard('getfreq_main', 'SELECT_getfreq');
     end
   end
   guidtawr(Me, 'INPUT_var', 'direct', inp)
   guidtawr(Me, 'INPUT_var_struct', 'direct', get(inp))
   
   if session_load
      storewin('restore', Me, p4);
   else
      storewin('recover_settings', Me);
      guidtawr(Me, 'DATA_selected_freqs', 'direct', p4);
   end
   % store caller fcn's name and ID 
   guidtawr(Me, 'caller_name', 'direct', p2)
   guidtawr(Me, 'caller_ID', 'direct', p3)

   freqsel('refresh')

   %init zoom/select/deselect 
   freqsel('freqsel_uic_zsdspop')
     
   % process initvar here
      
   freqsel('status', 'Select / deselect frequencies...')
   % init help fcns
   helpmgr('init_help', '', myfcn, myfig );
   
   guimenus(Me,'freqsel','freqsel');
   DoneEnable(myfig)   
   if ishandle(fig) 
      
      intoscr({Me});
   
      % The above function, intoscr positions the windows given by their labels
      % into the actual screen. This might come handy when the session has been saved
      % on a machine with different resolution than that of the present machine.
      
      if (isnumeric(inp.outputvariance)&~any(inp.inputvariance>0)&~any(inp.outputvariance>0)) |...
        (iscell(inp.outputvariance)&~any(inp.inputvariance{1}>0)&~any(inp.outputvariance{1}>0))
        set(freqsel_uic_frffxfypop,'string',{'frf','output-input'});
      end
      
      set(fig,'visible','on');
      fixpopups(fig)
   else
      return
   end
   winmenu(myfig);
   ulevctrl(get(myfig,'tag'))
   
else

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   %                 COMMANDS
   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   if strcmp(p1, 'mousemotion')
      guiready(myfig, myfcn)
      
   elseif strcmp(p1,'freqsel_uic_donepb')
      freqsel('status', 'Closing ...', Me);
      call_fcn=guidtard(Me, 'caller_name');
      call_ID=guidtard(Me, 'caller_ID');
      inp=guidtard(Me, 'INPUT_var');
      
      index = guidtard(Me, 'DATA_selected_freqs');
      if isempty(index)
         freqsel('status', 'Error: Select frequencies before closing window')
         return
      end
      if 0&isa(inp,'iddat')
        result=inp(index);
      else
        h=findobj(allchild(myfig), 'flat', 'Tag','freqsel_uic_excpop');
        if ~guiinfos('islinear')&...
            strcmp(get(h,'visible'),'on')&any(findstr(popupstr(h),'excit'))
          fp=inp.freqpoints;
          ifp=find((fp>=min(fp(index)))&(fp<=max(fp(index))));
          if length(ifp)<length(fp), result=inp(ifp,:,:); else result=inp; end
          result.frequencies=fp(index);
          feind=round(fp(index)/dfcalc(result));
          if any(rem(feind,2)==0)
            %freqsel('status','Error: there is even frequency among the excitation lines')
            %error('There is even frequency among the excitation lines')
          elseif ~israndomized(result)
            freqsel('status','Error: this is not a randomized-grid experiment')
            error('This is not a randomized-grid experiment')
          end
        else %linear or frequencies selected
          result=inp(index,:,:);
        end
      end
      
      eval([call_fcn '(''freqsel_ready'',''done'', result, call_ID, Me)'])
      eval([call_fcn '(''status'', ''Frequency selection finished.'' , Me)' ])
      guiclose('freqsel')   

      if strcmp(call_fcn, 'gettime')
        if strcmpi(guiinfos('userlevel'),'automatic')|strcmpi(guiinfos('signaltype'),'all')
          gettime('autofinish')
          %if interactive, it makes not much sense to open agv...
          agv
          if strcmpi(guiinfos('signaltype'),'all')%all signal types: close agv
            %  guifreez('average_main','freeze_strong','freqsel');
            %  set(findall(0,'type','figure','tag','average_main'),'visible','off')
            agv('agv_autofinish')
          else %periodic: open freqsel in agv
            freqsel('init', 'agv', 'AVERAGE', '');
          end
        end
      elseif strcmp(call_fcn, 'agv')
        if strcmpi(guiinfos('userlevel'),'automatic')|strcmpi(guiinfos('signaltype'),'all')
          agv('agv_uic_donepb')
        end
      end
      
   elseif strcmp(p1,'freqsel_uic_cancelpb')
      freqsel('status', 'Closing ...', Me);
      
      call_fcn=guidtard(Me, 'caller_name');
      call_ID=guidtard(Me, 'caller_ID');
      
      eval([call_fcn '(''freqsel_ready'', ''cancel'', [], call_ID, Me)'])
      eval([call_fcn '(''status'', ''Frequency selection cancelled.'' , Me)' ])
      guiclose('freqsel')   
      
      %if strcmpi(guiinfos('signaltype'),'all') %freeze agv
      %  guifreez('average_main','unfreeze','freqsel');
      %  agv('agv_autofinish')
      %end
      
      
   elseif strcmp(p1,'freqsel_uic_callpb')
      freqsel('status', 'Clearing all selection ...', Me);
      r(1) = findobj(myfig, 'tag','selected_l');
      r(2) = findobj(myfig, 'tag','selected_u');
      guidtawr(Me, 'DATA_selected_freqs', 'direct', []);

      if ~isempty(r(1))
         set(r(1),'xdata',[],'ydata',[]);
      end;
      if ~isempty(r(2))
         set(r(2),'xdata',[],'ydata',[]);
      end;
      h=findobj(myfig, 'tag','freqsel_uic_zsdspop');
      if strcmpi(popupstr(h), 'deselect')
         set(h, 'value', 2)  % Select
      end
      DoneEnable(myfig);
      freqsel('status', 'Done.', Me);
      
      
      
   elseif strcmp(p1,'freqsel_uic_sallpb')
      freqsel('status', 'Selecting all frequencies ...', Me);
      [f_vect, ia_vect, oa_vect, va_vect, cuy, fa_vect, vtf, na_vect]=getinpvars(Me); 
      f_vect = f_vect*scalekhz;
      r(1) = findobj(myfig, 'tag','selected_l');
      r(2) = findobj(myfig, 'tag','selected_u');
      if isempty(r(1))
         axes(findobj(myfig, 'tag','freqsel_axes_laxes'));
         r(1) = line('tag','selected_l','marker','x','linestyle','none','xdata',[],'ydata',[],'color','red');
      end;
      if isempty(r(2))
         axes(findobj(myfig, 'tag','freqsel_axes_uaxes'));
         r(2) = line('tag','selected_u','marker','x','linestyle','none','xdata',[],'ydata',[],'color','red');
      end;
      guidtawr(Me, 'DATA_selected_freqs', 'direct', 1:length(f_vect));

      h1=findobj(myfig, 'tag','freqsel_uic_frffxfypop');
      string1=popupstr(h1);
      if strcmp(string1,'frf')
         set(r(1),'xdata',f_vect,'ydata',mean(fa_vect,3));
         set(r(2),'xdata',f_vect,'ydata',mean(ia_vect,3)); %visible off
      elseif strcmp(string1,'frf + std')
         %set(r(1),'xdata',f_vect,'ydata',vtf);
         set(r(1),'xdata',f_vect,'ydata',mean(fa_vect,3));
         set(r(2),'xdata',f_vect,'ydata',mean(ia_vect,3));
      elseif strcmp(string1,'output-input')
         set(r(1),'xdata',f_vect,'ydata',mean(ia_vect,3));
         set(r(2),'xdata',f_vect,'ydata',mean(oa_vect,3));
      elseif strcmp(string1,'output-input + std')
         set(r(1),'xdata',f_vect,'ydata',mean(ia_vect,3));
         set(r(2),'xdata',f_vect,'ydata',mean(oa_vect,3));
      elseif strcmp(string1,'SNR + frf')
         set(r(1),'xdata',f_vect,'ydata',1./mean(na_vect,3));
         set(r(2),'xdata',f_vect,'ydata',mean(ia_vect,3));       
      elseif strcmp(string1,'NSR + frf')
         set(r(1),'xdata',f_vect,'ydata',mean(na_vect,3));
         set(r(2),'xdata',f_vect,'ydata',mean(ia_vect,3));       
      else
        error('Unknown menu item')
      end;
      h=findobj(myfig, 'tag','freqsel_uic_zsdspop');
      if strcmpi(popupstr(h), 'select')
         set(h, 'value', 3)  % Deselect
      end
      DoneEnable(myfig);
      freqsel('status', 'Done.', Me);
      
      
      
   elseif strcmp(p1,'freqsel_uic_excpop')
     
   elseif strcmp(p1,'freqsel_uic_zsdspop')
       h1=findobj(myfig, 'tag','freqsel_uic_zsdspop');
       modestr=popupstr(h1); M1=modestr; M1(1)=upper(modestr(1));
       freqsel('status', [M1 ' mode set. Use the mouse to ' modestr '.']);
      
       %h1=findobj(myfig, 'tag','freqsel_uic_zsdspop');
       %fig=findobj(myfig, 'tag', Me);
       %string1=get(h1,'string');
       %value=get(h1,'value');
       %string1=string1(value);
       %if strcmp(string1,'zoom')
       %  set(fig, 'windowbuttondownfcn', '');
       %  set(fig, 'windowbuttonupfcn', '');
       %  zoom on
       %elseif strcmp(string1,'deselect')
       %  zoom off;
       %  set(fig, 'windowbuttondownfcn', 'fdtool(''callback'',''freqsel'',''buttondown'')');
       %  set(fig, 'windowbuttonupfcn', 'fdtool(''callback'',''freqsel'',''buttonup'')')
       %elseif strcmp(string1,'select')
       %  zoom off;
       %  set(fig, 'windowbuttondownfcn', 'fdtool(''callback'',''freqsel'',''buttondown'')');
       %  set(fig, 'windowbuttonupfcn', 'fdtool(''callback'',''freqsel'',''buttonup'')')
       %end;
      
   elseif strcmp(p1,'freqsel_uic_frffxfypop')
      freqsel('refresh');
      
      
   elseif strcmp(p1,'freqsel_uic_linloghpop')
      h1=findobj(myfig, 'tag','freqsel_uic_linloghpop');
      h2=findobj(myfig, 'tag','freqsel_axes_laxes');
      h3=findobj(myfig, 'tag','freqsel_axes_uaxes');
      string1=popupstr(h1);
      
      %GYUSZI! Ez is egy javitas
      lh=findobj([h2,h3],'type','line');
      xd=get(lh,'xdata');
      if iscell(xd), xd=cat(2,xd{:}); end
      fmin=min(xd);
      ind=find(xd<=0); if ~isempty(ind), xd(ind)=[]; end
      xd=sort(xd); fminp=min(xd);
      ind=find(diff(xd)==0); if ~isempty(ind), xd(ind)=[]; end
      if isempty(fmin), error('fmin is empty'); end
      if isempty(fminp), fminp=fmin; end
      xlim=get(h2,'xlim');  
      if strncmpi(string1,'lin',3)
        if length(xd)>=2, df=diff(xd(1:2));
        else df=fmin/4;
        end
        xlim(1)=min(xlim(1),fmin-df);
      elseif strncmpi(string1,'log',3)
        if length(xd)>=2, df=(xd(2)/xd(1))^0.25;
        else df=2;
        end
        xlim(1)=fminp/df;
      else error('Invalid string')
      end
      set([h2,h3],'xlim',xlim)
      %JAVITAS VEGE
      
      set([h2 h3],'XScale', string1(1:3));
      
      
%   elseif strcmp(p1,'freqsel_uic_linlogvpop')
%      disp('freqsel_uic_linlogvpop selected.')
%      
%      h1=findobj(myfig, 'tag','freqsel_uic_linlogvpop');
%      h2=findobj(myfig, 'tag','freqsel_axes_laxes');
%      h3=findobj(myfig, 'tag','freqsel_axes_uaxes');
%      string1=popupstr(h1);
%      set([h2 h3],'YScale', string1);
      
      
   elseif strcmp(p1,'status')
      c=allchild(myfig);
      status=findobj(c, 'flat', 'tag','freqsel_uic_statustext');
      statusfr=findobj(c, 'flat', 'tag','freqsel_uic_statusframe');
      glstatus(myfig, status, statusfr, p2)
      
      
      
      
   elseif strcmp(p1,'resize')
      
      axdiffy=45; %ez a ket axes kozotti tavolsag
      mindx=530;
      mindy=370;
      scr=get(0,'screensize');
      mainfigmaxx=scr(3);
      mainfigmaxy=scr(4);

      pos=get(findobj(myfig, 'tag',Me),'position');
      fig_offsx=pos(1);
      fig_offsy=pos(2);
      fig_dx=pos(3);
      fig_dy=pos(4);
      if fig_dx < mindx
         fig_dx=mindx;
      end;
      if fig_dy < mindy
         fig_dy=mindy;
      end;
      %      if fig_offsx+fig_dx > mainfigmaxx
      %         fig_offsx=10;
      %      end;
      if fig_offsy+fig_dy > mainfigmaxy
         fig_offsy=20;
      end;
      set(findobj(myfig, 'tag',Me),'position',[fig_offsx fig_offsy fig_dx fig_dy]);
      
      pos=get(findobj(myfig, 'tag','freqsel_uic_statusframe'),'position');
      set(findobj(myfig, 'tag','freqsel_uic_statusframe'),'position',[pos(1) pos(2) fig_dx pos(4)]);
      pos=get(findobj(myfig, 'tag','freqsel_uic_statustext'),'position');
      set(findobj(myfig, 'tag','freqsel_uic_statustext'),'position',[pos(1) pos(2) fig_dx-6 pos(4)]);
      pos=get(findobj(myfig, 'tag','freqsel_uic_donepb'),'position');
      set(findobj(myfig, 'tag','freqsel_uic_donepb'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
      pos=get(findobj(myfig, 'tag','freqsel_uic_cancelpb'),'position');
      set(findobj(myfig, 'tag','freqsel_uic_cancelpb'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
      pos=get(findobj(myfig, 'tag','freqsel_uic_callpb'),'position');
      set(findobj(myfig, 'tag','freqsel_uic_callpb'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
      pos=get(findobj(myfig, 'tag','freqsel_uic_sallpb'),'position');
      set(findobj(myfig, 'tag','freqsel_uic_sallpb'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
      pos=get(findobj(myfig, 'tag','freqsel_uic_excpop'),'position');
      set(findobj(myfig, 'tag','freqsel_uic_excpop'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
      pos1=get(findobj(myfig, 'tag','freqsel_uic_zsdspop'),'position');
      pos2=get(findobj(myfig, 'tag','freqsel_uic_cancelpb'),'position');
      axl_offsx=pos1(1);
      axl_dx=pos2(1)-axl_offsx-40;
      axl_offsy=pos2(2)+pos2(4);
      
      val=get(findobj(myfig, 'tag','freqsel_uic_frffxfypop'),'value');
      string=get(findobj(myfig, 'tag','freqsel_uic_frffxfypop'),'string');
      if ~any(findstr(string{val},'output-input'))
         axl_dy=fig_dy-axl_offsy-40;
         axu_dy=(fig_dy-axl_offsy-20-axdiffy)/2;
      else
         axl_dy=(fig_dy-axl_offsy-40-axdiffy)/2;
         axu_dy=(fig_dy-axl_offsy-40-axdiffy)/2;
      end;
      
      
      set(findobj(myfig, 'tag','freqsel_axes_laxes'),'position',[ axl_offsx axl_offsy axl_dx axl_dy]);
      set(findobj(myfig, 'tag','freqsel_axes_uaxes'),'position',[ axl_offsx axl_offsy+axu_dy+axdiffy axl_dx axu_dy]);
      pos=get(findobj(myfig, 'tag','freqsel_uic_frffxfypop'),'position');
      set(findobj(myfig, 'tag','freqsel_uic_frffxfypop'),'position',[ axl_offsx+axl_dx-pos(3) pos(2) pos(3) pos(4)]);
      pos=get(findobj(myfig, 'tag','freqsel_uic_linloghpop'),'position');
      set(findobj(myfig, 'tag','freqsel_uic_linloghpop'),'position',[ axl_offsx+axl_dx/2-pos(3)/2 pos(2) pos(3) pos(4)]);
      %      pos=get(findobj(myfig, 'tag','freqsel_uic_linlogvpop'),'position');
      %      pos1=get(findobj(myfig, 'tag','freqsel_axes_uaxes'),'position');
      %      set(findobj(myfig, 'tag','freqsel_uic_linlogvpop'),'position',[ fig_dx-pos(3)-20 pos1(2)-axdiffy/2-pos(4)/2 pos(3) pos(4)]);
      
      
   elseif strcmp(p1,'buttondown')
      % The buttondown funtion is used to handle the selection/deselection
      % actions.
      set(myfig,'windowbuttonmotionfcn', '')
      h1=findobj(myfig, 'tag','freqsel_uic_zsdspop');
      curr_ax=get(myfig, 'currentaxes');
      if strcmp(lower(popupstr(h1)), 'zoom') % zoom 
         set(myfig, 'handlevisibility', 'callback')
         zoom down
         set(myfig, 'handlevisibility', 'off')
         xlim=get(curr_ax, 'xlim');
         axs=[findobj(allchild(myfig), 'flat', 'tag', 'freqsel_axes_uaxes'), ...
            findobj(allchild(myfig), 'flat', 'tag', 'freqsel_axes_laxes')];
         set(axs, 'xlim', xlim)
      else % select/deselect
         set(myfig, 'handlevisibility', 'callback')
         box=rbbox;
         set(myfig, 'handlevisibility', 'off')
         [f_vect,ia_vect,oa_vect,va_vect,cuy,fa_vect,vtf,na_vect]=getinpvars(Me);
         f_vect = f_vect*scalekhz;
         h1=findobj(myfig, 'tag','freqsel_uic_frffxfypop');
         string1=popupstr(h1);
         if strcmp(string1,'frf')
            a_vect = fa_vect;
         elseif strcmp(string1,'frf + std')
            a_vect = fa_vect; %vtf for variance
         elseif strcmp(string1,'output-input')
            if strcmp(get(curr_ax,'tag'),'freqsel_axes_uaxes')
               a_vect = oa_vect;
            else
               a_vect = ia_vect;
            end
         elseif strcmp(string1,'output-input + std')
            if strcmp(get(curr_ax,'tag'),'freqsel_axes_uaxes')
               a_vect = oa_vect;
            else
               a_vect = ia_vect;
            end
         elseif strcmp(string1,'SNR + frf')
            a_vect = -na_vect;
         elseif strcmp(string1,'NSR + frf')
            a_vect = na_vect;
         else
           error('Unknown menu item')
         end
         
         
         msg = SelectPosition(f_vect, a_vect, box);
         % The function constructs a selection message with the selection mode
         % (select/deselect) and the selection box in brackets.
         if findstr(lower(msg),'error')
            freqsel('status', msg);
         elseif findstr(msg, 'no axes')
            % no action required
         else
            fdtool('callback', 'freqsel',  'ui_freqselection', msg, get(curr_ax,'tag'));
         end
      end
      set(myfig,'windowbuttonmotionfcn', 'fdtool(''callback'',''freqsel'',''mousemotion'')' )

      
   elseif strcmp(p1,'ui_freqselection')
      % Based on the selection message the actual selection on data
      % is performed.
      
      freqsel('status', p2);
      [f_vect, ia_vect, oa_vect, va_vect, cuy, fa_vect, vtf, na_vect]=getinpvars(Me); 
      
      f_vect = f_vect*scalekhz;
      h1=findobj(myfig, 'tag','freqsel_uic_frffxfypop');
      string1=popupstr(h1);
      if strcmp(string1,'frf')
         a_vect = fa_vect;
      elseif strcmp(string1,'frf + std')
         a_vect = fa_vect; %vtf for variance
      elseif strcmp(string1,'output-input')
         if ~isempty(findstr('InpAmp',p2))
            a_vect = ia_vect;
         else
            a_vect = oa_vect;
         end;
      elseif strcmp(string1,'output-input + std')
         if ~isempty(findstr('InpAmp',p2))
            a_vect = ia_vect;
         else
            a_vect = oa_vect;
         end;
      elseif strcmp(string1,'SNR + frf')
         a_vect = -na_vect; %-na_vect for SNR
      elseif strcmp(string1,'NSR + frf')
         a_vect = na_vect; %na_vect for NSR
      else
        error('Unknown menu item')
      end;
      msg = p2;
      box = str2num(msg(find(msg == '['):find(msg == ']')));
      if length(box) == 2
         [f, i] = n_freq(box, f_vect, a_vect, msg);
         click=1; % Selection/deselection was done through a click
                  % The click inverts selection. The nearest frequency
                  % point is selected.
      elseif length(box) == 4
         [f, i] = f_in_box(box, f_vect, a_vect);
         click=0; % Selection/deselection was done through a rubberbox
                  % The rubberbox is dependent on select/deselect state
      else
         i = [];
      end;
      %ho = ishold;
      %hold on;
      r(1) = findobj(myfig, 'tag','selected_l');
      r(2) = findobj(myfig, 'tag','selected_u');
      if isempty(r(1))
         ax=axes(findobj(myfig, 'tag','freqsel_axes_laxes'));
         set(ax, 'nextplot', 'add')
         r(1) = line('parent', ax, 'tag','selected_l','marker','x','linestyle','none',...
            'xdata',[],'ydata',[],'color','red');
         set(ax, 'nextplot', 'replacechildren')
      end;
      if isempty(r(2))
         ax=axes(findobj(myfig, 'tag','freqsel_axes_uaxes'));
         set(ax, 'nextplot', 'add')
         r(2) = line('parent', ax, 'tag','selected_u','marker','x','linestyle','none',...
            'xdata',[],'ydata',[],'color','red');
         set(ax, 'nextplot', 'replacechildren')
      end;
      h1 = findobj(myfig, 'tag','freqsel_uic_zsdspop');
      string2=popupstr(h1);
      index = guidtard(Me, 'DATA_selected_freqs');
      % For selection the union, for deselection the set difference of
      % the original selection and the new selection is used.
      ui = union(i,index);
      di = setdiff(index,i);
      ii = intersect(i,index);      
      if click
         if ~isempty(ii) %&~isempty(find(index==i))
            ni = di;
         else
            ni = ui;
         end;
         % The selection is stored in two graphical objects.
         if strcmp(string1,'output-input')
            set(r(1),'xdata',f_vect(ni),'ydata',ia_vect(ni),'visible','on');
            set(r(2),'xdata',f_vect(ni),'ydata',oa_vect(ni),'visible','on');
         else
            set(r(1),'xdata',f_vect(ni),'ydata',a_vect(ni),'visible','on');
            set(r(2),'xdata',f_vect(ni),'ydata',ia_vect(ni),'visible','off');
         end;
         guidtawr(Me, 'DATA_selected_freqs', 'direct', ni);     
         
      else
         if ~isempty(findstr(lower(msg),'deselect'))
            if any(findstr(string1,'output-input'))
               set(r(1),'xdata',f_vect(di),'ydata',ia_vect(di),'visible','on');
               set(r(2),'xdata',f_vect(di),'ydata',oa_vect(di),'visible','on');
            else
               set(r(1),'xdata',f_vect(di),'ydata',a_vect(di),'visible','on');
               set(r(2),'xdata',f_vect(di),'ydata',ia_vect(di),'visible','off');
            end;
            guidtawr(Me, 'DATA_selected_freqs', 'direct', di);     
         elseif ~isempty(findstr(lower(msg),'select'))
            if any(findstr(string1,'output-input'))
               set(r(1),'xdata',f_vect(ui),'ydata',ia_vect(ui),'visible','on');
               set(r(2),'xdata',f_vect(ui),'ydata',oa_vect(ui),'visible','on');
            else
               set(r(1),'xdata',f_vect(ui),'ydata',a_vect(ui),'visible','on');
               set(r(2),'xdata',f_vect(ui),'ydata',ia_vect(ui),'visible','off');
            end;
            guidtawr(Me, 'DATA_selected_freqs', 'direct', ui);     
         end;
         DoneEnable(myfig);
         
         %if ~ho
         %   hold off;
         %end;
      end
      
         
      
   elseif strcmp(p1,'buttonup')
      set(myfig,'windowbuttonmotionfcn', '')
      
    elseif strcmp(p1,'freqsel_uic_print')
      %freqsel print command
      fdgprint(Me)
      freqsel('status','Print figure done.')
      
    elseif strcmp(p1,'freqsel_mod_print_ps')
      %freqsel print command
      fdgprint(Me,'ps')
      

   elseif strcmp(p1, 'refresh')
      
      guifreez(Me, 'freeze', 'freqsel_refresh');
      freqsel('status', 'Please wait, updating plot...')
      h_linlog=findobj(allchild(myfig), 'flat', 'tag', 'freqsel_uic_linloghpop');
      linlogstr=popupstr(h_linlog);
      linlogstr=linlogstr(1:3);
      inputdata=guidtard(Me, 'INPUT_var');
      if isempty(inputdata.SisoVariance)
        set(findobj(myfig,'Tag','freqsel_uic_frffxfypop'),...
          'String',{'frf','output-input'})
      end
      h_mode=findobj(allchild(myfig), 'flat', 'tag', 'freqsel_uic_frffxfypop');
      modestr=popupstr(h_mode);

      t_axes_u='freqsel_axes_uaxes';
      t_axes_l='freqsel_axes_laxes';

      axes_u=findobj(allchild(myfig), 'flat', 'Tag', t_axes_u);
      axes_l=findobj(allchild(myfig), 'flat', 'Tag', t_axes_l);
      
      buttonfcn_axes_u=get(axes_u, 'buttondownfcn');
      buttonfcn_axes_l=get(axes_l, 'buttondownfcn');
      
      if strcmp(linlogstr, 'lin')
         fscale='lin';
      else
         fscale='log';
      end
      cdat=[];
      switch lower(modestr)
      case 'frf'
         msc='*'; h=axes_l;
      case 'frf + std'
        msc='*'; h=axes_l;
        cdat=inputdata.OldTBSisoVariance;
      case 'output-input'
         msc='&'; h=[axes_l, axes_u];
      case 'output-input + std'
         msc='&'; h=[axes_l, axes_u];
         cdat=inputdata.OldTBSisoVariance;
      case 'snr + frf'
        cdat=inputdata.OldTBSisoVariance;
        if ~isempty(cdat), msc='S';
        else msc='*';
        end
        h=axes_l;
      case 'nsr + frf'
        cdat=inputdata.OldTBSisoVariance;
        if ~isempty(cdat), msc='N';
        else msc='*';
        end
        h=axes_l;
      otherwise
        error('unknown menu item')
      end
      [dummy1,dummy2,fsc]=ploteltf('', '', inputdata, fscale, msc, cdat, '', '', '', '', 'nomesg', h);
      %setappdata(myfig,'fsc',fsc)
      set(axes_u, 'tag', t_axes_u, 'buttondownfcn', buttonfcn_axes_u);
      set(axes_l, 'tag', t_axes_l, 'buttondownfcn', buttonfcn_axes_l);
      r1 = findobj(myfig, 'tag','selected_l');
      r2 = findobj(myfig, 'tag','selected_u');
      if isempty(r1)
         %  axes(axes_l);
         set(axes_l, 'nextplot', 'add')
         r1=plot(0,0,'xr','tag','selected_l', 'parent' , axes_l);
         set(r1,'xdata',[],'ydata',[]);
         set(axes_l, 'nextplot', 'replacechildren')
         
      end;
      if isempty(r2)
         % axes(axes_u);
         set(axes_u, 'nextplot', 'add')
         r2=plot(0,0,'xr','tag','selected_u', 'parent' , axes_u);
         set(r2,'xdata',[],'ydata',[],'visible','off');
         set(axes_u, 'nextplot', 'replacechildren')
      end;
      r = [r1 r2];
      freqsel('resize')     
      freqsel('refreshselection');
      freqsel('status', 'Done.')
      guifreez(Me, 'unfreeze', 'freqsel_refresh');
      

   elseif strcmp(p1, 'refreshselection')
      h_mode=findobj(allchild(myfig), 'flat', 'tag', 'freqsel_uic_frffxfypop');
      modestr=popupstr(h_mode);
      [f_vect, ia_vect, oa_vect, va_vect, cuy, fa_vect, vtf, na_vect]=getinpvars(Me); 
      f_vect = f_vect*scalekhz;
      t_axes_u='freqsel_axes_uaxes';
      t_axes_l='freqsel_axes_laxes';
      axes_u=findobj(allchild(myfig), 'flat', 'Tag', t_axes_u);
      axes_l=findobj(allchild(myfig), 'flat', 'Tag', t_axes_l);                             
      string1=modestr;
      r(1) = findobj(myfig, 'tag','selected_l');
      r(2) = findobj(myfig, 'tag','selected_u');
      index = guidtard(Me, 'DATA_selected_freqs');
      allc = allchild(axes_u);
      if strcmp(string1,'frf')
         set(r,'xdata',f_vect(index),'ydata',fa_vect(index));
         set(r(1),'visible','on');
         set(r(2),'visible','off');
         set(axes_u,'visible','off');
         set(allc,'visible','off');
      elseif strcmp(string1,'frf + std')
         set(r,'xdata',f_vect(index),'ydata',fa_vect(index)); %vtf(index) for var sel
         set(r(1),'visible','on');
         set(r(2),'visible','off');
         set(axes_u,'visible','off');
         set(allc,'visible','off');
      elseif strcmp(string1,'output-input')
         set(r(1),'xdata',f_vect(index),'ydata',ia_vect(index));
         set(r(2),'xdata',f_vect(index),'ydata',oa_vect(index));
         set(r(1),'visible','on');
         set(r(2),'visible','on');
         set(axes_u,'visible','on');
         set(allc,'visible','on');
      elseif strcmp(string1,'output-input + std')
         set(r(1),'xdata',f_vect(index),'ydata',ia_vect(index));
         set(r(2),'xdata',f_vect(index),'ydata',oa_vect(index));
         set(r(1),'visible','on');
         set(r(2),'visible','on');
         set(axes_u,'visible','on');
         set(allc,'visible','on');
      elseif strcmp(string1,'SNR + frf')
         set(r,'xdata',f_vect(index),'ydata',fa_vect(index)); %-na_vect(index) for SNR
         set(r(1),'visible','on');
         set(r(2),'visible','off');
         set(axes_u,'visible','off');
         set(allc,'visible','off');
      elseif strcmp(string1,'NSR + frf')
         set(r,'xdata',f_vect(index),'ydata',fa_vect(index)); %na_vect(index) for NSR
         set(r(1),'visible','on');
         set(r(2),'visible','off');
         set(axes_u,'visible','off');
         set(allc,'visible','off');
      else
        error('Unknown menu item')
      end;
      
                                          
   elseif strcmp(p1,'dummy')
      % no action
      
   else 
      error(['Error: freqsel.m called with incorrect command:' p1]) 
   end 
end % not init



function res = cont_point(ax, box)

pos = get(ax, 'position');
pos(3) = pos(1)+pos(3);
pos(4) = pos(2)+pos(4);

if (point_in_box(box, [pos(1) pos(2)]) | ...
      point_in_box(box, [pos(1) pos(4)]) | ...
      point_in_box(box, [pos(3) pos(2)]) | ...
      point_in_box(box, [pos(3) pos(4)]) | ...
      point_in_box(pos, [box(1) box(2)]) | ...
      point_in_box(pos, [box(1) box(4)]) | ...
      point_in_box(pos, [box(3) box(2)]) | ...
      point_in_box(pos, [box(3) box(4)]) | ...
      cross(box, pos))
   res = 1;
else
   res = 0;
end;


function res = point_in_box(box, point)

% Checks whether a point is contained in a box.
if ((point(1) >= box(1) & point(1) <= box(3)) & ...
      (point(2) >= box(2) & point(2) <= box(4)))
   res = 1;
else
   res = 0;
end;


function res = cross(box, pos)

if ((((box(1) < pos(1) & box(3) > pos(1)) & ...
      (box(1) < pos(3) & box(3) > pos(3))) | ...
      ((pos(1) < box(1) & pos(3) > box(1)) & ...
      (pos(1) < box(3) & pos(3) > box(3)))) & ...
      (((box(2) < pos(2) & box(4) > pos(2)) & ...
      (box(2) < pos(4) & box(4) > pos(4))) | ...
      ((pos(2) < box(2) & pos(4 > box(2)) & ...
      (pos(2) < box(4) & pos(4) > box(4))))))
   res = 1;
else
   res = 0;
end;



function [freq_vect, index_vect] = f_in_box(box, f_vect, a_vect)

% The function receives a rubber box in axis units, a frequency 
% vector and an absract amplitude vector (its contents depends
% on the uicontrols, it can be amplitude, wariance, etc.).
% The function returns two vectors: a frequency vector, and an index 
% vector. The amplitude at these frequencies are inside of the box.
% box is of the form [lower_left_x lower_left_y upper_right_x upper_right_y]

index_vect = find((mean(a_vect,3) > box(2) & mean(a_vect,3) < box(4)) & ...
   (f_vect > box(1) & f_vect < box(3)));

freq_vect = f_vect(index_vect);               



function message = SelectPosition(f_vect, a_vect, box)

% The function constructs a selection message containing the selection
% mode and the selection box in rectangles.
message = '';
Me='freqselfig';
myfig=findall(0, 'tag',Me);
if isempty(myfig)
   Me='freqsel2fig';
   myfig=findall(0, 'tag',Me);
end
if isempty(myfig)
   Me='freqsel3fig';
   myfig=findall(0, 'tag',Me);
end
%box=rbbox;
if (box(3) == 0 | box(4) == 0)
   fname = 'point';
else 
   fname = 'box';
end;

box(3) = box(1)+box(3);
box(4) = box(2)+box(4);
range_f_pix=[box(1) box(3)];
range_a_pix=[box(2) box(4)];

axv(1) = findobj(myfig, 'tag', 'freqsel_axes_uaxes');
axv(2) = findobj(myfig, 'tag', 'freqsel_axes_laxes');

res(1) = cont_point(axv(1), box) & strcmp(get(axv(1),'visible'),'on');
res(2) = cont_point(axv(2), box) & strcmp(get(axv(2),'visible'),'on');

if res
   message = 'Error: Only one axes can be used for selection at a time.';
   return;
elseif ~res
   message = 'no axes';
   return;
else
   ax = axv(find(res));
end;

axpos=get(ax, 'position');
xlim=get(ax, 'xlim');
ylim=get(ax, 'ylim'); 

%GYUSZI! JAVITAS INNEN
xscale=get(ax,'xscale'); %linear or log
%Now the pixel box values are converted to freqs
if strcmp(xscale,'linear')
  %ez maradt a regi
  xsc=diff(xlim)/axpos(3);
  ysc=diff(ylim)/axpos(4);
  range_f=(range_f_pix-axpos(1))*xsc+xlim(1);
  range_a=(range_a_pix-axpos(2))*ysc+ylim(1);
  if range_f(1) < xlim(1), range_f(1)=-inf; end
  if range_f(2) > xlim(2), range_f(2)= inf; end
  if range_a(1) < ylim(1), range_a(1)=-inf; end
  if range_a(2) > ylim(2), range_a(2)= inf; end  
elseif strcmp(xscale,'log')
  xsc=xlim(2)/xlim(1);
  range_f=xlim(1)*exp(log(xsc)*(range_f_pix-axpos(1))/(axpos(3)));
  ysc=diff(ylim)/axpos(4);
  range_a=(range_a_pix-axpos(2))*ysc+ylim(1);
  if range_f(1) < xlim(1), range_f(1)=-inf; end
  if range_f(2) > xlim(2), range_f(2)= inf; end
  if range_a(1) < ylim(1), range_a(1)=-inf; end
  if range_a(2) > ylim(2), range_a(2)= inf; end
else
  error('invalid xscale')
end
%JAVITAS VEGE

if strcmp(fname, 'point')
  box = [mean(range_f) mean(range_a)];
  %   [freq_vect, index_vect] = n_freq([mean(range_f) mean(range_a)], f_vect, a_vect, msg);
else
  box = [range_f(1) range_a(1) range_f(2) range_a(2)];
  %   [freq_vect, index_vect] = f_in_box([range_f(1) range_a(1) range_f(2) range_a(2)], f_vect, a_vect);
end;

val = get(findobj(myfig, 'tag','freqsel_uic_zsdspop'),'value');
str = get(findobj(myfig, 'tag','freqsel_uic_zsdspop'),'string');
str1 = str{val};
str2 = ' on ';
str3 = 'Freq & ';
val = get(findobj(myfig, 'tag','freqsel_uic_frffxfypop'),'value');
str = get(findobj(myfig, 'tag','freqsel_uic_frffxfypop'),'string');

if ~any(findstr(str{val}, 'output-input'))
   str4 = str{val};
elseif strcmp(get(ax, 'tag'), 'freqsel_axes_uaxes')
   str4 = 'OutAmp';
else 
   str4 = 'InpAmp';
end;

str5 = ': ';
%str6  = ['[' num2str(box) ']'];
prstr='%g  %g  %g  %g'; prstr=['[' prstr(1:4*length(box)-2) ']'];
str6  = sprintf(prstr, box);

message = [str1 str2 str3 str4 str5 str6];



function [sl, su] = scalekhz

% This function assumes that both in the lower and upper axis
% there is exactly one text object containing the label 'Hz', or 'kHz'.
% Since the f_vect is in Hz, the scaling factor is 0.001 if the axis
% is in kHz, 1 if it is in Hz.
axesl = findall(0, 'tag','freqsel_axes_laxes');
axesu = findall(0, 'tag','freqsel_axes_uaxes');
lchild = get(axesl,'children');
uchild = get(axesu,'children');
tl = findobj(lchild,'type','text');
tu = findobj(uchild,'type','text');
if isempty(tl)
   stringll = 'bingo';
else 
   stringll='bingo';
   stringl = get(tl,'string'); %JAVITANDO!!!
   if isa(stringl,'char'), stringl={stringl}; end %fix for string
   for i = 1:length(stringl)    % Itt feltetelezem, hogy legfeljebb egy Hz string van, vagy azonosak.
      if not(isempty(findstr('Hz', stringl{i})))
         stringll=stringl{i};
      end;
   end;
   
end;
if isempty(tu)
   stringuu = 'bingo';
else
   stringuu='bingo';
   stringu = get(tu,'string');
   if isa(stringu,'char'), stringu={stringu}; end %fix for string
   for i = 1:length(stringu)
      if not(isempty(findstr('Hz', stringu{i})))
         stringuu=stringu{i};
      end;
   end;
   
end;

switch (stringll)
case 'Hz',  sl = 1;
case 'kHz', sl = 0.001;
case 'MHz', sl = 0.000001;
case 'GHz', sl = 1e-9;
case 'THz', sl = 1e-12;
case 'mHz', sl = 1000;
otherwise, sl = 1;
end;

switch (stringuu)
case 'Hz',  su = 1;
case 'kHz', su = 0.001;
case 'MHz', su = 0.000001;
case 'GHz', su = 1e-9;
case 'THz', su = 1e-12;
case 'mHz', su = 1000;
otherwise,  su = 1;
end;



function [value, index] = n_freq (click_pos, f_vect, a_vect, msg)

% Returns the index and value of the first closest element of
% fvect to the current mouse click. In the algorithm the horizontal
% distance is used.
% avect (an abstract amplitude vector) is passed to the function
% in order to provide the possibility of later changes.

% The mouse click position is in axis units.

myfig=findall(0,'tag', 'freqselfig');
if isempty(myfig)
   myfig=findall(0,'tag', 'freqsel2fig');
end
if isempty(myfig)
   myfig=findall(0,'tag', 'freqsel3fig');
end

if ~isempty(findstr('InpAmp', msg))
   h=findobj(allchild(myfig),'flat', 'tag', 'freqsel_axes_uaxes');
else
   h=findobj(allchild(myfig),'flat', 'tag', 'freqsel_axes_laxes');
end;

pos=get(h,'position');
xlim=get(h,'xlim');
ylim=get(h,'ylim');

df_vect2 = (abs(f_vect-click_pos(1))./(xlim(2)-xlim(1))*pos(3)).^2;
da_vect2 = (abs(a_vect-click_pos(2))./(ylim(2)-ylim(1))*pos(4)).^2;
[value, index] = min(df_vect2+min(da_vect2,[],3));
value = f_vect(index);

function [f_vect,ia_vect,oa_vect,va_vect,cuy,fa_vect,vtf,na_vect]=getinpvars(tWin) 
%f_vect: frequency vector
%ia_vect: input amplitude vector
%oa_vect: output amplitude vector
%va_vect: variance vector: output, input, covariance
%cuy: covariance vector
%fa_vect: frf amplitudes
%vtf: variance of frf
%na_vect: noise-to-signal vector

inp=guidtard(tWin,'INPUT_var');
if isa(inp,'iddat')
  f_vect=inp.FreqPoints; %frequency vector
  F=length(f_vect);
  ia_vect = inp.input; %Input amplitudes
  if iscell(ia_vect), ia_vect=ia_vect{1}; end
  oa_vect = inp.output; %Output amplitudes
  if iscell(oa_vect), oa_vect=oa_vect{1}; end
  idelay=inp.inputdelay; if isempty(idelay), idelay=0; end
  if iscell(idelay), idelay=idelay{1}; end
  odelay=inp.outputdelay; if isempty(odelay), odelay=0; end
  if iscell(odelay), odelay=odelay{1}; end
  if iscell(ia_vect)
    if isnumeric(idelay)
      idelay=num2cell(idelay*ones(length(ia_vect),1));
      odelay=num2cell(odelay*ones(length(ia_vect),1));
    end
    ia_vectsav=ia_vect; ia_vect=exp(-j*2*pi*f_vect*idelay{1}).*ia_vectsav{1};
    oa_vectsav=oa_vect; oa_vect=exp(-j*2*pi*f_vect*odelay{1}).*oa_vect{1};
    for ii=2:size(ia_vectsav,2)
      ia_vect=cat(3,ia_vect,exp(-j*2*pi*f_vect*idelay{ii}).*ia_vectsav{ii});
      oa_vect=cat(3,oa_vect,exp(-j*2*pi*f_vect*odelay{ii}).*oa_vectsav{ii});
    end
  else
    ia_vect=exp(-j*2*pi*f_vect*(idelay)).*ia_vect;  
    oa_vect=exp(-j*2*pi*f_vect*(odelay)).*oa_vect;  
  end
  va_vect = inp.SisoVariance; %Vector of complex variances
  cuy=inp.CovVect;
end
smallinp=find(abs(ia_vect)<=100*length(ia_vect)*eps*max(abs(ia_vect)));
largeinp=find(abs(ia_vect)>100*length(ia_vect)*eps*max(abs(ia_vect)));
fa_vect=oa_vect;
fa_vect(largeinp)=oa_vect(largeinp)./ia_vect(largeinp); %frf amplitudes
fa_vect(smallinp)=NaN*smallinp;
if ~isempty(va_vect)
   if isnumeric(va_vect)&(size(va_vect,1)==1)
     va_vect=va_vect(ones(F,1),1:2);
     if ~isempty(cuy), cuy=cuy(ones(F,1),1); end
   elseif iscell(va_vect)
     for ie=1:length(va_vect)
       if (size(va_vect{ie},1)==1)
         va_vect{ie}=va_vect{ie}(ones(F,1),1:2);
       end
     end
   end
   if iscell(va_vect)
     varx=va_vect{1}(:,2); vary=va_vect{1}(:,1);
     if iscell(cuy), cuy=cuy{1}; end
   else
     varx=va_vect(:,2); vary=va_vect(:,1);
   end
   if isempty(cuy), cuy=zeros(F,1); end
   vtf=(vary+abs(fa_vect).^2.*varx-2*real(cuy.*conj(fa_vect))); %delay?
   vtf=abs(vtf)./ia_vect.^2; %variance of frf
   na_vect=vtf./abs(fa_vect.^2);
else
   vtf=[]; na_vect=[];
end
ia_vect(smallinp)=max(abs(ia_vect(largeinp)))*eps*ones(size(smallinp));
ia_vect(largeinp)=20*log10(abs(ia_vect(largeinp)));
oa_vect(smallinp)=max(abs(oa_vect(largeinp)))*eps*ones(size(smallinp));
oa_vect(largeinp)=20*log10(abs(oa_vect(largeinp)));
if iscell(va_vect)
  for ie=1:length(va_vect)
    va_vect{ie}=10*log10(abs(va_vect{ie}));
  end
else
  va_vect=10*log10(abs(va_vect));
end
fa_vect=20*log10(abs(fa_vect));
na_vect=10*log10(abs(na_vect));
vtf=10*log10(abs(vtf));
%
%End of getinpvars


function  DoneEnable(myfig);
% set close enable property
c=allchild(myfig);
h=[findobj(c, 'flat', 'tag', 'freqsel_uic_donepb'), ...
      findobj(c, 'flat', 'tag', 'freqsel_menu_file_close')];

index = guidtard(get(myfig, 'tag'), 'DATA_selected_freqs');
if length(index) > 0  % the number of required selected frequencies is 1 
   set(h, 'enable', 'on')
else
   set(h, 'enable', 'off')
end
%