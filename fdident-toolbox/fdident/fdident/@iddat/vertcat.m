function Out = vertcat(varargin)
%VERTCAT Vertical concatenation of iddat objects: concatenate different channels
%       [dat1 ; dat2 ...]
%       In unambiguity, the first object dominates (e.g. Name)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Oct-1998

ni = nargin;
no = nargout;
if length(varargin)==1, Out=varargin{1}; return, end

Out=varargin{1};
for ii=2:length(varargin)
  dat2=varargin{ii};
  if ~strcmp(class(Out),class(dat2))
    error('All input arguments must be objects of the same class')
  end
  if ii==2
    if strcmp(class(Out),'iddat'), Out=iddat(struct(Out)); end
  end
  
  %Name, UserData stays that of dat1
  %Out.Notes='';
  addhist(Out,'Vertical concatenation of two objects')
  %
  Data1=Out.Data; Data2=dat2.Data;
  if ~iscell(Data1)&(get(Out,'chnumber')==1), Data1={Data1}; end
  if ~iscell(Data2)&(get(dat2,'chnumber')==1), Data2={Data2}; end
  if (length(Data2)==1)&isempty(Data2{1})
    while size(Data2,2)<size(Data1,2), Data2=[Data2,Data2(1)]; end
  end
  Data1=[Data1;Data2];  
  if length(Data1)==1, Data1=Data1{1}; end
  Out.Data=Data1;
  Out.ChTypes=[Out.ChTypes;dat2.ChTypes];
  chn1=length(Out.ChTypes); chn2=length(dat2.ChTypes);
  %
  emptyc={''};
  sc1=Out.Scales; sc2=dat2.Scales;
  if isempty(sc1)&(chn1>0)&~isempty(sc2), sc1=ones(chn1,1); end
  if isempty(sc2)&(chn2>0)&~isempty(sc1), sc2=ones(chn2,1); end
  Out.Scales=[sc1;sc2];
  %
  n1=Out.Names; n2=dat2.Names;
  if isempty(n1)&(chn1>0)&~isempty(n2), n1=emptyc(ones(chn1,1)); end
  if isempty(n2)&(chn2>0)&~isempty(n1), n2=emptyc(ones(chn2,1)); end
  if ~iscell(n1), n1={n1}; end
  if ~iscell(n2), n2={n2}; end
  Out.Names=[n1;n2];
  %
  u1=Out.Units; u2=dat2.Units;
  if isempty(u1)&(chn1>0)&~isempty(u2), u1=emptyc(ones(chn1,1)); end
  if isempty(u2)&(chn2>0)&~isempty(u1), u2=emptyc(ones(chn2,1)); end
  if ~iscell(u1), u1={u1}; end
  if ~iscell(u2), u2={u2}; end
  Out.Units=[u1;u2];
  %
  c1=Out.Characters; c2=dat2.Characters;
  if isempty(c1)&(chn1>0)&~isempty(c2), c1=emptyc(ones(chn1,1)); end
  if isempty(c2)&(chn2>0)&~isempty(c1), c2=emptyc(ones(chn2,1)); end
  if ~iscell(c1), c1={c1}; end
  if ~iscell(c2), c2={c2}; end
  Out.Characters=[c1;c2];
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
  if isempty(fr1)&(chn1>0)&~isempty(fr2), fr1=cell(chn1,1); end
  if isempty(fr2)&(chn2>0)&~isempty(fr1), fr2=cell(chn2,1); end
  if isnumeric(fr1)&(chn1>1), fr1=fr1(ones(chn1,1),:); end
  if isnumeric(fr2)&(chn2>1), fr2=fr2(ones(chn2,1),:); end
  Out.Frequencies=[fr1;fr2];
  %
  st1=Out.State; st2=dat2.State;
  if isempty(st1)|isempty(st2), st='';
  elseif strcmp(st1,'transient')|strcmp(st2,'transient'), st='transient';
  else st='steady-state';
  end
  Out.State=st;
  %
  sy1=Out.Synchronization; sy2=dat2.Synchronization;
  if isempty(sy1)|isempty(sy2), sy='';
  elseif strcmp(st1,'off')|strcmp(st2,'off'), st='off';
  else sy='on';
  end
  Out.Synchronization=sy;
end %for ii
%
%end @iddat/vertcat.m
