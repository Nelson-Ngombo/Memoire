function [out1,out2,out3]=fdtool(varargin)
%FDTOOL Main routine to start fdident GUI, and show main window
%
%       Utilities:
%       fdtool manual or fdtool doc - show electronic manual in browser
%       fdtool version - display version and date of toolbox
%       fdtool date - display date of toolbox
%       fdtool license - show license data
%       fdtool objects - display information on objects
%       r=fdtool('root') - return root directory of fdident
%       fdtool quick - start GUI without loading default session
%       fdtool automatic periodic - start GUI in automatic mode (no modifiers, no default session, periodic data)
%       fdtool basic periodic - start GUI in automatic mode (no modifiers, no default session, periodic data)
%       fdtool basic - start GUI in automatic mode (no modifiers, no default session)
%       fdtool automatic - start GUI in automatic mode (no modifiers, no default session)
%       fdtool session <filename> - start gui with given session
%       fdtool exit - close the GUI with question (are you sure?)
%       fdtool exit force - close the GUI, no question
%       fdtool userlevel [Automatic | Interactive | Advanced] - set User level
%       fdtool modeltype [Linear |  Nonlinear errors] - set Model type
%
%       fdtool preload - preparse large functions to make startup of demo quicker
%
%       Usage: fdtool
%
%       See also: FDIDENT.

%       fdtool setguimodes {''|'M'|'MD'|,'D'}
%       fdtool getguimodes

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2010
%       All rights reserved.
%       $Revision
%       Last modified: 17-May-2011


% ###############  C A L L B A C K   W R A P P E R  #################
%  forward callback, buttondownfcn, etc. calls to private fcns
%  call form: fdtool('callback',funcname,parameters)
if (nargin>=2)&strcmpi(varargin{1},'callback')
    varargin=varargin(2:end);
    isstrv=1;
    for ii=1:length(varargin)
      if ~isstr(varargin{ii})&~isempty(varargin{ii}), isstrv=0; break, end
    end
    if isstr(varargin{end})&strcmp(varargin{end},'autoscan'), isstrv=0; end
    returntocaller=0;
    try
      if (nargin>=3)&isstrv
        %varargin{:}
        hmstat=helpmgr('callback_action',varargin{:});
        if strcmp('help',hmstat), returntocaller=1; return, end
      end
    catch
      %nothing to do
      varargin{:}
      warning('Something is wrong in helpmgr')
    end
    if returntocaller, return, end %bypass error in 5.2...  
    %
    if ~exist('gui_recorder.m')
      makehist(varargin{:}); %using built-in recorder
    else
      gui_recorder('record', 'fdtool', varargin{:}); %call to separate recorder
    end
    if nargout==0, feval(varargin{:});
    elseif nargout==1, out1=feval(varargin{:});
    elseif nargout==2, [out1,out2]=feval(varargin{:});
    elseif nargout==3, [out1,out2,out3]=feval(varargin{:});
    else error('Too many output arguments')
    end
    if length(varargin)>=2
      %notify makehist that the command is ended:
      if ~exist('gui_recorder.m')
        makehist('fdtool_command_execution_finished', varargin{2}) %for built-in recorder
      else
        gui_recorder('finished_running', 'fdtool');
      end
    end
    return
elseif (nargin==1)&isstr(varargin{1})&strncmp(varargin{1},'devhelp',4)
  disp('fdtool setguimodes {''''|''M''|''MD''|,''D''}')
  disp('fdtool getguimodes')
  return
end
% ###################################################################

mainfig=findall(0, 'tag','fdtool_main');
Me='fdtool_main'; myfcn='fdtool';

if nargin >0,	
   myfig=findall(0,'tag',Me);
   p1=varargin{1};
   if nargin>=2, p2=varargin{2}; end
   if nargin>=3, p3=varargin{3}; end
   if nargin == 6
      seltype=varargin{6};
      sender=varargin{5};		
   else						
      seltype=get(myfig,'selectiontype');
      sender=varargin{nargin};
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                 INITIALIZATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfn=setstr([102, 100, 99, 102, 115, 53, 95, 50]);
if strncmp(version,'5.2',3), cfl=8; else cfl=5; end
dispdate='28-Jun-2019'; %date to be displayed
development_override=0; %if set, simulate no development
if (nargin==1)&strncmpi(p1,'date',3)
  if nargout>0, out1=dispdate;
  else disp(['Fdident date: ',dispdate]);
  end
  return
elseif (nargin==1)&strcmpi(p1,'root')
  d=which('fdtool.m');
  if iscell(d), d=d{1}; end
  d=d(1:end-9);
  if nargout>0, out1=d;
  else disp(['Fdtool root: ',d]);
  end
  return
elseif (nargin==1)&(strncmpi(p1,'manual',3)|strncmpi(p1,'doc',3))
  manfile=[fdtool('root'),filesep,'private',filesep,'fdident.html'];
  manfilepdf=[manfile(1:end-4),'pdf'];
  if exist(manfilepdf)
    try
      %disp(['Opening ''',manfile,''''])
      web(manfile,'-browser');
    catch
      try
        web(manfile);
      catch
        warning(['Cannot open browser'])
      end
    end
  else
    warning(['Cannot find pdf file of the manual'])
  end
  clear manfile manfilepdf
  return
elseif (nargin==1)&strcmpi(p1,'addpath_fdident')
  fdident addpath_fdident
  return
elseif (nargin==1)&strcmpi(p1,'reportnote')
  note='';
  if guiinfos('isdevelopment'), note=[note,'D']; end
  if guiinfos('ismeasurement'), note=[note,'M']; end
  if isempty(note), note='-'; end
  out1={['fdtool V',fdtool('version'),', ',fdtool('date'), ', ',fdtool('licgroup'),', ',note]};
  return
end

if (nargin==0) | ...
    ( (nargin==1)&( strcmp(p1,'quick')|strncmpi(p1,'version',3)|...
    strncmpi(p1,'MLversion',5)|strncmpi(p1,'oldMLversion',8)|...
    strcmp(p1,'simple')|strcmp(p1,'basic')|strcmp(p1,'automatic')|strcmp(p1,'trial')|strcmp(p1,'demo') ) ) %| ...
    %( (nargin==2)&( (strcmp(p1,'quick')&strcmp(p2,'basic'))|(strcmp(p2,'quick')&strcmp(p1,'basic')) ) )
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ep=which('elis.m','-all');
   if length(ep)>1
     disp('Occurrences of elis.m on the path:')
     disp(ep)
     error('elis.m occurs more than one times')
   end
   VNo='5.0r';
   oldMLver='5.2.0.3084 (R10)'; 
   oldMLverown='5.2.1.1420';
   %MLver='6.5.1.199709 (R13) Service Pack 1'; %last tested Matlab version
   %MLver='7.0.0.19920 (R14)'; %last tested Matlab version
   %MLver='7.0.1.24704 (R14) Service Pack 1'; %last tested Matlab version
   MLver='7.0.4.365 (R14) Service Pack 2'; %last tested Matlab version
   MLver='7.1.0.246 (R14) Service Pack 3'; %last tested Matlab version
   MLver='7.2.0.232 (R2006a)'; %last tested Matlab version
   MLver='7.3.0.267 (R2006b)'; %last tested Matlab version
   MLver='7.4.0.287 (R2007a)'; %last tested Matlab version
   MLver='7.5.0.342 (R2007b)'; %last tested Matlab version
   MLver='7.6.0.324 (R2008a)'; %last tested Matlab version
   MLver='7.7.0.471 (R2008b)'; %last tested Matlab version
   MLver='7.8.0.347 (R2009a)'; %last tested Matlab version
   MLver='7.9.0.529 (R2009b)'; %last tested Matlab version
   MLver='7.10.0.59 (R2010a)'; %last tested Matlab version
   MLver='7.11.0.584 (R2010b)'; %last tested Matlab version
   MLver='7.12.0.635 (R2011a)'; %last tested Matlab version
   MLver='7.14.0.834 (R2012a)'; %last tested Matlab version
   MLver='8.1.0.604 (R2013a)'; %last tested Matlab version
   MLver='8.2.0.701 (R2013b)'; %last tested Matlab version
   MLver='8.3.0.532 (R2014a)'; %last tested Matlab version
   MLver='8.4.0.150421 (R2014b)'; %last tested Matlab version
   MLver='8.5.0.197613 (R2015a)'; %last tested Matlab version
   MLver='8.6.0.267246 (R2015b)'; %last tested Matlab version
   MLver='9.0.0.341360 (R2016a)'; %last tested Matlab version
   %MLver='9.0.0.341360 (R2016a)'; %last tested Matlab version
   %MLver='9.0.0.341360 (R2016a)'; %last tested Matlab version
   MLver='9.3.0.713579 (R2017b)';%last tested Matlab version
   MLver='9.6.0.1099231 (R2019a) Update 1';
   GUIversion=['Version ',VNo];
   if (nargin==1)&strncmpi(p1,'version',3)
     if nargout>0, out1=VNo;
     else disp(['Fdident version: ',VNo,', date: ',dispdate]);
     end
     return
   elseif (nargin==1)&strncmpi(p1,'MLversion',5)
     if nargout>0, out1=MLver;
     else
       disp(['Toolbox has already been tested with MATLAB versions ',oldMLverown,' - ',MLver,]);
       vers={version;MLver}; vers{1}=vers{1}(1:min(end,length(vers{2}))); vers2=sort(vers);
       if ~isequal(vers,vers2)
         warning('This toolbox version was not yet tested with this MATLAB version')
       end
     end
     return
   elseif (nargin==1)&strncmpi(p1,'oldMLver',8)
     if nargout>0, out1=oldMLver;
     else
       disp(['Old Macintosh MATLAB version: ',oldMLver]);
       vers={oldMLver;version}; vers2=sort(vers);
       if ~isequal(vers,vers2)
         warning('This toolbox version does not run with this MATLAB version')
       end
     end
     return
   end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   v=version;
   if length(v)<3, v=[v,'   ']; end
   if any(str2num(v(1:3))<5.2)
      error('fdtool runs only in Matlab 5.2 or higher')
   end
   if (nargin == 1) & (strcmp(p1,'quick')|strcmp(p1,'basic')|strcmp(p1,'automatic')|strcmp(p1,'trial')|strcmp(p1,'demo'))
      QUICK_INIT=1;
      if strcmp(p1,'basic')|strcmp(p1,'automatic')|strcmp(p1,'trial')
        development_override=1;
      end
   else
      QUICK_INIT=0;
   end
   %
   if ~isempty(mainfig)
      if strcmp(lower(get(mainfig,'visible')),'off')
        delete(mainfig)  % possible error during previous init
      else
        if (nargin == 1) & (strcmp(p1,'simple')|strcmp(p1,'basic')|strcmp(p1,'automatic')|strcmp(p1,'trial')|strcmp(p1,'demo'))
          fdtool exit force %need to restart
        else
          %just bring the main window to the front 
          figure(mainfig)
          return
        end
      end
   end
   %
   if (nargin == 1) & strcmp(p1,'trial')
     if exist('rml.m'), rml
     elseif fdtool('license')>1, disp('Cannot set trial license')
     end
   else 
     if exist('rml.m'), feval('rml','r');, end
   end
   
   %Check if MATLAB was tested with this toolbox version
   vers={version;fdtool('MLver')}; vers{1}=vers{1}(1:min(end,length(vers{2})));
   ind=find(vers{1}=='.'); vers{1}=vers{1}(1:ind(2)-1); 
   if ind(2)-ind(1)>2, vers{1}=[vers{1}(1:ind(1)),setstr('a'-10+str2num(vers{1}(ind(1)+1:end)))]; end
   ind=find(vers{2}=='.'); vers{2}=vers{2}(1:ind(2)-1);
   if ind(2)-ind(1)>2, vers{2}=[vers{2}(1:ind(1)),setstr('a'-10+str2num(vers{2}(ind(1)+1:end)))]; end
   %'7.c'
   vers2=sort(vers);
   if ~isequal(vers,vers2)
     warning('This toolbox version was not yet tested with this MATLAB version')
   end
   vers={fdtool('oldMLver');version}; vers2=sort(vers);
   if ~isequal(vers,vers2)
     if (length(vers)==2)&any(findstr(vers{1},vers{2}))
     else
      % error('This toolbox version does not run with this MATLAB version')
     end
   end

   intro('begin')

   if any(exist('elis.p'))
     warning('P-code for elis exists')
     which elis -all
     fduncode=0; %Bypass P-files
   else
     fduncode=2; %Warn for P-files
   end
   %
   %Now check if the latest toolbox is present:
   runfdu=0;
   fid=fopen('lin2qlog.m','r'); fstr=setstr(fread(fid)'); fclose(fid);
   ind=findstr(fstr,'dified:');
   if isempty(ind), intro('end'), error('Cannot find date string in lin2qlog'), end
   dstr=fstr(ind+7+[1:11]); ldstr='30-Dec-2003';
   if ~strcmp(dstr,ldstr)
     runfdu=1;
   end
   if ~exist([cfn(1:cfl),setstr([46,112])])&...
       ~exist(['private',filesep,cfn(1:cfl),setstr([46,112])])
    %error(sprintf(['This is not a supported fdident toolbox copy:\n',...
    %  '  please register or email to the distributors at fdident@vub.ac.be']))
   end
   if runfdu
     %Run fdunique and return result if necessary
     tbunique=1;
     if ~QUICK_INIT
       [tbunique,msg]=fdunique(fduncode); %check uniqueness
     end
     if ~tbunique
       disp(msg)
       disp(' ')
       intro('end')
       error('File repetition found for the fdident toolbox') %error out for shadowed toolbox file
       warning('File repetition found for the fdident toolbox') %warning if error is commented out
     end
     if ~strcmp(dstr,ldstr)
       intro('end')
       disp(['lin2qlog date is ',dstr,', required: ',ldstr])
       error('New toolbox version is not consistent: please reinstall it.')
     end
   else
     disp('Tip: Run ''fdunique'' once in a while to check that there are no name clashes')
     disp('  with your other files.')
   end
   getfpos; %check proper screen resolution

   blue=[.2 .7 .8]; grey=[.7 .7 .7]; black=[0 0 0];

   text_font_size = 8; % overdef'd later !!
   % size defs
   widx=10; widy=10;

   widlx=1; widly=1.4; % arrow line width
   lenar=2;            % arrow length
   widar=2.5;          % arrow width

   x1=18; x2=35; x3=50; x4=65; x5=80; x6=95; x7=110; x8=125; x9=140;
   x10=x9+widx;, x11=x10+4;
   y1=50; y2=30; y3=70; y4=47; y5=53;

   color_excitation=blue;
   color_gettime=blue;
   color_getfreq=blue;
   color_average=grey;
   color_select=grey;
   color_aided=grey;
   color_compare=grey;

   OldUnit=get(0, 'units');
   set(0, 'units', 'pixels');
   scrsize=get(0,'screensize');
   set(0, 'units', OldUnit);
   figwid=638;
   figheig=300;

   % figure creation & positioning
   name=['FDIdent GUI ' GUIversion];
   if fdtool('license')<=1
     name=[name,', trial setup: full functionality, but no model saving or pole/zero listing'];
   elseif fdtool('license')==2
     name=[name,' for students only'];
   elseif fdtool('license')==6
     name=[name,', demo license, not for regular use'];
   %elseif fdtool('license')==10
   %  name=[name,', this copy is for academic use only'];
   end
   mainfig=figure('visible','off',...
      'closerequestfcn', 'fdtool(''exit'')',...
      'tag','fdtool_main',...
      'integerhandle', 'off',...
      'handlevisibility', 'off',...
      'color','w',...
      'pointer','arrow',...
      'units', 'pixels',...
      'position',[2 scrsize(4)-figheig-60 figwid figheig],...
      'resize','on',...
      'resizefcn','fdtool(''resize'')',...
      'name',name,...
      'numbertitle','off',...
      'menubar', 'none');

   %get(mainfig)
   if (nargin == 1) & (strcmp(p1,'simple')|strcmp(p1,'basic')|strcmp(p1,'automatic')|strcmp(p1,'trial'))
     fdtool('setguimodes','')
   else
     fdtool('setguimodes')
   end   
   fdwindef; % find and store aproppriate platform dependent default properties

   ax=axes('parent', mainfig,...
      'units', 'normalized',...
      'position',[0 0 1 1],...
      'xlim', [0, 160],...
      'ylim', [0, 90],...
      'tag', 'fdtool_main_ax',...
      'visible','off');

   % Object defs

   patch_excitation=[x1-widx,x1+widx,...
         x1+widx,x1-widx;...
         y1-widx,y1-widx,...
         y1+widx,y1+widx];

   patch_gettime=[x3-widx,x3+widx,...
         x3+widx,x3-widx;...
         y3-widx,y3-widx,...
         y3+widx,y3+widx];

   patch_getfreq=[x3-widx,x3+widx,...
         x3+widx,x3-widx;...
         y2-widx,y2-widx,...
         y2+widx,y2+widx];

   patch_average=[x5-widx,x5+widx,...
         x5+widx,x5-widx;...
         y1-widx,y1-widx,...
         y1+widx,y1+widx];

   patch_select=[x7-widx,x7+widx,...
         x7+widx,x7-widx;...
         y3-widx,y3-widx,...
         y3+widx,y3+widx];

   patch_aided=[x7-widx,x7+widx,...
         x7+widx,x7-widx;...
         y2-widx,y2-widx,...
         y2+widx,y2+widx];

   patch_compare=[x9-widx,x9+widx,...
         x9+widx,x9-widx;...
         y1-widx,y1-widx,...
         y1+widx,y1+widx];


   text_excitation=[text(x1, y1+widy/2,'Excitation', ...
         'horiz','ce','color',black, ...
         'parent', ax);
      text(x1, y1,'Signal', ...
         'horiz','ce','color',black, ...
         'parent', ax);
      text(x1, y1-widy/2,'Design', ...
         'horiz','ce','color',black, ...
         'parent', ax)];

   if guiinfos('ismeasurement'), rmtxt='Read/Meas.';
   else rmtxt='Read';
   end
   text_gettime=[text(x3, y3+widy/2,rmtxt, ...
         'horiz','ce','color',black, ...
         'parent', ax,'HitTest','off');
      text(x3, y3,'Time Domain', ...
         'horiz','ce','color',black, ...
         'parent', ax,'HitTest','off');
      text(x3, y3-widy/2,'Data', ...
         'horiz','ce','color',black, ...
         'parent', ax,'HitTest','off')];

   if guiinfos('ismeasurement'), rmtxt='Read/Meas.';
   else rmtxt='Read';
   end
   text_getfreq=[text(x3, y2+widy/2,rmtxt, ...
         'horiz','ce','color',black, ...
         'parent', ax,'HitTest','off');
      text(x3, y2, 'Frequency', ...
         'horiz','ce','color',black, ...
         'parent', ax,'HitTest','off');
      text(x3, y2-widy/2,'Domain Data', ...
         'horiz','ce','color',black, ...
         'parent', ax,'HitTest','off')];

   text_average=[text(x5, y1+widy/2, 'Variances', ...
         'horiz','ce','color',black, ...
         'parent', ax);
      text(x5, y1,'and', ...
         'horiz','ce','color',black, ...
         'parent', ax);
      text(x5, y1-widy/2,'Averaging', ...
         'horiz','ce','color',black, ...
         'parent', ax)];

   text_select=[text(x7, y3+widy/2,'Estimate', ...
         'horiz','ce','color',black, ...
         'parent', ax);
      text(x7, y3,'Plant', ...
         'horiz','ce','color',black, ...
         'parent', ax);
      text(x7, y3-widy/2,'Model', ...
         'horiz','ce','color',black, ...
         'parent', ax)];

   text_aided=[text(x7, y2+widy/2,'Computer', ...
         'horiz','ce','color',black, ...
         'parent', ax);
      text(x7, y2,'Aided Model', ...
         'horiz','ce','color',black, ...
         'parent', ax);
      text(x7, y2-widy/2,'Scan', ...
         'horiz','ce','color',black, ...
         'parent', ax)];

   text_compare=[text(x9, y1+widy/2,'Evaluate', ...
         'horiz','ce','color',black, ...
         'parent', ax);
      text(x9, y1,'or Compare', ...
         'horiz','ce','color',black, ...
         'parent', ax);
      text(x9, y1-widy/2,'Plant Models', ...
         'horiz','ce','color',black, ...
         'parent', ax)];

   set([text_excitation; text_gettime; text_getfreq; text_average;...
         text_select; text_aided; text_compare],  ...
      'fontsize',text_font_size)

   rect_excitation=patch(patch_excitation(1,:), ...
      patch_excitation(2,:),color_excitation, ...
      'parent', ax,'FaceAlpha',0.5);

   rect_gettime=patch(patch_gettime(1,:), ...
      patch_gettime(2,:),color_gettime, ...
      'parent', ax,'FaceAlpha',0.5);

   rect_getfreq=patch(patch_getfreq(1,:), ...
      patch_getfreq(2,:),color_getfreq, ...
      'parent', ax,'FaceAlpha',0.5);

   rect_average=patch(patch_average(1,:), ...
      patch_average(2,:),color_average, ...
      'parent', ax,'FaceAlpha',0.5);

   rect_select=patch(patch_select(1,:), ...
      patch_select(2,:),color_select, ...
      'parent', ax,'FaceAlpha',0.5);

   rect_aided=patch(patch_aided(1,:), ...
      patch_aided(2,:),color_aided, ...
      'parent', ax,'FaceAlpha',0.5);

   rect_compare=patch(patch_compare(1,:), ...
      patch_compare(2,:),color_compare, ...
      'parent', ax,'FaceAlpha',0.5);

   % lines an arrows

   l1=patch([x1+widx,x1+widx,x2-widlx, x2,x2-widlx],...
      [y1+widly,y1-widly, y1-widly, y1, y1+widly], ...
      grey, 'parent', ax);

   l2=patch([x2,x2+widlx, x2+widlx, x3-widx-lenar,  ...
         x3-widx-lenar, ...
         x3-widx, x3-widx-lenar,x3-widx-lenar , ...
         x2-widlx,x2-widlx],...
      [y1,y1+widly, y3-widly, y3-widly, y3-widar,y3, ...
         y3+widar, y3+widly, y3+widly, y1+widly], ...
      grey, 'parent', ax);

   l3=patch([x2,x2+widlx, x2+widlx, x3-widx-lenar,  ...
         x3-widx-lenar, ...
         x3-widx, x3-widx-lenar,x3-widx-lenar , ...
         x2-widlx,x2-widlx],...
      [y1,y1-widly, y2+widly, y2+widly,  ...
         y2+widar,y2, y2-widar,  ...
         y2-widly, y2-widly, y1-widly], ...
      grey, 'parent', ax);


   l4=patch([x3+widx, x4-widlx, x4-widlx, x5-widx-lenar,  ...
         x5-widx-lenar,   ...
         x5-widx, x5-widx-lenar, x5-widx-lenar, ...
         x4+widlx, x4+widlx, x3+widx],...
      [y3-widly, y3-widly, y5-widly, y5-widly,  ...
         y5-widar, y5, y5+widar,  ...
         y5+widly, y5+widly, y3+widly, y3+widly], ...
      grey, 'parent', ax);

   l5=patch([x3+widx, x4-widlx, x4-widlx, x5-widx-lenar,  ...
         x5-widx-lenar,   ...
         x5-widx, x5-widx-lenar, x5-widx-lenar, ...
         x4+widlx, x4+widlx, x3+widx],...
      [y2+widly, y2+widly, y4+widly, y4+widly,  ...
         y4+widar, y4, y4-widar,  ...
         y4-widly, y4-widly, y2-widly, y2-widly], ...
      grey, 'parent', ax);

   l6=patch([x5+widx, x5+widx,x6-widlx, x6,x6-widlx],...
      [y1+widly,y1-widly, y1-widly, y1, y1+widly], ...
      grey, 'parent', ax);

   l7=patch([x6,x6+widlx,x6+widlx, x7-widx-lenar,  ...
         x7-widx-lenar,  ...
         x7-widx, x7-widx-lenar,x7-widx-lenar , ...
         x6-widlx,x6-widlx],...
      [y1,y1+widly, y3-widly, y3-widly, y3-widar, ...
         y3, y3+widar,  ...
         y3+widly, y3+widly, y1+widly], ...
      grey, 'parent', ax);

   l8=patch([x6,x6+widlx,x6+widlx, x7-widx-lenar,  ...
         x7-widx-lenar, x7-widx,  ...
         x7-widx-lenar,x7-widx-lenar , ...
         x6-widlx,x6-widlx],...
      [y1,y1-widly, y2+widly, y2+widly,  ...
         y2+widar,y2, y2-widar,  ...
         y2-widly, y2-widly, y1-widly], ...
      grey, 'parent', ax);


   l9=patch([x7+widx, x8-widlx, x8-widlx,  ...
         x9-widx-lenar, x9-widx-lenar,   ...
         x9-widx, x9-widx-lenar, x9-widx-lenar, ...
         x8+widlx, x8+widlx, x7+widx],...
      [y3-widly, y3-widly, y5-widly, y5-widly,  ...
         y5-widar, y5, y5+widar,  ...
         y5+widly, y5+widly, y3+widly, y3+widly], ...
      grey, 'parent', ax);


   l10=patch([x7+widx, x8-widlx, x8-widlx,  ...
         x9-widx-lenar, x9-widx-lenar,   ...
         x9-widx, x9-widx-lenar, x9-widx-lenar, ...
         x8+widlx, x8+widlx, x7+widx],...
      [y2+widly, y2+widly, y4+widly, y4+widly,  ...
         y4+widar, y4, y4-widar,...
         y4-widly, y4-widly, y2-widly, y2-widly], ...
      grey, 'parent', ax);

   l11=patch([x10, x11, x11, x11+lenar, x11, x11, x10],...
      [y1+widly, y1+widly, y1+widar, y1, y1-widar, y1-widly, y1-widly, ], ...
      grey, 'parent', ax);


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   %                 UICONTROLS
   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % menus

   menu_file=uimenu(mainfig, 'label','&File','posit',1, 'tag', 'fdtool_menu_file');
   menu_file_load=uimenu(menu_file,...
      'label', '&Load',...
      'tag',   'fdtool_menu_load', ...
      'enable','on');
   menu_file_load_session=uimenu(menu_file_load,...
      'label',    '&Session...',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''load_session'', ''fdtool_menu_load_session'')',...
      'tag',      'fdtool_menu_load_session', ...
      'enable',   'on');
   menu_file_load_default=uimenu(menu_file_load,...
      'label',    '&Default session',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''ui_load_default_session'', ''fdtool_menu_load_default_session'')',...
      'tag',      'fdtool_menu_load_default_session', ...
      'enable',   'on');

   menu_file_load_arrow=uimenu(menu_file_load,...
      'label',    '&Arrow data',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''load_arrow_data'', ''fdtool_menu_load_arrow_data'')',...
      'tag',      'fdtool_menu_load_arrow_data', ...
      'separator','on', ...
      'enable',   'on');

   menu_file_load_input=uimenu(menu_file_load,...
      'label',    '&Input data',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''load_input_data'', ''fdtool_menu_load_input_data'')',...
      'tag',      'fdtool_menu_load_input_data', ...
      'enable',   'on');

   menu_file_load_arrow=uimenu(menu_file_load,...
      'label',    'Data to &Workspace',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''load_workspace_data'', ''fdtool_menu_load_workspace_data'')',...
      'tag',      'fdtool_menu_load_workspace_data', ...
      'separator','on', ...
      'enable',   'on');

   menu_file_save=uimenu(menu_file,...
      'label',    '&Save',...
      'tag',      'fdtool_menu_save', ...
      'enable',   'on');
   menu_file_save_session=uimenu(menu_file_save,...
      'label',    '&Session as...',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''save_session'', ''fdtool_menu_save_session'')',...
      'tag',      'fdtool_menu_save_session',...
      'enable',   'on');
   menu_file_save_default=uimenu(menu_file_save,...
      'label',	  'Session as &default',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''save_default_session'', ''fdtool_menu_save_default_session'')',...
      'tag',	  'fdtool_menu_save_default_session',...
      'enable',   'on');
   menu_file_save_arrow=uimenu(menu_file_save,...
      'label',	  '&Arrow data',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''save_arrow_data'', ''fdtool_menu_save_arrow_data'')',...
      'tag',      'fdtool_menu_save_arrow_data', ...
      'enable',   'on');

   menu_file_save_result=uimenu(menu_file_save,...
      'label',	  '&Results',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''save_results'', ''fdtool_menu_save_results'')',...
      'tag',      'fdtool_menu_save_results', ...
      'enable',   'on');

   menu_file_print=uimenu(menu_file,...
      'label','&Print',...
      'callback', ['fdtool(''callback'', ''fdtool'', ''fdtool_uic_print'',''fdtool_uic_print'');'],...
      'tag',      'fdtool_uic_print',...
      'separator','on');

   menu_file_print_ps=uimenu(menu_file,...
      'label','Print to PS &File',...
      'callback', ['fdtool(''callback'', ''fdtool'', ''fdtool_mod_print_ps'',''fdtool_uic_print_ps'');'],...
      'tag', 'fdtool_uic_print_ps',...
      'separator','off');

   menu_file_close_all=uimenu(menu_file,...
      'label',	  'Close all &Windows',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''close_all_windows'', ''fdtool_menu_closewindows'')',...
      'tag',      'fdtool_menu_closewindows', ...
      'enable',   'on', ...
      'separator','on');

   menu_file_forget=uimenu(menu_file,...
      'label',    '&Clear',...
      'tag',	  'fdtool_menu_forget',...
      'separator','off');
   menu_file_forget_settings=uimenu(menu_file_forget,...
      'label',	  '&Panel settings',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''ui_forget_settings'', ''fdtool_menu_forget_settings'')',...
      'tag',	  'fdtool_menu_forget_settings',...
      'separator','off');
   menu_file_forget_data=uimenu(menu_file_forget,...
      'label',	  '&Arrow data',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''ui_forget_data'', ''fdtool_menu_forget_data'')',...
      'tag',	  'fdtool_menu_forget_data',...
      'separator','off');
   menu_file_forget_all=uimenu(menu_file_forget,...
      'label',	  '&Whole GUI',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''ui_forget_all'', ''fdtool_menu_forget_all'')',...
      'tag',	  'fdtool_menu_forget_all',...
      'separator','off');

   menu_file_reset=uimenu(menu_file,...
      'label',    'Restart &GUI',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''ui_reset'', ''fdtool_menu_reset'')',...
      'tag',	  'fdtool_menu_reset',...
      'separator','off');

   if guiinfos('isdevelopment')&~development_override
     menu_file_basic=uimenu(menu_file,...
       'label',    'Restart GUI in &automatic mode',...
       'callback', 'fdtool(''callback'', ''fdtool'', ''ui_basic'', ''fdtool_menu_basic'')',...
       'tag',	  'fdtool_menu_basic',...
       'separator','off');
     menu_file_trial=uimenu(menu_file,...
       'label',    'Restart GUI in &trial mode',...
       'callback', 'fdtool(''callback'', ''fdtool'', ''ui_trial'', ''fdtool_menu_trial'')',...
       'tag',	  'fdtool_menu_trial',...
       'separator','off');
   end
   
   menu_file_reset=uimenu(menu_file,...
      'label',    '&Unfreeze GUI',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''ui_unfreeze'', ''fdtool_menu_unfreeze'')',...
      'tag',	  'fdtool_menu_unfreeze',...
      'separator','on');

   menu_file_advanced_on=uimenu(menu_file,...
      'label',    '&Enable advanced level',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''ui_advanced_on'', ''fdtool_menu_advanced_on'')',...
      'tag',	  'fdtool_menu_advanced_on',...
      'separator','off');

   menu_file_exit=uimenu(menu_file,...
      'label',	   '&Exit GUI',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''exit'', ''fdtool_menu_exit'')',...
      'tag',	   'fdtool_menu_exit',...
      'separator','on');

   if strncmp(version,'5.2',3)
     pm=1;
     menu_userlevel=uimenu(mainfig, 'label','&UserLevel','posit',2,'tag', 'fdtool_menu_userlevel');
     %menu_userlevel_simple=uimenu(menu_userlevel,...
     %  'label','&Simple',...
     %  'callback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Simple'', ''fdtool_menu_userlevel_simple'')',...
     %  'userdata', 'fdtool_menu_userlevel',...
     %  'tag',		'fdtool_menu_userlevel_simple',...
     %  'checked',  'on'); % this is the default
     menu_userlevel_basic=uimenu(menu_userlevel,...
       'label','A&utomatic',...
       'callback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Automatic'', ''fdtool_menu_userlevel_basic'')',...
       'userdata', 'fdtool_menu_userlevel',...
       'tag',		'fdtool_menu_userlevel_basic',...
       'checked',  'on'); % this is the default
     menu_userlevel_intermediate=uimenu(menu_userlevel,...
       'label','&Interactive',...
       'callback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Interactive'', ''fdtool_menu_userlevel_intermediate'')',...
       'userdata', 'fdtool_menu_userlevel',...
       'tag',		'fdtool_menu_userlevel_intermediate');
     menu_userlevel_advanced=uimenu(menu_userlevel,...
       'label','A&dvanced',...
       'callback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Advanced'', ''fdtool_menu_userlevel_advanced'')',...
       'userdata', 'fdtool_menu_userlevel',...
       'tag',		'fdtool_menu_userlevel_advanced');
     
   else %toolbar possible
     pm=0; uimt=uitoolbar(mainfig,'tag','fdtool_menu_userlevel_modeltype');
     %menu_userlevel_simple=uitoggletool(uimt,...
     %  'tooltipstring','User level: Simple',...
     %  'cdata',getcd('ulsi'),...
     %  'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Simple'', ''fdtool_menu_userlevel_simple'')',...
     %  'userdata', 'fdtool_menu_userlevel',...
     %  'tag',		'fdtool_menu_userlevel_simple',...
     %  'state','on'); % this is the default
     menu_userlevel_basic=uitoggletool(uimt,...
       'tooltipstring','User level: Automatic',...
       'cdata',getcd('ulau'),...
       'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Automatic'', ''fdtool_menu_userlevel_basic'')',...
       'userdata', 'fdtool_menu_userlevel',...
       'tag',		'fdtool_menu_userlevel_basic',...
       'state',  'on'); % this is the default
     menu_userlevel_intermediate=uitoggletool(uimt,...
       'tooltipstring','User level: Interactive',...
       'cdata',getcd('ulia'),...
       'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Interactive'', ''fdtool_menu_userlevel_intermediate'')',...
       'userdata', 'fdtool_menu_userlevel',...
       'tag',		'fdtool_menu_userlevel_intermediate',...
       'state','off');
     menu_userlevel_advanced=uitoggletool(uimt,...
       'tooltipstring','User level: Advanced',...
       'cdata',getcd('ulad'),...
       'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Advanced'', ''fdtool_menu_userlevel_advanced'')',...
       'userdata', 'fdtool_menu_userlevel',...
       'tag',	'fdtool_menu_userlevel_advanced',...
       'state','off');     
   end

   %Signal popup menu
   if strncmp(version,'5.2',3)
     text_bgr_col = [ 1 1 1 ]; %'default'; %[ 0.5 0.5 0.5 ];
     text_fg_col  = 'default'; %[ 0 0 0 ];
     signalmod=20;
     uimenu_signaltype=uicontrol(...
       'parent',mainfig,...
       'style','popupmenu',...
       'position',[5,278-signalmod,100,20],...
       'string',{'All signals','Periodic only'},...
       'tooltipstring','Select between signal types',...
       'value',2,...
       'BackgroundColor',[1 1 1],...
       'userdata','fdtool_menu_signaltype',...
       'tag', 'fdtool_menu_signaltype',...
       'callback', 'fdtool(''callback'', ''fdtool'', ''ui_signaltype_set'', ''Linear'', ''fdtool_menu_signaltype'')');
     uitext_signaltype=uicontrol(... 
       'Parent',mainfig,...
       'callback', 'fdtool(''callback'', ''fdtool'', ''sme_uic_signaltypetext'', ''sme_uic_signaltypetext'')',...
       'Units','pixels',...
       'Position',[5,278+18-signalmod,100-1,18],...
       'BackgroundColor',text_bgr_col,...
       'ForegroundColor',text_fg_col,...
       'String','Type of signal:',... 
       'tooltipstring','Select between signal types',...
       'HorizontalAlignment','center',... 
       'Style','text',... 
       'tag', 'fdtool_text_signaltype',...
       'UserData',''); 
     %set(mainfig,'visible','on')
   else %toolbar possible
     %uist=uitoolbar(mainfig,'tag','fdtool_menu_userlevel_signaltype');
     uimenu_signaltype_linear=uitoggletool(uimt,...
       'tooltipstring','Signal type: All',...
       'separator','on',...
       'cdata',getcd('stall'),...
       'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_signaltype_set'', ''All signal types'', ''fdtool_menu_signaltype_all'')',...
       'userdata', 'fdtool_menu_signaltype',...
       'tag',		'fdtool_menu_signaltype_all',...
       'state','on'); % this is the default
     uimenu_signaltype_nonlinear_error=uitoggletool(uimt,...
       'tooltipstring','Signal type: Periodic only',...
       'separator','off',...
       'cdata',getcd('stper'),...
       'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_signaltype_set'', ''Periodic signals'', ''fdtool_menu_signaltype_periodic'')',...
       'userdata', 'fdtool_menu_signaltype',...
       'tag',		'fdtool_menu_signaltype_periodic',...
       'state','off'); % this is the default
   end

   %Nonlinear popup menu
   if strncmp(version,'5.2',3)
     text_bgr_col = [ 1 1 1 ]; %'default'; %[ 0.5 0.5 0.5 ];
     text_fg_col  = 'default'; %[ 0 0 0 ];
     modelmod=20;
     uimenu_modeltype=uicontrol(...
       'parent',mainfig,...
       'style','popupmenu',...
       'position',[5,278-modelmod,100,20],...
       'string',{'Linear','Nonlinear errors'},...
       'tooltipstring','Select between linear modeling or detection of nonlinearities',...
       'value',1,...
       'BackgroundColor',[1 1 1],...
       'userdata','fdtool_menu_modeltype',...
       'tag', 'fdtool_menu_modeltype',...
       'callback', 'fdtool(''callback'', ''fdtool'', ''ui_modeltype_set'', ''Linear'', ''fdtool_menu_modeltype'')');
     uitext_modeltype=uicontrol(... 
       'Parent',mainfig,...
       'callback', 'fdtool(''callback'', ''fdtool'', ''sme_uic_modeltypetext'', ''sme_uic_modeltypetext'')',...
       'Units','pixels',...
       'Position',[5,278+18-modelmod,100-1,18],...
       'BackgroundColor',text_bgr_col,...
       'ForegroundColor',text_fg_col,...
       'String','Type of model:',... 
       'tooltipstring','Select between linear modeling or detection of nonlinearities',...
       'HorizontalAlignment','center',... 
       'Style','text',... 
       'tag', 'fdtool_text_modeltype',...
       'UserData',''); 
     %set(mainfig,'visible','on')
   else %toolbar possible
     %uimt=uitoolbar(mainfig,'tag','fdtool_menu_userlevel_modeltype');
     uimenu_modeltype_linear=uitoggletool(uimt,...
       'tooltipstring','Model type: Linear',...
       'separator','on',...
       'cdata',getcd('mtli'),...
       'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_modeltype_set'', ''Linear'', ''fdtool_menu_modeltype_linear'')',...
       'userdata', 'fdtool_menu_modeltype',...
       'tag',		'fdtool_menu_modeltype_linear',...
       'state','on'); % this is the default
     uimenu_modeltype_nonlinear_error=uitoggletool(uimt,...
       'tooltipstring','Model type: Nonlinear errors',...
       'separator','off',...
       'cdata',getcd('mtne'),...
       'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_modeltype_set'', ''Nonlinear errors'', ''fdtool_menu_modeltype_nonlinear_errors'')',...
       'userdata', 'fdtool_menu_modeltype',...
       'tag',		'fdtool_menu_modeltype_nonlinear_errors',...
       'state','off'); % this is the default
   end
   
   menu_demo=uimenu(mainfig, 'label','&Recorder','posit',2+pm,...
     'tag',		'fdtool_menu_record');
   menu_demo_record=uimenu(menu_demo,...
      'label', 	'&Open',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''history_on'', ''fdtool_menu_record_open'')',...
      'tag',		'fdtool_menu_record_open');
   menu_demo_stop=uimenu(menu_demo,...
      'label', 	'&Stop',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''history_off'', ''fdtool_menu_record_stop'')',...
      'tag',		'fdtool_menu_record_stop');
   menu_demo_close=uimenu(menu_demo,...
      'label', 	'&Close',...
      'callback', 'fdtool(''callback'', ''fdtool'', ''history_close'', ''fdtool_menu_record_close'')',...
      'tag',		'fdtool_menu_record_close');
   if guiinfos('isdevelopment')&~development_override
      menu_demo_record2=uimenu(menu_demo,...
         'label', 	'Open in &Development Mode',...
         'callback', 'fdtool(''callback'', ''fdtool'', ''develophistory_on'', ''fdtool_menu_record_open2'')',...
         'separator', 'on', ...
         'tag',		'fdtool_menu_record_open2');
   end

   menu_window=uimenu(mainfig, 'label','&Window','posit',3+pm,...
      'Callback', 'winmenu(findall(0, ''tag'', ''fdtool_main''))',...
      'tag','winmenu');

   menu_help=uimenu(mainfig, 'label','&Help','posit',4+pm, 'tag', 'fdtool_menu_help');
   menu_help_start=uimenu(menu_help,...
      'label',	'&Getting started...',...
      'callback','fdtool(''callback'',''helpmgr'',''ui_help_start'',''fdtool'',''fdtool_menu_help_start'')',...
      'tag',		['fdtool' '_menu_help_start']);
   menu_help_fdid=uimenu(menu_help,...
      'label',	'&Fdident GUI',...
      'callback','fdtool(''callback'',''helpmgr'',''ui_help_fdid'',''fdtool'',''fdtool_menu_help_fdid'')',...
      'tag',		['fdtool' '_menu_help_fdid']);
   menu_help_expimp=uimenu(menu_help,...
      'label',	'&Export/import data',...
      'callback','fdtool(''callback'',''helpmgr'',''ui_help_expimp'',''fdtool'',''fdtool_menu_help_expimp'')',...
      'tag',		['fdtool' '_menu_help_expimp']);
   menu_help_this=uimenu(menu_help,...
      'label',	'&This window',...
      'callback',['fdtool(''callback'',''helpmgr'',''ui_help_this'',''fdtool'', ''fdtool_menu_help_this'' )'],...
      'tag',		['fdtool' '_menu_help_this']);
   menu_help_nonlin=uimenu(menu_help,...
      'label',	'&Nonlinearities',...
      'callback','fdtool(''callback'',''helpmgr'',''ui_help_nonlin'',''fdtool'',''fdtool_menu_help_nonlin'')',...
      'tag',		['fdtool' '_menu_help_nonlin']);
   %menu_help_topic=uimenu(menu_help,...
   %   'label',	'&Search by topic',...
   %   'callback','fdtool(''callback'',''helpmgr'',''ui_help_search'',''fdtool'',''fdtool_menu_help_search'')',...
   %   'tag',		['fdtool' '_menu_help_search']);
   
   manfilepdf=[fdtool('root'),filesep,'private',filesep,'fdident.pdf'];
   if exist(manfilepdf)
     if ~strncmp(version,'5',1)
       menu_help_manual_int=uimenu(menu_help,...
         'label',	'Manual (in Matlab''s internal &viewer)',...
         'callback','fdtool(''callback'', ''fdtool'', ''ui_help_manual_int'', ''fdtool_menu_help_manual_int'')',...
         'tag',		['fdtool' '_menu_help_manual_int'],...
         'separator','off');
     end
     menu_help_manual=uimenu(menu_help,...
       'label',	'&Manual (PDF)',...
       'callback','fdtool(''callback'', ''fdtool'', ''ui_help_manual'', ''fdtool_menu_help_manual'')',...
       'tag',		['fdtool' '_menu_help_manual'],...
       'separator','off');
   end
   
   menu_help_object=uimenu(menu_help,...
     'label',	'Help on &Object',...
     'callback',['fdtool(''callback'',''helpmgr'',''ui_help_object'',''fdtool'',''fdtool_menu_help_object'')'],...
     'tag',		['fdtool' '_menu_help_object'],...
     'separator','on');

   %menu_demo=uimenu(menu_help,...
   %  'label',	'&Introductory Demos',...
   %  'tag',		['fdtool' '_MENU_intro'],...
   %  'separator','on');
   
   menu_demo_GUI=uimenu(menu_help,...
     'label',	'Examples: how to use &GUI',...
     'callback',	[ 'fdtool(''callback'', ''fdtool'', ''ui_help_introductions_gui'', ''fdtool_menu_intro_gui'')'],...
     'tag',		['fdtool' '_menu_intro_gui'],...
     'separator','on');
   
   menu_demo_ident=uimenu(menu_help,...
     'label',	'Examples: how to &Identify',...
     'callback',	'fdtool(''callback'', ''fdtool'', ''ui_help_introductions_ident'', ''fdtool_menu_intro_ident'')',...
     'tag',		['fdtool' '_menu_intro_ident'],...
     'separator','off');
   
   menu_demo_complex=uimenu(menu_help,...
     'label',	'&Complex Examples and Demos',...
     'callback', [ 'fdtool(''callback'', ''fdtool'', ''ui_help_examples'', ''fdtool_menu_demo'')'],...
     'tag', ['fdtool' '_menu_demo'],...
     'separator','off');
   
   if guiinfos('isdevelopment')&~development_override
     menu_demo=uimenu(menu_help,...
       'label',	'Fdident G&UI Tests',...
       'callback', 'fdtool(''callback'', ''fdtool'', ''ui_help_tests'', ''fdtool_menu_test'')',...
       'tag',		['fdtool' '_menu_test'],...
       'separator','off');
   end
   
   %menu_help_web=uimenu(menu_help,...
   %  'label',	'Fdident &User Web Page',...
   %  'callback','fdtool(''callback'', ''fdtool'', ''ui_help_web'', ''fdtool_menu_help_web'')',...
   %  'tag',		['fdtool' '_menu_help_web'],...
   %  'separator','on');
   
   menu_help_dev_web=uimenu(menu_help,...
     'label',	'Fdident Developers'' &Web Page',...
     'callback','fdtool(''callback'', ''fdtool'', ''ui_help_devb_web'', ''fdtool_menu_help_devb_web'')',...
     'tag',		['fdtool' '_menu_help_devb_web'],...
     'separator','on');

   menu_help_faq_web=uimenu(menu_help,...
     'label',	'Fdident Frequently Asked &Questions',...
     'callback','fdtool(''callback'', ''fdtool'', ''ui_help_faq_web'', ''fdtool_menu_help_faq_web'')',...
     'tag',		['fdtool' '_menu_help_faq_web'],...
     'separator','off');

   menu_help_dev_mail=uimenu(menu_help,...
     'label',	'Technical &Support',...
     'callback','fdtool(''callback'', ''fdtool'', ''ui_help_dev_mail'', ''fdtool_menu_help_dev_mail'')',...
     'tag',		['fdtool' '_menu_help_dev_mail'],...
     'separator','off');

   menu_help_data_web=uimenu(menu_help,...
     'label',	'Fdident &Data sheet',...
     'callback','fdtool(''callback'', ''fdtool'', ''ui_help_data_web'', ''fdtool_menu_help_data_web'')',...
     'tag',		['fdtool' '_menu_help_data_web'],...
     'separator','off');

   %menu_help_dev_reg=uimenu(menu_help,...
   %  'label',	'&Registration for the fdident extension',...
   %  'callback','fdtool(''callback'', ''fdtool'', ''ui_help_dev_reg'', ''fdtool_menu_help_dev_reg'')',...
   %  'tag',		['fdtool' '_menu_help_dev_reg'],...
   %  'separator','off');

   menu_help_lic=uimenu(menu_help,...
     'label',	'&License information',...
     'callback','fdtool(''callback'', ''fdtool'', ''ui_help_lic'', ''fdtool_menu_help_lic'')',...
     'tag',		['fdtool' '_menu_help_lic'],...
     'separator','off');

   menu_help_about=uimenu(menu_help,...
     'label',	'&About fdident ...',...
     'callback','fdtool(''callback'', ''fdtool'', ''ui_help_about'', ''fdtool_menu_help_about'')',...
     'tag',		['fdtool' '_menu_help_about'],...
     'separator','on');

   frame_status=uicontrol('parent', mainfig, ...
     'style','frame',...
     'unit','pixels','position',[1 1  figwid 24],...
     'background', 'default',...
     'hittest', 'off', ...
     'tag', 'frame_status');
   status=uicontrol('parent', mainfig, ...
     'style','text',...
     'unit','pixels', ...
     'position',[3 3 figwid-6 18], ...
     'background', 'default',...
     'horiz', 'left', ...
     'hittest', 'off', ...
     'string', 'Initializing...',...
     'tag','status_main');


   % set all tags for graphics
   set(text_excitation,'tag','text_excitation');
   set(text_gettime,'tag','text_gettime');
   set(text_getfreq,'tag','text_getfreq');
   set(text_average,'tag','text_average');
   set(text_select,'tag','text_select');
   set(text_aided,'tag','text_aided');
   set(text_compare,'tag','text_compare');

   set(rect_excitation,'tag','rect_excitation');
   set(rect_gettime,'tag','rect_gettime');
   set(rect_getfreq,'tag','rect_getfreq');
   set(rect_average,'tag','rect_average');
   set(rect_select,'tag','rect_select');
   set(rect_aided,'tag','rect_aided');
   set(rect_compare,'tag','rect_compare');

   set(l1,'tag','l1');
   set(l2,'tag','l2');
   set(l3,'tag','l3');
   set(l4,'tag','l4');
   set(l5,'tag','l5');
   set(l6,'tag','l6');
   set(l7,'tag','l7');
   set(l8,'tag','l8');
   set(l9,'tag','l9');
   set(l10,'tag','l10');
   set(l11,'tag','l11');




   % set all callbacks for graphics

   set(text_gettime, 'hittest', 'off');
   set(rect_gettime,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_gettime'',''rect_gettime'')')

   set(text_getfreq, 'hittest', 'off');
   set(rect_getfreq,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_getfreq'',''rect_getfreq'')')

   set(text_excitation, 'hittest', 'off');
   set(rect_excitation,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_excitation'',''rect_excitation'')')

   set(text_average, 'hittest', 'off');
   set(rect_average,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_average'',''rect_average'')')

   set(text_select, 'hittest', 'off');
   set(rect_select,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_select'',''rect_select'')')

   set(text_aided, 'hittest', 'off');
   set(rect_aided, ...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_aided'',''rect_aided'')')


   set(text_compare, 'hittest', 'off');
   set(rect_compare,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_compare'',''rect_compare'')')


   set(l1,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l1'',''l1'')')
   set(l2,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l2'',''l2'')')
   set(l3,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l3'',''l3'')')
   set(l4,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l4'',''l4'')')
   set(l5,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l5'',''l5'')')
   set(l6,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l6'',''l6'')')
   set(l7,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l7'',''l7'')')
   set(l8,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l8'',''l8'')')
   set(l9,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l9'',''l9'')')
   set(l10,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l10'',''l10'')')
   set(l11,...
      'buttondown','fdtool(''callback'', ''fdtool'', ''click_on_l11'',''l11'')')



   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % 		VARIABLES
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % input values of the boxes in the main window
   inpfrom.excitation=['nothing'];
   inpfrom.gettime=   ['nothing'];
   inpfrom.getfreq=   ['nothing'];
   inpfrom.average=   ['nothing'];
   inpfrom.select=    ['nothing'];
   inpfrom.aided=     ['nothing'];
   inpfrom.compare=   ['nothing'];

   inpnext1.excitation=['gettime'];
   inpnext1.gettime=['average'];
   inpnext1.getfreq=['average'];
   inpnext1.average=['select'];
   inpnext1.select=['compare'];
   inpnext1.aided=['compare'];
   inpnext1.compare=['-'];

   inpnext2.excitation=['getfreq'];
   inpnext2.gettime=['-'];
   inpnext2.getfreq=['-'];
   inpnext2.average=['aided'];
   inpnext2.select=['-'];
   inpnext2.aided=['-'];
   inpnext2.compare=['-'];

   fnames=fieldnames(inpfrom);
   for i=1:7
      inp.from=getfield(inpfrom,char(fnames(i)));
      inp.next1=getfield(inpnext1,char(fnames(i)));
      inp.next2=getfield(inpnext2,char(fnames(i)));
      guidtawr(Me, ['INPUT_', char(fnames(i))], 'direct', inp)
   end


   % output values of the boxes in the main window
   outs.excitation=[];
   outs.gettime=[];
   outs.getfreq=[];
   outs.average=[];
   outs.select=[];
   outs.aided=[];
   outs.compare=[];
   fnames=fieldnames(outs);
   for i=1:7
      guidtawr(Me, ['OUTPUT_', char(fnames(i))], 'direct', ...
         getfield(outs,char(fnames(i))))
   end

   % state variables of the boxes in the main window
   states.excitation=['excitation init init state vars'];
   states.gettime=[];
   states.getfreq=[];
   states.average=[];
   states.select=[];
   states.aided=[];
   states.compare=['compare init state vars'];
   fnames=fieldnames(states);
   for i=1:7
      guidtawr(Me, ['STATUS_', char(fnames(i))], 'direct', ...
         getfield(states,char(fnames(i))))
   end



   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % 		OTHERS
   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


   % initialization of the state vars and colors
   boxmgr('init', 'fdtool_main');
   fdtool('status',['FDIdent Toolbox GUI ' GUIversion])

   % init help
   helpmgr('init_help', '', myfcn, mainfig );

   if ~QUICK_INIT
      % load default session if any
      default_session=sessave('Hello !','What is the default filename, please ?');
      if exist(default_session, 'file')
         FullSessionName=which(default_session);
         status=sesload(FullSessionName);
         if status
            fdtool('status', ['#yFDIdent GUI: Default session automatically ',...
                  'loaded from ''', FullSessionName, '''.'])
         end
      end
   elseif strcmp(p1,'demo')
     fdtool('userlevel_set','interactive')
     fdtool preload
     evalin('base','if exist(''loadrd.m''), loadrd, end')
   end
   
   fdtool('resize');

   % precompile main files
   % fdtool('preload')
   %For the time being, eliminate preload from initial start

   set(mainfig, ...
      'visible', 'on',...
      'windowbuttonmotion','fdtool(''mouse_motion'', ''fdtool_main'')');
   winmenu(mainfig);
   %
   %Nonlinear menu
   hnonlinm=[findall(0,'tag','fdtool_menu_modeltype');
     findall(0,'tag','fdtool_menu_modeltype_linear');
     findall(0,'tag','fdtool_menu_modeltype_nonlinear_errors')];
   hnonlin=[hnonlinm,findall(0,'tag','fdtool_text_modeltype')];
   hadvanced=findall(0,'tag','fdtool_menu_userlevel_advanced');
   %Enable nonlinear analysis without condition
   set([hnonlin(:);hnonlinm(:)],'enable','on','visible','on')
   if guiinfos('isdevelopment')&~development_override
     set(hadvanced,'enable','on','visible','on')
     ham = findall(0, 'tag', 'fdtool_menu_advanced_on');
     set(ham,'label','&Disable advanced level')
   elseif guiinfos('ismeasurement')
   else
     %fdtool('modeltype_set','no nonlinear')
     fdtool('userlevel_set','automatic')
     fdtool('signaltype_set','all')
     %set([hnonlin(:);hnonlinm(:)],'enable','off','visible','off')
     %if strcmp(get(hadvanced,'state'),'on')
     %  fdtool('userlevel_set','Interactive')
     %end
     %set(hadvanced,'enable','off','visible','off')
     fdtool('setguimodes','')
   end
   %
   ulevctrl;
   intro('end')

   if ~QUICK_INIT
     %drawnow
     %fdident preload
   end
   % end of init



   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % 		MAIN WINDOW COMMANDS
   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


else  % nargin > 0
   [s,ind]=sort({version,'6.5.1.2'});
   %ind(1): version is earlier
   if ind(1)==1, matlaberror=1; else matlaberror=0; end
   %matlab error: wrong handling of toolbar visibility in Matlab, error in
   %V6.5.1.199709
   if strcmp(p1,'mouse_motion')
      %
      %guiready(mainfig, 'fdtool')
      %return
      %

      lastupdate=get(mainfig,'userdata');
      if isempty(lastupdate), return, end
      if isstr(lastupdate), return, end
      try, ludt=etime(clock,lastupdate); catch, ludt=0; end
      if ludt > 3
         pointersh=get(mainfig,'pointer');
         if strcmp(pointersh, 'arrow')
            fdtool('status', 'Ready.')
            msg=fdident('private',cfn(1:cfl),'fdtool');
         elseif ~isempty(guidtard(Me, 'ui_props_save'))
            % let's have fun !
            status=findobj(allchild(mainfig), 'flat', 'tag','status_main');
            curstr=get(status,'string');
            if length(curstr)<40
               ext=get(status, 'position'); ext=ext(3);
               measure_steps=[100 50 20 10 5];
               for meas_ix=1:length(measure_steps);
                  step_size=measure_steps(meas_ix);
                  ext_new=0;
                  while ext > ext_new;
                     curstr=[curstr blanks(step_size)];
                     set(status, 'string', curstr);
                     ext_new=get(status, 'extent'); ext_new=ext_new(3);
                  end
                  curstr=curstr(1:length(curstr)-step_size);
               end
               set(status, 'string', curstr);
            else
               pos=get(status, 'position'); wid=pos(3); hei=pos(4);
               cp=get(mainfig, 'currentpoint'); cpx=cp(1); cpy=cp(2);
               l=length(curstr);
               msg='Click on an object to get help.';
               lmsg=length(msg);
               b1=floor((cpx/wid)*(l-lmsg));
               b2=l-lmsg-b1;
               if b2<0, b1=b1+b2; b2=0; end
               curstr=[blanks(b1) , msg, blanks(b2)];
               set(status, 'string', curstr);
            end
         end
      end

   elseif strcmp(p1,'status')
      if isempty(mainfig), fdtool; end
      c=allchild(mainfig);
      status=findobj(c, 'flat', 'tag','status_main');
      statusfr=findobj(c, 'flat', 'tag','frame_status');
      glstatus(mainfig, status, statusfr, p2)


   % handle click on boxes:
   elseif strcmp(p1,'click_on_excitation')
      guifreez(Me, 'freeze', p1);
      if boxmgr(p1,Me)
         fdtool('status', 'Opening Excitation Signal Design...', Me);
         essd
         fdtool('status', 'Done. ', Me);
      end
      guifreez(Me, 'unfreeze', p1);

   elseif strcmp(p1,'click_on_gettime')
      guifreez(Me, 'freeze', p1);
      if boxmgr(p1,Me)
         %fdtool('status', 'Opening Read/Measure Time Domain Data', Me);
         fdtool('status', 'Opening Read Time Domain Data', Me);
         gettime
         fdtool('status', 'Done. ', Me);
      end
      guifreez(Me, 'unfreeze', p1);

   elseif strcmp(p1,'click_on_getfreq')
      guifreez(Me, 'freeze', p1);
      if boxmgr(p1,Me)
         %fdtool('status', 'Opening Read/Measure Frequency Domain Data...', Me);
         fdtool('status', 'Opening Read Frequency Domain Data...', Me);
         gfdd
         fdtool('status', 'Done.', Me);
      end
      guifreez(Me, 'unfreeze', p1);

   elseif strcmp(p1,'click_on_average')
      guifreez(Me, 'freeze', p1);
      if boxmgr(p1,Me)
         fdtool('status', 'Opening Variances and/or Averaging...', Me);
         agv;
         fdtool('status', 'Done.', Me);
      end
      guifreez(Me, 'unfreeze', p1);
      fixpopups(findall(0,'type','figure','tag','average_main'))
      
   elseif strcmp(p1,'click_on_select')
      guifreez(Me, 'freeze', p1);
      if boxmgr(p1,Me)
         fdtool('status', 'Opening Estimate Plant Model...', Me);
         sme('init_sme');
         fdtool('status', 'Done.', Me);
      end
      guifreez(Me, 'unfreeze', p1);

   elseif strcmp(p1,'click_on_aided')
      guifreez(Me, 'freeze', p1);
      if boxmgr(p1,Me)
         fdtool('status', 'Opening Computer Aided Model Scan...', Me);
         sme('init_cams');
         fdtool('status', 'Done.', Me);
      end
      guifreez(Me, 'unfreeze', p1);

   elseif strcmp(p1,'click_on_compare')
      guifreez(Me, 'freeze', p1);
      if boxmgr(p1,Me)
         fdtool('status', 'Opening Evaluate or Compare Plant Models...', Me);
         caem;
         fdtool('status', 'Done.', Me);
      end
      guifreez(Me, 'unfreeze', p1);

   elseif strncmp(p1,'click_on_l',10)    % doubleclick on arrow
      arrnum=str2num(p1(11:length(p1)));
      arrowstr=guidtard(Me, 'ARRMGR');
      arrstatus=arrowstr(arrnum);
      switch arrstatus
      case {'a', 'A'}
         %fdtool('status',['l' num2str(arrnum) ' clicked. This arrow is already active.'])
         questarr('init1', arrnum, Me)% ask if plot or save is required
      case '-'
         %fdtool('status',['l' num2str(arrnum) ' clicked. This arrow has no data.'])
         questarr('init3', arrnum, Me)% only load is possible
      case {'p', 'P'}
         %fdtool('status',['l' num2str(arrnum) ' clicked. This arrow has passive data.'])
         questarr('init2', arrnum, Me)% ask if plot, save or activation is required
      end

   elseif strcmp(p1,'activate_an_arrow')
      % warning message here ????
      fdtool('status', 'Activating arrow...')
      switch p2 % arrnum
         % flip-flop arrows
      case 4
         fdtool('forward_data', 'gettime')
         boxmgr(['end_of_gettime'], Me, 'UPDATE')
      case 5
         fdtool('forward_data', 'getfreq')
         boxmgr(['end_of_getfreq'], Me, 'UPDATE')
      case 9
         fdtool('forward_data', 'select')
         boxmgr(['end_of_select'], Me, 'UPDATE')
      case 10
         fdtool('forward_data', 'aided')
         boxmgr(['end_of_aided'], Me, 'UPDATE')
      otherwise
         % no action
      end
      fdtool('status','Arrow activated.')

   elseif strcmp(p1,'load_an_arrow')  % called by load arrow data
      arrnum=p2; data=varargin{3};
      switch arrnum
      case {1, 2, 3}
         guidtawr(Me,'OUTPUT_excitation','direct',data);
         fdtool('forward_data', 'excitation')
         boxmgr(['end_of_excitation'], Me, 'LOADEDDATA')
      case 4
         guidtawr(Me,'OUTPUT_gettime','direct',data);
         fdtool('forward_data', 'gettime')
         boxmgr(['end_of_gettime'], Me, 'LOADEDDATA')
      case 5
         guidtawr(Me,'OUTPUT_getfreq','direct',data);
         fdtool('forward_data', 'getfreq')
         boxmgr(['end_of_getfreq'], Me, 'LOADEDDATA')
      case {6, 7, 8}
         guidtawr(Me,'OUTPUT_average','direct',data);
         if data.expn > 1
            data=data{:,1};
            fdtool('status', 'Warning: Multiple experiments not allowed on this arrow. Experiment #1 automatically selected.')
         end
         fdtool('forward_data', 'average')
         boxmgr(['end_of_average'], Me, 'LOADEDDATA')
      case 9
         guidtawr(Me,'OUTPUT_select','direct',data);
         fdtool('forward_data', 'select')
         boxmgr(['end_of_select'], Me, 'LOADEDDATA')
      case 10
         guidtawr(Me,'OUTPUT_aided','direct',data);
         fdtool('forward_data', 'aided')
         boxmgr(['end_of_aided'], Me, 'LOADEDDATA')
      case 11
         guidtawr(Me,'OUTPUT_compare','direct',data);
         boxmgr(['end_of_compare'], Me, 'LOADEDDATA')
      end


   elseif strcmp(p1,'quit')
      guiclose('fdtool')

   elseif strcmp(p1,'ui_reset')
      ans=questdlg('Are you sure you want to restart FDIdent GUI ?',  ...
         'FDIdent GUI    Restart', 'Yes', 'No', 'No');
      if strcmp(ans,'Yes')
         fdtool('quit', Me)
         fdtool
      end

   elseif strcmp(p1,'ui_basic')
      ans=questdlg('Are you sure you want to restart FDIdent GUI ?',  ...
         'FDIdent GUI    Restart', 'Yes', 'No', 'No');
      if strcmp(ans,'Yes')
         fdtool('quit', Me)
         fdtool basic
      end

   elseif strcmp(p1,'ui_trial')
      ans=questdlg('Are you sure you want to restart FDIdent GUI ?',  ...
         'FDIdent GUI    Restart', 'Yes', 'No', 'No');
      if strcmp(ans,'Yes')
         fdtool('quit', Me)
         fdtool trial
      end

   elseif strcmp(p1,'exit')
     if (nargin==2)&strcmp(p2,'force')
       fdtool('quit')
     else
       ans=questdlg('Are you sure you want to exit FDIdent GUI ?',  ...
       'FDIdent GUI    EXIT', 'Yes', 'No', 'No');
       if strcmp(ans,'Yes')
         fdtool('quit')
       end
     end
     
     
   elseif strcmp(p1,'load_session') % called by menu
      [filename,pathname]=uigetfile('*.mat','Load Session');
      if isempty(filename)| ~isstr(filename)
         fdtool('status', 'Load cancelled')
      else
         fullname=fullfile(pathname, filename);
         fdtool('ui_load_session', fullname, 'fdtool_menu_load_session')
      end

   elseif strcmp(p1,'ui_load_session') % recorded only if valid filename given
      sesload(p2);
      ulevctrl; % user level ctrl

   elseif strcmp(p1,'ui_load_default_session')
      default_session=sessave('Hello !','What is the default filename, please ?');
      if exist(default_session, 'file')
         fullname=which(default_session);
         status=sesload(default_session);
         ulevctrl; % user level ctrl
         if status==1
            fdtool('status', ['Default session loaded from file ' fullname])
         else
            % warning or error status written by sesload
         end
      else
         fdtool('status',...
            ['Error: Default session file does not exist yet.'])
      end

   elseif strcmp(p1,'save_session') % called by menu
      [filename,pathname]=uiputfile('*.mat','Save Session');
      if ~isempty(filename)& isstr(filename)
         fullname=fullfile(pathname, filename);
         fdtool('ui_save_session', fullname, 'fdtool_menu_save_session')
      else
         fdtool('status', 'Session save cancelled')
      end

   elseif strcmp(p1,'ui_save_session') % recorded command
      sessave(p2);

   elseif strcmp(p1,'save_default_session')
      default_session=sessave('Hello !','What is the default filename, please ?');
      fullname=fullfile(pwd, default_session);
      fdtool('status', ['Saving default session to file ' fullname '...'])
      if exist(fullname, 'file')
         answer=questdlg(...
            ['Are you sure you want to overwrite current default session file (', ...
               fullname, ') ?'],...
            'Save Default Session', 'Yes', 'No', 'No');
      else
         answer='Yes';
      end
      if strcmp(answer, 'Yes')
         fdtool('ui_save_default_session', sender)
      else
         fdtool('status', 'Default session save cancelled')
      end

   elseif strcmp(p1,'ui_save_default_session')
      default_session=sessave('Hello !','What is the default filename, please ?');
      fullname=fullfile(pwd, default_session);
      fdtool('status', ['Saving default session to file ' fullname '...'])
      sessave(fullname);
      fdtool('status', ['Default session saved to ' fullname '.'])


   elseif strcmp(p1,'setline') % set arrows' color
      % p2 line id: a string or cell array of strings
      % p3 line color
      ax=findobj(allchild(mainfig), 'flat', 'tag', 'fdtool_main_ax');
      ch=get(ax, 'children');
      lineid=zeros(1,length(p2));
      for ii=1:length(p2)
         lineid(ii)=findobj(allchild(ax),'flat','tag',['l' num2str(p2(ii))]);
      end
      if ~isempty(lineid)
        set(lineid,'facecolor',varargin{3})
      end


   elseif strcmp(p1,'setbox') % set color of a box
      % p2 box id
      % p3 box color
      ax=findobj(allchild(mainfig),'flat','tag','fdtool_main_ax');
      boxid=findobj(allchild(ax),'flat','tag',p2);
      set(boxid,'facecolor',varargin{3})

   elseif strcmp(p1,'history_on')  % open recorder in default mode
     %if ~guiinfos('isrecorderopen') %for built-in recorder
     %find old and new tags...
     hr=[findall(0, 'tag','fdtool_recorder_fig');
       findall(0, 'tag','guirecrd_fdtool')];
     if isempty(hr)
       guirecrd('init', 'recorder');
       %guirecrd('INIT', 'fdtool', 'fdtool_window', 'NORMAL');
     else
       %old and new recorders...
       hr=[findall(0,'type','figure','tag','fdtool_recorder_fig');
         findall(0, 'tag','gui_recorder_fdtool')];
       figure(hr)
     end

   elseif strcmp(p1,'develophistory_on')% open recorder in development mode
     guirecrd('init', 'development');
     %guirecrd('INIT', 'fdtool', 'fdtool_window', 'DEVELOPMENT');	

   elseif strcmp(p1,'history_off') % stop recorder
     guirecrd('stop');
     %guirecrd('recorder_stop', 'guirecrd_fdtool'); %Ez nem lesz jó!

   elseif strcmp(p1,'history_close') % close recorder
     guirecrd('close');
     %guirecrd('callback', 'recorder_close', 'guirecrd_fdtool')

   elseif strcmp(p1,'finished_box') % called when a box is closed (by done or cancel)
      % p2: box ID
      % p3: cancel or done
      guifreez(Me, 'freeze', 'fdtool_main_finished_box');
      caller_name=p2(6:length(p2));
      if strcmp(varargin{3}, 'cancel')
         boxmgr(['cancel_of_' caller_name], Me)
      else % 'done'
         fdtool('forward_data', caller_name)
         boxmgr(['end_of_' caller_name], Me, 'NEWDATA')
         % main_ax=findobj(mainfig,'tag','fdtool_main_ax');
         % set(main_ax,'visi','on'), set(main_ax,'visi','off')
      end
      figure(mainfig);  % main window forward
      guifreez(Me, 'unfreeze', 'fdtool_main_finished_box');

   elseif strcmp(p1,'forward_data') % provide data to the next box
      % name of box to forward data from is p2
      caller_name=p2;
      inp=guidtard('fdtool_main', ['INPUT_' caller_name]);
      % find out where to send message
      inpnext1=inp.next1;
      inpnext2=inp.next2;
      if ~strcmp(inpnext1,'-')
         inp=guidtard('fdtool_main', ['INPUT_' inpnext1]);
         inp.from=caller_name; % modify the from field of the next box
         guidtawr('fdtool_main', ['INPUT_' inpnext1], 'direct', inp); % write back
      end
      % the same for the second possible box in the sequence
      if ~strcmp(inpnext2,'-')
         inp=guidtard('fdtool_main', ['INPUT_' inpnext2]);
         inp.from=caller_name;
         guidtawr('fdtool_main', ['INPUT_' inpnext2], 'direct', inp);
      end

   elseif any(findstr(p1, 'userlevel_set')) % called by userlevel menu
      p2m=p2;
      if strncmpi(p2m,'Automatic',4), p2m='Basic';
      %elseif strncmpi(p2m,'Simple',4), p2m='Simple';
      elseif strncmpi(p2m,'Interactive',8), p2m='Intermediate';
      elseif strncmpi(p2m,'Advanced',3), p2m='Advanced';
        ham = findall(0, 'tag', 'fdtool_menu_advanced_on');
        if any(findstr(get(ham,'label'),'Enable'))
          fdtool('ui_advanced_on')
          set(ham,'label','&Disable advanced level')
        end
        V=version; 
        if 0&(str2num(V(1))<=6)&(str2num(V(1:3))>5.2)
          %bypass Matlab error in visualization
          uimt=findall(0,'tag','fdtool_menu_userlevel_modeltype');
          hnl=[findall(uimt, 'tag', 'fdtool_menu_modeltype_linear');...
              findall(uimt, 'tag', 'fdtool_menu_modeltype_nonlinear_errors')];
          nlset=strcmp(get(findall(uimt, 'tag', 'fdtool_menu_modeltype_nonlinear_errors'),'state'),'on');
          delete(hnl)
          ha=findall(0, 'tag', 'fdtool_menu_userlevel_advanced');
          if ~isempty(ha), delete(ha), end
          ha=uitoggletool(uimt,...
            'tooltipstring','User level: Advanced',...
            'cdata',getcd('ulad'),...
            'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Advanced'', ''fdtool_menu_userlevel_advanced'')',...
            'userdata', 'fdtool_menu_userlevel',...
            'tag',	'fdtool_menu_userlevel_advanced');
          uimenu_modeltype_linear=uitoggletool(uimt,...
            'tooltipstring','Model type: Linear',...
            'separator','on',...
            'cdata',getcd('mtli'),...
            'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_modeltype_set'', ''Linear'', ''fdtool_menu_modeltype_linear'')',...
            'userdata', 'fdtool_menu_modeltype',...
            'tag',		'fdtool_menu_modeltype_linear',...
            'state','on'); % this is the default
          uimenu_modeltype_nonlinear_error=uitoggletool(uimt,...
            'tooltipstring','Model type: Nonlinear errors',...
            'separator','off',...
            'cdata',getcd('mtne'),...
            'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_modeltype_set'', ''Nonlinear errors'', ''fdtool_menu_modeltype_nonlinear_errors'')',...
            'userdata', 'fdtool_menu_modeltype',...
            'tag',		'fdtool_menu_modeltype_nonlinear_errors',...
            'state','off'); % this is the default
          if nlset, fdtool('modeltype','Nonlinear errors'), end
        end %5.3...6.5.1
      elseif strncmpi(p2m,'Intermediate',8), p2m='Intermediate';
        warning(['Obsolete UserLevel ''',p2m,''''])
      elseif (nargin>=3)&strcmpi(p2,'No')&strncmpi(p3,'advanced',3), p2m=[p2,' ',p3]; 
      elseif strncmpi(p2,'No advanced',6)
      else
        if ~exist('p3'), p3=''; else p3=[' ',p3]; end
        error(['Invalid UserLevel ''',p2,':',p3,''''])
      end
      hm=[findobj(allchild(mainfig), 'tag','fdtool_menu_userlevel_modeltype');
        findobj(allchild(mainfig), 'tag','fdtool_menu_userlevel')];
      if strcmp(get(hm,'type'), 'uimenu') %old call with pulldown menu
        %str=get(hm,'string');
      else %toolbar
        if strncmpi(p2m,'no advanced',6)
          hpushed=[];
        elseif nargin>=3
          hpushed=findobj(mainfig,'tag',p3);
          if isempty(hpushed)
            if ~strcmpi(p2m,'Advanced')
              error('hpushed is empty')
            end
          end
        else 
          hpushed=findobj(mainfig,'tag',['fdtool_menu_userlevel_',lower(p2m)]);;
          %if isempty(hpushed), error('hpushed is empty'), end
        end
        hChecked=findobj(mainfig, ...
          'userdata', 'fdtool_menu_userlevel', 'state', 'on');
        if ~isempty(hpushed)
          for ii=length(hChecked):-1:1
            if hChecked(ii)==hpushed, hChecked(ii)=[]; end
          end
        end
        set(hChecked,'state','off')
      end
      if strcmp(get(hm,'type'), 'uimenu') %old call
        hAll=findobj(allchild(mainfig), 'type', 'uimenu', ...
          'userdata', 'fdtool_menu_userlevel');
        if strncmpi(p2m,'no advanced',6)
          %Hide advanced set
          hadv=findobj(hAll, 'tag', 'fdtool_menu_userlevel_advanced');
          if strcmp(get(findobj(hAll, 'tag', 'fdtool_menu_userlevel_advanced'),'checked'),'on')
            set(findobj(hAll, 'tag', 'fdtool_menu_userlevel_intermediate'),'checked','on')  
          end
          set(hadv,'checked','off','visible','off')
        else %regular set
          hSelected=findobj(hAll, 'tag', ['fdtool_menu_userlevel_' lower(p2m)]);
          set(hAll, 'checked', 'off');
          set(hSelected, 'checked', 'on','visible','on')
          lab=get(hSelected,'label'); ind=find(lab=='&'); if ~isempty(ind), lab(ind)=''; end
        end
      else %toolbar
        if strncmpi(p2m,'no advanced',6)
          hadv=findobj(myfig, 'tag', 'fdtool_menu_userlevel_advanced');
          if strcmp(get(findobj(myfig, 'tag', 'fdtool_menu_userlevel_advanced'),'state'),'on')  
            set(findobj(myfig, 'tag', 'fdtool_menu_userlevel_intermediate'),'state','on')  
          end
          if ~matlaberror, set(hadv,'state','off','visible','off')
          else delete(hadv); %Error in Matlab: invisible toolbar element makes toolbar wrong 
          end
          %fdtool('modeltype_set','no nonlinear')
        else
          if strcmpi(p2m,'advanced')
            hadv=findobj(myfig, 'tag', 'fdtool_menu_userlevel_advanced');
            if isempty(hadv)
              %Advanced button does not exist, create it
              uimt=findall(myfig,'tag','fdtool_menu_userlevel_modeltype');
              menu_userlevel_advanced=uitoggletool(uimt,...
                'tooltipstring','User level: Advanced',...
                'cdata',getcd('ulad'),...
                'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Advanced'', ''fdtool_menu_userlevel_advanced'')',...
                'userdata', 'fdtool_menu_userlevel',...
                'tag',	'fdtool_menu_userlevel_advanced',...
                'state','on');     
            else
              set(hadv,'visible','on','state','on')
            end
          end
          hChecked=findobj(allchild(mainfig), ...
            'userdata', 'fdtool_menu_userlevel', 'state', 'on');
          if isempty(hChecked), set(hpushed,'state','on','visible','on'), end
        end
      end
      %
      lab=guiinfos('UserLevel');
      ulevctrl; % settings in other windows
      fdtool('status', ['Userlevel set to ' lab '.']);
      
 %%%%%%%%%%%%%%%%%%%%%%%
 elseif any(findstr(p1, 'signaltype_set')) % called by signaltype menu
     p2m=p2;
     if (nargin>=3)&strcmpi(p2,'All')&strcmpi(p3,'signal'), p2m=[p2,' ',p3]; 
     elseif (nargin>=3)&strcmpi(p2,'No')
       p2m=[p2,' ',p3]; 
       if nargin>=4, p2m=[p2m,' ',p4]; end
     end
     hm=[findobj(allchild(mainfig), 'tag','fdtool_menu_userlevel_signaltype');
       findobj(allchild(mainfig), 'tag','fdtool_menu_signaltype')];
     if strcmp(get(hm,'type'),'uicontrol') %old pulldown menu
       val=get(hm,'value');
       str=get(hm,'string');
       if strcmp(p1,'ui_modeltype_set')&exist('p3')&~isempty(p3) 
         %callback
         %valnew=strmatch(p2m,str);
         p2m=popupstr(hm);
       end
     else %toolbar
       hmt=findobj(myfig, 'userdata', 'fdtool_menu_signaltype');
       if isempty(hmt)
         %Signal type buttons do not exist, create them
         uimt=findall(myfig,'tag','fdtool_menu_userlevel_signaltype');
         uimenu_signaltype_all=uitoggletool(uimt,...
           'tooltipstring','Signal type: All',...
           'separator','on',...
           'cdata',getcd('stall'),...
           'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_signaltype_set'', ''All'', ''fdtool_menu_signaltype_all'')',...
           'userdata', 'fdtool_menu_signaltype',...
           'tag',		'fdtool_menu_signaltype_all',...
           'state','on'); % this is the default
         uimenu_signaltype_periodic=uitoggletool(uimt,...
           'tooltipstring','Signal type: Periodic only',...
           'separator','off',...
           'cdata',getcd('stper'),...
           'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_signaltype_set'',''Periodic'', ''fdtool_menu_signaltype_periodic'')',...
           'userdata', 'fdtool_menu_signaltype',...
           'tag',		'fdtool_menu_signaltype_periodic',...
           'state','off'); 
       else
         set(hmt,'visible','on','state','on')
       end
       hChecked=findobj(mainfig, ...
         'userdata', 'fdtool_menu_signaltype', 'state', 'on');
       if nargin>=3, hpushed=findobj(mainfig,'tag',p3); else hpushed=[]; end
       if ~isempty(hpushed)
         for ii=length(hChecked):-1:1
           if hChecked(ii)==hpushed, hChecked(ii)=[]; end
         end
       end
       set(hChecked,'state','off')
     end
     if strncmpi(p2m,'All',3), p2m='All'; val=1;
     elseif strncmpi(p2m,'Periodic signals',8), p2m='Periodic'; val=2;
     else error(['Invalid signal type ''',p2m,''''])
     end
     if strcmp(get(hm,'type'),'uicontrol')
       set(hm,'value',max(val,1))
       hmt=findobj(myfig, 'tag','fdtool_text_signaltype');
     else %toolbar
       hChecked=findobj(allchild(mainfig), ...
         'userdata', 'fdtool_menu_signaltype', 'state', 'on');
       if isempty(hChecked), 
         if ~isempty(hpushed), set(hpushed,'state','on')
         elseif val==0
           if ~matlaberror
             set(findobj(mainfig,'tag','fdtool_menu_signaltype_all'),'state','on','visible','off')
             set(findobj(mainfig,'tag','fdtool_menu_signaltype_periodic'),'state','off','visible','off')
           else 
             delete(findobj(mainfig,'userdata','fdtool_menu_signaltype')); %Error in Matlab: invisible toolbar element makes toolbar wrong 
           end
         elseif val==1, set(findobj(mainfig,'tag','fdtool_menu_signaltype_all'),'state','on')
         elseif val==2, set(findobj(mainfig,'tag','fdtool_menu_signaltype_periodic'),'state','on')
         end
       end
     end
     ulevctrl; % settings in other windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   elseif any(findstr(p1, 'modeltype_set')) % called by modeltype menu
     p2m=p2;
     if (nargin>=3)&strcmpi(p2,'Nonlinear')&strcmpi(p3,'errors'), p2m=[p2,' ',p3]; 
     elseif (nargin>=3)&strcmpi(p2,'No')
       p2m=[p2,' ',p3]; 
       if nargin>=4, p2m=[p2m,' ',p4]; end
     end
     hm=[findobj(allchild(mainfig), 'tag','fdtool_menu_userlevel_modeltype');
       findobj(allchild(mainfig), 'tag','fdtool_menu_modeltype')];
     if strcmp(get(hm,'type'),'uicontrol') %old pulldown menu
       val=get(hm,'value');
       str=get(hm,'string');
       if strcmp(p1,'ui_modeltype_set')&exist('p3')&~isempty(p3) 
         %callback
         %valnew=strmatch(p2m,str);
         p2m=popupstr(hm);
       end
     else %toolbar
       hmt=findobj(myfig, 'userdata', 'fdtool_menu_modeltype');
       if isempty(hmt)
         %Model type buttons do not exist, create them
         uimt=findall(myfig,'tag','fdtool_menu_userlevel_modeltype');
         uimenu_modeltype_linear=uitoggletool(uimt,...
           'tooltipstring','Model type: Linear',...
           'separator','on',...
           'cdata',getcd('mtli'),...
           'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_modeltype_set'', ''Linear'', ''fdtool_menu_modeltype_linear'')',...
           'userdata', 'fdtool_menu_modeltype',...
           'tag',		'fdtool_menu_modeltype_linear',...
           'state','on'); % this is the default
         uimenu_modeltype_nonlinear_error=uitoggletool(uimt,...
           'tooltipstring','Model type: Nonlinear errors',...
           'separator','off',...
           'cdata',getcd('mtne'),...
           'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_modeltype_set'', ''Nonlinear errors'', ''fdtool_menu_modeltype_nonlinear_errors'')',...
           'userdata', 'fdtool_menu_modeltype',...
           'tag',		'fdtool_menu_modeltype_nonlinear_errors',...
           'state','off'); % this is the default
       else
         set(hmt,'visible','on','state','on')
       end
       hChecked=findobj(mainfig, ...
         'userdata', 'fdtool_menu_modeltype', 'state', 'on');
       if nargin>=3, hpushed=findobj(mainfig,'tag',p3); else hpushed=[]; end
       if ~isempty(hpushed)
         for ii=length(hChecked):-1:1
           if hChecked(ii)==hpushed, hChecked(ii)=[]; end
         end
       end
       set(hChecked,'state','off')
     end
     if strncmpi(p2m,'Linear',3), p2m='Linear'; val=1;
     elseif strncmpi(p2m,'Nonlinear errors',9), p2m='Nonlinear errors'; val=2;
     elseif strncmpi(p2m,'No nonlin',9)|strncmpi(p2m,'No linear',6), val=0;
     else error(['Invalid model type ''',p2m,''''])
     end
     if strcmp(get(hm,'type'),'uicontrol')
       set(hm,'value',max(val,1))
       hmt=findobj(myfig, 'tag','fdtool_text_modeltype');
       if strncmpi(p2m,'No ',3), set([hm;hmt],'visible','off')
       else set([hm;hmt],'visible','on')
       end
     else %toolbar
       hChecked=findobj(allchild(mainfig), ...
         'userdata', 'fdtool_menu_modeltype', 'state', 'on');
       if isempty(hChecked), 
         if ~isempty(hpushed), set(hpushed,'state','on')
         elseif val==0
           if ~matlaberror
             set(findobj(mainfig,'tag','fdtool_menu_modeltype_linear'),'state','on','visible','off')
             set(findobj(mainfig,'tag','fdtool_menu_modeltype_nonlinear_errors'),'state','off','visible','off')
           else 
             delete(findobj(mainfig,'userdata','fdtool_menu_modeltype')); %Error in Matlab: invisible toolbar element makes toolbar wrong 
           end
         elseif val==1, set(findobj(mainfig,'tag','fdtool_menu_modeltype_linear'),'state','on')
         elseif val==2, set(findobj(mainfig,'tag','fdtool_menu_modeltype_nonlinear_errors'),'state','on')
         end
       end
     end
     essdfig=findall(0,'tag','excitation_main');
     if strncmpi(p2m,'Nonlinear errors',6)
       %if nonlinearity set, make selection visible
       set([hm;findobj(hm,'tag','fdtool_menu_modeltype_nonlinear_errors');...
         findobj(hm,'tag','fdtool_menu_modeltype_linear')],'visible','on')
       set(get(hm,'children'),'enable','on')
       if strcmp(get(hm,'type'),'uicontrol'), set(hm,'enable','on'), end
       if get(findobj(essdfig, 'tag', 'essd_uic_stsgrb(4)_singleexp'),'value')
         set(findobj(essdfig, 'tag','essd_uic_repedit'),'String','6')
         set(findobj(essdfig, 'tag','essd_uic_expedit'),'String','1')       
       elseif get(findobj(essdfig, 'tag', 'essd_uic_stsgrb(3)_multiexp'),'value')
         set(findobj(essdfig, 'tag','essd_uic_repedit'),'String','2')
         set(findobj(essdfig, 'tag','essd_uic_expedit'),'String','6')
       end
     else
       set(findobj(essdfig, 'tag','essd_uic_repedit'),'String','1')
       set(findobj(essdfig, 'tag','essd_uic_expedit'),'String','1')       
     end
     fdtool('status', ['Model type set to ' p2m '.']);
     ulevctrl; % settings in other windows
     
   elseif strcmp(p1, 'load_arrow_data') % called by file>load>arrow data
      %fdtool('status', '$yDouble click on an arrow to load data.')
      helpwin('Double click on an active arrow to load data...','Load arrow data')

   elseif strcmp(p1, 'load_input_data') % called by file>load>input data
      %fdtool('status', '$yDouble click on a Read/Meas. block to load input data.')
      %fdtool('status', '$yDouble click on a Read Data block to load input data.')
      helpwin('Double click on an active arrow to load input data...','Load input data')

   elseif strcmp(p1, 'load_workspace_data') % called by file>load>data to wp
      [filename, path]=uigetfile('*.mat', 'Load data to Workspace');
      if ~isstr(filename)
         fdtool('status', 'Import data cancelled')
      else
         file=fullfile(path, filename);
         fdtool('ui_load_workspace_data', file, sender)
      end

   elseif strcmp(p1, 'ui_load_workspace_data') % called by playback or the previous command
      err=0;
      evalin('base', ['load ' p2 ], 'err=1;')
      if err
         disp(lasterr)
         fdtool('status', 'Error: Load data to Workspace failed')
      else
         fdtool('status', ['Data from file ''' p2 ''' loaded to Workspace.'])
      end

   elseif strcmp(p1, 'save_arrow_data') % called by file>save>arrow data
      %fdtool('status', '$yDouble click on an active arrow to save data...')
      helpwin('Double click on an active arrow to save data...','Save arrow data')
   elseif strcmp(p1, 'save_results') % called by file>save>result
      %fdtool('status', '$yDouble click on an arrow and select ''Save''.')
      helpwin('Double click on an arrow and select ''Save''.','Save results')

   elseif strcmp(p1, 'amnesia') % forget panel settings
      % for total amnesia call fdtool('amnesia', 'total')
      % can be called for a specific box only, e.g. fdtool('amnesia', 'excitation_main')
      %fdtool('ui_unfreeze')
      if strcmp(p2, 'total')
         children=guiinfos('children', 'fdtool_main');
      else
         children={p2};
      end
      for chix=1:length(children)
         wintag=children{chix};
         ix=findstr(wintag, '_main');
         name=wintag(1:ix-1);
         guidtawr(Me,  ['STATUS_' name], 'direct','');
      end
      if strcmp(p2, 'total')&~guiinfos('islinear')
        fdtool('modeltype','linear')
      end
      
   elseif strcmp(p1, 'getguimodes') % get gui's development and measurement mode
      out1=guidtard('fdtool_main', 'CurrentGuiModes');

   elseif strcmp(p1, 'setguimodes') % set gui's development and measurement mode
      if nargin<2  % auto set
         if exist('fdguidev.mat','file')
            modestr='DM';
         else
            modestr='';
         end
         if exist('fdguimeas.mat','file')
            modestr=[modestr, 'M'];
         else
         end
      else % manual set
         modestr=p2;
         msg='GUI mode set: ';
         if findstr(modestr, 'D')
            msg=[msg, 'Development on, '];
         else
            msg=[msg, 'Development off, '];
         end
         if findstr(modestr, 'M')
            msg=[msg, 'Measurement on.'];
         else
            msg=[msg, 'Measurement off.'];
         end
         fdtool('status', msg)
      end
      if isempty(modestr), 
        1;
      end
      guidtawr('fdtool_main', 'CurrentGuiModes', 'direct', modestr)

   elseif strcmp(p1, 'close_all_windows') % close all windows except FDTOOL main window
      h=allchild(0);
      h=setdiff(h, myfig);
      for ix=1:length(h)
        if ishandle(h(ix))
          if strcmp(get(h, 'visible'), 'on')
            try, close(h), catch, 1; end
          else
            delete(h)
          end
        end
      end
      
    elseif strcmp(p1, 'ui_unfreeze') % unfreeze menu
      % (seldom necessary, auto unfreeze almost always helps)
      fdtool('status','Please wait, unfreeze in progress...')
      fr=guifreez('all_fdtool', 'unfreeze', 'force');
      if any(fr)
        fdtool('status','FDTool unfrozen.')
      else
        fdtool('status','There is nothing to unfreeze.')
      end
      
    elseif strcmp(p1, 'ui_advanced_on')
      V=version; 
      if (str2num(V(1))<=6)&(str2num(V(1:3))>5.2)
        lab=guiinfos('UserLevel');
        ham = findall(0, 'tag', 'fdtool_menu_advanced_on');
        label=get(ham,'label');
        ha=findall(0, 'tag', 'fdtool_menu_userlevel_advanced');
        uimt=findall(0,'tag','fdtool_menu_userlevel_modeltype');
        nlset=strcmp(get(findall(uimt, 'tag', 'fdtool_menu_modeltype_nonlinear_errors'),'state'),'on');
        hnl=[findall(uimt,'tag','fdtool_menu_modeltype_linear');...
            findall(uimt,'tag','fdtool_menu_modeltype_nonlinear_errors')];
        delete(hnl), %drawnow
        %
        %uist=findall(0,'tag','fdtool_menu_userlevel_signaltype');
        allset=strcmp(get(findall(uimt, 'tag', 'fdtool_menu_signaltype_all'),'state'),'on');
        hst=[findall(uimt,'tag','fdtool_menu_signaltype_all');...
            findall(uimt,'tag','fdtool_menu_signaltype_periodic')];
        delete(hst), %drawnow
        %
        if ~isempty(ha), delete(ha), end
        if any(findstr('Enable',label)) 
          ha=uitoggletool(uimt,...
            'tooltipstring','User level: Advanced',...
            'cdata',getcd('ulad'),...
            'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_userlevel_set'', ''Advanced'', ''fdtool_menu_userlevel_advanced'')',...
            'userdata', 'fdtool_menu_userlevel',...
            'tag',	'fdtool_menu_userlevel_advanced');     
        end
        %
        uimenu_signaltype_all=uitoggletool(uimt,...
          'tooltipstring','Signal type: All',...
          'separator','on',...
          'cdata',getcd('stall'),...
          'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_signaltype_set'', ''All'', ''fdtool_menu_signaltype_all'')',...
          'userdata', 'fdtool_menu_signaltype',...
          'tag',		'fdtool_menu_signaltype_all',...
          'state','on'); % this is the default
        uimenu_signaltype_periodic=uitoggletool(uimt,...
          'tooltipstring','Signal type: Periodic only',...
          'separator','off',...
          'cdata',getcd('stper'),...
          'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_signaltype_set'',''Periodic'', ''fdtool_menu_signaltype_periodic'')',...
          'userdata', 'fdtool_menu_signaltype',...
          'tag',		'fdtool_menu_signaltype_periodic',...
          'state','off'); 
        %
        uimenu_modeltype_linear=uitoggletool(uimt,...
          'tooltipstring','Model type: Linear',...
          'separator','on',...
          'cdata',getcd('mtli'),...
          'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_modeltype_set'', ''Linear'', ''fdtool_menu_modeltype_linear'')',...
          'userdata', 'fdtool_menu_modeltype',...
          'tag','fdtool_menu_modeltype_linear',...
          'state','on'); % this is the default
        uimenu_modeltype_nonlinear_error=uitoggletool(uimt,...
          'tooltipstring','Model type: Nonlinear errors',...
          'separator','off',...
          'cdata',getcd('mtne'),...
          'clickedcallback', 'fdtool(''callback'', ''fdtool'', ''ui_modeltype_set'', ''Nonlinear errors'', ''fdtool_menu_modeltype_nonlinear_errors'')',...
          'userdata', 'fdtool_menu_modeltype',...
          'tag',		'fdtool_menu_modeltype_nonlinear_errors',...
          'state','off'); % this is the default
        %if strcmpi('interactive',lab), fdtool('userlevel',lab), end
        if strcmpi('advanced',lab), fdtool('userlevel','interactive'), end
        if allset, fdtool('signaltype','All'), end
        if nlset, fdtool('modeltype','Nonlinear errors'), end
        if any(findstr('Enable',label)) 
          set(ham,'label','&Disable advanced level') 
        else
          set(ham,'label','&Enable advanced level') 
        end %enable/disable
      else %7.x, 5.2
        ha = findall(0, 'tag', 'fdtool_menu_userlevel_advanced');
        ham = findall(0, 'tag', 'fdtool_menu_advanced_on');
        if ~ishandle(ha)
          error('Cannot find advanced level item') 
        end
        if strcmp(get(ha,'visible'),'off')
          set(ha,'visible','on')
          set(ham,'label','&Disable advanced level') 
        elseif strcmp(get(ha,'visible'),'on')
          if ((str2num(V(1:3))==5.2)&isequal(get(ha,'checked'),1))
            fdtool userlevel Interactive
          elseif (str2num(V(1:3))>5.2)
            if strcmp(get(ha,'state'),'on')
              fdtool userlevel Interactive
            end
          end
          set(ha,'visible','off')
          set(ham,'label','&Enable advanced level') 
        end
      end
      
   elseif findstr(p1, 'forget_settings') % forget user panel settings
      fdtool('status','Please wait, clearing in progress...')
      fdtool('amnesia', 'total')
      fdtool('status', 'Button settings set to default in all panels')

   elseif findstr(p1, 'forget_data') % forget arrow data
      fdtool('status','Please wait, clearing in progress...')
      c=guiinfos('children', 'fdtool_main');
      for ii=1:length(c)
         h=findall(0, 'tag', c{ii});
         if ishandle(h) % it might have disappeared in the meantime...
            if strcmp(get(h, 'visible'), 'on')
               close(h)
            else
               delete(h)
            end
         end
      end
      boxmgr('init', 'fdtool_main')
      fdtool('status','FDTool main window cleared')

   elseif strcmp(p1, 'ui_forget_all') % forget arrow data and panel settings
      fdtool('forget_settings')
      fdtool('forget_data')
      ulevctrl
      
   elseif strcmp(p1, 'ui_help_introductions')
      fddgui1('intro')

   elseif strcmp(p1, 'ui_help_introductions_gui')
      fddgui1('intro_gui')

   elseif strcmp(p1, 'ui_help_introductions_ident')
      fddgui1('intro_ident')

   elseif strcmp(p1, 'ui_help_examples')
      fddgui1

   elseif strcmp(p1, 'ui_help_tests') %only in development mode
      fddgui1('test')

   elseif strcmp(p1, 'ui_help_data_web')
      webaddr='http://home.mit.bme.hu/~kollar/fdident/fdident-datasheet.pdf';
      disp(['Connecting to ''',webaddr,''''])
      web(webaddr);
      clear webaddr

   elseif strcmp(p1, 'ui_help_manual_int')|strcmp(p1, 'ui_help_manual')
      %manfile=[matlabroot,filesep,'help',filesep,'pdf_doc',filesep,'fdident',filesep,'fdident.pdf'];
      manfile=[fdtool('root'),filesep,'private',filesep,'fdident.html'];
      manfilepdf=[manfile(1:end-4),'pdf'];
      if exist(manfilepdf)
        %disp(['Opening ''',manfile,''''])
        if strcmp(p1, 'ui_help_manual')
          %force external browser
          failed=web(manfilepdf,'-browser');
        elseif strcmp(p1, 'ui_help_manual_int')
          %internal browser
          failed=web(manfile);
        end
        if failed
          fdtool('status','Error: Matlab cannot launch browser')
          warning(['Matlab cannot launch browser'])
        end
      else
        helpwin('Cannot localize manual file, it is probably not yet installed')
        warning(['Cannot find pdf file of the manual'])
      end
      clear manfile

   elseif strcmp(p1, 'ui_help_devb_web')
      webaddr='http://home.mit.bme.hu/~kollar/fdident/';
      disp(['Connecting to ''',webaddr,''''])
      web(webaddr);
      clear webaddr

   elseif strcmp(p1, 'ui_help_faq_web')
      webaddr='http://home.mit.bme.hu/~kollar/fdident/fdident-FAQ.html';
      disp(['Connecting to ''',webaddr,''''])
      web(webaddr);
      clear webaddr

   elseif strcmp(p1, 'ui_help_dev_mail')
      %webaddr='mailto:fdident@vub.ac.be';
      %disp(['Connecting to ''',webaddr,''''])
      %web(webaddr);
      %clear webaddr
      %disp('Send technical questions to: fdident@vub.ac.be')
      
      %helpwin(['A lot of information is available from the WEB page',setstr(10),...
      %  '  http://home.mit.bme.hu/~kollar/fdident/',setstr(10),...
      %  'if you have more technical questions, please email to:',setstr(10),...
      %  '  fdident@vub.ac.be',setstr(10),...
      %  'with questions concerning sales and availability, turn to:',setstr(10),...
      %  '  fdident@x2con.com'],'Technical Support')
      helpwin('technical_support')
      
   elseif strcmp(p1, 'ui_help_lic')
     fid=fopen('fdlicens.m','r');
     if fid==-1, error('Cannot open license file'), end
     helpstr=fread(fid); fclose(fid);
     helpstr=setstr(helpstr(:)');
     ind=findstr(setstr([13,10]),helpstr);
     if ~isempty(ind), helpstr(ind)=''; end
     %helpwin(helpstr,'License information');
     helpwin('license_info');
     %type fdlicens

   elseif strcmp(p1, 'ui_help_about')
     helpstr=['Version: ',fdtool('version'),setstr(10),...
         'Date: ',fdtool('date'),setstr(10),...
         'Command-line toolbox: István Kollár, Johan Schoukens, Rik Pintelon',setstr(10),...
         'Graphical user interface: István Kollár, Gyula Simon, Gyula Román'];
     %helpwin(helpstr,'About the fdident toolbox');
     helpwin('about_FDIDENT')
     %type fdlicens
     
   elseif strcmp(p1,'fdtool_uic_print')
     % print command
     fdgprint(Me)
     fdtool('status','Print figure done.')

   elseif strcmp(p1,'fdtool_mod_print_ps')
     % print command
     fdgprint(Me,'eps')
     
   elseif strcmpi(p1,'install')|strcmpi(p1,'uninstall')
     fdident(varargin{:})
     
   elseif strncmp(p1,'license',3)
     if nargout>=1
       out1=fdident(varargin{:});
     else
       fdident(varargin{:});
     end
     
   elseif strcmp(p1,'preload')
     disp('Preloading GUI functions...')
     t0=clock;
     essd('preload')
     gettime('preload')
     gfdd('preload')
     agv('preload')
     sme('preload')
     caem('preload')
     if guiinfos('ismeasurement')
       fdsimul('preload')
       fdmeasw('preload')
     end
     guiimpv('preload')
     fdhlpstr('fdtool_main', 'rect_gettime'); % help
     %
     guirecrd('preload');
     guiimpv('preload')
     arrplot('preload')
     guimenus('preload')
     boxmgr('preload')
     fprintf('  Elapsed time: %.1f s\n',etime(clock,t0))
     %
     fdident preload
     return
     
   elseif strncmpi(p1,'object',3)
     elis object

   elseif strcmp(p1,'resize')
      pos=get(mainfig, 'position');
      dx=pos(3);
      dy=pos(4);
      %pos=get(findobj(mainfig, 'tag','fdtool_menu_userlevel'),'position');
      %set(findobj(mainfig, 'tag','fdtool_menu_userlevel'),'position',[pos(1) dy-22-20 pos(3) pos(4)]);
      %pos=get(findobj(mainfig, 'tag','fdtool_text_userlevel'),'position');
      %set(findobj(mainfig, 'tag','fdtool_text_userlevel'),'position',[pos(1) dy-22 pos(3) pos(4)]);
      %
      if strncmp(version,'5.2',3)
        pmod=0;
        pos=get(findobj(mainfig, 'tag','fdtool_menu_modeltype'),'position');
        set(findobj(mainfig, 'tag','fdtool_menu_modeltype'),'position',[pos(1) dy-22-20-pmod pos(3) pos(4)]);
        pos=get(findobj(mainfig, 'tag','fdtool_text_modeltype'),'position');
        set(findobj(mainfig, 'tag','fdtool_text_modeltype'),'position',[pos(1) dy-22-pmod pos(3) pos(4)]);
      end
      %
      frame_status=findobj(mainfig, 'tag', 'frame_status');
      text_status=findobj(mainfig, 'tag', 'status_main');
      posframe=get(frame_status,'position');
      postext=get(text_status,'position');
      posframe(3)=dx;
      postext(3)=dx-6;
      set(frame_status,'position',posframe);
      set(text_status,'position',postext);
      % text size setting
      h_rect=findobj(mainfig, 'tag', 'rect_excitation');
      rect_posy=get(h_rect, 'xdata');
      rect_width=max(rect_posy)-min(rect_posy); % width of a rect object
      rect_width=rect_width*0.99;
      texth=findobj(mainfig, 'type', 'text');
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

      intoscr({Me});
      % The above function, intoscr positions the windows given by their labels
      % into the actual screen. This might come handy when the session has been saved
      % on a machine with different resolution than that of the present machine.


   elseif strcmp(p1, 'session') % command call: load session as well
      fdtool
      sesload(p2);
   elseif strcmp(p1, 'logo')
      intro('begin')
   else
      if guiinfos('isdevelopment')
         error(['FDTool called with bad parameter: ' p1])
      else
         error(['FDTool called with bad parameter.'])
      end
   end % of instructions
end


% Logo Screen Handler Fcn
function intro(command, param)
h_intro=findobj(allchild(0), 'flat', 'tag', 'fdtool_intro_screen');
switch command
case 'begin'
   OldUnit=get(0, 'units');
   set(0, 'units', 'pixels');
   scrsize=get(0,'screensize');
   set(0, 'units', OldUnit);
   dx=300; dy=200;
   if ishandle(h_intro), delete(h_intro), end
   h_intro=figure(...
      'tag','fdtool_intro_screen',...
      'integerhandle', 'off',...
      'handlevisibility', 'off',...
      'color', [0 0 0],...
      'pointer','watch',...
      'units', 'pixels',...
      'position',[scrsize(3)/2-dx/2, scrsize(4)/2-dy/2, dx, dy],...
      'resize','off',...
      'name',['FDTool '],...
      'numbertitle','off',...
      'windowstyle', 'modal', ...
      'menubar', 'none');
   ax=axes('parent', h_intro, ...
      'units', 'normal', ...
      'position', [0 0 1 1], ...
      'visible', 'off');
   logoname=which('fdtlogo.mat','-all');
   logo=imread(logoname{1}, 'jpg');
   image(logo, 'parent', ax)
   set(ax, 'visible', 'off')
   text=uicontrol('parent', h_intro, ....
      'units', 'pixel', ...
      'position', [1 1 dx 20], ...
      'style', 'text', ...
      'foregroundcolor', 'y', ...
      'backgroundcolor', [0 0 0], ...
      'string', 'FDTool is loading, please wait...', ...
      'visible', 'off', ...
      'tag', 'fdtool_logo_text');
   drawnow

case 'end'
   if ishandle(h_intro), delete(h_intro), end
end

function cdata=getcd(code)
%GETCD  Get uitoggletool pictures
%
%       code:
%         ulsi - User level Simple  
%         ulau - User level Automatic  
%         ulia - User level Interactive  
%         ulad - User level Advanced
%         mtli - Model type Linear
%         mtne - Model type Nonlinear errors
%
%       See also: FDTOOL.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2004
%       All rights reserved.
%       $Revision
%       Last modified: 20-Mar-2004

if strcmp(code,'ulau')
  pic=[...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '            0  0';...
      '0           00 0';...
      '0000000000000000';...
      '0           00 0';...
      '            0  0';...
      '                '];
elseif strcmp(code,'ulsi')
  pic=[...
      '                ';...
      '                ';...
      '     00      00 ';...
      '    0  0    0  0';...
      '    0  0    0  0';...
      '  00   0  00   0';...
      ' 0     0 0     0';...
      '0       0       ';...
      '                ';...
      '            0  0';...
      '0           00 0';...
      '0000000000000000';...
      '0           00 0';...
      '            0  0';...
      '                '];
elseif strcmp(code,'ulia')
  pic=[...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '    0  0    0  0';...
      '0   00 0    00 0';...
      '0000000000000000';...
      '0   00 0    00 0';...
      '    0  0    0  0';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                '];
elseif strcmp(code,'ulad')
  pic=[...
      '            0  0';...
      '            00 0';...
      '    0  0   00000';...
      '0   00 0  0 00 0';...
      '0000000000  0  0';...
      '0   00 0        ';...
      '    0  0        ';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '                '];
elseif strcmp(code,'stper')
  pic=[...
      '                ';...
      '                ';...
      '                ';...
      '                ';...
      '   000          ';...
      '  00 00         ';...
      ' 00   00       0';...
      '00     00     00';...
      '0       00   00 ';...
      '         00 00  ';...
      '          000   ';...
      '                ';...
      '                ';...
      '                ';...
      '                '];
elseif strcmp(code,'stall')
  pic=[...
      '                ';...
      '              00';...
      '             00 ';...
      '            00  ';...
      '   000      00  ';...
      '  00 00    00   ';...
      ' 00  00    00   ';...
      ' 00   00  00    ';...
      ' 00   00 00     ';...
      '00     000      ';...
      '00              ';...
      '00              ';...
      '00              ';...
      '00              ';...
      '                '];
elseif strcmp(code,'mtli')
  pic=[...
      ' 0            00';...
      ' 0           00 ';...
      ' 0          00  ';...
      ' 0         00   ';...
      ' 0        00    ';...
      ' 0       00     ';...
      ' 0      00      ';...
      ' 0     00       ';...
      ' 0    00        ';...
      ' 0   00         ';...
      ' 0  00          ';...
      ' 0 00           ';...
      ' 000            ';...
      ' 000000000000000';...
      '                '];
elseif strcmp(code,'mtne')
  pic=[...
      ' 0           000';...
      ' 0         000  ';...
      ' 0       000    ';...
      ' 0      000     ';...
      ' 0     00       ';...
      ' 0    00        ';...
      ' 0   00         ';...
      ' 0  00          ';...
      ' 0  00          ';...
      ' 0 00           ';...
      ' 0 00           ';...
      ' 000            ';...
      ' 000            ';...
      ' 000000000000000';...
      '                '];
else
  error('Invalid code')
end
%Make cdata for an uitoggletool

if any([size(pic,1),size(pic,2)]~=[15,16]), error('Size of pic is not [15,16]'), end
cdata=zeros(size(pic));
ind=find(pic==' ');
cdata(ind)=NaN*cdata(ind);
if size(cdata,3)==1
  cdata=cdata(:,:,ones(1,3));
end

%End of file
