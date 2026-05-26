function out=gmexp(p1,p2,p3,p4,p5,seltype) 

Me='getmexp';
myfcn='gmexp';

if nargin >0,        
   myfig=findall(0,'tag',Me);
   if nargin == 6
      sender=p5;
      replay_mode='replay';
   else                                                
      seltype=get(myfig,'selectiontype');
      eval(['sender=p', num2str(nargin) ';']);
      replay_mode='normal';
   end
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                 INITIALIZATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(p1, 'init')
   tmp=findall(0,'tag',Me);
   if ~isempty(tmp) 
      % set(tmp,'visible','on');
      %figure(tmp);
      delete(tmp)         
   end
   gmexpdef

   
   fig = figure(...
      'position',[ fig_offsx fig_offsy fig_dx fig_dy ],... 
      'resize','off','tag','average',...
      'Name','Get Matlab Expression',...
      'NumberTitle','off',...
      'MenuBar', 'none', ...
      'tag', 'getmexp',...
      'Color',figure_col,...
      'CloseRequestFcn', ['fdtool(''callback'',''gmexp'',''gmexp_uic_cancelpb'',''gmexp_uic_cancelpb'');'],...
      'handlevisibility', 'off', ...
      'visible','off'); 
   myfig=fig;
   if nargin>=5
     if isstr(p5)
       set(myfig,'Name',p5)
     end
   end
   
   %  Uicontrol Object Creation 
   
   gmexp_uic_donepb = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''gmexp'',''gmexp_uic_donepb'',''gmexp_uic_donepb'')',... 
      'Units','pixels',... 
      'Position',[ donepb_offsx donepb_offsy donepb_dx donepb_dy ],... 
      'BackgroundColor',pushb_bgr_col,... 
      'ForegroundColor',pushb_fg_col,...
      'HorizontalAlignment','center',... 
      'String','Eval',... 
      'Style','pushbutton',... 
      'enable', 'on',...
      'Tag','gmexp_uic_donepb',... 
      'UserData',''); 
    gmexp_uic_cancelpb = uicontrol(... 
      'Parent',fig,...
      'CallBack','fdtool(''callback'',''gmexp'',''gmexp_uic_cancelpb'',''gmexp_uic_cancelpb'')',... 
      'Units','pixels',... 
      'Position',[ cancelpb_offsx cancelpb_offsy cancelpb_dx cancelpb_dy ],... 
      'BackgroundColor',pushb_bgr_col,... 
      'ForegroundColor',pushb_fg_col,...
      'HorizontalAlignment','center',... 
      'String','Cancel',... 
      'Style','pushbutton',... 
      'Tag','gmexp_uic_cancelpb',... 
      'UserData',''); 
    gmexp_uic_text = uicontrol(... 
      'Parent',fig,...
      'Units','pixels',...
      'Position',[ text_offsx text_offsy ...
        text_dx text_dy ],... 
      'BackgroundColor', figure_col,...
        'ForegroundColor',text_fg_col,...
        'String','Enter Matlab Expression. Press enter to check syntax.',... 
        'HorizontalAlignment','left',... 
        'Style','text',... 
        'Tag','gmexp_uic_text',... 
        'UserData',''); 
      
      gmexp_uic_errtext = uicontrol(... 
        'Parent',fig,...
        'Units','pixels',...
        'Position',[ errtext_offsx errtext_offsy  errtext_dx errtext_dy ],... 
        'BackgroundColor', figure_col,...
        'ForegroundColor',text_fg_col,...
        'String','',... 
        'HorizontalAlignment','left',... 
        'Style','text',... 
        'Tag','gmexp_uic_errortext',... 
        'UserData',''); 
      
      gmexp_uic_edit = uicontrol(... 
        'Parent',fig,...
        'CallBack','fdtool(''callback'',''gmexp'',''ui_edit'', ''gmexp_uic_edit'')',...
        'Units','pixels',...
        'Position',[ edit_offsx edit_offsy edit_dx edit_dy ],... 
        'BackgroundColor',edit_bgr_col,...
        'ForegroundColor',edit_fg_col,...
        'String','',... 
        'HorizontalAlignment','left',... 
        'Style','edit',... 
        'Tag','gmexp_uic_edit',... 
        'ToolTipString','Valid MATLAB expression',...
        'UserData',''); 
      
      %  Menu Object Creation 


        %  Axes and Text Object Creation 

   % store caller fcn's name and ID if exists
   guidtawr(Me, 'caller_name', 'direct', p2)
   guidtawr(Me, 'caller_ID', 'direct', p3)
   if nargin>3
      set(gmexp_uic_edit, 'string', p4)
   end
   
   set(fig,'visible','on'); pause(0)
   %try to avoid transparency of figure on laptop - wait with setting:
   set(fig,'windowstyle', 'modal')

elseif strcmp(p1,'gmexp_uic_donepb')
   if gmexp('check_edit')
      commstr = get(findobj(myfig,'Tag','gmexp_uic_edit'), 'String');
      call_fcn=guidtard(Me, 'caller_name');
      call_ID=guidtard(Me, 'caller_ID');
      delete(myfig);
      eval([call_fcn '(''status'', ''Matlab expression evaluated.'' , Me)' ])
      eval([call_fcn '(''gmexp_ready'',''done'', commstr, call_ID, Me)'])
   end
   
   
elseif strcmp(p1,'gmexp_uic_cancelpb')
   call_fcn=guidtard(Me, 'caller_name');
   call_ID=guidtard(Me, 'caller_ID');
   delete(myfig);
   eval([call_fcn '(''gmexp_ready'',''cancel'', [], call_ID, Me)'])
   eval([call_fcn '(''status'', ''Get Matlab expression cancelled.'' , Me)' ])
      

elseif strcmp(p1,'check_edit') % checks input syntax
   edith=findobj(myfig, 'Tag', 'gmexp_uic_edit');
   commstr=get(edith, 'String');
   size_comm=size(commstr); lineno=size_comm(1);
   h_text=findobj(get(myfig, 'children'),'flat', 'tag', 'gmexp_uic_text');
   h_error=findobj(get(myfig, 'children'),'flat', 'tag', 'gmexp_uic_errortext');
   if lineno>1 
      % handle muliple line error (bug ?): replace edit string with its last line
      commstr=commstr(lineno,:);
      set(edith, 'string', commstr);
   end
   if isempty(commstr), 
      out=0;                 
      set(h_text,'string', 'Enter Matlab Expression. Press enter to check syntax.');
      set(h_error,'string', '' );
      return 
   end      
   callID=guidtard(Me, 'caller_ID');
   res = MakeEval(commstr, callID);
   %h_done=findobj(get(myfig, 'children'),'flat', 'tag', 'gmexp_uic_donepb');
   if isa(res, 'double')
      if strcmp(callID, 'integer')
         if floor(res)==res & length(res)==1 &~any(res<0)
            set(h_text,'string','Matlab expression syntax OK.');
            set(h_error,'string', '' );
            out=1;
         else
            set(h_text,'string', 'An integer value expected.');
            set(h_error,'string', '' );
            out=0;
         end
      elseif strcmp(callID, 'nonpositive')
         if (length(res)==1) & (0>=res)
            set(h_text,'string','Matlab expression syntax OK.');
            set(h_error,'string', '' );
            out=1;
         else
            set(h_text,'string', 'A non-positive value expected.');
            set(h_error,'string', '' );
            out=0;
         end
      elseif strcmp(callID, 'posle1')
         if (length(res)==1) & (0<res) & (1>=res)
            set(h_text,'string','Matlab expression syntax OK.');
            set(h_error,'string', '' );
            out=1;
         else
            set(h_text,'string', 'A value is expected in the interval (0,1].');
            set(h_error,'string', '' );
            out=0;
         end
      else
         set(h_text,'string','Matlab expression syntax OK.');
         set(h_error,'string', '' );
         out=1;
      end
   else
      if isstr(res)
         set(h_text,'string', 'Error in expression.' );
         if strcmp(res, 'Error_msg')
           errstr=get(0, 'errormessage');
         else
           errstr=res;
         end
         set(h_error,'string', res );
      else
         errstr='Double value requested';
         set(h_text,'string', 'Error in expression.' );
         set(h_error,'string', errstr );
      end
      out=0;     
   end
   
   
elseif strcmp(p1,'ui_edit')
   gmexp('check_edit');
   
else 
        error(['Error: gmexp.m called with incorrect command:' p1]) 
end 



function out=MakeEval(commstr, varargin)
if strcmpi(varargin{1}, 'freq')
   eval('fs=1; fc=1; df=1;');
elseif strcmpi(varargin{1}, 'ampl')
   eval('fv=1:100; ');
end
out=eval(commstr, '''Error_msg''');
if ~strcmp(varargin{1},'nonpositive')&any(out<0)
  out='Negative element in vector';
end
