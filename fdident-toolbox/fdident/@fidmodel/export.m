function Outstruct = export(obj,mode)
%EXPORT  Export object as structure or variables in the base workspace
%
%       Examples: 
%         s=export(modelobj);
%         export(modelobj,'vars') %clear base workspace, then creates variables

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 01-Sep-2003

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,2,ni)), %earlier
end
if nargin<2, mode=''; end
if isempty(mode)|strcmp(mode,'vars')
else error(['mode is invalid> ''',mode,''''])
end

date=obj.date; obj.date='';
m=fidmodel; m.date='';
if isequal(obj,m)
  plist=1;
  Out=set(obj);
  fns=fieldnames(Out);
  for ii=1:length(fns)
    if strcmp(fns{ii},'Version')
      Out.Version=get(fiddata,'Version');
    else
      if strcmpi(fns{ii},'Intersample')|ischar(get(obj,fns{ii})), Out=setfield(Out,fns{ii},'');
      elseif iscell(get(obj,fns{ii})), Out=setfield(Out,fns{ii},{});
      else Out=setfield(Out,fns{ii},[]);
      end
    end
  end
else %list of true properties
  plist=0;
  obj.date=date; %restore
  Out=get(obj);
  if isfield(Out,'Data')
    if isa(Out.Data,'fiddata'), Out.Data=export(Out.Data); end
  end
end

fns={'Fscale','InputGroup','OutputGroup','InputChNumber','OutputChNumber',...
    'tauR','Znum','Zdenom','Zntr','Ntr','Representation','Coefficients','Algorithm','FitInfo',...
    'InputDelay','OutputDelay'};
%if plist, fns=[fns,{'Information'}]; end
for fn=fns
  if isfield(Out,fn{1}), 
    Out=rmfield(Out,fn{1});
  else
    %warning(['Property ''',fn{1},''' does not exist'])
  end  
end

if no>=1
  Outstruct=Out;
end
if strcmp(mode,'vars')
  evalin('base','clear')
  struct2vars(Out)
end
%End of export


function struct2vars(s)
%STRUCT2VARS  Generate variables from structure fields

if ~isstruct(s), error('s is not a structure'), end
fns=fieldnames(s);
for ii=1:length(fns)
  assignin('base',fns{ii},getfield(s,fns{ii}))
end

% end of file @fidmodel/export.m
