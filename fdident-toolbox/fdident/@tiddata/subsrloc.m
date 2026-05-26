function Out = subsrloc(dat,cr,er,sr)
%SUBSRLOC  Subscript child properties only
%       dat: tiddata object
%       cr: channel subscription index
%       er: experiment subscription index
%       sr: sample subscription index

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 015-Aug-2003

if nargin<2, Out=dat; return, end
if nargin<3, er=':'; end
if nargin<4, sr=':'; end
if strncmp(version,'5.2',3)&strcmp(cr,':')
  cr=[1:get(dat,'chnumber')]';   
end

chst=dat.SampleTimes;
if ~isempty(chst)
  if iscell(chst) %cell, channels x 1 or channels x experiments
    if isnumeric(er)&~isempty(er)&(max(er)>size(chst,2))
      chst=chst(cr,:);
    else
      if ~strcmp(er,':'), chst=chst(cr,er); else chst=chst(cr,:); end
    end
    for ii=1:size(chst,1)
      for iii=1:size(chst,2)
        chsti=chst{ii,iii};
        if ~strcmp(er,':'), chst{ii,iii}=chsti(sr); end
      end
    end 
  elseif isnumeric(chts)
    if ~strcmp(er,':'), chts=chts(sr); end
  end
  dat.SampleTimes=chst;
end

if isnumeric(sr)
  if length(sr)<=1
  elseif length(sr)==2, dat.Ts=diff(sr)*dat.Ts;
  else
    dts=diff(diff(sr));
    if any(dts~=0), error('Subscripting is not equidistant')
    else dat.Ts=mean(diff(sr))*dat.Ts;
    end
  end
end
  
chts=dat.TStart;
if ~isempty(chts)
  if length(cr)==0, chts=[];
  else
    if (size(chts,1)>1)&~strcmp(cr,':'), chts=chts(cr,:); end
    if ~strcmp(er,':'), chts=chts(:,er); end
  end
  dat.TStart=chts;
end

if isfield(dat.NewProperties,'Reference')
  Ref=dat.NewProperties.Reference;
  if ~isempty(Ref)
    if ~iscell(Ref), Ref={Ref}; end
    if size(Ref,1)==1, cr=1; end
    Ref=Ref(cr,er);
    for ii=1:length(Ref)
      Ref{ii}=Ref{ii}(sr);
    end %for ii
    if length(Ref)==1, Ref=Ref{1}; end
    dat.NewProperties.Reference=Ref;
  end
end

Out=dat;
%
%end @tiddata/subsrloc.m
