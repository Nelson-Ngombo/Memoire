function ulevctrl(tWin)
%ULEVCTRL sets the controls according to userlevel

%       Last modified: 15-Mar-2005

level=lower(guiinfos('userlevel'));
signaltypeall=strcmpi(guiinfos('signaltype'),'all');
automatic=strcmp(level, 'automatic');
interactive=strcmp(level, 'interactive');
advanced=strcmp(level, 'advanced');
modeltype=guiinfos('modeltype');
linear=strcmp(modeltype,'Linear');
nonlinerrors=strcmp(modeltype,'Nonlinear errors');
if signaltypeall&nonlinerrors
  fdtool modeltype linear
  fdtool('status', ['Model type set to Linear.']);
  modeltype=guiinfos('modeltype');
  linear=strcmp(modeltype,'Linear');
  nonlinerrors=strcmp(modeltype,'Nonlinear errors');
end

if nargin==0
   if signaltypeall&automatic
     boxmgr('excitmode', 'fdtool_main', 'off') % essd disabled
     arrowstr=guidtard('fdtool_main', 'ARRMGR');
     arrowstr=['---',arrowstr(4),'-',arrowstr(6:end)];
     guidtawr('fdtool_main', 'ARRMGR','direct',arrowstr);
     boxmgr('freqmode', 'fdtool_main', 'off')
   elseif automatic|(~guiinfos('ismeasurement')&~advanced)
     boxmgr('excitmode', 'fdtool_main', 'on')
     boxmgr('freqmode', 'fdtool_main', 'on')
     %minimal excitmode for userlevel automatic:
     arrowstr=guidtard('fdtool_main', 'ARRMGR');
     arrowstr=[arrowstr(1),'--',arrowstr(4:end)];
     guidtawr('fdtool_main', 'ARRMGR','direct',arrowstr);
   else
     boxmgr('excitmode', 'fdtool_main', 'on') %show excit window
     boxmgr('freqmode', 'fdtool_main', 'on')
     arrowstr=guidtard('fdtool_main', 'ARRMGR');
     arrowstr=[arrowstr(1),arrowstr(1),arrowstr(1),arrowstr(4:end)];
     guidtawr('fdtool_main', 'ARRMGR','direct',arrowstr);
   end
   boxmgr('updatecolors','fdtool_main')
   wintags=guiinfos('allchild', 'fdtool_main');
   for ix=1:length(wintags)
      ulevctrl(wintags{ix})
   end
   ulevctrl('fdtool_main')
else %nargin>0
   hWin=findall(0, 'tag', tWin);
   if isempty(hWin)
      return
   end
   switch tWin
   case 'fdtool_main'
     havtext=findobj(hWin,'tag','text_average');
     if linear
       %set(havtext,'erase','normal')
       if 0 & signaltypeall
         set(havtext(3),'string','Select')
         set(havtext(2),'string','Frequency')
         set(havtext(1),'string','Points')
       else
         set(havtext(3),'string','Variances')
         set(havtext(2),'string','and')
         set(havtext(1),'string','Averaging')
       end
       %set(havtext,'erase','none')
     else
       %set(havtext,'erase','normal')
       havtext=findobj(hWin,'tag','text_average');
       set(havtext(3),'string','Variances')
       set(havtext(2),'string','Nonlin. Anal.')
       set(havtext(1),'string','Averaging')
       %set(havtext,'erase','none')
     end
   case 'excitation_main'
     Me = 'excitation_main'; myfig=findall(0,'tag',Me);
     essd('setgenpop');
     %odd linear, import, Matlab, DFT, almost DFT, odd quasilog:
     hadvancedfreq=[findobj(hWin,'tag','essd_uic_fgrb(4)');...
         findobj(hWin,'tag','essd_uic_fgrb(5)');...
         findobj(hWin,'tag','essd_uic_fgrb(7)');...
         findobj(hWin,'tag','essd_uic_fgrb(8)')]; 
     hadvanced=[findobj(hWin,'tag','essd_uic_agrb(2)');...
         findobj(hWin,'tag','essd_uic_agrb(3)');...
         findobj(hWin,'tag','essd_uic_agrb(4)');...
         findobj(hWin,'tag','essd_uic_agrb(5)');...
         findobj(hWin,'tag','essd_uic_agrb(6)');...
         findobj(hWin,'tag','essd_uic_agrb(7)');...
         findobj(hWin,'tag','essd_uic_adjustpbn');...
         findobj(hWin,'tag','essd_uic_reptext');...
         findobj(hWin,'tag','essd_uic_exptext')...
       ];
     hms=findobj(hWin,'tag','essd_uic_stsgrb(1)'); %Multisine
     hmlbs=findobj(hWin,'tag','essd_uic_stsgrb(3)'); %MLBS
     hdibs=findobj(hWin,'tag','essd_uic_stsgrb(2)'); %DIBS
     hdits=findobj(hWin,'tag','essd_uic_stsgrb(4)'); %DITS
     hsingle=findobj(hWin,'tag','essd_uic_stsgrb(4)_singleexp'); %single-experiment
     hmulti=findobj(hWin,'tag','essd_uic_stsgrb(3)_multiexp'); %multi-experiment
     hinit=findobj(hWin,'tag','essd_uic_startpop'); %Initial phases
     hinittext=findobj(hWin,'tag','essd_uic_starttext'); %Text of initial phases
     hstate=findobj(hWin,'tag','essd_uic_stateedit'); %Initial state of rnd gen
     hstatetext=findobj(hWin,'tag','essd_uic_statetext'); %Text of initial state of rnd gen
     hiter=findobj(hWin,'tag','essd_uic_iteredit'); %Number of iterations
     hitertext=findobj(hWin,'tag','essd_uic_itertext'); %Text of number of iterations
     hgen=findobj(hWin,'tag','essd_uic_genpop'); %Generator
     hgentxt=findobj(hWin,'tag','essd_uic_gentypetext'); %Generator text
     hrecfilt=[findobj(hWin,'tag','essd_uic_recfiltrb(1)');...
         findobj(hWin,'tag','essd_uic_recfiltrb(2)');...
         findobj(hWin,'tag','essd_uic_recfilttext')];
     hlin=findobj(hWin,'tag','essd_uic_fgrb(1)'); %Linear frequency grid
     hconst=findobj(hWin,'tag','essd_uic_agrb(1)'); %Constant aplitudes
     hview=findobj(hWin,'tag','essd_uic_viewpb'); 
     hAeffedit=findobj(hWin,'tag','essd_uic_agedit(21)'); %Aeff edit box
     haeff=[findobj(hWin,'tag','essd_uic_agtext(20)');hAeffedit]; %Aeff handles
     hrep=findobj(hWin,'tag','essd_uic_repedit'); %Repetitions
     hexp=findobj(hWin,'tag','essd_uic_expedit'); %Experiments
     hsel=[hconst;hrep;hexp];
     hrandlin=findall(hWin, 'tag', 'essd_uic_fgrb(6)');
     hoddntlin=hrandlin;
     hrandlog=findall(hWin, 'tag', 'essd_uic_fgrb(3)');
     hoddqlog=hrandlog;
     hoddlin=findobj(hWin,'tag','essd_uic_fgrb(2)');
     hrand=[hrandlin;hrandlog];
     hqlog=findall(hWin,'tag','essd_uic_fgrb(9)');
     %
     if linear
       set([hdibs;hdits;hmlbs],'visible','on')
       set([hsingle;hmulti],'visible','off')
       set([hlin;hoddlin],'enable','on')
       if ~isequal(get(hmlbs,'value'),1)
         set([hoddqlog;hqlog],'enable','on')
       end
       %if signaltypeall
       %  set(hms,'enable','off')
       %else
       if automatic
         try, set(hgen,'value',strmatch('DAC',get(hgen,'string')));
         catch, set(hgen,'Value',1)
         end
         essd('essd_uic_recfiltrb(2)');
         set([hgen;hgentxt;hrecfilt],'enable','off')
         if ~isequal(get(hms,'value'),1), essd('essd_uic_stsgrb(1)'), end %Multisine
         set([hms;hinit;hinittext],'enable','off')
         set(hinit,'value',1)
         set(hiter,'string',200)
         set([hstate;hstatetext],'visible','off')
         set([hiter;hitertext],'visible','on','enable','off')
         v4=get([hlin;hqlog],'value');
         if all(cat(1,v4{:})==0), essd(get(hlin,'tag')), end %Linear
         set([hadvancedfreq;hoddntlin],'enable','off')
         set([hoddlin;hoddqlog],'enable','off')
         %
         set(hrep,'string','1') %No extra repetition
         set(hexp,'string','1') %One experiment
       else %interactive, advanced
         %if interactive
         %  try, set(hgen,'value',strmatch('DAC',get(hgen,'string')));
         %  catch, set(hgen,'Value',1)
         %   end
         %  essd('essd_uic_recfiltrb(2)');
         %  set([hgen;hgentxt;hrecfilt],'enable','off')
         %elseif advanced
         set([hgen;hgentxt;hrecfilt],'enable','on')
         %end
         if ~isequal(get(hmlbs,'value'),1)
           set(hqlog,'enable','on')
           set([hadvancedfreq;hoddlin;hoddntlin],'enable','on') %+inv repeat
           %if 0 
             %set([hstart,hstartt],'enable','on')
             %set([findobj(c, 'flat', 'tag','essd_uic_itertext');
             %  findobj(c, 'flat', 'tag','essd_uic_iteredit')],'enable','on');
           %end
           set([hms;hinit;hinittext],'enable','on')
           %set([hstate;hstatetext],'visible','off')
           set([hiter;hitertext],'visible','on','enable','on')
           iterstr=get(hiter,'userdata');
           if ~isempty(iterstr)
             set(hiter,'string',iterstr)
             set(hiter,'userdata','');
           end
         end
       end
       %set(hrandlin,'enable','off')
       randv=get(hrand,'Value');
       for ii=1:length(randv)
         if (randv{ii}==1)&strcmp(get(hrand(ii),'enable'),'off')
           essd('essd_uic_fgrb(1)')
         end
       end
     else %nonlinear
       if ~isequal(get(hms,'value'),1), essd('essd_uic_stsgrb(1)'), end %Multisine
       set([hdibs;hdits;hmlbs],'visible','off')
       linoddlin=[hlin;hoddlin];
       if automatic
         try, set(hgen,'value',strmatch('DAC',get(hgen,'string')));
         catch, set(hgen,'Value',1)
         end
         essd('essd_uic_recfiltrb(2)');
         set([hgen;hgentxt;hrecfilt],'enable','off')
         set([hadvancedfreq;linoddlin;hoddntlin],'enable','off')
         if strncmpi(guiinfos('modeltype'),'Nonlinear errors',4)
           if get(findobj(myfig, 'tag', 'essd_uic_stsgrb(4)_singleexp'),'value')
             set(findobj(myfig, 'tag','essd_uic_repedit'),'String','6')
             set(findobj(myfig, 'tag','essd_uic_expedit'),'String','1')     
           elseif get(findobj(myfig, 'tag', 'essd_uic_stsgrb(3)_multiexp'),'value')
             set(findobj(myfig, 'tag','essd_uic_repedit'),'String','2')
             set(findobj(myfig, 'tag','essd_uic_expedit'),'String','6')
           end
         end
       else %interactive, advanced
         if interactive
           try, set(hgen,'value',strmatch('DAC',get(hgen,'string')));
           catch, set(hgen,'Value',1)
           end
           essd('essd_uic_recfiltrb(2)');
           set([hgen;hgentxt;hrecfilt],'enable','off')
         elseif advanced
           set([hgen;hgentxt;hrecfilt],'enable','on')
         end
         set([hadvancedfreq;linoddlin;hoddntlin],'enable','on')
         set([hms;hinit;hinittext],'enable','on')
       end
       set([hsingle;hmulti],'visible','on')
       set(hinit,'Value',1) %Random
       iterations=str2num(get(hiter,'string'));
       if ~isequal(iterations,0)
         set(hiter,'userdata',get(hiter,'string'))
         set(hiter,'string','0')
       end
       %set([hiter;hitertext],'visible','off')
       set([hiter;hitertext],'enable','off')
       essd('essd_uic_startpop')
       set([hms;hinit;hinittext],'enable','off')
       if get(hsingle,'value')==1 %Single experiment for nonlinear: randomized grids
         set(hadvancedfreq,'enable','off')
         set(hrand,'enable','on')
         set(linoddlin,'enable','off')
         if (get(hrandlin,'value')==0)&(get(hrandlog,'value')==0)
           hlog=findobj(hWin,'tag','essd_uic_fgrb(9)');
           if get(hlog,'value')==1
             essd(get(hrandlog,'tag'))
           else
             essd(get(hrandlin,'tag'))
           end
         end
         %Odd linear, quasilog
         set([findobj(hWin,'tag','essd_uic_fgrb(2)');findobj(hWin,'tag','essd_uic_fgrb(9)')],'enable','off')
       else %Multiexperiment
         set(hlin,'enable','on') %linear
         %Odd linear, quasilog
         set([hoddlin;hqlog;hoddqlog],'enable','on')
         v4=get([hlin;hoddlin;hqlog;hoddqlog],'value');
         if all(cat(1,v4{:})==0), essd(get(hlin,'tag')), end
       end  
     end %linear/nonlinear
     
     if strcmp(get(hmulti,'visible'),'off')|...
         (strcmp(get(hmulti,'visible'),'on')&(get(hmulti,'value')==1))
       set(hrandlin,'String','Odd, no third harmonics',...
         'tooltipstring','Every even and third harmonics suppressed')
       set(hrandlog,'string','Odd quasilog',...
         'ToolTipString','Approximate logarithmic set from odd DFT grid')
         %'tag','essd_uic_fgrb(6)',...
         %'tag','essd_uic_fgrb(3)',...
     else
       set(hrandlin,'String','Randomized odd linear',...
         'ToolTipString',...
         'Randomized odd grid from DFT lines (about 1/3 of lines randomly dropped)')
       set(hrandlog,'string','Randomized odd quasilog',...
         'ToolTipString','Approximate logarithmic set from odd DFT grid, maybe randomly dropped lines')
         %'tag','essd_uic_fgrb(6)_randomized',...
         %'tag','essd_uic_fgrb(3)_randomized',...
     end
     %
     if automatic
       set([hdibs;hdits;hmlbs],'enable','off')
       %
       set(hgen,'value',1) %DAC
       essd('essd_uic_genpop')
       set(hconst,'value',1) %Constant amplitudes
       essd('essd_uic_agrb(1)')
       set([hsel;hms;hadvanced;hmlbs;hdibs;hdits],'enable','off')
       set(hview,'enable','off')
       set(hAeffedit,'string',0.7)
       set(haeff,'enable','off')
     else %Interactive or Advanced
       set([hdibs;hdits;hmlbs],'enable','on')
       %
       if ~get(hmlbs,'value'), set([hsel;hadvanced],'enable','on'), end
       if linear, set([hms,hlin],'enable','on'), end
       set(hview,'enable','on')
       set(haeff,'enable','on')
       essd('essd_freqsel_execute');
     end
     
   case 'gettime_main'
     hmod=[findobj(hWin,'tag','gettime_auto_convert');...
         findobj(hWin, 'tag', 'gettime_check_memory')];
     if automatic
       set(hmod,'visible','off')
       gettime('zohcomp','off')
     elseif interactive
       set(hmod,'visible','on')
       gettime('zohcomp','off')
     elseif advanced
       set(hmod,'visible','on')
       gettime('zohcomp','on')
     end
     
     inputdata=guidtard('gettime_main','DATA_gotdata');
     if ~isempty(inputdata), expno=get(inputdata,'expnumber'); 
     else expno=[]; 
     end
     if signaltypeall|automatic|get(hmod(1),'Value')|any(expno>1)|...
         (isempty(expno)&~linear)
       gettime('setblocks','auto')
     else
       gettime('setblocks','segm')
     end
     %
     %h=findobj(hWin, 'tag', 'gettime_check_memory');
     %is_save=strcmp(get(h,'visible'),'on')&get(h,'value');
     %set(h,'value',1)
     %gettime('check&clear_memory','gettdata')
     %set(h,'value',is_save)
      if strcmpi(guiinfos('signaltype'),'all')&strcmpi(guiinfos('userlevel'),'basic')
        gettime('setbox','rect_convert',guicolor('BOX_COLOR_UNSELECTABLE'));
      end

     case {'gettdatafig', 'getfreq_main'}
      switch tWin
      case 'gettdatafig'
         h(2)=findobj(allchild(hWin), 'flat','Tag','gettdata_measurement');
         h(1)=findobj(allchild(hWin), 'flat', 'Tag','gettdata_simulation');
      case 'getfreq_main'
         h(2)=findobj(allchild(hWin), 'flat', 'Tag','gfdd_uic_measurepb');
         h(1)=findobj(allchild(hWin), 'flat', 'Tag','gfdd_uic_simulatepb');
      end
      if guiinfos('ismeasurement')
         set(h(1), 'visible', 'on')
         if automatic
            set(h(1), 'enable', 'off')
            set(h(2), 'enable', 'off')
         elseif interactive
            set(h(1), 'enable', 'on')
            set(h(2), 'enable', 'on')
         else
            set(h, 'enable', 'on')
         end
      else
         set(h(2), 'visible', 'off') %measurement
         if automatic|signaltypeall
            set(h, 'enable', 'off')
         elseif interactive
            set(h, 'enable', 'off')
         else % advanced
            set(h, 'enable', 'on')
         end
      end
      
   case 'average_main'
     %not touched in automatic level
     agv('setplottype')
     agv('suggest')     
     agv('update_plot')
     powerpb=findobj(hWin,'Tag','agv_uic_avrb(4)');
     if get(powerpb,'value'), agv('agv_uic_avrb(1)'), end
     inp=guidtard('fdtool_main', ['INPUT_average']);
     inpval=guidtard('fdtool_main', ['OUTPUT_', inp.from]);
     if advanced %&(inpval.expnumber>1)
       set(powerpb,'enable','on')
       if isequal(get(powerpb,'value'),1)
         set([findobj(hWin,'tag','agv_uic_windowpop'),...
           findobj(hWin,'tag','agv_uic_windowtext')],'enable','on')
       else
         set([findobj(hWin,'tag','agv_uic_windowpop'),...
           findobj(hWin,'tag','agv_uic_windowtext')],'enable','off')
       end
     else
       set(powerpb,'enable','off')
       set([findobj(hWin,'tag','agv_uic_windowpop'),...
         findobj(hWin,'tag','agv_uic_windowtext')],'enable','off')
     end
     
   case {'fdtool_importfig', 'fdtool_exportfig'}
      % nothing to do here
      
   case {'select_main', 'aided_main'}
      ch=allchild(hWin);
      h(1)=findobj(ch, 'flat', 'Tag','sme_uic_improvedcb');
      h(2)=findobj(ch, 'flat', 'Tag','sme_uic_slowertext');
      h(3)=findobj(ch, 'flat', 'Tag','sme_uic_transientcb');
      h(4)=findobj(ch, 'flat', 'Tag','sme_uic_complexcb');
      h(5)=findall(ch, 'flat', 'tag', 'sme_uic_delaytext');
      h(6)=findall(ch, 'flat', 'tag', 'sme_uic_delpop');
      h(7)=findall(ch, 'flat', 'tag', 'sme_uic_raztext');
      h(8)=findall(ch, 'flat', 'tag', 'sme_uic_razpop');
      h(9)=findall(ch, 'flat', 'tag', 'sme_uic_deledit');
      h(10)=findall(ch, 'flat', 'tag', 'sme_uic_raztext2');
      h(11)=findall(ch, 'flat', 'tag', 'sme_uic_sectext');
      h(12)=findall(ch, 'flat', 'tag', 'sme_uic_valuetext');
      h(13)=findall(ch, 'flat', 'tag', 'sme_uic_trordtext');
      h(14)=findall(ch, 'flat', 'tag', 'sme_uic_trordedit');
      h(15)=findall(ch, 'flat', 'tag', 'sme_uic_ordnumtext');
      h(16)=findall(ch, 'flat', 'tag', 'sme_uic_onedit');
      h(17)=findall(ch, 'flat', 'tag', 'sme_uic_orddentext');
      h(18)=findall(ch, 'flat', 'tag', 'sme_uic_odedit');
      h(19)=findall(ch, 'flat', 'tag', 'sme_uic_autoorderpb');
      h(20)=findall(ch, 'flat', 'tag', 'sme_uic_razedit');
      
      h_dompop=findobj(ch, 'flat', 'Tag','sme_uic_dompop');
      if automatic
         set(h([1:15,17,20:end]), 'enable', 'off')
         set(h(19), 'enable', 'on')
         set(h([1,2,4]),'value',0)
         if get(h_dompop,'value')>2
           set(h_dompop,'value',1)
           sme('sme_uic_dompop');
         end 
         set(h_dompop,'String',{'s','z'})
         if strcmp(popupstr(h_dompop),'z')
           set(findobj(ch, 'tag', 'sme_uic_autoorderpb'),'enable','off')
           %sme('status','Warning: Automatic order setting is not available for z-domain')
         elseif strcmp(popupstr(h_dompop),'s')
           set(findobj(ch, 'tag', 'sme_uic_autoorderpb'),'enable','on')
           if strcmp(tWin,'select_main')
             sme('sme_uic_autoorderpb','sme_uic_autoorderpb');  
           else
             sme('sme_uic_autoorderpb','sme_uic_autoorderpb','autoscan');  
           end
         end
         set(h(6),'value',1) %sme_uic_delpop
         sme('sme_uic_delpop')
         set(h(8),'value',1) %sme_uic_razpop
         sme('sme_uic_razpop')
         set(h(3),'value',0) %sme_uic_transientcb
         set(h(4),'value',0) %sme_uic_complexcb
         set(h(9),'string','0') %sme_uic_deledit
         set(h(14),'string','maxord-1') %sme_uic_trordedit
      else %not automatic
         set(h_dompop,'String',{'s', 'z', 'w','r'})
         set(h(3:19), 'enable', 'on')
         if strcmp(popupstr(h_dompop),'s')
            set(h(1:2), 'enable', 'on')
            set(findobj(ch, 'tag', 'sme_uic_autoorderpb'),'enable','on')
            if get(h(3),'value')==0, set(h(13:14),'enable','off'), end
         elseif strcmp(popupstr(h_dompop),'z')
            set(h(1:2), 'enable', 'on')
            set(h(13:14), 'enable', 'off')
            set(findobj(ch, 'tag', 'sme_uic_autoorderpb'),'enable','off')
         else %w,r
            set(h(1:2), 'enable', 'off')
            if strcmp(popupstr(h_dompop),'r') %w not!
              set(h(13:14), 'enable', 'off')
            end
            set(findobj(ch, 'tag', 'sme_uic_autoorderpb'),'enable','off')
         end
      end
      %
      hrm=findall(hWin,'type','uimenu','tag','sme_MENU_runmod');
      hrmadvonly=[findall(hWin,'type','uimenu','tag','sme_menu_runmod_iobj');...
          findall(hWin,'type','uimenu','tag','sme_menu_runmod_iobj_setweight')];
      %findall(hWin,'type','uimenu','tag','sme_menu_runmod_stab');...
      %findall(hWin,'type','uimenu','tag','sme_menu_runmod_fmph');...
      %findall(hWin,'type','uimenu','tag','sme_menu_runmod_itno');...
      hIterpb=findall(hWin,'tag','sme_uic_elisparampb');
      hH=findall(hWin,'label','&Help');
      hrmh=findall(hWin,'tag','select_menu_help_runmod');
      if advanced
        if ishandle(hrm)
          set([hrm, hIterpb],'visible','on')
        end
        if ishandle(hrmadvonly)
          set(hrmadvonly,'visible','on')
        end
        set(hrmh,'visible','on')
      elseif interactive
        if ishandle(hrm)
          if ~(strncmpi(computer,'MAC',3)&strncmp(version,'5.2',3))
            %on a Mac with 5.2, this confuses the whole menu...
            set([hrm; hIterpb],'visible','on')
            set(hrmadvonly,'visible','off')
          else %MAC, 5.2
            set([hrm; hIterpb; hrmadvonly],'visible','on')
          end
        end
        set(hrmh,'visible','on')
      elseif automatic
        if ishandle(hrm)
          set([hrm; hIterpb;hrmadvonly],'visible','off');
        end
        set(hrmh,'visible','off')
      end
      if linear&~automatic
        set(h(3),'enable','on')
      elseif ~linear
        set(h(3),'value',0)
        set(h(3),'enable','off')
      end
      if strncmp(get(gcbo,'tag'),'fdtool_menu_modeltype_',22)
        sme('sme_uic_transientcb') %only to eliminate estimated model
      end
      sme('update_plot')
      
   case 'compare_main'
      h=findobj(allchild(hWin), 'flat', 'Tag','caem_uic_typepop');
      ix=get(h, 'value');
      strcautomatic1={'TF Magnitudes + Errors',...
            'TF Magnitudes + Errors + Bounds',...
            'TF Magnitudes',...
            'TF Magnitudes + TF std''s',...
            'TF Magnitudes, Linear Scale',...
            'TF Phases',...
            'TF Phases Wrapped',...
            'Poles/Zeros + Bounds',...
            'Poles/Zeros'};
      strcautomatic2={'Cloud of Models',...
            'Cloud of Models with Data'};
      strcautomatic3={'Impulse response',...
            'Step response',...
            'Nyquist diagram'};
      if   exist('@zpk/zpk.m')
         strcautomatic=[strcautomatic1, strcautomatic3, strcautomatic2];
      else
         strcautomatic=[strcautomatic1, strcautomatic2];
      end
      if automatic
        set(h, 'String',strcautomatic)
         if ix>2
            set(h, 'value', 1)
            caem('update_plot2')
            caem('update_plot3')
         end
      else
        set(h, 'String',[strcautomatic,...
            {'Cost Function vs. Delay', 'Residuals', 'Correlation Test'}])
        caem('update_plot2')
        caem('update_plot3')
      end
 
   case 'fdsimulation_main'
      if automatic
         guiclose( 'fdsimulation')
      end
      
   case 'fdmeasurement_main'
      if automatic
         guiclose('fdmeasurement')         
      end
      
   case {'freqselfig', 'freqsel3fig'} %gtdd, gfdd
     h=findobj(allchild(hWin), 'flat', 'Tag','freqsel_uic_excpop');
     if ~isempty(h)
       inp=guidtard('gettime_main', 'DATA_converteddata');
       if linear
         set(h,'visible','off')
       else
         set(h,'visible','on')
       end
     end
     
   case {'freqsel2fig'}
      % nothing to do
      h=findobj(allchild(hWin), 'flat', 'Tag','freqsel_uic_excpop');
      if ~isempty(h)
        set(h,'visible','off')
      end
      
   case {'fdident_gui_demos'}
      % nothing to do

   case {'fdtool_compinput_time_main'}
      % nothing to do

   case {'fdtool_compinput_time2_main'}
      % nothing to do

   case {'fdtool_compinput_freq_main'}
      % nothing to do

   otherwise
      disp(['Userlevel control not implemented for window ''' tWin ''''])
      % !!!!!! test only !!! 
   end
   fixpopups(hWin)

end
