function Out = subsrloc(dat,cr,er,sr)
%SUBSRLOC  Subscript child properties only
%       dat: fiddata object
%       cr: channel subscription index
%       er: experiment subscription index
%       sr: sample subscription index

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Aug-2003

if nargin<2, Out=dat; return, end
if nargin<3, er=':'; end
if nargin<4, sr=':'; end
if strncmp(version,'5.2',3)&strcmp(cr,':')
  cr=[1:get(dat,'chnumber')]';   
end
if isempty(sr)
  if strcmp(cr,':'), chn=get(dat,'chnumber'); else chn=length(cr); end   
  if strcmp(er,':'), expn=get(dat,'expnumber'); else expn=length(er); end   
  set(dat,'FreqPoints',cell(chn,expn));
  Out=dat;
  return
end
%
s=struct(dat); s2=struct(s.iddat); chtypes=s2.ChTypes;
fpt=dat.FreqIndices;
if ~isempty(fpt)
  if isnumeric(fpt)&~strcmp(sr,':'), fpt=fpt(sr);
  elseif iscell(fpt)
    if ~strcmp(er,':')
      if isempty(cr), fpt=fpt([],min(er,end));
      elseif size(fpt,1)==1, fpt=fpt(:,min(er,end));
      else fpt=fpt(min(cr,end),min(er,end));
      end
    else
      if isempty(cr), fpt=fpt([],:);
      elseif size(fpt,1)==1, fpt=fpt(:,:);
      else fpt=fpt(cr,:);
      end
    end
    for ii=1:size(fpt,1)
      for iii=1:size(fpt,2)
        fpti=fpt{ii,iii};
        if ~strcmp(sr,':'), fpt{ii,iii}=fpti(sr); end
      end 
    end %for ii
    if length(fpt)==1, fpt=fpt{1}; end
  end
  dat.FreqIndices=fpt;
end
%
afp=dat.AllFreqPoints;
if ~isempty(afp)
  if isnumeric(afp) %nothing to do
  elseif iscell(afp)
    if ~strcmp(er,':'), afp=afp(:,er); end
  end
  %
  %Now replace unused frequencies by NaN in AllFreqPoints
  if isnumeric(afp), afp={afp}; end
  if isnumeric(fpt), fpt={fpt}; end
  newind=cell(size(afp)); nanind=newind; %initialize
  for ii=1:length(afp)
    for iii=1:length(afp{ii})
      found=0;
      for ic=1:size(fpt,1)
        if any(iii==[fpt{ic,ii};NaN]), found=1; end
      end %for ic
      if found==0      
        afp{ii}(iii)=NaN;
      end
    end %for iii
    [afp{ii},newind{ii}]=sort(afp{ii});
    %NaN values to be deleted
    nanind{ii}=find(isnan(afp{ii}));
    if ~isempty(nanind{ii}), afp{ii}(nanind{ii})=[]; end
  end %for ii
  %
  if ~iscell(fpt), fpt={fpt}; end
  for ii=1:length(afp)
    %if length(newind{ii})~=length(afp{ii})
    for iii=1:size(fpt,1)
      fptii=fpt{iii,ii};
      for iv=1:length(fptii)
        ind=find(fptii(iv)==newind{ii});
        fpt{iii,ii}(iv)=ind;
      end %for iv
    end %for iii
  end %for ii
  if length(fpt)==1, fpt=fpt{1}; end
  dat.FreqIndices=fpt;
  if length(afp)==1, afp=afp{1}; end
  dat.AllFreqPoints=afp;
end
%
freqs=get(dat,'frequencies');
if ~isempty(freqs)
  if ~iscell(freqs), freqs={freqs}; end
  if isnumeric(afp), afp={afp}; end
  while size(afp,1)<size(freqs,1), afp=[afp;afp(1,:)]; end
  while size(afp,2)<size(freqs,2), afp=[afp,afp(:,1)]; end
  while size(freqs,1)<size(afp,1), freqs=[freqs;freqs(1,:)]; end
  while size(freqs,2)<size(afp,2), freqs=[freqs,freqs(:,1)]; end
  for ii=1:size(freqs,1)
    for iii=1:size(freqs,2)
      for iv=length(freqs{ii,iii}):-1:1
        if ~any(freqs{ii,iii}(iv)==afp{ii,iii}), 
          freqs{ii,iii}(iv)=[];
        end
      end  
    end
  end
  if length(freqs)==1, freqs=freqs{1}; end
  set(dat,'frequencies',freqs,'noconsistency')
end
%
delays=dat.Delays;
if ~isempty(delays)
  if ~strcmp(er,':'), delays=delays(cr,er); else delays=delays(cr,:); end
  dat.Delays=delays;
end
%
for ctype={'lin','nonlin'}
  ctype=ctype{1};
  if strcmp(ctype,'lin'), covs=dat.Covariance;
  elseif strcmp(ctype,'nonlin'), covs=get(dat,'NonlinCovariance');
  end
  if ~isempty(covs)
    %Covariance is not subscripted by samples:
    %it follows the property AllFreqPoints
    if ~iscell(covs), covs={covs}; end
    if ~strcmp(er,':')|(length(er)~=length(covs))
      expno=get(dat,'expn');
      if length(covs)>1
        covs=covs(er);
      end
    end
    for ie=1:length(covs)
      covs{ie}=covs{ie}(cr,cr,:);
      if length(newind)==1, newindii=newind{1}; else newindii=newind{ie}; end
      covs{ie}=covs{ie}(:,:,newindii);
      if length(nanind{:,min(ie,end)})>0
        if ~isempty(nanind{:,min(ie,end)}), covs{ie}(:,:,nanind{:,min(ie,end)})=[]; end 
      end
    end
    if length(covs)==1, covs=covs{1}; end
    if strcmp(ctype,'lin'), dat.Covariance=covs;
    elseif strcmp(ctype,'nonlin'), set(dat,'NonlinCovariance',covs);
    end
  end %if ~isempty
end %for ctype
%
covs=dat.Coherence;
if ~isempty(covs)
  %Coherence is not subscripted by samples (sr):
  %it follows the property AllFreqPoints
  if ~iscell(covs), covs={covs}; end
  if ~strcmp(er,':')|(length(er)~=length(covs))
    covs=covs(er);
  end
  for ie=1:size(covs,2)
    if ~isempty(covs{ie}), covs{ie}=covs{ie}(cr,cr,:); end
  end
  if length(covs)==1, covs=covs{1}; end
  dat.Coherence=covs;
end
%
M=get(dat,'M');
if length(M)>1
  M=M(er);
  if all(isnan(M)), M=[]; end
  set(dat,'M',M,'noconsistency')
end
%
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
%
Out=dat;
%
%end @fiddata/subsrloc.m