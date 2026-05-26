function loadhist(filename,rtype,discardpause)
%LOADHIST Load history from file
%
%       Examples: 
%          loadhist emachdem
%          %You may open the recorder beforehand in any style
%          loadhist testautolevel dev ndp
%          %Load history in development mode, and stop at first pause
%          loadhist testautolevel std load
%          %Load history in standard mode and stop at first command
%
%       Defaults: rtype='dev', discardpause=dp

%       rtype = 'dev' means to run in development mode, 'std' in standard mode
%       discardpause = 'dp' if run in discardpause mode

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 31-Aug-2003, IK

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
filenamec=filename;
if ~iscell(filenamec), filenamec={filenamec}; end
filename=filenamec(:)'; if iscell(filename), filename=filename{1}; end
ind1=findstr('(',filename); ind2=findstr(')',filename);
if ~isempty(ind1), varname=filename(ind1+1:ind2-1); filename=filename(1:ind1-1); 
else varname='';
end
%filename=filename{1};
if exist([filename,'.mat'],'file'), filename=[filename,'.mat']; end
if ~exist(filename,'file')
  dc=struct2cell(dir);
  ind=strmatch(filename,dc(1,:));
  if length(ind)==1
    filename=dc{1,ind};
  else
    error(['Cannot find file ''',filename,''''])
  end
end
disp(['Loading action history from file ''',filename,''''])
varstr=load(filename,'-mat');
vars=fieldnames(varstr);
if ~isempty(varname), vars={varname}; end
validh=0;
for hi=1:length(vars)
  history_data1=getfield(varstr,vars{hi});
  if ~isfield(history_data1,'history')|~isfield(history_data1,'history')|...
      ~isfield(history_data1,'time')
    %warning(['Variable ''',vars{hi},''' in file ''',filename,''' is not a history record'])
  elseif isempty(history_data1.history)
    warning(['Empty history in file ''',filename,''', variable ''',vars{hi}])
    validh=1;
  else
    validh=1;
    if nargin<3, discardpause='ndp'; end
    guirecrdtype='development'; %Initialize development recorder
    fdtool quick
    if ~fdtool('callback','guiinfos','isdevelopment')
      guirecrdtype='recorder'; %Initialize demo recorder
    end
    if nargin<2, rtype=''; end
    if strncmp(rtype,'dev',3)|(isempty(rtype)&fdtool('callback','guiinfos','isdevelopment'))
      guirecrdtype='development';
    end
    fdtool('callback','guirecrd','init',guirecrdtype)
    fdtool('callback','guirecrd','stop')
    fdtool('callback','guirecrd','LoadHist',filename,vars{hi})
    if fdtool('callback','guiinfos','isdevelopment')&strcmpi(computer,'SOL2')
      hr=findall(0,'type','figure','tag','fdtool_recorder_fig');
      pos=get(hr,'position');
      if pos(2)==50, pos(2)=pos(2)+20; set(hr,'position',pos), end
    end
    fdtool('callback','guirecrd','SetEmulatemouse', 0)
    fdtool('callback','guirecrd','SetContinuous', 1)
    if strncmpi(discardpause,'s',1), return, end
    if strncmpi(discardpause,'n',1), dp=0;
    else dp=1;
    end
    fdtool('callback','guirecrd','SetDiscardPause', dp)
    if dp
      %This is the start of running the demo:
      fdtool('callback','guirecrd','PlayHist')
    end
  end
end %for hi
if validh==0
  error(['File ''',filename,''' is not a history file'])
end
%
%End of loadhist