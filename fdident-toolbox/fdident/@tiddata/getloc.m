function Out = getloc(dat,prop,chi)
%GETLOC  Get property value of non-field child properties
%       dat: object
%       prop: full property name
%       chi: channel number (if necessary)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 06-Jan-2000

if nargin<3, chi=0; end %0 means all channels
if length(chi)>1, error('chi is a vector or an array'), end
%
if strcmp(prop,'SampleNumber')
  dats=struct(dat);
  if isa(dat,'tiddata'), dats=struct(dats.iddat); end
  if iscell(dats.Data)
    S=size(dats.Data{1,1},1); Sc=cell(size(dats.Data));
    for ii=1:size(dats.Data,1)
      for iii=1:size(dats.Data,2)
        l=size(dats.Data{ii,iii},1);
        if l~=S, S=NaN; end
        Sc{ii,iii}=l;
      end
    end
    Sca=reshape(cat(1,Sc{:}),size(Sc));
    if all(all(diff(Sca)==0)), Sc=Sc(1,:); end
    if ~isnan(S), Out=S; else Out=Sc; end
  elseif ~isempty(dats.Data)
    Out=size(dats.Data,1);
  else
    Out=0;
  end
  return
elseif strcmp(prop,'InputVariance')
  if ~isequal(chi,0), error('chi is not 0 for ''InputVariance'''), end
  if isfield(dat.NewProperties,'InputVariance')
    Out=dat.NewProperties.InputVariance;
    if iscell(Out)&(length(Out)==1), Out=Out{1}; end
    if ~iscell(Out)&all(isnan(Out)), Out=[];
    elseif isempty(Out), Out=[];
    end
  else
    Out=[];
  end
elseif strcmp(prop,'OutputVariance')
  if ~isequal(chi,0), error('chi is not 0 for ''OutputVariance'''), end
  if isfield(dat.NewProperties,'OutputVariance')
    Out=dat.NewProperties.OutputVariance;
    if iscell(Out)&(length(Out)==1), Out=Out{1}; end
    if ~iscell(Out)&all(isnan(Out)), Out=[];
    elseif isempty(Out), Out=[];
    end
  else
    Out=[];
  end
elseif strcmp(prop,'InputTStart')
  if ~isequal(chi,0), error('chi is not 0 for ''InputTStart'''), end
  tstart=get(dat,'TStart');
  if ~isempty(tstart)
    if isnumeric(tstart), Out=tstart; return, end
    ch=get(dat,'chtypes');
    ind=find(ch=='i'+0);
    if size(tstart,1)==1, Out=tstart(1,:);
    else Out=tstart(ind,:);
    end
    if length(Out)==1, Out=Out{1}; end 
  else
    Out=[];
  end
elseif strcmp(prop,'OutputTStart')
  if ~isequal(chi,0), error('chi is not 0 for ''OutputTStart'''), end
  tstart=get(dat,'TStart');
  if ~isempty(tstart)
    if isnumeric(tstart), Out=tstart; return, end
    ch=get(dat,'chtypes');
    ind=find(ch=='o'+0);
    if size(tstart,1)==1, Out=tstart(1,:);
    else Out=tstart(ind,:);
    end
    if length(Out)==1, Out=Out{1}; end 
  else
    Out=[];
  end
elseif strcmp(prop,'SamplingInstants')
    Out=dat.SampleTimes;
elseif strcmp(prop,'OutputSamplingInstants')
  if ~isequal(chi,0), error('chi is not 0 for ''OutputSamplingInstants'''), end
  si=get(dat,'SamplingInstants');
  if ~isempty(si)
    if isnumeric(si), Out=si; return, end
    ch=get(dat,'chtypes');
    ind=find(ch=='o'+0);
    Out=si(ind);
    if length(Out)==1, Out=Out{1}; end 
  else
    Out=[];
  end
elseif strcmp(prop,'InputSamplingInstants')
  if ~isequal(chi,0), error('chi is not 0 for ''InputSamplingInstants'''), end
  si=get(dat,'SamplingInstants');
  if ~isempty(si)
    if isnumeric(si), Out=si; return, end
    ch=get(dat,'chtypes');
    ind=find(ch=='i'+0);
    Out=si(ind);
    if length(Out)==1, Out=Out{1}; end 
  else
    Out=[];
  end
elseif strcmp(prop,'PeriodNumber')|strcmp(prop,'PeriodSamples')
  Tp=get(dat,'PeriodLength');
  Ts=get(dat,'Ts');
  if strcmp(prop,'PeriodNumber')
    N=get(dat,'SampleNumber');
    if ~isempty(Tp)&~isempty(Ts), Out=N/(Tp/Ts); else Out=[]; end
  elseif strcmp(prop,'PeriodSamples')
    if ~isempty(Tp)&~isempty(Ts), Out=Tp/Ts; else Out=[]; end
  end
  return
else
  error(['Unknown tiddata property ''',prop,''''])
end
%
%end @tiddata/getloc.m