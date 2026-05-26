function caem(p1,p2,p3,p4,p5,seltype) 
%CAEM - Evaluate or Compare Plant Models main function
%
%       Used by FDTOOL.
%
%       Usage: caem(p1,p2,p3,p4,p5,seltype)
%       Example: caem
%
%       See also: CAEMDEF.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon, Gy. Roman and I. Kollar
%       Last modified: 03-Jul-2003, IK

mainfig=findall(0,'tag','fdtool_main');
Me = 'compare_main';
myfcn='caem';
myname='compare';

if nargin >0 & ~strcmp(p1, 'init')
  myfig=findall(0,'tag',Me);
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

if nargin ==0 | strcmp(p1, 'init')
  tmp=findall(0,'tag','compare_main');
  if ~isempty(tmp) 
    guiclose('compare')         
  end
  caemdef
  fig = figure(...
    'Position',[ fig_offsx, fig_offsy, fig_dx, fig_dy ], ... 
    'Resize','on', ...
    'Tag','compare_main', ... 
    'NumberTitle', 'off', ...
    'IntegerHandle', 'off',...
    'Color', figure_col,...
    'Name', 'Evaluate or Compare Plant Models', ...
    'deletefcn', 'fdtool(''callback'',''caem'',''destroyed'');', ...
    'ResizeFcn','fdtool(''callback'',''caem'',''resize'')',...
    'Visible','off'); 
  if ~strncmp('5.2',version,3), set(fig,'toolbar','none'); end
  myfig=fig;
  fdwindef(myfig); % set default window props
  set(myfig, 'units', 'normalized') % for rotate3d text to aid resize
  ver=version;
  if strncmp(ver,'5.2',3) %old version, Macintosh
    rotate3d('on') % init rotate, then disactivate
  elseif (str2num(ver(1:3))>=6.1)&strcmp(ver(4),'.')&(str2num(ver(1:3))<7.2) %newest version, rotate3d changed
    rotate3d(myfig,'on') % init rotate, then disactivate
  elseif strcmp(ver(4),'.')&str2num(ver(1:3))<7.2 %from 7.2, this is wrong
    rotate3d(myfig,'on') % init rotate, then disactivate
  end
  set(myfig, ...
    'Handlevisibility', 'off',...
    'units', 'pixels',...
    'windowbuttondownfcn', '',...
    'windowbuttonupfcn', '',...
    'windowbuttonmotionfcn', 'fdtool(''callback'',''caem'',''mousemotion'')');
  
  %  Uicontrol Object Creation 
  caem_uic_donepb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''caem'',''caem_uic_donepb'',''caem_uic_donepb'');',... 
    'Units', 'pixels',...
    'Position',[ donepb_offsx donepb_offsy donepb_dx donepb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Close',...
    'Tooltipstring','Close window and save selected model from set #1 to arrow',... 
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','caem_uic_donepb',...
    'UserData',''); 
  cams_uic_cancelpb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''caem'',''caem_uic_cancelpb'',''caem_uic_cancelpb'');',... 
    'Units', 'pixels',...
    'Position',[ cancelpb_offsx cancelpb_offsy cancelpb_dx cancelpb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Cancel',...
    'Tooltipstring','Close window without saving data',...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','caem_uic_cancelpb',... 
    'UserData',''); 
  caem_uic_crosspop = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''caem'', ''caem_uic_crosspop'', ''caem_uic_crosspop'')',...
    'Units', 'pixels',...
    'Position',[ crosspop_offsx crosspop_offsy crosspop_dx crosspop_dy ],... 
    'BackgroundColor',popup_bgr_col,...
    'ForegroundColor',popup_fg_col,...
    'String',{'Validate', 'Cross Validate'},...
    'tooltipstring','Calculate criteria with original data or with cross data',...
    'HorizontalAlignment','right',... 
    'Style','popupmenu',... 
    'Min',[ 1 ],... 
    'Value',[ 1 ],... 
    'Tag','caem_uic_crosspop',... 
    'UserData',''); 
  %   cams_uic_loadmpb = uicontrol(... 
  %      'Parent',fig,...
  %      'CallBack','fdtool(''callback'',''caem'',''caem_uic_loadmpb'',''caem_uic_loadmpb'');',... 
  %      'Units', 'pixels',...
  %      'Position',[ loadmpb_offsx loadmpb_offsy loadmpb_dx loadmpb_dy ],... 
  %      'BackgroundColor',pushb_bgr_col,...
  %      'ForegroundColor',pushb_fg_col,...
  %      'String','2nd Model',...
  %      'HorizontalAlignment','center',... 
  %      'Style','pushbutton',... 
  %      'Tag','caem_uic_loadmpb',... 
  %      'UserData',''); 
  cams_uic_comparepb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''caem'',''caem_uic_comparepb'',''caem_uic_comparepb'');',... 
    'Units', 'pixels',...
    'Position',[ comparepb_offsx comparepb_offsy comparepb_dx comparepb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','<>',...
    'tooltipstring','Plot functions of two selected models on each other for comparison',...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','caem_uic_comparepb',...
    'enable','off',...
    'UserData',''); 
  cams_uic_crosspb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''caem'',''caem_uic_crosspb'',''caem_uic_crosspb'');',... 
    'Units', 'pixels',...
    'Position',[ crosspb_offsx crosspb_offsy crosspb_dx crosspb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','Cross Data',...
    'tooltipstring','Load and evaluate cross validation data',...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','caem_uic_crosspb',... 
    'UserData',''); 
  caem_uic_fr1ttext = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ fr1ttext_offsx fr1ttext_offsy fr1ttext_dx fr1ttext_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Models in set #1',...
    'HorizontalAlignment','center',... 
    'Style','text',... 
    'Tag','caem_uic_fr1ttext',... 
    'UserData',''); 
  guititle(caem_uic_fr1ttext);
  % connecting frame
  %caem_uic_frame(4) = uicontrol(... 
  %   'Parent',fig,...
  %   'Units', 'pixels',...
  %   'Position',[ frame4_offsx frame4_offsy frame4_dx frame4_dy ],... 
  %   'BackgroundColor',frame_bgr_col,...
  %   'ForegroundColor',frame_fg_col,...
  %   'String','12',...
  %   'HorizontalAlignment','center',... 
  %   'Style','frame',... 
  %   'Enable','off',... 
  %   'Tag','caem_uic_frame(4)',... 
  %   'hittest', 'off', ...
  %   'UserData',''); 
  caem_uic_frame(1) = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ frame1_offsx frame1_offsy frame1_dx frame1_dy ],... 
    'BackgroundColor',frame_bgr_col,...
    'ForegroundColor',frame_fg_col,...
    'String','1',...
    'HorizontalAlignment','center',... 
    'Style','frame',... 
    'Tag','caem_uic_frame(1)',... 
    'UserData',''); 
  caem_uic_bmtext = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ bmtext_offsx bmtext_offsy bmtext_dx bmtext_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Set #1  Best Model:',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Hittest', 'off',...
    'Tag','caem_uic_bmtext',... 
    'UserData',''); 
  caem_uic_modeltext = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ modeltext_offsx modeltext_offsy modeltext_dx modeltext_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','',...
    'HorizontalAlignment','right',... 
    'Style','text',... 
    'Tag','caem_uic_modeltext',... 
    'UserData',''); 
  caem_uic_f1text = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ f1text_offsx f1text_offsy f1text_dx f1text_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Hittest', 'off',...
    'Tag','caem_uic_f1text',... 
    'UserData',''); 
  caem_uic_fr2ttext = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ fr2ttext_offsx fr2ttext_offsy fr2ttext_dx fr2ttext_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Model Plot in #1',...
    'HorizontalAlignment','center',... 
    'Style','text',... 
    'Tag','caem_uic_fr2ttext',... 
    'UserData',''); 
  guititle(caem_uic_fr2ttext);
  
  caem_uic_frame(2) = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ frame2_offsx frame2_offsy frame2_dx frame2_dy ],... 
    'BackgroundColor',frame_bgr_col,...
    'ForegroundColor',frame_fg_col,...
    'String','2',...
    'HorizontalAlignment','center',... 
    'Style','frame',... 
    'Tag','caem_uic_frame(2)',... 
    'UserData',''); 
  caem_uic_m1text = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ m1text_offsx m1text_offsy m1text_dx m1text_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Set #1  Model:',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Hittest', 'off',...
    'Tag','caem_uic_m1text',... 
    'UserData',''); 
  caem_uic_modelpop2 = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'', ''caem'', ''caem_uic_modelpop2'', ''caem_uic_modelpop2'')',...
    'Units', 'pixels',...
    'Position',[ modelpop2_offsx modelpop2_offsy modelpop2_dx modelpop2_dy ],... 
    'BackgroundColor',popup_bgr_col,...
    'ForegroundColor',popup_fg_col,...
    'String',' ',...
    'tooltipstring','Select model by numerator/denominator orders',...
    'HorizontalAlignment','right',... 
    'Style','popupmenu',... 
    'Min',[ 1 ],... 
    'Value',[ 1 ],... 
    'Tag','caem_uic_modelpop2',... 
    'UserData',''); 
  caem_uic_f2text = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ f2text_offsx f2text_offsy f2text_dx f2text_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Hittest', 'off',...
    'Tag','caem_uic_f2text',... 
    'UserData',''); 
  caem_uic_fr3ttext = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ fr3ttext_offsx fr3ttext_offsy fr3ttext_dx fr3ttext_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Model Plot in #2',...
    'HorizontalAlignment','center',... 
    'Style','text',... 
    'Tag','caem_uic_fr3ttext',... 
    'UserData',''); 
  guititle(caem_uic_fr3ttext);
  
  caem_uic_frame(3) = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ frame3_offsx frame3_offsy frame3_dx frame3_dy ],... 
    'BackgroundColor',frame_bgr_col,...
    'ForegroundColor',frame_fg_col,...
    'String','rb',...
    'HorizontalAlignment','center',... 
    'Style','frame',... 
    'Tag','caem_uic_frame(3)',... 
    'UserData',''); 
  caem_uic_m2text = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ m2text_offsx m2text_offsy m2text_dx m2text_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Set #2  Model:',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Hittest', 'off',...
    'Tag','caem_uic_m2text',... 
    'UserData',''); 
  caem_uic_modelpop3 = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'', ''caem'', ''caem_uic_modelpop3'', ''caem_uic_modelpop3'')',...
    'Units', 'pixels',...
    'Position',[ modelpop3_offsx modelpop3_offsy modelpop3_dx modelpop3_dy ],... 
    'BackgroundColor',popup_bgr_col,...
    'ForegroundColor',popup_fg_col,...
    'String',' ',...
    'tooltipstring','Select model by numerator/denominator orders',...
    'HorizontalAlignment','right',... 
    'Style','popupmenu',... 
    'Min',[ 1 ],... 
    'Value',[ 1 ],... 
    'Tag','caem_uic_modelpop3',... 
    'UserData',''); 
  caem_uic_f3text = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ f3text_offsx f3text_offsy f3text_dx f3text_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Hittest', 'off',...
    'Tag','caem_uic_f3text',... 
    'UserData',''); 
  caem_uic_critpop = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'', ''caem'', ''caem_uic_critpop'', ''caem_uic_critpop'')',...
    'Units', 'pixels',...
    'Position',[ critpop_offsx critpop_offsy critpop_dx critpop_dy ],... 
    'BackgroundColor',popup_bgr_col,...
    'ForegroundColor',popup_fg_col,...
    'String',{'MDL','Akaike', 'Cost Fcn', 'Mean Model Error'},...
    'tooltipstring','Type of model evaluation criterion',...
    'HorizontalAlignment','right',... 
    'Style','popupmenu',... 
    'Min',[ 1 ],... 
    'Value',[ 1 ],... 
    'Tag','caem_uic_critpop',... 
    'UserData',''); 
  caem_uic_typepop = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'', ''caem'', ''caem_uic_typepop'', ''caem_uic_typepop'')',...
    'Units', 'pixels',...
    'Position',[ typepop_offsx typepop_offsy typepop_dx typepop_dy ],... 
    'BackgroundColor',popup_bgr_col,...
    'ForegroundColor',popup_fg_col,...
    'String',{'this is set in ulevctrl !!'},...
    'tooltipstring','Type of model plot',...
    'HorizontalAlignment','right',... 
    'Style','popupmenu',... 
    'Min',[ 1 ],... 
    'Value',[ 1 ],... 
    'Tag','caem_uic_typepop',... 
    'UserData',''); 
  caem_uic_linlogpop = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'', ''caem'', ''caem_uic_linlogpop'', ''caem_uic_linlogpop'')',...
    'Units', 'pixels',...
    'Position',[ linlogpop_offsx linlogpop_offsy linlogpop_dx linlogpop_dy ],... 
    'BackgroundColor',popup_bgr_col,...
    'ForegroundColor',popup_fg_col,...
    'String',{'lin freq','log freq'},...
    'tooltipstring','Linear/logarithmic frequency axis',...
    'HorizontalAlignment','right',... 
    'Style','popupmenu',... 
    'Min',[ 1 ],... 
    'Value',[ 1 ],... 
    'Tag','caem_uic_linlogpop',...
    'visible','on',...
    'UserData',''); 
  caem_uic_couplepop = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'', ''caem'', ''caem_uic_couplepop'', ''caem_uic_couplepop'')',...
    'Units', 'pixels',...
    'Position',[ couplepop_offsx couplepop_offsy couplepop_dx couplepop_dy ],... 
    'BackgroundColor',popup_bgr_col,...
    'ForegroundColor',popup_fg_col,...
    'String',{'Coupled','Decoupled'},...
    'tooltipstring','Coupled/decoupled scaling of the two plots',...
    'HorizontalAlignment','right',... 
    'Style','popupmenu',... 
    'Min',[ 1 ],... 
    'Value',[ 1 ],... 
    'Tag','caem_uic_couplepop',...
    'visible','on',...
    'UserData',''); 
  caem_uic_comptext = uicontrol(... 
    'Parent',fig,...
    'Units', 'pixels',...
    'Position',[ comptext_offsx comptext_offsy comptext_dx comptext_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','Criterion',...
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Tag','caem_uic_comptext',... 
    'UserData',''); 
  
  cams_uic_copypb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''caem'',''caem_uic_copypb'',''caem_uic_copypb'');',... 
    'Units', 'pixels',...
    'Position',[ copypb_offsx copypb_offsy copypb_dx copypb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','>',...
    'Tooltipstring', 'Copy selected model in set #1 into model set #2 (add to set)', ...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','caem_uic_copypb',... 
    'UserData', ''); 
  
  cams_uic_copysetpb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''caem'',''caem_uic_copysetpb'',''caem_uic_copysetpb'');',... 
    'Units', 'pixels',...
    'Position',[ copysetpb_offsx copysetpb_offsy copysetpb_dx copysetpb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','>>',...
    'Tooltipstring', 'Copy model set #1 to model set #2 (unify the two sets)', ...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','caem_uic_copysetpb',... 
    'userdata', '');
  
  cams_uic_remcopypb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''caem'',''caem_uic_remcopypb'',''caem_uic_remcopypb'');',... 
    'Units', 'pixels',...
    'Position',[ remcopypb_offsx remcopypb_offsy remcopypb_dx remcopypb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','<',...
    'Tooltipstring', 'Copy selected model in set #2 into model set #1 (add to set)', ...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','caem_uic_remcopypb',... 
    'UserData','Model #2'); 
  
  cams_uic_remcopysetpb = uicontrol(... 
    'Parent',fig,...
    'CallBack','fdtool(''callback'',''caem'',''caem_uic_remcopysetpb'',''caem_uic_remcopysetpb'');',... 
    'Units', 'pixels',...
    'Position',[ remcopysetpb_offsx remcopysetpb_offsy remcopysetpb_dx remcopysetpb_dy ],... 
    'BackgroundColor',pushb_bgr_col,...
    'ForegroundColor',pushb_fg_col,...
    'String','<<',...
    'Tooltipstring', 'Copy model set #2 to model set #1 (unify the two sets)', ...
    'HorizontalAlignment','center',... 
    'Style','pushbutton',... 
    'Tag','caem_uic_remcopysetpb',... 
    'UserData','Model #2');
  
  
  caem_uic_statusframe = uicontrol(... 
    'Parent',fig,...
    'Units','pixels',...
    'Position',[ statusframe_offsx statusframe_offsy statusframe_dx statusframe_dy ],... 
    'BackgroundColor',frame_bgr_col,...
    'ForegroundColor',frame_fg_col,...
    'String','',... 
    'HorizontalAlignment','left',... 
    'Style','frame',... 
    'Enable','off',... 
    'Tag','caem_uic_statusframe',... 
    'UserData',''); 
  caem_uic_statustext = uicontrol(... 
    'Parent',fig,...
    'Units','pixels',...
    'Position',[ statustext_offsx statustext_offsy statustext_dx statustext_dy ],... 
    'BackgroundColor',text_bgr_col,...
    'ForegroundColor',text_fg_col,...
    'String','',... 
    'HorizontalAlignment','left',... 
    'Style','text',... 
    'Tag','caem_uic_statustext',... 
    'UserData',''); 
  
  
  %  Menu Object Creation 
  
  
  %  Axes and Text Object Creation 
  
  caem_axes_axes(1) = axes(... 
    'Parent',fig,...
    'Units','pixels', ... 
    'Position',[ axes1_offsx axes1_offsy axes1_dx axes1_dy ],... 
    'Xgrid','off', ... 
    'Ygrid','off', ... 
    'Xlim',[ 0 1 ],... 
    'Ylim',[ 0 1 ],... 
    'Clipping','on', ... 
    'Fontname',axes_font_name,...
    'buttondown','fdtool(''callback'',''caem'',''mouse_buttondown_on_axes(1)'',''caem_axes_axes(1)'')',...
    'Tag','caem_axes_axes(1)', ... 
    'UserData',''); 
  caem_axes_axes(2) = axes(... 
    'Parent',fig,...
    'Units','pixels', ... 
    'Position',[ axes2_offsx axes2_offsy axes2_dx axes2_dy ],... 
    'Units','normalized', ... 
    'Xgrid','off', ... 
    'Ygrid','off', ... 
    'Xlim',[ 0 1 ],... 
    'Ylim',[ 0 1 ],... 
    'Clipping','on', ... 
    'Fontname',axes_font_name,...
    'buttondownfcn','fdtool(''callback'',''caem'',''click_on_axes_axes(2)'',''Zoom in'',''caem_axes_axes(2)'')',...
    'Tag','caem_axes_axes(2)', ... 
    'UserData',''); 
  caem_axes_axes(3) = axes(... 
    'Parent',fig,...
    'Units','pixels', ... 
    'Position',[ axes3_offsx axes3_offsy axes3_dx axes3_dy ],... 
    'Xgrid','off', ... 
    'Ygrid','off', ... 
    'Xlim',[ 0 1 ],... 
    'Ylim',[ 0 1 ],... 
    'Clipping','on', ... 
    'Fontname',axes_font_name,...
    'buttondown','fdtool(''callback'',''caem'',''click_on_axes_axes(3)'',''Zoom in'',''caem_axes_axes(3)'')',...
    'Tag','caem_axes_axes(3)', ... 
    'UserData',''); 
  
  set([caem_uic_modeltext, caem_uic_bmtext, caem_uic_f1text, caem_uic_frame(1)], ...
    'enable', 'inactive')
  set([caem_uic_m1text, caem_uic_f2text, caem_uic_frame(2)], ...
    'enable', 'inactive')
  set([caem_uic_m2text, caem_uic_f3text, caem_uic_frame(3)], ...
    'enable', 'inactive')
  % init help fcns
  
  guimenus('compare_main','compare','caem');
  
  if nargin >1 
    if ~isempty(p2) % caem('init', initvar): load session 
      storewin('restore_all', Me, p2) % bring up window with settings in p2
      load_need=0;
    else
      load_need=1;
      % caem('init', ''): default settings
    end
  else % caem or caem('init') : no initvars, restore if possible
    load_need=storewin('recover_more', Me);
  end
  if load_need
    %% Load input variable
    inp=guidtard('fdtool_main', ['INPUT_compare']);
    inpval=guidtard('fdtool_main', ['OUTPUT_', inp.from]);
    inpval=Convert2InternalFormat(inpval);
    guidtawr(Me,'DATA_INPUT_2','direct',inpval);
    % guidtawr(Me,'DATA_INPUT_3','direct',{}); % forget 2nd model set on new load
    guidtawr(Me,'DATA_CROSS_2','direct',{}); % clear previous cross validation data
    guidtawr(Me,'DATA_CROSS_3','direct',{});
    guidtawr(Me,'DATA_CROSSFDATA','direct',{}); % clear cross fdata
    set(caem_uic_crosspop, 'value', 1, 'enable', 'off'); % validation is set
    
    caem('orderstr_update', 2, 'best')
  end  
  
  if length(guidtard(Me, 'DATA_INPUT_2'))>1
    model='multi';
  else % select
    model='single';
  end
  guidtawr(Me, 'MODEL_SINGLE_MULTI', 'direct', model);
  
  ulevctrl(Me); % userlevel control
  caem('resize');
  caem('status', 'Please wait...');  % init status time data before activating figure
  
  intoscr({'compare_main'});
  % The above function, intoscr positions the windows given by their tags
  % into the actual screen. This might come handy when the session has been saved 
  % on a machine with different resolution than that of the present machine.
  
  set(fig,'visible','on'); %pause(0), %drawnow
  
  helpmgr('init_help', '', myfcn, myfig );
  caem('status', 'Please wait...')
  winmenu(myfig);
  
  inp3=guidtard(Me, 'DATA_INPUT_3');
  Xdata=guidtard('fdtool_main', 'DATA_MODELS_FROM_SME_TO_CAMS'); % sme stored data here
  % check if sme/cams saved models; if so, copy them to set #2
  if isempty(Xdata) % no external model imported
    if isempty(inp3)  % only plot 2 is active
      caem('twomodel', 'off')
    else
      caem('twomodel', 'on', 'no order string update')
    end

  else
    if ~iscell(Xdata), Xdata={Xdata}; end
    caem('model_transfer: copy set X2X->2', Xdata)
    guidtawr('fdtool_main', 'DATA_MODELS_FROM_SME_TO_CAMS', 'direct','') % clear stored data
	end

  SetCmpEnable(myfig) % set cmp button's enable property
  %% plot input vars
  caem('update_plot2');
  caem('update_plot1');
  fixpopups(myfig)
  
elseif strcmp(p1, 'mousemotion')
  guiready(myfig, myfcn)
  
elseif strcmp(p1, 'caem_uic_linlogpop')
  caem('update_plot2')
  if istwomodel(myfig), caem('update_plot3'), end
  UpdateCompareIfNeeded(myfig)
  
elseif strcmp(p1, 'caem_uic_couplepop') % 'coupled' popupmenu
  caem('update_plot2')
  if istwomodel(myfig), caem('update_plot3'), end
  
elseif strcmp(p1,'caem_uic_donepb')
  model=guidtard(Me, 'MODEL_SINGLE_MULTI');
  caem('status', 'closing...', Me);
  inpval=guidtard(Me,'DATA_INPUT_2');
  if strcmp(model, 'single')  % input from sme 
    modelno=1;
  else % input from cams
    popup='caem_uic_modelpop2';
    h=findobj(allchild(myfig), 'flat', 'tag', popup);
    modelno=get(h,'value');
  end
  outval=Convert2ExternalFormat(inpval{modelno});
  % write back output data to main window
  guidtawr('fdtool_main', ['OUTPUT_' myname], 'direct', outval);
  fdtool('finished_box', 'rect_compare', 'done', Me);
  storewin('remember', Me)
  guiclose('compare')   
  
elseif strcmp(p1,'caem_uic_cancelpb')
  caem('status', 'canceling...', Me);
  guiclose('compare')
  fdtool('finished_box', 'rect_compare', 'cancel', Me);
  fdtool('status', 'Compare panel closed by Cancel. ', Me);
  
  
elseif strcmp(p1,'caem_uic_movepb') % x>  NOT PRESENT ANY MORE
  caem('status', 'Moving models...') 
  caem('model_transfer: move 1->2')
  caem('status', 'Moving finished.') 
  
elseif strcmp(p1,'caem_uic_copypb') % >
  caem('status', 'Copying models...') 
  caem('model_transfer: copy 1->2')
  caem('status', 'Copying finished.') 
  
elseif strcmp(p1,'caem_uic_copysetpb') % >>
  caem('status', 'Copying models...') 
  caem('model_transfer: copy set 1->2')
  caem('status', 'Copying finished.') 
  
elseif strcmp(p1,'caem_uic_remmovepb') %<x  NOT PRESENT ANY MORE
  caem('status', 'Moving models...') 
  caem('model_transfer: move 2->1')
  caem('status', 'Moving finished.') 
  
elseif strcmp(p1,'caem_uic_remcopypb') %<
  caem('status', 'Copying model...') 
  caem('model_transfer: copy 2->1')
  caem('status', 'Copying finished.') 
  
elseif strcmp(p1,'caem_uic_remcopysetpb') %<<
  caem('status', 'Copying models...') 
  caem('model_transfer: copy set 2->1')
  caem('status', 'Copying finished.') 
  
elseif strcmp(p1,'caem_uic_copyset12')  % menu   NOT PRESENT ANY MORE
  caem('status', 'Copying model set...') 
  caem('model_transfer: copy set 1->2')
  caem('status', 'Copying finished.') 
  
elseif strcmp(p1,'caem_uic_copyset21')  % menu   NOT PRESENT ANY MORE
  caem('status', 'Copying model set...') 
  caem('model_transfer: copy set 2->1')
  caem('status', 'Copying finished.') 
  
elseif strcmp(p1,'caem_uic_moveset21')  % menu   NOT PRESENT ANY MORE
  caem('status', 'Moving model set...') 
  caem('model_transfer: move set 2->1')
  caem('status', 'Moving finished.') 
  
  
elseif any(findstr(p1,'model_transfer'))
  % copy, move models in set #1 & set #2
  % command format: model_transfer: copy|move {set} 1->2|2->1|X->1|X->2
  % (the lattest form loads from external source, 
  %  syntax: caem('model_transfer: copy set X->1', {model1, ... modeln})
  ch=allchild(myfig);
  if findstr(p1, '1->2')
    SourceSetNo='2'; DestSetNo='3';
  elseif findstr(p1, '2->1')
    SourceSetNo='3'; DestSetNo='2';
  elseif findstr(p1, 'X->1')  % external source
    SourceSetNo='X'; DestSetNo='2';
  elseif findstr(p1, 'X->2')  % external source
    SourceSetNo='X'; DestSetNo='3';
  end
  
  if strcmp(SourceSetNo, 'X')  % external source
    SourceData = p2;
    SourceCross={};
    ixSource=1;
  else
    SourceData =guidtard(Me, ['DATA_INPUT_' SourceSetNo]);
    SourceCross=guidtard(Me, ['DATA_CROSS_' SourceSetNo]);
    hSourcePop=findobj(ch, 'flat', 'tag', ['caem_uic_modelpop' SourceSetNo]);
    ixSource=get(hSourcePop, 'Value');
  end
  if length(SourceCross) ~= length(SourceData)
    SourceCross=cell(size(SourceData));
  end
  DestData =guidtard(Me, ['DATA_INPUT_' DestSetNo]);
  OriginalDestLength=length(DestData);
  if isempty(DestData); DestData={}; end
  DestCross=guidtard(Me, ['DATA_CROSS_' DestSetNo]);
  if length(DestCross) ~= length(DestData)
    DestCross=cell(size(DestData));
  end
  hDestPop=findobj(ch, 'flat', 'tag', ['caem_uic_modelpop' DestSetNo]);
  ixDest=get(hDestPop, 'Value');
  
  if findstr(p1, 'set') % append whole source set to end of dest set
    DestData(end+1:end+length(SourceData))=SourceData;
    DestCross(end+1:end+length(SourceData))=SourceCross;
  else % append selected source item to end of dest set
    DestData(end+1)=SourceData(ixSource);
    DestCross(end+1)=SourceCross(ixSource);
  end
  guidtawr(Me, ['DATA_INPUT_' DestSetNo], 'direct', DestData);
  guidtawr(Me, ['DATA_CROSS_' DestSetNo], 'direct', DestCross);
  
  if findstr(p1, 'move')  % delete source item or set
    if findstr(p1, 'set')
      if findstr(p1, '1->2')
        error('Bad model move call') % only move 2->1 is possible
        return
      end
      caem('twomodel', 'off')
    else % Current Item
      SourceData={SourceData{1:ixSource-1}, SourceData{ixSource+1:end}};
      SourceCross={SourceCross{1:ixSource-1}, SourceCross{ixSource+1:end}};
      guidtawr(Me, ['DATA_INPUT_' SourceSetNo], 'direct', SourceData);
      guidtawr(Me, ['DATA_CROSS_' SourceSetNo], 'direct', SourceCross);
      switch SourceSetNo  % update source plot
        case '2'
          caem('orderstr_update', 2, 'best');
          caem('update_plot2')
          caem('update_plot1')
        case '3'
          if isempty(SourceData)
            caem('twomodel', 'off')
          else
            caem('orderstr_update', 3, 'best');
            caem('update_plot3')
          end
      end
    end
  end
  % update dest plot
  if findstr(p1, 'set') % new dest sel = old source sel
    dix=ixSource;  
  else
    dix=1;  
  end
  switch DestSetNo
    case '2'
      caem('orderstr_update', 2, num2str(OriginalDestLength+dix));
      caem('update_plot2')
      caem('update_plot1')
    case '3'
      caem('twomodel', 'on', num2str(OriginalDestLength+dix));
  end
  
  UpdateCompareIfNeeded(myfig)
  caem('status', 'Model transfer finished.')
  
  
elseif any(findstr(p1, 'uic_model_paste_')) | any(findstr(p1, 'from_load_model_paste_'))
  % PASTE from clipboard - but LOAD load utilizes this routine as well !!!!
  %
  % syntax: caem_uic_model_paste_SPECIFICATION_SETNUMBER
  %         from_load_model_paste_SPECIFICATION_SETNUMBER
  % SPECIFICATION = replace | add
  % SETNUMBER = 1 | 2
  if findstr(p1, 'add')
    command='add'; CmdStr='added to';
  elseif findstr(p1, 'replace')
    command='replace'; CmdStr='replaced';
  else
    error('internal error: bad command')
  end
  
  ch=allchild(myfig);
  if findstr(p1, '_1')
    SourceSetNo='2'; SourceStr='Set #1';
  elseif findstr(p1, '_2')
    SourceSetNo='3'; SourceStr='Set #2';
  else
    error('internal error: bad command')
  end
  
  SourceData =guidtard(Me, ['DATA_INPUT_' SourceSetNo]); % old data
  SourceCross=guidtard(Me, ['DATA_CROSS_' SourceSetNo]);
  hSourcePop=findobj(ch, 'flat', 'tag', ['caem_uic_modelpop' SourceSetNo]);
  ixSource=get(hSourcePop, 'Value');
  if length(SourceCross) ~= length(SourceData)
    SourceCross=cell(size(SourceData));
  end
  OriginalSourceLength=length(SourceData);
  
  % find data to paste
  if any(findstr(p1, 'uic_model_paste_'))
    % find Clipboard data
    clip=ReadfromClipBoard(Me);
    if isempty(clip)
      ClipData={};
      ClipCross={};
    else
      ClipData=clip.data;
      ClipCross=clip.crossdata;
    end
  else
    % find import data
    ClipData=guidtard(Me, 'IMPORTED_VAR');
    guidtawr(Me,'IMPORTED_VAR', 'direct', '');  % clear tmp var
    
    ClipData=Convert2InternalFormat(ClipData);
    ClipCross={};
  end
  
  % find selection index: select the best of the new models
  ix=selbcf(myfig, ClipData);  
  switch command
    case 'add'
      SourceDataNew={SourceData{:}, ClipData{:}};
      SourceCrossNew={SourceCross{:}, ClipCross{:}};
      caem('status', [''])
      ix=OriginalSourceLength+ix;
    otherwise % 'replace'
      SourceDataNew=ClipData;
      SourceCrossNew=ClipCross;
      ix=ix;
  end
  
  % check
  if strcmp(SourceSetNo, '2') & isempty(SourceDataNew)
    caem('status', ['Error: Set #1 cannot be empty, ''' command ''' command not executed.'])
  else % paste can be executed
    if ~isempty(ClipData) | length(SourceDataNew)~=OriginalSourceLength  % paste action
      guidtawr(Me, ['DATA_INPUT_' SourceSetNo], 'direct', SourceDataNew);
      guidtawr(Me, ['DATA_CROSS_' SourceSetNo], 'direct', SourceCrossNew);
      
      switch SourceSetNo
        case '2'
          caem('orderstr_update', 2, num2str(ix));
          caem('update_plot2')
          caem('update_plot1')
        case '3'
          if isempty(SourceDataNew)   
            caem('twomodel', 'off');
          else
            caem('twomodel', 'on', num2str(ix));
          end
      end
      UpdateCompareIfNeeded(myfig)
    end
    nr=num2str(length(ClipData));
    if length(ClipData)>1, pl='s'; else pl=''; end
    if any(findstr(p1, 'uic_model_paste_'))
      caem('status', [' Paste command: ' nr ' model' pl ' ' CmdStr ' ' SourceStr ' from clipboard.'])
    else
      caem('status', [' Load command: ' nr ' model' pl ' ' CmdStr ' ' SourceStr '.'])
    end
  end
  
  
elseif any(findstr(p1, 'uic_model_copy_')) | ...
    any(findstr(p1, 'uic_model_cut_')) | ...
    any(findstr(p1, 'uic_model_delete_')) % model copy/cut/delete
  % syntax: caem_uic_model_COMMAND_SPECIFICATION_SETNUMBER
  % COMMAND = copy | paste | delete
  % SPECIFICATION = set | selected | nonsel | unstab | bad
  % SETNUMBER = 1 | 2
  if findstr(p1, 'copy')
    command='copy';
  elseif findstr(p1, 'cut')
    command='cut';
  elseif findstr(p1, 'delete')
    command='delete';
  else
    error('internal error: bad command')
  end
  
  ch=allchild(myfig);
  if findstr(p1, '_1')
    SourceSetNo='2'; SourceStr='Set #1';
  elseif findstr(p1, '_2')
    SourceSetNo='3'; SourceStr='Set #2';
  else
    error('internal error: bad command')
  end
  SourceData =guidtard(Me, ['DATA_INPUT_' SourceSetNo]);
  SourceCross=guidtard(Me, ['DATA_CROSS_' SourceSetNo]);
  hSourcePop=findobj(ch, 'flat', 'tag', ['caem_uic_modelpop' SourceSetNo]);
  ixSource=get(hSourcePop, 'Value');
  if length(SourceCross) ~= length(SourceData)
    SourceCross=cell(size(SourceData));
  end
  OriginalSourceLength=length(SourceData);
  
  if findstr(p1, 'set') % source is the whole set
    source_use_ix=1:OriginalSourceLength;
    source_rem_ix=[];
  elseif findstr(p1, 'selected') % source is the selected model
    source_use_ix=ixSource;
    source_rem_ix=[1:ixSource-1, ixSource+1:OriginalSourceLength];
  elseif findstr(p1, 'nonsel') % source is the nonselected model set
    source_use_ix=[1:ixSource-1, ixSource+1:OriginalSourceLength];
    source_rem_ix=ixSource;
  elseif findstr(p1, 'unstab') % source is the unstable model set
    source_use_ix=[]; source_rem_ix=[];
    for ii=1:length(SourceData);
      if isstable(SourceData{ii})
        source_rem_ix=[source_rem_ix ii];
      else
        source_use_ix=[source_use_ix ii];
      end
    end
  elseif findstr(p1, 'bad') % source is the "bad" model set
    meas_vect=zeros(1,length(SourceData));
    for ii=1:length(SourceData);
      data=SourceData{ii};
      measure=data.fitinfo.cf; % measure can be modified if required
      meas_vect(ii)=measure;
    end
    min_meas=min(meas_vect);
    max_meas=max(meas_vect);
    MAGIC_CONSTANT=0.2;
    limit=(max_meas-min_meas)*MAGIC_CONSTANT+min_meas;
    source_use_ix=find(meas_vect>limit);
    source_rem_ix=find(~(meas_vect>limit));
  end
  SourceDataUse=SourceData(source_use_ix);
  SourceCrossUse=SourceCross(source_use_ix);
  SourceDataNew=SourceData(source_rem_ix);
  SourceCrossNew=SourceCross(source_rem_ix);
  
  errorstatus=0;
  if strcmp(command, 'copy') 
    
  else % cut or delete
    % Checking
    % set #1 cannot be deleted
    if strcmp(SourceSetNo, '2') & isempty(SourceDataNew)
      caem('status', ['Error: Set #1 cannot be empty, ''' command ''' command not executed.'])
      errorstatus=1;
    else
      if ~isempty(SourceDataUse) % if no delete - no action
        guidtawr(Me, ['DATA_INPUT_' SourceSetNo], 'direct', SourceDataNew);
        guidtawr(Me, ['DATA_CROSS_' SourceSetNo], 'direct', SourceCrossNew);
        
        ix=find([source_rem_ix, -1]== ixSource); % keep the old selection if possible (-1 is to avoid []==scalar warning)
        if isempty(ix)
          ix=selbcf(myfig, SourceDataNew);  % otherwise select the best model
        end
        switch SourceSetNo
          case '2'
            caem('orderstr_update', 2, num2str(ix));
            caem('update_plot2')
            caem('update_plot1')
          case '3'
            if isempty(SourceDataNew)   
              caem('twomodel', 'off');
            else
              caem('twomodel', 'on', num2str(ix));
            end
        end
        UpdateCompareIfNeeded(myfig)
      end
    end
  end
  if ~errorstatus
    clipdata=[];
    clipdata.data=SourceDataUse;
    clipdata.crossdata=SourceCrossUse;
    
    nr=num2str(length(source_use_ix));
    if length(source_use_ix)>1, pl='s'; else pl=''; end
    switch command
      case 'copy'
        caem('status', [nr ' model' pl ' copied to clipboard from ' SourceStr '.'])
        CopytoClipBoard(Me, clipdata);
      case 'cut'
        caem('status', [nr ' model' pl ' cut to clipboard from ' SourceStr '.'])
        CopytoClipBoard(Me, clipdata);
      case 'delete'
        caem('status', [nr ' model' pl ' deleted from ' SourceStr '.'])
    end
    
  end
  
  
elseif strcmp(p1,'menu_clipboard_info')
  clipdata=ReadfromClipBoard(Me);
  if isempty(clipdata)
    data='';
  else
    data=clipdata.data;
  end
  new_data='';
  for ii=1:length(data)  % inside caem cell array of fidmodels is used !!
    if isempty(new_data), new_data=data{ii};
    else new_data=stack(1,new_data,data{ii});
    end
  end
  garrinfo(1001, new_data, 'Clipboard information')
  caem('status', 'See Help Window for Clipboard Information...')   
  
  
elseif strcmp(p1,'import_ready')
  guifreez(Me, 'unfreeze', 'force');
  switch  p2
    case 'cancel'
      caem('status', 'Load cancelled')
    case 'done'
      if findstr(p3,  'model_')  % model_replace_1, model_add_1, model_replace_2, ...
        data=guidtard('fdtool_importfig', 'IMPORTED_VAR');
        guidtawr(Me,'IMPORTED_VAR','direct',data);
        caem(['from_load_model_paste_' p3(7:end)])
      elseif strcmp(p3,  'crossdata')
        crossfdata=guidtard('fdtool_importfig', 'IMPORTED_VAR');
        data2=guidtard(Me, 'DATA_INPUT_2');
        data3=guidtard(Me, 'DATA_INPUT_3');
        if isempty(data3), alldata=data2; else, alldata=[data2 data3]; end
        
        modcross=crossval(myfig, alldata, crossfdata); % cross validation
        DeleteClipCross(Me) % delete (possibly old) cross validation data from clipboard
        
        caem('status', 'Cross validation finished.');
        guidtawr(Me, 'DATA_CROSSFDATA', 'direct', crossfdata)
        guidtawr(Me, 'DATA_CROSS_2', 'direct', modcross(1:length(data2)))
        if isempty(data3)
          guidtawr(Me, 'DATA_CROSS_3', 'direct', {})
        else
          guidtawr(Me, 'DATA_CROSS_3', 'direct', modcross(length(data2)+1:end))
        end
        hvalid=findobj(allchild(myfig),'Tag','caem_uic_crosspop');
        %Enable cross validate, select cross validate, execute cross validate
        set(hvalid, 'enable', 'on','value',2)
        caem('caem_uic_crosspop')
      end
  end
  
elseif strcmp(p1,'caem_uic_comparepb')|...
    strcmp(p1,'compare_zoom')|strcmp(p1,'zoom_in_axes')
  if strcmp(p1,'zoom_in_axes')
    caem('status', 'Please wait, zooming in progress...')
    comparemode='Zoom in';
    axes_ix=p2; % it can be used to distinguish between ax2 and ax3
  else % compare
    comparepbh=findobj(allchild(myfig), 'flat', 'tag', 'caem_uic_comparepb');
    if strcmp(get(comparepbh, 'enable'), 'off')
      % compare called but compare is not enabled
      % may happen when auto-update is performed
      comparemode='compare_disable';
      figtag='caem_compare_model_fig';
      figh=findobj(allchild(0), 'flat', 'tag', figtag);
      ch=allchild(figh); axs=findobj(ch, 'flat', 'type', 'axes');
      delete(axs)
      return
    else
      caem('status', 'Please wait, comparison in progress...')
      comparemode='compare';
    end
    axes_ix=2; % call from button: ax2 is the default
  end
  typeh=findobj(allchild(myfig), 'flat', 'tag', 'caem_uic_typepop');
  typestr=popupstr(typeh);
  hax2=findobj(allchild(myfig), 'flat', 'tag', 'caem_axes_axes(2)');
  hax3=findobj(allchild(myfig), 'flat', 'tag', 'caem_axes_axes(3)');
  if axes_ix==2
    [modelset, modelno, dummy]=GetCurrentModel(2, myfig);
    model2=modelset{modelno};
    % model2=guidtard(Me, 'DATA_MODEL_2'); obsolate
    [modelset, modelno, dummy]=GetCurrentModel(3, myfig);
    model3=modelset{modelno};
    % model3=guidtard(Me, 'DATA_MODEL_3'); obsolate
    if isempty(get(hax2, 'children')) % clear model if main plot is empty
      model2='';
    end
    if isempty(get(hax3, 'children')) % clear model if main plot is empty
      model3='';
    end
  else
    [modelset, modelno, dummy]=GetCurrentModel(3, myfig);
    model2=modelset{modelno};
    % model2=guidtard(Me, 'DATA_MODEL_3'); obsolate
    model3='';
    if isempty(get(hax3, 'children')) % clear model if main plot is empty
      model2='';
    end
  end
  
  if strcmp(lower(comparemode), 'zoom in')
    model3='';
  end
  if isempty(model3)|any(findstr(lower(typestr),'tf'))|...
      any(findstr(lower(typestr),'poles/zeros'))|...
      any(findstr(lower(typestr),'response'))|any(findstr(lower(typestr),'nyquist'))
    %For the rest, the compare function is not implemented
    %nem kellene inkabb szurkiteni ilyenkor? DE: ha model3 nincs, akkor kellenek!
    if strcmp(lower(comparemode), 'compare') & any(findstr(lower(typestr),'poles/zeros'))
      if ~strcmp(model2.variable, model3.variable)
        caem('status', 'Warning: Domains are different, pole/zero comparison not possible') 
        return
      end
    end
    if findstr(p1, 'zoom_in')
      figname=['View: selected model in set #'  num2str(p2-1)];
      figtag='caem_model_zoom_fig';
    else
      figname='Compare Models';
      figtag='caem_compare_model_fig';
    end
    figh=findobj(allchild(0), 'flat', 'tag', figtag);
    if isempty(figh)
      figh=figure;
      
    end
    delete(allchild(figh))
    set(figh, 'name', figname, 'tag', figtag, 'numbertitle', 'off')
    if strcmp(p1, 'caem_uic_comparepb')
      figure(figh)
    end
    axh=axes('Parent',figh);
  end
  %
  if any(findstr(lower(typestr),'tf'))|any(findstr(lower(typestr),'cloud'))
    models=model2; if ~isempty(model3), models=stack(1,models,model3); end 
    Fdata_ploteltf=model2.data;
    vdat=[];
    h1=findall(0, 'tag','caem_uic_linlogpop');
    linlogvar=get(h1,'value');
    if linlogvar==2
      fscale='log';
    else %1
      fscale='lin';
    end
    if findstr(lower(typestr),'phase')
      msc='-';
      titlstr='Phases (degrees)';
      xlabstr='';
    elseif ~strcmp(p1,'caem_uic_comparepb')&any(findstr(lower(typestr),'error'))
      if any(findstr(lower(typestr),'bound'))
        %if guiinfos('islinear'), msc='a';
        %else 
          msc='b';
        %end
        titlstr='Magnitudes, Complex Errors and Error Bounds';
        xlabstr='Amplitudes: +, fitting errors: x, bounds: --';
      else
        msc='r';
        titlstr='Magnitudes and Complex Errors';
        xlabstr='Amplitudes: +, fitting errors: x';
      end
    elseif any(findstr(lower(typestr),'cloud'))
      msc='+';
      vdat=Fdata_ploteltf.OldTBSisoVariance;
      titlstr='Models and std''s of measured data';
      xlabstr='';
    else
      msc='+';
      if strcmp(p1,'caem_uic_comparepb'), titlstr='Magnitudes (compared)';
      else titlstr='Magnitudes';
      end
      xlabstr='';
      vdat=[];
    end
    if strcmp(p1,'zoom_in_axes')
      %Zoom with copyobj
      hcaemaxes=findall(0, 'tag', sprintf('caem_axes_axes(%.0f)',axes_ix));
      axh=copyaxes(hcaemaxes,axh);
    else
      %Remove variances from Fourier data:
      set(Fdata_ploteltf,'covariance',[],'noconsistency')
      %
      %Zoom-in plot
      if any(findstr(lower(typestr),'cloud'))
        models=cloud(models);
      end
      ploteltf(models,'',Fdata_ploteltf,fscale,msc,vdat,'',3000,...
        '','','nomesg',axh)
      %if strcmp(fscale,'log'), fdident('private','fixlgtck'), end
      %
      if strcmp(p1,'caem_uic_comparepb')&strcmpi(typestr,'TF Magnitudes')&0
        %experiment to plot also difference: for small magnitudes it is
        %misleading
        h1=findobj(axh,'tag','modelplot');
        h2=findobj(axh,'tag','modelplot2');
        set(axh,'nextplot','add')
        plot(get(h1,'xdata'),get(h2,'ydata')-get(h1,'ydata'),'--r')
        set(axh,'nextplot','replace')
      end
    end
    set(axh,'PlotBoxAspectRatioMode','auto')
    if ~any(findstr(lower(typestr),'cloud'))
      set(get(axh,'xlabel'),'string','Model in #1: red, #2: light red')
    end
    ht=get(axh,'title');
    %
    title(titlstr)
    %
    %This destroys the title, I do not know why
    %set(ht,'string',titlstr)
    %guititle(ht); %adjust title width
    %
    set(get(axh,'xlabel'),'string',xlabstr)
    if findstr(lower(typestr),'linear scale')
      set(get(axh,'ylabel'),'string','')
    end
    if ~isempty(model3)
      hp2=findobj(axh,'tag','modelplot2');
      c2=get(hp2,'color'); c3=min(max(c2+0.75,0),1);
      set(hp2,'color',c3);
    end
  elseif any(findstr(lower(typestr),'response'))
    if any(findstr(lower(typestr),'impulse'))
      if ~isempty(model2)
        [y,t]=impulse(model2);
      end
      if ~isempty(model3)
        [y3,t3]=impulse(model3);
      end
    else %step
      if ~isempty(model2)
        [y,t]=step(model2);
      end
      if ~isempty(model3)
        [y3,t3]=step(model3);
      end
    end
    if ~isempty(model2)
      if any(findstr(model2.variable,'z'))
        t=[t';t'+mean(diff(t))]; t=t(:);
        y=[y';y']; y=y(:);
      end
    end
    if ~isempty(model3) 
      if any(findstr(model3.variable,'z'))
        t3=[t3';t3'+mean(diff(t3))]; t3=t3(:);
        y3=[y3';y3']; y3=y3(:);
      end
    end
    if strcmp(p1,'zoom_in_axes')
      if ~isempty(model2)
        plot(t,y,[min(t),max(t)], [0,0],':k','parent', axh)
      end
    else
      c1=[1 0 0]; c2=[1 .75 .75];
      if ~isempty(model2)&~isempty(model3) % both models are present
        [hlines]=plot(t,y, t3,y3, [min(min(t), min(t3)), max(max(t), max(t3))],[0,0],':k','parent', axh);
        set(hlines(1), 'color', c1);
        set(hlines(2), 'color', c2);
      else
        if ~isempty(model2) % only model2 is present
          % t=t;y=y;
          c=c1;
        elseif ~isempty(model3) % only model3 is present
          t=t3;y=y3; c=c2;
        else % none of the models are present
          t=[];
        end
        if ~isempty(t)
          hline=plot(t,y,  [min(t), max(t)],[0,0],':k','parent', axh);
          set(hline, 'color', c);
        end
      end
    end   
    ht=title(typestr,'parent',axh);
  elseif any(findstr(lower(typestr),'nyquist'))
    if strcmp(p1,'zoom_in_axes')
      if isempty(model2)
        modixv=[];
      else
        modixv=1;
      end
    else % compare
      modixv=[];
      if ~isempty(model2)
        modixv=1;
      end
      if ~isempty(model3)
        modixv=[modixv, 2];
      end
    end
    for modix=modixv
      if modix==1
        actmodel=model2;
      else
        actmodel=model3;
      end
      
      [RE,IM]=nyquist(actmodel);
      RE=permute(RE,[3,2,1]); IM=permute(IM,[3,2,1]);
      hlines1=plot([RE;flipud(RE)],[IM;-flipud(IM)],'parent',axh);
      xlim=[min(RE),max(RE)]; ylim=[min([-IM;IM]),max([-IM;IM])];
      lIM=length(IM); IM2=[-IM;IM]; [maxIM,iIMmax]=max(IM2); [minIM,iIMmin]=min(IM2);
      iREmin=rem(iIMmin-1,lIM)+1;
      iREmax=rem(iIMmax-1,lIM)+1;
      set(axh,'nextplot','add')
      if iREmin<lIM
        if RE(iREmin)<RE(iREmin+1), mark='>'; else mark='<'; end
      else
        if RE(iREmin-1)<RE(iREmin), mark='>'; else mark='<'; end
      end
      if strcmp(mark,'<'), mark2='>'; else mark2='<'; end
      hlines2=plot(RE(iREmin),IM2(iIMmin),mark,'parent',axh);
      hlines3=plot(RE(iREmax),IM2(iIMmax),mark2,'parent',axh);
      if strcmp(comparemode, 'compare')
        % set colors
        col={[1 0 0], [1 .75 .75]};
        set([hlines1(:);hlines2(:);hlines3(:)], 'color', col{modix})
        
        % save axis limits
        if modix==1
          xlim1=xlim;
          ylim1=ylim;
        end
      end
    end
    % set axis limits
    % ## AXIS IS SET LATER IN PREPZOOM ##
    %xlim=xlim+diff(xlim)*0.05*[-1,1];
    %ylim=ylim+diff(ylim)*0.05*[-1,1];
    %if diff(xlim)>0, set(axh,'xlim',xlim), end
    %if diff(ylim)>0, set(axh,'ylim',ylim), end
    set(axh,'nextplot','replace')     
    ht=title(typestr,'parent',axh);
    
  elseif any(findstr(lower(typestr),'poles/zeros'))
    if ~any(findstr(lower(typestr),'bounds'))
      set(model2,'covariance',[],'noconsistency'); %eliminate covariance ellipses
      %else
      %if any(findstr(model2.variable,'z'))&strcmp(model2.representation,'orthopol')
      %  caem('status','Warning: cannot plot yet confidence ellipses for orthopol in z-domain')
      %  set(model2,'covariance',[],'noconsistency'); %eliminate covariance ellipses
      %end
    end
    if strcmp(p1,'zoom_in_axes')
      %Zoom with copyobj
      hcaemaxes=findall(0, 'tag', sprintf('caem_axes_axes(%.0f)',axes_ix));
      axh=copyaxes(hcaemaxes,axh);
      %
      hz=findall(hcaemaxes,'marker','o');
      zarr2=get(hz,'Xdata')+j*get(hz,'Ydata');
      hp=findall(hcaemaxes,'marker','x');
      parr2=get(hp,'Xdata')+j*get(hp,'Ydata');
    else
      [zarr2,parr2]=...
        plotelpz(model2,model2.covariance,[],[],'notext','','','','','','','',axh);
    end
    if ~isempty(model3)
      if ~any(findstr(lower(typestr),'bounds'))
        set(model3,'covariance',[],'noconsistency'); %eliminate covariance ellipses
        %else
        %if any(findstr(model3.variable,'z'))&strcmp(model3.representation,'orthopol')
        %  caem('status','Warning: cannot plot yet confidence ellipses for for rothopol in z-domain')
        %  set(model3,'covariance',[],'noconsistency'); %eliminate covariance ellipses
        %end
      end
      ax(1:2)=get(axh,'xlim'); ax(3:4)=get(axh,'ylim');
      delete(get(axh,'children'));
      [zarr3,parr3]=plotelpz(model3,model3.covariance,[],ax,'notext',...
        '','','',''	,'','','',axh);
      h3=findobj(figh, 'tag','modelplot');
      if ~isempty(h3)
        c3=get(h3,'color'); c3=c3{1};
        c3n=min(max(c3+.60,0),1);
        for ii=1:length(h3), set(h3(ii),'color',c3n); end
      end
      h3=findobj(figh, 'tag','modelplotb'); %bounds
      if ~isempty(h3)
        c3=get(h3,'color'); c3=c3{1};
        c3n=min(max(c3+.60,0),1);
        for ii=1:length(h3), set(h3(ii),'color',c3n); end
      end
      set(axh,'nextplot','add')
      plotelpz(model2,model2.covariance,[],ax,'notext','','','','','',...
        '','',axh); 
      set(axh,'nextplot','replace')
      %set(axh,'xlimmode','auto','ylimmode','auto')
    end
    %     figure(get(axh,'parent')) %bypass bug  % Pisti! Miert kell ez ?? Elorejon az ablak akkor is, ha nem kellene
    ht=title('Pole/zero patterns','parent',axh);
    %guititle(ht); %adjust title width
    
    xlim=get(axh,'xlim'); ylim=get(axh,'ylim');
    nshz2=sum((real(zarr2)<xlim(1))|(real(zarr2)>xlim(2))|...
      (imag(zarr2)<ylim(1))|(imag(zarr2)>ylim(2)));
    nshp2=sum((real(parr2)<xlim(1))|(real(parr2)>xlim(2))|...
      (imag(parr2)<ylim(1))|(imag(parr2)>ylim(2)));
    if any(findstr(model2.variable,'z'))
      nonmphz2=sum(abs(zarr2)>=1);
      unstp2=sum(abs(parr2)>=1);
    elseif strncmp(model2.variable,'s',1)
      nonmphz2=sum(real(zarr2)>=0);
      unstp2=sum(real(parr2)>=0);
    elseif strncmp(model2.variable,'w',1)
      nonmphz2=sum(real(zarr2.^2)>=0);
      unstp2=sum((real(parr2.^2)>=0)&(real(parr2)>=0));
    end
    %xtext=sprintf('Not shown: %.0f/%.0f, nonmph/unst: %.0f/%.0f',...
    %    nshz2,nshp2,nonmphz2,unstp2);
    xtext=sprintf('Not minimum phase/unstable: %.0f/%.0f',nonmphz2,unstp2);
    if ~isempty(model3)
      nshz3=sum((real(zarr3)<xlim(1))|(real(zarr3)>xlim(2))|...
        (imag(zarr3)<ylim(1))|(imag(zarr3)>ylim(2)));
      nshp3=sum((real(parr3)<xlim(1))|(real(parr3)>xlim(2))|...
        (imag(parr3)<ylim(1))|(imag(parr3)>ylim(2)));
      xtext=sprintf('Poles/zeros: set #1 (darker), and set #2 (lighter)');
    end
    xlabel(xtext,'parent',axh)
  elseif strcmp(typestr,'Residuals')
    if ~isempty(model3)
      caem('status','Error: Compare residuals is not implemented.')
    else %only one model, only zoom-in is possible
      if strcmp(p1,'zoom_in_axes')
        %Zoom with copyobj
        hcaemaxes=findall(0, 'tag', sprintf('caem_axes_axes(%.0f)',axes_ix));
        axh=copyaxes(hcaemaxes,axh);
      else
        fdata=model2.Data;
        if isa(fdata,'iddat')
          x=fdata.input; y=fdata.output;
          if iscell(x)
            xsav=x; x=xsav{1}; ysav=y; y=ysav{1};       
            for ii=2:size(x,2)
              x=[x;xsav{:,2}]; y=[y;ysav{ii}]; 
            end
          end
          F=fdata.freqn; p=fdata.chn; expno=fdata.expn;
          Fdat=fdata; fv=fdata.inputfreqpoints;
        end
        vdat=fdata.OldTBSisoVariance;
        %
        rdat=rdueelis(model2);
        ryx=rdat.output; vryx=rdat.OldTBSisoVariance; vryx=vryx(:,2);
        %
        [fvs,indf]=sort(fv);
        plot(fv, db(ryx), 'r+',fv(indf), 0.5*db(vryx(indf)), 'c:',...
          fv(indf), 0.5*db(4*vryx(indf)), 'c:', 'parent', axh);
        xlim=[0,max(fv)];
        df=(max(fv)-min(fv))/30;
        if min(fv)<df, xlim(1)=xlim(1)-df; end
        xlim(2)=xlim(2)+df;
        set(axh,'xlim',xlim)
        if get(findall(0,'tag','caem_uic_linlogpop'),'value')==2 %'log'
          set(axh,'xscale','log')
        else
          set(axh,'xscale','lin')
        end
      end
      ht=title('Absolute Values of Complex Residuals with Confidence Limits','parent',axh);
      guititle(ht); %adjust title width
      xlabel('Frequency [Hz]')
    end
  elseif strcmp(typestr,'Correlation Test')
    if ~isempty(model3)
      caem('status','Error: Compare functions of dependency is not implemented.')    
    else %zoom-in only
      if strcmp(p1,'zoom_in_axes')
        %Zoom with copyobj
        hcaemaxes=findall(0, 'tag', sprintf('caem_axes_axes(%.0f)',axes_ix));
        axh=copyaxes(hcaemaxes,axh);
      else
        fdata=model2.data;
        if isa(fdata,'fiddata')
          x=fdata.input; y=fdata.output;
          if iscell(x)
            xsav=x; x=xsav{1}; ysav=y; y=ysav{1};       
            for ii=2:size(x,2)
              x=[x;xsav{:,2}]; y=[y;ysav{ii}]; 
            end
          end
          F=fdata.freqn; p=fdata.chn; expno=fdata.expn;
          fv=fdata.freqpoints;
        end
        Fdat=expfou(fv, reshape(x,F*expno,1), reshape(y,F*expno,1));
        rdat=rdueelis(model2);
        ryx=rdat.output; vryx=rdat.OldTBSisoVariance; vryx=vryx(:,2);
        %
        pno=size(model2.covariance,1);
        if pno>0
          freepar=pno;
          for ii=1:pno
            if all(model2.covariance(ii,:)==0), freepar=freepar-1; end
          end
          %set(axh,'xscale','linear')
        else
          fiti=model2.fitinfo; freepar=fiti.freepar;
        end
        corrtest(ryx,vryx,freepar,axh);
      end
      delete(get(axh,'title'))
      ht=title('Correlation Test','parent',axh);
      guititle(ht); %adjust title width
    end
  elseif strcmp(typestr,'Cost Function vs. Delay')
    if ~isempty(model3)
      caem('status','Error: Compare CF vs. Delay is not implemented.')    
      return
    else %zoom-in only
      if strcmp(p1,'zoom_in_axes')
        %Zoom with copyobj
        hcaemaxes=findall(0, 'tag', sprintf('caem_axes_axes(%.0f)',axes_ix));
        axh=copyaxes(hcaemaxes,axh);
      else
        plotdelays(model2,[],'parent',axh);
        fdident('private','fixlgtck',axh)
      end
      set(get(axh,'title'),'string','Cost function for different delays')
      set(get(axh,'xlabel'),'string','Delays (the triangles mark the starting delay values)')
      ht=get(axh,'title');
      %guititle(ht); %adjust title width
    end
  end
  %
  %set zooming in zoomed plot
  if ~exist('models'), models={}; end
  prepzoom(axh,typestr,models)
  %
  if any(findstr(lower(typestr),'poles/zeros'))
    hf=get(axh,'parent');
    winpos=get(hf, 'position');
    callb=['fdtool(''callback'',''caem'',''caem_axis_equal'',''',get(hf,'name'),''');'];
    % make pb
    h_pb=uicontrol('parent', hf, ...
      'units', 'pixel',...   
      'position', [winpos(3)-60, 25, 60 20],...
      'string', 'Equal',...
      'callback', callb,...
      'tooltipstring','Set axis to equal x-y tickmark increments',...
      'tag', 'equal_pb');
    set(h_pb,'units','normalized');
  end
  %
  if exist('figh')
    dismispb(figtag)
    ver=version;
    if strcmp(ver(4),'.')&str2num(ver(1:3))<7.2
      set(figh, 'windowbuttondownfcn', 'zoom down', 'windowbuttonupfcn', 'ones;' )
      set(axh, 'buttondownfcn', '')
    end
  end
  caem('status', 'Ready')
  
elseif strcmp(p1,'caem_axis_equal')
  hf=findall(0,'Name',p2);
  axh=findobj(hf,'type','axes');
  xlim=get(axh,'xlim'); ylim=get(axh,'ylim');
  dmax=max(diff(xlim),diff(ylim));
  %
  axs=get(get(axh,'Zlabel'),'UserData');
  if diff(xlim)<diff(ylim)
    xlim=sum(xlim)/2+dmax*[-0.5,0.5]; set(axh,'xlim',xlim)
  elseif diff(xlim)>diff(ylim)
    ylim=sum(ylim)/2+dmax*[-0.5,0.5]; set(axh,'ylim',ylim)
  end
  set(get(axh,'Zlabel'),'UserData',axs);
elseif strcmp(p1,'caem_uic_crosspb')
  guifreez(Me, 'freeze_strong', 'caem_import_crossdata');
  guiimpv('init', 'caem' , 'crossdata', '', 'filter: fiddata Object with Variance');
  caem('status', 'Please specify frequency data in the Import window...');
  
elseif strcmp(p1,'caem_uic_modelpop2')
  caem('update_plot2')
  UpdateCompareIfNeeded(myfig)
  caem('update_plot1')
  
elseif strcmp(p1,'caem_uic_modelpop3')
  caem('update_plot3')
  UpdateCompareIfNeeded(myfig)
  
elseif strcmp(p1,'caem_uic_critpop')
  caem('update_plot1')
  h=findobj(allchild(myfig), 'flat', 'tag', p1);
  caem('status', ['Criterion set to ' popupstr(h) '.'])
  
elseif strcmp(p1,'caem_uic_crosspop')
  h=findobj(allchild(myfig), 'flat', 'tag', 'caem_uic_crosspop');
  h_critpop=findobj(allchild(myfig), 'flat', 'tag', 'caem_uic_critpop');
  if any(findstr(popupstr(h), 'Cross')) & isempty(guidtard(Me, 'DATA_CROSSFDATA'))
    set(h, 'value', 1);
    caem('status', 'Error: Cross data not loaded yet.')
    return
  end
  if findstr(popupstr(h), 'Cross')
    set(h_critpop, 'value', 2, 'enable', 'off')
    caem('status', ['Cross validation on'])
  else
    set(h_critpop, 'enable', 'on')
    caem('status', ['Cross validation off'])
  end
  caem('update_plot2')
  caem('update_plot1')
  if istwomodel(myfig)
    caem('update_plot3', Me)
    UpdateCompareIfNeeded(myfig)
  end
  
elseif strcmp(p1,'caem_uic_typepop')
  hm=findobj(allchild(myfig), 'flat', 'tag','caem_uic_typepop');
  typstrcell=get(hm,'string');
  linlogen=[strmatch('TF',typstrcell);strmatch('Cloud',typstrcell);...
      strmatch('Residuals',typstrcell)];
  %tf mag + error, tf magnitude, phase, cloud, residual 
  if any(get(hm,'value')==linlogen)
    set(findall(0,'tag','caem_uic_linlogpop'),'enable','on')
  else %pole/zero, p/z + error, corrtest
    set(findall(0,'tag','caem_uic_linlogpop'),'enable','off')
  end
  
  SetCmpEnable(myfig) % set cmp button's enable property
  
  %if strcmpi(popupstr(hm),'Correlation Test') 
  %set(findall(0,'tag','caem_uic_linlogpop'),'value',1)
  %end
  
  caem('update_plot2', Me)
  if istwomodel(myfig)
    caem('update_plot3', Me)
    UpdateCompareIfNeeded(myfig)
  end
  caem('status', ['Plot type set to ' popupstr(hm) '.'])
  
  
elseif strcmp(p1,'status')
  c=allchild(myfig);
  status=findobj(c, 'flat', 'tag','caem_uic_statustext');
  statusfr=findobj(c, 'flat', 'tag','caem_uic_statusframe');
  glstatus(myfig, status, statusfr, p2)
  
  
elseif strcmp(p1,'menu_load')
  % No action necessary yet
  
elseif findstr(p1,'ui_menu_load_model_')
  if findstr(p1, 'replace')
    mode='replace';
  else
    mode='add';
  end
  target=p1(end); % '1' or '2'
  caem('status', ['Loading model set ', target, '...'])
  guifreez(Me, 'freeze_strong', 'caem_import_model');
  guiimpv('init', 'caem' , ['model_' mode '_', target], '', 'filter: fidmodel object(s) with fitted data');
  caem('status', 'Please specify model data in the Import window...');
  
elseif strcmp(p1,'menu_save') | strcmp(p1,'menu_delete') |...
    strcmp(p1, 'menu_copy') | strcmp(p1, 'menu_move') | ...
    strcmp(p1, 'menu_cut') | strcmp(p1, 'menu_paste')
  
  if ~guiinfos('ishelpmode',myfig)
    h=findobj(allchild(myfig), 'tag', sender);
    ch=get(h, 'children');
    h2nd=findobj(ch, 'userdata', 'Model #2');
    if istwomodel(myfig)
      set(h2nd, 'enable', 'on')
    else
      set(h2nd, 'enable', 'off')
    end
    % check if Actual #1 can be active
    h1=findobj(ch, 'flat', 'userdata', 'Model #1');
    models=guidtard(Me, 'DATA_INPUT_2');
    if length(models)>1
      set(h1, 'enable', 'on')
    else
      set(h1, 'enable', 'off')
    end
  end
  
  
elseif findstr(p1,'menu_save_')
  if findstr(p1, 'model1')
    filter='filter: fidmodel object(s) with fitted data';
    VarName='modelset';
    source='DATA_INPUT_2';
    ID='Model Set #1';
  elseif findstr(p1, 'model2')
    filter='filter: fidmodel object(s) with fitted data';
    VarName='modelset';
    source='DATA_INPUT_3';
    ID='Model Set #2';
  elseif findstr(p1, 'actual1')
    popup='caem_uic_modelpop2';
    filter='filter: fidmodel object(s) with fitted data';
    VarName='model';
    source='DATA_INPUT_2';
    ID='Selected Model in Set #1';
  elseif findstr(p1, 'actual2')
    popup='caem_uic_modelpop3';
    filter='filter: fidmodel object(s) with fitted data';
    VarName='model';
    source='DATA_INPUT_3';
    ID='Selected Model in Set #2';
  end
  initvar=struct(...
    'CurrentSource', 'WP', ...
    'CurrentPath', [''],...
    'CurrentFileName', 'fdmodels',...
    'CurrentVarName', VarName);
  initvar.ExportData=Convert2ExternalFormat(guidtard(Me, source));
  if findstr(p1, 'actual')
    hpop=findobj(allchild(myfig), 'flat', 'tag', popup);
    ix=get(hpop, 'value');
    ordstr=popupstr(hpop);
    ID=[ID ' (order: ' ordstr ')'];
    initvar.ExportData=initvar.ExportData(:,:,ix);
  end   
  guiimpv('init_export', myfcn, ID, initvar, filter)
  
elseif strcmp(p1, 'export_ready')
  switch  p2
    case 'cancel'
      caem('status', 'Save cancelled.')
    case 'done'
      caem('status', ['Save of ' p3 ' completed.'])
  end      
  
elseif strcmp(p1,'ui_menu_delete_model2')
  caem('twomodel', 'off')
  caem('status' , 'Model Set #2 deleted')
  
elseif findstr(p1,'ui_menu_delete_actual')
  if findstr(p1, '1'), indx='2'; else indx='3'; end
  target1=['DATA_INPUT_' indx];
  target2=['DATA_CROSS_' indx];
  models=guidtard(Me, target1);
  cross=guidtard(Me, target2);
  if length(models)>1
    h_ix=findobj(allchild(myfig), 'flat', 'tag', ['caem_uic_modelpop' indx]);
    ix=get(h_ix, 'value');
    order=popupstr(h_ix);
    newmodels=[models(1:ix-1) models(ix+1:end)];
    guidtawr(Me, target1, 'direct', newmodels);
    if ~isempty(cross)
      newcross=[cross(1:ix-1) cross(ix+1:end)];
      guidtawr(Me, target2, 'direct', newcross);
    end
    caem('orderstr_update', str2num(indx), 'best');
    caem(['update_plot' indx])
    UpdateCompareIfNeeded(myfig)
    if findstr(p1, '1')
      caem('update_plot1') % if model #1 changed, bar update is needed
      caem('status' , ['Selected item (' order ') of Model Set #1 is deleted'])
    else
      caem('status' , ['Selected item (' order ') of Model Set #2 is deleted'])
    end   
  else
    if findstr(p1, '2')
      caem('twomodel', 'off')
      caem('status' , 'Last item of Model Set #2 is deleted')
    else
      caem('status', 'Error: Last item of Model Set #1 cannot be deleted.')
    end
  end 
  
  
elseif findstr(p1, 'rotate3d')
  InternalAxes= findobj(allchild(myfig), 'flat', 'tag', 'caem_axes_axes(1)');
  ExternalFig=  findobj(allchild(0), 'flat', 'tag', 'caem_view_bar_figure');
  ExternalAxes= findobj(allchild(ExternalFig), 'flat',  'Tag', 'caem_view_bar_external_axes');
  ExternalMode=strcmp(p3, 'external');
  if ExternalMode
    seltype=get(ExternalFig, 'selectiontype');
  end
  if ~strcmpi(seltype, 'normal'), return, end  % no rotation if doubleclick
  ver=version;
  if strcmp(p2, 'on')
    if ExternalMode
      setptr(ExternalFig, 'closedhand')
      rotate3d down
    else
      set(myfig, ...
        'windowbuttonupfcn', ['fdtool(''callback'',''caem'',''rotate3d'', ''up'',  ''' p3 ''')'],...
        'windowbuttonmotionfcn', '',...
        'handlevisibility', 'callback')
      setptr(myfig, 'closedhand')
      %this is the beginning of rotate:
      if str2num(ver(1:3))>=6.1 %new version
        if exist('hgprops'), disp('rotate3d down:'), hgprops(myfig), end
        rotate3d down
      else
        rotate3d down
      end
    end
    
  elseif strcmp(p2, 'up')
    if ExternalMode
      OldViewVal=get(ExternalAxes, 'view');
      rotate3d up
      set(ExternalFig,'pointer', 'arrow')
      ViewVal=get(ExternalAxes, 'view');
    else
      OldViewVal=get(InternalAxes, 'view');
      %this is the end of rotate
      if str2num(ver(1:3))>=6.1 %new version
        if exist('hgprops'), disp('rotate3d up before:'), hgprops(myfig), end
        rotate3d up
        if exist('hgprops'), disp('rotate3d up after:'), hgprops(myfig), end
      else
        rotate3d up
      end
      set(myfig,...
        'windowbuttonupfcn', '',...
        'windowbuttonmotionfcn', 'fdtool(''callback'',''caem'',''mousemotion'')',...
        'handlevisibility', 'off',...
        'pointer', 'arrow')
      ViewVal=get(InternalAxes, 'view');
    end
    MinRotaLimit=3; % minimum rotation required
    if any(abs(OldViewVal-ViewVal)>MinRotaLimit)
      ViewStr=sprintf('Az: %4g, El:%4g', ViewVal(1), ViewVal(2));
      % special long call to force Seltype to 'normal' in history
      fdtool('callback', 'caem', 'ui_rotate3d', ViewStr, '', '', 'caem_axes_axes(1)', 'normal')
    end
  else % ui call
    ix=findstr(p2,', El:');
    az=str2num(p2(4:ix-1));
    el=str2num(p2(ix+5:end));
    set(ExternalAxes, 'view', [az el])
    set(InternalAxes, 'view', [az el])
  end
  
elseif findstr(p1, 'mouse_buttondown_on_axes(1)')
  InternalAxes= findobj(allchild(myfig), 'flat', 'tag', sender);
  %if strcmp(seltype, 'normal')
  %  caem('rotate3d', 'on', 'internal')
  %else % not rotate, but open external figure
    fdtool('callback', 'caem', 'click_on_axes_axes(1)', 'Zoom in', sender)
  %end
  
elseif findstr(p1, 'click_on_axes_axes(')
  caem('status', 'Please wait, zooming in progress...')
  if findstr(p1, '1')
    caem('status', 'Please wait, zooming in progress...')
    f=findobj(allchild(0), 'flat', 'tag', 'caem_view_bar_figure');
    isNewFig=isempty(f);
    if isNewFig
      f=figure('Name', 'View: Scanned Models',...
        'NumberTitle', 'off',...
        'IntegerHandle', 'off',...
        'HandleVisibility', 'on', ...
        'Tag', 'caem_view_bar_figure');
      dismispb('caem_view_bar_figure')
      ExternalAxes=axes('parent', f,...
        'tag', 'caem_view_bar_external_axes');
    else
      ExternalAxes=findobj(allchild(f), 'flat',...
        'tag', 'caem_view_bar_external_axes');
      figure(f)
    end
    InternalAxes= findobj(allchild(myfig), 'flat', 'tag', sender);
    ViewVal=get(InternalAxes, 'view');
    caem('update_plot1')
    set(InternalAxes, 'view',ViewVal); % restore view
    set(ExternalAxes, 'view',ViewVal);
    %drawnow
    %pause(0)
    if isNewFig
      %  rotate3d on 
      %%  rotate3d down % up may be called earlier than down causing an error
      %%  rotate3d up
      %  set(f, 'HandleVisibility', 'callback',...
      %     'windowbuttondownfcn', '',...
      %     'windowbuttonupfcn', 'fdtool(''callback'',''caem'',''rotate3d'', ''up'', ''external'')');
      %  set(ExternalAxes, ...
      %      'buttondownfcn', 'fdtool(''callback'',''caem'',''rotate3d'', ''on'', ''external'')');
    end
    caem('status', 'Ready.')
    if findstr(p1, 'click_on_axes_axes(1)')
      if strncmp(version,'5.2',3),
        figure(get(ExternalAxes,'parent')), rotate3d('on')  
      elseif strncmp(version,'5.3',3)
        rotate3d(get(ExternalAxes,'parent'),'on')
      else
        rotate3d(ExternalAxes,'on')
      end
      %set(get(ExternalAxes,'parent'),'selectiontype','alt')
    end    
    1;
    
  elseif findstr(p1, '2')
    caem('zoom_in_axes', 2)
  elseif findstr(p1, '3')
    caem('zoom_in_axes', 3)
  end
  
elseif strcmp(p1,'destroyed')
  % close all children 
  guiclose('compare')         
  fdtool('finished_box', 'rect_compare', 'cancel', Me);
  
elseif strcmp(p1,'twomodel')
  % SWITCH ON/OFF 2ND MODEL PLOT
  % p2: 'on'/'off'
  % p3 optional string, if exists, it will be the index of the sel'd model
  
  ch=allchild(myfig);
  hCompare=findobj(ch,'flat','tag', 'caem_uic_comparepb');
  hCoupled=findobj(ch,'flat','tag', 'caem_uic_couplepop');
  hPlotMode=findobj(ch,'flat','tag', 'caem_uic_typepop');
  axis3=findobj(ch, 'flat', 'tag', 'caem_axes_axes(3)');
  set(axis3, 'visible', p2)
  if strcmp(p2, 'on')
    set([hCoupled], 'enable', 'on')
    %set([hCompare], 'enable', 'on')
    %typstrcell=get(hPlotMode,'string');
    %hcompdis=[strmatch('Poles/Zeros with Bounds',typstrcell);...
    %    strmatch('Residuals',typstrcell)];
    %if ~any(get(hPlotMode, 'value')==[hcompdis;inf])
    %   set([hCompare], 'enable', 'on') %disable certain plot compares
    %end
    SetCmpEnable(myfig)
    if nargin < 3
      caem('orderstr_update',3, 'best')
    elseif strcmp(p3, 'no order string update')
      caem('orderstr_update',3, 'current')
    else
      caem('orderstr_update',3, p3)
    end
    caem('update_plot3')
    UpdateCompareIfNeeded(myfig)
  else % off
    set([hCompare; hCoupled], 'enable', 'off');
    delete(allchild(axis3)) 
    guidtawr(Me, 'DATA_INPUT_3', 'direct', {}) % clear input data 
    guidtawr(Me, 'DATA_CROSS_3', 'direct', {}) % clear cross valid. data if any
    hstr=findobj(allchild(myfig), 'flat', 'Tag','caem_uic_f3text');
    set(hstr,'string','')
    caem('orderstr_update',3, '1')
    UpdateCompareIfNeeded(myfig) %!!*!!
  end
  
elseif strcmp(p1,'orderstr_update')
  % FILL IN ORDER POPUP'S STRING PROPERTY
  % p2: 2,3 (plot number)
  % p3: 'best', 'current', or index (string) of selected model in popupstr 
  [inpval, modelno, validation]=GetCurrentModel(p2, myfig);
  
  h_order=findobj(allchild(myfig), 'flat', 'Tag',['caem_uic_modelpop' num2str(p2)]);
  if isempty(inpval{1})  % inpval is {''} 
    str={'No model'}; enstr='off';
  else
    %for ii=1:length(inpval)
    %   str{ii}=[num2str(length(inpval{ii}.num)-1) '/' num2str(length(inpval{ii}.denom)-1)];
    %end
    [str, pieces] = fdmodord(inpval, 'distinguish');
    enstr='on';
  end
  % select required model and set popup value
  if strcmp(p3, 'best')
    index=selbcf(myfig,inpval); % best model
  elseif strcmp(p3, 'current') 
    index=get(h_order, 'value'); % current model
  else
    index=str2num(p3);
  end
  set(h_order, 'string', str, 'value', index, 'enable', enstr);
  
  switch p2 % enable'disable toolbar objs
    case 2
      hcopy=findobj(allchild(myfig), 'flat', 'Tag','caem_uic_copypb');
      if length(inpval)>1
        set(hcopy, 'enable', 'on')
      else
        set(hcopy, 'enable', 'on')
      end
    case 3
      h2ndSet=findobj(allchild(myfig), 'flat','type', 'uicontrol', ...
        'userdata', 'Model #2');
      if isempty(inpval{1})
        set(h2ndSet, 'Enable', 'off')
      else
        set(h2ndSet, 'Enable', 'on')
      end
  end
  
  
elseif strcmp(p1, 'update_plot1')
  %BAR PLOT
  guifreez(Me, 'freeze', 'caem_update_plot1');
  SetFigureMode(Me) % switch plot1 on/off depending on the # of Models in set1
  model=guidtard(Me, 'MODEL_SINGLE_MULTI');
  if strcmp(model, 'multi')  % input from cams
    [inputmodel, index, validation]=GetCurrentModel(2, myfig);
    %validation=popupstr(findobj(allchild(myfig),'Tag','caem_uic_crosspop'));
    criterion=popupstr(findobj(allchild(myfig),'Tag','caem_uic_critpop'));
    selected_order=popupstr(findobj(allchild(myfig),'Tag','caem_uic_modelpop2'));
    axesh=findobj(allchild(myfig),'tag','caem_axes_axes(1)');
    external_figure=findall(0, 'Tag', 'caem_view_bar_figure');
    if ~isempty(external_figure)
      external_axes=findobj(allchild(external_figure), 'flat',...
        'Tag', 'caem_view_bar_external_axes');
      if isempty(external_axes)
        external_axes=axes('parent', external_figure,...
          'tag', 'caem_view_bar_external_axes');
      end
      axesh=[axesh, external_axes];
    end
    %if strcmp(lower(validation),'validate')
    %   inputmodel=guidtard(Me, ['DATA_INPUT_2']);
    %else % cross validation
    %   inputmodel=guidtard(Me, ['DATA_CROSS_2']);
    %end         
    %Prepare data:
    barstructv='';
    numv=[]; denomv=[]; critv=[];
    for ii=1:length(inputmodel)
      fitinfo=inputmodel{ii}.fitinfo;
      if isstruct(fitinfo)
        if strcmp(criterion,'Akaike')
          %critv(ii)=fitinfo.AIC;
          if isfield(fitinfo,'MDL'), critv(ii)=fitinfo.AIC;
          else
            critv(ii)=fitinfo.cf*(1+fitinfo.freepar/fitinfo.F);
          end
        elseif strcmp(criterion,'MDL')
          %critv(ii)=fitinfo.MDL;***
          if isfield(fitinfo,'MDL'), critv(ii)=fitinfo.MDL;
          else
            if any(inputmodel{ii}.data.inputvar), lnf=4; else lnf=2; end
            critv(ii)=fitinfo.cf*(1+fitinfo.freepar/(2*fitinfo.F)*log(lnf*fitinfo.F));
          end
        elseif strcmp(criterion,'Cost Fcn')
          critv(ii)=fitinfo.cf;
        elseif strcmp(criterion,'Mean Model Error')
          critv(ii)=fitinfo.mmerror;
        else
          error('Criterion not found')
        end           
      elseif isnumeric(fitinfo)
        warning('Old form of fitinfo found')
        if strcmp(criterion,'Akaike')
          fitind=12;
        elseif strcmp(criterion,'MDL')
          fitind=19;
        elseif strcmp(criterion,'Cost Fcn')
          fitind=1;
        elseif strcmp(criterion,'Mean Model Error')
          fitind=10;
        else
          error('Criterion not found')
        end
        critv(ii)=fitinfo(fitind);
      end
      numv(ii)=length(inputmodel{ii}.num)-1;
      denomv(ii)=length(inputmodel{ii}.denom)-1;
    end
    [orderstr, pieces] = fdmodord(inputmodel, 'distinguish');
    guibar3(denomv, numv, critv, axesh, 0.8, orderstr, pieces); % The numv and denomv has been flopped.
    if length(axesh)>1
      ht=get(findall(0,'tag','caem_view_bar_external_axes'), 'title');
      set(ht,'string','Evaluation criteria of models');
      %guititle(ht); %adjust title width
    end
    % Best model info update
    bestix=selbcf(myfig,inputmodel);
    if length(inputmodel)>1
      bestorderstr=orderstr{bestix};
    else % index must be 1!!!
      bestorderstr=orderstr;
    end
    msgstr=msgmodel(inputmodel{bestix});
    ordh=findobj(allchild(myfig),'tag','caem_uic_modeltext');
    msgh=findobj(allchild(myfig),'tag','caem_uic_f1text');
    set(ordh, 'string', bestorderstr);
    set(msgh, 'string', msgstr);
    
    % set color of best and selected model bars
    bars=allchild(axesh(1)); 
    h_best=findobj(bars, 'flat', 'tag', ['caem_bar3d[' bestorderstr ']']);
    h_act=findobj(bars, 'flat', 'tag', ['caem_bar3d[' selected_order ']']);
    if ~isempty(external_figure)
      h_best=[h_best; findobj(allchild(axesh(2)), 'flat', ...
        'tag', ['external_caem_bar3d[' bestorderstr ']'])];
      h_act=[h_act; findobj(allchild(axesh(2)), 'flat', ...
        'tag', ['external_caem_bar3d[' selected_order ']'])];
    if strncmp(version,'5.2',3),
      figure(external_figure), rotate3d('on')  
    elseif strncmp(version,'5.3',3),
      rotate3d(external_figure,'on')  
    else
      rotate3d(findall(external_figure,'tag','caem_view_bar_external_axes'),'on')  
    end
  end
    userdat=struct('critval', critv(bestix), 'status', 'BEST');
    set(h_best, 'facecolor', guicolor('BAR_BEST'),...
      'userdata', userdat);
    set(h_act, 'facecolor', guicolor('BAR_SELECTED'));
  end
  guifreez(Me, 'unfreeze', 'caem_update_plot1');
  %
  %rotate3d(findall(myfig,'tag','caem_axes_axes(1)'),'on')
  
elseif strcmp(p1, 'update_plot2') | strcmp(p1, 'update_plot3')
  if strcmp(p1, 'update_plot3')
    %pause(0)
    %drawnow %Make previous plot before this one
  end
  plotno=p1(12);
  [input_source, modelno, validation]=GetCurrentModel(str2num(plotno), myfig);
  inputmodel=input_source{modelno};
  if isempty(inputmodel), return, end
  if strcmp(p1, 'update_plot2')
    hstr=findobj(allchild(myfig), 'flat', 'Tag','caem_uic_f2text');
  else %plot3
    hstr=findobj(allchild(myfig), 'flat', 'Tag','caem_uic_f3text');
  end
  set(hstr,'string',msgmodel(inputmodel))
  
  axis_tag=['caem_axes_axes(' plotno ')'];
  ax=findobj(allchild(myfig), 'Tag', axis_tag);
  delete(get(ax,'children'))
  bfcn_axes=get(ax,'buttondownfcn');
  hmode=findobj(allchild(myfig), 'Tag', 'caem_uic_typepop');
  mode=popupstr(hmode);
  if isempty(inputmodel.data)
    if strncmpi(mode,'resid',5)|strncmpi(mode,'correlation',10)
      mode='TF Magnitudes';
      caem('status','Warning: Model object contains no data')
    end
  end
  guifreez(Me, 'freeze', 'caem_update_plot23');
  caem('status','Please wait, updating plot...')
  h1=findall(0, 'tag','caem_uic_linlogpop');
  linlogvar=get(h1,'value');
  if linlogvar==2
    fscale='log';
  else %1
    fscale='lin';
    set(ax,'xtickmode','auto') %restore xtickmode
  end
  set(ax,'yscale','lin')
  if any(findstr(lower(mode), 'tf'))|any(findstr(lower(mode),'cloud'))
    %mag or phase
    % transfer fcn case
    cdat=[];
    fdata=inputmodel.Data;
    if isa(fdata,'iddat')
      fv=fdata.inputfreqpoints; x=fdata.input; y=fdata.output;
      F=fdata.freqn; expno=fdata.expn; p=fdata.chn;
      xl=x; yl=y;
      if iscell(x), xl=x{1}; for ii=2:length(x), xl=[xl;x{ii}]; end, end
      if iscell(y), yl=y{1}; for ii=2:length(y), yl=[yl;y{ii}]; end, end         
      if iscell(fv), fv=cat(1,fv{:}); end
      Fdat=expfou(fv,xl,yl,[],[],[],[],[],[],'neg');
      Fdat=fdata;
    else
      Fdat=[];
    end
    if findstr(lower(mode), 'phase'), msc='-';
    elseif findstr(lower(mode), 'error')
      if findstr(lower(mode), 'bound')
        %if guiinfos('islinear'), msc='a';
        %else 
        msc='b';
        %end
      else msc='r';
      end
    elseif any(findstr(lower(mode),'cloud')), msc='+';
    else msc='+';
    end
    plotmodel=inputmodel;
    if findstr(lower(mode), 'error')
      if ~isempty(fdata)
        if any(findstr(get(plotmodel,'errorweighting'),'onlin'))
          vdat=sisononlinerror(fdata)/2;
        else
          vdat=fdata.OldTBSisoVariance;
        end
      else vdat=[];
        end
    elseif any(findstr(lower(mode),'cloud'))
      if isempty(inputmodel.covariance)
        mode='TF Magnitudes'; vdat=[];
        caem('status','Warning: Model object contains no covariances')
      else
        plotmodel=cloud(inputmodel);
        if isa(fdata,'fiddata')
          fv=fdata.freqpoints; fmin=min(fv); fmax=max(fv); df=fmax-fmin;
          if fmin==fmax, dfl=max(fmin/1000,1e-6); dfh=max(fmin/1000,1e-6);
          else dfl=diff(fv(1:2)); dfh=diff(fv(end+[-1,0]));
          end
          fscale=[fscale+0,fmin-dfl,fmax+dfh];
          %fscaleend=[max(0,fmin-dfl),fmax+dfh];
        end
        if strcmp(lower(mode),'cloud of models')
          Fdat=[]; vdat=[];
        else %cloud + data
          vdat=fdata.OldTBSisoVariance;
        end
      end
    elseif any(findstr(lower(mode),'std''s'))
      if isempty(inputmodel.covariance)
        mode='TF Magnitudes'; vdat=[];
        caem('status','Warning: Model object contains no covariances')
      else
        plotmodel=inputmodel; vdat=plotmodel.covariance; msc='*';
        if isa(fdata,'fiddata')
          fv=fdata.freqpoints; fmin=min(fv); fmax=max(fv); df=fmax-fmin;
          if fmin==fmax, dfl=max(fmin/1000,1e-6); dfh=max(fmin/1000,1e-6);
          else dfl=diff(fv(1:2)); dfh=diff(fv(end+[-1,0]));
          end
          fscale=[fscale+0,fmin-dfl,fmax+dfh];
          %fscaleend=[max(0,fmin-dfl),fmax+dfh];
        end
      end
    else vdat=[];
    end
    %CAEM in-block plot
    if isempty(Fdat)&strcmp(msc,'r'), msc='*'; end
    if strcmp(msc,'b')&...
        ~any(findstr(lower(plotmodel.errorweighting),'nonlin'))
      msc='a'; 
    end
    ploteltf(plotmodel, [], Fdat, fscale, msc,vdat,'','','','','notext',ax);
    %if strcmp(fscale,'log'), fdident('private','fixlgtck'), end
    %if any(findstr(lower(mode),'cloud'))&exist('fscaleend')
    %  set(ax,'xlim',fscaleend)
    %end
    typeh=findobj(allchild(myfig), 'flat', 'tag', 'caem_uic_typepop');
    typestr=popupstr(typeh);
    %
    set(ax,'ytickmode','auto')
    if any(findstr(lower(typestr),'wrapped'))
      hl=findobj(ax,'type','line');
      for ii=1:length(hl)
        y=get(hl(ii),'ydata');
        y=rem(y-floor(min(y)/360)*360+180,360)-180;
        set(hl(ii),'ydata',y)
      end %for ii
      set(ax,'ylim',[-200,200])
      set(ax,'ytick',[-180,-90,0,90,180]);
    elseif any(findstr(lower(typestr),'linear sc'))
      hl=findobj(ax,'type','line');
      ymax=-inf; ymin=inf;
      for ii=1:length(hl)
        if strcmp(get(hl(ii),'visible'),'on')
          y=get(hl(ii),'ydata');
          y=10.^(y/20);
          set(hl(ii),'ydata',y)
          ymin=min(ymin,min(y));
          ymax=max(ymax,max(y));
          ymm=ymax-ymin;
        end
      end %for ii
      set(ax,'ylim',[ymin-0.04*ymm,ymax+0.04*ymm],'ytickmode','auto')
      ht=get(ax,'title');
      set(ht,'string','')
      guititle(ht); %adjust title width
      %delete(get(ax,'ylabel'))
    end
    set(ax,'PlotBoxAspectRatioMode','auto')
    
  elseif findstr(lower(mode), 'pole')
    if ~any(findstr(lower(mode),'bounds'))
      set(inputmodel,'covariance',[],'noconsistency'); %eliminate covariance ellipses
      %else
      %if any(findstr(inputmodel.variable,'z'))&strcmp(inputmodel.representation,'orthopol')
      %  caem('status','Warning: cannot plot yet confidence ellipses for z-domain')
      %  set(inputmodel,'covariance',[],'noconsistency'); %eliminate covariance ellipses
      %end
    end
    plotelpz(inputmodel, inputmodel.covariance, '', '', 'notext','','','',...
      'anal','','','',ax);
  elseif findstr(lower(mode), 'residuals')
    fdata=inputmodel.Data;
    if isa(fdata,'fiddata')
      x=fdata.input; y=fdata.output;
      if iscell(x)
        xsav=x; x=xsav{1}; ysav=y; y=ysav{1};       
        for ii=2:size(x,2)
          x=[x;xsav{:,2}]; y=[y;ysav{ii}]; 
        end
      end
      F=fdata.freqn; p=fdata.chn; expno=fdata.expn;
      fv=fdata.freqpoints;
      if ~isfield(inputmodel.fitinfo,'errorweighting')|...
          strcmp(inputmodel.fitinfo.errorweighting,'Linear')
        if isempty(fdata.SisoVariance) %artificial variances necessary
          va=ones(length(fv),1);
          set(fdata,'inputvariance',va,'outputvariance',va);
          artvar=1;
        else
          artvar=0;
        end
      else %nonlinear
        if isempty(sisononlinvariance(fdata)) %artificial variances necessary
          va=ones(length(fv),1);
          set(fdata,'inputnonlinvariance',va,'outputnonlinvariance',va);
          artvar=1;
        else
          artvar=0;
        end
      end
    end
    %Fdat=expfou(fv,reshape(x,F*expno,1),reshape(y,F*expno,1),[],[],[],[],[],[],'neg');
    %vdat=fdata.OldTBSisoVariance;
    %[rx, ry, ryx, vryx]=rdueelis(inputmodel, inputmodel.covariance,Fdat,vdat);
    if ~isfield(inputmodel.fitinfo,'errorweighting')|...
        strcmp(inputmodel.fitinfo.errorweighting,'Linear')
      rdat=rdueelis(inputmodel);
      bc='m'; %color of bound
      M=get(inputmodel.data,'M'); 
      mf95=f_dist_mod(M,0.95); mf50=f_dist_mod(M,0.5);
    else %nonlinear
      inputmodel.data=nonlinvar2var(inputmodel.data);
      rdat=rdueelis(inputmodel);
      bc='b'; %color of bound
      nonlinM=get(inputmodel.data,'M'); 
      mf95=f_dist_mod(nonlinM,0.95); mf50=f_dist_mod(nonlinM,0.5);
    end
    ryx=rdat.output; vryx=rdat.OldTBSisoVariance; vryx=vryx(:,1);
    if length(vryx)==1, vryx=vryx*ones(size(ryx)); end
    %
    [fvs,indf]=sort(fv);
    if artvar==0
      set(ax,'ylimmode','auto')
      plot(fv, db(ryx(1:F)), 'c+',...
        fv(indf), db(mf50*sqrt(-log(1-0.95)*vryx(indf)/0.5)), [bc,':'],...
        fv(indf), db(mf95*sqrt(-log(1-0.5)*vryx(indf)/0.5)), [bc,':'], 'parent', ax);
      %set(ax,'nextplot','replacechildren')
    else %artificial variances
      plot(fv, db(ryx(1:F)), 'c+', 'parent', ax);
      caem('status','Warning: Without variances, the confidence limits cannot be given')
    end
    if get(findall(0,'tag','caem_uic_linlogpop'),'value')==2 %'log'
      set(ax,'xscale','log')
      fdident('private','fixlgtck',ax)
    else
      set(ax,'xscale','lin')
    end
    if length(ryx)>F
      set(ax,'nextplot','add')
      for ii=1:length(ryx)/F-1
        plot(fv, db(ryx(ii*F+[1:F])), 'c+', 'parent', ax)
      end %for ii
      set(ax,'nextplot','replacechildren')
    end
    xlim=[min(fv),max(fv)];
    df=(max(fv)-min(fv))/30;
    if min(fv)<df, xlim(1)=xlim(1)-df; end
    xlim(2)=xlim(2)+df;
    set(ax,'xlim',xlim)
    
  elseif findstr(lower(mode), 'correlation test')
    fdata=inputmodel.Data;
    if isa(fdata,'iddat')
      x=fdata.input; y=fdata.output;
      F=fdata.freqn; p=fdata.chn; expno=fdata.expn;
      fv=fdata.freqpoints;
    end
    linear=~strncmpi(get(inputmodel,'errorweighting'),'nonlin',6);
    if (linear&isempty(fdata.SisoVariance))|(~linear&isempty(fdata.OutputNonlinError))
      guifreez(Me, 'unfreeze', 'caem_update_plot23');
      set(hmode,'value',1)
      caem('update_plot2')
      caem('update_plot1')
      if linear
        caem('status',['Error: cannot calculate correlation test without ',...
            'variances of Fourier amplitudes'])
      else 
        caem('status',['Error: cannot calculate correlation test without ',...
            'nonlinear errors of Fourier amplitudes'])
      end
      return
    end
    pno=size(inputmodel.covariance,1);
    if pno>0
      freepar=pno;
      for ii=1:pno
        if all(inputmodel.covariance(ii,:)==0), freepar=freepar-1; end
      end
    else
      freepar=inputmodel.fitinfo.freepar;
    end
    if 0
      if ~isempty(fdata.OutputNonlinError)
        fdata=nonlinvar2var(fdata);
        inputmodel.data=fdata;
      end
      rdat=rdueelis(inputmodel);
      ryx=rdat.output; vryx=rdat.OldTBSisoVariance; vryx=vryx(:,1);
      corrtest(ryx,vryx,freepar,ax);
    else
      if strcmp(p1, 'update_plot3')
        %global CORRTESTBASE, CORRTESTBASEsave=CORRTESTBASE; CORRTESTBASE='nlvar'; %new plot
      else
        %global CORRTESTBASE, CORRTESTBASEsave=CORRTESTBASE; CORRTESTBASE='nlva'; %old plot
      end
      [corrdev,bound,fraction]=corrtest(inputmodel,freepar,'parent',ax); %for test
      %CORRTESTBASE=CORRTESTBASEsave; 
      %if guiinfos('isdevelopment'), fraction, end
    end
    delete(get(ax,'title'))
  elseif strcmp(lower(mode),lower('Cost Function vs. Delay'))
    plotnon=str2num(plotno); 
    [inputmodel, index, validation]=GetCurrentModel(plotnon, myfig);
    inputm=inputmodel{1};
    for ii=2:length(inputmodel), inputm=stack(2,inputm,inputmodel{ii}); end
    plotdelays(inputm,index,'parent',ax);
    fdident('private','fixlgtck',ax)
    delete(get(ax,'title'))
    delete(get(ax,'xlabel'))     
  elseif strcmp(lower(mode),lower('Impulse response'))
    if any(findstr(inputmodel.variable,'s'))&(length(inputmodel.num)>=length(inputmodel.denom))
      guifreez(Me, 'unfreeze', 'caem_update_plot23');
      caem('status','Error: s-domain numerator order is not smaller than denominator order (direct feedthrough)')
      return
    elseif strcmp(inputmodel.variable,'w')|strcmp(inputmodel.variable,'r')
      guifreez(Me, 'unfreeze', 'caem_update_plot23');
      caem('status',['Error: cannot calculate impulse response for variable ''',...
          inputmodel.variable',''''])
      return
    else
      if ~strcmp(get(inputmodel,'coefficients'),'complex')
        [y,t]=impulse(inputmodel);
        if any(findstr(inputmodel.variable,'z'))
          t=[t';t'+mean(diff(t))]; t=t(:);
          y=[y';y']; y=y(:);
        end
        plot(t,y,[min(t),max(t)],[0,0],':k','parent', ax)
        set(ax,'xlimmode','auto','ylimmode','auto')
      else
        guifreez(Me, 'unfreeze', 'caem_update_plot23');
        caem('status','Error: Cannot plot impulse response for complex coefficients')
        return
      end
    end
  elseif strcmp(lower(mode),lower('Step response'))
    if ~strcmp(get(inputmodel,'coefficients'),'complex')
      if any(findstr(inputmodel.variable,'s'))&(length(inputmodel.num)>length(inputmodel.denom))
        guifreez(Me, 'unfreeze', 'caem_update_plot23');
        caem('status','Error: s-domain numerator order is larger than denominator order (differentiator)')
        return
      elseif strcmp(inputmodel.variable,'w')|strcmp(inputmodel.variable,'r')
        guifreez(Me, 'unfreeze', 'caem_update_plot23');
        caem('status',['Error: cannot calculate step response for variable ''',...
            inputmodel.variable',''''])
        return
      else
        [y,t]=step(inputmodel);
        if any(findstr(inputmodel.variable,'z'))
          t=[t';t'+mean(diff(t))]; t=t(:);
          y=[y';y']; y=y(:);
        end
        plot(t,y,[min(t),max(t)],[0,0],':k','parent', ax)
        set(ax,'xlimmode','auto','ylimmode','auto')
      end
    else
      guifreez(Me, 'unfreeze', 'caem_update_plot23');
      caem('status','Error: Cannot plot step response for complex coefficients')
      return
    end
  elseif strcmp(lower(mode),lower('nyquist diagram'))
    if ~strcmp(get(inputmodel,'coefficients'),'complex')
      if strcmp(inputmodel.variable,'w')|strcmp(inputmodel.variable,'r')
        guifreez(Me, 'unfreeze', 'caem_update_plot23');
        caem('status',['Error: cannot calculate Nyquist diagram for variable ''',...
            inputmodel.variable',''''])
        return
      else
        [RE,IM]=nyquist(inputmodel);
        RE=permute(RE,[3,2,1]); IM=permute(IM,[3,2,1]);
        plot([RE;flipud(RE)],[IM;-flipud(IM)],'parent',ax)
        xlim=[min(RE),max(RE)]; ylim=[min([-IM;IM]),max([-IM;IM])];
        xlim=xlim+diff(xlim)*0.05*[-1,1];
        ylim=ylim+diff(ylim)*0.05*[-1,1];
        set(ax,'xlimmode','auto','ylimmode','auto')
        if diff(xlim)>0, set(ax,'xlim',xlim), end
        if diff(ylim)>0, set(ax,'ylim',ylim), end
        lIM=length(IM); IM2=[-IM;IM]; [maxIM,iIMmax]=max(IM2); [minIM,iIMmin]=min(IM2);
        iREmin=rem(iIMmin-1,lIM)+1;
        iREmax=rem(iIMmax-1,lIM)+1;
        set(ax,'nextplot','add')
        if iREmin<lIM
          if RE(iREmin)<RE(iREmin+1), mark='>'; else mark='<'; end
        else
          if RE(iREmin-1)<RE(iREmin), mark='>'; else mark='<'; end
        end
        if strcmp(mark,'<'), mark2='>'; else mark2='<'; end
        plot(RE(iREmin),IM2(iIMmin),mark,'parent',ax)
        plot(RE(iREmax),IM2(iIMmax),mark2,'parent',ax)
        set(ax,'nextplot','replace')     
      end
    else
      guifreez(Me, 'unfreeze', 'caem_update_plot23');
      caem('status','Error: Cannot plot Nyquist diagram for complex coefficients')
      return
    end
  else
    guifreez(Me, 'unfreeze', 'caem_update_plot23');
    error(['CAEM: Bad plot mode: ',mode])
  end        
  set(ax, 'tag', axis_tag ,'buttondownfcn', bfcn_axes);
  %pause(0) %plot when first plot ready
  
  % store current axis limits
  ax_cur.xlim=get(ax, 'xlim'); ax_cur.ylim=get(ax, 'ylim');
  set(ax, 'userdata', ax_cur);
  % set the same axis
  hCoupled=findobj(allchild(myfig), 'flat', 'tag', 'caem_uic_couplepop');
  if strcmpi(popupstr(hCoupled), 'coupled')
    SetSameAxis(myfig)
    fdident('private','fixlgtck',ax) %fix log tick  
    if istwomodel(myfig)
      % correct "Cost fcn vs. Delay" plot
      h_type=findobj(allchild(myfig), 'flat', 'tag', 'caem_uic_typepop');
      if strcmpi(popupstr(h_type), 'cost function vs. delay')
        h=findall(0,'tag','delay-evolution');
        hp=get(h,'parent'); hp=cat(1,hp{:});
        hp=sort(hp);
        hp1=hp(1); hp2=hp(end);
        for hpi=[hp1,hp2]
          hi=findobj(hpi,'tag','delay-evolution');
          minhi=inf;
          for ii=1:length(hi)
            minhi=min(minhi,min(get(hi(ii),'ydata')));
          end %for ii
          yl=get(hpi,'ylim');
          xl=get(hpi,'xlim');
          if minhi>yl(1)
            sc=yl(1)/minhi;
            zoomin=1 - log10(sc) / log10(yl(2)/yl(1));
            hpli=findobj(hpi,'type','line','linestyle','-');
            if isnumeric(hpli), hpli={hpli}; end
            xmin=inf; xmax=-inf;
            for ii=1:length(hpli)
                if iscell(hpli), xdata=get(hpli{ii},'xdata');
              elseif isa(hpli,'matlab.graphics.chart.primitive.Line'), xdata=get(hpli(ii),'xdata');
              end
              if iscell(xdata)
                xdat=[];
                for iii=1:length(xdata)
                  xdat=[xdat;min(xdata{iii}),max(xdata{iii})];
                end %for iii
                xdata=xdat;
              end
              xmin=min(xmin,min(xdata(:)));
              xmax=max(xmax,max(xdata(:)));
            end %for ii
            if xmax>xmin
              zoomin=zoomin/(xl(2)-xl(1))*1.05*(xmax-xmin);
            end
            for ii=1:length(hi)
              ydata=sc*get(hi(ii),'ydata');
              if isnumeric(ydata), ydata={ydata}; end
              ls=get(hi(ii),'linestyle');
              if ~iscell(ls), ls={ls}; end
              for iii=1:length(ydata)
                if strcmp(ls{iii},'-')
                  ydata{iii}=(ydata{iii}/yl(1)).^zoomin*yl(1);
                end
              end %for iii
              if length(ydata)==1, ydata=ydata{1}; end
              set(hi(ii),'ydata',ydata)
            end %for ii
          end
        end %for hpi
      end
      %disp('Cost fcn vs. Delay plot correction here')
    end
  end
  h_extrafig=findobj(allchild(0), 'flat', 'tag', 'caem_model_zoom_fig');
  if ishandle(h_extrafig)
    % update plot of zoom figure
    name=get(h_extrafig, 'name');
    ix=findstr(name, '#'); setno=str2num(name(ix+1));
    if (setno+1)==str2num(plotno)
      caem('zoom_in_axes', setno+1);
    end
  end
  
  caem('status', ['Plot of model set #'  num2str(str2num(plotno)-1) ' updated.'])
  guifreez(Me, 'unfreeze', 'caem_update_plot23');
  1;
  
  
elseif findstr(p1,'selectbar')
  if findstr(sender, 'external')
    sender=sender(9:end);
  end;
  h_extfig=findall(allchild(0), 'flat', 'Tag', 'caem_view_bar_figure');
  ExternalMode=~isempty(h_extfig);
  
  c=get(myfig, 'children');
  hcrit=findobj(c, 'flat', 'tag', 'caem_uic_critpop');
  hord=findobj(c, 'flat', 'tag', 'caem_uic_modelpop2');
  haxes=findobj(c, 'flat', 'tag', 'caem_axes_axes(1)');
  %   ix1=findstr(p1, '['); ix2=findstr(p1, ']');
  %   ord=p1(ix1+1:ix2-1);
  ord=p2;
  modelstr=get(hord, 'string');
  modelix=0;
  for ix=1:length(modelstr); % find model index from popup
    if strcmp(modelstr{ix}, ord) | strcmp(modelstr{ix}, [ord ' (1)'])
      modelix=ix; break
    end
  end
  if ~modelix
    error(['Model ' ord ' not found.'])
    return   
  end
  criterionstr=popupstr(hcrit);
  bars=allchild(haxes);
  h_bar=findobj(bars, 'flat', 'tag', sender);
  if length(h_bar)>1
    h_bar=h_bar(1);
    caem('status', ['Warning: multiple occurances of model order ' ord])
  end
  userdat=get(h_bar, 'userdata');
  critval=userdat.critval; barstatus=userdat.status;
  if strcmp(seltype, 'normal')
    msg=['Model order: ' ord ',  ' , ...
        criterionstr, ': ' num2str(critval)];
    if strcmp(barstatus, 'CUT')
      msg=[msg '  (Too high, not shown properly)'];
    elseif strcmp(barstatus, 'BEST')
      msg=[msg '  (Best model)'];
    end         
    caem('status', msg)
  else
    msg=['Selecting model ' ord ' with ' , ...
        criterionstr, ': ' num2str(critval)];
    caem('status', msg)
    % select model in popupmenu
    set(hord, 'value', modelix);
    fdtool('callback', 'caem', 'caem_uic_modelpop2', 'caem_uic_modelpop2');  
  end
  
elseif findstr(p1, 'ui_help_advice')    
  models='';
  [models, ix, validation]=GetCurrentModel(2, myfig);
  [models2, ix2, validation2]=GetCurrentModel(3, myfig);
  if isempty(models)
    % no action
  else
    models=models{ix};
  end
  if isempty(models2)
      % no action
  else
    models2=models2{ix2};
  end
  mm=stack(2,models,models2);
  advice(mm)
  
elseif findstr(p1, 'click_on_uicontrol')    
  models='';
  switch sender
    case {'caem_uic_modeltext', 'caem_uic_bmtext', 'caem_uic_f1text', 'caem_uic_frame(1)'}
      infostr='Info on best model in model set #1';
      [models, ix, validation]=GetCurrentModel(2, myfig);
      ix=selbcf(myfig,models);
    case {'caem_uic_m1text', 'caem_uic_f2text', 'caem_uic_frame(2)'}
      infostr='Info on selected model in model set #1';
      [models, ix, validation]=GetCurrentModel(2, myfig);
    case {'caem_uic_m2text', 'caem_uic_f3text', 'caem_uic_frame(3)'}
      infostr='Info on selected model in model set #2';
      [models, ix, validation]=GetCurrentModel(3, myfig);
  end
  if isempty(models)
    % no action
  else
    model=models{ix};
    garrinfo(1001, model, infostr)
  end
  
elseif strcmp(p1,'caem_uic_print')
  %caem print command
  fdgprint(Me)
  caem('status','Print figure done.')
  
elseif strcmp(p1,'caem_mod_print_ps')
  %caem print command
  fdgprint(Me,'ps')
  
elseif strcmp(p1, 'preload')
  % preload, nothing to do
  
elseif strcmp(p1,'resize')
  mindx=640;
  mindy=480;
  scr=get(0,'screensize');
  mainfigmaxx=scr(3);
  mainfigmaxy=scr(4);
  
  if scr(3) == 640
    mindy = 420; %Minimum allowed height of CAEM window
  end;
  
  ch=allchild(myfig);
  if isempty(ch)  % MATLAB 'feature': resize sometimes called when figure created
    return
  end
  model=guidtard(Me, 'MODEL_SINGLE_MULTI');
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
  if fig_offsy+fig_dy > mainfigmaxy
    fig_offsy=20;
  end;
  resize_fcn=get(myfig, 'resizefcn');
  set(myfig, 'resizefcn', '');
  set(myfig,'position',[fig_offsx fig_offsy fig_dx fig_dy]);
  set(myfig, 'resizefcn', resize_fcn);
  axdiff_dx=40;
  pbdiff_dx=10;
  fromframe_dy=75;
  
  pos=get(findobj(ch, 'flat', 'tag','caem_uic_statusframe'),'position');
  set(findobj(ch, 'flat', 'tag','caem_uic_statusframe'),'position',[pos(1) pos(2) fig_dx pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','caem_uic_statustext'),'position');
  set(findobj(ch, 'flat', 'tag','caem_uic_statustext'),'position',[pos(1) pos(2) fig_dx-6 pos(4)]);
  pos=get(findobj(ch, 'flat', 'tag','caem_uic_donepb'),'position');
  set(findobj(ch, 'flat', 'tag','caem_uic_donepb'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
  pos1=get(findobj(ch, 'flat', 'tag','caem_uic_donepb'),'position');
  pos=get(findobj(ch, 'flat', 'tag','caem_uic_cancelpb'),'position');
  set(findobj(ch, 'flat', 'tag','caem_uic_cancelpb'),'position',[pos1(1) pos(2) pos(3) pos(4)]);
  if scr(3) == 640
    set(findobj(ch, 'flat', 'tag','caem_uic_cancelpb'),'position',[pos1(1)-pos(3)-20 pos(2) pos(3) pos(4)]);
  end;   
  pos=get(findobj(ch, 'flat', 'tag','caem_uic_couplepop'),'position');
  set(findobj(ch, 'flat', 'tag','caem_uic_couplepop'),'position',[fig_dx-pos(3)-20 pos(2) pos(3) pos(4)]);
  pos1=get(findobj(ch, 'flat', 'tag','caem_uic_cancelpb'),'position');
  %   pos=get(findobj(ch, 'flat', 'tag','caem_uic_loadmpb'),'position');
  %   set(findobj(ch, 'flat', 'tag','caem_uic_loadmpb'),'position',[pos1(1)-pbdiff_dx-pos(3) pos(2) pos(3) pos(4)]);
  %   pos1=get(findobj(ch, 'flat', 'tag','caem_uic_loadmpb'),'position');
  if strcmp(model, 'single')
    set(findobj(ch, 'flat', 'tag','caem_axes_axes(1)'),'visible','off');
    set(findobj(ch, 'flat', 'tag','caem_uic_frame(1)'),'visible','off');
    set(findobj(ch, 'flat', 'tag','caem_uic_comptext'),'visible','off');
    set(findobj(ch, 'flat', 'tag','caem_uic_critpop'),'visible','off');
    set(findobj(ch, 'flat', 'tag','caem_uic_bmtext'),'visible','off');
    set(findobj(ch, 'flat', 'tag','caem_uic_modeltext'),'visible','off');
    set(findobj(ch, 'flat', 'tag','caem_uic_f1text'),'visible','off');
    set(findobj(ch, 'flat', 'tag','caem_uic_fr1ttext'),'visible','off');
    frame1=get(findobj(ch, 'flat', 'tag','caem_uic_frame(1)'),'position');
    pos=get(findobj(ch, 'flat', 'tag','caem_axes_axes(1)'),'position');
    ax_dx=(fig_dx-20-axdiff_dx-axdiff_dx)/2;
    ax_offsy=frame1(2)+frame1(4)+fromframe_dy;
    ax_dy=fig_dy-20-ax_offsy;
    %
    %Fix for Matlab 6
    hax3=findobj(ch, 'flat', 'tag','caem_axes_axes(3)');
    set(hax3,'position',[fig_dx-20-ax_dx ax_offsy ax_dx ax_dy]);
    bd=get(hax3,'buttondown'); set(hax3,'buttondown',''), drawnow
    set(hax3,'buttondown',bd)
    hax2=findobj(ch, 'flat', 'tag','caem_axes_axes(2)');
    set(hax2,'units','pixels','position',[axdiff_dx ax_offsy ax_dx ax_dy]);
    bd=get(hax2,'buttondown'); set(hax2,'buttondown',''), drawnow
    set(hax2,'buttondown',bd)
    %
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_fr2ttext'),'position');
    pos2=get(findobj(ch, 'flat', 'tag','caem_axes_axes(2)'),'position');
    pos3=get(findobj(ch, 'flat', 'tag','caem_axes_axes(3)'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_fr2ttext'),'position',[pos2(1) pos2(2)+pos2(4) pos2(3) pos(4)]);
    guititle(findobj(ch, 'flat', 'tag','caem_uic_fr2ttext'));
    set(findobj(ch, 'flat', 'tag','caem_uic_fr3ttext'),'position',[pos3(1) pos3(2)+pos3(4) pos3(3) pos(4)]);
    guititle(findobj(ch, 'flat', 'tag','caem_uic_fr3ttext'));
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_typepop'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_typepop'),'position',[pos2(1)+(pos3(1)+pos3(3)-pos2(1))/2-pos(3)/2 pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_linlogpop'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_linlogpop'),'position',[pos2(1) pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_frame(3)'),'position');
    gr_offsx=pos3(1)-pos(1);posfr3=[pos(1)+gr_offsx pos(2) pos3(3) pos(4)];
    set(findobj(ch, 'flat', 'tag','caem_uic_frame(3)'),'position',posfr3);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_m2text'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_m2text'),'position',[pos(1)+gr_offsx pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_modelpop3'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_modelpop3'),'position',[pos3(1)+pos3(3)-pos(3)-10 pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_f3text'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_f3text'),'position',[pos(1)+gr_offsx pos(2) pos3(3)-20 pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_frame(2)'),'position');
    gr_offsx=pos2(1)-pos(1); posfr2=[pos(1)+gr_offsx pos(2) pos2(3) pos(4)];
    set(findobj(ch, 'flat', 'tag','caem_uic_frame(2)'),'position',posfr2);
    %pos=get(findobj(ch, 'flat', 'tag','caem_uic_frame(4)'),'position');
    %posfr4=[pos(1) pos(2) (posfr2(1)+posfr2(3)-pos(1))+5 pos(4)];
    %set(findobj(ch, 'flat', 'tag','caem_uic_frame(4)'),'position', posfr4);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_m1text'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_m1text'),'position',[pos(1)+gr_offsx pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_modelpop2'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_modelpop2'),'position',[pos2(1)+pos2(3)-pos(3)-10 pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_f2text'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_f2text'),'position',[pos(1)+gr_offsx pos(2) pos2(3)-20 pos(4)]);
    
    %???
    %pos=get(findobj(ch, 'flat', 'tag','caem_uic_comparepb'),'position');
    %set(findobj(ch, 'flat', 'tag','caem_uic_comparepb'),'position',[(posfr2(1)+posfr2(3)+posfr3(1))/2-pos(3)/2 pos(2) pos(3) pos(4)]);
    %set(findobj(ch, 'flat', 'tag','caem_uic_copysetpb'),...
    %   'position',[(posfr4(1)+posfr4(3)+posfr3(1))/2-10, posfr2(2)+posfr2(4)*3/4-pos(4), 20, 20]);
    %set(findobj(ch, 'flat', 'tag','caem_uic_rempb'),...
    %   'position',[(posfr4(1)+posfr4(3)+posfr3(1))/2-10, posfr2(2)+posfr2(4)/4, 20, 20]);
    %???
  else
    set(findobj(ch, 'flat', 'tag','caem_axes_axes(1)'),'visible','on');
    set(findobj(ch, 'flat', 'tag','caem_uic_frame(1)'),'visible','on');
    set(findobj(ch, 'flat', 'tag','caem_uic_comptext'),'visible','on');
    set(findobj(ch, 'flat', 'tag','caem_uic_critpop'),'visible','on');
    set(findobj(ch, 'flat', 'tag','caem_uic_bmtext'),'visible','on');
    set(findobj(ch, 'flat', 'tag','caem_uic_modeltext'),'visible','on');
    set(findobj(ch, 'flat', 'tag','caem_uic_f1text'),'visible','on');
    set(findobj(ch, 'flat', 'tag','caem_uic_fr1ttext'),'visible','on');
    frame1=get(findobj(ch, 'flat', 'tag','caem_uic_frame(1)'),'position');
    pos=get(findobj(ch, 'flat', 'tag','caem_axes_axes(1)'),'position');
    ax_dx=(fig_dx-20-axdiff_dx-2*axdiff_dx)/3;
    ax_offsy=frame1(2)+frame1(4)+fromframe_dy;
    ax_dy=fig_dy-20-ax_offsy;
    set(findobj(ch, 'flat', 'tag','caem_axes_axes(1)'),'position',[axdiff_dx ax_offsy ax_dx ax_dy]);
    set(findobj(ch, 'flat', 'tag','caem_axes_axes(3)'),'position',[fig_dx-20-ax_dx ax_offsy ax_dx ax_dy]);
    set(findobj(ch, 'flat', 'tag','caem_axes_axes(2)'),'units','pixels');
    set(findobj(ch, 'flat', 'tag','caem_axes_axes(2)'),'position',[axdiff_dx+(fig_dx-20-axdiff_dx)/2-ax_dx/2 ax_offsy ax_dx ax_dy]);
    %
    %Fix for Matlab 6
    hax3=findobj(ch, 'flat', 'tag','caem_axes_axes(3)');
    bd=get(hax3,'buttondown'); set(hax3,'buttondown',''), drawnow
    set(hax3,'buttondown',bd)
    hax2=findobj(ch, 'flat', 'tag','caem_axes_axes(2)');
    bd=get(hax2,'buttondown'); set(hax2,'buttondown',''), drawnow
    set(hax2,'buttondown',bd)
    hax1=findobj(ch, 'flat', 'tag','caem_axes_axes(1)');
    bd=get(hax1,'buttondown'); set(hax1,'buttondown',''), drawnow
    set(hax1,'buttondown',bd)
    %
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_fr1ttext'),'position');
    pos1=get(findobj(ch, 'flat', 'tag','caem_axes_axes(1)'),'position');
    pos2=get(findobj(ch, 'flat', 'tag','caem_axes_axes(2)'),'position');
    pos3=get(findobj(ch, 'flat', 'tag','caem_axes_axes(3)'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_fr1ttext'),'position',[pos1(1) pos1(2)+pos1(4) pos1(3) pos(4)]);
    guititle(findobj(ch, 'flat', 'tag','caem_uic_fr1ttext'));
    set(findobj(ch, 'flat', 'tag','caem_uic_fr2ttext'),'position',[pos2(1) pos2(2)+pos2(4) pos2(3) pos(4)]);
    guititle(findobj(ch, 'flat', 'tag','caem_uic_fr2ttext'));
    set(findobj(ch, 'flat', 'tag','caem_uic_fr3ttext'),'position',[pos3(1) pos3(2)+pos3(4) pos3(3) pos(4)]);
    guititle(findobj(ch, 'flat', 'tag','caem_uic_fr3ttext'));
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_typepop'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_typepop'),'position',[pos2(1)+(pos3(1)+pos3(3)-pos2(1))/2-pos(3)/2 pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_linlogpop'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_linlogpop'),'position',[pos2(1) pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_frame(3)'),'position');
    gr_offsx=pos3(1)-pos(1);posfr3=[pos(1)+gr_offsx pos(2) pos3(3) pos(4)];
    set(findobj(ch, 'flat', 'tag','caem_uic_frame(3)'),'position',posfr3);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_m2text'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_m2text'),'position',[pos(1)+gr_offsx pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_modelpop3'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_modelpop3'),'position',[pos3(1)+pos3(3)-pos(3)-10 pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_f3text'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_f3text'),'position',[pos(1)+gr_offsx pos(2) pos3(3)-20 pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_frame(2)'),'position');
    gr_offsx=pos2(1)-pos(1);
    gr_offsx=pos2(1)-pos(1); posfr2=[pos(1)+gr_offsx pos(2) pos2(3) pos(4)];
    set(findobj(ch, 'flat', 'tag','caem_uic_frame(2)'),'position',posfr2);
    %pos=get(findobj(ch, 'flat', 'tag','caem_uic_frame(4)'),'position');
    %posfr4=[pos(1) pos(2) (posfr2(1)+posfr2(3)-pos(1))+5 pos(4)];
    %set(findobj(ch, 'flat', 'tag','caem_uic_frame(4)'),'position', posfr4);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_m1text'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_m1text'),'position',[pos(1)+gr_offsx pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_modelpop2'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_modelpop2'),'position',[pos2(1)+pos2(3)-pos(3)-10 pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_f2text'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_f2text'),'position',[pos(1)+gr_offsx pos(2) pos2(3)-20 pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_frame(1)'),'position');
    gr_offsx=pos1(1)-pos(1);
    set(findobj(ch, 'flat', 'tag','caem_uic_frame(1)'),'position',[pos(1)+gr_offsx pos(2) pos1(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_bmtext'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_bmtext'),'position',[pos(1)+gr_offsx pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_modeltext'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_modeltext'),'position',[pos1(1)+pos1(3)-pos(3)-10 pos(2) pos(3) pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_f1text'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_f1text'),'position',[pos(1)+gr_offsx pos(2) pos1(3)-20 pos(4)]);
    pos=get(findobj(ch, 'flat', 'tag','caem_uic_critpop'),'position');
    set(findobj(ch, 'flat', 'tag','caem_uic_critpop'),'position',[pos1(1)+pos1(3)-pos(3) pos(2) pos(3) pos(4)]);
    %
    %???
    %pos=get(findobj(ch, 'flat', 'tag','caem_uic_comparepb'),'position');
    %set(findobj(ch, 'flat', 'tag','caem_uic_comparepb'),'position',[(posfr2(1)+posfr2(3)+posfr3(1))/2-pos(3)/2 pos(2) pos(3) pos(4)]);
    %set(findobj(ch, 'flat', 'tag','caem_uic_copysetpb'),...
    %   'position',[(posfr4(1)+posfr4(3)+posfr3(1))/2-10, posfr2(2)+posfr2(4)*3/4-pos(4), 20, 20]);
    %set(findobj(ch, 'flat', 'tag','caem_uic_rempb'),...
    %   'position',[(posfr4(1)+posfr4(3)+posfr3(1))/2-10, posfr2(2)+posfr2(4)/4, 20, 20]);
    %???
    
  end;
  
  fr2=get(findobj(ch, 'flat', 'tag','caem_uic_frame(2)'),'position');
  fr3=get(findobj(ch, 'flat', 'tag','caem_uic_frame(3)'),'position');
  pos =get(findobj(ch, 'flat', 'tag','caem_uic_comparepb'),'position');
  offsx=fr3(1)-(fr3(1)-(fr2(1)+fr2(3)))/2-pos(3)/2;
  set(findobj(ch, 'flat', 'tag','caem_uic_comparepb'),'position',[offsx pos(2) pos(3) pos(4)]);
  pos =get(findobj(ch, 'flat', 'tag','caem_uic_copysetpb'),'position');
  set(findobj(ch, 'flat', 'tag','caem_uic_copysetpb'), 'position',[offsx pos(2) pos(3) pos(4)]);
  pos =get(findobj(ch, 'flat', 'tag','caem_uic_copypb'),'position');
  set(findobj(ch, 'flat', 'tag','caem_uic_copypb'), 'position',[offsx pos(2) pos(3) pos(4)]);
  pos =get(findobj(ch, 'flat', 'tag','caem_uic_remcopysetpb'),'position');
  set(findobj(ch, 'flat', 'tag','caem_uic_remcopysetpb'), 'position',[offsx pos(2) pos(3) pos(4)]);
  pos =get(findobj(ch, 'flat', 'tag','caem_uic_remcopypb'),'position');
  set(findobj(ch, 'flat', 'tag','caem_uic_remcopypb'), 'position',[offsx pos(2) pos(3) pos(4)]);
  
else 
  if guiinfos('isdevelopment')
    error(['Error: caem.m called with incorrect command: ' p1]) 
  end
end 
%End of function caem


function bestcfi=selbcf(myfig,inpval)
%SELBCF Select best model index
%
criterion=popupstr(findobj(allchild(myfig),'Tag','caem_uic_critpop'));
cfbest=inf; bestcfi=1;
for ii=1:length(inpval)
  if iscell(inpval)&length(inpval{1})==1
    str{ii}=[num2str(length(inpval{ii}.num)-1) '/' num2str(length(inpval{ii}.denom)-1)];
    fitinfoi=inpval{ii}.fitinfo; datai=inpval{ii}.data;
  else
    inpval=inpval{1};
    str{ii}=[num2str(length(inpval(ii).num)-1) '/' num2str(length(inpval(ii).denom)-1)];
    fitinfoi=inpval(ii).fitinfo; datai=inpval(ii).data;
  end
  if isstruct(fitinfoi)
    if isnan(fitinfoi.cf)
      fitinfocrit=NaN; %no information available!
    elseif strcmp(criterion,'Akaike')
      %fitinfocrit=fitinfoi.AIC;
      if isfield(fitinfoi,'MDL'), fitinfocrit=fitinfoi.AIC;
      else
        fitinfocrit=fitinfoi.cf*(1+fitinfoi.freepar/fitinfoi.F);
      end
    elseif strcmp(criterion,'MDL')
      %fitinfocrit=fitinfoi.MDL;***
      if isfield(fitinfoi,'MDL'), MDL=fitinfoi.MDL;
      else
        if any(datai.inputvar), lnf=4; else lnf=2; end
        MDL=fitinfoi.cf*(1+fitinfoi.freepar/(2*fitinfoi.F)*log(lnf*fitinfoi.F));
      end
      fitinfocrit=MDL;
    elseif strcmp(criterion,'Cost Fcn')
      fitinfocrit=fitinfoi.cf;
    elseif strcmp(criterion,'Mean Model Error')
      fitinfocrit=fitinfoi.mmerror;
    else
      error('Criterion not found')
    end
  else %vector
    warning('Old form of fitinfo found')
    if strcmp(criterion,'Akaike')
      fitind=12;
    elseif strcmp(criterion,'MDL')
      fitind=19;
    elseif strcmp(criterion,'Cost Fcn')
      fitind=1;
    elseif strcmp(criterion,'Mean Model Error')
      fitind=10;
    else
      error('Criterion not found')
    end
    try, fitinfocrit=fitinfoi(fitind); catch, fitinfocrit=NaN; end
  end
  if fitinfocrit<cfbest, cfbest=fitinfocrit; bestcfi=ii; end
end
%
%End of selbcf



function str=msgmodel(model)
%MSGMODEL Generate message to display
%
if isempty(model); str=''; return; end
info=model.fitinfo;
if isstruct(info)
  cf=info.cf;
  if ~isnan(cf), cfth=info.cfth; mmerror=info.mmerror;
    if isfield(info,'MDL'), MDL=info.MDL; AIC=info.AIC; 
    else
      if any(model.data.inputvar), lnf=4; else lnf=2; end
      MDL=info.cf*(1+info.freepar/(2*info.F)*log(lnf*info.F));
      AIC=info.cf*(1+info.freepar/info.F);
    end
  else cfth=NaN; AIC=NaN; mmerror=NaN; MDL=NaN;
  end
else
  warning('Old form of fitinfo found')  
  cf=info(1); cfth=info(2); AIC=info(12); mmerror=info(10);
  if length(info)>=19, MDL=info(19); else MDL=NaN; end
end
if imag(mmerror), mmerror=0; end
delay=model.delay;
if isempty(delay), delay=0; end
if findstr(model.variable,'z')|findstr(model.variable,'q'), dunit='samples'; else dunit='s'; end
if findstr(model.variable,'r'), tauRtxt=sprintf(', Tr=%.3g s',get(model,'tauR')); 
else tauRtxt='';
end
repr=model.representation;
if any(findstr(repr,'orthopol')), reprtxt=[', ',repr]; else reprtxt=''; end
if ~isstable(model), unsttxt=', unstable'; else unsttxt=' '; end
if any(findstr(model.errorweighting,'onlin'))
  nltxt=[', ''',model.errorweighting,''''];
else nltxt='';
end
str=sprintf([model.date,'\n','Domain: ',model.variable,'%s%s%s\n',...
    'Delay: %.4g %s\n','Cost: %.4g',', theor: %.4g',nltxt,'\n',...
    'MDL: %.4g\n','Akaike: %.4g\n','Mean model error: %.4g'],...
  reprtxt,tauRtxt,unsttxt,delay,dunit,cf,cfth,MDL,AIC,mmerror);
%
%end of msgmodel

function cross=crossval(myfig, model, crossfdata)
%CROSSVAL cross validation
%model is class of fidmodel, crossfdata is fiddata

guifreez(get(myfig, 'tag'), 'freeze', 'caem_cross_validation');
caem('status', 'Please wait, cross validation in progress...');
if isempty(crossfdata.SisoVariance)
  crossfdata.inputvariance=1; crossfdata.outputvariance=1; 
end
cross={};
for ii=1:length(model)
  di=model{ii};
  if findstr(di.variable,'z'), domain='z';
  else domain=di.variable;
  end
  fs=di.fs;
  NaNv=NaN;
  if domain=='z', runmod.fs=fs;
  else runmod.fscale=fs;
  end
  runmod.itmax=0;
  runmod.algorithm='svd';
  runmod.initset='object';
  runmod.initmodel=di;
  if strcmp(di.coefficients,'complex'), runmod.coefficients='complex'; end
  runmod.plot0='off';
  runmod.plotdens=inf;  
  devrunmod.displaymessages='off';
  crossmodel=elis(crossfdata,domain,...
    length(di.num)-1,length(di.denom)-1,runmod,devrunmod);

  %crossmodel=elis(crossfdata,[],[domain+0,length(di.num)-1,...
  %  length(di.denom)-1, fs],[],['sf',0],...
  %  [inf,NaNv(ones(1,12)),'n'+0],di);
  crossmodel.date=di.date;
  crossmodel.data=crossfdata;
  crossmodel.covariance=[];
  cross{ii}=crossmodel;
  if length(model)>1
    caem('status', sprintf('Cross validation in progress... %3.0f%% done.' ,...
      100*ii/length(model)));
  end
end %for ii 
guifreez(get(myfig, 'tag'), 'unfreeze', 'caem_cross_validation');
% end of crossval


function out=istwomodel(myfig)
%ISTWOMODEL true, if 2nd model plot containes data
%check uses the << pb's enable property
%
h=findobj(allchild(myfig),'flat','tag', 'caem_uic_remcopypb');
% warning: 'on' cannot be examined here --vvv-- because of freeze's 'inactive' state
out=~any(findstr(lower(get(h,'enable')), 'off')); 


function  SetSameAxis(myfig)
% set the same axis for model plots
if istwomodel(myfig)
  c=allchild(myfig);
  hax2=findobj(c, 'flat', 'tag', 'caem_axes_axes(2)');
  oldaxis2=get(hax2, 'userdata'); 
  if isempty(oldaxis2), return, end
  oldxlim2=oldaxis2.xlim; oldylim2=oldaxis2.ylim; 
  if isempty(get(hax2, 'children'))  % no plot, ignore this axis
    oldxlim2=[inf, -inf]; oldylim2=[inf, -inf];
  end
  
  hax3=findobj(c, 'flat', 'tag', 'caem_axes_axes(3)');
  oldaxis3=get(hax3, 'userdata');
  if isempty(oldaxis3), return, end
  oldxlim3=oldaxis3.xlim; oldylim3=oldaxis3.ylim; 
  if isempty(get(hax3, 'children'))  % no plot, ignore this axis
    oldxlim3=[inf, -inf]; oldylim3=[inf, -inf];
  end
  
  
  if ~strcmp(get(hax2, 'xscale'),get(hax3, 'xscale'))
    return
  end
  
  xma=-inf;
  if 0 %GYUSZI! Ez sehogy sem mukodik, pedig itt a warning a set xscale-ben
    hll= findobj(c, 'flat', 'tag', 'caem_uic_linlogpop');
    str=get(hll,'string'); typ=str{get(hll,'value')};
    if any(findstr(typ,'log'))
      xma=min(oldxlim2(1),oldxlim3(1)); %minimum value of lower limit
      if xma<=0
        xma=max(oldxlim2(2),oldxlim3(2))/1e12;
      end
      set([hax2, hax3], 'xscale','log')
    else
      set([hax2, hax3], 'xscale','linear')
    end
  end
  
  new_xlim=[max(min(oldxlim2(1), oldxlim3(1)),xma),...
      max(oldxlim2(2), oldxlim3(2))];
  %
  hll= findobj(c, 'flat', 'tag', 'caem_uic_linlogpop');
  linlogstr=popupstr(hll); enstr=get(hll, 'ena');
  %xlimit to max of data size
  h=findobj(c,'tag','dataplot');
  if ~isempty(h)
    xmind=inf; xmaxd=-inf;
    for hi=h(:)'
      xd=get(hi,'xdata');
      xmind=min(xmind,min(xd));
      xmaxd=max(xmaxd,max(xd));
    end
    if strncmp(linlogstr,'lin',3)|strcmp(enstr,'off')
      dx=(xmaxd-xmind)/20;
      if dx==0, dx=xmaxd/20; end
      if dx==0, dx=1/20/1e3; end
      new_xlim=[xmind-dx,xmaxd+dx];
    elseif strncmp(linlogstr,'log',3)
      dx=(xmaxd/xmind)^(1/20);
      if dx==1, dx=xmaxd^(11/20); end
      if dx==1, dx=1+1e-4; end
      new_xlim=[xmind/dx,xmaxd*dx];
    else error('linlogstr is invalid')
    end
  end
  %
  new_ylim=[min(oldylim2(1), oldylim3(1)), max(oldylim2(2), oldylim3(2))];
  
  %   set([hax2, hax3], 'xscale', linlogstr(1:3), 'xlim', new_xlim, 'ylim', new_ylim)
  %   [num2str(new_xlim), '-->' linlogstr(1:3), ' old:' get(hax2, 'xscale'), get(hax3, 'xscale')]
  if any(~isreal(new_xlim)), new_xlim=real(new_xlim); end
  if any(~isreal(new_ylim)), new_ylim=real(new_ylim); end
  if (diff(new_xlim)>0)&(diff(new_ylim)>0)
    set([hax2], 'xlim', new_xlim, 'ylim', new_ylim)
    set([hax3], 'xlim', new_xlim, 'ylim', new_ylim)
  end
  if strncmp(linlogstr,'log',3)
    fdident('private','fixlgtck',hax2)
    fdident('private','fixlgtck',hax3)
  end
end

function [input_source, modelno, validation]=GetCurrentModel(modno, myfig);
% get current model from modelset modno (2 or 3)
ch=allchild(myfig);
Me=get(myfig, 'tag');
validation=popupstr(findobj(allchild(myfig),'Tag','caem_uic_crosspop'));
if strcmp(lower(validation),'validate')
  input1str='DATA_INPUT_';
else % cross validation
  input1str='DATA_CROSS_';
end         
switch modno
  case 2
    source=[input1str '2'];
    popup='caem_uic_modelpop2';
  case 3
    source=[input1str '3'];
    popup='caem_uic_modelpop3';
end
h=findobj(ch, 'flat', 'tag', popup);
modelno=get(h,'value');
input_source=guidtard(Me, source);

if strcmp(lower(validation),'validate')  
  if isempty(input_source)
    input_source={''}; modelno=1;
  end
else % cross validation, cross data is not yet computed !!
  inpvect=guidtard(Me, ['DATA_INPUT_' num2str(modno)]);
  crossfdata=guidtard(Me, 'DATA_CROSSFDATA');
  if isempty(crossfdata)
    caem('status', 'Error: Cross Data is missing')
    error(['FATAL ERROR: cross fiddata is missing.'])
  else
    old_cross_model=guidtard(Me, ['DATA_CROSS_' num2str(modno)]);
    if length(old_cross_model)~=length(inpvect)
      old_cross_model=cell(size(inpvect));
    end
    empty_ix=[]; ct=0;
    for ix=1:length(inpvect)
      if isempty(old_cross_model{ix})
        ct=ct+1; empty_ix(ct)=ix;
      end
    end
    if ct>0 % perform x-validation 
      old_cross_model(empty_ix)=crossval(myfig, inpvect(empty_ix), crossfdata);
    end
    input_source=old_cross_model;
    guidtawr(Me, ['DATA_CROSS_' num2str(modno)], 'direct', input_source)
  end
end
if isempty(input_source)
  input_source={''}; modelno=1;
end


function SetFigureMode(Me)
% if only one model is available in Set #1 then Scanned Models ... plot is removed
% if more than one model is present, it is switched on

ModelSet1=guidtard(Me, 'DATA_INPUT_2');
Modestr=guidtard(Me, 'MODEL_SINGLE_MULTI');
hExternalBarFig=findobj(allchild(0), 'tag', 'caem_view_bar_figure');
hExternalBarAx=findobj(allchild(hExternalBarFig), 'tag', 'caem_view_bar_external_axes');
if length(ModelSet1) > 1 & strcmp(Modestr, 'single')
  set([allchild(hExternalBarAx); hExternalBarAx], 'visible', 'on')
  guidtawr(Me, 'MODEL_SINGLE_MULTI', 'direct', 'multi')
  caem('resize')
elseif length(ModelSet1) <= 1 & strcmp(Modestr, 'multi')
  set([allchild(hExternalBarAx); hExternalBarAx], 'visible', 'off')
  guidtawr(Me, 'MODEL_SINGLE_MULTI', 'direct', 'single')
  %%%
  %make bar plot invisible (under pole-zero plot)
  myfig=findall(0,'tag',Me);
  hax1=findobj(allchild(myfig), 'flat', 'tag', 'caem_axes_axes(1)');
  set([hax1;allchild(hax1)],'visib','off')
  %%%
  caem('resize')
end


function UpdateCompareIfNeeded(myfig)
% if compare window exists then update if possible
h_comparefig=findobj(allchild(0), 'flat', 'tag', 'caem_compare_model_fig');
if ishandle(h_comparefig)
  caem('compare_zoom')
end
%


function SetCmpEnable(myfig)
hm=findobj(allchild(myfig), 'flat', 'tag','caem_uic_typepop');
h=findobj(allchild(myfig), 'flat', 'tag', 'caem_uic_comparepb');
typstrcell=get(hm,'string');
compdis=[strmatch('TF Magnitudes + Errors',typstrcell);...
    strmatch('TF Magnitudes, Linear Scale',typstrcell);...
    strmatch('TF Magnitudes + TF std''s',typstrcell);...
    strmatch('Cloud',typstrcell);...
    strmatch('Residuals',typstrcell);...
    strmatch('Correlation Test',typstrcell);...
    strmatch('Cost Function vs. Delay',typstrcell)];
% tf+error, tf linear, cloud, corrtest, resid -> no compare
if any(get(hm,'value')==compdis)
  set(h, 'enable', 'off')
else
  if istwomodel(myfig), set(h, 'enable', 'on'), end
end



function out=Convert2InternalFormat(in);
% Internal format is cell array of fidmodels
% Convert array of fidmodels to this format
out={};
if isa(in, 'fidmodel'); 
  for ii=1:length(in) 
    out{ii}=in(:,:,ii); 
  end
else
  error('Not fidmodel data in caem. Possible cause: obsolate session.')
end


function out=Convert2ExternalFormat(in);
% External format is array of fidmodels
% Convert cell array of fidmodels to this format
out='';
if isa(in, 'fidmodel'); 
  out=in;
elseif isa(in, 'cell'); 
  for ii=1:length(in) 
    if isempty(out), out=in{ii}; 
    else out=stack(2,out,in{ii}); 
    end
  end
else
  error('Bad internal fidmodel format in caem.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                CLIPBOARD FUNCTIONS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CopytoClipBoard(Me, clipdata)
place='fdtool_main';
guidtawr(place, 'fdidgui_local_clipboard', 'direct', clipdata);

function clipdata=ReadfromClipBoard(Me)
place='fdtool_main';
clipdata=guidtard(place, 'fdidgui_local_clipboard');

function result=DeleteClipCross(Me)
clipdata=ReadfromClipBoard(Me);
if ~isempty(clipdata)
  data=clipdata.data;
  empty_cross=cell(size(data));
  clipdata.crossdata=empty_cross;
  CopytoClipBoard(Me, clipdata)
end


%Test function:
function propstruct=hgprops(h)
%HGPROPS  Return Handle Gpraphics object properties as structure with true values

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end
if ~ishandle(h), error('h is not a valid handle'), end
props=get(h);
f=fieldnames(props);
for ii=1:length(f)
  props=setfield(props,f{ii},get(h,f{ii}));
end
try
  ad=get(h,'ApplicationData');
  if ~isfield(props,'ApplicationData')
    props=setfield(props,'ApplicationData',ad);
  end
catch
end
if nargout>0
  propstruct=props;
else
  disp(props)
  if isfield(props,'ApplicationData')
    ad=props.ApplicationData;
    disp('ApplicationData:')
    disp(ad)
  end
  hr=findall(h,'tag','rotaObj');
  if ~isempty(hr), disp('rotaObj axes exists'); end
end
%
%End of hgprops

function y=db(x)
%DB  Value of the complex amplitude vector in decibels
y=NaN*zeros(size(x));
ind=find(~isnan(abs(x))&(abs(x)~=0));
if ~isempty(ind), y(ind)=20*log10(abs(x(ind))); end

%End of file
