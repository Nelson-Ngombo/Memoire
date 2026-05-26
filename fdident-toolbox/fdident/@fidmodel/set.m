function Out = set(data,varargin)
%SET  Set properties of fidmodel object.
%
%   SET(DATA,'Property',VALUE)  sets the property of DATA specified
%   by the string 'Property' to the value VALUE.
%
%   SET(DATA,'Property1',Value1,'Property2',Value2,...)  sets multiple 
%   property values with a single statement.
%
%   SET(DATA,'Property')  displays possible values for the specified
%   property of DATA.
%
%   SET(DATA)  displays all properties of DATA and their admissible 
%   values.
%
%   See also  GET.
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 13-Aug-2004

ni = nargin;
no = nargout;
%
if (ni>=3)&~isa(data,'fidmodel')&isstr(varargin{1})
  %In this case, call was initiated for built-in set: set(handle,string,value...)
  %so call built-in set
  setstr='builtin(''set'',data';
  for ii=1:length(varargin)
    setstr=[setstr,',varargin{',num2str(ii),'}'];
  end
  setstr=[setstr,');'];
  if no==1, setstr=['Out=',setstr]; end
  %disp(setstr)
  eval(setstr)
  return
end
if ~isa(data,'fidmodel'),
   error('The first argument of SET must be an fidmodel object.');
elseif no & ni>1,
   error('Output argument allowed only in SET(DATA), with one input argument only');
end
% Get properties and their admissible values
[Props,PValues] = idpvpget(data);
variable=get(data,'variable');
indskip=[];
if (isstr(variable)&~any(findstr(variable,'z')))|(iscell(variable)&~any(findstr(variable{1},'z')))
  indskip=strmatch('Fs',Props,'exact'); %Props(ind)=''; PValues(ind)='';
  if strcmp(get(data,'representation'),'orthopol')
    ind=strmatch('Fscale',Props,'exact');
    PValues{ind}='scalar, scaling frequency of orthogonal basis';
  end
else %z
  indskip=strmatch('Fscale',Props,'exact'); %Props(ind)=''; PValues(ind)='';
end
indskip=[indskip;strmatch('Type',Props,'exact')];
indskip=[indskip;strmatch('ioDelayMatrix',Props,'exact')];
if ni==1 %all possible properties
  if ~isempty(indskip)
    Props(indskip)=''; PValues(indskip)='';
  end
  lPV=length(PValues);
   if no,
     Out = cell2struct(PValues,Props,1);
   else
     shprops(Props,PValues,':  ',fidmodel)
   end
   return
elseif ni==2 %possible values of one given property
   str = varargin{1};
   if ~isstr(str),
      error('Property names must be single-line strings');
   end
   % Return admissible property value(s)
   Property = lower(varargin{1});
   [Property,dummy,indp]=idpvpstr(data,Property);
   if strncmpi(Property,'Fs',2)
     variable=get(data,'variable');
     if strcmpi(Property,'Fs')&~any(findstr(variable,'z'))
       error(['Fs is not allowed for variable ''',variable,''''])
     elseif strcmpi(Property,'Fscale')
       if any(findstr(variable,'z'))
         error(['Fscale is not allowed for variable ''',variable,''''])
       end
     end
   elseif strcmpi(Property,'InterSample')&~any(findstr(get(data,'variable'),'z'))
     error(['Property Intersample is not defined for variable ''',get(data,'variable'),''''])
   end
   if indp>length(PValues), error(['Property ''',Property,''' cannot be set']), end
   if no,
     Out = PValues{indp};
   else
     disp(PValues{indp})
   end
   return
elseif no,
   error('No output argument when set is called with PV pairs.')
elseif rem(ni-1,2)~=0,
  if ~strcmp(varargin{ni-1},'noconsistency')
    error('Property/Value pairs must come in even number.')
  end  
end
% Now we have set(data,P1,V1, ...)
name = inputname(1);
if isempty(name),
   error('First argument to set must be a named variable.')
end
for i=1:2:ni-1,
   % Set each PV pair in turn
   Property = varargin{i};
   %return if 'noconsistency' is requested, without checking consistency
   if strcmpi(Property,'noconsistency'), break, end
   %
   Value = varargin{i+1};
   Property=idpvpstr(data,varargin{i}); %Exact property  
   
   switch lower(Property)
   case 'name'
     if ~isstr(Property), error('Name must be a string'), end 
     if min(size(Property))~=1, error('Name must be a single string'), end
   case 'version'
   case 'date'
   case 'notes'
   case 'history'
   case 'algorithm'
   case 'userdata'
   case 'data'
   case 'type'  
     error('Property ''Type'' is read-only')
   case 'coefficients'  
     data.newproperties.Coefficients=Value;  
   case 'taur'  
     data.newproperties.tauR=Value;  
   case 'intersample'  
     data.newproperties.InterSample=Value;  
   case 'num'
     set(data,'covariance',[],'noconsistency')  
   case 'denom'
     set(data,'covariance',[],'noconsistency')  
   case 'a'
     set(data,'covariance',[],'noconsistency')  
   case 'b'
     set(data,'covariance',[],'noconsistency')  
   case 'c'
     set(data,'covariance',[],'noconsistency')  
   case 'd'
     set(data,'covariance',[],'noconsistency')  
   case 'f'
     set(data,'covariance',[],'noconsistency')  
   case 'ntr'
     set(data,'covariance',[],'noconsistency')  
   case 'fixedpar'
   case 'varet'
   case 'fitinfo'
   case 'errorweighting'
   case 'variable'
     if ~strcmp(data.variable,Value)
       error('Change of variable of fidmodel is not yet implemented')
     end
   case 'representation'
   case {'znum', 'zdenom', 'zntr'}
     if ~isempty(Value), set(data,'representation','orthopol','noconsistency'); end
   case 'freqvect'
   case 'fs'
     variable=get(data,'variable');
     if ~any(findstr(variable,'z'))
       warning(['Property ''Fs'' is being be set instead of ''Fscale'''])
     end
   case 'fscale'
     variable=get(data,'variable');
     if any(findstr(variable,'z'))
       error(['Property Fscale cannot be set for variable ''',variable,''''])
     elseif strcmpi(data.representation,'orthopol')&...
         ~isequal(data.fs,Value)
       warning('Changing fscale in orthopol makes the model inconsistent')
     end
     Property='Fs';  
   case 'delay'
   case 'iodelaymatrix'
     Property='Delay';
   case {'outputdelay','inputdelay','outputgroup','inputgroup'}
   case {'outputname','inputname','outputunit','inputunit',}
   case 'covariance'
   case 'consistency'
   case 'ts'
     Property='Fs'; Value=1/Value;  
   otherwise
      error('Unexpected property name.')
   end % switch
   %
   if strcmp(Property,'Znum')|strcmp(Property,'Zdenom')|strcmp(Property,'Zntr')
     propn=Property;
   else
     propn=lower(Property);
   end
   if strcmpi(Property,'Delay')&strcmp(data.representation,'orthopol')
     Value=Value*get(data,'fscale');
   end
   if strcmpi(Property,'Coefficients')
   elseif strcmpi(Property,'InterSample')
   elseif strcmpi(Property,'tauR')
   elseif strcmpi(Property,'errorweighting')
     if strncmpi(Value,'linear',3), Value='Linear';
     elseif strncmpi(Value,'nonlinear',6), Value='Nonlinear';
     elseif strncmpi(Value,'odd nonlinear',8), Value='Odd nonlinear';
     end
     if isstr(Value)&(isempty(Value)|any(strmatch(Value,{'Linear','Nonlinear','Odd nonlinear'})))
       fiti=get(data,'fitinfo');
       fiti.errorweighting=Value;
       set(data,'fitinfo',fiti);
     else
       error(['Bad value of ''errorweighting'': ',Value])
     end
   else
     eval(['data.',propn,'=Value;'])
     %dats=struct(data);
     %eval(['dats.',Property,'=Value;'])
     %datanew=fidmodel(dats);
   end
 end % for
  
 if ~strcmpi(Property,'noconsistency')
   if ~get(data,'consistency')
     error('Inconsistent data after setting the properties: see the warning message above for the reason')
   end
 end
%
% Finally, assign data in caller's workspace
assignin('caller',name,data)
%
%end @fidmodel/set.m
