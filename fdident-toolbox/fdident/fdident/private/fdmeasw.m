function fdmeasw(p1,p2,p3,p4,p5,seltype) 
%       Handle measurement window for time or frequency domain
%
%       Input arguments:
%       p1 - type of action
%       p2 - action modifier
%       p3 - caller
%       p4 - not used
%       p5 - not used
%       seltype - selection type (in playback mode)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 21-Aug-2003

mainfig=findall(0, 'tag','fdtool_main');
Me = 'fdmeasurement_main';
myfcn='fdmeasw';

if nargin >0 & ~strcmp(p1, 'init')
   myfig=findall(0,'tag',Me);
   
   if nargin == 6
      sender=p5;
      replay_mode= 'replay';
   else
      seltype=get(myfig,'selectiontype');
      eval(['sender=p', num2str(nargin) ';']);
      replay_mode= 'normal';
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                 INITIALIZATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin ==0 | strcmp(p1, 'init')
   tmp=findall(0, 'tag','fdmeasurement_main');
   if ~isempty(tmp) 
      % set(tmp,'visible','on');
      %figure(tmp);
      guiclose('fdmeasurement')         
   end
   
   fdmeadef
   fig = figure(...
      'Units','pixels',...
      'Position',[ fig_offsx fig_offsy fig_dx fig_dy ],...
      'Resize','off',...
      'color',figure_col,...
      'Tag','fdmeasurement_main',...
      'Name','Measurement in FDTool (under development)',...
      'NumberTitle','off',...
      'IntegerHandle', 'off',...
      'Handlevisibility', 'off',...
      'windowbuttonmotion', 'fdtool(''callback'',''fdmeasw'',''mouse_motion'')',...
      'Closerequestfcn','fdtool(''callback'',''fdmeasw'',''fdmeas_uic_cancelpb'',''fdmeas_uic_cancelpb'');',... 
      'visible','off'); 
   % resize is off...
   %    'resizefcn','fdtool(''callback'',''fdmeasw'',''resize'',''resize'')',...
   if strncmp(version,'5',1), set(fig,'Position',[ fig_offsx fig_offsy fig_dx fig_dy ]), end %fix in 5.3
   myfig=fig;
   fdwindef(myfig);  % set default window properties
   
   %  Uicontrol Object Creation 
   
   fdmeas_uic_donepb = uicontrol(...
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''fdmeasw'',''fdmeas_uic_donepb'',''fdmeas_uic_donepb'');', ...
      'Units','pixels',...
      'Position',[ donepb_offsx donepb_offsy donepb_dx donepb_dy ], ...
      'BackgroundColor',pushb_bgr_col,...
      'ForegroundColor',pushb_fg_col,...
      'String','Close', ...
      'tooltipstring','Close window and return data',...
      'HorizontalAlignment','center', ...
      'Style','pushbutton',...
      'enable', 'off', ...
      'Tag','fdmeas_uic_donepb',...
      'UserData',''); 
   fdmeas_uic_cancelpb = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''fdmeasw'',''fdmeas_uic_cancelpb'',''fdmeas_uic_cancelpb'');',... 
      'Units','pixels',...
      'Position',[ cancelpb_offsx cancelpb_offsy cancelpb_dx cancelpb_dy ],... 
      'BackgroundColor',pushb_bgr_col,...
      'ForegroundColor',pushb_fg_col,...
      'String','Cancel',... 
      'tooltipstring','Close window and do not return data',...
      'HorizontalAlignment','center',...
      'Style','pushbutton',... 
      'enable', 'on', ...
      'Tag','fdmeas_uic_cancelpb',... 
      'UserData',''); 
   fdmeas_uic_fdtakepb = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''fdmeasw'',''fdmeas_uic_fdtakepb'',''fdmeas_uic_fdtakepb'');',... 
      'Units','pixels',...
      'Position',[ fdtakepb_offsx fdtakepb_offsy fdtakepb_dx fdtakepb_dy ],... 
      'BackgroundColor',pushb_bgr_col,...
      'ForegroundColor',pushb_fg_col,...
      'String','Take data',... 
      'Tooltipstring','Take data from virtual instrument',...
      'HorizontalAlignment','center',...
      'Style','pushbutton',... 
      'enable', 'on', ...
      'Tag','fdmeas_uic_fdtakepb',... 
      'UserData',''); 
   fdmeas_uic_gotovipb = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''fdmeasw'',''fdmeas_uic_gotovipb'',''fdmeas_uic_gotovipb'');',... 
      'Units','pixels',...
      'Position',[ gotovipb_offsx gotovipb_offsy gotovipb_dx gotovipb_dy ],... 
      'BackgroundColor',pushb_bgr_col,...
      'ForegroundColor',pushb_fg_col,...
      'String','Goto VI',... 
      'Tooltipstring','Go to Virtual Instrument or HW emulator',...
      'HorizontalAlignment','center',...
      'Style','pushbutton',... 
      'enable', 'on', ...
      'Tag','fdmeas_uic_gotovipb',... 
      'UserData',''); 
   fdmeas_uic_viframe = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''fdmeasw'',''fdmeas_uic_viframe'',''fdmeas_uic_viframe'');',... 
      'Units','pixels',...
      'Position',[ viframe_offsx viframe_offsy viframe_dx viframe_dy ],... 
      'BackgroundColor',frame_bgr_col,...
      'ForegroundColor',frame_fg_col,...
      'String','Instruments',... 
      'HorizontalAlignment','left',...
      'Style','frame',... 
      'Tag','fdmeas_uic_viframe',... 
      'Enable','off',... 
      'UserData',''); 
   fdmeas_uic_hwpop = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'', ''fdmeasw'', ''fdmeas_uic_hwpop'',''fdmeas_uic_hwpop'');',... 
      'Units','pixels',...
      'Position',[ hwpop_offsx hwpop_offsy hwpop_dx hwpop_dy ],... 
      'BackgroundColor',radiob_bgr_col,...
      'ForegroundColor',radiob_fg_col,...
      'String',{'Hardware?'},... 
      'tooltipstring','Select hardware',...
      'HorizontalAlignment','left',...
      'Style','popupmenu',... 
      'Tag','fdmeas_uic_hwpop',... 
      'Interruptible', 'off', ...
      'UserData',''); 
   fdmeas_uic_vipop = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'', ''fdmeasw'', ''fdmeas_uic_vipop'',''fdmeas_uic_vipop'');',... 
      'Units','pixels',...
      'Position',[ vipop_offsx vipop_offsy vipop_dx vipop_dy ],... 
      'BackgroundColor',radiob_bgr_col,...
      'ForegroundColor',radiob_fg_col,...
      'String',{'Instrument?'},... 
      'tooltipstring','Select virtual instrument',...
      'HorizontalAlignment','left',...
      'Style','popupmenu',... 
      'Tag','fdmeas_uic_vipop',... 
      'Interruptible', 'off', ...
      'UserData',''); 
   fdmeas_uic_viinfopb = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''fdmeasw'',''fdmeas_uic_viinfopb'',''fdmeas_uic_viinfopb'');',... 
      'Units','pixels',...
      'Position',[ viinfo_offsx viinfo_offsy viinfo_dx viinfo_dy ],... 
      'BackgroundColor',pushb_bgr_col,...
      'ForegroundColor',pushb_fg_col,...
      'String','Info on VI',... 
      'Tooltipstring','Information on Virtual Instrument or HW emulator',...
      'HorizontalAlignment','center',...
      'Style','pushbutton',... 
      'enable', 'on', ...
      'Tag','fdmeas_uic_viinfopb',... 
      'UserData',''); 
   fdmeas_uic_vihdtext = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ vihdtext_offsx vihdtext_offsy vihdtext_dx vihdtext_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','Instruments',... 
      'HorizontalAlignment','center',...
      'Style','text',...
      'Tag','fdmeas_uic_vihdtext',... 
      'UserData',''); 
   guititle(fdmeas_uic_vihdtext);
   fdmeas_uic_ipsframe = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ ipsframe_offsx ipsframe_offsy ipsframe_dx ipsframe_dy ],... 
      'BackgroundColor',frame_bgr_col,...
      'ForegroundColor',frame_fg_col,...
      'String','',... 
      'HorizontalAlignment','left',...
      'Style','frame',... 
      'Tag','fdmeas_uic_ipsframe',... 
      'Enable','off',... 
      'UserData','');
   fdmeas_uic_exftext = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ exftext_offsx exftext_offsy exftext_dx exftext_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','Excitation signal',... 
      'HorizontalAlignment','center',...
      'Style','text',...
      'Tag','fdmeas_uic_exftext',... 
      'UserData',''); 
   fdmeas_uic_excsigtext(1) = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ var1rb_offsx var1rb_offsy var1rb_dx var1rb_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','Empty',...
      'tooltipstring','',...
      'HorizontalAlignment','left',...
      'Style','text',... 
      'Tag','fdmeas_uic_excsigtext(1)',... 
      'UserData',''); 
   fdmeas_uic_excsigtext(2) = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ var2rb_offsx var2rb_offsy var2rb_dx var2rb_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','Empty',...
      'tooltipstring','',...
      'HorizontalAlignment','left',...
      'Style','text',... 
      'Tag','fdmeas_uic_excsigtext(2)',... 
      'UserData',''); 
   fdmeas_uic_excsigtext(3) = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ var3rb_offsx var3rb_offsy var3rb_dx var3rb_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','Empty',...
      'tooltipstring','',...
      'HorizontalAlignment','left',...
      'Style','text',... 
      'Tag','fdmeas_uic_excsigtext(3)',... 
      'UserData',''); 
   
   fdmeas_uic_tdtext = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ tdtext_offsx tdtext_offsy tdtext_dx tdtext_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','Delay:',...
      'tooltipstring','Delay to wait for the end of system transients',...
      'HorizontalAlignment','left',...
      'Style','text',... 
      'Tag','fdmeas_uic_tdtext',... 
      'UserData',''); 
   fdmeas_uic_tdedit = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'',''fdmeasw'',''ui_edit'',''fdmeas_uic_tdedit'');',...
      'Units','pixels',...
      'Position',[ tdedit_offsx tdedit_offsy tdedit_dx tdedit_dy ],... 
      'BackgroundColor',edit_bgr_col,...
      'ForegroundColor',edit_fg_col,...
      'String','Inf',... 
      'tooltipstring','Delay to wait for the end of system transients',...
      'HorizontalAlignment','right',...
      'Style','edit',... 
      'Tag','fdmeas_uic_tdedit',... 
      'UserData',''); 
   fdmeas_uic_tdtext2 = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ tdtext2_offsx tdtext2_offsy tdtext2_dx tdtext2_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','samples',...
      'tooltipstring','Delay to wait for the end of system transients',...
      'HorizontalAlignment','left',...
      'Style','text',... 
      'Tag','fdmeas_uic_tdtext2',... 
      'UserData',''); 
   fdmeas_uic_ptpop = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'',''fdmeasw'',''fdmeas_uic_ptpop'', ''fdmeas_uic_ptpop'')',...
      'Units','pixels',... 
      'Position',[ ptpop_offsx ptpop_offsy ptpop_dx ptpop_dy ],... 
      'BackgroundColor',popup_bgr_col,... 
      'ForegroundColor',popup_fg_col,...
      'HorizontalAlignment','right',... 
      'String',{'Periodic','One-shot'},...
      'tooltipstring','Repeat input signal periodically, or apply it just once',...
      'Style','popup',... 
      'Tag','fdmeas_uic_ptpop',... 
      'UserData',''); 
   fdmeas_uic_pttext = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ pttext_offsx pttext_offsy pttext_dx pttext_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','Apply input signal as:',...
      'tooltipstring','Repeat input signal periodically, or apply it just once',...
      'HorizontalAlignment','left',...
      'Style','text',... 
      'Tag','fdmeas_uic_pttext',... 
      'UserData','');
   fdmeas_uic_netext = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ netext_offsx netext_offsy netext_dx netext_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','# of experiments:',...
      'tooltipstring','Number of experiments to be generated',...
      'HorizontalAlignment','left',...
      'Style','text',... 
      'Tag','fdmeas_uic_netext',... 
      'UserData',''); 
   fdmeas_uic_needit = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'',''fdmeasw'',''ui_edit'',''fdmeas_uic_needit'');',...
      'Units','pixels',...
      'Position',[ needit_offsx needit_offsy needit_dx needit_dy ],... 
      'BackgroundColor',edit_bgr_col,...
      'ForegroundColor',edit_fg_col,...
      'String','1',... 
      'tooltipstring','Number of experiments to be generated',...
      'HorizontalAlignment','right',...
      'Style','edit',... 
      'Tag','fdmeas_uic_needit',... 
      'UserData',''); 
   fdmeas_uic_retext = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ retext_offsx retext_offsy retext_dx retext_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','# of repetitions:',...
      'tooltipstring','Number of consecutive repetitions of signal',...
      'HorizontalAlignment','left',...
      'Style','text',... 
      'Tag','fdmeas_uic_retext',... 
      'UserData',''); 
   fdmeas_uic_reedit = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'',''fdmeasw'',''ui_edit'',''fdmeas_uic_reedit'');',...
      'Units','pixels',...
      'Position',[ reedit_offsx reedit_offsy reedit_dx reedit_dy ],... 
      'BackgroundColor',edit_bgr_col,...
      'ForegroundColor',edit_fg_col,...
      'String','1',... 
      'tooltipstring','Number of consecutive repetitions of signal',...
      'HorizontalAlignment','right',...
      'Style','edit',... 
      'Tag','fdmeas_uic_reedit',... 
      'UserData',''); 
   fdmeas_uic_calpop = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'',''fdmeasw'',''fdmeas_uic_calpop'', ''fdmeas_uic_calpop'')',...
      'Units','pixels',... 
      'Position',[ calpop_offsx calpop_offsy calpop_dx calpop_dy ],... 
      'BackgroundColor',popup_bgr_col,... 
      'ForegroundColor',popup_fg_col,...
      'HorizontalAlignment','right',... 
      'String',{'calibration off','calibration on'},...
      'tooltipstring','Handle calibration data (remove FRF imperfections from processed data)',...
      'Tag','fdmeas_uic_calpop',... 
      'Style','popup',... 
      'UserData',''); 
   fdmeas_uic_calpb = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'',''fdmeasw'',''fdmeas_uic_calpb'', ''fdmeas_uic_calpb'')',...
      'Units','pixels',... 
      'Position',[ calpb_offsx calpb_offsy calpb_dx calpb_dy ],... 
      'BackgroundColor',pushb_bgr_col,... 
      'ForegroundColor',pushb_fg_col,...
      'HorizontalAlignment','center',... 
      'String','Get cal. data',...
      'tooltipstring','Take or read calibration data',...
      'Tag','fdmeas_uic_calpb',... 
      'Style','pushbutton',... 
      'interruptible', 'off', ...   
      'UserData',''); 
   fdmeas_uic_statusframe = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ statusframe_offsx statusframe_offsy statusframe_dx statusframe_dy ],... 
      'BackgroundColor',frame_bgr_col,...
      'ForegroundColor',frame_fg_col,...
      'String','statusframe',... 
      'HorizontalAlignment','left',...
      'Style','frame',... 
      'Tag','fdmeas_uic_statusframe',... 
      'Enable','off',... 
      'UserData','');
   fdmeas_uic_statustext = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ statustext_offsx statustext_offsy statustext_dx statustext_dy ],... 
      'BackgroundColor',text_bgr_col,...
      'ForegroundColor',text_fg_col,...
      'String','',... 
      'HorizontalAlignment','left',...
      'Style','text',...
      'Tag','fdmeas_uic_statustext',... 
      'UserData','');
    
   %  Menu Object Creation 
   guimenus(Me,'measurement','fdmeasw');
   
   % init help fcns
   helpmgr('init_help', '', myfcn, myfig );
   
   if nargin==2  % session load: fdmeasw('init', initvar)
      storewin('restore', Me, p2);
      fdmeasw('setvipop')
   else
      % fdmeasw('init', 'FREQ' or 'TIME', 'gfdd' or 'gettime')
      caller_info=struct('ID', p2, 'fcn', p3);
      switch p2
      case 'FREQ'
         status=guidtard('getfreq_main', 'STATUS_MEASUREMENT');
      case 'TIME'
         status=guidtard('gettime_main', 'STATUS_MEASUREMENT');
      end
      storewin('restore', Me, status);
      fdmeasw('setvipop',p2)
      guidtawr(Me, 'DATA_OUTDATA', 'direct', '')  % clear previous result
      guidtawr(Me, 'DATA_CALLER_INFO', 'direct', caller_info)
   end
   
   fdmeasw('check_rb_settings') % check and correct rb settings if necesssary
   set(fig,'visible','on'); 
   winmenu(myfig);
   fdmeasw('status', 'Ready.')
   %fdmeasw('fdmeas_uic_vipop') %Generate warnings if necessary
   
elseif strcmp(p1,'status')
   status=findobj(allchild(myfig), 'flat', 'tag', 'fdmeas_uic_statustext');
   statusfr=findobj(allchild(myfig), 'flat', 'tag', 'fdmeas_uic_statusframe');
   glstatus(myfig, status, statusfr, p2)
   
elseif strcmp(p1, 'mouse_motion')   
   guiready(myfig, 'fdmeasw')
   
elseif strcmp(p1,'setvipop')
   %First fill in Hardware list
   hh=findobj(myfig,'tag','fdmeas_uic_hwpop');
   hwall=fdhwcall('Hardware');
   caller_info=guidtard(Me, 'DATA_CALLER_INFO');
   if isstruct(caller_info)
     p2=caller_info.ID;
   end
   for ii=length(hwall):-1:1
     info=fdhwcall('Type',hwall{ii});
     if ~isempty(info)
       if ~any(findstr(p2,info.domain)), hwall(ii)=[]; end
     end
   end
   if isempty(hwall), hwall={'none'}; end
   vhh=min(get(hh,'value'),length(hwall));
   set(hh,'string',hwall,'value',vhh)
   hwstr=hwall{vhh}; %This is the selected HW
   
   %Now fill in VI list
   excsig=guidtard('fdtool_main', 'OUTPUT_excitation');
   h=findobj(myfig,'tag','fdmeas_uic_vipop');
   gval=get(h,'value');
   gstr=get(h,'string');
   if ~isempty(gval)&(length(gval)==1)&(gval>=1)&(gval<=length(gstr))
      vistr=gstr{gval};
   else
      vistr='';
   end
   vis=fdhwcall('Instruments',hwstr);
   visv=length(vis);
   oldvi=0;
   if ~exist('p2'), p2='E'; end
   for visii=length(vis):-1:1
      props=fdhwcall('type',[hwstr,'/',vis{visii}]);
      [stat,msg]=fdhwcall('hw_chk',[hwstr,'/',vis{visii}]);
      if any(findstr(lower(p2),lower(props.domain)))
         if any(stat)&(oldvi==0)
            visv=visii;
            if strcmp(vis{visv},vistr), oldvi=1; end
            if isfield(props,'tooltipstring')
               tts=props.tooltipstring;
               set(h,'tooltipstring',tts)
            end
         end
      else
         vis(visii)=[]; visv=visv-1;
      end
   end
   if isempty(vis)
     vis={'none'}; visv=1;
     set(h,'tooltipstring','No instrument in this domain')  
   else
     if gval<=visv, visv=gval; end
   end
   set(h,'string',vis,'value',visv)
   if strcmp(p2,'TIME')
     set(findobj(myfig,'tag','fdmeas_uic_calpop'),'visible','off')
     set(findobj(myfig,'tag','fdmeas_uic_calpb'),'visible','off')
   elseif (visv==0)|any(findstr(vis{visv},'emula'))
      set(findobj(myfig,'tag','fdmeas_uic_calpb'),'enable','on')
      set(findobj(myfig,'tag','fdmeas_uic_calpop'),'value',1,'enable','off')
   else
     set(findobj(myfig,'tag','fdmeas_uic_calpb'),'enable','on')
     set(findobj(myfig,'tag','fdmeas_uic_calpop'),'enable','on')
   end
   if isa(excsig,'tiddata')
      pl=excsig.periodlength;
      if isnan(pl)|isempty(pl)
         fv=excsig.frequencies;
         if ~isempty(fv)
            pl=1/dfcalc([fv(:)]); %;1/excsig.ts
         end
      end
      Pno=excsig.ts*(excsig.samplen/pl);
      if rem(Pno,1)==0
        txt1=sprintf('%.0f samples, %.0f periods',excsig.samplen,Pno);  
      else
        txt1=sprintf('%.0f samples, %.3f periods',excsig.samplen,Pno);  
      end
      txt2=sprintf('fc = %.4g Hz',1/excsig.ts);
      freqv=excsig.frequencies;
      txt3='';
      if ~isempty(freqv)
         txt3=sprintf('freqs: F = %.0f,  [%.4g Hz - %.4g Hz]',...
            length(freqv),min(freqv),max(freqv));
      end
   else
      txt1='Empty';
      txt2='';
      txt3='';
   end
   h=findall(myfig,'Tag','fdmeas_uic_excsigtext(1)');
   set(h,'string',txt1)
   h=findall(myfig,'Tag','fdmeas_uic_excsigtext(2)');
   set(h,'string',txt2)
   h=findall(myfig,'Tag','fdmeas_uic_excsigtext(3)');
   set(h,'string',txt3)
   %
   set(findall(myfig,'tag','fdmeas_uic_fdtakepb'),'enable','on')
   fdmeasw('close_enable','off')
   
elseif strcmp(p1,'fdmeas_uic_viinfopb')
   VIname=whichvi(myfig,'hw');
   [info,msg]=fdhwcall('Information',VIname);
   if isempty(info)
      info='Sorry! No information provided.';
      if ~isempty(msg), fdmeasw('status',msg), end
   end
   %disp(info)
   helpwin(info,'','VI information')
   if isempty(msg)
      fdmeasw('status','VI information has been displayed.')
   end
   
elseif strcmp(p1,'fdmeas_uic_donepb')
   outdata=guidtard(Me, 'DATA_OUTDATA');
   if isempty(outdata)
      fdmeasw('gotovi')
      outdata=guidtard(Me, 'DATA_OUTDATA');
   end
   if isempty(outdata)
      fdmeasw('take_data')
      outdata=guidtard(Me, 'DATA_OUTDATA');
   end
   %
   if isempty(outdata) % measurement failed: do not close
      return   
   end
   
   h=findobj(myfig,'tag','fdmeas_uic_calpop');
   string=popupstr(h);
   if any(findstr(string,'on'))
     caldata=guidtard(Me, 'DATA_CALIBR_DATA');
     if isa(caldata,'fiddata')
       outdata=modifyfv(outdata,caldata);
     elseif isa(caldata,'fidmodel')
       outdata=modifyfv(outdata,caldata);
     end
   end
   
   fdmeasw('status', 'Closing...')
   fdhwcall('close_all_instruments',whichvi(myfig,'hw'));
   
   caller_info=guidtard(Me, 'DATA_CALLER_INFO');
   ID=caller_info.ID; fcn=caller_info.fcn;
   status=storewin('store_all', Me);
   
   switch ID
   case 'FREQ'
      guidtawr('getfreq_main', 'STATUS_MEASUREMENT', 'direct', status);
   case 'TIME'
      guidtawr('gettime_main', 'STATUS_MEASUREMENT', 'direct', status);
   end
   guiclose('fdmeasurement'), drawnow
   feval(fcn, 'measurement_ready', 'done', outdata);  
   
   
elseif strcmp(p1,'fdmeas_uic_cancelpb')
   fdmeasw('status', 'Canceling...', Me);
   fdhwcall('close_all_instruments',whichvi(myfig,'hw'));
   caller_info=guidtard(Me, 'DATA_CALLER_INFO');
   ID=caller_info.ID; fcn=caller_info.fcn;
   guiclose('fdmeasurement')
   feval(fcn, 'measurement_ready', 'cancel', '');  
   
elseif strcmp(p1,'fdmeas_uic_gotovipb') | strcmpi(p1, 'gotovi') %Goto VI
   guidtawr(Me, 'DATA_OUTDATA', 'direct', []) %clear previous data
   fdmeasw('close_enable','off')
   %
   input_data=guidtard('fdtool_main', 'OUTPUT_excitation');
   %guifreez(Me, 'freeze', 'fdmeas_measurement');
   caller_info=guidtard(Me, 'DATA_CALLER_INFO');
   mode=caller_info.ID; fcn=caller_info.fcn;
   c=allchild(myfig);
   No_exp=str2num(get(findobj(c, 'flat', 'tag', 'fdmeas_uic_needit') ,'string'));
   No_rep=str2num(get(findobj(c, 'flat', 'tag', 'fdmeas_uic_reedit') ,'string')); %
   if No_rep>1
     pl=input_data.periodlength;
     if isempty(pl), pl=1/dfcalc(input_data); end
     if ~isempty(pl)&(abs(rem(input_data.samplenumber*input_data.ts/pl+0.5,1)-0.5)>100*eps)
       fdmeasw('status','Error: signal with fractional periods is repeated')
       error('Signal with fractional periods is repeated')
     end
   end
   %input_data=guidtard('fdtool_main', 'OUTPUT_excitation');
   %Now measurement follows
   %First check if there is HW
   VIname=whichvi(myfig,'hw');
   isopen=fdhwcall('isopen',VIname);
   
   if strcmp(mode, 'FREQ')|strcmp(mode, 'TIME')
      VIname=whichvi(myfig,'hw');
      if isempty(VIname)
         fdmeasw('status','Error: no instrument is selected')
         outdata=[];
         guifreez(Me, 'unfreeze', 'fdmeas_measurement');
         return
      else
        hh=findobj(myfig,'tag','fdmeas_uic_hwpop');
        hwall=fdhwcall('Hardware');
        if isempty(hwall), hwall={'none'}; end
        vhh=min(get(hh,'value'),length(hwall));
        hwstr=hwall{vhh}; %This is the selected HW
        [stat,msg]=fdhwcall('hw_chk',VIname); %whichvi already added hw name
        if isempty(stat)
          fdmeasw('status',['Error: ',msg])
          outdata=[];
          guifreez(Me, 'unfreeze', 'fdmeas_measurement');
          return
        elseif isequal(stat,1)
          fdmeasw('status', 'Measurement in progress...', Me);  
        elseif isequal(stat,-1)
          fdmeasw('status', 'Emulation in progress...', Me);  
        else
          fdmeasw('status', 'Warning: status value is illegal', Me);  
        end
        excsig=guidtard('fdtool_main', 'OUTPUT_excitation');
        if isa(excsig,'tiddata')&(excsig.expn>1)
          %outdata=0; msg='Warning: several experiments in excitation signal';
          %return
        end
        h=findall(myfig,'tag','fdmeas_uic_needit');
        expno=str2num(get(h,'string'));
        if expno<1
          fdmeasw('status','Error: experiment number is less than 1')
          guifreez(Me, 'unfreeze', 'fdmeas_measurement');
          return
        end
        params.expno=expno;
        delay=str2num(get(findobj(c,'flat','tag','fdmeas_uic_tdedit'),'string'));
        params.delay=delay;
        charv=get(findobj(c,'flat','tag','fdmeas_uic_ptpop'),'value');
        charstr=get(findobj(c,'flat','tag','fdmeas_uic_ptpop'),'string');
        params.character=charstr{charv};
        %
        if rem(No_rep,1)~=0
          fdmeasw('status','Error: repetition number is not integer')
          guifreez(Me, 'unfreeze', 'fdmeas_measurement');
          return
        end
        params.repno=No_rep;
        %
        Nsobj=fdhwcall('Properties',VIname,'Ns',1024);
        Ns=Nsobj.Ns; % default Ns
        if isa(excsig,'tiddata'), Ns=excsig.samplen; end
        [outdata,msg]=fdhwcall('Properties',VIname,...
          'Ns',Ns,'expno',No_exp,'repno',No_rep);
        if (outdata.Ns<Ns)|(outdata.expno<No_exp)|(outdata.repno<No_rep)
          fdmeasw('status','Error: too many points requested')
          guifreez(Me, 'unfreeze', 'fdmeas_measurement');
          return
        end
        [outdata,msg]=fdhwcall('Measure',VIname,excsig,params);
        if isempty(outdata)
          if ~isempty(msg)
            fdmeasw('status',msg)
          end
          guifreez(Me, 'unfreeze', 'fdmeas_measurement');
          return
        else
          if (outdata.expn>1)
            if excsig.expn>1
              outdata.Ref=excsig.inputdata;
            elseif No_exp>1
              %if isempty(outdata.synchronized), outdata.synchronized='on'; end
            end
          end
        end
      end
   end
   
   if isa(outdata,'iddat') %Proper data
      addhist(outdata, 'Measured data.');
      guidtawr(Me, 'DATA_OUTDATA', 'direct', outdata)
      
      % if measurement pb pressed then plot result 
      if strcmp(p1,'fdmeas_uic_gotovipb') 
         if isa(outdata, 'tiddata')
            arrplot('tim_meas_update')
         else % fiddata
            arrplot('freq_meas_update')
         end
      end
      %fdmeasw('status', 'Measurement ready', Me);
   else
      if ~isempty(msg)&isstr(msg)
         fdmeasw('status',msg)  
      else
         fdmeasw('status','Warning: data is not yet taken from virtual instrument')
      end
      guifreez(Me, 'unfreeze', 'fdmeas_measurement');
      return
   end
   guifreez(Me, 'unfreeze', 'fdmeas_measurement');
   % end of measurement
   if isa(guidtard(Me, 'DATA_OUTDATA'),'iddat')
      fdmeasw('status','#yVirtual instrument has returned data')  
      fdmeasw('close_enable','on')
      %Check if returned data are as expected
      check_generated_data(outdata)  
   end
   %
   if isopen
     fdmeasw('take_enable','on')
   else
     fdmeasw('close_enable','on')
     fdmeasw('take_enable','off')
   end
   
elseif strcmp(p1,'fdmeas_uic_fdtakepb') | strcmpi(p1, 'take_data') | ...
      strcmpi(p1, 'take_calibr_data')
   %fdmeasw('close_enable','off')
   VIname=whichvi(myfig,'hw');
   %
   isopen=fdhwcall('isopen',VIname);
   if isequal(isopen,1)
      set(findall(myfig,'tag','fdmeas_uic_fdtakepb'),'enable','on')
   else
      set(findall(myfig,'tag','fdmeas_uic_fdtakepb'),'enable','on')
      fdmeasw('status','Warning: virtual instrument is not open')
      return
   end
   %
   
   if strcmpi(p1, 'take_data')
      guidtawr(Me, 'DATA_OUTDATA', 'direct', []) %clear previous data
   else   
      guidtawr(Me, 'DATA_CALIBR_DATA', 'direct', []) %clear previous data
   end
   excsig=guidtard('fdtool_main', 'OUTPUT_excitation');
   
   h=findall(myfig,'tag','fdmeas_uic_needit');
   No_exp=str2num(get(h,'string'));
   h=findall(myfig,'tag','fdmeas_uic_reedit');
   No_rep=str2num(get(h,'string'));
   Nsobj=fdhwcall('Properties',VIname,'Ns',1024);
   Ns=Nsobj.Ns; % default Ns
   if isa(excsig,'tiddata'), Ns=excsig.samplen; end
   [outdata,msg]=fdhwcall('Properties',VIname,...
     'Ns',Ns,'expno',No_exp,'repno',No_rep);
   if (outdata.Ns<Ns)|(outdata.expno<No_exp)|(outdata.repno<No_rep)
     fdmeasw('status','Error: too many points requested')
     guifreez(Me, 'unfreeze', 'fdmeas_measurement');
     return
   end

   [outdata,msg]=fdhwcall('take_data',VIname,excsig);
   if isa(outdata,'iddat')&...
         (strcmpi(p1, 'take_data')|strcmp(p1,'fdmeas_uic_fdtakepb'))
      guidtawr(Me, 'DATA_OUTDATA', 'direct', outdata)
      % if take data pb pressed then plot result 
      if strcmp(p1,'fdmeas_uic_fdtakepb') 
         if isa(outdata, 'tiddata')
            arrplot('tim_meas_update')
         else % fiddata
            arrplot('freq_meas_update')
         end
      end
      fdmeasw('close_enable','on')
      check_generated_data(outdata)
   elseif isa(outdata,'iddat')&strcmpi(p1, 'take_calibr_data')
      guidtawr(Me, 'DATA_CALIBR_DATA', 'direct', outdata)
   elseif ~isempty(msg)
      fdmeasw('status',['#r',msg])
   else
      error('Empty msg, invalid outdata')
   end
   %
   set(findall(myfig,'tag','fdmeas_uic_fdtakepb'),'enable','on')
   
elseif strcmp(p1,'fdmeas_uic_hwpop')
  caller_info=guidtard(Me, 'DATA_CALLER_INFO');
  if isstruct(caller_info)
    p2=caller_info.ID;
  end
  fdmeasw('setvipop',p2)
  
elseif strcmp(p1,'fdmeas_uic_vipop')
   hw=findobj(myfig,'tag','fdmeas_uic_hwpop');
   hwv=get(hw,'value'); hws=get(hw,'string');
   hwstr=hws{hwv};
   
   ht=findobj(myfig,'tag','fdmeas_uic_vipop');
   s=fdhwcall('Instruments',hwstr);
   set(ht,'String',s)
   fdmeasw('setvipop')
   
   %Allow valid v only
   v=get(ht,'value');
   if v>length(s)
     v=1; set(ht,'value',v)
     if length(s)==0
       s={'none'}; set(ht,'string',s)
       set(ht,'tooltipstring','No instrument in this domain')  
     end
   end
   excsig=guidtard('fdtool_main', 'OUTPUT_excitation');
   OK=1;
   if ~isequal(s,{'none'})
     vi=s{v};
     props=fdhwcall('type',[hwstr,'/',vi]);
     if isfield(props,'tooltipstring')
       tts=props.tooltipstring;
     else
       tts='';
     end 
     set(ht,'tooltipstring',tts)
     if isfield(props,'input')
       if strcmp(props.input,'needed')&isempty(excsig)
         fdmeasw('status','Warning: No excitation signal given')
         OK=0;
       end
     end
     [stat,msg]=fdhwcall('hw_chk',[hwstr,'/',vi]);
     if isempty(stat)
       ind=findstr(msg,'Error');
       if ~isempty(ind), msg=['Warning',msg(6:end)];
       else msg=['#y',msg];
       end
       fdmeasw('status',msg)
     end
     set(findall(myfig,'tag','fdmeas_uic_fdtakepb'),'enable','on')
   else
     fdmeasw('status','Warning: No instrument available')
     OK=0;
   end
   %
   fdmeasw('close_enable','off')
   if OK==1; fdmeasw('status','Ready.'), end
   
   
elseif strcmp(p1, 'ui_list')
   % This is to make replay possible
   h=findobj(myfig,'tag',sender);
   str=get(h,'string');
   ix=-1;
   for i=1:length(str);
      if strcmpi(str(i),p2), ix=i; end
   end
   if ix ~=-1, 
      set(h,'value',ix), 
      guidtawr(Me, 'DATA_OUTDATA', 'direct', '') % clear prev meas result if any
   else
      errordlg(['Fdmeas replay failed, bad parameter: ' p2],  'Error', 'replace');
      error(['Fdmeas replay failed']);
   end
   
elseif strcmp(p1, 'fdmeas_uic_ptpop')   
   guidtawr(Me, 'DATA_OUTDATA', 'direct', '') % clear prev meas result if any
   
elseif strcmp(p1, 'fdmeas_uic_calpb')   
   % ####PISTI  itt be kell allitani, hopgy a take funkcio engedelyezett-e
   take_enable=1;
   if take_enable
      getcald('init')
   else
      getcald('init2')
   end
   
elseif strcmp(p1, 'calibration_selection')
   switch p2
   case 'cancel'
      fdmeasw('status','Get Calibration Data cancelled ')
   case 'fiddata'
      guifreez(Me, 'freeze_strong', 'import_caldata');
      fdmeasw('status','$yGet Calibration fiddata in the Import window')
      guiimpv('init', myfcn, 'caldata', [], 'filter: fiddata Object')
   case 'fidmodel'
      guifreez(Me, 'freeze_strong', 'import_caldata');
      fdmeasw('status','$yGet Calibration fidmodel data in the Import window')
      guiimpv('init', myfcn, 'caldata', [], 'filter: fidmodel object')
   case 'take'
      fdmeasw('take_calibr_data')
      guidtawr(Me, 'DATA_OUTDATA', 'direct', ''); % clear prev meas result if any
      fdmeasw('calibration_on/off')
   end
   
   
elseif strcmp(p1, 'import_ready')
   switch  p2
   case 'cancel'
      switch p3 % caller_ID
      case 'caldata' 
         guifreez(Me, 'unfreeze', 'import_caldata');
         fdmeasw('calibration_on/off')
      end
   case 'done'
      % h=findall(0, 'tag', 'fdtool_importfig');
      data=guidtard('fdtool_importfig', 'IMPORTED_VAR');
      switch p3 % caller_ID
      case 'caldata'
             guidtawr(Me,'DATA_CALIBR_DATA','direct',data);
        guidtawr(Me, 'DATA_OUTDATA', 'direct', ''); % clear prev meas result if any
        guifreez(Me, 'unfreeze', 'import_caldata');
        fdmeasw('calibration_on/off')
     end
   end
   
elseif strcmp(p1, 'calibration_on/off')
   caldata=guidtard(Me, 'DATA_CALIBR_DATA');
   h=findobj(myfig,'tag','fdmeas_uic_calpop');
   if ~isa(caldata,'fiddata')&~isa(caldata,'fidmodel')
      set(h,'enable','off','Value',1) %Calibration off
   else   
      set(h,'enable','on') %Calibration on option enable
   end
   
 elseif strcmp(p1, 'fdmeas_uic_calpop')   
   h=findobj(myfig,'tag','fdmeas_uic_calpop');
   string=popupstr(h);
   if any(findstr(string,'off'))
      %nothing to do
      return
   elseif any(findstr(string,'on'))
      %nothing to do, but check validity
   else error(['Unknown string ''',string,''''])
   end
   caldata=guidtard(Me, 'DATA_CALIBR_DATA');
   if isa(caldata,'fiddata')|isa(caldata,'fidmodel')
      set(h,'Value',2) %Calibration on 
   else
      set(h,'Value',1) %Calibration off
   end

elseif strcmp(p1, 'fdmeas_uic_vipop')   
   guidtawr(Me, 'DATA_OUTDATA', 'direct', '') % clear prev meas result if any
      
elseif strcmp(p1,'ui_edit')
   h=findobj(myfig,'tag',sender);
   edstr=get(h,'string');
   ednum=str2num(edstr);
   if any(isnan(ednum)), ednum=[]; end
   orig_num=ednum;
   if strcmp(sender, 'fdmeas_uic_needit')  % number of experiments
      if isempty(ednum) | any(ednum < 1)
         ednum=10;
      else
         ednum=floor(ednum(1,1));
      end
      edstr=num2str(ednum);
      set(h,'string',edstr);
   elseif strcmp(sender, 'fdmeas_uic_tdedit') % delay 
      if isempty(ednum)|isnan(ednum)
         ednum=Inf;
      elseif  any(ednum < 0)
         ednum=0;
      else
         ednum=ednum(1,1);
      end
      edstr=num2str(ednum);
      set(h,'string',edstr);
   elseif strcmp(sender, 'fdmeas_uic_reedit') % number of repetitions
      if isempty(ednum)| any(ednum < 0)
         ednum=1;
      else
         ednum=floor(ednum(1,1));
      end
      edstr=num2str(ednum);
      set(h,'string',edstr);
   else % SNR values
   end
   if ~isequal(orig_num, ednum)
      fdmeasw('status', 'Warning: Bad input value automatically corrected.')
   else
      fdmeasw('status', 'Input value accepted')
   end
   %guidtawr(Me, 'DATA_OUTDATA', 'direct', '') % clear prev sim result if any
   fdmeasw('close_enable','off')
   
elseif strcmp(p1, 'close_enable')   
   % p2= 'on' or 'off' or 'set'
   % enable/disable measure and close pbs
   % 'set' checks amplitude settings and sets enable according to it
   c=allchild(myfig);
   h_pb=[findobj(c, 'flat', 'Tag','fdmeas_uic_donepb'),...
         findobj(c, 'Tag','measurement_menu_file_close')];  % <- menu, not flat !
   set(h_pb, 'enable', p2)
   
   
elseif strcmp(p1, 'take_enable')   
   % p2= 'on' or 'off' or 'set'
   % enable/disable take pbs
   c=allchild(myfig);
   h_pb=findobj(c, 'flat', 'Tag','fdmeas_uic_fdtakepb');
   set(h_pb, 'enable', p2)
   
   
elseif strcmp(p1,'check_rb_settings')
   % check andcorrect rb settings according to current fdtool state
   c=allchild(myfig);
   %---- TIME/FREQ: set visibility
   caller_info=guidtard(Me, 'DATA_CALLER_INFO');
   mode=caller_info.ID; fcn=caller_info.fcn;
   if strcmp(mode, 'TIME')
   else %frequency
      h2=[findobj(c, 'flat', 'Tag','fdmeas_uic_tdtext');
         findobj(c, 'flat', 'Tag','fdmeas_uic_tdedit');
         findobj(c, 'flat', 'Tag','fdmeas_uic_tdtext2');
         findobj(c, 'flat', 'Tag','fdmeas_uic_pttext');
         findobj(c,'flat', 'Tag', 'fdmeas_uic_ptpop')];
      set(h2, 'visible', 'off') 
   end
   
   
   
elseif findstr(p1, 'fdmeas_uic_amplhlp')   
   % help on amplitude settings: text info or plot
   mode=any(findstr(p1, '2'));  % 0: info, 1: plot
   c=allchild(myfig);
   h_mod=findobj(c, 'flat', 'userdata', 'fdmeas_uic_mgrb', 'value', 1);
   t_mod=get(h_mod, 'tag');
   moddat='';
   if isempty(h_mod)
      % no amplitude specified
      ampl_dat='';
      FirstLine='No amplitude data specified yet. Select on option.';
   elseif any(findstr(t_mod,'(5)')) % Import FRF of TIME
      ampl_dat=guidtard(Me, 'IMPORTDATA_FRF_TIME'); 
      FirstLine=['Info on measurement/amplitude (' get(h_mod, 'string') ')'];
   else
      % model specified
      ampl_dat=guidtard(Me, 'IMPORTDATA_MODEL');
      FirstLine=['Info on measurement/amplitude (' get(h_mod, 'string') ')'];
   end
   
   if mode ==0 
      garrinfo(1001, ampl_dat, FirstLine)
   else
      if isa(ampl_dat, 'fidmodel')
         arrplot('fidmodel', ampl_dat);
      elseif isa(ampl_dat, 'fiddata') 
         arrplot('fiddata', ampl_dat);
      elseif isa(ampl_dat, 'tiddata') 
         % if more experiments, select first
         %small_dat=tiddata(ampl_dat.output{1}, ampl_dat.output{1}, ampl_dat.ts); 
         %arrplot('tiddata', small_dat); 
         arrplot('tiddata',ampl_dat); 
      end
   end
   
elseif strcmp(p1,'fdmeas_uic_print')
   %fdmeas print command
   fdgprint(Me)
   fdmeasw('status','Print figure done.')
   
elseif strcmp(p1,'fdmeas_mod_print_ps')
   %fdmeas print command
   fdgprint(Me,'ps')
   
elseif strcmp(p1, 'preload')
   % preload, nothing to do
   
elseif strcmp(p1,'resize')
   
   mindx=500;
   mindy=280;
   scr=get(0,'screensize');
   mainfigmaxx=scr(3);
   mainfigmaxy=scr(4);
   
   
   pos=get(findobj(myfig, 'tag','fdmeasurement_main'),'position');
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
   set(myfig,'position',[fig_offsx fig_offsy fig_dx fig_dy]);
   fromframe_dx=60;
   fromevalpb_dy=60;
   pos=get(findobj(myfig, 'tag','fdmeas_uic_ipsframe'),'position');
   frame_offsx=pos(1);
   frame_dx=pos(3);
   gr_offsy=fig_dy-20-(pos(2)+pos(4));
   frame_dx=(fig_dx-50)/2;
   set(findobj(myfig, 'tag','fdmeas_uic_ipsframe'),'position',[pos(1) pos(2)+gr_offsy frame_dx pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_exftext'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_exftext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_varrb(1)'),'position');
   %set(findobj(myfig, 'tag','fdmeas_uic_varrb(1)'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_dbintext'),'position');
   %dbin_dx=pos(3);
   %dbin_offsx=frame_offsx+frame_dx-5-dbin_dx;
   %set(findobj(myfig, 'tag','fdmeas_uic_dbintext'),'position',[dbin_offsx pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_inedit'),'position');
   %inedit_dx=pos(3);
   %inedit_offsx=dbin_offsx-5-inedit_dx;
   %set(findobj(myfig, 'tag','fdmeas_uic_inedit'),'position',[inedit_offsx pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_intext'),'position');
   %intext_dx=pos(3);
   %intext_offsx=inedit_offsx-5-intext_dx;
   %set(findobj(myfig, 'tag','fdmeas_uic_intext'),'position',[intext_offsx pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_dbouttext'),'position');
   %set(findobj(myfig, 'tag','fdmeas_uic_dbouttext'),'position',[dbin_offsx pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_outedit'),'position');
   %set(findobj(myfig, 'tag','fdmeas_uic_outedit'),'position',[inedit_offsx pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_outtext'),'position');
   %set(findobj(myfig, 'tag','fdmeas_uic_outtext'),'position',[intext_offsx pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_alltext'),'position');
   %set(findobj(myfig, 'tag','fdmeas_uic_alltext'),'position',[inedit_offsx-inedit_dx pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_muledit'),'position');
   %set(findobj(myfig, 'tag','fdmeas_uic_muledit'),'position',[inedit_offsx pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_multext'),'position');
   %set(findobj(myfig, 'tag','fdmeas_uic_multext'),'position',[inedit_offsx-inedit_dx-5 pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_varrb(2)'),'position');
   %set(findobj(myfig, 'tag','fdmeas_uic_varrb(2)'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_varrb(3)'),'position');
   %set(findobj(myfig, 'tag','fdmeas_uic_varrb(3)'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
   %pos=get(findobj(myfig, 'tag','fdmeas_uic_varrb(4)'),'position')
   %set(findobj(myfig, 'tag','fdmeas_uic_varrb(4)'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]); 
   pos=get(findobj(myfig, 'tag','fdmeas_uic_viframe'),'position');
   %gr_offsx=fig_dx-20-frame_dx-pos(1);
   gr_offsx=0; %???  
   set(findobj(myfig, 'tag','fdmeas_uic_viframe'),'position',[pos(1)+gr_offsx pos(2)+gr_offsy frame_dx pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_vihdtext'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_vihdtext'),'position',[pos(1)+gr_offsx pos(2)+gr_offsy pos(3) pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_vipop'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_vipop'),'position',[pos(1)+gr_offsx pos(2)+gr_offsy pos(3) pos(4)]);
   
   pos=get(findobj(myfig, 'tag','fdmeas_uic_netext'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_netext'),'position',[pos(1) pos(2) pos(3) pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_needit'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_needit'),'position',[pos(1) pos(2) pos(3) pos(4)]);
   
   pos=get(findobj(myfig, 'tag','fdmeas_uic_retext'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_retext'),'position',[pos(1) pos(2) pos(3) pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_reedit'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_reedit'),'position',[pos(1) pos(2) pos(3) pos(4)]);
   
   pos=get(findobj(myfig, 'tag','fdmeas_uic_statusframe'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_statusframe'),'position',[pos(1) pos(2) fig_dx pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_statustext'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_statustext'),'position',[pos(1) pos(2) fig_dx-6 pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_donepb'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_donepb'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_cancelpb'),'position');
   cancelpb_offsx=fig_dx-pos(3)-20;
   set(findobj(myfig, 'tag','fdmeas_uic_cancelpb'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_fdtakepb'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_fdtakepb'),'position',[cancelpb_offsx pos(2) pos(3) pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_gotovipb'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_gotovipb'),'position',[cancelpb_offsx pos(2) pos(3) pos(4)]);
   pos=get(findobj(myfig, 'tag','fdmeas_uic_ptpop'),'position');
   set(findobj(myfig, 'tag','fdmeas_uic_ptpop'),'position',[pos(1) pos(2) pos(3) pos(4)]);
   %'fdmeas_uic_excsigtext(1)' ???
   %'fdmeas_uic_excsigtext(2)' ???
   %'fdmeas_uic_excsigtext(3)' ???
   
else 
   if guiinfos('isdevelopment')
      warning(['Error: fdmeas.m called with incorrect command:' p1]) 
   end
end


function VIname=whichvi(myfig,mode)
%Determine which VI is selected
VIname='';
h=findobj(myfig,'tag','fdmeas_uic_vipop');
v=get(h,'value'); s=get(h,'string');
VIname=s{v};
if ~isempty(VIname)&strcmp(mode,'hw')
  hw=findobj(myfig,'tag','fdmeas_uic_hwpop');
  hwv=get(hw,'value'); hws=get(hw,'string');
  hwstr=hws{hwv};
  VIname=[hwstr,'/',VIname];
end

function check_generated_data(outdata)  
%Check if generated data are consistent with requirements
%If not, a warning is generated in the Measurement window.
Me = 'fdmeasurement_main';
myfig=findall(0,'tag',Me);
caller_info=guidtard(Me, 'DATA_CALLER_INFO');
mode=caller_info.ID; %TIME or FREQ
c=allchild(myfig);
No_exp=str2num(get(findobj(c,'flat','tag','fdmeas_uic_needit'),'string'));
No_rep=str2num(get(findobj(c,'flat','tag','fdmeas_uic_reedit'),'string')); %
expo=outdata.expn;
%
excsig=guidtard('fdtool_main', 'OUTPUT_excitation');
if isa(excsig,'tiddata')
  freqv=excsig.frequencies;
else
  freqv=[];
end
%
stmsg='';
if outdata.chn~=2
   stmsg=sprintf('Channels: %.0f, instead of 2',outdata.chn);
end
if strcmp(mode,'TIME')
  if ~isa(outdata,'tiddata')
    stmsg='result is not time domain data';
  end
  if isa(excsig,'tiddata')
    Ne=excsig.samplen;
    N=outdata.samplen;
    if ~isequal(No_rep*Ne,N)
      if isempty(stmsg)
        stmsg=sprintf('samples: %.0f, required: %.0f x %.0f',N,No_rep,Ne);
      end
      if ~isempty(freqv)&~isequal(freqv,outdata.frequencies)
        if isempty(stmsg)
          stmsg='excitation and response frequencies differ';
        end
      end
    end
  end
else %FREQ
   if ~isa(outdata,'fiddata')
      stmsg='result is not frequency domain data';
   end
   freqp=outdata.freqpoints;  
   if ~isempty(freqv)&~isequal(freqv,freqp)
      if isempty(stmsg)
         stmsg='excitation and response frequencies differ';
      end
   end
end
if expo~=No_exp
   if isempty(stmsg)
      stmsg=sprintf('experiments: %.0f, required: %.0f',expo,No_exp);
   end
end
%
if ~isempty(stmsg)
   fdmeasw('status',['Warning: ',stmsg])
end


%End of fdmeasw
