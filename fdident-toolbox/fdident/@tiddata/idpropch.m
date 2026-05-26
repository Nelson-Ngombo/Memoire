function [props,values,indp] = idpropch(dat,property,mode)
%IDPROPCH  Return the string of properties and their admissible values  
%       for the object class of object DAT (tiddata).
%       If property is not given, all properties are returned
%       MODE modifies the list of properties:
%       list: mode - 'set', 'all', '', 'child', 'childset'
%       single property: mode - '', 'noerror'

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Aug-2003

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
if ~isa(dat,'tiddata'), error('class is not ''tiddata'''), end
if nargin<2, property=''; end
if nargin<3, mode=''; end
%
%All specific TIDDATA Properties
props = ['|Version|Ts|TStart|InputTStart|OutputTStart|',...
    'SamplingInstants|InputSamplingInstants|OutputSamplingInstants|SampleNumber|',...
    'PeriodNumber|PeriodSamples|',...
    'iddat|',...
    'InputVariance|OutputVariance|'];
%Property list also directly handled in tiddata.m when defining fields

if nargout>1 %values also needed
  values = {...
      'scalar';...
      'scalar or cell array'; ...
      'scalar or cell array';...
      'vector or cell array';...
      'vector or cell array';...
      'vector or cell array';...
      'vector or cell array';...
      'vector or cell array';...
      'read-only scalar';...
      ...
      'positive number, preferably integer';...
      'positive number, preferably integer';...
      ...
      'Hidden propery: iddat object';...
      'scalar or cell array';...
      'scalar or cell array'...
    };
end
if (nargin>=2)&strncmpi(property,'SampleTimes',7)
  warning('Property ''SampleTimes'' is obsolete, use ''SamplingInstants'' instead')
  property='SamplingInstants';
end

if ~any(findstr(mode,'child'))
  s=struct(dat); siddat=s(1).iddat;
  [props2,values2]=idpropch(siddat,'',mode); %properties of iddat
  ind=find(props=='|');
  vi=findstr('|Version|',props);
  props(vi+[0:7])='';
  props=[props2,props(2:end)];
  if nargout>1
    %Eliminate Version
    id=find(ind==vi);
    values(id)=[];
    values=[values2;values];
  end
end

ind=find(props=='|'); pno=length(ind)-1;
if (nargout>1)&(length(values)~=pno)
  error('Different number of properties and values')
end
%
if (nargin==1)|isempty(property), return, end

if ~isempty(property) %Property to be determined
  if (length(property)>1)&any(findstr(lower(property(1)),'yu'))&~strncmpi(property,'use',3)
    if strcmp(lower(property(1)),'u'), property=['input',property(2:end)];
    elseif strcmp(lower(property(1)),'y'), property=['output',property(2:end)];
    end
  end
  if strncmpi(property,'InputData',7)
    property='Input';
  elseif strncmpi(property,'OutputData',8)
    property='Output';
  elseif strcmpi(property,'InputD')
    indpstr=[2,3];
  elseif strcmpi(property,'OutputD')
    indpstr=[2,3];
  else
    indpstr=findstr(lower(props),['|',lower(property)]);
  end
  if strcmp(lower(property),'input')|strcmp(lower(property),'output')|...
      strcmp(lower(property),'ts')
    indpstr=findstr(lower(props),['|',lower(property),'|']);
  end
  if strcmp(lower(property),'u')|strcmp(lower(property),'y')|strcmp(lower(property),'groups') 
    %u or y or groups
    indpstr=findstr(lower(props),['|',lower(property),'|']);
  end
  if isempty(indpstr)
    error(['Unidentifiable tiddata property ',property])
  else
    if indpstr(1)==1, indpstr(2)=[]; end %eliminate Names ambiguity
    if length(indpstr)>1
      error(['Ambiguous tiddata property ',property])
    else
      indi=min(find(ind>indpstr)); inde=ind(indi);
      props=props(indpstr+1:inde-1);
      if nargout>1
        no=length(find(ind<=indpstr)); values=values{no};
        indp=find(ind==indpstr);
      end
    end
  end
end
%
% end @tiddata/idpropch.m
