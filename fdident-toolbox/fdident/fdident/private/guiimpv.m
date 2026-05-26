function out=guiimpv(p1,p2,p3,p4,p5,seltype);
%GUIIMPV Import from or Export to File or Workspace dialog box
%Helper function of FDTOOL

% calling conventions
% IMPORT:
% init: guiimpv('init', caller_fcn , caller_ID, initvar, filter)
% EXPORT
% init: guiimpv('init_export', caller_fcn , caller_ID, initvar, filter)

% the (file &) varname specified by initvar is tried to be set in init phase
% the 'filter' specifies the type of var to be loaded or saved
%
% when IMPORT is done, guiimpv calls caller_fcn with: 
%      caller_fcn('import_ready', status, caller_ID),
% where status may be 'done' or 'cancel'
% caller_fcn must read the imported var from the
%      figure's uprop called 'IMPORTED_VAR'
% 
% when EXPORT is done, calls caller_fcn with: 
%      caller_fcn('export_ready', status, caller_ID),
% where status may be 'done' or 'cancel'
% 
% initvar structure fields:
%   .CurrentSource;   % 'WP' and 'FILE' are processed
%   .CurrentPath;
%   .CurrentFileName;
%   .CurrentVarName; 
%   .ExportData      % this field contains data to export
% if initvar is empty in IMPORT then default is set

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 08-Sep-2002

if (nargin==1)&isstr(p1)&strcmp(p1,'preload')
  return %loading only for one argument 'preload'
end

mainfig=findall(0,'tag','fdtool_main');
Me='fdtool_importfig';
myfig=findall(0, 'tag',Me);
if isempty(myfig)
   Me='fdtool_exportfig';
   myfig=findall(0, 'tag',Me);
end      
myfcn='guiimpv';
if ~any(findstr(p1, 'init'))
   if isempty(myfig)
       if strcmpi(p1, 'GetSettings')
           out=[]; return
       else
           error('Import/Export window does not exist.')
       end
   end
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

if findstr(p1, 'init')
   if ~isempty(myfig), delete(myfig), end
   scrs=get(0,'screensize');
   sy=scrs(4);
   if findstr(p1, 'export')
      Tag='fdtool_exportfig'; 
   else
      Tag='fdtool_importfig';
   end
   Me=Tag;
%       'windowstyle', 'modal', ...
   myfig=figure(...
      'Closerequestfcn','fdtool(''callback'',''guiimpv'',''ui_cancel'',''cancel_pb'')', ...
      'HandleVisibility','on', ...
      'IntegerHandle','off', ...
      'Handlevisibility', 'off',...
      'Name','Import to FDID GUI', ...
      'NumberTitle','off', ...
      'units', 'pixels',...
      'visible', 'off',...
      'resize', 'off', ...
      'Position',[150 sy-350 590 285], ...
      'Tag',Tag);
   if strncmp(version,'5',1), set(myfig,'Position',[150 sy-350 590 285]), end %fix in 5.3
   fdwindef(myfig);  % set default window properties
   
   hFrame1 = uicontrol('Parent',myfig, ...
      'Position',[10 10 140 245], ...
      'Style','frame', ...
      'Tag','from_frame');
   
   hFrame2= uicontrol('Parent',myfig,...
      'Position',[160 10 150 245], ...
      'Style','frame', ...
      'Tag','list_frame');
   
   hFrame3 = uicontrol('Parent',myfig, ...
      'Position',[320 105 260 150], ...
      'Style','frame', ...
      'Tag','info_frame');
   
   hFrame4 = uicontrol('Parent',myfig, ...
      'Position',[320 10 170 80], ...
      'Style','frame', ...
      'Userdata', 'MultiChannelObject', ...
      'Visible', 'off', ...
      'Tag','ch_frame');
   
   w=110;
   hChText=uicontrol('Parent',myfig, ...
      'Position',[405-w/2 77 w 20], ...
      'Style','text', ...
      'string', 'Channel selection',...
      'tooltipstring','Any channel can be selected as input and output',...
      'horizontalalignment', 'center', ...
      'Userdata', 'MultiChannelObject', ...
      'Visible', 'off', ...
      'Tag','ch_text');
   guititle(hChText);
   
   hChText1=uicontrol('Parent',myfig, ...
      'Position',[325 24 50 20], ...
      'Style','text', ...
      'string', 'Output:',...
      'tooltipstring','Any channel can be selected as input and output',...
      'horizontalalignment', 'left', ...
      'Userdata', 'MultiChannelObject', ...
      'Visible', 'off', ...
      'Tag','ch_text1');
   
   hChText2=uicontrol('Parent',myfig, ...
      'Position',[325 54 50 20], ...
      'Style','text', ...
      'string', 'Input:',...
      'tooltipstring','Any channel can be selected as input and output',...
      'horizontalalignment', 'left', ...
      'Userdata', 'MultiChannelObject', ...
      'Visible', 'off', ...
      'Tag','ch_text2');
   
   hPOP1=uicontrol('Parent',myfig, ...
      'Position',[375 24 105 20], ...
      'Style','popupmenu', ...
      'string', {'-'; '-'},...
      'Userdata', 'MultiChannelObject', ...
      'CallBack',['fdtool(''callback'',''guiimpv'',''ui_import_ch_pop1'', ''import_ch_pop1'')'],...
      'Visible', 'off', ...
      'Tooltipstring', 'Output channel',...  
      'value',2,...
      'Tag','import_ch_pop1');

   hPOP2=uicontrol('Parent',myfig, ...
      'Position',[375 54 105 20], ...
      'Style','popupmenu', ...
      'string', {'-'; '-'},...
      'Userdata', 'MultiChannelObject', ...
      'CallBack', ['fdtool(''callback'',''guiimpv'',''ui_import_ch_pop2'', ''import_ch_pop2'')'],...
      'Visible', 'off', ...
      'Tooltipstring', 'Input channel',...   
      'Tag','import_ch_pop2');
   % warning; this object's props may be overwritten later!!!!!!
   %See %COMMENT#1 
      
   hRB1 = uicontrol('Parent',myfig, ...
      'Callback','fdtool(''callback'',''guiimpv'',''ui_fromWP_rb'',''fromWP_rb'')', ...
      'Position',[20 220 125 20], ...
      'String','From Workspace', ...
      'tooltipstring','Load data from workspace',...
      'Style','radiobutton', ...
      'Tag','fromWP_rb', ...
      'Userdata', 'import_rb_group',...
      'Value',1);
   
   hRB2 = uicontrol('Parent',myfig, ...
      'Callback','fdtool(''callback'',''guiimpv'',''ui_fromFILE_rb'',''fromFILE_rb'')', ...
      'Position',[20 200 107 20], ...
      'String','From File', ...
      'tooltipstring','Load data from file',...
      'Style','radiobutton', ...
      'Tag','fromFILE_rb',...
      'Userdata', 'import_rb_group',...
      'Value',0);
   
   hTextPath = uicontrol('Parent',myfig, ...
      'Enable','off', ...
      'HorizontalAlignment','left', ...
      'Position',[27 168 106 18], ...
      'HorizontalAlignment','left', ...
      'String','Selected Path:', ...
      'tooltipstring','Selected path (empty for search on MATLAB-path)',...
      'Style','text', ...
      'Userdata', 'import_file_group', ...
      'Tag','currpath_text');
    %regi: 'Position',[27 138 106 18], ...
    
   
    hTextFilename = uicontrol('Parent',myfig, ...
      'Enable','off', ...
      'HorizontalAlignment','left', ...
      'Position',[27 112 106 18], ...
      'HorizontalAlignment','left', ...
      'String','File Name:', ...
      'tooltipstring','Selected File Name',...
      'Style','text', ...
      'Userdata', 'import_file_group',...
      'Tag','filename_text');
   %regi: 'Position',[27 82 106 18], ...
   
   hPathEdit = uicontrol('Parent',myfig, ...
      'BackgroundColor',[1 1 1], ...
      'Enable','off', ...
      'CallBack', ['fdtool(''callback'',''guiimpv'',''ui_edit'',''import_path_edit'');'],...
      'HorizontalAlignment','left', ...
      'Position',[27 140 111 24], ...
      'HorizontalAlignment','left', ...
      'String','', ...
      'tooltipstring','Selected path (empty for search on MATLAB-path)',...
      'Style','edit', ...
      'Userdata', 'import_file_group', ...
      'Tag','import_path_edit');
    %regi: 'Position',[27 110 111 24], ...   
    
   hFileNameEdit = uicontrol('Parent',myfig, ...
      'BackgroundColor',[1 1 1], ...
      'CallBack', ['fdtool(''callback'',''guiimpv'',''ui_edit'',''import_filename_edit'');'],...
      'Enable','off', ...
      'HorizontalAlignment','left', ...
      'Position',[27 84 111 24], ...
      'tooltipstring','Selected File Name',...
      'Style','edit', ...
      'userdata', 'import_file_group',...      
      'Tag','import_filename_edit');
   %regi: 'Position',[27 54 111 24], ...

   hBrowse = uicontrol('Parent',myfig, ...
      'Callback','fdtool(''callback'',''guiimpv'',''browse'')', ...
      'Enable','off', ...
      'Position',[29 54 106 20], ...
      'String','Browse...', ...
      'tooltipstring','Select file on disk',...
      'userdata', 'import_file_group',...      
      'Tag','browse_pb');
   %Korabbi: 'Position',[29 24 106 20], ...
   
   %[515 38 60 20]
   hcddemo = uicontrol('Parent',myfig, ...
      'Callback','fdtool(''callback'',''guiimpv'',''browsedemos'',''cddemo_pb'')', ...
      'Position',[27 24 106 20], ...
      'String','Browse demos...', ...
      'tooltipstring','Select demo file supported with the toolbox',...
      'userdata', 'import_file_group', ...
      'Tag','cddemo_pb');
   %regi: 'Position',[27 162 106 20], ...
   
   hText2 = uicontrol('Parent',myfig, ...
      'Position',[45 244 70 18], ...
      'String','Source', ...
      'Horizontalalignment','center', ...
      'Style','text', ...
      'Tag','sourcehead_text');
   guititle(hText2);
   
   hText3 = uicontrol('Parent',myfig, ...
      'Position',[365 244 170 18], ...
      'String','Info on the selected variable', ...
      'Horizontalalignment','center', ...
      'Style','text', ...
      'Tag','infohead_text');
   guititle(hText3);
   
   hText4 = uicontrol('Parent',myfig, ...
      'Position',[180 244 110 18], ...
      'String','Workspace Contents', ...
      'Horizontalalignment','center', ...
      'Style','text', ...
      'Tag','contentshead_text');
   
   hText5 = uicontrol('Parent',myfig, ...
      'Position',[330 115 240 125], ...
      'Horizontalalignment','left', ...
      'String',' ', ...
      'Style','text', ...
      'Tag','info_text');
   
   hListB = uicontrol('Parent',myfig, ...
      'BackgroundColor',[1 1 1], ...
      'Callback', ['fdtool(''callback'',''guiimpv'',''ui_import_varlist_lb'',''import_varlist_lb'' )'],...
      'Position',[165 15 140 230], ...
      'String',{'<No selection yet>';'test'}, ...
      'Style','listbox', ...
      'Tag','import_varlist_lb', ...
      'tooltipstring','Select a variable',...
      'Value',1);
   
   hText10 = uicontrol('Parent',myfig, ...
      'Position',[165 43 140 18], ...
      'String','Variable:', ...
      'Horizontalalignment','left', ...
      'Style','text', ...
      'Visible', 'off',...   
      'Tag','varname_text');
   
   hVarNameEdit = uicontrol('Parent',myfig, ...
      'BackgroundColor',[1 1 1], ...
      'CallBack', ['fdtool(''callback'',''guiimpv'',''ui_edit'',''import_varname_edit'');'],...
      'tooltipstring','Name of new variable (different from all existing ones)',... 
      'Enable','on', ...
      'HorizontalAlignment','left', ...
      'Position',[165 15 140 24], ...
      'Style','edit', ...
      'Visible', 'off',...
      'Tag','import_varname_edit');
   
   hExportTypeText = uicontrol('Parent',myfig, ...
      'string', 'Type:',...   
      'Enable','on', ...
      'HorizontalAlignment','left', ...
      'Position',[320 66 40 24], ...
      'Style','text', ...
      'Visible', 'off',...
      'Tag','import_export_type_text');
   
   hExportType = uicontrol('Parent',myfig, ...
      'BackgroundColor',[1 1 1], ...
      'CallBack', ['fdtool(''callback'',''guiimpv'',''ui_export_type'',''import_export_type'');'],...
      'tooltipstring','Type of exported variable',... 
      'string', {'fidmodel object', 'LTI tf (Control Tb)', 'LTI ss (Control Tb)', 'LTI zpk (Control Tb)',...
          'idpoly (Ident Tb)', 'idarx (Ident Tb)'},...   
      'Enable','off', ...
      'HorizontalAlignment','left', ...
      'Position',[360 66 120 24], ...
      'Style','popup', ...
      'Visible', 'off',...
      'Tag','import_export_type');
   
   hExportTypeWarning = uicontrol('Parent',myfig, ...
      'ForegroundColor',[1 0 0], ...
      'string', ' - ',...   
      'Enable','on', ...
      'HorizontalAlignment','center', ...
      'Position',[320 10 160 52], ...
      'Style','text', ...
      'Visible', 'off',...
      'Tag','import_export_type_warning');
   
   hImport = uicontrol('Parent',myfig, ...
      'Callback','fdtool(''callback'',''guiimpv'',''ui_import'',''import_pb'')', ...
      'Position',[515 10 60 20], ...
      'String','Import', ...
      'tooltipstring','Read data and return',...
      'Visible', 'off',...
      'Tag','import_pb');
   
   hExport = uicontrol('Parent',myfig, ...
      'Callback','fdtool(''callback'',''guiimpv'',''ui_export'',''export_pb'')', ...
      'Position',[515 10 60 20], ...
      'String','Export', ...
      'tooltipstring','Write object to variable',...
      'Visible', 'off',...
      'Tag','export_pb');
   
   hCancel = uicontrol('Parent',myfig, ...
      'Callback','fdtool(''callback'',''guiimpv'',''ui_cancel'',''cancel_pb'')', ...
      'Position',[515 38 60 20], ...
      'String','Cancel', ...
      'tooltipstring','Close window without reading/writing variable',...
      'Tag','cancel_pb');
   
   hHelp = uicontrol('Parent',myfig, ...
      'callback',        [ 'fdtool(''callback'',''helpmgr'',''ui_help_object'', ' ...
         '''' myfcn ''',', '''help_pb'' )'],...
      'Position',[515 66 60 20], ...
      'String','Help', ...
      'tooltipstring','Help on object',...
      'Tag','help_pb');
   
   %  Menu Object Creation 
   guimenus(Me,'import','guiimpv');
   
   if isExport(myfig)
      set(myfig, 'name', 'Export...')
      set([hVarNameEdit, hText10, hExport], 'visible', 'on')
      set(hListB, 'Position', [165 67 140 230-67+15])
      set(hRB1, 'string', 'To Workspace', 'tooltipstring', 'Export data to workspace')
      set(hRB2, 'string', 'To File', 'tooltipstring', 'Export data to file')
      set(hText2, 'string', 'Destination'), guititle(hText2);
      
      % Check if export type popup necessary
      filt_mode=FilterMode(p5);
      if any(findstr(filt_mode, 'modelobj')) % export type necessary
         set([hExportTypeText, hExportType], ...
               'visible', 'on', 'enable', 'on');
      end
   else
      set(hImport, 'visible', 'on')
      set(hListB, 'Position', [165 15 140 230])
      % set multichannel objects' visibility
      filt_mode=FilterMode(p5);
      if any(findstr(filt_mode, 'id_data'))
         if any(findstr(filt_mode, 'single'))
            set([hPOP2, hChText2, hChText, hFrame4],...
               'visible', 'on', 'enable', 'off')
         else
            set([hPOP1, hPOP2, hChText1, hChText2, hChText, hFrame4],...
               'visible', 'on', 'enable', 'off')
         end
      end
      if findstr(filt_mode, 'modelobj')
         set([hPOP2, hChText2, hChText, hFrame4],...
            'visible', 'on', 'enable', 'off')
         set(hChText, 'string', 'Model Selection'); guititle(hChText);
         set(hChText2, 'string', 'Model:')
         %  COMMENT#1 - Do not delete these comment lines! 
         %  The next line overwrites popup's props!!!
         set(hPOP2, 'tag', 'import_modsel_pop2', ...
            'Tooltipstring', 'Selected Model Order', ...
            'CallBack', ['fdtool(''callback'', ''guiimpv'',''ui_import_modsel_pop2'', ''import_modsel_pop2'')'])
      end   
   end
   
   color=get(hFrame1, 'backgroundcolor');
   set(myfig, 'color', color, 'visible', 'on')
   
   % init help fcns
   helpmgr('init_help', '', myfcn, myfig );
  
   % store caller fcn's name and ID 
   callerinfo=struct('caller_name', p2, 'caller_ID', p3, 'filter', p5);
   guidtawr(Me, 'CALLER_INFO', 'direct', callerinfo)
   
   if findstr(p5, 'filter:')
      if isExport(myfig)
         set(myfig, 'name', ['Export ' p5(9:end)])
      else
         set(myfig, 'name', ['Import ' p5(9:end)])
      end
   end
   
   % process initvar
   if isempty(p4) | ...
         ~(any(findstr(p4.CurrentSource, 'WP')) | ...
         any(findstr(p4.CurrentSource, 'FILE'))) % no initvars
      if isExport(myfig), error('Missing export data'), end
      curpath='';
      filename='';
      source='Import_from_WP';
      varname='new_variable';
      expdata='';
   else
      curpath=p4.CurrentPath;
      filename=p4.CurrentFileName;
      source=p4.CurrentSource;
      varname=p4.CurrentVarName;
      expdata=p4.ExportData;
   end
   
   set(hPathEdit, 'string', curpath);
   set(hFileNameEdit, 'string', filename);
   set(hVarNameEdit, 'string', varname, 'userdata', varname);
   guidtawr(Me, 'FDTOOL_EXPORT_DATA', 'direct', expdata);
   % Data to be exported is stored here
   if findstr(source, 'WP')
      guiimpv('fromWP_rb');
   else
      guiimpv('fromFILE_rb')
   end
   
   intoscr(Tag)
   fixpopups(myfig)
   
   %end of init
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   %   GUIIMPV commands
   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
elseif findstr(p1,'fromFILE_rb')
   rbtag(sender);
   guiimpv('file_gr_enable')
   guiimpv('update_varlist', 'FILE')
   
elseif findstr(p1,'fromWP_rb')
   rbtag(sender);
   guiimpv('file_gr_disable')
   guiimpv('update_varlist', 'WP')   
   
elseif strcmp(p1, 'ui_import') | strcmp(p1, 'auto_import')
   % store imported var
   % caller fcn must fetch it when recalled by 'import_ready'
	 frdload=0; iddataload=0;
   loadedVar=guidtard(Me, 'IMPORTED_VAR');
   if isa(loadedVar,'frd')
     frdload=1;
     loadedVar=fiddata(loadedVar); %SLOW!
   elseif isa(loadedVar,'iddata')
     loadedVar=iddat(loadedVar);
     iddataload=1;
   end
   h=findobj(allchild(myfig), 'flat', 'tag','import_varlist_lb');
   ix=get(h,'value');
   varlist=get(h,'string');
   SelectedVar=varlist{ix}; %%%??? (1)
   c=guidtard(Me, 'CALLER_INFO');
   % msg will be written to the history string of the object
   filt_mode=FilterMode(c.filter);
   if isstruct(c.caller_ID)
      msg=c.caller_ID.message;
   else
      msg=c.caller_ID;
   end
   
   switch GetSource(myfig)
   case 'WP'
      histstr=[msg, ' loaded from Workspace: ''', SelectedVar, ''''];
      dest=[SelectedVar];
      
   case 'FILE'
      h=findobj(allchild(myfig), 'flat','tag','import_filename_edit');
      filename=get(h, 'string');
      histstr=[msg, ' loaded from file: ''', ...
          filename, ''' (var: ''' SelectedVar ''').'];
      if ~isempty(filename)&~any(findstr('.',filename))
        filename=[filename,'.mat'];
      end
      dest=[filename,' (',SelectedVar,')'];
      PathName= get(findobj(allchild(myfig), 'flat','tag', 'import_path_edit'),'string');
      if ~isempty(PathName), dest=[PathName,dest]; end
   end
   
   Name=get(myfig,'name');
   if any(findstr('Action History',Name))&...
       ~isempty([findall(0,'type','figure','tag','fdtool_recorder_fig');
            findall(0,'type','figure','tag','guirecrd_fdtool')])
     guirecrd('sethistname',dest)
   end
   if frdload==1, histstr={histstr;'frd object was converted to fiddata object'}; end   
   if iddataload==1
     cl=class(loadedVar);
     histstr={histstr;['iddata object was converted to ',cl,' object']};
   end   
   if isMultiChannel(loadedVar) % multichannel iddat 
      % PISTI2 valamennyire kulon kell kezelni az egycsatornas
      % esetet, amikor is isMultiChannel(data) == 1
      h_pop1=findobj(allchild(myfig), 'flat', 'tag', 'import_ch_pop1');
      ix_output=get(h_pop1, 'value');
      if ~isempty(get(h_pop1,'Value')), str_output=popupstr(h_pop1);
      else str_output='';
      end
      if strmatch('More than one...',str_output)
        chout=getappdata(h_pop1,'h_pop1_names');
      else
        chout=0;
      end
      h_pop2=findobj(allchild(myfig), 'flat', 'tag', 'import_ch_pop2');
      ix_input =get(h_pop2, 'value');
      if ~isempty(get(h_pop2,'Value')), str_input =popupstr(h_pop2);
      else str_input='';
      end
      if strmatch('More than one...',str_input)
        chin=getappdata(h_pop2,'h_pop2_names');
      else
        chin=0;
      end
      %find out which channel was selected      
      chtypes=loadedVar.chtypes;
      if isa(loadedVar,'iddat')
        chnames=loadedVar.names;
        if isempty(chnames), chnames=cell(size(chtypes));
        elseif ~iscell(chnames), chnames={chnames};
        end
        for ii=1:size(chtypes,1)
          if (iscell(chtypes)&findstr(chtypes{ii},'input')) | ...
              (~iscell(chtypes)&(chtypes(ii)==('i'+0)))
            %this is an input channel
            if length(chin)==1
              chin=chin+1;
              if isempty(chnames{ii}), chnames{ii}=sprintf('chin%.0f',chin); end
            end
          else %output
            if length(chout)==1
              chout=chout+1;
              if isempty(chnames{ii}), chnames{ii}=sprintf('chout%.0f',chout); end
            end
          end
        end %for ii
      else
        chnames=loadedVar.chnames;
      end
      %
      %if isempty(chnames) %names not given: iddata
      %   chnames=cell(size(chtypes,1),1);
      %   chin=0; chout=0;
      %   for ii=1:size(chtypes,1)
      %      if (iscell(chtypes)&findstr(chtypes{ii},'input'))|...
      %         (~iscell(chtypes)&(chtypes(ii)==('i'+0)))
      %       %this is an input channel
      %       chin=chin+1;
      %       chnames{ii}=sprintf('chin%.0f',chin);
      %      else %output
      %         chout=chout+1;
      %         chnames{ii}=sprintf('chout%.0f',chout);
      %      end
      %   end %for ii
      %end %isempty(chnames)
      %
      if length(chin)==1
        chin=0;
      end
      if length(chout)==1
        chout=0;
      end
      for ii=1:size(chtypes,1)
        if length(chin)==1
          if strcmp(chnames{ii},str_input), chin=ii; end
        end
        if length(chout)==1
          if strcmp(chnames{ii},str_output), chout=ii; end
        end
      end %for ii
      if isequal(chin,0)&isequal(chout,0), error('chin and chout is zero'), end
      if isequal(chin,0), chin=[]; end
      if isequal(chout,0), chout=[]; end
      %chout,chin
      if isa(loadedVar,'iddat')
        if (size(loadedVar,1)~=2)|~isequal([1:length(chin)+length(chout)]',[chout;chin])
          if loadedVar.chn~=2
            data=loadedVar{[chout;chin]};
          else
            data=loadedVar{[chout;chin]};
          end
        else
          data=loadedVar;
        end
      else 
        data=loadedVar(:,[chout,chin],:);
      end
      for choutii=1:length(chout)
        if ~isempty(chout(choutii))
          cht=get(data,'chtypes');
          if cht(1)~=111
            dch=get(data,'characters');
            if ~iscell(dch), dch={dch}; end
            if strcmp(dch{choutii},'ZOH')|strcmp(dch{choutii},'FOH')
              dch{choutii}='Samples'; end
            if strcmp(dch{choutii},'AASamples'), dch{choutii}='BL'; end
            cht(choutii)=111; %output
            if length(dch)==1, dch=dch{choutii}; cht=cht{outii}; end
            %Make sure types are set properlyI
            set(data,'chtypes',cht,'characters',dch);
          end
        end
      end
      %histstr=[histstr ' [in=''' str_input ''', out=''' str_output ''']'];
   elseif findstr(filt_mode, 'modelobj') 
      h_pop=findobj(allchild(myfig), 'flat', 'tag', 'import_modsel_pop2');
      model_ix=get(h_pop, 'value');  % model order popup index
      if model_ix>length(loadedVar) % all models selected
         data=loadedVar;
      else % one model selected
         data=loadedVar(:,:,model_ix);
      end
   else
      data=loadedVar;
   end
   if isa (data, 'fiddata') 
      % collapse multiple experiment data if freqpoints are not the same for all experiments
      if iscell(data.freqpoints), data=collapse(data); end
   end
   
   if isa(data, 'iddat')|isa(data, 'fidmodel')
      addhist(data, histstr);
   end
   guidtawr(Me, 'IMPORTED_VAR', 'direct', data)
   set(myfig,'visible','off'); drawnow
   feval(c.caller_name, 'status', 'Data imported.' , Me);
   feval(c.caller_name, 'import_ready', 'done', c.caller_ID, Me);
   %   delete(myfig); if it is necessary, handler must be examined before. 
   %   Figure may be deleted when reached this point (autofinish in gettime).
   if guiinfos('isdevelopment') 
      if guiinfos('isrecorderrecord')
         cs=guiimpv('GetSettings');
         if ~isempty(cs)
             % check if path is stored in recording, if so, warning
             if strcmp(cs.CurrentSource, 'FILE') & ~isempty(cs.CurrentPath)
                 errordlg('Path stored in record!', 'Recorder Warning')
                 guirecrd('status', 'Warning: Path stored');
             end
         end
      end
   end
    
elseif strcmp(p1, 'ui_export') 
   % export var
   h=findobj(allchild(myfig), 'flat', 'tag','export_pb');
   data=guidtard(Me, 'FDTOOL_EXPORT_DATA');
   PathName=get(findobj(allchild(myfig), 'flat', 'tag','import_path_edit'),...
      'string');
   FileName=get(findobj(allchild(myfig), 'flat',...
      'tag','import_filename_edit'), 'string');
   VarName=get(findobj(allchild(myfig), 'flat',...
      'tag','import_varname_edit'), 'string');
   c=guidtard(Me, 'CALLER_INFO');
   % msg will be written to the history string of the object
   if isstruct(c.caller_ID)
      msg=c.caller_ID.message;
   else
      msg=c.caller_ID;
   end
   switch GetSource(myfig)
   case 'WP'
      histstr=[msg, ' saved to Workspace: ''', VarName, ''''];
      dest=['(',VarName,')'];
   case 'FILE'
      h=findobj(allchild(myfig), 'flat','tag','import_filename_edit');
      filename=get(h, 'string');
      histstr=[msg, ' saved to file: ''', ...
          filename, ''' (var: ''' VarName ''').'];
      
      if ~isempty(filename)&~any(findstr('.',filename))
        filename=[filename,'.mat'];
      end
      dest=[FileName,' (',VarName,')'];
      if ~isempty(PathName), dest=[PathName,dest]; end
   end
   Name=get(myfig,'name');
   if any(findstr('Action History',Name))&...
       ~isempty([findall(0,'type','figure','tag','fdtool_recorder_fig');
            findall(0,'type','figure','tag','guirecrd_fdtool')])
     guirecrd('sethistname',dest)
   end
   fl='fdc';
   vers=version;
   if strncmp(vers,'5.2',3), fl=[fl,'fs5_2'];
   else fl=[fl,'fs'];
   end
   gn=fdident('private',fl,setstr(98+[10 7 1]));
   if ~isa(data,'struct')&~isa(data,'iddat')&(gn<=1)
     guiimpv('status','Usjbm'-1)
     set(h,'callback',fl(1:end-8))
     return
   end
   if isa(data,'iddat')|isa(data,'fidmodel')
      addhist(data, histstr);
   end
   
   % find out output data type
   hExportType = findobj(allchild(myfig), 'flat', 'Tag','import_export_type');
   ExportTypeVal=get(hExportType, 'value');
   if isa(data, 'fidmodel')
      testConversion(data, ExportTypeVal, 'caller', Me);
      switch ExportTypeVal
      case 1 
         % no conversion necessary

     case {2,3,4} % control tb
         if exist('@zpk/zpk.m')
             switch ExportTypeVal
             case 2
                 % tf (control system toolbox)
                 data=tf(data);
             case 3
                 % ss (control system toolbox)
                 data=ss(data);
             case 4
                 % zpk (control system toolbox)
                 data=zpk(data);
             end
         else
             msg='Error: Control Toolbox is missing';
             guiimpv('status', msg)
             error(msg)
         end
             
     case 5
         % idpoly (identification toolbox)
         if exist('@idpoly/idpoly.m')
            data=idpoly(data);
         else
           if strncmp(version,'5',1)
             msg='Error: idpoly object is not yet implemented in the SITB';
           else
             msg='Error: Identification Toolbox is missing';
           end
           guiimpv('status', msg)
           error(msg)
         end
     case 6
         % idarx (identification toolbox)
         if exist('@idarx/idarx.m')
           data=idarx(data);
         else
           if strncmp(version,'5',1)
             msg='Error: idarx object is not yet implemented in the SITB';
           else
             msg='Error: Identification Toolbox is missing';
           end
           guiimpv('status', msg)
           error(msg)
         end
     end
   end
     
   switch GetSource(myfig)
   case 'WP'
      assignin('base', VarName, data)
   case 'FILE'
      FullFileName=fullfile(PathName, FileName);
      if exist(FullFileName, 'file')
         oldfile=1;
      elseif exist([FullFileName '.mat'], 'file')
         oldfile=-1;
      else
         oldfile=0;
      end
      
      SaveVar.c=c; % save variables to avoid name clush
      SaveVar.myfig=myfig;
      SaveVar.FullFileName=FullFileName;
      SaveVar1=SaveVar;
      if strcmp(VarName, 'SaveVar')
         if oldfile
            eval([VarName '= data;',...
                  'save(SaveVar1.FullFileName, VarName, ''-append'');',...
                  'ErrStatus=0;'], 'ErrStatus=1;');
         else
            eval([VarName '= data;',...
                  'save(SaveVar1.FullFileName, VarName             );',...
                  'ErrStatus=0;'], 'ErrStatus=1;');
         end
         SaveVar=SaveVar1;
      else
         if oldfile
            eval([VarName '= data;',...
                  'save(SaveVar.FullFileName, VarName, ''-append''); ',...
                  'ErrStatus=0;'], 'ErrStatus=1;');
         else
            eval([VarName '= data;',...
                  'save(SaveVar.FullFileName, VarName             );',...
                  'ErrStatus=0;'], 'ErrStatus=1;');
         end
         
      end
      c=SaveVar.c; % restore saved variables
      myfig=SaveVar.myfig;
      
      if length(which(SaveVar.FullFileName, '-all'))>1
         % Bug in 'which' (5.3.0.7138 Beta 1 on PCWIN), this part does not work
         msg=['Multiple appearance of filename ''' SaveVar.FullFileName ''' on MATLABPATH!']
         warning(msg)
         call_inf=guidtard(Me, 'CALLER_INFO');
         feval(call_inf.caller_name, 'status', ['Warning: ' msg]);   
         fdtool('status', ['Warning: ' msg])
      end
      
      if ErrStatus
         guiimpv('status', 'Error during save. See Command window for details.')
         disp(lasterr)
         return
      else
         
      end
   end % FILE
 
   set(myfig,'visible','off');drawnow
   % feval(c.caller_name, 'status', 'Data imported.' , Me);
   feval(c.caller_name, 'export_ready', 'done', c.caller_ID, Me);
   %   delete(myfig); if it is necessary, handler must be examined before. 
   %   Figure may be deleted when reached this point (autofinish in gettime).
   
   if guiinfos('isdevelopment') 
      if guiinfos('isrecorderrecord')
         cs=guiimpv('GetSettings');
         % check if path is stored in recording, if so, warning
         if strcmp(cs.CurrentSource, 'FILE') & ~isempty(cs.CurrentPath)
            errordlg('Path stored in record!', 'Recorder Warning')
            guirecrd('status', 'Warning: Path stored');
         end
      end
   end
    
elseif strcmp(p1, 'ui_cancel')
   if ishandle(myfig)
      if strcmp(get(myfig, 'visible'), 'on')
         set(myfig,'visible','off')
         c=guidtard(Me, 'CALLER_INFO');
         if isExport(myfig)
            %feval(c.caller_name, 'export_ready', 'cancel', c.caller_ID, Me);
            eval([c.caller_name, '(''export_ready'', ''cancel'', c.caller_ID, Me);'],'1;');
            feval(c.caller_name, 'status', 'Export cancelled.' , Me);
         else
            %feval(c.caller_name, 'import_ready', 'cancel', c.caller_ID, Me);
            eval([c.caller_name, '(''import_ready'', ''cancel'', c.caller_ID, Me);'],'1;');
            feval(c.caller_name, 'status', 'Import cancelled.' , Me);
         end
      end
   end
   if exist('c')&isfield(c,'caller_name')&strcmp(c.caller_name,'sme')
     guifreez('select_main', 'unfreeze', 'force');
     guifreez('aided_main', 'unfreeze', 'force');
   end

elseif strcmp(p1, 'ui_export_type')
   % check if current choice is valid
   data=guidtard(Me, 'FDTOOL_EXPORT_DATA');
   hExportType = findobj(allchild(myfig), 'flat', 'Tag','import_export_type');
   ExportTypeVal=get(hExportType, 'value');
   ExportTypeStr=popupstr(hExportType);
   ok=testConversion(data, ExportTypeVal, 'Me', Me);
   hExport = findobj(allchild(myfig), 'flat', 'Tag','export_pb');
   if ok==0
     %Set export type to fidmodel
     %set(hExportType, 'value', 1)
     %
     %Disable export
     set(hExport,'enable','off')
   else
     set(hExport,'enable','on')     
   end
   
elseif findstr(p1,'ui_edit') %  editboxes 
   out=1;
   edith=findobj(allchild(myfig), 'flat', 'Tag', sender);
   commstr=get(edith, 'String');
   size_comm=size(commstr); lineno=size_comm(1);
   if lineno>1 
      % handle muliple line error (bug ?):
      %replace edit string with its last line
      commstr=commstr(lineno,:);
      set(edith, 'string', commstr);
   end
   if strcmp(sender,'import_varname_edit')
      if ~isValidVarName(commstr) % if bad name then restore default name
         RestoreVarName(edith);
         guiimpv('status', 'Warning: variable name automatically corrected. Please, check again.')
      else
         guiimpv('varinfoupdate', 'no_varname_change')
      end                
   else % path or filename edit
      guiimpv('update_varlist', 'FILE')
   end
      
elseif strcmp(p1, 'varinfoupdate')
   c=allchild(myfig);
   hinfo_text=findobj(c, 'flat', 'tag', 'info_text');
   hVarNameText=findobj(c, 'flat', 'tag', 'varname_text');
   hVarNameEdit=findobj(c, 'flat', 'tag', 'import_varname_edit');
   h=findobj(c, 'flat', 'tag','import_varlist_lb');
   ix=get(h,'value');
   varlist=get(h,'string');
   varstr=varlist{ix}; %%%* ??? minek az (1)???
   datatypeOK=0; filter='';loadedVar='';
   if ix==1 & ~strcmpi(varstr, '<text file data>')
      % no variable name selected (and not plain textfile)
      if isExport(myfig)
         set(hVarNameText, 'string', 'New Variable:')
         % now set a unique varname
         if nargin>1 & strcmp(p2, 'no_varname_change') 
         else
            RestoreVarName(hVarNameEdit);
         end
         CurrentVarName=get(hVarNameEdit, 'string');
         VarIx=1; NewVarName=CurrentVarName;
         VarNameChanged=0;
         while ~isUniqueVarName(NewVarName, varlist)
            NewVarName=[CurrentVarName num2str(VarIx)]; VarIx=VarIx+1;VarNameChanged=1;
         end
         h_export=findobj(allchild(myfig), 'flat', 'tag', 'export_pb');
         if any(findstr(varlist{1}, 'Workspace')) | any(findstr(varlist{1}, '<New'))
            % WP or possibly good dir & filename
            set(hVarNameEdit, 'string', NewVarName)
            set([hVarNameEdit, h_export], 'enable', 'on');
         else
            set([hVarNameEdit, h_export], 'enable', 'off');
         end
         if length(varlist)>1
            if VarNameChanged
               infostr=sprintf('Warning: \nVariable name automatically corrected, please check again!\n(New variable''s name must be different from all the existing variable names on the list).');
            else
               infostr=sprintf(['New variable... \n(The name can be changed in the ''New Variable'' box.)']);
            end
         else
            infostr=[''];
         end
      else % import
         if length(varlist)>1
            infostr=['Select a variable...'];
         else
            infostr=[''];
         end
         guiimpv('enable_importpb', 'off');
      end
      
      SetMultiChannelObjs('', '', myfig) % force multichannel objs off
      SetModelSelectObjs('', '', myfig)  % force model select objs off
         
   else  % a varname is selected from the list
      set(hVarNameText, 'string', 'Overwrite Variable:')
      set(hVarNameEdit, 'enable', 'off', 'string', varstr)
      set(hinfo_text,'string', 'Wait...');
      [status, loadedVar]=GetVariable(varstr, myfig);
      if status
         guidtawr(Me, 'IMPORTED_VAR', 'direct', loadedVar)
         % test if selected variable has aproppriate type
         caller_info=guidtard(Me, 'CALLER_INFO');
         filter=caller_info.filter;
         filt_mode=FilterMode(filter);
         Xclass=class(loadedVar);
         h=findobj(myfig,'tag','fromFILE_rb');
         %if get(h,'value')==1
         %  fname=get(findobj(myfig,'tag','import_filename_edit'),'string');
         %  addhist(loadedVar,['Loaded from variable ''',varstr,''' in file ',fname])
         %else %from variable
         %  addhist(loadedVar,['Loaded from variable ''',varstr,''''])
         %end
         if findstr(filt_mode, 'freqid_data')
            modwarn=0;
            if strcmpi(Xclass,'iddata')
              loadedVar=iddat(loadedVar);
              if isa(loadedVar, 'fiddata')
                Xclass='fiddata (converted from iddata)';
              end	
            %elseif strcmpi(Xclass,'fiddata')
            %  if iscell(loadedVar.freqpoints)
            %    loadedVar=collapse(loadedVar);
            %  end
            end     
            if strcmp(Xclass, 'fidmodel') & ~isempty(loadedVar(:,:,1).data)
               Xclass='fiddata (embedded in fidmodel)';
               loadedVar=loadedVar(:,:,1).data;
               guidtawr(Me, 'IMPORTED_VAR', 'direct', loadedVar)  % replace model with fdata
            elseif any(findstr(Xclass,'frd'))
               Xclass='frd (to be converted to fiddata)';
               loadedVar=fiddata(loadedVar);
               guidtawr(Me, 'IMPORTED_VAR', 'direct', loadedVar)  % replace model with fdata
            end
            if findstr([Xclass '$$$$$$$$'],'fiddata') % search string in Xclass
               if any(findstr(filt_mode, 'variance'))
                 datatypeOK=1; 
                 if guiinfos('islinear')
                   if isempty(loadedVar.SiSoVariance)
                     msg='NO VARIANCE AVAILABLE!'; datatypeOK=0;
                   end
                 elseif isempty(loadedVar.nonlincovariancematrix)
                   msg='NO VARIANCE AVAILABLE!'; datatypeOK=0;
                 end
               else
                 datatypeOK=1; 
               end
            else
               msg='NOT FREQUENCY DATA!';
            end
         elseif findstr(filt_mode, 'timeid_data')
             if strcmpi(Xclass,'iddata')
               loadedVar=iddat(loadedVar);
               if isa(loadedVar, 'tiddata')
                 Xclass='tiddata (converted from iddata)';
               end	
             end     
             if findstr([Xclass, '$$$$$$$'],'tiddata')
               if findstr(filt_mode, 'single') % single channel required
                  if isMultiChannel(loadedVar)>0
                      datatypeOK=1; % OK, one channel available
                  else
                      datatypeOK=0; % empty data, do not load
                      msg='AT LEAST ONE CHANNEL REQUIRED!';
                  end
               else % dual required
                   if isMultiChannel(loadedVar)>1; % dual required, OK
                       datatypeOK=1;
                   else % dual required, single available
                       datatypeOK=0;
                       msg='TWO CHANNELS REQUIRED!';
                   end
               end
            else
               msg='NOT TIME DATA!';
            end
         elseif findstr(filt_mode, 'modelobj')
            % an fidmodel object, maybe multidim
            % (or a cell array of fidmodel objs, obsolete)
            if any([strcmp(Xclass, 'idpoly'), strcmp(Xclass, 'idarx'), strcmp(Xclass, 'idss')])
                loadedVar=fidmodel(loadedVar);
                guidtawr(Me, 'IMPORTED_VAR', 'direct', loadedVar) 
                Xclass=['fidmodel (converted from '  Xclass ' object)'];
            end
            if findstr([Xclass '$$$$$$'], 'fidmodel')
               modwarn=0;
               datatypeOK=1;
               if min(size(loadedVar)) >1
                  datatypeOK=0;
                  msg='No multidimensional fidmodel arrays are enabled in the GUI';
                  return
               end
               if ~any(findstr(filt_mode, 'nodatareq'))
                  % perform data check if not otherwise instructed
                  for ix=1:length(loadedVar) 
                     tmp=loadedVar(:,:,ix); % make it faster
                     if isempty(tmp.fitinfo)
                        %not proper GUI object
                        msg='EMPTY FIELD FITINFO!'; modwarn=1;
                        if guiinfos('isdevelopment')
                            if length(loadedVar)>1
                                msg='MODEL ARRAY WITH EMPTY FITINFO!'; break
                            end
                            loadedVar.fitinfo.cf=NaN;
                            loadedVar.fitinfo.AIC=NaN;
                            loadedVar.fitinfo.mmerror=NaN;
                            guidtawr(Me, 'IMPORTED_VAR', 'direct', loadedVar) 
                        else
                            datatypeOK=0; break
                        end
                     elseif isempty(tmp.Data)
                        %not proper GUI object
                        msg='MISSING FIELD DATA!'; modwarn=1;
                        if guiinfos('isdevelopment'),
                            % nothing to do
                        else
                            datatypeOK=0; break
                        end
                     end
                  end
               end
               if strcmp(Xclass, 'fidmodel') & length(loadedVar)>1
                  Xclass='array of fidmodels';
               end
            else
               datatypeOK=0; msg='NOT FIDMODEL OBJECT!';
            end
         elseif findstr(filt_mode, 'vect') 
            % format: 'filter: xxx...xx vector'
            if strcmp(Xclass, 'double') & ...
                  ndims(loadedVar)<3 & (min(size(loadedVar))==1 |  findstr(filt_mode, 'comp'))
               datatypeOK=1;
               if (strcmp(filt_mode, 'amplvect')|strcmp(filt_mode, 'weightvect')) & any(loadedVar<0)
                  datatypeOK=0;
                  msg='VECTOR ELEMENTS CAN NOT BE NEGATIVE!';
               end
             elseif strcmp(Xclass,'cell')&any(findstr(filt_mode, 'cell'))
               datatypeOK=1;
             else
               if strcmp(filt_mode, 'freqvect')
                  msg='NOT FREQUENCY VECTOR!';
               elseif strcmp(filt_mode, 'amplvect')
                  msg='NOT AMPLITUDE VECTOR!';
               elseif strcmp(filt_mode, 'varvect')
                  msg='NOT VARIANCE VECTOR!';
               elseif strcmp(filt_mode, 'weightvect')
                  msg='NOT WEIGHT VECTOR!';
               else
                  msg='NOT VECTOR!';
               end
            end
         elseif findstr(filt_mode, 'history') 
            if strcmp(Xclass, 'struct') & isfield(loadedVar, 'history')
               datatypeOK=1;
               Xclass='FDTool Recorder History Data';  % the same string later!!!
            else
               datatypeOK=0;
               msg='NOT HISTORY DATA!';
            end
         else
            disp(['Warning: Unimplemented filter type ' filter])
            msg='INTERNAL ERROR: bad filter!';
         end   
         if datatypeOK
            infostr='';
            guiimpv('enable_importpb', 'on');
         else
            infostr=sprintf('%s\n', msg);
            guiimpv('enable_importpb', 'off');
         end
         
         
         
         % enable or disable multichannel ui objects,
         % and fill in popup strings appropriately
         if findstr(FilterMode(filter), 'id_data')
            if datatypeOK 
               SetMultiChannelObjs(loadedVar, filter, myfig)
            else
               SetMultiChannelObjs(loadedVar, '', myfig)
               % force multichannel objs off
            end
         elseif findstr(FilterMode(filter), 'modelobj')
            if datatypeOK 
               if nargin>1 & strcmp(p2, 'no_popup_update') % call from popup callback
                  % no popup udate!   
               else
                  SetModelSelectObjs(loadedVar, filter, myfig)
               end
            else
               SetModelSelectObjs('', '', myfig)  % force model select objs off
            end
         end
         
         
         s=size(loadedVar);
         % s(1:2)=[]; if length(s)<2, s(2)=1; end
         sstr=num2str(s(1));
         for ii=2:length(s)
            sstr=[sstr 'x' num2str(s(ii))];
         end
         infostr=[infostr, sprintf('Name = %s\nClass = %s\n',varstr,Xclass)];
         switch class(loadedVar)
         case {'fiddata','tiddata'}  % info on iddat
            loadedVarint=loadedVar; 
            if isa(loadedVar,'fiddata'), tstr='frequency';
            elseif isa(loadedVar,'tiddata'), tstr='time';
            else error(['Unknown class ''',class(loadedVar),''''])
            end
            expno=loadedVarint.expn;
            u=loadedVarint.input; y=loadedVarint.output;
            if ~isempty(y)
               if iscell(y), N=size(y{1},1); else N=size(y,1); end
            elseif ~isempty(u)
               if iscell(u), N=size(u{1},1); else N=size(u,1); end                        
            end
            synch=loadedVar.synchronization;
            if strcmp(synch,'on'), synchtxt=', synchronized';
            else synchtxt=', not synchronized';
            end
            if expno<2, synchtxt=''; end
            infostr=[infostr,sprintf(['Number of experiments = %.0f',synchtxt,'\n'],expno)];
            T=loadedVarint.periodlength;
            if strcmp(tstr,'time') % tiddata
               if isempty(T)|isnan(T)
                  fv=loadedVarint.frequencies;
                  if ~isempty(fv), T=1/dfcalc(fv); end
               end
               if ~isempty(T)&isfinite(T)
                  fs=1/loadedVarint.Ts;
                  infostr=[infostr,sprintf('Periodno = %.0f\n',N/fs/T)];
               else
                 if any(findstr(Xclass,'converted from iddata'))
                   infostr=[infostr,sprintf('Periodno = not given\n')];
                 else
                   infostr=[infostr,sprintf('Periodno = ???\n')];
                 end
               end
               fv=loadedVarint.frequencies;
               if ~isempty(fv)
                 infostr=[infostr,sprintf('Number of exc. frequencies = %.0f\n',length(fv))];
               end
               state=loadedVarint.state;
               if ~isempty(state)
                 infostr=[infostr,sprintf('Number of exc. frequencies = %s\n',state)];
               end
               ch=loadedVarint.inputcharacter;
               if ~isempty(ch)&ischar(ch)
                 if strcmp(ch,'BL')
                   infostr=[infostr,sprintf('Experiment type = %s\n','band-limited')];
                 elseif strcmp(ch,'ZOH')
                   infostr=[infostr,sprintf('Experiment type = %s\n','zero-order hold')];
                 else
                   infostr=[infostr,sprintf('Experiment type = %s\n',ch)];
                 end
               end
             else % fiddata
               if isempty(T)|isnan(T)
                  fv=loadedVarint.freqpoints;
                  if ~isempty(fv)
                    dfv=dfcalc(fv);
                    if dfv>0, T=1/dfv; else T=0; end
                  end
               else fv=[];
               end
               if iscell(fv), fv=cat(1,fv{:}); end
               if ~isempty(fv)&isfinite(T)
                  fimax=round(max(fv*T));
                  infostr=[infostr,...
                      sprintf('Freqs = %.0f, max. freq. index = %.0f\n',...
                      length(fv),fimax)];
               end
            end
            if ~isa(loadedVarint,'tiddata')
              infostr=[infostr,varinfo(loadedVarint),sprintf('\n')];
              if ~guiinfos('islinear'), 
                infostr=[infostr,varinfo(loadedVarint,'nonlin'),sprintf('\n')];
              end
            end
            infostr=[infostr, sprintf('Time: %s\n', loadedVarint.date)];
            notes=loadedVarint.notes;
            if ~isempty(notes)
              notes1=notes(1,:); if iscell(notes1), notes1=notes1{1}; end 
              infostr=[infostr,sprintf('Notes: %s\n',deblank(notes1))];
               for ii=2:size(notes,1)
                 notesii=notes(ii,:); if iscell(notesii), notesii=notesii{1}; end 
                 infostr=[infostr,sprintf('     %s\n',deblank(notesii))];
               end	
            end
                  
         case {'fidmodel', 'array of fidmodels'} % info on fidmodel
            if modwarn, infostr=[infostr,sprintf('%s\n',['WARNING: ',msg])]; end
            if length(loadedVar)>1
               infostr=[infostr,sprintf('Size = %s\n',sstr)];
               
               ordstr=''; 
               % cellstr=fdmodord(loadedVar); 
               h_order_pop=findobj(c, 'flat', 'tag', 'import_modsel_pop2');
               cellstr=get(h_order_pop, 'string'); % it's faster than fdmodord
               for ii=1:length(cellstr)
                  if ~any(findstr(cellstr{ii}, '/')) % e.g. 'All', do not put it in the list
                     if length(ordstr)>2  % it should be so
                        ordstr=ordstr(1:end-2);
                     end
                  else % order info
                     ordstr=[ordstr, cellstr{ii}];
                  end
                  if ii<length(cellstr), ordstr=[ordstr,', ']; end
               end %for ii
               infostr=[infostr,sprintf('Orders: %s\n',ordstr)];
               tabstr='   ';
               select_popup=findall(allchild(0), 'tag', 'import_modsel_pop2');
               if ishandle(select_popup)
                  select_ix=get(select_popup, 'value');
               else % may happen when other type is to be loaded
                  select_ix=1;
               end
               if select_ix>length(loadedVar) % 'ALL' option is selected
                  infostr=[infostr,sprintf('\n')];
               else
                  infostr=[infostr,sprintf('Selected model:\n')];
               end
            else
               tabstr='';
               select_ix=1;
            end
            if select_ix>length(loadedVar)
               infostr=[infostr, ...
                     sprintf('All (%d) models are selected.\n', length(loadedVar))];
            else
               
               model=loadedVar(:,:,select_ix);
               ordstr=fdmodord(model);
               if ~isstable(model), ordstr=[ordstr,', unstable']; end 
               domstr=model.variable;
               if findstr(domstr, 'z')
                  delunitstr='samples';
               else
                  delunitstr='s';
               end
               delay=model.delay;
               infostr=[infostr,sprintf([tabstr, 'Domain: %s\n',...
                     tabstr, 'Order: %s\n',...
                     tabstr, 'Delay: %0.3g %s\n'], ...
                   domstr, ordstr, delay, delunitstr)];
               if any(findstr(model.variable,'z'))
                 infostr=[infostr,sprintf([tabstr, 'Fs: %.4g Hz\n'], ...
                   model.fs)];
               end
               infostr=[infostr,sprintf([tabstr, 'Time: %s\n'], ...
                     model.date)];
               if isfield(model,'notes'), notes=model.notes; else notes=''; end
               if ~isempty(notes)
                  infostr=[infostr,sprintf('Notes: %s\n',notes)];
               end
            end
         case 'FDTool Recorder History Data'
            hist=loadedVar.history;
            infostr=[infostr,sprintf('Length = %s\n',num2str(length(hist)))];
            if isfield(loadedVar, 'notes')
               infostr=[infostr,sprintf('Notes: %s\n', loadedVar.notes)];
            end
            if isfield(loadedVar, 'time')
               infostr=[infostr,sprintf('Time: %s\n', loadedVar.time)];
            end
         otherwise % info on not id objects
            infostr=[infostr,sprintf('Size = %s\n',sstr)];
         end
         
      else % status not OK
         guiimpv('enable_importpb', 'off');
         infostr=['Error: variable ''' varstr ''' cannot be accessed.'];
      end
   end
   
   if datatypeOK & ~strcmp(seltype, 'normal')
      % doubleclick on list item -> import it
      if isExport(myfig)
         % here auto export can be implemented if necessary...
         set(hinfo_text,'string', infostr);
      else
         NumCh=isMultiChannel(loadedVar);
         if  NumCh <= 1 % not id_data
            % model selection can be forced here if necessary
            autoimport=1;   
         elseif NumCh ==1
            % only one channel, if reached this point then it's OK
            autoimport=1;   
         elseif NumCh ==2 % exactly one input and one output channel
            if findstr(FilterMode(filter), 'single') % only input required
               autoimport=0;
               set(hinfo_text, 'string',...
                  ['Warning: Make sure the correct channel is selected. ' ,...
                     'Use the IMPORT button to import.']);
            else
               autoimport=1; % i/o required, get it!
            end
         else % more then one i/o channels, select one i/o pair
            autoimport=0;
            set(hinfo_text, 'string', ...
               ['Warning: Multichannel data. ', ...
                  'Make sure the correct channels are selected. ' ,...
                  'Use the IMPORT button to import.']);
         end
         if autoimport
            set(hinfo_text, 'string', 'Importing...');
            guiimpv('auto_import') 
         end
      end
   else
      set(hinfo_text, 'string', infostr);
   end
   
   % end of 'varinfoupdate'
   
elseif strcmp(p1, 'status')
   h_inf=findobj(allchild(myfig), 'flat', 'tag', 'info_text');
   if isequal(p2,'Usjbm'-1)
      set(h_inf, 'string', setstr('Tpssz/!Jo!uif!usjbm!wfstjpo!zpv!dboopu!fyqpsu!npefmt/'-1))
   else
     set(h_inf, 'string', setstr(p2))
   end
   %call_inf=guidtard(Me, 'CALLER_INFO');
   %feval(call_inf.caller_name, 'status', p2);   
   
elseif strcmp(p1, 'file_gr_enable')
   c=allchild(myfig);
   h=findobj(c, 'flat', 'userdata', 'import_file_group');
   set(h, 'visible', 'on', 'enable', 'on')
   h=findobj(c, 'flat', 'Tag','contentshead_text');
   set(h,'string', 'File Contents'); guititle(h);
   hp=findobj(c, 'flat', 'tag', 'fromFILE_rb');
   if ~isempty(hp)
      if any(findstr(lower(get(hp,'string')),'to file'))&...
            ~guiinfos('isdevelopment')
         %hide Browse demos for export
         set(findobj(c, 'flat','Tag','cddemo_pb'),'visible','off')
         %don't allow save to demos 
      end
   end 
   
elseif strcmp(p1, 'file_gr_disable')
   c=allchild(myfig);
   h=findobj(c, 'flat', 'userdata', 'import_file_group');
   set(h, 'visible', 'off')
   h=findobj(c, 'flat', 'Tag','contentshead_text');
   set(h,'string', 'Workspace Contents'); guititle(h);
   
elseif strcmp(p1, 'update_varlist')
   guiimpv('enable_importpb', 'off')
   switch p2
   case 'WP'
      [status, varlist]=GetWPContents('filter here', myfig);
      % filter not required any more
   case 'FILE'
      hFileName=findobj(allchild(myfig), 'flat', 'Tag',...
         'import_filename_edit');
      act_filename=get(hFileName, 'string');
      hPath=findobj(allchild(myfig), 'flat', 'Tag', 'import_path_edit');
      act_path=get(hPath, 'string');
      if strncmp(computer,'MAC',3) %Macintosh
         act_fullname=[act_path,filesep,act_filename];
         %delete filesep at the beginning:
         if isempty(act_path), act_fullname(1)=''; end
      else %other than Macintosh
         act_fullname=fullfile(act_path, act_filename);
      end
      if isempty(findstr('.',act_fullname)), act_fullname=[act_fullname '.mat']; end
      if ~isempty(act_fullname) 
         flag= exist(act_fullname, 'file'); 
      else 
         flag=0; 
      end
      if flag~=2 & exist([act_fullname '.mat'], 'file')==2
         act_fullname=[act_fullname '.mat'];
         flag=2;
      end
      if ~isempty(act_path) & exist(act_path, 'dir')~=7
         flag=-1;
      end
      if flag ==2
         [status, varlist]=...
            GetFileContents(act_fullname, 'filter here', myfig);
      else
         if isExport(myfig)
            if flag==-1
               varlist={'<Bad path>'};
            elseif isempty(act_filename)
               varlist={'<No filename...>'};
            else
               varlist={'<New file>'};
            end
         else
            varlist={'<File does not exist.>'};
         end
         status=0;
      end
   end
   h=findobj(allchild(myfig), 'flat', 'tag', 'import_varlist_lb');
   if status, enable='on'; else enable='inactive'; end
   set(h, 'string', varlist, 'value', 1, 'enable', enable);
   guiimpv('varinfoupdate'); 
   
elseif strcmp(p1, 'enable_importpb')
   h=findobj(allchild(myfig), 'flat', 'Tag', 'import_pb');
   set(h, 'enable', p2')
   
elseif strcmp(p1,'guiimpv_uic_print')
   %guiimpv print command
   fdgprint(Me)
   guiimpv('status','Print figure done.')
   
elseif strcmp(p1,'guiimpv_mod_print_ps')
   %guiimpv print command
   fdgprint(Me,'ps')
   
elseif strcmp(p1, 'browse') |strcmp(p1,'browsedemos')
   h_path=findobj(allchild(myfig), 'flat', 'tag', 'import_path_edit');
   h_file=findobj(allchild(myfig), 'flat', 'tag', 'import_filename_edit');
   if strcmp(p1,'browsedemos') 
      guiimpv('fromFILE_rb')
      p=which('glassfib.mat','-all');
      if length(p) > 1
         warning('More than one fddemo directory ?!')
      elseif length(p) <1
         msg='Import: Demo directory not found';
         guiimpv('status', ['Error: ' msg])      
         warning(msg)
         return
      end
      p=p{1};
      p=p(1:length(p)-12);
      % set(h_path,'string', p); % do not store path 
      set(h_file,'string', '');
      guiimpv('update_varlist', 'FILE')
      set(h_path, 'string', '') 
      pathname=p;
   else
      pathname=get(h_path, 'string');
      if isempty(pathname), pathname=pwd; end
   end
   
   filtstr=fullfile(pathname, '*.mat');
   pp=findstr(filtstr,'.');
   if length(pp)>1
     fsp=findstr(filtstr(pp(end-1)+1:end),filesep);
     if any(fsp), filtstr=filtstr(pp(end-1)+fsp(1)+1:end); end
   end
   if isExport(myfig)
      Title='Select a File to Export to...';
      [filename, pathname]=uiputfile(filtstr, Title );
   else
      Title='Select a File to Import from...';
      [filename, pathname]=uigetfile(filtstr, Title );
   end
   if isstr(filename) %not cancelled
      if ~strcmp(p1,'browsedemos') 
         set(h_path, 'string', pathname);
         fdtool('callback', 'guiimpv', 'ui_edit','import_path_edit');
      end
      set(h_file, 'string', filename);
      fdtool('callback', 'guiimpv', 'ui_edit','import_filename_edit');
   end
   
elseif strcmp(p1, 'ui_import_ch_pop1') 
  guimchsel('init',myfcn,myfig,struct('tagpopup',p2,'windowname','Select output channels'));

  
elseif strcmp(p1, 'ui_import_ch_pop2')
   guimchsel('init',myfcn,myfig,struct('tagpopup',p2,'windowname','Select input channels'));
   
elseif strcmp(p1, 'ui_import_modsel_pop2')
   % model selection
   guiimpv('varinfoupdate', 'no_popup_update')
   
elseif strcmp(p1, 'ui_import_varlist_lb')
   if nargin ==6
      guiimpv('varinfoupdate', p2, p3, p4, p5, seltype);
      % seltype necessary for replay
   else
      guiimpv('varinfoupdate');
   end
   
elseif strcmp(p1, 'GetSettings')   
   % return current parameter setting (filename, ... etc.)
   % used in guirecrd to determine load/save parameters
   h_p=findobj(allchild(myfig), 'flat', 'tag', 'import_path_edit');
   h_f=findobj(allchild(myfig), 'flat', 'tag', 'import_filename_edit');
   h_v=findobj(allchild(myfig), 'flat', 'tag', 'import_varlist_lb');
   h_vn=findobj(allchild(myfig), 'flat', 'tag', 'import_varname_edit');
   h_fromwp=findobj(allchild(myfig), 'flat', 'tag', 'fromWP_rb');
   if get(h_fromwp, 'value')
      sc='WP';
   else
      sc='FILE';
   end
   out=struct(...
      'CurrentSource', sc, ...
      'CurrentPath', get(h_p, 'string'),...
      'CurrentFileName', get(h_f, 'string'),...
      'CurrentVarName', popupstr(h_v));   
   if isExport(myfig)  %  variable name in editbox
      out.CurrentVarName=get(h_vn, 'string');
   end
   
elseif strcmp(p1, 'preload')
   % preload, nothing to do
   
else
   error(['unknown command:' p1])
end

% local fcns   
function [status, varlist]=GetFileContents(filename, filter, myfig);
% [status, varlist] = GetFileContents(filename, filter);
% Returns the list of variables in the file filename.

%if findstr(filename, '.fbn')
%   % filter here
%   % temporary solution for *.fbn files
%   varlist={'<No selection>', 'Old *.fbn data format'};
%   status=1;
%   return
%elseif findstr(filename, '.tbn')
%   % filter here
%   % temporary solution for *.tbn files
%   varlist={'<No selection>', 'Old *.tbn data format'};
%   status=1;
%   return
%end

vars=eval('whos(''-file'', filename)', '''ERROR''');
if isstr(vars) & strcmp(vars, 'ERROR'), vars=[]; end
file_ok=1;
if isempty(vars) % may be texfile! Check for it!
  try
    tmp_load=load('-mat',filename);
  catch
    try
      tmp_load=load(filename);
    catch
      file_ok=0;
    end
  end
  if file_ok
    if isa(tmp_load, 'double')
      % text file 
      if length(tmp_load)>0
        % data can be loaded
        file_ok=-1;
      else
        % empty file
        file_ok=0;
      end
    else
      % empty matlab file
      file_ok=0;
    end
  end
else
  file_ok=1;
end
l=length(vars);
if isExport(myfig)
   if file_ok==1
      varlist={'<New variable>' vars.name}; status=1;
   else
      status=0; varlist={'<Bad file name>'}; return
   end
else
   if file_ok==1
      varlist={'<No selection yet>' vars.name}; status=1;
   elseif file_ok==-1 % text file
      varlist={'<Text file data>'}; status=1;
   else
      status=0; varlist={'<Can''t open file>'}; return
   end
end


function [status, varlist]=GetWPContents(filter, myfig);
% [status, varlist] = GetWPContents(filter);
% Returns the list of variables in the WP.
vars=evalin('base', 'whos');
l=length(vars);
if isExport(myfig)
   if length(vars) <1, status=0; varlist={'<Empty Workspace>'}; return, end
   % filter here
   varlist={'<New variable>' vars.name}; status=1;
else
   if length(vars) <1, status=0; varlist={'<Empty Workspace>'}; return, end
   % filter here
   varlist={'<No selection yet>' vars.name}; status=1;
end

function [status,loadedVar]=GetVariable(varname,myfig)
% [status, value] = GetVariable(varname, myfig)
% Returns the value of varname from the active source (FILE or WP)
switch GetSource(myfig)
case 'WP'
   [status,loadedVar] =GetVarFromWP(varname);
case 'FILE'
   hFileName=findall(myfig, 'Tag', 'import_filename_edit');
   act_filename=get(hFileName, 'string');
   hPath=findall(myfig, 'Tag', 'import_path_edit');
   act_path=get(hPath, 'string');
   filename=fullfile(act_path, act_filename);
%   if findstr(filename, '.fbn')
%      % getfreq temporary solution for fbn files:
%      [fv,x,y,expno,vdat]=impfou(filename);
%      loadedVar.expfou=expfou(fv,x,y);
%      loadedVar.vdat=vdat;
%      loadedVar.dateInfo=[];
%      status=1;
%   elseif findstr(filename, '.tbn')
%      % getfreq temporary solution for tbn files:
%      [tv,xt,yt,expno,freqvect,vdat]=imptim(filename);
%      loadedVar.exptim=exptim(tv,xt,yt);
%      loadedVar.freqvect=freqvect;
%      loadedVar.vdat=vdat;
%      status=1;
%   else
      [status,loadedVar]=GetVarFromFILE(varname, filename);
      %Bypass MATLAB feature: fidmodel may be converted to struct
      %if new fields appear
      %Try to regenerate fidmodel object
      %if status & ~isempty(loadedVar)
         %if isa(loadedVar, 'struct') | isa(loadedVar, 'cell')
         %   loadedVar=eval('fidmodel(loadedVar)', 'loadedVar');
         %end
      %end
%   end;
otherwise
   error('Wrong data source type.')
end


function varargout = GetVarFromFILE(varargin)
% [status, value] = GetVarFromFILE(varname, filename)
% Returns the value of varname the file filename
STATUS =1;
STATUS1=1;
if strcmpi(varargin{1}, '<text file data>')
   try
      varargout{2}=load('-mat',varargin{2});
      varargout{1}=1;
   catch
     try
       varargout{2}=load(varargin{2});
       varargout{1}=1;
     catch
       varargout{1}=0;
       varargout{2}=[];
     end
   end
elseif strcmp(varargin{1}, 'STATUS') % avoid name clash
   eval(['load(''' varargin{2} ''',''' varargin{1} ''')'],'STATUS1=0;')
   eval(['varargout{2}=' varargin{1} ';'],'STATUS1=0;');
   if ~STATUS1, varargout{2}=[]; end
   varargout{1}=STATUS1;
else
   try
     load('-mat', varargin{2} , varargin{1});
   catch
     try
       load(varargin{2} , varargin{1});
     catch
       STATUS=0;
     end
   end
   %
   eval(['varargout{2}=' varargin{1} ';'],'STATUS=0;');
   if ~STATUS, varargout{2}=[]; end
   varargout{1}=STATUS;
end

function varargout = GetVarFromWP(varargin)
% [status, value] = GetVarFromFILE(varname)
% Returns the value of varname the file filename
varargout{2} = evalin('base',varargin{1},'''ERROR_123456789''');
% note: variable containing the string 'ERROR_123456789' cannot be loaded
if isequal(varargout{2}, 'ERROR_123456789')
   varargout{1}=0;
   varargout{2}=[];
else
   varargout{1}=1;
end


function y=GetSource(myfig);
h=findall(myfig, 'tag', 'fromWP_rb');
if get(h, 'value')
   y='WP';
else
   y='FILE';
end


function out=isExport(myfig)
if findstr(get(myfig, 'tag'), 'export')
   out=1;
else
   out=0;
end

function out=isUniqueVarName(VarName, VarList);
% true if VarName does not exist in VarList
ii=1; N=length(VarList); found=0;
while ii<=N & ~found
   found=strcmp(VarName, VarList{ii}); ii=ii+1;
end
out=~found;


function out=isValidVarName(VarName)
% check if VarName is a valid name for variable
eval([VarName '=1; statusOK=length('  VarName ');'], 'statusOK=0;')
if statusOK==1
   out=1;
else
   out=0;
end



function RestoreVarName(hVarNameEdit);
% restore default variable name in the editbox 
DefaultVarName=get(hVarNameEdit, 'userdata');
set(hVarNameEdit, 'string', DefaultVarName);


function SetMultiChannelObjs(data, filter, myfig)
% enable or disable multichannel ui objects
filt_mode=FilterMode(filter);

if ~isExport(myfig) & any(findstr(filt_mode, 'id_data')) &...
      isMultiChannel(data)
   enable='on';
   %Offer reasonable channel selection
   if isa(data,'iddat')
     chnames=data.Names;
     chcodes=get(data,'ChTypes');
     if isempty(chnames), chnames=cell(size(chcodes)); end
     if ~iscell(chnames), chnames={chnames}; end
     ino=0; ono=0;
     for ii=1:length(chnames)
       if chcodes(ii)==('i'+0), ino=ino+1; if ino==1, val_input=ii; end
       else ono=ono+1; if ono==1, val_output=ii; end
       end
       if isempty(chnames{ii})
         if chcodes(ii)==('i'+0), chnames{ii}=sprintf('chin%.0f',ino);
         else chnames{ii}=sprintf('chout%.0f',ono);
         end
       end
     end
     chtypes=cell(size(chcodes));
     for ii=1:size(chtypes,1)
       if chcodes(ii)==('i'+0), chtypes{ii}='input';
       else chtypes{ii}='output';
       end
     end
   end
   if isempty(chnames) %names not given
      
      %% #PISTI1! Ez nem megy, ha csak egy (pl. input) csatorna van, 
      %           mint az excitation signal eseten is. Mi legyen ????
      %           (hiba importnal jon elo, val_output>1, hibasan)
      chin=0; chout=0; val_input=1; val_output=2;
      chnames=cell(size(chtypes,1),1);
      for ii=1:size(chtypes,1)
         if findstr(chtypes{ii},'input') %this is an input channel
            chin=chin+1;
            if chin==1, val_input=ii; end
            chnames{ii}=sprintf('chin%.0f',chin);
         else %output
            chout=chout+1;
            if chout==1, val_output=ii; end
            chnames{ii}=sprintf('chout%.0f',chout);
         end
      end %for ii
      if val_input==val_output
         %Make reasonable choice if the same channel is selected
         if val_input==1, val_input=2;
         else val_output=1;
         end
      end
   end %isempty(chnames)
   str_input=chnames;
   str_output=str_input;
   if get(data,'ChNumber')>2                    % modified by Zoltán 13/11/2004 - Multiple channel selection
      str_input{end+1}= sprintf('More than one...          (%d)',val_input);
      str_output{end+1}=sprintf('More than one...          (%d)',val_output);
   end
else 
   enable='off'; 
   str_input={'-'}; val_input=1;
   str_output={'-'}; val_output=1;
end
c=allchild(myfig);
h=findobj(c, 'flat', 'Userdata', 'MultiChannelObject');
set(h, 'enable', enable); % set all multichannel objects' enable property
h_pop1=findobj(c, 'flat', 'tag', 'import_ch_pop1');
h_pop2=findobj(c, 'flat', 'tag', 'import_ch_pop2');

if ~exist('val_input'), val_input=[]; end       
set(h_pop2, 'string', str_input,  'value', val_input);
if ~exist('val_output'), val_output=[]; end
set(h_pop1, 'string', str_output, 'value', val_output);


function out=isMultiChannel(data)
% returns true if data is multichannel iddat object, false otherwise
out=0;
if isa(data,'iddat')
  out=get(data,'ChNumber');
elseif isa(data,'iddata')
  out=get(iddat(data),'ChNumber');
end

function SetModelSelectObjs(data, filter, myfig) 
% enable or disable model selection ui objects. 
filt_mode=FilterMode(filter);
c=allchild(myfig);
h_pop=findobj(c, 'flat', 'tag', 'import_modsel_pop2');
h_txt2=findobj(c, 'flat', 'tag', 'ch_text2');
h_txt=findobj(c, 'flat', 'tag', 'ch_text');
h_frame=findobj(c, 'flat', 'tag', 'ch_frame');
if ~isempty(data)
   OrdStr=cellstr(fdmodord(data, 'distinguish'));
else
   OrdStr={'-'};
end
if  length(OrdStr)>1
   en='on';
else
   en='off';
end
val=1;
if ~any(findstr([filt_mode '#@#@#'], 'one_modelobj'))& length(OrdStr)>1 
   % more models 
   OrdStr{end+1}='All'; val=length(OrdStr);
end
set([h_pop, h_txt, h_txt2, h_frame], 'enable', en)
set(h_pop, 'string', OrdStr, 'value', val)


function [typeOK, msg]=testConversion(data, destFormat, msgMode, Me)
% destFormat, fidmodel case (other types are not implemented yet)
% 1 : no conversion
% 2 : tf  (control system toolbox)
% 3 : ss  (control system toolbox)
% 4 : zpk (control system toolbox)
% 5 : idpoly (system identification toolbox)
% 6 : idarx (system identification toolbox)
% msgMode (any of the following strings, or they combination)
% 'silent' : no other action, but return msg
% 'caller' : send msg status to caller
% 'Me'     : send msg to import status
% 'console': send msg to command window
% output: 
%          typeOK:  0 conversion not allowed 
%          typeOK:  1 conversion allowed and OK
%          typeOK: -1 conversion allowed but badly conditioned

myfig=findobj(allchild(0), 'flat', 'tag', Me);
hExportTypeWarning = findobj(allchild(myfig), 'flat', 'Tag','import_export_type_warning');

if destFormat==1 % native format
   typeOK=1; msg=[];   
else % not native format
   if isa(data, 'fidmodel')
      h= findall(0, 'tag', 'import_export_type');
      dFtxts=get(h,'string');
      dFtxt=dFtxts{destFormat};
      if length(data)>1 % array of models, conversion not allowed
         typeOK=0;
         msg=['Only type ''fidmodel'' is allowed with ARRAYs of models.'];
      elseif any(findstr(lower(dFtxt),'control'))
         if exist('@tf/tf.m') % conversion allowed
           % test robustness
           callerinfo=guidtard(Me, 'CALLER_INFO');
           callername=callerinfo.caller_name;
           if strcmp(data.variable,'w')
             typeOK=0;
             msg=['Conversion of w-domain model is not possible.'];
           elseif ~strcmp(data.representation, 'polynomial') & destFormat==2
             typeOK=-1;
             msg='Conversion to ''tf'' from orthogonal representation may be badly conditioned';
           else
             typeOK=1;
             msg='';
           end
         else
           typeOK=0;
           msg=['Conversion is not possible without the Control System Toolbox.'];
         end
      elseif any(findstr(lower(dFtxt),'ident'))
         if exist('@idpoly/idpoly.m')
            if strcmp(data.representation,'orthopol')
              typeOK=0;
              msg='Conversion from orthogonal polynomials to idpoly or idarx is not possible';
            %elseif any(findstr(lower(dFtxt),'idarx'))&strcmp(data.variable,'s')
              % typeOK=0;
              % msg='Conversion of s-domain model to idarx is not possible.';
            elseif strcmp(data.variable,'w')
              typeOK=0;
              msg='Conversion of w-domain model to idpoly or idarx is not possible.';
            elseif strcmp(data.variable,'r')
              typeOK=0;
              msg='Conversion of Raileigh-domain model to idpoly or idarx is not possible.';
            elseif ~any(findstr('z',data.variable))&any(findstr(lower(dFtxt),'arx'))
              typeOK=0;
              msg='Continuous time IDARX models are currently not supported in SITB.';
            else
              typeOK=1;
              msg='';
            end
         elseif strncmp(version,'5',1)
            typeOK=0;
            msg='Conversion is not yet possible in Matlab Version 5.';
         else
            typeOK=0;
            msg=['Conversion is not possible without the System Identification Toolbox.'];
         end
      else
         error('Unknown save format')
      end
   else
      % nothing here yet. Shouldn't happen
      typeOK=0;
      msg=['Not implemented yet.'];
   end
end

if any(findstr(msgMode, 'silent'))
   % nothing to do
else % display message if necessary
   if any(findstr(msgMode, 'caller')) & typeOK<=0
      c=guidtard(Me, 'CALLER_INFO');
      caller=c.caller_name;
      feval(caller, 'status', ['Warning: ' msg]);   
   end   
   if any(findstr(msgMode, 'Me'))
      h=findobj(allchild(myfig), 'flat', 'Tag','import_export_type_warning');
      if typeOK==0
         set(hExportTypeWarning, 'string', ['Warning: ' msg], ...
            'foregroundcolor', 'r', 'visible', 'on');
      elseif typeOK < 0
         set(hExportTypeWarning, 'string', ['Warning: ' msg],...
            'foregroundcolor', 'y', 'visible', 'on');
      else 
         set(hExportTypeWarning, 'visible', 'off'); 
      end
   end
   if any(findstr(msgMode, 'console'))
      warning(msg)
   end
end


function mode=FilterMode(filter);
% convert filter mode str into representation independent mode str

% {time|tiddata} object
% {frequency|fiddata} object
% {frequency|fiddata} object with variance
% model object
% model object(s)
% history

ff=lower(filter);
if any(findstr(ff, 'object'))
   if any(findstr(ff, 'time'))|any(findstr(ff, 'tiddata')) 
      if any(findstr(ff, 'single'))
         mode='timeid_data/single';% 'single channel time ... object'
      else
         mode='timeid_data';% 'time ... object'
      end
   elseif any(findstr(ff, 'frequency'))|any(findstr(ff, 'fiddata')) 
      if any(findstr(ff, 'variance'))
         mode='freqid_data/variance';% 'frequency ... object with variance'
      else
         mode='freqid_data';% 'frequency ... object'
      end
   elseif any(findstr(ff, 'model'))
      if any(findstr(ff, '(s)'))
         mode='modelobj'; % 'model ... object(s)'
      else
         if any(findstr(ff, 'with'))
            % data, fitinfo required
            mode='one_modelobj'; % 'model ... object with fitted data'
         else
            mode='one_modelobj_nodatareq'; % 'model ... object'
         end
      end
   else
      mode='';
   end
elseif any(findstr(ff, 'history'))
   mode='history'; % recorder history data 
elseif any(findstr(ff, 'vector'))
   if any(findstr(ff, 'variance'))
      mode='varvect'; % 'variance vector'
   elseif any(findstr(ff, 'amplitude'))
      mode='amplvect'; % 'amplitude vector'
   elseif any(findstr(ff, 'frequency'))
      mode='freqvect'; % 'frequency vector'
   elseif any(findstr(ff, 'weight'))
      mode='weightvect'; % 'weight vector'
   elseif any(findstr(ff, 'compose'))
      if any(findstr(ff,'cell')), mode='composevectcell';
      else mode='composevect';
      end
    else
      mode='';
   end
else
   mode='';
end
%
% End of file guiimpv
