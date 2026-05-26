function gettime(p1,p2,p3,p4,p5,seltype);
% get time domain data main window
% helper file of FDTool

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 13-May-2002, IK

% The data stored in the figure's uprops:
% DATA_gotdata
% DATA_segmenteddata
% DATA_converteddata
% DATA_selecteddata


mainfig=findall(0, 'tag','fdtool_main');
Me='gettime_main';
myfcn='gettime';
myname='gettime';


if nargin >0 & ~strcmp(p1, 'init')
  myfig=findall(0, 'tag',Me);
  %   if isempty(myfig), disp(['Warning: ' myname ' window missing.']), return, end
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

if nargin == 0 | strcmp(p1, 'init')

  text_font_size = 'default';

  % colors
  grey=[1 1 1]/sqrt(2);
  color_gettdata=grey;
  color_segment=grey;
  color_convert=grey;
  color_freqsel=grey;
  color_info='g';
  color_arrow='g';
  color_blockbg='default';
  color_infobg='default';
  color_figbg=[1 1 1]*.9;

  tmp=findall(0, 'tag','gettime_main');
  if ~isempty(tmp)
    % set(tmp,'visible','on');
    %figure(tmp);
    guiclose('gettime')
  end
  % object postitions and size

  figwid=515; fighei=250;

  boxwid=20;
  boxdist=32;
  boxdist1=33;

  x1=10; x2=x1+boxwid;
  x3=x1+boxdist; x4=x3+boxwid;
  x5=x3+boxdist; x6=x5+boxwid;
  x7=x5+boxdist; x8=x7+boxwid;
  x23=x2+(x3-x2)*.4;
  x45=x4+(x5-x4)*.4;

  y1=60; y2=40; y10=30; y3=50.1; y4=50.1; y5=20; y6=0;

  aspr=.75;
  arwid=3.5; arwid5=arwid*aspr;
  arlen=3; arlen5=arlen/aspr;
  arlinwid=1.5; arlinwid5=arlinwid*aspr;

  gettidef


  gettimefig = figure('Color',color_figbg, ...
    'units', 'pixels'   , ...
    'Position',[fig_offsx fig_offsy fig_dx fig_dy], ...
    'Tag','gettime_main',...
    'name','Read Time Domain Data',...
    'color', get(0,'defaultuicontrolbackgroundcolor'),...
    'numbertitle','off', ...
    'IntegerHandle', 'off',...
    'Handlevisibility', 'off',...
    'windowbuttonmotion', 'fdtool(''callback'',''gettime'',''mouse_motion'')',...
    'resize', 'on', ...
    'visible','off',...
    'resizefcn','fdtool(''callback'',''gettime'',''resize'',''resize'')',...
    'deletefcn', 'fdtool(''callback'',''gettime'',''destroyed'',''gettime_main'')');
  intoscr('gettime_main')   ;
  %      'closerequestfcn', 'fdtool(''callback'',''gettime'',''ui_cancel'',''gettime_button_cancel'')', ...

  fdwindef(gettimefig);  % set default window properties
  dfs=get(gettimefig,'defaultaxesfontsize');
  %ha=findobj(gettimefig,'type','axes');
  %set(ha,'defaulttextfontsize',dfs);
  %figure(getttimefig), clf
  %hc=findobj(gettimefig,'type','text');
  %set(hc,'fontsize',dfs)

  %      'deletefcn', 'fdtool(''callback'',''gettime'',''destroyed'',''gettime_main'')');
  myfig=gettimefig;
  axe1= axes('Parent',gettimefig, ...
    'color',color_blockbg,...
    'Units','pixels', ...
    'Position',[axes_offsx axes_offsy axes_dx axes_dy],...
    'xlim', [5 140], ...
    'ylim', [25 75], ...
    'tag', 'gettime_main_ax',...
    'Visible','off');
  %      'Position',[0.0 .53 .8 .5],...

  text_gettdata=[text((x1+x2)/2,y3, 'Get','vert','bottom','parent', axe1), ...
    text((x1+x2)/2,y4, 'Data','vert','top','parent', axe1)];

  text_segment=[text((x3+x4)/2,y3, 'Segmen','vert','bottom','parent', axe1), ...
    text((x3+x4)/2,y4, 'tation','vert','top','parent', axe1)];

  text_convert=[text((x5+x6)/2,y3, 'Conv. to','vert','bottom','parent', axe1), ...
    text((x5+x6)/2,y4, 'Freq','vert','top','parent', axe1)];

  text_freqsel=[text((x7+x8)/2,y3, 'Freq','vert','bottom','parent', axe1), ...
    text((x7+x8)/2,y4, 'Select','vert','top','parent', axe1)];

  set([text_gettdata,text_segment,text_convert,text_freqsel],...
    'horiz','cent', ...
    'fontsize',text_font_size,...
    'color',[0 0 0], ...
    'hittest', 'off');

  rect_gettdata=patch([x1,x2, x2, x1],...
    [y1, y1, y2, y2],color_gettdata,'parent', axe1,'FaceAlpha',0.5);
  rect_segment=patch([x3,x4, x4, x3],...
    [y1, y1, y2, y2],color_segment,'parent', axe1,'FaceAlpha',0.5);
  rect_convert=patch([x5,x6, x6, x5],...
    [y1, y1, y2, y2],color_convert,'parent', axe1,'FaceAlpha',0.5);
  rect_freqsel=patch([x7,x8, x8, x7],...
    [y1, y1, y2, y2],color_freqsel,'parent', axe1,'FaceAlpha',0.5);

  % arrows
  ay0=(y1+y2)/2; ay1=(y1+y2)/2+arlinwid; ay2=(y1+y2)/2-arlinwid;


  arrx=[x2 x3-arlen x3-arlen x3 x3-arlen x3-arlen x2];
  arry=[ay2 ay2 ay0-arwid ay0 ay0+arwid ay1 ay1];

  arr1=patch(arrx, arry, color_arrow,'parent', axe1);
  arr2=patch(arrx+x3-x1,arry,color_arrow,'parent', axe1);
  arr3=patch(arrx+x5-x1,arry,color_arrow,'parent', axe1);
  arr4=patch(arrx+x7-x1,arry,color_arrow,'parent', axe1);
  %autoconvert arrow
  arr12=patch(arrx+[0,ones(1,5),0]*(x3-x1), arry, color_arrow,'parent', axe1);

  %ax1=x23-arlinwid5; ax2=x23+arlinwid5;
  %ax3=x45-arlinwid5; ax4=x45+arlinwid5;
  %ay1=ay0-arlinwid; ay2=ay0+arlinwid;
  %ay3=y10+arlinwid; ay4=y10-arlinwid;
  %
  %   arr4=patch([ax1 ax1 ax2 ax2],...
  %      [ay1 ay4 ay3 ay1],...
  %      color_arrow,'parent', axe1);
  %
  %   arr5=patch([ax1 ax2 ax3 ax4],...
  %      [ay4 ay3 ay3 ay4],...
  %      color_arrow,'parent', axe1);
  %
  %   arr6=patch([ax4 ax4 x45+arwid5 ...
  %         x45 x45-arwid5 ax3 ax3],...
  %      [ay4 ay1-arlen5 ay1-arlen5 ...
  %         ay1  ay1-arlen5 ay1-arlen5 ay3],...
  %      color_arrow,'parent', axe1);


  fr_info=uicontrol('Parent',gettimefig, ...
    'style','frame',...
    'backgroundcolor',color_infobg,...
    'Units','pixels', ...
    'Position',[dataframe_offsx dataframe_offsy dataframe_dx dataframe_dy],...
    'tooltipstring', 'Info on loaded/measured data', ...
    'tag', 'fr_info');

  text_info11=uicontrol('Parent',gettimefig, ...
    'style','text',...
    'backgroundcolor',color_infobg,...
    'Units','pixels', ...
    'Position',[infotext1_offsx infotext1_offsy infotext1_dx infotext1_dy],...
    'tooltipstring', 'Info on loaded/measured data', ...
    'tag', 'text_info11',...
    'horizontal','left',...
    'string','Data not available yet.');

  text_info21=uicontrol('Parent',gettimefig, ...
    'style','text',...
    'backgroundcolor', color_infobg,...
    'Units','pixels', ...
    'Position',[infotext21_offsx infotext21_offsy infotext21_dx infotext21_dy],...
    'tooltipstring', 'Info on loaded/measured data', ...
    'tag', 'text_info21',...
    'horizontal','left',...
    'string','');

  text_info22=uicontrol('Parent',gettimefig, ...
    'style','text',...
    'backgroundcolor', color_infobg,...
    'Units','pixels', ...
    'Position',[infotext22_offsx infotext22_offsy infotext22_dx infotext22_dy],...
    'tooltipstring', 'Info on loaded/measured data', ...
    'tag', 'text_info22',...
    'horizontal','left',...
    'string','');

  text_info31=uicontrol('Parent',gettimefig, ...
    'style','text',...
    'backgroundcolor',  color_infobg,...
    'Units','pixels', ...
    'Position',[infotext31_offsx infotext31_offsy infotext31_dx infotext31_dy],...
    'tooltipstring', 'Info on loaded/measured data', ...
    'tag', 'text_info31',...
    'horizontal','left',...
    'string','');

  text_info32=uicontrol('Parent',gettimefig, ...
    'style','text',...
    'backgroundcolor',  color_infobg,...
    'Units','pixels', ...
    'Position',[infotext32_offsx infotext32_offsy infotext32_dx infotext32_dy],...
    'tooltipstring', 'Info on loaded/measured data', ...
    'tag', 'text_info32',...
    'horizontal','left',...
    'string','');

  text_info41=uicontrol('Parent',gettimefig, ...
    'style','text',...
    'backgroundcolor', color_infobg,...
    'Units','pixels', ...
    'Position',[infotext41_offsx infotext41_offsy infotext41_dx infotext41_dy],...
    'tooltipstring', 'Info on loaded/measured data', ...
    'tag', 'text_info41',...
    'horizontal','left',...
    'string','');

  text_info42=uicontrol('Parent',gettimefig, ...
    'style','text',...
    'backgroundcolor',  color_infobg,...
    'Units','pixels', ...
    'Position',[infotext42_offsx infotext42_offsy infotext42_dx infotext42_dy],...
    'tooltipstring', 'Info on loaded/measured data', ...
    'tag', 'text_info42',...
    'horizontal','left',...
    'string','');

  text_info51=uicontrol('Parent',gettimefig, ...
    'style','text',...
    'backgroundcolor', color_infobg,...
    'Units','pixels', ...
    'Position',[infotext51_offsx infotext51_offsy infotext51_dx infotext51_dy],...
    'tooltipstring', 'Info on loaded/measured data', ...
    'tag', 'text_info51',...
    'horizontal','left',...
    'string','');

  text_info52=uicontrol('Parent',gettimefig, ...
    'style','text',...
    'backgroundcolor', color_infobg,...
    'Units','pixels', ...
    'Position',[infotext52_offsx infotext52_offsy infotext52_dx infotext52_dy],...
    'tooltipstring', 'Info on loaded/measured data', ...
    'tag', 'text_info52',...
    'horizontal','left',...
    'string','');

  % set tags and callbacks for graphics objects
  set(rect_gettdata, ...
    'tag', 'rect_gettdata', ...
    'buttondown', 'fdtool(''callback'',''gettime'',''click_on_gettdata'',''rect_gettdata'')');

  set(rect_segment, ...
    'tag', 'rect_segment', ...
    'buttondown', 'fdtool(''callback'',''gettime'',''click_on_segment'',''rect_segment'')');

  set(rect_convert, ...
    'tag', 'rect_convert', ...
    'buttondown', 'fdtool(''callback'',''gettime'',''click_on_convert'',''rect_convert'')');

  set(rect_freqsel, ...
    'tag', 'rect_freqsel', ...
    'buttondown', 'fdtool(''callback'',''gettime'',''click_on_freqsel'',''rect_freqsel'')');

  set(text_gettdata, ...
    'tag', 'text_gettdata');

  set(text_segment, ...
    'tag', 'text_segment');

  set(text_convert, ...
    'tag', 'text_convert');

  set(text_freqsel, ...
    'tag', 'text_freqsel');


  set(arr1, ...
    'tag', 'arr1', ...
    'buttondown', 'fdtool(''callback'',''gettime'',''click_on_arr1'',''arr1'')');

  set(arr2, ...
    'tag', 'arr2', ...
    'buttondown', 'fdtool(''callback'',''gettime'',''click_on_arr2'',''arr2'')');

  set(arr12, ...
    'tag', 'arr12', ...
    'buttondown', 'fdtool(''callback'',''gettime'',''click_on_arr12'',''arr12'')');

  set(arr3, ...
    'tag', 'arr3', ...
    'buttondown', 'fdtool(''callback'',''gettime'',''click_on_arr3'',''arr3'')');

  set(arr4, ...
    'tag', 'arr4', ...
    'buttondown', 'fdtool(''callback'',''gettime'',''click_on_arr4'',''arr4'')');

  hmod=[findobj(myfig,'tag','gettime_auto_convert');...
    findobj(myfig, 'tag', 'gettime_check_memory')];
  if strcmpi(guiinfos('userlevel'),'Automatic')
    set([arr1,rect_segment,text_segment,arr2,hmod'],'visible','off')
  else
    set([arr12],'visible','off')
  end

  %   set(arr4, ...
  %      'tag', 'arr4', ...
  %      'buttondown', 'fdtool(''callback'',''gettime'',''click_on_arr5'',''arr5'')');
  %   set(arr5, ...
  %      'tag', 'arr5', ...
  %      'buttondown', 'fdtool(''callback'',''gettime'',''click_on_arr5'',''arr5'')');
  %   set(arr6, ...
  %      'tag', 'arr6', ...
  %      'buttondown', 'fdtool(''callback'',''gettime'',''click_on_arr5'',''arr5'')');




  set([text_info11, text_info21, text_info22,...
    text_info31, text_info32 ,text_info41, text_info42,...
    text_info51, text_info52],...
    'fontsize',text_font_size)

  frame_status=uicontrol('Parent',gettimefig, ...
    'style','frame',...
    'unit','pixels',...
    'position',[statusframe_offsx statusframe_offsy statusframe_dx statusframe_dy],...
    'tag', 'frame_status');
  % others
  status=uicontrol('Parent',gettimefig, ...
    'style','text',...
    'unit','pixels', ...
    'position',[statustext_offsx statustext_offsy statustext_dx statustext_dy], ...
    'horiz', 'left', ...
    'tag', 'status_gettime', ...
    'string', '');

  set(status,'fontsize',text_font_size);

  check_memory = uicontrol('Parent',gettimefig, ...
    'style', 'checkbox',...
    'Units','pixels', ...
    'Position',[memorycb_offsx memorycb_offsy memorycb_dx memorycb_dy], ...
    'String','Save memory', ...
    'tooltipstring','Spare memory by automatically clearing old data from the arrows',...
    'callback', 'fdtool(''callback'',''gettime'',''ui_memory'',''gettime_check_memory'')',...
    'enable','on',...
    'Tag','gettime_check_memory');

  auto_convert = uicontrol('Parent',gettimefig, ...
    'style', 'checkbox',...
    'Units','pixels', ...
    'Position',[autocb_offsx autocb_offsy autocb_dx autocb_dy], ...
    'String','Autoconvert', ...
    'tooltipstring','Perform automatic period length calculation, Fourier and variance analysis',...
    'callback', 'fdtool(''callback'',''gettime'',''ui_autoconvert'',''gettime_auto_convert'')',...
    'enable','on',...
    'Tag','gettime_auto_convert');

  ZOH_compensate = uicontrol('Parent',gettimefig, ...
    'style', 'checkbox',...
    'Units','pixels', ...
    'Position',[zohcb_offsx zohcb_offsy zohcb_dx zohcb_dy], ...
    'String','ZOH compensation', ...
    'tooltipstring','Compensate during conversion for effect of ZOH transfer function',...
    'callback', 'fdtool(''callback'',''gettime'',''ui_zohcomp'',''gettime_zoh_compensate'')',...
    'enable','on',...
    'visible','off',...
    'value',0,...
    'Tag','gettime_zoh_compensate');

  button_done = uicontrol('Parent',gettimefig, ...
    'Units','pixels', ...
    'Position',[donepb_offsx donepb_offsy donepb_dx donepb_dy], ...
    'String','Autofinish', ...
    'tooltipstring','Process data and close block without further questions',...
    'callback', 'fdtool(''callback'',''gettime'',''ui_done'',''gettime_button_done'')',...
    'enable','on',...
    'Tag','gettime_button_done');

  button_cancel = uicontrol('Parent',gettimefig, ...
    'Units','pixels', ...
    'Position',[cancelpb_offsx cancelpb_offsy cancelpb_dx cancelpb_dy], ...
    'String','Cancel', ...
    'Tooltipstring','Close window without saving data',...
    'callback', 'fdtool(''callback'',''gettime'',''ui_cancel'',''gettime_button_cancel'')',...
    'Tag','gettime_button_cancel');

  % set buttondown fcns for help
  helpmgr('init_help', '', myfcn, myfig );

  guimenus('gettime_main','gettime','gettime');
  boxmgr('init','gettime_main');

  if nargin >1
    storewin('restore_all', Me, p2) % bring up window with settings in p2
  else
    storewin('recover', Me); % restore previous settings if any
  end


  gettime('resize');

  intoscr({'gettime_main'});

  % The above function, intoscr positions the windows given by their labels
  % into the actual screen. This might come handy when the session has been saved
  % on a machine with different resolution than that of the present machine.

  ulevctrl('gettime_main')
  set(gettimefig,'visible','on');
  winmenu(gettimefig)
  gettime('status', 'Ready.')

  % end  of init


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %                 GET TIME DOMAIN WINDOW COMMANDS
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


else

  if strcmp(p1,'status')
    c=allchild(myfig);
    status=findobj(c, 'flat', 'tag','status_gettime');
    statusfr=findobj(c, 'flat', 'tag','frame_status');
    glstatus(myfig, status, statusfr, p2)

  elseif strcmp(p1, 'mouse_motion')
    guiready(myfig, 'gettime')

  elseif strcmp(p1,'click_on_gettdata')
    if boxmgr(p1,'gettime_main')
      gettime('status', 'Opening...', Me);
      gettdata
      gettime('status', 'Done. ', Me);
    end

  elseif strcmp(p1,'click_on_segment')| strcmp(p1, 'activate_segment')
    if boxmgr('click_on_segment','gettime_main')
      gettime('status', 'Opening...', Me);
      segmdata
      gettime('status', 'Done. ', Me);
    end

  elseif strcmp(p1,'click_on_convert') | strcmp(p1, 'activate_convert')
    if boxmgr('click_on_convert','gettime_main')
      guifreez(Me, 'freeze', 'gettime_convert_start');
      gettime('status', 'Opening...', Me);
      msg=''; try, msg=conv2frd; catch, disp(lasterr), end
      if isempty(msg), gettime('status', 'Done. ', Me); end
      guifreez(Me, 'unfreeze', 'gettime_convert_start');
    end

  elseif strcmp(p1,'click_on_freqsel')
    if boxmgr(p1,'gettime_main')
      gettime('status', 'Opening...', Me);
      init_var=[];
      % itt ki kell vadaszni az esetleges elozo szelekciokat
      % es az indexvektort at kell adni az init_var-ban
      freqsel('init', myfcn, 'GETTIME', init_var);
      gettime('status', 'Done. ', Me);
    end


  elseif strncmp(p1,'click_on_arr',12)
    arrnum=str2num(p1(13));
    arrowstatus=guidtard(Me, 'ARRMGR');
    if strcmp(lower(arrowstatus(arrnum)), 'a')
      gettime('status', 'This arrow has active data')
      questarr('init1', arrnum, Me)% ask if plot, load  or save is required
    else
      questarr('init3', arrnum, Me)% ask if load is required
    end

  elseif strcmp(p1,'load_an_arrow')
    arrnum=p2; data=p3;
    h_donepb=findobj(myfig,'tag','gettime_button_done');
    switch arrnum
      case 1
        guidtawr(Me,'DATA_gotdata','direct',data);
        boxmgr(['end_of_gettdata'], Me, 'LOADEDDATA')
        set(h_donepb, 'userdata', 'gettdata');
        arrplot('arr1', 'infoupdate')
      case 2
        guidtawr(Me,'DATA_segmenteddata','direct',data);
        boxmgr(['end_of_segment'], Me, 'LOADEDDATA')
        set(h_donepb, 'userdata', 'segment');
        arrplot('arr2', 'infoupdate')
      case 3
        guidtawr(Me,'DATA_converteddata','direct',data);
        boxmgr(['end_of_convert'], Me, 'LOADEDDATA')
        set(h_donepb, 'userdata', 'convert');
        arrplot('arr3', 'infoupdate')
      case 4
        guidtawr(Me,'DATA_selecteddata','direct',data);
        boxmgr(['end_of_freqsel'], Me, 'LOADEDDATA')
        set(h_donepb, 'userdata', 'freqsel');
        arrplot('arr4', 'infoupdate')
    end

  elseif strcmp(p1,'ui_cancel')
    gettime('status', 'canceling...', Me);
    %set(myfig,'visible','off');
    guiclose('gettime')
    fdtool('finished_box', 'rect_gettime', 'cancel', Me);
    fdtool('status', 'Gettime panel closed by Cancel. ', Me);

  elseif strcmp(p1,'ui_memory')
    h=findobj(allchild(myfig), 'flat', 'tag', 'gettime_check_memory');
    is_save=get(h, 'value');
    if is_save
      msg='Memory saving option is on (unnecessary arrows will automatically be deleted !)';
    else
      msg='Memory saving option is off.';
    end
    gettime('status', msg)

  elseif strcmp(p1,'ui_autoconvert')|strcmp(p1,'setblocks')
    if (nargin>=2)&isstr(p2)&(strcmp(p2,'segm')|strcmp(p2,'auto'))
      is_auto=strncmp(p2,'auto',4);
    else
      h=findobj(myfig, 'tag', 'gettime_auto_convert');
      is_auto=(strcmp(get(h,'visible'),'on')&get(h, 'value'))|~guiinfos('islinear');
    end
    hsegm=[findobj(myfig,'tag','arr1');...
      findobj(myfig,'tag','rect_segment');...
      findobj(myfig,'tag','text_segment');...
      findobj(myfig,'tag','arr2')];
    boxstr=guidtard('gettime_main', 'BOXMGR');
    arrowstatus=guidtard('gettime_main', 'ARRMGR');
    if is_auto %hide segmentation
      set(hsegm,'visible','off')
      set(findobj(myfig,'tag','arr12'),'visible','on')
      boxmgr('delete_arrow_3','gettime_main')
      if strcmpi(arrowstatus(1),'a')
        boxstr(3).status='s';
        gettime('setbox',boxstr(3).name, guicolor('BOX_COLOR_SELECTABLE')); drawnow
      end
      hview=findobj(0,'type','figure','tag','arrow_plot_fig_gettime');
      if ~isempty(hview), delete(hview); end
    else %not auto
      set(hsegm,'visible','on')
      set(findobj(myfig,'tag','arr12'),'visible','off')
      if strcmpi(arrowstatus(2),'a')
        boxstr(3).status='s';
        gettime('setbox',boxstr(3).name, guicolor('BOX_COLOR_SELECTABLE')); drawnow
      end
      if strcmpi(arrowstatus(1),'a')
        boxstr(2).status='s';
        gettime('setbox',boxstr(2).name, guicolor('BOX_COLOR_SELECTABLE')); drawnow
      elseif strcmpi(arrowstatus(1),'-')
        boxstr(2).status='u';
        gettime('setbox',boxstr(2).name, guicolor('BOX_COLOR_UNSELECTABLE')); drawnow
      end
      boxmgr('delete_arrow_3','gettime_main')
    end
    boxmgr('delete_arrow_4','gettime_main')
    %boxstr(4).status='u';
    %gettime('setbox',boxstr(4).name, guicolor('BOX_COLOR_UNSELECTABLE')); drawnow
    guidtawr('gettime_main', 'BOXMGR', 'direct', boxstr)

    if is_auto %hide segmentation
      msg='Automatic conversion is on';
    else
      msg='Automatic conversion is off.';
    end
    if (nargin>=2)&isstr(p2)&(strcmp(p2,'segm')|strcmp(p2,'auto'))
    else
      gettime('status', msg)
    end

  elseif strcmp(p1,'ui_zohcomp')
    for ixx=[3,4]
      boxmgr(['delete_arrow_' num2str(ixx)], 'gettime_main')
      gettime('ui_autoconvert') %fix coloring
    end

  elseif strcmp(p1,'check&clear_memory')
    h=findobj(allchild(myfig), 'flat', 'tag', 'gettime_check_memory');
    is_save=strcmp(get(h,'visible'),'on')&get(h,'value');
    if is_save
      switch p2
        case 'gettdata'
          delete_arrows=[2,3,4];
        case 'segment'
          delete_arrows=[1,3,4];
        case 'convert'
          delete_arrows=[1,2,4];
        case 'freqsel'
          delete_arrows=[1,2,3];
      end
      for ixx=1:length(delete_arrows)
        boxmgr(['delete_arrow_' num2str(delete_arrows(ixx))], 'gettime_main')
      end
    end

  elseif strcmp(p1,'ui_done') | strcmp(p1, 'autofinish')
    dismispb('remove', 'arrow_plot_fig_gettime'), drawnow
    h=findobj(allchild(myfig), 'flat', 'tag', 'gettime_button_done');
    boxname=get(h, 'userdata');   % this is the name of the box finished last time
    if isempty(boxname)
      gettime('status', 'Error: Use Get Data block before calling Autofinish.')
      return
    end
    guifreez(Me, 'freeze', 'gettime_finish');
    if strcmpi(guiinfos('signaltype'),'periodic')
      gettime('status',['#yAutomatic processing for periodic data is in progress. This may take several minutes.'] )
    else
      gettime('status',['#yAutomatic processing for arbitrary data is in progress. This may take several minutes.'] )
    end
    figure(myfig)
    %perform automatic segmentation if necessary
    if strcmp(boxname,'gettdata')&strcmpi(guiinfos('signaltype'),'periodic')&...
        strcmp(get(findobj(allchild(myfig),'tag','arr2'),'visible'),'on')
      gettime('activate_segment');
      segmdata('done');
      dismispb('remove', 'arrow_plot_fig_gettime'), drawnow
      gettime('status',['Automatic Segmentation done.'] )
      boxname='segment';
    end
    if strcmp(boxname,'gettdata')|strcmp(boxname,'segment')
      %conversion to frequency domain
      gettime('activate_convert')
      dismispb('remove', 'arrow_plot_fig_gettime'), drawnow
      gettime('status',['Conversion to Frequency Domain done.'] )
      boxname='convert';
    end
    if strcmp(boxname,'convert')
      % select all
      if (nargin==3)&strcmp(p3,'with_freq_selection')
        gettime('click_on_freqsel')
        return
      else %run to the end
        boxmgr('click_on_freqsel','gettime_main'); % simulate open box
        convdata=guidtard(Me, 'DATA_converteddata');
        gettime('freqsel_ready', 'done', convdata);
        dismispb('remove', 'arrow_plot_fig_gettime'), drawnow
        gettime('status',['Automatic Time Domain Data Processing Finished.'] )
        boxname='freqsel';
        %guidtawr('gettime_main', 'DATA_selecteddata', 'direct', outdata);
        %gettime('status',['Automatic Processing Finished.'] )
      end
    end
    if strcmp(boxname,'freqsel')
      gettime('status', 'closing...', Me);
      outval=guidtard(Me, 'DATA_selecteddata');
      % write back output data to main window
      guidtawr('fdtool_main', ['OUTPUT_' myname], 'direct', outval);

      % check if memory saving is on
      h=findobj(allchild(myfig), 'flat', 'tag', 'gettime_check_memory');
      is_save=get(h, 'value');
      if is_save  % forget last arrow as well
        boxmgr('delete_arrow_4', 'gettime_main')
      end
      % initiate close button
      %h=findobj(allchild(myfig), 'flat', 'tag', 'gettime_button_done');
      %set(h, 'string', 'Autofinish', 'userdata', '')

      % refresh state variables
      guifreez(Me, 'unfreeze', 'force');
      storewin('remember', Me);

      fdtool('finished_box', 'rect_gettime', 'done', Me);
      fdtool('status', 'Gettime finished. ', Me);
      guiclose('gettime')
      % if auto userlevel, run agv
      if strcmp(lower(guiinfos('userlevel')),'automatic');
        agv;
      end
    end %freqsel

  elseif strcmp(p1,'arrow_deleted')
    deleted_box=p2(6:end);
    h=findobj(allchild(myfig), 'flat', 'tag', 'gettime_button_done');
    last_active_box=get(h,'userdata');
    if strcmp(deleted_box, last_active_box)
      % autofinish is in trouble !!!
      arrstr=guidtard(Me, 'ARRMGR');
      active_ix=find(arrstr== 'a');
      last_box_ix=max([active_ix, 0]);
      switch last_box_ix
        case 0
          act='';
        case 1
          act='gettdata';
        case 2
          act='segment';
        case 3
          act='convert';
        case 4
          act='freqsel';
      end
      if last_box_ix==4
        str='Close';
      else
        str='Autofinish';
      end
      set(h, 'userdata', act, 'string', str);
    end
  elseif strcmp(p1,'destroyed')
    % close all children
    guiclose('gettime')
    try, fdtool('finished_box', 'rect_gettime', 'cancel', Me); catch, end

  elseif strcmp(p1,'setline')
    % p2 line id
    % p3 line color
    ax=findobj(allchild(myfig), 'flat', 'tag', 'gettime_main_ax');
    ch=get(ax, 'children');
    lineid=zeros(1,length(p2));
    for ii=1:length(p2)
      lineid(ii)=findobj(allchild(ax),'flat','tag',['arr' num2str(p2(ii))]);
    end
    %Set arr12 similarly to arr1
    if any(1==[p2,inf])
      lineid(end+1)=findobj(allchild(ax),'flat','tag',['arr' num2str(12)]);
    end
    if ~isempty(lineid)
      set(lineid,'facecolor',p3)
    end

  elseif strcmp(p1,'load_arrow_data')
    gettime('status', '$gDoubleclick on an arrow to load data...')

  elseif strcmp(p1,'save_arrow_data')
    gettime('status', '$gDoubleclick on an active arrow to save data...')

  elseif strcmp(p1,'ui_forget_data')
    gettime('status', 'Please wait, clearing in progress...')
    boxmgr('init', 'gettime_main')
    gettime('setinfo','text_info11', 'Data not available (window cleared)')
    gettime('setinfo','text_info21', '')
    gettime('setinfo','text_info31', '')
    gettime('setinfo','text_info41', '')
    gettime('setinfo','text_info51', '')
    gettime('setinfo','text_info22', '')
    gettime('setinfo','text_info32', '')
    gettime('setinfo','text_info42', '')
    gettime('setinfo','text_info52', '')
    gettime('zohcomp','off')
    h=findobj(allchild(myfig), 'flat', 'tag', 'gettime_button_done');
    set(h, 'userdata', ''); % clear autofinish info
    gettime('status', 'Window cleared')

  elseif strcmp(p1,'setbox')
    % p2 box id
    % p3 box color
    boxid=findobj(myfig,'tag',p2);
    set(boxid,'facecolor',p3)

  elseif strcmp(p1,'finished_box')
    guifreez(Me, 'freeze', 'gettime_finished_box');
    caller_name=p2(6:length(p2));
    if strcmp(p3, 'cancel')
      boxmgr(['cancel_of_' caller_name], Me)
    else % 'done'
      boxmgr(['end_of_' caller_name], Me, 'NEWDATA')
      gettime('status', 'Please wait...')
      h=findobj(myfig,'tag','gettime_button_done');
      if strcmp(caller_name, 'freqsel')
        done_string='Close';
      else
        done_string='Autofinish';
      end
      %            if strcmp(caller_name, 'gettime')
      %               set(h, 'enable', 'on')
      %            end
      set(h, 'userdata', caller_name,...
        'string', done_string)   % store last box's name for autofinish
      set(h,'tooltipstring','Close window, return result')

      gettime('check&clear_memory', caller_name); % check if memory save option is on.
      %If so, delete unnecessary data.

      if strcmp(caller_name, 'gettdata')
        data=guidtard(Me, 'DATA_gotdata');
        expno=data.expnumber;

        % skip segmentation if multiple experiments
        if expno ==1
          % info update & plot
          arrplot('arr1', 'infoupdate')
        else
          % no segmentation required, copy tdata
          guidtawr(Me, 'DATA_segmenteddata', 'direct', data)
          gettime('finished_box', 'rect_segment', 'done');
        end


      elseif strcmp(caller_name, 'segment')
        if strcmp(get(findobj(allchild(myfig),'flat','tag','arr2'),'visible'),'on')
          arrplot('arr2', 'infoupdate')
        else
          arrplot('arr12', 'infoupdate')
        end
      elseif strcmp(caller_name, 'convert')
        arrplot('arr3', 'infoupdate')
      end
      % if basic level then activate autofinish
      if strcmp(caller_name, 'gettdata') & strcmp(guiinfos('UserLevel'), 'Automatic')
        %&~guiinfos('isrecorderplayback')
        drawnow;
        %fdtool('callback', 'gettime', 'ui_done', 'gettime_button_done')
        if strcmpi(guiinfos('signaltype'), 'periodic')
          gettime('ui_done', 'gettime_button_done')
        else %arbitrary data: do signal selection only
          gettime('ui_done', 'gettime_button_done','with_freq_selection')
        end
      end
      gettime('status', 'Done.')

    end %done
    if ishandle(myfig)
      figure(myfig)
    end
    guifreez(Me, 'unfreeze', 'gettime_finished_box');

  elseif strcmp(p1,'freqsel_ready')
    switch p2
      case 'done'
        result=p3;
        addhist(result, 'Frequency selection done.')
        guidtawr('gettime_main', ['DATA_selecteddata'], 'direct', result);
        gettime('finished_box', 'rect_freqsel', 'done', Me);
        %         statusreg=guidtard('gettime_main', ['STATUS_' myname]); % the old statusreg
        %         statusreg=[statusreg '*'];  % example only
        %         guidtawr('gettime_main', ['STATUS_' myname], 'direct', statusreg);
      case 'cancel'
        gettime('finished_box', 'rect_freqsel', 'cancel', Me);
        %            gettime('status', 'Freqsel panel closed by Cancel. ', Me);
    end

  elseif strcmp(p1,'zohcomp')
    h=findobj(allchild(myfig), 'flat', 'tag', 'gettime_zoh_compensate');
    zohcompv=get(h,'value');
    if isa(p2,'tiddata')&strcmp(guiinfos('userlevel'),'Advanced')
      set(h,'visible','on')
    elseif isstr(p2)&strcmp(p2,'on')
      set(h,'visible','on')
    else
      set(h,'visible','off','value',0)
    end
    if ~isequal(zohcompv,get(h,'value'))
      %remove data with other precompensation
      for ixx=[3,4]
        boxmgr(['delete_arrow_' num2str(ixx)], 'gettime_main')
      end
    end

  elseif strcmp(p1,'setinfo')
    h=findobj(allchild(myfig), 'flat', 'tag', p2);
    set(h,'string',p3)
    if exist('p4')
      if ~isstr(p4), error('p4 is not a string'), end
    else
      p4='';
    end
    set(h,'tooltipstring',p4)

  elseif strcmp(p1,'gettime_uic_print')
    %gettime print command
    fdgprint(Me)
    gettime('status','Print figure done.')

  elseif strcmp(p1,'gettime_mod_print_ps')
    %gettime print command
    fdgprint(Me,'ps')

  elseif strcmp(p1, 'preload')
    % preload, nothing to do

  elseif strcmp(p1,'resize')

    mindx=530;
    mindy=310;
    scr=get(0,'screensize');
    mainfigmaxx=scr(3);
    mainfigmaxy=scr(4);

    pos=get(findobj(myfig, 'tag','gettime_main'),'position');
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
      fig_offsy=300;
    end;
    set(myfig,'position',[fig_offsx fig_offsy fig_dx fig_dy]);
    pos=get(findobj(myfig, 'tag','frame_status'),'position');
    set(findobj(myfig, 'tag','frame_status'),'position',[pos(1) pos(2) fig_dx pos(4)]);
    pos=get(findobj(myfig, 'tag','status_gettime'),'position');
    set(findobj(myfig, 'tag','status_gettime'),'position',[pos(1) pos(2) fig_dx-6 pos(4)]);
    pos=get(findobj(myfig, 'tag','gettime_button_done'),'position');
    donepb_dx=pos(3);
    set(findobj(myfig, 'tag','gettime_button_done'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
    pos=get(findobj(myfig, 'tag','gettime_button_cancel'),'position');
    set(findobj(myfig, 'tag','gettime_button_cancel'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
    pos=get(findobj(myfig, 'tag','gettime_check_memory'),'position');
    set(findobj(myfig, 'tag','gettime_check_memory'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
    pos=get(findobj(myfig, 'tag','gettime_auto_convert'),'position');
    set(findobj(myfig, 'tag','gettime_auto_convert'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
    pos=get(findobj(myfig, 'tag','gettime_zoh_compensate'),'position');
    set(findobj(myfig, 'tag','gettime_zoh_compensate'),'position',[0.55*fig_dx-100 0.30*fig_dy+110 pos(3) pos(4)]);

    pos=get(findobj(myfig, 'tag','fr_info'),'position');
    frame_offsx=pos(1);
    frame_offsy=pos(2);
    frame_dx=fig_dx-10-20-20-donepb_dx;
    frame_dy=pos(4);
    text_info21_dx=(frame_dx-20)/2;
    set(findobj(myfig, 'tag','fr_info'),'position',[pos(1) pos(2) frame_dx pos(4)]);
    pos=get(findobj(myfig, 'tag','text_info11'),'position');
    set(findobj(myfig, 'tag','text_info11'),'position',[pos(1) pos(2) frame_dx-10 pos(4)]);
    pos=get(findobj(myfig, 'tag','text_info21'),'position');
    set(findobj(myfig, 'tag','text_info21'),'position',[pos(1) pos(2) text_info21_dx pos(4)]);
    pos=get(findobj(myfig, 'tag','text_info22'),'position');
    text_info22_dx=text_info21_dx;
    text_info22_offsx=frame_offsx+frame_dx-5-text_info22_dx;
    set(findobj(myfig, 'tag','text_info22'),'position',[text_info22_offsx pos(2) text_info22_dx pos(4)]);
    pos=get(findobj(myfig, 'tag','text_info31'),'position');
    set(findobj(myfig, 'tag','text_info31'),'position',[pos(1) pos(2) text_info21_dx pos(4)]);
    pos=get(findobj(myfig, 'tag','text_info32'),'position');
    set(findobj(myfig, 'tag','text_info32'),'position',[text_info22_offsx pos(2) text_info22_dx pos(4)]);
    pos=get(findobj(myfig, 'tag','text_info41'),'position');
    set(findobj(myfig, 'tag','text_info41'),'position',[pos(1) pos(2) text_info21_dx pos(4)]);
    pos=get(findobj(myfig, 'tag','text_info42'),'position');
    set(findobj(myfig, 'tag','text_info42'),'position',[text_info22_offsx pos(2) text_info22_dx pos(4)]);
    pos=get(findobj(myfig, 'tag','text_info51'),'position');
    set(findobj(myfig, 'tag','text_info51'),'position',[pos(1) pos(2) text_info21_dx pos(4)]);
    pos=get(findobj(myfig, 'tag','text_info52'),'position');
    set(findobj(myfig, 'tag','text_info52'),'position',[text_info22_offsx pos(2) text_info22_dx pos(4)]);
    pos=get(findobj(myfig, 'tag','gettime_main_ax'),'position');
    set(findobj(myfig, 'tag','gettime_main_ax'),'position',[pos(1) pos(2) frame_dx fig_dy-(frame_offsy+frame_dy+5)]);

    % text size setting
    h_rect=findobj(myfig, 'tag', 'rect_gettdata');
    rect_posy=get(h_rect, 'xdata');
    rect_width=max(rect_posy)-min(rect_posy); % width of a rect object
    rect_width=rect_width*0.99;
    texth=findobj(myfig, 'type', 'text');
    % now select widest text
    widest_ix=0; widest_wid=0;
    for ii=1:length(texth)
      ext=get(texth(ii), 'extent');
      if ext(3)>widest_wid
        widest_wid=ext(3);
        widest_ix=ii;
      end
    end
    h_widest=texth(widest_ix);
    fontsize=15; widest_wid=inf;
    while (widest_wid>rect_width) & fontsize>5
      fontsize=fontsize-1;
      set(h_widest, 'fontsize', fontsize)
      ext=get(h_widest, 'extent');
      widest_wid=ext(3);
    end
    set(texth, 'fontsize',fontsize);
  else
    if guiinfos('isdevelopment')
      error(['Error: unknown GETTIME command:' p1])
    end
  end
end
