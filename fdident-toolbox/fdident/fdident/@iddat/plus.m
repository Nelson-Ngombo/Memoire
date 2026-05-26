function Out = plus(varargin)
%PLUS  Unify two object by putting the samples beside each other
%       dat1 + dat2 ...
%       The first object dominates (e.g. Name)
%
%       See also: @tiddata/plus

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Dec-1998

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,100); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,100,ni)), %earlier
end
if isa(varargin{1},'fiddata')
  error('Function ''+'' not defined for variables of class ''fiddata''.')
end

if length(varargin)==1, Out=varargin{1}; return, end

Out=varargin{1};
for ii=2:length(varargin)
  dat2=varargin{ii};
  
  if ~strcmp(class(Out),class(dat2))
    error('All input arguments must be objects of the same class')
  end
  if strcmp(class(Out),'iddat')
    if ii==2, Out=iddat(struct(Out)); end
  else
    error('Class is not iddat')
  end
  %Name, UserData stays that of Out
  dtmp=iddat; Out.Date=dtmp.Date; Out.Version=dtmp.Version;
  Out.Notes=''; Out.Instrumentation=[];
  addhist(Out,'Concatenation of samples in two objects')
  %
  Data1=Out.Data; Data2=dat2.Data;
  if ~iscell(Data1)&~isempty(Data1), Data1={Data1}; end
  if ~iscell(Data2)&~isempty(Data2), Data2={Data2}; end
  if iscell(Data1)&iscell(Data2)
    if size(Data1,1)~=size(Data2,1)
      error('Different numbers of channels')
    elseif size(Data1,2)~=size(Data2,2)
      error('Different numbers of experiments')
    end
  end
  %
  chn1=length(Out.ChTypes); chn2=length(dat2.ChTypes);
  if chn1~=chn2, error('Different number of channels in the two objects'), end
  sc1=Out.Scales; sc2=dat2.Scales;
  if isempty(sc1)&(chn1>0)&~isempty(sc2), sc1=ones(chn1,1); end
  if isempty(sc2)&(chn2>0)&~isempty(sc1), sc2=ones(chn2,1); end
  if isempty(sc1) %done
  elseif isequal(sc1,sc2)
    if iscell(sc1)&(size(sc1,2)>1)
      alleq=1;
      for ii=2:size(sc1,2)
        if ~isequal(sc1{:,1},sc1{:,ii}), alleq=0; break, end
      end
      if alleq==1, sc1=sc1(:,1); end
      if length(sc1)==1, sc1=sc1{1}; end
    end
    Out.Scales=sc1;
  else %no other way than to multiply data by scales
    for ii=1:size(Data1,1)
      for iii=1:size(Data1,2)
        Data1{ii,iii}=sc1*Data1{ii,iii};
      end
    end
    for ii=1:size(Data2,1)
      for iii=1:size(Data2,2)
        Data2{ii,iii}=sc2*Data2{ii,iii};
      end
    end
  end
  %
  Data=Data1;
  for ii=1:prod(size(Data))
    Data{ii}=[Data{ii};Data2{ii}];
  end
  %
  if length(Data)==1, Data=Data{1}; end
  Out.Data=Data;
  ch1=Out.ChTypes; ch2=dat2.ChTypes;
  if isempty(ch1)&isempty(ch2)
    %warning('Addition of two empty objects')
  elseif (isempty(ch1)&~isempty(ch2)) | (isempty(ch2)&~isempty(ch1))
    error('Incompatible channel numbers')
  elseif ~isempty(ch1)&~isempty(ch2)&any(ch1~=ch2)
    error('Channels are in different orders in the two objects')
  end
  %
  c1=Out.Names; c2=dat2.Names;
  if compcell(c1,c2), error('Different channel names'), end
  Out.Names=c1;
  %
  c1=Out.Units; c2=dat2.Units;
  if compcell(c1,c2), error('Different channel units'), end
  Out.Units=c1;
  %
  c1=Out.Characters; c2=dat2.Characters;
  if compcell(c1,c2), error('Different channel characters'), end
  Out.Characters=c1;
  %
  pl1=Out.PeriodLength; pl2=dat2.PeriodLength;
  fr1=Out.Frequencies; fr2=dat2.Frequencies; 
  if isempty(pl1)|isempty(pl2), pl=[]; 
  elseif any([isnan(pl1),isnan(pl2)]), pl=NaN;
  elseif any(~isfinite([pl1,pl2])), pl=inf;
  elseif pl1==pl2, pl=pl1;
  elseif any([1:100]*pl1==pl2), pl=pl2;
  elseif any([1:100]*pl2==pl1), pl=pl1;  
  elseif ~isempty(fr1)&~isempty(fr2), pl=NaN;
  else pl=Inf;
  end
  Out.PeriodLength=pl;
  %
  %Frequencies still to be checked
  Out.Frequencies=fr1;
  %
  st1=Out.State; st2=dat2.State;
  if isempty(st1)|isempty(st2), st='';
  elseif strcmp(st1,'transient')|strcmp(st2,'transient'), st='transient';
  else st='steady-state';
  end
  Out.State=st;
  sy1=Out.Synchronization; sy2=dat2.Synchronization;
  if isempty(sy1)|isempty(sy2), sy='';
  elseif strcmp(st1,'off')|strcmp(st2,'off'), st='off';
  else sy='on';
  end
  Out.Synchronization=sy;
end %for ii
%
%Consistency is checked in children functions
%if ~get(Out,'consistency')
%  error('Something is wrong with horzcat')
%end
%
% end of function @iddat/horzcat


function cdiff=compcell(c1,c2)
if nargin<3, chno=length(c1); end
cdiff=0;
for ii=1:chno
  if ~isempty(c1)&~isempty(c2)
    if ~strcmp(c1{ii},c2{ii})&~isempty(c1{ii})&~isempty(c2{ii}), cdiff=1; end
  end
end %for ii
%
%end @iddat/horzcat.m
