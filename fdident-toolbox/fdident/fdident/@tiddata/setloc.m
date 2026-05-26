function setloc(dat,prop,value,chi)
%SETLOC  Set property value of child properties
%
%       Arguments:
%       dat = object
%       prop = property
%       value = value to assign
%       chi = indices of selected channels (if missing, all (i/o) channels)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Aug-2003

if nargin<4, chi=0, end %channel index, 0 means all
if length(chi)>1, error('chi is a vector or an array'), end

if isfield(struct(dat),prop) %child field
  if chi==0
    eval(['dat.',prop,'=value;'])
  else %this is not a necessary case now
    warning('Channel property setting does nothing now in @tiddata/setloc')
  end
  ch=get(dat,'chtypes');
  if strcmp(prop,'TStart')
    if isnumeric(value)
      if ~isempty(value)
        si=dat.SampleTimes;
        if isnumeric(si)&~isempty(si)
          si=si-si(1)+value;
          dat.SampleTimes=si;
        end
      end
    elseif iscell(value)
      si=dat.SampleTimes;
      if ~isempty(si)
        while size(value,1)<length(ch)
          value=[value;value(1,:)];
        end
        if isnumeric(si), si={si}; end
        while size(si,1)<length(ch)
          value=[si;si(1,:)];
        end
        for ii=1:length(ch)
          if ~isempty(si{ii}), si{ii}=si{ii}-si{ii}(1)+value{ii,:}; end
        end %for ii
        dat.SampleTimes=si;
      end
    end %iscell(value)
  end
elseif strcmp(prop,'InputTStart')|strcmp(prop,'OutputTStart')
  ch=get(dat,'chtypes'); ind=find(ch==lower(prop(1))+0);
  if isnumeric(value), value={value}; end
  tstart=dat.TStart;
  if isempty(tstart)
    tstart=cell(length(ch),1);
    %if ~isempty(dat.Ts), tst=dat.Ts; else tst=0; end
    tst=0;
    for ii=1:length(ch), tstart{ii,1}=tst; end
  elseif isnumeric(tstart)
    tst=tstart;
    tstart=cell(length(ch),1);
    for ii=1:length(ch), tstart{ii,1}=tst; end
  end
  tstart(ind)=value;
  dat.TStart=tstart;
  si=dat.SampleTimes;
  tsa=cat(1,tstart{:});
  if isnumeric(si)&~isempty(si)
    si=si-si(1)+tsa(1);
    dat.SampleTimes=si;
  elseif iscell(si)
    if size(si,1)==1
      si{1}=si{1}-si{1}(1)+tsa(1);
      dat.SampleTimes=si;
    else
      for ii=1:length(ch)
        si{ii}=si{ii}-si{ii}(1)+tsa(ii);
      end %for
      dat.SampleTimes=si;
    end
  end
elseif strcmp(prop,'SamplingInstants')
  if isnumeric(value)
    if prod(size(value))==length(value), value=value(:); end
  end
  dat.SampleTimes=value;
  %
  if isnumeric(value)
    if ~isempty(value), tstart=value(1); else tstart=[]; end
  elseif iscell(value)
    tstart=dat.TStart;
    if isnumeric(tstart), tstart={tstart}; end
    ch=get(dat,'chtypes');
    while size(tstart,1)<length(ch)
      tstart=[tstart;tstart(1,:)];
    end
    for ii=1:length(ch)
      if ~isempty(value{ii}), tstart{ii,:}=value{ii,:}(1); end
    end
  else
    error('Value is not numeric, and not a cell array')
  end
  if ~isempty(tstart), dat.TStart=tstart; end
elseif strcmp(prop,'InputSamplingInstants')|strcmp(prop,'OutputSamplingInstants')
  if isnumeric(value)
    if prod(size(value))==length(value), value=value(:); end
  end
  si=get(dat,'samplinginstants');
  ch=get(dat,'chtypes'); ind=find(ch==lower(prop(1))+0);
  if isempty(si), si=cell(length(ch),1);
  elseif isnumeric(si)
    sin=si;
    si=cell(length(ch),1); 
    for ii=1:length(si), si{ii}=sin; end
  elseif iscell(si)
    if size(si,1)==1
      for ii=2:length(ch), si=[si;si(1,:)];  end
    end
  end
  if isnumeric(value), si{ind}=value;
  else si{ind,1}=value;
  end
  dat.SampleTimes=si;
  %
  tstart=dat.TStart;
  if isnumeric(tstart), tstart={tstart}; end
  ch=get(dat,'chtypes');
  while size(tstart,1)<length(ch)
    tstart=[tstart;tstart(1,:)];
  end
  for ii=1:length(ch)
    if ~isempty(si{ii}), tstart{ii,:}=si{ii,1}(1); end
  end
  if ~isempty(tstart), dat.TStart=tstart; end
elseif strcmp(prop,'InputVariance')
  dat.NewProperties.InputVariance=value;
elseif strcmp(prop,'OutputVariance')
  dat.NewProperties.OutputVariance=value;
elseif strcmp(prop,'PeriodNumber')|strcmp(prop,'PeriodSamples')
  Ts=get(dat,'Ts');
  if strcmp(prop,'PeriodNumber')
    N=get(dat,'SampleNumber');
    set(dat,'PeriodLength',N/value*Ts,'noconsistency');
  elseif strcmp(prop,'PeriodSamples')
    set(dat,'PeriodLength',value*Ts,'noconsistency');
  end
else %this is not a necessary case now
  warning('@tiddata/setloc does nothing now for non-field properties')
end
assignin('caller',inputname(1),dat)
%
%end @tiddata/setloc.m
