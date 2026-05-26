function out=sme(p1,p2,p3,p4,p5,seltype)
%SME Select Model and Estimate

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 26-Apr-2016, IK

mainfig=findall(0, 'tag','fdtool_main');
myfcn='sme';

if nargin >0 & isempty(findstr(p1, 'init'))
  Me='select_main';
  myfig=findall(0, 'tag',Me);
  myname='select';
  if isempty(myfig)
    Me='aided_main';
    myfig=findall(0, 'tag',Me);
    myname='aided';
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
%               INITIALIZATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin ==0 | ~isempty(findstr(p1, 'init'))
  tmp=findall(0, 'tag','select_main');
  if ~isempty(tmp) 
    % set(tmp,'visible','on');
    %figure(tmp);
    guiclose('select')         
  end
  tmp=findall(0, 'tag','aided_main');
  if ~isempty(tmp) 
    % set(tmp,'visible','on');
    %figure(tmp);
    guiclose('select')         
  end
  smedef
  
  fig = figure(...
    'Units','pixels',...
    'position',[ fig_offsx fig_offsy fig_dx fig_dy ],... 
    'NumberTitle','off',...
    'IntegerHandle', 'off',...
    'Handlevisibility', 'off',...
    'windowbuttondownfcn', '',...
    'windowbuttonmotionfcn', 'fdtool(''callback'',''sme'',''mousemotion'')', ...
    'resize','on',...
    'color',figure_col,...   
    'resizefcn','fdtool(''callback'',''sme'',''resize'',''resize'')',...
    'visible','off'); 
  
  fdwindef(fig);  % set default window properties
  
  if nargin>1 & isstruct(p2) & strcmp(p2.figuretag, 'aided_main')
    p1='init_cams';
  end
  
  if nargin>0 & strcmp(p1, 'init_cams')
    set(fig, 'Tag', 'aided_main',...
      'Name','Computer Aided Model Scan',...
      'deletefcn', 'fdtool(''callback'',''sme'',''destroyed'',''aided_main'')');
    Me='aided_main';
    myname='aided';
  else
    set(fig, 'Tag', 'select_main',...
      'Name','Estimate Plant Model',...
      'deletefcn', 'fdtool(''callback'',''sme'',''destroyed'',''select_main'')');
    Me='select_main';
    myname='select';
  end
  myfig=fig;
  
  
  
  %  Uicontrol Object Creation 
  
  sme_uic_uframe = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_uframe'',''sme_uic_uframe'');',... 
    'Units','pixels',...
    'Position',[ uframe_offsx uframe_offsy uframe_dx uframe_dy ],... 
    'BackgroundColor',frame_bgr_col,...
    'ForegroundColor',frame_fg_col,...
    'String','Upper frame',... 
    'Style','frame',... 
    'Enable','off',...
    'HitTest', 'off',...
    'Tag','sme_uic_uframe',... 
    'UserData',''); 
  sme_uic_domaintext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_domaintext'',''sme_uic_domaintext'');',... 
    'Units','pixels',...
    'Position',[ domaintext_offsx domaintext_offsy domaintext_dx domaintext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Domain',... 
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Tag','sme_uic_domaintext',... 
    'UserData',''); 
  sme_uic_dompop = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'', ''sme'', ''sme_uic_dompop'', ''sme_uic_dompop'')',...
    'Units','pixels',... 
    'Position',[ dompop_offsx dompop_offsy dompop_dx dompop_dy ],... 
    'BackgroundColor',popup_bgr_col,...
    'ForegroundColor',popup_fg_col,...
    'String',{'s', 'z', 'w','r'},... 
    'tooltipstring','Domain of the transfer function: s, z, w=sqrt(s), r=th(s*tauR)',...
    'HorizontalAlignment','right',... 
    'Style','popupmenu',... 
    'Tag','sme_uic_dompop',... 
    'Min',[ 1 ],... 
    'Value',[ 1 ],... 
    'UserData',''); 
  %'tooltipstring','Domain of the transfer function',...
  sme_uic_ordnumtext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_ordnumtext'',''sme_uic_ordnumtext'');',... 
    'Units','pixels',...
    'Position',[ ordnumtext_offsx ordnumtext_offsy ordnumtext_dx ordnumtext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Order of numerator',... 
    'tooltipstring','Order of numerator',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Tag','sme_uic_ordnumtext',... 
    'UserData',''); 
  sme_uic_onedit = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'',''sme'',''ui_edit'',''sme_uic_onedit'');',...
    'Position',[ onedit_offsx onedit_offsy onedit_dx onedit_dy ],...
    'BackgroundColor',edit_bgr_col,...
    'ForegroundColor',edit_fg_col,...
    'String','6',... 
    'tooltipstring','Order of numerator',...
    'HorizontalAlignment','right',... 
    'Style','edit',... 
    'interruptible', 'off', ...
    'Tag','sme_uic_onedit',... 
    'UserData',''); 
  sme_uic_orddentext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_orddentext'',''sme_uic_orddentext'');',... 
    'Units','pixels',...
    'Position',[ orddentext_offsx orddentext_offsy orddentext_dx orddentext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Order of denominator',... 
    'tooltipstring','Order of denominator',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Tag','sme_uic_orddentext',... 
    'UserData',''); 
  sme_uic_odedit = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'',''sme'',''ui_edit'',''sme_uic_odedit'');',...
    'Position',[ odedit_offsx odedit_offsy odedit_dx odedit_dy ],...
    'BackgroundColor',edit_bgr_col,...
    'ForegroundColor',edit_fg_col,...
    'String','6',... 
    'tooltipstring','Order of denominator',...
    'HorizontalAlignment','right',... 
    'Style','edit',... 
    'interruptible', 'off', ...
    'Tag','sme_uic_odedit',... 
    'UserData',''); 
  
  sme_uic_autoorderpb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_autoorderpb'',''sme_uic_autoorderpb'');',... 
    'Units', 'pixels',...
    'Position',[autopb_offsx autopb_offsy autopb_dx autopb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Auto',...
    'tooltipstring','Set automatic order selection',...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','sme_uic_autoorderpb',... 
    'enable', 'on',...
    'UserData',''); 
  
  sme_uic_delaytext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_delaytext'',''sme_uic_delaytext'');',... 
    'Units','pixels',...
    'Position',[ delaytext_offsx delaytext_offsy delaytext_dx delaytext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Delay',... 
    'tooltipstring','Extra delay in the model',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Tag','sme_uic_delaytext',... 
    'UserData',''); 
  sme_uic_delpop = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'', ''sme'', ''sme_uic_delpop'', ''sme_uic_delpop'')',...
    'Units','pixels',... 
    'Position',[ delpop_offsx delpop_offsy delpop_dx delpop_dy ],... 
    'BackgroundColor',popup_bgr_col,...
    'ForegroundColor',popup_fg_col,...
    'String',{'fixed', 'variable'},... 
    'tooltipstring','Keep variable fixed, or estimate it',...
    'HorizontalAlignment','right',... 
    'Style','popupmenu',... 
    'interruptible', 'off', ...
    'Tag','sme_uic_delpop',... 
    'Min',[ 1 ],... 
    'Value',[ 1 ],... 
    'UserData',''); 
  sme_uic_valuetext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_valuetext'',''sme_uic_valuetext'');',... 
    'Units','pixels',...
    'Position',[ valuetext_offsx valuetext_offsy valuetext_dx valuetext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','value:',... 
    'tooltipstring','Extra delay in the model',...
    'HorizontalAlignment','right',... 
    'Style','text',... 
    'Tag','sme_uic_valuetext',... 
    'UserData',''); 
  sme_uic_deledit = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'',''sme'',''ui_edit'',''sme_uic_deledit'');',...
    'Position',[ deledit_offsx deledit_offsy deledit_dx deledit_dy ],...
    'BackgroundColor',edit_bgr_col,...
    'ForegroundColor',edit_fg_col,...
    'String','0',... 
    'tooltipstring','Extra delay in the model',...
    'HorizontalAlignment','right',... 
    'Style','edit',... 
    'interruptible', 'off', ...
    'Enable','on',...
    'Tag','sme_uic_deledit',... 
    'UserData',''); 
  sme_uic_sectext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_sectext'',''sme_uic_sectext'');',... 
    'Units','pixels',...
    'Position',[ sectext_offsx sectext_offsy sectext_dx sectext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'tooltipstring','Extra delay in the model',...
    'String','s',... 
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Tag','sme_uic_sectext',... 
    'UserData',''); 
  sme_uic_fstext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_fstext'',''sme_uic_fstext'');',... 
    'Units','pixels',...
    'Position',[ fstext_offsx fstext_offsy fstext_dx fstext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','fs:',... 
    'tooltipstring','Sampling frequency for z-domain',...
    'HorizontalAlignment','right',... 
    'Style','text',... 
    'Visible','off',...
    'Tag','sme_uic_fstext',... 
    'UserData',''); 
  sme_uic_fsedit = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'',''sme'',''ui_edit'',''sme_uic_fsedit'');',...
    'Position',[ fsedit_offsx fsedit_offsy fsedit_dx fsedit_dy ],...
    'BackgroundColor',edit_bgr_col,...
    'ForegroundColor',edit_fg_col,...
    'String','0',... 
    'HorizontalAlignment','right',... 
    'tooltipstring','Sampling frequency for z-domain',...
    'Style','edit',... 
    'interruptible', 'off', ...
    'Visible','off',...
    'Tag','sme_uic_fsedit',... 
    'UserData',''); 
  sme_uic_fstext2 = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_fstext2'',''sme_uic_fstext2'');',... 
    'Units','pixels',...
    'Position',[ fstext2_offsx fstext2_offsy fstext2_dx fstext2_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Hz',... 
    'tooltipstring','Sampling frequency for z-domain',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Visible','off',...
    'Tag','sme_uic_fstext2',... 
    'UserData',''); 
  sme_uic_trtext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_trtext'',''sme_uic_trtext'');',... 
    'Units','pixels',...
    'Position',[ fstext_offsx fstext_offsy fstext_dx fstext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','tauR:',... 
    'tooltipstring','tau coefficient for Richards-domain',...
    'HorizontalAlignment','right',... 
    'Style','text',... 
    'Visible','off',...
    'Tag','sme_uic_trtext',... 
    'UserData',''); 
  sme_uic_tredit = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'',''sme'',''ui_edit'',''sme_uic_tredit'');',...
    'Position',[ fsedit_offsx fsedit_offsy fsedit_dx fsedit_dy ],...
    'BackgroundColor',edit_bgr_col,...
    'ForegroundColor',edit_fg_col,...
    'String','0.01',... 
    'HorizontalAlignment','right',... 
    'tooltipstring','tau coefficient for Richards-domain',...
    'Style','edit',... 
    'interruptible', 'off', ...
    'Visible','off',...
    'Tag','sme_uic_tredit',... 
    'UserData',''); 
  sme_uic_trtext2 = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_trtext2'',''sme_uic_trtext2'');',... 
    'Units','pixels',...
    'Position',[ fstext2_offsx fstext2_offsy fstext2_dx fstext2_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','s',... 
    'tooltipstring','tau coefficient for Richards-domain',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Visible','off',...
    'Tag','sme_uic_trtext2',... 
    'UserData',''); 
  sme_uic_raztext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_raztext'',''sme_uic_raztext'');',... 
    'Units','pixels',...
    'Position',[ raztext_offsx raztext_offsy raztext_dx raztext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Fixed',... 
    'HorizontalAlignment','left',... 
    'tooltipstring','In estimated model, fix poles or zeros at position zero',...
    'Style','text',... 
    'Tag','sme_uic_raztext',... 
    'UserData',''); 
  sme_uic_razpop = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'', ''sme'', ''sme_uic_razpop'', ''sme_uic_razpop'')',...
    'Units','pixels',... 
    'Position',[ razpop_offsx razpop_offsy razpop_dx razpop_dy ],... 
    'BackgroundColor',popup_bgr_col,... 
    'ForegroundColor',popup_fg_col,...
    'HorizontalAlignment','right',... 
    'String',{'no root','poles','zeros'},...
    'value', 1, ...   
    'tooltipstring','In estimated model, fix poles or zeros at position zero',...
    'Style','popup',...
    'enable','on',...
    'Tag','sme_uic_razpop',... 
    'UserData',''); 
  sme_uic_raztext2 = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_raztext2'',''sme_uic_raztext2'');',... 
    'Units','pixels',...
    'Position',[ raztext2_offsx raztext2_offsy raztext2_dx raztext2_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','at zero',... 
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'tooltipstring','In estimated model, fix poles or zeros at position zero',...
    'Tag','sme_uic_raztext2',... 
    'UserData',''); 
  sme_uic_razedit = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'',''sme'',''ui_edit'',''sme_uic_razedit'');',...
    'Position',[ razedit_offsx razedit_offsy razedit_dx razedit_dy ],...
    'BackgroundColor',edit_bgr_col,...
    'ForegroundColor',edit_fg_col,...
    'String','0',... 
    'HorizontalAlignment','right',... 
    'Style','edit',... 
    'interruptible', 'off', ...
    'tooltipstring','Number of fixed poles or zeros at position zero',...
    'Enable','on',...
    'Visible','off',...
    'Tag','sme_uic_razedit',... 
    'UserData',''); 
  sme_uic_improvedcb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_improvedcb'',''sme_uic_improvedcb'');',... 
    'Units','pixels',...
    'Position',[ improvedcb_offsx improvedcb_offsy improvedcb_dx improvedcb_dy ],...
    'BackgroundColor',checkb_bgr_col,...
    'ForegroundColor',checkb_fg_col,...
    'String','Improved numerical stability',...
    'tooltipstring','Slower but numerically more robust algorithm',...
    'enable','on',...
    'HorizontalAlignment','left',... 
    'Style','checkbox',... 
    'Value',[ 0],... 
    'Tag','sme_uic_improvedcb',... 
    'UserData','');
  sme_uic_slowertext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_slowertext'',''sme_uic_slowertext'');',... 
    'Units','pixels',...
    'Position',[ slowertext_offsx slowertext_offsy slowertext_dx slowertext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','(slower iteration)',... 
    'enable','on',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Tag','sme_uic_slowertext',... 
    'UserData',''); 
  
  sme_uic_transientcb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_transientcb'',''sme_uic_transientcb'');',... 
    'Units','pixels',...
    'Position',[ transientcb_offsx transientcb_offsy transientcb_dx transientcb_dy ],...
    'BackgroundColor',checkb_bgr_col,...
    'ForegroundColor',checkb_fg_col,...
    'String','Transient elimination',...
    'tooltipstring','Deal with transients in measured data',...
    'enable','on',...
    'HorizontalAlignment','left',... 
    'Style','checkbox',... 
    'Value',[ 0 ],... 
    'Tag','sme_uic_transientcb',... 
    'UserData',''); 
  
  sme_uic_complexcb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_complexcb'',''sme_uic_complexcb'');',... 
    'Units','pixels',...
    'Position',[ complexcb_offsx complexcb_offsy complexcb_dx complexcb_dy ],...
    'BackgroundColor',checkb_bgr_col,...
    'ForegroundColor',checkb_fg_col,...
    'String','Complex Coeffs',...
    'tooltipstring','Enable complex coefficients',...
    'enable','on',...
    'HorizontalAlignment','left',... 
    'Style','checkbox',... 
    'Value',[ 0 ],... 
    'Tag','sme_uic_complexcb',... 
    'UserData',''); 
  
  sme_uic_trordtext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_valuetext'',''sme_uic_valuetext'');',... 
    'Units','pixels',...
    'Position',[ trordtext_offsx trordtext_offsy trordtext_dx trordtext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Order:',... 
    'tooltipstring','Order of transient numerator',...
    'HorizontalAlignment','right',... 
    'Style','text',... 
    'Tag','sme_uic_trordtext',... 
    'enable','off',...
    'UserData',''); 
  
  sme_uic_trordedit = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'',''sme'',''ui_edit'',''sme_uic_trordedit'');',...
    'Position',[ trordedit_offsx trordedit_offsy trordedit_dx trordedit_dy ],...
    'BackgroundColor',edit_bgr_col,...
    'ForegroundColor',edit_fg_col,...
    'String','maxord-1',... 
    'tooltipstring','Order of transient numerator',...
    'HorizontalAlignment','right',... 
    'Style','edit',... 
    'interruptible', 'off', ...
    'Tag','sme_uic_trordedit',... 
    'enable','off',...
    'UserData',''); 
  
  sme_uic_lframe = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_lframe'',''sme_uic_lframe'');',... 
    'Units','pixels',...
    'Position',[ lframe_offsx lframe_offsy lframe_dx lframe_dy ],... 
    'BackgroundColor',frame_bgr_col,...
    'ForegroundColor',frame_fg_col,...
    'Style','frame',... 
    'Enable','off',...
    'HitTest', 'off',...
    'Tag','sme_uic_lframe',... 
    'UserData',''); 
  sme_uic_iterationtext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_iterationtext'',''sme_uic_iterationtext'');',... 
    'Units','pixels',...
    'Position',[ iterationtext_offsx iterationtext_offsy iterationtext_dx iterationtext_dy ],...
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Iteration:',... 
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Tag','sme_uic_iterationtext',... 
    'UserData',''); 
  sme_uic_startpb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_startpb'',''sme_uic_startpb'');',... 
    'Units','pixels',...
    'Position',[ startpb_offsx startpb_offsy startpb_dx startpb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Start',... 
    'tooltipstring','Start iteration',...
    'HorizontalAlignment','center',...
    'Style','pushbutton',... 
    'Tag','sme_uic_startpb',... 
    'UserData','');
  if iscams(myfig)
    set(sme_uic_startpb,'tooltipstring','Start scanning')
  end
  
  sme_mod_pausepb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_mod_pausepb'',''sme_mod_pausepb'');',... 
    'Units','pixels',...
    'Position',[ pausepb_offsx pausepb_offsy pausepb_dx pausepb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Pause',... 
    'tooltipstring','Stop iterating until next Continue command',...
    'HorizontalAlignment','center',...
    'Style','pushbutton',... 
    'enable', 'off',...
    'Tag','sme_mod_pausepb',... 
    'UserData',''); 
  
  sme_mod_finishpb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_mod_finishpb'',''sme_mod_finishpb'');',... 
    'Units','pixels',...
    'Position',[ finishpb_offsx finishpb_offsy finishpb_dx finishpb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Finish',... 
    'tooltipstring','Finish running iteration, return result',...
    'HorizontalAlignment','center',...
    'Style','pushbutton',... 
    'enable', 'off',...
    'Tag','sme_mod_finishpb',... 
    'UserData',''); 
  
  sme_mod_skippb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_mod_skippb'',''sme_mod_skippb'');',... 
    'Units', 'pixels',...
    'Position',[ skippb_offsx skippb_offsy skippb_dx skippb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Skip',...
    'tooltipstring','Skip this model from scan',...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','sme_mod_skippb',... 
    'enable', 'off',...
    'UserData',''); 
  
  sme_mod_abortpb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_mod_abortpb'',''sme_mod_abortpb'');',... 
    'Units', 'pixels',...
    'Position',[ abortpb_offsx abortpb_offsy abortpb_dx abortpb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Abort',...
    'tooltipstring','Abort estimation iterations',...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'enable', 'off',...
    'Tag','sme_mod_abortpb',... 
    'UserData',''); 
  
  sme_mod_elisparampb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_elisparampb'',''sme_uic_elisparampb'');',... 
    'Units', 'pixels',...
    'Position',[ elispb_offsx elispb_offsy elispb_dx elispb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor','r',...
    'String','Parameters...',...
    'tooltipstring','Elis parameters (string is read for special settings)',...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','sme_uic_elisparampb',... 
    'UserData','',...
    'visible','off'); 
  
  if ~iscams(myfig)
    sme_uic_linloghpop = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'',''sme'', ''sme_uic_linloghpop'', ''sme_uic_linloghpop'')',...
      'Units','pixels',... 
      'Position',[ linloghpop_offsx linloghpop_offsy linloghpop_dx linloghpop_dy ],... 
      'BackgroundColor',popup_bgr_col,... 
      'ForegroundColor',popup_fg_col,...
      'HorizontalAlignment','right',... 
      'String',{'lin freq','log freq'},... 
      'tooltipstring','Linear/logarithmic frequency axis',...
      'Style','popup',... 
      'Tag','sme_uic_linloghpop',... 
      'UserData',''); 
    
    sme_uic_varpop = uicontrol(... 
      'Parent',fig,...
      'CallBack', 'fdtool(''callback'', ''sme'', ''sme_uic_varpop'', ''sme_uic_varpop'')',...
      'Units','pixels',... 
      'Position',[ varpop_offsx varpop_offsy varpop_dx varpop_dy ],... 
      'BackgroundColor',popup_bgr_col,... 
      'ForegroundColor',popup_fg_col,...
      'HorizontalAlignment','right',... 
      'String',{'var on','var off'},...
      'value', 1, ...   
      'tooltipstring','Show or do not show variance data in plot',...
      'Style','popup',...
      'enable','on',...
      'Tag','sme_uic_varpop',... 
      'UserData',''); 
  end
  
  sme_uic_collectpb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_collectpb'',''sme_uic_collectpb'');',... 
    'Units','pixels',...
    'Position',[ collectpb_offsx collectpb_offsy collectpb_dx collectpb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Collect',... 
    'tooltipstring','Collect calculated model(s) into set #2 of next block',...
    'HorizontalAlignment','center',...
    'Style','pushbutton',... 
    'Tag','sme_uic_collectpb',... 
    'enable', 'off',...
    'UserData',''); 
  
  sme_uic_cancelpb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_cancelpb'',''sme_uic_cancelpb'');',... 
    'Units','pixels',...
    'Position',[ cancelpb_offsx cancelpb_offsy cancelpb_dx cancelpb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Cancel',... 
    'tooltipstring','Close window, return no result',...
    'HorizontalAlignment','center',...
    'Style','pushbutton',... 
    'Tag','sme_uic_cancelpb',... 
    'UserData',''); 
  
  sme_uic_donepb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_donepb'',''sme_uic_donepb'');',... 
    'Units','pixels',...
    'Position',[ donepb_offsx donepb_offsy donepb_dx donepb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Close',... 
    'tooltipstring','Close window, return result',...
    'HorizontalAlignment','center',...
    'Style','pushbutton',... 
    'enable', 'off',...
    'Tag','sme_uic_donepb',... 
    'UserData',''); 
  
  sme_uic_deselpb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_deselpb'',''sme_uic_deselpb'');',...
    'Units','pixels',...
    'Position',[ deselpb_offsx deselpb_offsy deselpb_dx deselpb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Deselect improper',... 
    'tooltipstring','Deselect models with order of numerator > order of denominator',...
    'HorizontalAlignment','left',...
    'Style','pushbutton',... 
    'Tag','sme_uic_deselpb',... 
    'visible', 'off', ...
    'enable', 'on', ...
    'UserData','');
  
  sme_uic_statusframe = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_statusframe'',''sme_uic_statusframe'');',... 
    'Units','pixels',...
    'Position',[ statusframe_offsx statusframe_offsy statusframe_dx statusframe_dy ],... 
    'BackgroundColor',frame_bgr_col,...
    'ForegroundColor',frame_fg_col,...
    'String','',... 
    'HorizontalAlignment','left',... 
    'Style','frame',... 
    'Enable','off',... 
    'Tag','sme_uic_statusframe',... 
    'UserData',''); 
  
  sme_uic_statustext = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_statustext'',''sme_uic_statustext'');',... 
    'Units','pixels',...
    'Position',[ statustext_offsx statustext_offsy statustext_dx statustext_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Help area',... 
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Tag','sme_uic_statustext',... 
    'UserData',''); 
  
  sme_uic_zsdspop = uicontrol(... 
    'Parent',fig,...
    'CallBack', 'fdtool(''callback'', ''sme'', ''sme_uic_zsdspop'', ''sme_uic_zsdspop'')',...
    'Units','pixels',... 
    'Position',[ zsdspop_offsx zsdspop_offsy zsdspop_dx zsdspop_dy ],... 
    'BackgroundColor',popup_bgr_col,... 
    'ForegroundColor',popup_fg_col,...
    'HorizontalAlignment','right',... 
    'String',{'Zoom','Select models','Deselect models'},... 
    'tooltipstring','Choose type of mouse action on plot',...
    'Value', 2,...
    'Style','popup',... 
    'Tag','sme_uic_zsdspop',... 
    'UserData',''); 
  
  sme_uic_showcb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''sme'',''sme_uic_showcb'',''sme_uic_showcb'');',... 
    'Units', 'pixels',...
    'Position',[ showcb_offsx showcb_offsy showcb_dx showcb_dy ],... 
    'BackgroundColor',figure_col,...
    'ForegroundColor',checkb_fg_col,...
    'String','Show ELiS',...
    'tooltipstring','Show/hide plots during estimation iterations',...
    'HorizontalAlignment','left',... 
    'Style','checkbox',... 
    'Tag','sme_uic_showcb',...
    'Value',1,...
    'UserData',''); 
  
  %  Menu Object Creation 
  
  
  %  Axes and Text Object Creation 
  
  sme_axes_ax = axes(... 
    'Parent',fig,...
    'Units','pixels', ... 
    'Position',[ ax_offsx ax_offsy ax_dx ax_dy],... 
    'Xgrid','off', ... 
    'Ygrid','off', ... 
    'Xlim',[ 0 1 ],... 
    'Ylim',[ 0 1 ],... 
    'buttondownfcn', 'fdtool(''callback'',''sme'',''buttondown'',''sme_axes_ax'')',...
    'defaultlinehittest', 'off',...
    'nextplot', 'replacechildren',...
    'Clipping','on', ... 
    'Tag','sme_axes_ax', ... 
    'UserData',''); 
  
  % init help fcns
  helpmgr('init_help', '', myfcn, myfig );
  guimenus(Me , myname,'sme');
  winmenu(myfig);
  
  %   if strcmp(Me, 'select_main')
  %      set(sme_mod_skippb, 'visible', 'off')
  %   end
  sme('set_sme/cams')
  if iscams(myfig)
    set(sme_uic_deselpb, 'visible', 'on')
    set([sme_uic_onedit, sme_uic_odedit], 'string', '5:6');
    set(sme_uic_showcb, 'value', 0);
  end
  
  if strcmpi(guiinfos('userlevel'),'automatic')
    if ~iscams(myfig)
      sme('sme_cmd_autoorderpb','sme_uic_autoorderpb');
    else
      sme('sme_cmd_autoorderpb','sme_uic_autoorderpb','autoscan');
    end
    sme('status','#yIf model orders are known, please write them into the corresponding fields before starting.')
  end
  
  if nargin >1
    if ~isempty(p2) % sme('init', initvar): load session 
      storewin('restore_all', Me, p2) % bring up window with settings in p2
      load_need=0;
    else
      load_need=1;
      % sme('init', ''): default settings
    end
  else % sme or sme('init') : no initvars, restore if possible
    load_need=storewin('recover_more', Me);
  end
  sme('status', 'Please wait...')
  if load_need
    %% Load input variable
    inpval=guidtard('fdtool_main', 'OUTPUT_average');
    guidtawr(Me,'DATA_INPUT','direct',inpval);
    if strcmp(inpval.state,'transient'), set(sme_uic_transientcb,'value',1), end
    guidtawr(Me,'FINAL_DATA','direct',{});
  end
  sme('sme_uic_delpop', 'nodelete') % check consistency (value/start value)
  sme('sme_uic_zsdspop') % set deselpb's enable status correctly
  sme('sme_uic_dompop', 'nodelete') % check consistency (samples/s, fs enable/disable)
  CheckElisParameters(myfig, 'silent')
  if iscams(myfig) 
    if isempty(guidtard(Me, 'SELECTED_MODELS')) |...
        isempty(guidtard(Me, 'MODEL_RANGE'))
      %   sme('sme_uic_zsdspop') % set zoom/select/deselect mode
      sme('in_axes');
    else
      sme('in_axes', 'keep old selection');
    end
  end
  ulevctrl(Me); %user level control
  SetMsg(myfig)
  sme('update_plot', Me);
  
  intoscr({Me});
  sme('resize','resize');
  
  % The above function, intoscr positions the windows given by their labels
  % into the actual screen. This might come handy when the session has been saved 
  % on a machine with different resolution than that of the present machine.

  set(myfig,'visible','on'); pause(0), %drawnow;
  sme('status', 'Ready.')
  
  inpval=guidtard(Me, 'DATA_INPUT');
  warn=0; nonlinM=inpval.nonlinM; if isempty(nonlinM), nonlinM=1; end
  if guiinfos('islinear')&any(nonlinM*inpval.M<3)
    warn=1; M=inpval.M;
  elseif ~guiinfos('islinear')&any(inpval.nonlinM<3)
    warn=1; M=inpval.nonlinM;
  end
  if warn
    sme('status',sprintf('Warning! Number of experiments is %.0f. Required: at least 4.',M))
  end
  
elseif strcmp(p1, 'mousemotion')
  guiready(myfig, myfcn)
  
elseif strcmp(p1,'status')
  c=allchild(myfig);
  status=findobj(c, 'flat', 'tag','sme_uic_statustext');
  statusfr=findobj(c, 'flat', 'tag','sme_uic_statusframe');
  glstatus(myfig, status, statusfr, p2)
  
elseif strcmp(p1, 'in_axes')
  % p2 optional, if exists, old range and selection kept   
  
  h  = findobj(allchild(myfig), 'flat', 'Tag', 'sme_axes_ax');
  h1 = findobj(allchild(myfig), 'flat', 'Tag', 'sme_uic_onedit');
  h2 = findobj(allchild(myfig), 'flat', 'Tag', 'sme_uic_odedit');
  try
    x = eval(['[',get(h2, 'string'),']'])';
    y = eval(['[',get(h1, 'string'),']'])';
  catch
    x = 1;
    y = 1;
  end
  
  % The transposition is needed, since the vector is row vector, and the graphical
  % functions expect column vectors.
  
  set(h, 'XLim', [min(x) - 1, max(x) + 1]);
  %   set(h, 'XTick', x);
  %   set(h, 'XTickLabel', num2str(x));
  set(h, 'YLim', [min(y) - 1, max(y) + 1]);
  %   set(h, 'YTick', y);
  %   set(h, 'YTickLabel', num2str(y)); 
  
  if nargin == 1 
    model_range = create_pairs(x, y);
    guidtawr(Me,'MODEL_RANGE','direct', model_range);
    update_selected_models(Me);
    update_done_models(Me);
  else
    % keep old values
  end
  
  
  
elseif strcmp(p1,'sme_uic_collectpb')
  sme('status', 'collecting models...', Me);
  outval=guidtard(Me, 'FINAL_DATA');
  collectdata=guidtard('fdtool_main', 'DATA_MODELS_FROM_SME_TO_CAMS');
  if isempty(collectdata), collectdata={}; end % be sure it's cell
  collectdata(end+1:end+length(outval))=outval;
  guidtawr('fdtool_main', 'DATA_MODELS_FROM_SME_TO_CAMS', 'direct', collectdata)
  if length(outval) > 1, grammar='s are'; else grammar=' is'; end
  sme('status', ['Model' grammar ' added to collection set.']);
  
elseif strcmp(p1,'sme_uic_donepb')| strcmp(p1,'sme_cmd_donepb')
  sme('status', 'closing...', Me);
  pause(0)
  outval=guidtard(Me, 'FINAL_DATA');
  % if length(outval)==1, outval=outval{1}; end % obsolate cell array output
  new_outval='';
  for ii=1:length(outval)  % inside sme cell array of fidmodels is used !!
    if isempty(new_outval), new_outval=outval{ii};
    else new_outval=stack(1,new_outval,outval{ii});
    end
  end
  % write back output data to main window
  guidtawr('fdtool_main', ['OUTPUT_' myname], 'direct', new_outval);
  fdtool('finished_box', ['rect_' myname], 'done', Me);
  storewin('remember', Me)
  guiclose('select')   
  
elseif strcmp(p1,'sme_uic_cancelpb')|strcmp(p1,'sme_mod_cancelpb')
  %        helis='';
  %        while isempty(helis), helis=findall(0, 'tag', 'elis_window');...
  %        eval('iterctrl(''Cancel'',helis);','helis=[]'), pause(0), end
  sme('status', 'Canceling...', Me);
  helis=findall(0, 'tag', 'elis_window');
  if ElisIsRunning
    % stop request to elis
    eval('iterctrl(''Cancel'', helis);', '')
    % set cancel flag now, if elis finished, cancel will be called again
    guidtawr(Me, 'cancelrequest', 'direct', 1)
    sme('status', 'Cancel in progress, waiting for ELiS to finish')
    return
  else
    guiclose('select')
    fdtool('finished_box', ['rect_' myname], 'cancel', Me);
    if strcmp(Me, 'select_main')
      fdtool('status', 'Select Model panel cancelled. ', Me);
    else
      fdtool('status', 'Computer Aided Model Scan panel cancelled. ', Me);
    end
  end
  
  
elseif strcmp(p1, 'sme_uic_elisparampb')
  if IsDefaultElisParam(myfig)
    str='default.';
  else
    str='not default.';
  end      
  sme('status', ['$yUnder construction... Use Run modifiers menu instead to adjust iteration parameters. Current settings: ' str])
  
elseif strcmp(p1, 'sme_update_iterctrl_menu')
  SetModifMenu(myfig)
  
elseif any(findstr(p1,'_runmod'))
  ElisParams=GetElisParams(myfig);
  switch p1
  case 'sme_uic_runmod_stab_off'
    ElisParams.stabilization='off';
    sme('status', 'Stabilization mode is off');
  case 'sme_uic_runmod_stab_refl'
    ElisParams.stabilization='reflection';
    sme('status', 'Stabilization mode is reflection');
  case 'sme_uic_runmod_stab_contr'
    ElisParams.stabilization='contraction';
    sme('status', 'Stabilization mode is contraction');
  case 'sme_uic_runmod_stab_limit'
    ElisParams.stabilization='limitation';
    sme('status', 'Stabilization mode is limitation');
  case 'sme_uic_runmod_fmph_off'
    ElisParams.minimumphase='off';
    sme('status', 'Minimum phase mode is off');
  case 'sme_uic_runmod_fmph_refl'
    ElisParams.minimumphase='reflection';
    sme('status', 'Minimum phase mode is reflection');
  case 'sme_uic_runmod_fmph_contr'
    ElisParams.minimumphase='contraction';
    sme('status', 'Minimum phase mode is contraction');
  case 'sme_uic_runmod_fmph_limit'
    ElisParams.minimumphase='limitation';
    sme('status', 'Minimum phase mode is limitation');
  case 'sme_uic_runmod_itno_default'
    ElisParams.maxiterations='default';
    sme('status', 'Max. iteration number is set to default');
  case 'sme_uic_runmod_itno_value'
    ElisParams.maxiterations='selected';
    sme('status', 'Max. iteration number is set to selected value');
  case 'sme_uic_runmod_itno_set'
    % call input window to import integer
    % set value on return
    guifreez(Me, 'freeze_strong', 'import_iteration_number');
    sme('status', 'Importing max. iteration number...');
    itnodefault=50;
    param=GetElisParams(myfig);
    if isfield(param,'selectedmaxiterations') & ~isempty(param.selectedmaxiterations)
      itnodefault=param.selectedmaxiterations;
    end
    gmexp('init', myfcn, 'integer', num2str(itnodefault));
    1;
  case 'sme_uic_runmod_margin'
    % call input window to import margin
    % set value on return
    hdom=findobj(myfig,'tag','sme_uic_dompop'); domain=popupstr(hdom);
    %guifreez(Me, 'freeze_strong', 'import_margin');
    sme('status', 'Importing stability / min phase margin ...');
    if strcmp(domain,'z'), margindefault=1; else margindefault=0; end
    param=GetElisParams(myfig);
    if isfield(param,'selectedmargin') & ~isempty(param.selectedmargin)
      margindefault=param.selectedmargin;
    end
    if strcmp(domain,'z')
      gmexp('init', myfcn, 'posle1', num2str(margindefault),'Enter positive number in (0,1]');
    else
      gmexp('init', myfcn, 'nonpositive', num2str(margindefault),'Enter nonpositive number (margin in radHz)');
    end
case 'sme_uic_runmod_iobj_trials'
    ElisParams.startingvalues='trials';
    sme('status', 'Starting value: trials (default)');
  case 'sme_uic_runmod_iobj_aml'
    ElisParams.startingvalues='AML';
    sme('status', 'Starting value: AML');
  case 'sme_uic_runmod_iobj_iqml'
    ElisParams.startingvalues='IQML';
    sme('status', 'Starting value: IQML');
  case 'sme_uic_runmod_iobj_ls'
    ElisParams.startingvalues='LS';
    sme('status', 'Starting value: LS');
  case 'sme_uic_runmod_iobj_uw'
    ElisParams.startingvalues='Ur-weight';
    sme('status', 'Starting value: Ur-weight');
  case 'sme_uic_runmod_iobj_ew'
    ElisParams.startingvalues='Eqr-weight';
    sme('status', 'Starting value: Eqr-weight');
  case 'sme_uic_runmod_iobj_yw'
    ElisParams.startingvalues='Yr-weight';
    sme('status', 'Starting value: Yr-weight');
  case 'sme_uic_runmod_iobj_equ'
    ElisParams.startingvalues='EE';
    sme('status', 'Starting value: Equation Error');
  case 'sme_uic_runmod_iobj_object'
    ElisParams.startingvalues='object';
    sme('status', 'Starting value: selected object');
  case 'sme_uic_runmod_iobj_weight'
    ElisParams.startingvalues='weight';
    sme('status', 'Starting value: selected weight');
    
    
  case 'sme_uic_runmod_iobj_setobject'
    % call input window to import fidmodel object
    % set value on return
    guifreez(Me, 'freeze_strong', 'import_initial_model');
    sme('status', 'Import fidmodel object...');
    filtstr='fidmodel object';
    guiimpv('init', myfcn, 'STARTING_MODEL', [], ['filter: ',filtstr] )
    %sd=guidtard(Me,'STARTING_MODEL') %too early
    set(get(get(findall(myfig,'tag','sme_menu_runmod_iobj_setobject'),...
      'parent'),'children'),'checked','off')
    set(findall(myfig,'tag','sme_menu_runmod_iobj_setobject'),'checked','on')
    guifreez(Me, 'unfreeze', 'force');
 
  case 'sme_uic_runmod_iobj_setweight'
    % call import vector
    % set value on return
    h=findobj(myfig,'tag','sme_menu_runmod_iobj_setweight');
    label=get(h,'label');
    if any(findstr('Load ',label))
      set(h,'Label','Clear initial &weight')
      guifreez(Me, 'freeze_strong', 'import_initial_weight');
      sme('status', 'Import weight vector...');
      filtstr='weight vector';
      guiimpv('init', myfcn, 'STARTING_WEIGHT', [], ['filter: ',filtstr] )
    else
      set(h,'Label','Load initial &weight')
      ElisParams=GetElisParams(myfig);
      ElisParams.selectedstartingweight=[];
      if isequal(ElisParams.startingvalues,'weight'), ElisParams.startingvalues='trials'; end
      SetElisParams(myfig, ElisParams);
    end
    guifreez(Me, 'unfreeze','force');
    
  case 'sme_uic_runmod_iobj_setdefault'
    % set value on return
    %eval(get(findall(0,'tag','sme_menu_runmod_stab_off'),'callback'));
    %eval(get(findall(0,'tag','sme_menu_runmod_fmph_off'),'callback'));
    %eval(get(findall(0,'tag','sme_menu_runmod_itno_default'),'callback'));
    %eval(get(findall(0,'tag','sme_menu_runmod_iobj_trials'),'callback'));
    ElisParams=defelpar('default');
    set(get(get(findall(myfig,'tag','sme_menu_runmod_iobj_sme'),'parent'),'children'),...
      'checked','off')
    sme('status', 'Run modifiers eliminated: run parameters set to default...');
    
  case {'sme_uic_runmod_iobj_sme_int','sme_uic_runmod_iobj_sme',...
        'sme_uic_runmod_iobj_cams', 'sme_uic_runmod_iobj_caem'}
    if strcmpi(p1,'sme_uic_runmod_iobj_sme_int')&...
        strcmp(get(findall(myfig,'tag','sme_menu_runmod_iobj_sme_int'),'checked'),'on')
      %SME_int checked, SME_int selected: do not touch checks
    else
      set(get(get(findall(myfig,'tag','sme_menu_runmod_iobj_sme'),'parent'),'children'),...
        'checked','off')
    end
    if any(findstr(p1, '_sme_int'))
      model=guidtard(Me, ['FINAL_DATA' ]);
      if iscell(model), model=model{1}; end
      name2='EPM result';
      if isempty(model)&strcmp(get(findall(myfig,'tag','sme_menu_runmod_iobj_sme_int'),'checked'),'on')
        %same selection, can keep former starting value
        model=guidtard(Me,'STARTING_MODEL');
        name2='earlier EPM result';
      elseif ~isempty(model)
        guidtawr(Me,'STARTING_MODEL','direct',model)
      end
      set(findall(myfig,'tag','sme_menu_runmod_iobj_sme_int'),'checked','on')
      if ~isempty(model), model='SME_result'; end
    elseif any(findstr(p1, '_sme'))
      model=guidtard('fdtool_main', ['OUTPUT_select' ]);
      name2='EPM output';
      set(findall(myfig,'tag','sme_menu_runmod_iobj_sme'),'checked','on')
    elseif any(findstr(p1, '_cams'))
      moddat=guidtard('fdtool_main', ['OUTPUT_aided']);
      name2='CAMS output';
      % select best model
      if isa(moddat, 'cell')
        Error('Old cell format !!!!')
      end
      % find best model here
      best_crit=inf;
      best_ix=1;
      for ix=1:length(moddat)
        tmp=moddat(ix); fit=tmp.fitinfo;
        if isstruct(fit)
          AIC=fit.AIC;
          if isfield(fit,'MDL'), MDL=fit.MDL; else MDL=[]; end
        else
          AIC=fit(12);
          if length(fit)>=19, MDL=fit(19); else MDL=[]; end
        end
        if ~isempty(MDL)&(MDL < best_crit)
          best_crit=MDL;
          best_ix=ix;
        end
      end
      model=moddat(best_ix);
      set(findall(myfig,'tag','sme_menu_runmod_iobj_cams'),'checked','on')
      
    elseif any(findstr(p1, '_caem'))
      model=guidtard('fdtool_main', ['OUTPUT_compare']);
      name2='ECPM output';
      set(findall(myfig,'tag','sme_menu_runmod_iobj_caem'),'checked','on')
    end         
    if ~isempty(model)
      ElisParams.selectedstartingmodel=model;
      ElisParams.startingvalues='object';
      sme('status', ['Initial model selected from ' name2])   
    else
      sme('status', ['Error: ' name2 ' is empty.'])   
      set(get(get(findall(myfig,'tag','sme_menu_runmod_iobj_sme'),...
        'parent'),'children'),'checked','off')
    end
  end
  %ElisParams;
  SetElisParams(myfig, ElisParams);
  SetMsg(myfig) % set default/nondefault setting msg
  
  % here a comparison could be made
  % if OldElisParam ~= NewElisParams
  sme('setbutton', 'disable_done, disable_pause')
  sme('forget_final_data')
  
elseif strcmp(p1,'sme_uic_dompop')
  c=allchild(myfig);
  h_pop=findobj(c, 'flat', 'tag', 'sme_uic_dompop');
  domain=popupstr(h_pop);
  %
  h_cb=findobj(allchild(myfig), 'flat', 'tag','sme_uic_transientcb');
  h_trord=[findobj(allchild(myfig), 'flat', 'tag','sme_uic_trordedit');...
      findobj(allchild(myfig), 'flat', 'tag','sme_uic_trordtext')];
  %
  if ~strcmpi(guiinfos('userlevel'),'automatic')
    if any(domain=='sp')
      set([h_cb;h_trord],'visible','on')
      set(h_cb,'enable','on')
      val=get(h_cb,'value');
      if val, set(h_trord,'enable','on'), else set(h_trord,'enable','off'), end
      set(findobj(c, 'tag', 'sme_uic_autoorderpb'),'enable','on')
    elseif domain=='z'
      set(h_cb,'visible','on','enable','on')
      set(h_trord,'visible','on','enable','off')
      set(findobj(c, 'tag', 'sme_uic_autoorderpb'),'enable','off')
    else
      if domain=='r', set([h_cb;h_trord],'visible','off','enable','off'), end  
      set(findobj(c, 'tag', 'sme_uic_autoorderpb'),'enable','off')
    end
    if strcmp(domain,'r') %Richards
      set(findobj(c, 'flat', 'tag','sme_uic_tredit'),'visible','on');
      set(findobj(c, 'flat', 'tag','sme_uic_trtext'),'visible','on');
      set(findobj(c, 'flat', 'tag','sme_uic_trtext2'),'visible','on');
    else
      set(findobj(c, 'flat', 'tag','sme_uic_tredit'),'visible','off');
      set(findobj(c, 'flat', 'tag','sme_uic_trtext'),'visible','off');
      set(findobj(c, 'flat', 'tag','sme_uic_trtext2'),'visible','off');
    end
  end
  if strcmp(domain,'z')
    set(findobj(c, 'flat', 'tag','sme_uic_sectext'),'string','samples'); %earlier: samples
    %
    set(findobj(c, 'flat', 'tag','sme_uic_fsedit'),'visible','on','enable','on');
    set(findobj(c, 'flat', 'tag','sme_uic_fstext'),'visible','on','enable','on');
    set(findobj(c, 'flat', 'tag','sme_uic_fstext2'),'visible','on','enable','on');
    %
    %Adjust fs to frequencies
    inpval=guidtard('fdtool_main', 'OUTPUT_average');
    fv=inpval.freqpoints;
    if iscell(fv), fmax=max(cat(1,fv{:})); else fmax=max(fv); end
    fs=inpval.fs;
    fvset=str2num(get(findall(myfig,'tag','sme_uic_fsedit'),'string'));
    if ~isempty(fs)
      if fvset<fs/100
        fvset=num2str(fs);
        set(findall(myfig,'tag','sme_uic_fsedit'),'string',fvset)
      end        
    elseif (fvset<2.5*fmax)|(fvset>10*fmax)
      fvset=num2str(2.5*fmax);
      set(findall(myfig,'tag','sme_uic_fsedit'),'string',fvset)
    end
    sme('check_edit1', 'sme_uic_fsedit'); % check sampling freq
    %
    set(findobj(c, 'flat', 'tag','sme_uic_raztext'),'visible','off');
    set(findobj(c, 'flat', 'tag','sme_uic_razpop'),'visible','off');
    set(findobj(c, 'flat', 'tag','sme_uic_raztext2'),'visible','off');
    set(findobj(c, 'flat', 'tag','sme_uic_razedit'),'visible','off');  
    
  else %domain not z
    set(findobj(c, 'flat', 'tag','sme_uic_sectext'),'string','s'); %earlier: samples
    set(findobj(c, 'flat', 'tag','sme_uic_fsedit'),'visible','off');
    set(findobj(c, 'flat', 'tag','sme_uic_fstext'),'visible','off');
    set(findobj(c, 'flat', 'tag','sme_uic_fstext2'),'visible','off');
    %
    if ~strcmpi(guiinfos('userlevel'),'automatic')
      set(findobj(c, 'flat', 'tag','sme_uic_raztext'),'visible','on');
      set(findobj(c, 'flat', 'tag','sme_uic_razpop'),'visible','on');
      set(findobj(c, 'flat', 'tag','sme_uic_raztext2'),'visible','on');
      if ~strncmp(popupstr(findobj(c, 'flat', 'tag','sme_uic_razpop')),'no root',6)
        set(findobj(c, 'flat', 'tag','sme_uic_razedit'),'visible','on');
      end
    end
  end;
  
  h_improved=[findobj(c, 'flat', 'tag', 'sme_uic_improvedcb'), ...
      findobj(c, 'flat', 'tag', 'sme_uic_slowertext')];
  if any(domain=='sz') & ~strcmpi(guiinfos('userlevel'), 'automatic')
    set(h_improved, 'enable', 'on')
  else
    set(h_improved, 'enable', 'off','value',0)
  end
  if (nargin<=1) | ~strcmp(p2,'nodelete')
    sme('setbutton', 'disable_done, disable_pause')
    sme('forget_final_data')
  end
  % set autopb's enable property
  %make sure c is OK (there is an error sometimes)
  c=allchild(myfig);
  if findstr('s', domain)%&~strcmpi(guiinfos('userlevel'),'automatic')
    set(findobj(c, 'flat', 'tag','sme_uic_autoorderpb'),'enable','on');
  else
    set(findobj(c, 'flat', 'tag','sme_uic_autoorderpb'),'enable','off');
  end
  sme('status', ['Domain set to ''' domain '''.'])
  inpval=guidtard(Me, 'DATA_INPUT');
  if strcmp(domain,'z')
    if ~strncmp(get(inpval,'inputcharacter'),'ZOH',3)&~strcmpi(get(inpval,'inputcharacter'),'discrete')
      sme('status', ['Warning! z-domain identification from ',get(inpval,'inputcharacter'),' data.'])    
    end
  else %other domains
    if ~strcmp(get(inpval,'inputcharacter'),'BL')&~strcmp(get(inpval,'inputcharacter'),'Samples')
      sme('status', ['Warning! ',domain,'-domain identification from ',get(inpval,'inputcharacter'),' data.'])    
    end
  end
elseif strcmp(p1,'sme_uic_delpop')
  c=allchild(myfig);
  h_pop=findobj(c, 'flat', 'tag','sme_uic_delpop');
  delay=popupstr(h_pop);
  if strcmp(delay,'fixed')
    set(findobj(c, 'flat', 'tag','sme_uic_valuetext'),'string','value:');
  else
    set(findobj(c, 'flat', 'tag','sme_uic_valuetext'),'string','starting value:');
  end;
  if (nargin<=1) | ~strcmp(p2, 'nodelete')
    sme('setbutton', 'disable_done, disable_pause')
    sme('forget_final_data')
  end
  sme('status', ['Delay set to ''' delay '''.'])
  
elseif strcmp(p1,'sme_uic_razpop')
  c=allchild(myfig);
  h_pop=findobj(c, 'flat', 'tag','sme_uic_razpop');
  razstr=popupstr(h_pop);
  if strncmpi(razstr,'no root',6)
    set(findobj(c, 'flat', 'tag','sme_uic_razedit'),'visible','off','string','0');
    set(findobj(c, 'flat', 'tag','sme_uic_raztext2'),'string','at zero');
  else
    set(findobj(c, 'flat', 'tag','sme_uic_razedit'),'visible','on');
    set(findobj(c, 'flat', 'tag','sme_uic_raztext2'),'string','at zero:');
  end;
  sme('setbutton', 'disable_done, disable_pause')
  if (nargin<=1) | ~strcmp(p2, 'nodelete')
    sme('forget_final_data')
  end
  sme('status', ['Fixed root selected as  ''' razstr '''.'])
  
elseif strcmp(p1,'sme_uic_improvedcb')
  c=allchild(myfig);
  h_sender=findobj(allchild(myfig), 'flat', 'tag',sender);
  val=get(h_sender,'value');
  sme('setbutton', 'disable_done, disable_pause')
  if val, msg='on'; else, msg='off'; end
  sme('status', ['Improved numerical stability is ' msg '.'])
  if val
    set(findobj(c, 'flat', 'tag','sme_uic_raztext'),'enable','off');
    set(findobj(c, 'flat', 'tag','sme_uic_razpop'),'enable','off','value',1);
    set(findobj(c, 'flat', 'tag','sme_uic_raztext2'),'enable','off','string','at zero');
    set(findobj(c, 'flat', 'tag','sme_uic_razedit'),'visible','off','string','0');
  else
    set(findobj(c, 'flat', 'tag','sme_uic_raztext'),'enable','on');
    set(findobj(c, 'flat', 'tag','sme_uic_razpop'),'enable','on','value',1);
    set(findobj(c, 'flat', 'tag','sme_uic_raztext2'),'enable','on','string','at zero');
  end
  sme('setbutton', 'disable_done, disable_pause')
  sme('forget_final_data')
  
elseif strcmp(p1,'sme_uic_transientcb')
  h_sender=findobj(allchild(myfig), 'flat', 'tag',sender);
  sme('setbutton', 'disable_done, disable_pause')
  val=get(h_sender,'value');
  if val, msg='on'; else, msg='off'; end
  h_trord=[findobj(allchild(myfig), 'flat', 'tag','sme_uic_trordedit');...
      findobj(allchild(myfig), 'flat', 'tag','sme_uic_trordtext')];
  h_pop=findobj(allchild(myfig), 'flat', 'tag', 'sme_uic_dompop');
  domain=popupstr(h_pop);
  if val&(any(domain=='spw')), set(h_trord,'enable','on')
  else set(h_trord,'enable','off')
  end
  if val&(domain=='z')
    set(h_trord,'visible','on')
    set(h_trord(1),'string','maxord-1')
  end
  sme('status', ['Transient elimination is ' msg '.'])
  sme('setbutton', 'disable_done, disable_pause')
  sme('forget_final_data')
  
elseif strcmp(p1,'sme_uic_autoorderpb')|strcmp(p1,'sme_cmd_autoorderpb')
  h=[];
  h(1)=findobj(allchild(myfig), 'flat', 'tag', 'sme_uic_onedit');
  h(2)=findobj(allchild(myfig), 'flat', 'tag', 'sme_uic_odedit');
  as=0;
  if nargin<3, p3=''; end
  if (nargin>=3)&~isempty(p3)
    if iscams(myfig)&(strcmp(p3,'auto')|strcmp(p3,'autoscan'))
      set(h,'string', p3)
      if strcmp(p3,'auto'), as=0; else as=1; end
    elseif ~iscams(myfig)&strcmp(p3,'auto')
      set(h,'string', p3)
      as=0;
    end
  else
    if (length(strmatch('auto',get(h,'string'),'exact'))==2)&iscams(myfig)
      as=1;
      set(h,'string', 'autoscan')
    else
      as=0;
      set(h,'string', 'auto')
    end
  end
  if iscams(myfig)
    if ~as
      sme('status', ['#cAutomatic order selection is on. ',...
          'Press ''Auto'' once more to retain all the reasonable estimated models.'])
    else
      sme('status', ['#cAutomatic order selection is on. ',...
          'All estimated models between verified and loose models will be retained.'])
    end
  else
    sme('status', ['Automatic order selection is on.'])
  end
  sme('setbutton', 'disable_done, disable_pause')
  if strcmp(Me,'aided_main');
    sme('in_axes')
  end
  sme('forget_final_data')
  
elseif strcmp(p1,'sme_uic_complexcb')
  h_sender=findobj(allchild(myfig), 'flat', 'tag',sender);
  val=get(h_sender,'value');
  sme('setbutton', 'disable_done, disable_pause')
  if val, msg='complex'; else, msg='real'; end
  sme('status', ['Coefficients are ' msg '.'])
  sme('setbutton', 'disable_done, disable_pause')
  sme('forget_final_data')
  
elseif strcmp(p1,'sme_uic_startpb')
  c=allchild(myfig);
  hdomain=findobj(c, 'flat','tag','sme_uic_dompop');
  dom_val=get(hdomain,'value');
  dom_str=get(hdomain,'string');
  domain=dom_str{dom_val};  
  hnumer=findobj(c, 'flat','tag','sme_uic_onedit');
  hdenom=findobj(c, 'flat','tag','sme_uic_odedit');
  if ~(domain=='s')&(strncmpi(get(hnumer,'string'),'auto',4)|strncmpi(get(hdenom,'string'),'auto',4))
    %if strcmp(guiinfos('userlevel'),'Automatic')
    %  sme('status',['Error: Automatic order estimation is not yet implemented for ',...
    %      domain,'-domain. Increase UserLevel in the menu of the main window.'])
		%else
      sme('status',['Error: Automatic order estimation is not yet implemented for ',...
          domain,'-domain. Please set the orders manually.'])
		%end
    return
  end
  if any(findstr(domain, 'z')) & sme('check_edit1', 'sme_uic_fsedit') % sampling freq too small
    return
  else
    sme('status', ['Please wait... '])
  end
  %sme('update_plot')
  %This is the deletion of the plotted model and the error:
  if ~iscams(myfig)
    delete(findall(myfig,'tag','modelplot'))
    delete(findall(myfig,'tag','errorplot'))
    %set(findall(myfig,'tag','sme_axes_ax'),'ylimmode','auto')
    pause(0)
  end
  
  inpval=guidtard(Me, 'DATA_INPUT');
  if strcmp(domain,'z')
    if ~strncmp(get(inpval,'inputcharacter'),'ZOH',3)&~strcmpi(get(inpval,'inputcharacter'),'discrete')
      sme('status', ['Warning! z-domain fit for ',get(inpval,'inputcharacter'),' data.'])    
    end
  else %other domains
    if ~strcmp(get(inpval,'inputcharacter'),'BL')&~strcmp(get(inpval,'inputcharacter'),'Samples')
      sme('status', ['Warning! ',domain,'-domain fit for ',get(inpval,'inputcharacter'),' data.'])    
    end
  end
  
  inp_numord=str2num(get(hnumer,'string')); if isempty(inp_numord), inp_numord=NaN; end
  inp_denomord=str2num(get(hdenom,'string')); if isempty(inp_denomord), inp_denomord=NaN; end
  if (any(isnan(inp_numord))&any(isfinite(inp_denomord)))|...
      (any(isfinite(inp_numord))&any(isnan(inp_denomord)))
    if strncmpi(get(hnumer,'string'),'auto',4)|strncmpi(get(hdenom,'string'),'auto',4)
      sme('status','Error: automatic order selection only works for both num and den')
      error('Automatic order selection only works for both num and den')
    else
      sme('status','Error: invalid order setting')
      error('Invalid order setting')
    end
  elseif strcmpi(get(hnumer,'string'),'auto')&strcmpi(get(hdenom,'string'),'auto')
    autoset=1;
  elseif strcmpi(get(hnumer,'string'),'autoscan')&strcmpi(get(hdenom,'string'),'autoscan')
    autoset=2;
  elseif all(isfinite(inp_numord))&all(isfinite(inp_denomord))
    autoset=0;
  else 
    autoset=-1;
  end
  
  htreat=findobj(c, 'flat','tag','sme_uic_delpop');
  treat=get(htreat,'value');
  hfs=findobj(c, 'flat','tag','sme_uic_fsedit');
  fs=str2num(get(hfs,'string'));
  if ~strcmp(domain,'z'), fs=nan; end
  htauR=findobj(c, 'flat','tag','sme_uic_tredit');
  tauR=str2num(get(htauR,'string'));
  if treat==1 %fixed
    delaytreat='f';
  else
    delaytreat='v';
  end
  hdelay=findobj(c, 'flat','tag','sme_uic_deledit');
  delay=str2num(get(hdelay, 'string'));
  htranselim=findobj(c, 'flat','tag','sme_uic_transientcb');
  transelim=0;
  if strcmp(get(htranselim,'enable'),'on'), transelim=get(htranselim, 'value'); end
  hcmplxc=findobj(c, 'flat','tag','sme_uic_complexcb');
  cmplxc=get(hcmplxc, 'value');
  
  hnumstab=findobj(c, 'flat','tag','sme_uic_improvedcb');
  numstab=get(hnumstab, 'value');
  if numstab
    if strcmp(domain,'s'), domain = 'p'; 
    elseif strcmp(domain,'z'), domain = 'q'; 
    end
  end
  if autoset
    sme('setbutton', 'disable_done')
    stck=dbstack; auo=0;
    for ix=1:length(stck);
      if any(findstr(stck(ix).name, 'autoorder')), auo=1; end
    end
    if ~auo, set(findobj(c, 'tag', 'sme_mod_abortpb'),'enable','on'), end
  else
    sme('setbutton', 'disable_done, enable_pause')
  end
  %
  plotdenstime=3; plotdensoffs=1;
  NaNv=NaN;
  if ~iscams(myfig)
    results=''; % forget done results
  else
    results=guidtard(Me, 'FINAL_DATA');
  end
  success_ct=length(results);
  
  hax = findobj(c, 'flat', 'Tag', 'sme_axes_ax');
  
  h_pop=findobj(c, 'flat', 'tag','sme_uic_razpop');
  razstr=popupstr(h_pop);
  ElisParams=GetElisParams(myfig);
  if autoset
    if any(domain=='wr')
      sme('status',['Error: automatic order setting is not possible for ',domain,'-domain'])
      sme('setbutton','disable_pause')
      return
      error(['Automatic order setting is not possible for ',domain,'-domain']')
    elseif delaytreat=='v'
      sme('status','Error: automatic order setting is not possible for variable delay')
      sme('setbutton','disable_pause')
      return
      error('Automatic order setting is not possible for variable delay')
    elseif length(delay)>1
      sme('status','Error: automatic order setting is not possible for several delays')
      sme('setbutton','disable_pause')
      return
      error('Automatic order setting is not possible for several delays')
    elseif strncmp(razstr,'pole',4)|strncmp(razstr,'zero',4)
      sme('status','Error: automatic order setting is not possible with parameter fixing')
      sme('setbutton','disable_pause')
      return
      error('Automatic order setting is not possible with parameter fixing')
    elseif transelim
      sme('status','Error: automatic order setting is not possible with transients')
      sme('setbutton','disable_pause')
      return
      error('Automatic order setting is not possible with transients')
    elseif cmplxc
      sme('status','Error: automatic order setting is not possible for complex coefficients')
      sme('setbutton','disable_pause')
      return
      error('Automatic order setting is not possible for complex coefficients')
    elseif ~isempty(ElisParams)&~isequal(ElisParams,defelpar('default'))
      sme('status','Error: automatic order setting is not possible with changed elis parameters')
      sme('setbutton','disable_pause')
      return
      error('Automatic order setting is not possible with changed elis parameters')
    elseif any(domain=='zq')
      if ~guiinfos('isdevelopment')
        sme('status','Error: automatic order setting is not yet ready for z-domain')
        sme('setbutton','disable_pause')
        return
      else
        warning('automatic order setting is not yet ready for z-domain')
      end
    end
  end 
  
  showplot=get(findobj(c, 'flat','tag','sme_uic_showcb'),'value');
  helis=findall(0, 'tag', 'elis_window');
  %if ~isempty(helis)&~showplot, delete(helis), helis=[]; end %bypass bug
  if isempty(helis)
    [pos,units]=getfpos;
    helis=figure('Units',units, 'position',pos,...
      'name', 'ELiS Run Info','Tag', 'elis_window',...
      'numbertitle','off');
    if ~strncmp('5.2',version,3), set(helis,'toolbar','none'); end
    fdwindef(helis);   
  else
    delete([findobj(helis,'type','axes'); findobj(helis,'type','uicontrol')]), drawnow
  end
  hit=[findall(helis,'label','&Iteration');findall(helis,'label','Iteration')];
  if isempty(hit), iterctrl('Initialize',helis); end
  iterctrl('Continue',helis);
  if showplot, set(helis,'visible','on'), haoFig=helis;
  else set(helis,'visible','off'), haoFig=0;
  end
  
  if autoset
    sme('status','#cAutomatic order selection is being performed ...')
    set(hnumstab, 'value',1) %orthopol is selected
    %if delay %delay is not zero
    %  if any(domain=='sp'), inpval.inputdelay=delay;
    %  elseif any(domain=='z'), inpval.inputdelay=delay/fs;
    %   end
    %end
      %
    h1=findobj(c,'flat', 'tag','sme_uic_linloghpop');
    linlogvar=get(h1,'value');
    if isequal(linlogvar,2)
      plotfreq='logarithmic';
    else
      plotfreq='linear';
    end
    %
    global use_autoorder_results
    if isempty(use_autoorder_results)
      %regular run
      aorunmod=struct('plotfreq',plotfreq);
      if autoset==1
      else %2
        aorunmod.mode='all';
      end
      aorunmod.delay=delay;
      if guiinfos('islinear'), errorweighting='Linear';
      elseif ~guiinfos('islinear'), errorweighting='Nonlinear';
      end
      aorunmod.errorweighting=errorweighting;
      if (strncmpi(errorweighting,'Linear',3)&isempty(inpval.outputvariance))
        sme('status','Error: variances are not given for automatic order selection')
        return
      elseif (any(findstr(errorweighting,'onlinear'))&isempty(inpval.OutputNonlinVariance))
        sme('status','Error: nonlinear variances are not given for automatic order selection')
        return
      end
      results=autoorder(inpval,domain,haoFig,aorunmod);
      if isempty(results)
        out=[];
        sme('status','Error: Run aborted.')
        %disp('Run aborted in sme...')
        return
      end
    else %quick run only for testing the environment (GUI, etc.)
      global use_autoorder_results_q
      if any(domain=='sp')
        results=use_autoorder_results;
      else
        results=use_autoorder_results_q;
      end
      if (autoset==1)&(length(results)>=3), results=results([1,3]); end
      if ~iscell(results), results={results}; end
      m=results{1};
      if guiinfos('islinear'), errorweighting='Linear';
      elseif ~guiinfos('islinear'), errorweighting='Nonlinear';
      end
      runmod=struct('itmax',0,'initset','object','plotfreq',plotfreq);
      runmod.errorweighting=errorweighting;
      elis(m,runmod,struct('displaymessages','off'));
      results{1}.note='Model is the verified result of the Automatic Model Selection.';
      if length(results)>=2,
        results{2}.note='Model is the not verified (lower order) result of the Automatic Model Selection';
      end
    end
    %Now results is an fidmodel object or an 1x2 or 1xK cell vector of fidmodel objects
    %
    if isa(results,'fidmodel'), results={results}; end
    if iscams(myfig)
      numord1=length(results{1}.num)-1;
      denomord1=length(results{1}.denom)-1;
      if length(results)==1
        numord2=numord1;
        denomord2=denomord1;
      else
        numord2=length(results{2}.num)-1;
        denomord2=length(results{2}.denom)-1;
      end
      nmin=min(numord1,numord2); nmax=max(numord1,numord2); 
      if nmax>nmin
        set(hnumer,'string',sprintf('[%.0f:%.0f]',nmin,nmax));
      else
        set(hnumer,'string',sprintf('%.0f',nmax));
      end
      dmin=min(denomord1,denomord2); dmax=max(denomord1,denomord2);
      if dmax>dmin
        set(hdenom,'string',sprintf('[%.0f:%.0f]',dmin,dmax));
      else
        set(hdenom,'string',sprintf('%.0f',dmax));
      end
      sm={};
      for ii=1:length(results)
        rii=results{ii};
        sm=[sm,{[length(rii.denom)-1,length(rii.num)-1]}];
      end
      guidtawr(Me,'SELECTED_MODELS','direct',sm);
      guidtawr(Me,'DONE_MODELS','direct',results);
      sme('in_axes')
      guidtawr(Me, 'FINAL_DATA', 'direct', results);
      sme('update_plot')
      %axes manipulation
      if length(results)>1
        h = findobj(allchild(findall(0, 'tag','aided_main')), 'flat', 'Tag', 'sme_axes_ax');
        hloos=findall(h,'Marker','.');
        for ii=1:length(hloos)
          nii=get(hloos(ii),'ydata'); dii=get(hloos(ii),'xdata');
          if ~isequal(dii,denomord1)|~isequal(nii,numord1)
            set(hloos(ii),'color',[0.55,1,0.55])
            %disp(sprintf('Model %.0f/%.0f is set light green\n',nii,dii))
          end
        end
      end
    else %EPM
      %write in the results
      numord=length(results{1}.num)-1;
      set(hnumer,'string',num2str(numord));
      denomord=length(results{1}.denom)-1;
      set(hdenom,'string',num2str(denomord));
      guidtawr(Me, 'FINAL_DATA', 'direct', results);
      sme('update_plot')
    end %CAMS/SME
  else %Regular estimate
		set(helis,'name','ELiS Run Info','Tag','elis_window');
    if iscams(myfig)
      orders = iter_orders(Me);
    else
      orders={[inp_denomord, inp_numord]};
    end
    
    delayv=delay; %vector of delays
    for iterct=1:length(orders)
      denomord=orders{iterct}(1);
      numord=orders{iterct}(2);
      if transelim
        maxord=max(numord,denomord);
        if domain=='z', inp_trnumord=maxord-1;
        else
          htrord=findobj(c, 'flat','tag','sme_uic_trordedit');
          inp_trnumordstr=get(htrord,'string');
          if any(findstr('maxord',inp_trnumordstr)), eval(['inp_trnumord=',inp_trnumordstr,';']);
          else inp_trnumord=str2num(inp_trnumordstr);
          end
        end
      else
        inp_trnumord='';
      end
      
      if iscams(myfig)
        curr_ax=findobj(myfig, 'tag', 'sme_axes_ax');
        %xlim=get(curr_ax,'xlim'); ylim=get(curr_ax,'ylim');
        hrun=plot(denomord,numord,'.r','markersize',24,'parent',curr_ax);
        %set(curr_ax,'xlim',xlim,'ylim',ylim)
        pause(0), drawnow
      end
      %
      %delay cycle 
      for delay=delayv(:)'
        %              
        msgstr=['#dIterating... Model: ', num2str(numord), '/', num2str(denomord), ' (', domain, ')'];
        if length(delayv)>1, msgstr=[msgstr,sprintf(', starting delay: %.3g',delay)]; end
        sme('status', msgstr)
        ulevel=guiinfos('userlevel');
        if strcmp(lower(ulevel),'automatic'), plotlevel='b'+0;
        else plotlevel=NaN;
        end
        Ne=numord+denomord+1+(delaytreat=='v');
        if isa(inpval,'iddat')
          fv=inpval.inputfreqpoints;
          if iscell(fv), fv=cat(1,fv{:}); end
        else
          fv=impfou(inpval);
        end
        fv=sort(fv); ind=find(diff([fv;inf])==0);
        if ~isempty(ind), fv(ind)=[]; end
        if min(fv)==0, eqnN=2*length(fv)-1; else eqnN=2*length(fv); end  
        if Ne>eqnN
          sme('status','Error: not enough frequencies')
          disp('Error: not enough frequencies')
          return
        end
        h1=findobj(c,'flat', 'tag','sme_uic_linloghpop');
        if ~isempty(h1)
          linlogvar=get(h1,'value');
          if linlogvar==2, fscale='o'; else fscale='i'; end
        else 
          fscale=NaN;
        end
        %
        showplot=get(findobj(c, 'flat','tag','sme_uic_showcb'),'value');
        if showplot 
          plotdens=NaN; 
        else
          plotdens=inf; 
        end
        
        % vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
        %Fix poles/zeros at zero position:
        fixp=delaytreat; fixpobj=[];
        h_edit=findobj(c, 'flat', 'tag','sme_uic_razedit');
        if strcmp(get(h_edit,'visible'),'on')
          h_pop=findobj(c, 'flat', 'tag','sme_uic_razpop');
          razstr=popupstr(h_pop);
          if strncmpi(razstr,'pole',4)|strncmpi(razstr,'zero',4)
            NaNv=NaN;
            fixpobj=fidmodel(domain,NaNv(ones(1,numord+1)),NaNv(ones(1,denomord+1)));
            if strcmp(fixp,'f'), fixp=[numord+denomord+3,delay];
            elseif strcmp(fixp,'v'), fixp=[];
            else error('Invalid delaytreat')
            end
            razno=str2num(get(h_edit,'string'));
            if strncmpi(razstr,'pole',4)
              if razno>denomord
                sme('status','Error: cannot set that many poles to zero')
                close
                return
              end
              offs=numord+denomord+2;
              fixpobj.denom=[NaNv(ones(1,denomord+1-razno)),zeros(1,razno)];
            else
              if razno>numord
                sme('status','Error: cannot set that many zeros to zero')
                close
                return
              end
              offs=numord+1;
              fixpobj.num=[NaNv(ones(1,numord+1-razno)),zeros(1,razno)];
            end
            for ii=razno-1:-1:0
              fixp=[offs-ii,0;fixp];
            end
          end
        end
        if isempty(fixp), fixp='v'; end
        delete(findall(helis,'tag','helis_poles/zeros'))
        runmod=struct('fs',fs,'algorithm','LM',...
          'lambdadecrease',1,'plotdens',plotdens,...
          'plotdenstime',plotdenstime,'delay',delay,'delaytreat',delaytreat);
        if transelim, runmod.transients='on'; end
        if ~isnan(cmplxc)&isequal(cmplxc,1), runmod.coefficients='complex'; end
        if ~isnan(fscale)&strcmp(setstr(fscale),'o'), runmod.plotfreq='logarithmic'; end
        if ~isnan(plotlevel)&strcmp(setstr(plotlevel),'b'), runmod.plotlevel='basic'; end
        if ~isempty(fixpobj), runmod.fixedpars=fixpobj; end
        if strcmp(domain,'r'), runmod.tauR=tauR; end
        if ~isempty(inp_trnumord), runmod.trnumord=inp_trnumord; end
        %
        iterparams=GetElisParams(myfig); %additional run parameters
        addrunmod=defelpar('runmod',iterparams);
        devrunmod=[];
        if isstruct(addrunmod)
          fn=fieldnames(addrunmod);
          for ii=1:length(fn)
            if ~strcmp(fn{ii},'selectedmargin')
              runmod=setfield(runmod,fn{ii},getfield(addrunmod,fn{ii}));
            else
              runmod=setfield(runmod,'stablimit',getfield(addrunmod,fn{ii}));
            end
          end %for ii
        end
        if guiinfos('isrecorderplayback') & guirecrd('gettestmode')==2 &...
            ~isequal(guirecrd('GetTestPlotMode'),1) %lecserélni???
        %if (guirecrd('callback', 'recorder_isrecorderplayback', 'guirecrd_fdtool') &...
        %    guirecrd('callback', 'recorder_gettestmode', 'guirecrd_fdtool') == 2 &...
        %    ~isequal(guirecrd('callback', 'recorder_gettestplotmode', 'guirecrd_fdtool'), 1))
          itmax=3; %quick execution
          global sme_itmax %itmax modified?
          if (length(sme_itmax)==1)&(sme_itmax>itmax)
            itmax=sme_itmax;
          end
          clear global sme_itmax
          runmod.itmax=itmax;
        end
        %
        if guiinfos('islinear'), runmod.errorweighting='Linear';
        elseif ~isempty(get(inpval,'EvenOutputNonlinError'))
          runmod.errorweighting='Interpolated nonlinear';
        else
          runmod.errorweighting='Nonlinear';
        end
        if isfield(runmod,'initset')
          if strcmp(runmod.initset,'object')
            im=runmod.initmodel;
            if domain=='p', domtrue='s'; elseif domain=='q', domtrue='z'; else domtrue=domain; end
            if ~strncmp(domtrue,im.variable,1)
              sme('setbutton','disable_pause')
              sme('status','Error: domain is inconsistent with initial object')
              delete(helis), return
            elseif strcmp(domtrue,'z')&~isequal(runmod.fs,im.fs)
              sme('setbutton','disable_pause')
              sme('status','Error: sampling frequency is inconsistent with initial object')
              delete(helis), return
            elseif ~isequal(numord,length(im.num)-1)
              sme('setbutton','disable_pause')
              sme('status','Error: numerator order is inconsistent with initial object')
              delete(helis), return
            elseif ~isequal(denomord,length(im.denom)-1)
              sme('setbutton','disable_pause')
              sme('status','Error: denominator order is inconsistent with initial object')
              delete(helis), return
            elseif isfield(runmod,'representation')
              if ~strcmp(im.representation,runmod.representation)
                sme('setbutton','disable_pause')
                sme('status','Error: representation is inconsistent with initial object')
                delete(helis), return
              end
            end
          end
        end
        %
				lasterr('');
				devrunmod.displaymessages='off';
        try, pvect=elis(inpval,domain,numord,denomord,runmod,devrunmod); ok=1;
        catch, pvect=[]; ok=0;
        end
        %
        dismispb(get(helis,'tag')); 
        if ok==1
          if fdtool(['l','ic'])>1
            %Poles/zeros menu
            menu_pz=uimenu(helis,'label','&Poles/zeros',...
              'tag', 'helis_poles/zeros'); 
            pvectr=pvect; 
            %if ~strcmp(pvectr.representation,'orthopol'), pvectr.data=[]; end 
            %pvectr.covariance=[];
            pvectr.data=[];
            menu_pz_list=uimenu(menu_pz,'label','&List',...
              'callback',['info(',...
                'get(findall(0,''tag'',''helis_poles/zeros_list''),',...
                '''userdata''),''Poles and zeros'')'],...
              'userdata',pvectr,...
              'tag', 'helis_poles/zeros_list');
            %'callback',['fdtool(''callback'',''garrinfo'',1001,',...
            %  'get(findall(0,''tag'',''helis_poles/zeros_list''),',...
            %  '''userdata''),''Information on the estimated model'')'],...
            pause(0) %update plots
          end
          %simulate zoom:
          if ishandle(helis) 
            set(helis,'WindowButtonDownFcn','zoom down','WindowButtonUpFcn','ones;')
          end
        elseif ~any(findstr('Abort requested through GUI',lasterr))
          if isempty(lasterr), lel='unknown origin'; else lel=lasterr; end
          le=lel;
          if size(le,1)>1, le=le(2,:); end, le=le(:)';
          ind=[find(le==setstr(10)),find(le==setstr(13))];
          while ~isempty(ind)&(max(ind)==length(le))
            ind=sort(ind); ind(end)=''; le(end)='';
          end
          if length(ind)>=2 
            if any(findstr(le(ind(1):ind(2)),'obsolete'))|...
                any(findstr(le(ind(1):ind(2)),'distributor'))
              le=le(ind(1)+1:ind(2)-1); %this type of message requires the second line
              ind=[];
            end
          end
          if ~isempty(ind)
            le=le(ind(end)+1:end);
          end
          sme('setbutton','disable_pause')
          sme('status',['#relis error: ',le])
          disp(['elis error: ',lel])
          return
        end
        % check if cancel requested 
        if ~isempty(guidtard(Me, 'cancelrequest'))
          sme('sme_mod_cancelpb')
          return
        end
        if isempty(pvect)
          sme('status', 'ELiS run cancelled.')
        else
          success_ct=success_ct+1;
          results{success_ct}=pvect;
          guidtawr(Me, 'FINAL_DATA', 'direct', results); %saving results and prepare update plot
        end
        if ok==0; 
          %results=[]; 
          break
        end
        %
        %End of delay cycle
      end %for delay
      %
      if iscams(myfig)
        if ishandle(hrun), delete(hrun), end
      end
      if ok==0; 
        %results=[]; 
        break
      end
      if isempty(pvect)
        sme('status', 'ELiS run cancelled.')
      else
        sme('update_plot')
      end
    end % for iterct=1:length(orders)
    guidtawr(Me, 'FINAL_DATA', 'direct', results);
    sme('update_plot')
  end %autoorder / regular estimate
  
  if ~isempty(results)
    sme('setbutton', 'enable_done, disable_pause')
    if autoset&(length(results)==2)
      if iscams(myfig)
        sme('status','#yOrders have been determined.')
      else
        sme('status',sprintf(['#yOrders have been determined. Lower (not verified) orders ',...
            'which you may also try: %.0f/%.0f.'],...
          length(results{2}.num)-1,length(results{2}.denom)-1))
      end
    else
        sme('status',['#gELiS run finished. Close this block, and ',...
                'open the next one for more information'])
        if strcmp(lower(guiinfos('userlevel')),'automatic')
            %sme('sme_cmd_donepb')
            %fdtool('click_on_compare','rect_compare')
        end

    end
  else
    if length(orders)<1
      sme('status', ['Warning: No model orders chosen. ',...
          'Select models on the figure then press Start.'])
    else
      sme('status', 'No model returned by ELiS.')
    end
    sme('setbutton', 'disable_done, disable_pause')
  end
  
elseif strcmp(p1,'setbutton')
  ch=get(myfig,'children');
  h=[findobj(ch,'tag','sme_uic_donepb'), ...
      findobj(ch,'tag','sme_mod_pausepb'),...
      findobj(ch,'tag','sme_mod_finishpb'),...
      findobj(ch,'tag','sme_mod_skippb'),...
      findobj(ch,'tag','sme_mod_abortpb'),...
      findobj(ch,'tag','sme_uic_startpb'), ...
      findobj(ch,'tag',[myname '_menu_file_close']),...
      findobj(ch,'tag','sme_uic_collectpb'),...
      findobj(ch,'tag','select_menu_file_save_model')];
  h1789=[findobj(ch,'tag','sme_uic_donepb'), ...
      findobj(ch,'tag',[myname '_menu_file_close']),...
      findobj(ch,'tag','sme_uic_collectpb'),...
      findobj(ch,'tag','select_menu_help_model'), ...
      findobj(ch,'tag','select_menu_help_advice'), ...
      findobj(ch,'tag','aided_menu_help_model'), ...
      findobj(ch,'tag','select_menu_file_save_model')];
  h6=[findobj(ch,'tag','sme_uic_startpb'),...
      findobj(ch,'tag','sme_MENU_runmod')];
  h25=[findobj(ch,'tag','sme_mod_pausepb'),...
      findobj(ch,'tag','sme_mod_skippb'),...
      findobj(ch,'tag','sme_mod_abortpb'),...
      findobj(ch,'tag','sme_mod_finishpb')];
  
  if any(findstr(p2, 'enable_done'))
    set(h1789, 'enable', 'on');
  elseif any(findstr(p2, 'disable_done'))
    final=guidtard(Me, 'FINAL_DATA');
    if ~iscams(myfig) | isempty(final)
      set(h1789, 'enable', 'off');
    end
  end
  if any(findstr(p2, 'enable_pause'))
    set(h25, 'enable', 'on');
    set(h6, 'enable', 'off');
  elseif any(findstr(p2, 'disable_pause'))
    set(h25, 'enable', 'off');
    set(h6, 'enable', 'on');
  end
  
  
elseif strcmp(p1,'update_plot')
  sme('status', 'Please wait, updating plot...')
  if ~iscams(myfig) % sme case     
    fd=guidtard('select_main', 'FINAL_DATA'); if iscell(fd)&(length(fd)>=1), fd=fd{1}; end
    if isa(fd,'fidmodel')
      if (~guiinfos('islinear')&~any(findstr('onlin',fd.errorweighting)))|...
          (guiinfos('islinear')&any(findstr('Nonlin',fd.errorweighting)))
        %delete if inconsistent with toolbox setting
        guidtawr('select_main', 'FINAL_DATA','direct',{});
      end
    end
    arrplot('sme_update')
    sme('status', 'Done.')
  else %cams
    curr_ax=findobj(myfig, 'tag', 'sme_axes_ax');
    model_range = guidtard(Me,'MODEL_RANGE');
    
    set(curr_ax, 'nextplot', 'replacechildren')
    xmin=inf; xmax=0; ymin=inf; ymax=0;
    for i  = 1:length(model_range)
      if i>1; set(curr_ax, 'nextplot', 'add'); end
      mod = model_range{i};
      x   = mod(1);
      y   = mod(2);
      plot(x, y, 'xb', 'parent', curr_ax);
      xmin=min(x,xmin); xmax=max(x,xmax); ymin=min(y,ymin); ymax=max(y,ymax);
    end;
    
    set(curr_ax, 'nextplot', 'add')
    selected_models = guidtard(Me,'SELECTED_MODELS');
    for i  = 1:length(selected_models)
      mod = selected_models{i};
      x   = mod(1);
      y   = mod(2);
      plot(x, y, 'or', 'markersize',5.5,'parent', curr_ax); %5.5: make sure green point covers
    end;
    done_models = guidtard(Me,'FINAL_DATA');
    for i  = 1:length(done_models)
      mod = done_models{i};
      x   = length(mod.denom)-1;
      y   = length(mod.num)-1;
      plot(x, y, '.g', 'parent', curr_ax, 'markersize', 24);
    end;
    hx=get(curr_ax,'xlabel'); set(hx,'string','denom','verticalalignment','middle')
    hy=get(curr_ax,'ylabel'); set(hy,'string','num')
    set(curr_ax,'ylim',[ymin-0.49,ymax+0.49])
    set(curr_ax,'xlim',[xmin-0.49,xmax+0.49])
    %
    %Eliminate fractional labels
    set(curr_ax,'xticklabelmode','auto','xtickmode','auto')
    xtl=get(curr_ax,'xticklabel'); xtm=get(curr_ax,'xtick');
    xtls=size(xtl,2);
    for xii=size(xtl,1):-1:1
      %if any(xtl{xii,:}=='.')
      %  xtl(xii,:)=''; xtm(xii)=[];
      %end
      if iscell(xtl)&any(xtl{xii,:}=='.'), xtl(xii,:)=''; xtm(xii)=[];
      elseif ischar(xtl)&any(xtl(xii,:)=='.'), xtl(xii,:)=''; xtm(xii)=[];
      end
    end %for xii
    set(curr_ax,'xticklabel',xtl,'xtick',xtm)
    %
    set(curr_ax,'yticklabelmode','auto','ytickmode','auto')
    ytl=get(curr_ax,'yticklabel'); ytm=get(curr_ax,'ytick');
    ytls=size(ytl,2);
    for yii=size(ytl,1):-1:1
      %if any(ytl{yii,:}=='.')
      %  ytl(yii,:)=''; ytm(yii)=[];
      %end
      if iscell(ytl)&any(ytl{yii,:}=='.'), ytl(yii,:)=''; ytm(yii)=[];
      elseif ischar(ytl)&any(ytl(yii,:)=='.'), ytl(yii,:)=''; ytm(yii)=[];
      end
    end %for yii
    set(curr_ax,'yticklabel',ytl,'ytick',ytm)
  end %iscams
  sme('status', 'Plot update ready')
  
elseif strcmp(p1,'sme_mod_pausepb')
  sme_mod_pausepb=findobj(allchild(myfig), 'flat','tag','sme_mod_pausepb');
  str = get(sme_mod_pausepb,'string'); 
  if ( str(1:5) == 'Pause')
    set(sme_mod_pausepb,'String','Continue');
    %    helis='';
    %    while isempty(helis), helis=findall(0, 'tag', 'elis_window');...
    %      eval('iterctrl(''Pause'',helis);','helis=[]'), pause(0), end
    helis=findall(0, 'tag', 'elis_window');
    iterctrl('Pause',helis);
  else
    set(sme_mod_pausepb,'String','Pause');
    %     helis='';
    %     while isempty(helis), helis=findall(0, 'tag', 'elis_window');...
    %       eval('iterctrl(''Continue'',helis);','helis=[]'), pause(0), end
    helis=findall(0, 'tag', 'elis_window');
    iterctrl('Continue',helis);
  end;
  
  
elseif strcmp(p1,'sme_mod_finishpb')
  %helis='';
  %          while isempty(helis), helis=findall(0, 'tag', 'elis_window');...
  %            eval('iterctrl(''Finish'',helis);','helis=[]'), pause(0), end
  helis=findall(0, 'tag', 'elis_window');
  iterctrl('Finish',helis);
  sme('status', 'Please wait, iteration is being finished...')
  
elseif strcmp(p1,'sme_mod_skippb')
  helis=findall(0, 'tag', 'elis_window');
  iterctrl('Cancel',helis);
  sme('status', 'Current model skipped.')
  
elseif strcmp(p1,'sme_mod_abortpb')
  helis=findall(0, 'type','figure','tag', 'elis_window');
  if isempty(helis)
    %error('elis window not found')
  end
  iterctrl('Abort',helis);
  drawnow
  
elseif strcmp(p1,'ui_edit')|strcmp(p1,'check_edit1') % checks and corrects editbox input values
  sme('status', 'Checking input data consistency...')
  h_edit=findobj(allchild(myfig), 'flat', 'tag',sender);
  editstr=get(h_edit,'string');
  corrected=0;
  errorstatus=0;
  if any(findstr(sender,'trord'))
    c=allchild(myfig);
    h_nord=findobj(c, 'flat', 'tag', 'sme_uic_onedit');
    numord=str2num(get(h_nord,'String'));
    h_dord=findobj(c, 'flat', 'tag', 'sme_uic_odedit');
    denomord=str2num(get(h_dord,'String'));
    maxord=max(numord,denomord);
    if any(findstr('maxord',editstr))
      eval(['editnum=',editstr,';']); 
    else
      editnum=str2num(editstr);
    end  
  else
    editnum=str2num(editstr);
    if isempty(editnum)  
      editnum=0; corrected=1;
    end
  end
  
  switch sender
  case {'sme_uic_onedit', 'sme_uic_odedit'} % order of numerator or denominator
    % order is non-negative integer
    if any(editnum < 0)
      editnum=abs(editnum); corrected=1;
    end
    if any(findstr(sender, 'onedit'))
      name='Order of numerator';
    else
      name='Order of denominator';
    end
    editnum_new=abs(floor(editnum));
    if ~iscams(myfig) % sme case: one integer
      editnum_new=editnum_new(1,1);
    else
      sorted=sort(editnum_new);
      if any(~diff(sorted))  % same values appear
        editnum_new=sorted([1 1+find(diff(sort(editnum_new))~= 0)]);
        corrected=1;
      end
    end
  case 'sme_uic_trordedit' % order of transient numerator
    % order is non-negative integer
    if any(editnum < 0)
      editnum=abs(editnum); corrected=1;
    end
    name='Order of transient numerator';
    if ~isempty(editnum)&~iscams(myfig) % sme case: one integer
      c=allchild(myfig);
      h_dom=findobj(c, 'flat', 'tag', 'sme_uic_dompop');
      domain=popupstr(h_dom);
      h_dord=findobj(c, 'flat', 'tag', 'sme_uic_odedit');
      denomord=abs(str2num(get(h_dord,'String')));
      h_nord=findobj(c, 'flat', 'tag', 'sme_uic_onedit');
      numord=abs(str2num(get(h_nord,'String')));
      maxord=max(numord,denomord);
      if any(domain=='sp')
        if editnum<denomord-1, editnum=maxord-1; corrected=1; end
      end
    end
    if ~isempty(editnum)
      editnum_new=abs(floor(editnum));
      if ~iscams(myfig) % sme case: one integer
        editnum_new=editnum_new(1,1);
      end
    end
  case 'sme_uic_deledit' % delay
    name='Delay';
    %
    %allow also vectors
    %editnum_new=editnum(1,1);
    if sum(size(editnum)~=1)>1, editnum_new=editnum(1,:); corrected=1;
    else editnum_new=editnum; 
    end
    %
    h=findobj(allchild(myfig), 'flat', 'tag', 'sme_uic_dompop');
    domain=popupstr(h);
    % integer legyen ???? Ha igen, akkor a  dompop-ban hivas kell ide !
    %if strcmp(domain, 'z')
    %   editnum_new=floor(editnum_new);
    %end
  case 'sme_uic_razedit' % delay
    name='Fixedroots';
    editnum_new=editnum(1,1);
    if any(editnum_new < 0)
      editnum_new=0; corrected=1;
    elseif any(rem(editnum_new,1)~=0)
      editnum_new=round(editnum_new); corrected=1;
    end
  case 'sme_uic_tredit' % tauR
    name='tauR';
    editnum_new=editnum(1,1);
    if any(editnum_new <= 0)
      editnum_new=1; corrected=1;
    end
  case 'sme_uic_fsedit' % sampling frequency
    if any(editnum < 0)
      editnum=abs(editnum); corrected=1;
    end
    name='Sampling frequency';
    fs=editnum(1,1);
    % check sampling frequency
    inpval=guidtard(Me, 'DATA_INPUT');
    if isa(inpval,'iddat')
      freqvect=inpval.freqpoints;
    else
      freqvect=inpval.places;
    end
    if iscell(freqvect), fmax=max(cat(1,freqvect{:}));
    else fmax=max(freqvect);
    end
    if fmax>= fs/2
      fsn=fmax*2.5;
      if fs<=0, 
        fsord=1;
      else
        fsord=ceil(log10(fs));
      end
      fsn=floor(fsn/(10^fsord)*1000)/1000*10^fsord;
      if strcmp(p1, 'check_edit1') % call from domain popup, change needed
        fs=fsn;
      else % call from editbox
        % no correction but warning
        msg=sprintf('Sampling frequency is too small! (suggested min value: %.4g)', fsn);
        errorstatus=1;
        warning(msg)
      end
    else
      
    end
    editnum_new=fs;
  end
  corrected=corrected | any(size(editnum)~=size(editnum_new));
  if ~corrected, corrected=any(editnum_new ~= editnum); end
  if corrected
    sme('status', ['Warning: ', name,' automatically corrected.'])
    if exist('maxord'), editstr='maxord-1';
    else editstr=sprintf('%.4g', editnum_new);
    end
    set(h_edit,'string',editstr);
  else
    if errorstatus
      sme('status', ['Warning: ' msg])
      out=1;
    else
      sme('status', 'Checking ready');
      out=0;
    end
  end
  
  % actions 
  if strcmp(p1, 'ui_edit')
    if strcmp(sender,'sme_uic_deledit')|strcmp(sender,'sme_uic_fsedit')| ...
        strcmp(sender,'sme_uic_trordedit')
      sme('forget_final_data')
    elseif strcmp(sender,'sme_uic_onedit') | strcmp(sender,'sme_uic_odedit') 
      if iscams(myfig)
        sme('in_axes');
        sme('update_plot');
      else
        sme('forget_final_data')
      end
    end   
    sme('setbutton', 'disable_done, disable_pause')
  end
  
elseif strcmp(p1,'sme_uic_zsdspop')
  h1=findobj(myfig, 'tag','sme_uic_zsdspop');
  modestr=lower(popupstr(h1)); M1=modestr; M1(1)=upper(modestr(1));
  if any(findstr(modestr, 'deselect')) %deselect mode
    enable_pb='on';
  else %other than deselect mode
    enable_pb='on';
  end
  h_pb=findobj(myfig, 'tag','sme_uic_deselpb');
  set(h_pb, 'enable', enable_pb);
  
  sme('status', [M1 ' mode set. Use the mouse to ' modestr ' in the plot.']);
  
elseif strcmp(p1,'sme_uic_linloghpop')
  sme('update_plot')
  
elseif strcmp(p1,'sme_uic_varpop')
  sme('update_plot')
  
elseif strcmp(p1,'sme_uic_info_object')  
  outval=guidtard(Me, 'FINAL_DATA');
  new_outval='';
  for ii=1:length(outval)  % inside sme cell array of fidmodels is used !!
    if isempty(new_outval), new_outval=outval{ii};
    else new_outval=stack(2,new_outval,outval{ii});
    end
  end
  if isa(new_outval,'fidmodel'), info(new_outval), end
  
elseif strcmp(p1,'ui_help_advice')  
  outval=guidtard(Me, 'FINAL_DATA');
  new_outval='';
  for ii=1:length(outval)  % inside sme cell array of fidmodels is used !!
    if isempty(new_outval), new_outval=outval{ii};
    else new_outval=stack(2,new_outval,outval{ii});
    end
  end
  if isa(new_outval,'fidmodel'), advice(new_outval), end

elseif strcmp(p1,'sme_uic_deselpb')
  selected_models = guidtard(Me, 'SELECTED_MODELS');
  keep_these={}; keep_ix=1;
  for ix=1:length(selected_models)
    model=selected_models{ix};
    if model(1)>=model(2) % denom>=num
      keep_these{keep_ix}=model;
      keep_ix=keep_ix+1;
    end
  end
  guidtawr(Me, 'SELECTED_MODELS', 'direct', keep_these)
  update_done_models(Me)
  sme('update_plot')
  
elseif strcmp(p1, 'buttondown')
  set(myfig,'windowbuttonmotionfcn', '')
  h1=findobj(allchild(myfig), 'flat', 'tag', 'sme_uic_zsdspop');
  if ~iscams(myfig) | strcmp(popupstr(h1), 'Zoom') % zoom is sme or cams zoom
    set(myfig, 'handlevisibility', 'callback')
    zoom down
    set(myfig, 'handlevisibility', 'off')
  else % select/deselect
    % The selection/deselection is handled by the buttondown function.
    % During the action a selection/deselection message is constructed
    % containing the selection box in brackets.
    set(myfig, 'handlevisibility', 'callback')
    box = rbbox;
    set(myfig, 'handlevisibility', 'off')
    msg = SelectModels(box);
    sme('status', msg);
    if any(findstr(lower(msg), 'error'))
      sme('status', msg);
    else
      fdtool('callback', 'sme', 'ui_modelselection', msg, 'sme_axes_ax');
      sme('setbutton', 'disable_done, disable_pause')
    end;
  end
  set(myfig,'windowbuttonmotionfcn', 'fdtool(''callback'',''sme'',''mousemotion'')' )
  
elseif strcmp(p1, 'ui_modelselection')
  sme('status', p2);
  msg = p2; % The msg contains the selection message
  % along with the selection box coordinates in rectangles.
  
  box = str2num(msg(find( msg == '['):find(msg == ']')));
  h = findobj(allchild(myfig), 'flat', 'Tag', 'sme_axes_ax');
  xl = get(h, 'xlim');
  yl = get(h, 'ylim');
  if length(box) == 2
    point_or_box = 'point'; % a single click selection of a point
  else
    point_or_box = 'box  '; % a rubberbox selection of a rectangle
  end;
  if box(1) == Inf
    box(1) = xl(2);
  elseif box(1) == -Inf
    box(1) = xl(1);
  end;
  if box(2) == Inf
    box(2) = yl(2);
  elseif box(2) == -Inf
    box(2) = yl(1);
  end;
  if length(box) == 4
    if box(3) == Inf
      box(3) = xl(2);
    elseif box(3) == -Inf
      box(3) = xl(1);
    end;
    if box(4) == Inf
      box(4) = yl(2);
    elseif box(4) == -Inf
      box(4) = yl(1);
    end;
  end;
  selected_deselected_models = models_in_box(Me, box);
  % It calculates the models which are inside the selection box.
  
  h = findobj(allchild(myfig), 'flat', 'Tag', 'sme_uic_zsdspop');
  string = popupstr(h);
  if ~isempty(findstr(msg, 'Deselect')) % deselect mode
    selected_models = reduce_models(Me, selected_deselected_models);
    guidtawr(Me, 'SELECTED_MODELS', 'direct', selected_models);
    update_done_models(Me);
    % It clears the deselected models, and writes them back into 
    % the storage area, then redisplays them.
  elseif ~isempty(findstr(msg, 'Select')) % select mode
    selected_models = extend_models(Me, selected_deselected_models, point_or_box);
    guidtawr(Me, 'SELECTED_MODELS', 'direct', selected_models);
    % It extends the selection with the newly selected models
    % and redisplays them. In this mode the click operates as a flip-flop.
    % If a selected model is clicked on, the model becomes deselected.
    % If a deselected model is clicked on, the model becomes selected.
  end;
  sme('update_plot');
  
elseif strcmp(p1,'sme_uic_showcb')
  h = findobj(allchild(myfig), 'flat', 'Tag', sender);
  val=get(h, 'value');
  if val, show='shown'; else, show='hidden'; end
  sme('status', ['ELiS window will be ' show ' during iteration.'])
  
  
elseif strcmp(p1,'set_sme/cams')
  c=allchild(myfig);
  h=[findobj(c, 'flat','tag','sme_uic_zsdspop'),...
      findobj(c, 'flat','tag','sme_mod_skippb')];
  if iscams(myfig)
    set(h, 'visible', 'on')
  else
    set(h, 'visible', 'off')
  end
  
elseif strcmp(p1, 'forget_final_data')
  result=guidtard(Me, 'FINAL_DATA');
  if ~isempty(result)
    guidtawr(Me, 'FINAL_DATA', 'direct', '')
    sme('update_plot')
  end
  sme('setbutton', 'disable_done')
  
elseif strcmp(p1,'destroyed')
  % close all children 
  guiclose('select')
  fdtool('finished_box', ['rect_' myname], 'cancel', Me);
  
  
elseif strcmp(p1,'dummy')
  % no action
  
elseif strcmp(p1,'click_on_axes')
  % no action
  
elseif strcmp(p1,'sme_uic_load_model')
  guifreez(Me, 'freeze_strong', 'sme_import_model');
  if iscams(myfig)
    sme('status', 'Please specify model(s) in the Import window...');
    guiimpv('init', 'sme' , ['SME_MODEL'], '', 'filter: fidmodel object(s) with fitted data');
  else
    sme('status', 'Please specify model in the Import window...');
    guiimpv('init', 'sme' , ['SME_MODEL'], '', 'filter: fidmodel object with fitted data');
  end
  
elseif strcmp(p1,'sme_uic_save_model')
  outval=guidtard(Me, 'FINAL_DATA');
  if isempty(outval)
    sme('status', 'Error: No model to save.') % shouldn't happen
  else
    guifreez(Me, 'freeze', 'sme_save_data');
    new_outval='';
    for ii=1:length(outval)  % inside sme cell array of fidmodels is used !!
      if isempty(new_outval), new_outval=outval{ii};
      else new_outval=stack(2,new_outval,outval{ii});
      end
    end
    filter='filter: fidmodel object(s) with fitted data';
    initvar=struct(...
      'CurrentSource', 'WP', ...
      'CurrentPath', [''],...
      'CurrentFileName', 'estimated_models',...
      'CurrentVarName', 'model');
    initvar.ExportData=new_outval; % it does not work with struct !!!!
    guiimpv('init_export', 'sme', 'EXPORT_DATA', initvar, filter)
  end
  
elseif strcmp(p1,'export_ready')
  guifreez(Me, 'unfreeze', 'sme_save_data');
  switch p2
  case 'done'
    sme('status', 'Model exported.')
  case 'cancel'
    sme('status', 'Model not exported.')
  end
  
elseif strcmp(p1,'import_ready')
  switch  p2
  case 'cancel'
    switch p3 % caller_ID
    case 'STARTING_MODEL'
      sme('status', 'Import of model cancelled')
      SetMsg(myfig) % set default/nondefault setting msg
      %Set all checked values off
      set(get(get(findall(myfig,'tag','sme_menu_runmod_iobj_setobject'),...
        'parent'),'children'),'checked','off')
      
    case 'STARTING_WEIGHT'
      sme('status', 'Import of initial weight vector cancelled')
      SetMsg(myfig) % set default/nondefault setting msg
    end
    
  case 'done'
    switch p3 % caller_ID
    case 'STARTING_MODEL'
      data=guidtard('fdtool_importfig', 'IMPORTED_VAR');
      ElisParams=GetElisParams(myfig);
      ElisParams.selectedstartingmodel=data;
      ElisParams.startingvalues='object'; % switch to selected
      SetElisParams(myfig, ElisParams);
      sme('status', 'Initial model imported.')
      SetMsg(myfig) % set default/nondefault setting msg
    case 'STARTING_WEIGHT'
      data=guidtard('fdtool_importfig', 'IMPORTED_VAR');
      ElisParams=GetElisParams(myfig);
      ElisParams.selectedstartingweight=data;
      ElisParams.startingvalues='weight'; % switch to selected
      SetElisParams(myfig, ElisParams);
      sme('status', ['Initial starting set to weight.'])
      CheckElisParameters(myfig)
      SetMsg(myfig) % set default/nondefault setting msg
    case 'SME_MODEL' %load model to sme
      results=guidtard('fdtool_importfig', 'IMPORTED_VAR');
      sme('status','Model being loaded...'), drawnow
      sme('restore_model',results)
      sme('setbutton', 'enable_done, disable_pause')
      guifreez(Me, 'unfreeze', 'force');
    end
  end
  
elseif strcmp(p1,'restore_model') %typical call: sme('restore_model',models,'autoorder')
  if iscell(p2)
    results=p2;
  else
    results={p2(:,:,1)};
    for ii=2:length(p2)
      results=[results,{p2(:,:,ii)}];
    end
  end
  c=allchild(myfig);
  h= findobj(c,'flat','tag', 'sme_uic_dompop');
  d=get(h,'string');
  ind=strmatch(results{1}.variable(1),d);
  if ~isequal(ind,get(h,'value'))
    set(h,'value',ind);
    sme('sme_uic_dompop', 'sme_uic_dompop'); %redisplay window
  end
  if any(findstr('z',results{1}.variable))
    h=findobj(c,'flat','tag','sme_uic_fsedit');
    set(h,'string',sprintf('%.2g',results{1}.fs))  
  else
    fs=results{1}.fs;
    if ~isempty(fs), set(h,'string',sprintf('%.2g',fs)), end
  end
  h=findobj(c,'flat','tag', 'sme_uic_deledit');
  set(h,'string',sprintf('%.2g',results{1}.delay))
  h=findobj(c,'flat','tag', 'sme_uic_complexcb');
  if strcmp(results{1}.coefficients,'complex'), set(h,'value',1), else set(h,'value',0), end
  h=findobj(c,'flat','tag', 'sme_uic_improvedcb');
  if strcmp(results{1}.representation,'polynomial'), set(h,'value',0), else set(h,'value',1), end
  h=findobj(c,'flat','tag', 'sme_uic_transientcb');
  if ~isequal(~isempty(results{1}.ntr),get(h,'value'))
    set(h,'value',~isempty(results{1}.ntr))
    sme('sme_uic_transientcb','sme_uic_transientcb'); 
    if ~isempty(results{1}.ntr)
      maxord=max(length(results{1}.num)-1,length(results{1}.denom)-1);
      h=findobj(c,'flat','tag', 'sme_uic_trordedit');
      str=get(h,'string');
      trord=eval(str);
      if ~isequal(trord,length(results{1}.ntr)-1)
        set(h,'string',num2str(length(results{1}.ntr)-1))
      end
    end
  end
  if ~isequal(results{1}.data,guidtard(Me,'DATA_INPUT'))
    fdtool('load_an_arrow', 7, results{1}.data) %change data in arrow
    guidtawr(Me,'DATA_INPUT','direct',results{1}.data);
  end
  hnumer=findobj(c, 'flat','tag','sme_uic_onedit');
  hdenom=findobj(c, 'flat','tag','sme_uic_odedit');
  if iscams(myfig)
    numord1=length(results{1}.num)-1;
    denomord1=length(results{1}.denom)-1;
    nmin=numord1; nmax=nmin;
    dmin=denomord1; dmax=dmin;
    for ii=2:length(results)
      no=length(results{ii}.num)-1;
      do=length(results{ii}.denom)-1;
      nmin=min(nmin,no); nmax=max(nmax,no);
      dmin=min(dmin,do); dmax=max(dmax,do);
    end
    if nmax>nmin
      set(hnumer,'string',sprintf('[%.0f:%.0f]',nmin,nmax));
    else
      set(hnumer,'string',sprintf('%.0f',nmax));
    end
    if dmax>dmin
      set(hdenom,'string',sprintf('[%.0f:%.0f]',dmin,dmax));
    else
      set(hdenom,'string',sprintf('%.0f',dmax));
    end
    sm={};
    for ii=1:length(results)
      rii=results{ii};
      sm=[sm,{[length(rii.denom)-1,length(rii.num)-1]}];
    end
    guidtawr(Me,'SELECTED_MODELS','direct',sm);
    guidtawr(Me,'DONE_MODELS','direct',results);
    sme('in_axes')
    guidtawr(Me, 'FINAL_DATA', 'direct', results);
    sme('update_plot')
    %axes manipulation
    if (nargin>=3)&strcmp(p3,'autoorder')&(length(results)>1)
      h = findobj(allchild(findall(0, 'tag','aided_main')), 'flat', 'Tag', 'sme_axes_ax');
      hloos=findall(h,'Marker','.');
      for ii=1:length(hloos)
        nii=get(hloos(ii),'ydata'); dii=get(hloos(ii),'xdata');
        if ~isequal(dii,denomord1)|~isequal(nii,numord1)
          set(hloos(ii),'color',[0.55,1,0.55])
          %disp(sprintf('Model %.0f/%.0f is set light green\n',nii,dii))
        end
      end
    end
  else %EPM
    %write in the results
    numord=length(results{1}.num)-1;
    set(hnumer,'string',num2str(numord));
    denomord=length(results{1}.denom)-1;
    set(hdenom,'string',num2str(denomord));
    guidtawr(Me, 'FINAL_DATA', 'direct', results);
    sme('update_plot')
  end %CAMS/SME
  sme('status', 'Model imported.')

elseif strcmp(p1, 'gmexp_ready')
  switch  p2
  case 'cancel'
    switch p4 % caller_ID
    case 'integer'
      sme('status', 'Import of Max. iteration number cancelled')
      SetMsg(myfig) % set default/nondefault setting msg
    end
    
  case 'done'
    % p3 is the command string. 
    data=str2num(p3);
    switch p4 % caller_ID
    case 'integer'   
      ElisParams=GetElisParams(myfig);
      if ~isempty(data), ElisParams.selectedmaxiterations=data; end
      ElisParams.maxiterations='selected'; % switch to selected
      SetElisParams(myfig, ElisParams);
      sme('status', ['Max. iteration number set to ' p3])
      CheckElisParameters(myfig)
      SetMsg(myfig) % set default/nondefault setting msg
    case {'nonpositive','posle1'}   
      ElisParams=GetElisParams(myfig);
      if ~isempty(data), ElisParams.selectedmargin=data; end
      hdom=findobj(myfig,'tag','sme_uic_dompop'); domain=popupstr(hdom);
      if (strcmp(domain,'z')&isequal(data,1)) | (~strcmp(domain,'z')&isequal(data,0))
        ElisParams.margin='default'; % back to default
        ElisParams=rmfield(ElisParams,'selectedmargin'); 
      else
        ElisParams.margin='selected'; % switch to selected
      end
    SetElisParams(myfig, ElisParams);
      sme('status', ['Stability / mph margin set to ' p3])
      CheckElisParameters(myfig)
      SetMsg(myfig) % set default/nondefault setting msg
    end
  end
  guifreez(Me, 'unfreeze', 'force');
  
  
elseif strcmp(p1,'sme_uic_print')
  %sme print command
  fdgprint(Me)
  sme('status','Print figure done.')
  
elseif strcmp(p1,'sme_mod_print_ps')
  %sme print command
  fdgprint(Me,'ps')
  
elseif strcmp(p1,'set_fs') % possibility to set fs from command line
  if isa(p2, 'double')
    p2=num2str(p2);
  end
  h=findobj(allchild(myfig), 'flat', 'tag', 'sme_uic_fsedit');
  set(h, 'string', p2)
  if strcmp(get(h, 'enable'), 'on')
    sme('ui_edit', 'sme_uic_fsedit');
  end
  
elseif strcmp(p1, 'preload')
  % preload, nothing to do
  
elseif strcmp(p1,'resize')
  
  mindx=620;
  mindy=385;
  scr=get(0,'screensize');
  mainfigmaxx=scr(3);
  mainfigmaxy=scr(4);
  
  
  
  ch=allchild(myfig);
  pos=get(myfig,'position');
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
  fromvarpop_dy=63;
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_uframe'),'position');
  frame_offsx=pos(1);
  frame_dx=pos(3);
  gr_offsy=fig_dy-20-(pos(2)+pos(4));
  set(findobj(ch, 'flat', 'tag','sme_uic_uframe'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_domaintext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_domaintext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_dompop'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_dompop'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_ordnumtext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_ordnumtext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_onedit'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_onedit'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_orddentext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_orddentext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_odedit'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_odedit'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_autoorderpb'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_autoorderpb'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_delaytext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_delaytext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_delpop'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_delpop'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_valuetext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_valuetext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_deledit'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_deledit'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_sectext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_sectext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_fstext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_fstext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_fstext2'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_fstext2'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_raztext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_raztext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_razpop'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_razpop'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_raztext2'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_raztext2'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_razedit'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_razedit'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  
  
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_fsedit'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_fsedit'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_improvedcb'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_improvedcb'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_slowertext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_slowertext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_transientcb'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_transientcb'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_complexcb'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_complexcb'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_trordtext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_trordtext'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_trordedit'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_trordedit'),'position',[pos(1) pos(2)+gr_offsy pos(3) pos(4)]);
  
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_statusframe'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_statusframe'),'position',[pos(1) pos(2) fig_dx pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_statustext'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_statustext'),'position',[pos(1) pos(2) fig_dx-6 pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_collectpb'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_collectpb'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_donepb'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_donepb'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_cancelpb'),'position');
  cancelpb_offsx=fig_dx-pos(3)-20;
  set(findobj(ch, 'flat', 'tag','sme_uic_cancelpb'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_uframe'),'position');
  ax_offsx=pos(1)+pos(3)+fromframe_dx;
  ax_dx=fig_dx-ax_offsx-20;
  if ~iscams(myfig)
    pos=get(findobj(ch, 'flat', 'tag','sme_uic_linloghpop'),'position');
  else
    pos=get(findobj(ch, 'flat', 'tag','sme_uic_zsdspop'),'position');
  end;
  ax_offsy=pos(2)+pos(4)+fromvarpop_dy;
  ax_dy=fig_dy-ax_offsy-20;
  set(findobj(ch, 'flat', 'tag','sme_axes_ax'),'position',[ ax_offsx ax_offsy ax_dx ax_dy]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_zsdspop'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_zsdspop'),'position',[ax_offsx pos(2) pos(3) pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','sme_uic_deselpb'),'position');
  set(findobj(ch, 'flat', 'tag','sme_uic_deselpb'),'position',[ax_offsx pos(2) pos(3) pos(4)]);
  
  
else 
  if guiinfos('isdevelopment')
    warning(['Error: sme.m called with incorrect command: '  p1]) 
  end
end 




%*************************************
% Local functions
%*************************************
function y=iscams(myfig)
y=any(strcmp(get(myfig, 'tag'), 'aided_main'));






function message = SelectModels(box)

% This function constructs a selection message containing the 
% selection mode and the selection box in brackets.
message = '';


box(3) = box(1)+box(3);
box(4) = box(2)+box(4);
oden_pix=[box(1) box(3)];
onum_pix=[box(2) box(4)];

ax = findall(0, 'tag', 'sme_axes_ax');


axpos=get(ax, 'position');
xlim=get(ax, 'xlim');
xscale=diff(xlim)/axpos(3);
ylim=get(ax, 'ylim'); 
yscale=diff(ylim)/axpos(4);
oden=(oden_pix-axpos(1))*xscale+xlim(1);
onum=(onum_pix-axpos(2))*yscale+ylim(1);
if (abs(oden(1)-oden(2)) < 0.1 & abs(onum(1)-onum(2)) < 0.1)
  fname = 'point';
else 
  fname = 'box';
end;

if oden(1) < xlim(1), oden(1)=-inf; end
if oden(2) > xlim(2), oden(2)= inf; end
if onum(1) < ylim(1), onum(1)=-inf; end
if onum(2) > ylim(2), onum(2)= inf; end

if strcmp(fname, 'point')
  box = round([mean(oden) mean(onum)]);
  %   box = [mean(oden) mean(onum)];
else
  box = [ceil(oden(1)) ceil(onum(1)) floor(oden(2)) floor(onum(2))];
  %   box = [oden(1) onum(1) oden(2) onum(2)];
end;

h = findall(0, 'tag','sme_uic_zsdspop');
str1 = popupstr(h); % Select/Deselect
str2 = ' from models in range: ';

prstr='%g  %g  %g  %g'; prstr=['[' prstr(1:4*length(box)-2) ']'];
str3  = sprintf(prstr, box);

message = [str1 str2 str3];


function res = find_model(model, models)
% return index of model in cell array models, zero if not found
res = 0;
for i = 1:length(models)
  res = (res | (all(model == models{i})));
  if res
    res=i; break
  end
end;





function pairs = create_pairs(x, y)

% creates model pairs

ind = 0; pairs='';
for i = 1:length(x)
  for j = 1:length(y)
    ind = ind + 1;
    pairs{ind} = [x(i) y(j)];
  end;
end;



function models = models_in_box(Me, box)

% returns the models inside the selection box

if length(box) == 4
  x = ceil(box(1)):floor(box(3));
  y = ceil(box(2)):floor(box(4));
elseif length(box) == 2
  x = round(box(1));
  y = round(box(2));
end;

ind = 0;
mods = create_pairs(x, y);
model_range = guidtard(Me, 'MODEL_RANGE');
models='';
for i = 1:length(mods)
  if find_model(mods{i}, model_range)
    ind = ind + 1;
    models{ind} = mods{i};
  end;
end;




function models = extend_models(Me, selected_models, point_or_box)

% The function extends the selected models stored with the newly
% selected models. point_or_box specifies, if the selection was
% by a click or a rubberbox. If click, then it works as a flip-flop.
% If the model clicked on had been selected, it becomes deselected,
% otherwise it becomes selected.

model_to_deselect = '';
current_selected_models = guidtard(Me, 'SELECTED_MODELS');
% retrives the currently selected models
for i = 1:length(selected_models)
  if find_model(selected_models{i}, current_selected_models)
    model_to_deselect = selected_models(i);
    % If a model is contained in the stored set, it marks for
    % deselection, thus if the action is a click, the selection
    % can be inverted.
  else
    current_selected_models{length(current_selected_models) + 1} = selected_models{i};
  end;
end;
if (point_or_box == 'point') & (~isempty(model_to_deselect))
  models = reduce_models(Me, model_to_deselect);
else
  models = current_selected_models;
end;




function models = reduce_models(Me, deselected_models)

% Clears the deselected models from the set.
models='';
current_selected_models = guidtard(Me, 'SELECTED_MODELS');
ind = 0;
for i = 1:length(current_selected_models)
  if ~find_model(current_selected_models{i}, deselected_models)
    % Here a reverse logic is followed:
    % each model in the currently selected model set is taken into consideration in turn.
    % If it is not in the deselected set, it is included in the remaining set of selected
    % models. If it is, it is excluded from it.
    ind = ind + 1;
    models{ind} = current_selected_models{i};
  else
    ;
  end
end


function update_done_models(Me)
% update done models: keep only those which are in the selected models set
current_selected_models = guidtard(Me, 'SELECTED_MODELS');
final_data = guidtard(Me, 'FINAL_DATA');
keep_ix=[];
for ix=1:length(final_data)
  act=final_data{ix};
  act_model=[length(act.denom)-1, length(act.num)-1];
  if find_model(act_model, current_selected_models)
    keep_ix(end+1)=ix;
  end
end
keep_these=final_data(keep_ix);
guidtawr(Me, 'FINAL_DATA', 'direct', keep_these);


function update_selected_models(Me)
% update selected models: keep only those which are in the actual model range
selected_models = guidtard(Me, 'SELECTED_MODELS');
model_range = guidtard(Me, 'MODEL_RANGE');
keep_ix=[];
for ix=1:length(selected_models)
  act_model=selected_models{ix};
  if find_model(act_model, model_range)

    keep_ix(end+1)=ix;
  end
end
keep_these=selected_models(keep_ix);
guidtawr(Me, 'SELECTED_MODELS', 'direct', keep_these);

function models=iter_orders(Me)
% return model orders for iteration (done models excluded)
selected_models=guidtard(Me, 'SELECTED_MODELS');
done_models=orders_of_done_models(Me);
keep_ix=0; models='';
for ix=1:length(selected_models)
  m=selected_models{ix};
  if ~find_model(m, done_models)
    keep_ix=keep_ix+1;
    models{keep_ix}=m;
  end
end
% iter order : denom-num
ordvals=zeros(1, length(models)); BIGNUM=10000; 
for ix=1:length(models)
  ordvals(ix)=[models{ix}(2)*BIGNUM+models{ix}(1)];
end
[tmp, ix]=sort(ordvals);
models=models(ix);


function models=orders_of_done_models(Me);
% return orders of done models 
final_data=guidtard(Me, 'FINAL_DATA');
done_models='';
for ix=1:length(final_data)
  act=final_data{ix};
  done_models{ix}=[length(act.denom)-1, length(act.num)-1];
end
models=done_models;


function out=ElisIsRunning
% return running status of elis (by stack examination)
out=0;
stck=dbstack;
for ix=1:length(stck);
  if any(findstr(stck(ix).name, 'elis')), out=1; end
end
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Elis parameter handling functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ElisParams=GetElisParams(myfig)
Me=get(myfig, 'tag');
ElisParams=guidtard(Me, 'ELISPARAMS');
if isempty(ElisParams)| strcmpi(guiinfos('userlevel'), 'automatic')
  ElisParams=defelpar('default');
elseif strcmp(ElisParams.startingvalues,'object')&isstr(ElisParams.selectedstartingmodel)
  if strcmp(ElisParams.selectedstartingmodel,'SME_result')
    model=guidtard(Me,'FINAL_DATA'); %this is the last calculated one
    if isempty(model)
      model=guidtard(Me,'STARTING_MODEL');
    elseif iscell(model)
      model=model{1};
    end
    ElisParams.selectedstartingmodel=model;
    if isempty(model)
      sme('status','Error: starting model is empty')
      error('Starting model is empty')
    elseif ~isa(model,'fidmodel')
      sme('status','Error: starting model is not an fidmodel object')
      error('Starting model is not an fidmodel object')
    end
  else
    sme('status','Error: starting model contains wrong string')
    error('SME result init model is wrongly given')
  end
end
%
%ElisParamsd=defelpar('default');
%if isequal(ElisParams,ElisParamsd), ElisParams=[]; end
%
% later a check should be done here to test 
% the existence of all the necessary fields 
% missing fields should be handled as default
% (if new params are added, saved sessions may cause problems otherwise)


function SetElisParams(myfig, ElisParams)
Me=get(myfig, 'tag');
guidtawr(Me, 'ELISPARAMS', 'direct', ElisParams);


function SetModifMenu(myfig) 
% sets Run Modifiers menu, enable/disable properties
ch='';
if ~guiinfos('ishelpmode',myfig)
  h=findobj(allchild(myfig), 'tag', 'sme_MENU_runmod');
  h_allmenu=findobj(allchild(h), 'type', 'uimenu');
  %set(h_allmenu,'checked', 'off')
  param=GetElisParams(myfig);
  
  if isfield(param,'stabilization')
    switch param.stabilization
    case 'off'
      ch='sme_menu_runmod_stab_off';
    case 'reflection'
      ch='sme_menu_runmod_stab_refl';
    case 'contraction'
      ch='sme_menu_runmod_stab_contr';
    case 'limitation'
      ch='sme_menu_runmod_stab_limit';
    end
    h_ch=findobj(h_allmenu, 'flat','tag', ch); 
    set(get(get(h_ch,'parent'),'children'),'checked','off')
    set(h_ch, 'checked', 'on')
  end
  
  if isfield(param,'minimumphase')
    switch param.minimumphase
    case 'off'
      ch='sme_menu_runmod_fmph_off';
    case 'reflection'
      ch='sme_menu_runmod_fmph_refl';
    case 'contraction'
      ch='sme_menu_runmod_fmph_contr';
    case 'limitation'
      ch='sme_menu_runmod_fmph_limit';
    end
    h_ch=findobj(h_allmenu, 'flat','tag', ch); 
    set(get(get(h_ch,'parent'),'children'),'checked','off')
    set(h_ch, 'checked', 'on')
  end
  
  if isfield(param,'maxiterations')
    switch param.maxiterations
    case 'default'
      ch='sme_menu_runmod_itno_default';
    case 'selected'
      ch='sme_menu_runmod_itno_value';
    end
    h_ch=findobj(h_allmenu, 'flat','tag', ch); 
    set(get(get(h_ch,'parent'),'children'),'checked','off')
    set(h_ch, 'checked', 'on')
  end
  
  if isfield(param,'startingvalues')
    switch param.startingvalues
    case 'trials'
      ch='sme_menu_runmod_iobj_trials';
    case 'AML'
      ch='sme_menu_runmod_iobj_aml';
    case 'IQML'
      ch='sme_menu_runmod_iobj_iqml';
    case 'LS'
      ch='sme_menu_runmod_iobj_ls';
    case 'Yr-weight'
      ch='sme_menu_runmod_iobj_yw';
    case 'Eqr-weight'
      ch='sme_menu_runmod_iobj_ew';
    case 'Ur-weight'
      ch='sme_menu_runmod_iobj_uw';
    case 'EE'
      ch='sme_menu_runmod_iobj_equ';
    case 'object'
      ch='sme_menu_runmod_iobj_object';
    case 'weight'
      ch='sme_menu_runmod_iobj_weight';
    otherwise
      error(['startingvalues ''',param.startingvalues,''' is not allowed'])
    end
  end
  
  if ~isempty(ch)
    h_ch=findobj(h_allmenu, 'flat','tag', ch); 
    set(get(get(h_ch,'parent'),'children'),'checked','off')
    set(h_ch, 'checked', 'on')
  end
  
  % enable/disable selected itno option
  h=findobj(h_allmenu, 'tag', 'sme_menu_runmod_itno_value'); 
  if isfield(param,'selectedmaxiterations') & ~isempty(param.selectedmaxiterations)
    set(h, 'enable', 'on', 'label', sprintf('Selected value: %.0f',param.selectedmaxiterations))
  else
    set(h, 'enable', 'off')
  end
  
  % enable/disable selected model and IQML options
  h=[findobj(h_allmenu, 'tag', 'sme_menu_runmod_iobj_object'), ...
      findobj(h_allmenu, 'tag', 'sme_menu_runmod_iobj_iqml')]; 
  if isfield(param, 'selectedstartingmodel') & isa(param.selectedstartingmodel, 'fidmodel')
    set(h, 'enable', 'on')
  else
    set(h, 'enable', 'off')
  end
  
  % enable/disable selected weight option
  h=findobj(h_allmenu, 'tag', 'sme_menu_runmod_iobj_weight'); 
  if isfield(param, 'selectedstartingweight') & ~isempty(param.selectedstartingweight)
    set(h, 'enable', 'on')
  else
    set(h, 'enable', 'off')
  end
  
  % enable/disable SME, CAMS, and CAEMS output options
  h=findobj(h_allmenu, 'tag', 'sme_menu_runmod_iobj_SME'); 
  if ~isempty(guidtard('fdtool_main', 'OUTPUT_select'))
    set(h, 'enable', 'on')
  else
    set(h, 'enable', 'off')
  end
  h=findobj(h_allmenu, 'tag', 'sme_menu_runmod_iobj_SME_int'); 
  if ~isempty(guidtard('fdtool_main', 'FINAL_DATA'))
    set(h, 'enable', 'on')
  else
    set(h, 'enable', 'off')
  end
  h=findobj(h_allmenu, 'tag', 'sme_menu_runmod_iobj_CAMS'); 
  if ~isempty(guidtard('fdtool_main', 'OUTPUT_aided'))
    set(h, 'enable', 'on')
  else
    set(h, 'enable', 'off')
  end
  h=findobj(h_allmenu, 'tag', 'sme_menu_runmod_iobj_CAEM'); 
  if ~isempty(guidtard('fdtool_main', 'OUTPUT_compare'))
    set(h, 'enable', 'on')
  else
    set(h, 'enable', 'off')
  end   
end



function out=IsDefaultElisParam(myfig)
% determine wheather the current setting is the default or not
param=GetElisParams(myfig);
out=defelpar('isdefault', param);





function CheckElisParameters(myfig,mode)
% check the set parameters
% MAY CHANGE FORMERLY SET ELIS PARAMETERS, if the data is not consistent !!!!
% if mode is silent, no message is generated.
param=GetElisParams(myfig);
if nargin <2, mode=''; end
Me=get(myfig, 'tag');
inputdata=guidtard(Me, 'DATA_INPUT');
% 1. check weight vector:
freqnum=inputdata.freqnumber;
if isfield(param, 'selectedstartingweight') & length(param.selectedstartingweight)~=freqnum
  param.selectedstartingweight=[];
  if isequal(param.startingvalues, 'weight')
    param.startingvalues='trials';
  end
  if ~strcmp(mode,'silent')
    sme('status', ['Error: Length of the weighting vector is not equal with the number of frequencies (',...
        num2str(freqnum), ').'])   
  end
end
% other check here, if necessary:

SetElisParams(myfig,param) % write back params



function SetMsg(myfig)
% set the iteration status message
% (currently the iteration pb's color)
h=findobj(myfig, 'tag', 'sme_uic_elisparampb');
set(h,'visible','off') %not used any more
hm=findobj(myfig, 'tag', 'sme_MENU_runmod'); %menu root
V=version;
if IsDefaultElisParam(myfig)
  if str2num(V(1))>=7, set(hm, 'foregroundcolor', 'default')
  else set(hm,'label','&Run modifiers')
  end
  set(h, 'foregroundcolor', 'default')
  if strncmp(version,'5.2',3), set(h,'string','Parameters...'), end
  h=[findobj(myfig, 'tag', 'sme_menu_runmod_stab');...
    findobj(myfig, 'tag', 'sme_menu_runmod_fmph');...
    findobj(myfig, 'tag', 'sme_menu_runmod_itno');...
    findobj(myfig, 'tag', 'sme_menu_runmod_margin');...
    findobj(myfig, 'tag', 'sme_menu_runmod_iobj');...
    findobj(myfig, 'tag', 'sme_menu_runmod_iobj_setweight')];
  set(h, 'foregroundcolor', 'default')
  if ~strncmp(version,'5.2',3), set(findobj(myfig, 'tag', 'sme_menu_runmod_margin'),'enable','off'), end
else
  if str2num(V(1))>=7, set(hm, 'foregroundcolor', [.9 0 0])
  else set(hm,'label','&Run modifiers*')
  end
  ElisParams=GetElisParams(myfig);
  defElisParams=defelpar('default');
  h=findobj(myfig, 'tag', 'sme_menu_runmod_stab');
  if isequal(ElisParams.stabilization,defElisParams.stabilization)
    set(h, 'foregroundcolor', 'default')
  else set(h, 'foregroundcolor', [.9 0 0])
  end
  h=findobj(myfig, 'tag', 'sme_menu_runmod_fmph');
  if isequal(ElisParams.minimumphase,defElisParams.minimumphase)
    set(h, 'foregroundcolor', 'default')
  else set(h, 'foregroundcolor', [.9 0 0])
  end
  h=findobj(myfig, 'tag', 'sme_menu_runmod_itno');
  if isequal(ElisParams.maxiterations,defElisParams.maxiterations)
    set(h, 'foregroundcolor', 'default')
  else set(h, 'foregroundcolor', [.9 0 0])
  end
  h=findobj(myfig, 'tag', 'sme_menu_runmod_margin');
  if isequal(ElisParams.margin,defElisParams.margin)
    set(h, 'foregroundcolor', 'default')
  else set(h, 'foregroundcolor', [.9 0 0])
  end
  if isequal(ElisParams.stabilization,defElisParams.stabilization) &...
      isequal(ElisParams.minimumphase,defElisParams.minimumphase) & ...
      ~strncmp(version,'5.2',3)
    set(h, 'enable', 'off'), 
  else
    set(h, 'enable', 'on'), 
  end
  h=findobj(myfig, 'tag', 'sme_menu_runmod_iobj');
  if isequal(ElisParams.startingvalues,defElisParams.startingvalues)
    set(h, 'foregroundcolor', 'default')
  else set(h, 'foregroundcolor', [.9 0 0])
  end
  h=findobj(myfig, 'tag', 'sme_menu_runmod_iobj_setweight');
  if ~isfield(ElisParams,'selectedstartingweight')
    set(h, 'foregroundcolor', 'default')
  else set(h, 'foregroundcolor', [.9 0 0])
  end
  %
  %set(h, 'foregroundcolor', [.9 0 0])
  %if strncmp(version,'5.2',3), set(h,'string','ModParams...'), end  
end
