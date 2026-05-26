function setloc(dat,prop,value,chi,expi)
%SETLOC  Set property value of child properties
%       dat = object
%       prop = property
%       value = value to assign
%       chi = indices of selected channels (if missing, all (i/o) channels)
%       expi = indices of selected experiments (if missing, all experiments)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 30-Nov-2003

if nargin<4, chi=0; end
if nargin<5, expi=[]; end
if isstr(expi)&strcmp(expi,':'), expi=[1:get(dat,'expnumber')]; end
if any(expi>get(dat,'expnumber')), error('Nonexistent experiment is referred to'), end
if (isstr(chi)&strcmp(chi,':')), chi=[1:get(dat,'chnumber')]; end
if any(chi>get(dat,'chnumber')), error('Nonexistent channel is referred to'), end
if isfield(struct(dat),prop)
  %child field, acceleration
  if isequal(chi,0) %chi is not given
    eval(['dat.',prop,'=value;'])
    assignin('caller',inputname(1),dat)
    return
  end
end
%
%non-field child property or subscripted property
%
chtypes=get(dat,'ChTypes');
indi=find([chtypes;0]==('i'+0)); in=length(indi);
indo=find([chtypes;0]==('o'+0)); on=length(indo);
indall=[1:length(chtypes)]';
if any(findstr(['|',prop],['|','Input'])), ind=indi; n=in;
elseif any(findstr(['|',prop],['|','Output'])), ind=indo; n=on;
else n=length(chtypes); ind=indall;
end
if isequal(chi,0), chi=ind; end
indc=find(ismember(chi,ind)); chi=chi(indc);
%
if strcmp(prop,'InputFreqPoints')|strcmp(prop,'OutputFreqPoints')|...
    strcmp(prop,'FreqPoints')
  %Set also allfreqpoints
  chno=get(dat,'ChNumber'); expno=get(dat,'ExpNumber');
  fi=dat.FreqIndices; afp=dat.AllFreqPoints;
  if iscell(fi)
    fp=cell(size(fi));
    for iii=1:size(fi,2)
      if ~iscell(afp), afpi=afp; else afpi=afp{iii}; end
      for ii=1:size(fi,1)
        fp{ii,iii}=afpi(fi{ii,iii});
      end
    end
  else %double
    if ~isempty(fi), fp=afp(fi); else fp=[]; end
  end
  %
  if strcmp(prop,'FreqPoints')
    fp=value; %only set size of Covariance and AllFreqPoints
  else %input or output
    %Make default multi-cell
    if ~iscell(fp), fp={fp}; end
    if size(fp,1)==1
      for ii=2:chno, fp(ii,:)=fp(1,:); end
    end
    if size(fp,2)==1
      for ii=2:expno, fp(:,ii)=fp(:,1); end
    end
    %
    if ~iscell(value), value={value}; end
    value0=value;
    if size(value,1)==1
      iii=0;
      for ii=chi(:)', iii=iii+1; value(iii,:)=value(1,:); end
    end
    if size(value,2)==1
      for ii=2:expno, value(:,ii)=value(:,1); end
    end
    %
    fp(chi,:)=value;
    %Now collapse if possible
    fph=fp(1,:); fpv=fp(:,1); h=1; v=1;
    for ii=1:size(fp,1)
      for iii=1:size(fp,2)
        if ~isequal(fp{ii,iii},fph{1,iii}), v=0; end
        if ~isequal(fp{ii,iii},fpv{ii,1}), h=0; end
        if (h==0)&(v==0), break, end
      end
      if (h==0)&(v==0), break, end
    end
    if (h==1)&(size(value0,1)==1), fp=fp(1,:); end
    if (v==1)&(size(value0,2)==1), fp=fp(:,1); end
    if length(fp)==1, fp=fp{1,1}; end
  end %input or output
  if ~iscell(fp)
    if isempty(fp), fi=[]; afp=[];
    else afp=fp(:); fi=[1:length(afp)]';
    end
  else %cell
    afp=cell(1,size(fp,2));
    fi=cell(size(fp));
    for iii=1:size(fp,2)
      for ii=1:size(fp,1)
        if ii==1, afp{1,iii}=fp{1,iii}; fi{ii,iii}=[1:length(fp{1,iii})]';
        else
          ivnot=[];
          for iv=1:length(fp{ii,iii})
            f=fp{ii,iii}(iv);
            ind=find(afp{1,iii}==f);
            %eliminate coinciding freqs:
            for iind=1:length(ind)
              if ~isempty(ivnot)&any(ind(1)==ivnot), ind(1)=[];
              else break
              end
            end
            if ~isempty(ind), fi{ii,iii}=[fi{ii,iii};ind(1)];
              if length(ind)>1, ivnot=[ivnot,ind(1)]; end
            else
              afp{1,iii}=[afp{1,iii};f];
              fi{ii,iii}=[fi{ii,iii};length(afp{1,iii})];
            end
          end %for iv
        end
      end %for ii
      %Now afp must be put into order
      %[afp{1,iii},ind]=sort(afp{1,iii});
      %if ~isequal(ind,[1:length(ind)]')
      %  for ii=1:size(fp,1)
      %    fi{ii,iii}=ind(fi{ii,iii});
      %  end
      %end
    end %for iii
    if length(afp)==1, afp=afp{1,1}; end
  end
  %
  %Now replace unused frequencies by NaN in AllFreqPoints
  if isnumeric(afp), afp={afp}; end
  fpt=fi; if isnumeric(fpt), fpt={fpt}; end
  for ii=1:length(afp)
    for iii=1:length(afp{ii})
      found=0;
      for ic=1:size(fpt,1)
        if any(iii==[fpt{ic,ii};NaN]), found=1; end
      end %for ic
      if found==0, afp{ii}(iii)=NaN; end
    end %for iii
  end %for ii
  if length(afp)==1, afp=afp{1}; end
  %
  dat.FreqIndices=fi; dat.AllFreqPoints=afp;
  %
  %Set the length of the Covariance/Coherence arrays, too
  %dat.Covariance=[]; %setting of freqpoints clears covariance
elseif strcmp(prop,'InputDelay')|strcmp(prop,'OutputDelay')
  dels=dat.Delays; chn=get(dat,'ChNumber'); expno=get(dat,'ExpNumber');
  if isempty(dels)&~isempty(value)
    dels={};
    for ii=1:chn
      for iii=1:expno
        dels{ii,iii}=0;
      end
    end
  end
  if ~iscell(value), value={value}; end
  for ii=1:size(value,1)
    for iii=1:size(value,2)
      dels{ind(ii),iii}=value{ii,iii}; 
    end
  end
  if length(dels)==1, dels=dels{1}; end
  dat.Delays=dels;
elseif strcmp(prop,'InputVariance')|strcmp(prop,'OutputVariance')|...
    strcmp(prop,'AllVariances')|...
    strcmp(prop,'InputNonlinError')|strcmp(prop,'OutputNonlinError')|...
    strcmp(prop,'InputNonlinVariance')|strcmp(prop,'OutputNonlinVariance')
  if any(findstr(prop,'putVar'))|strcmp(prop,'AllVariances')
    covs=dat.Covariance;
  else %nonlinear
    if isfield(dat.NewProperties,'NonlinCovariance')
      covs=dat.NewProperties.NonlinCovariance; %full nonlin covariance array, ch x ch x freq
      if strcmp(prop,'InputNonlinError')|strcmp(prop,'OutputNonlinError')
        M=get(dat,'M');
        % *** For nonlinear analysis, errors do not average out ***
        if ~isempty(M)
          if isnumeric(value), value=value/M;
          else for ii=1:prod(size(value)), value{ii}=value{ii}/M; end
          end
        end
      end
    else
      covs=[];
    end
  end
  if ~isempty(value)&isempty(covs)
    %make skeleton
    afp=dat.AllFreqPoints;
    if ~iscell(afp), afp={afp}; end
    covs=cell(size(afp));
    NaNv=NaN; chn=get(dat,'ChNumber');
    for ii=1:length(afp)
      s=length(afp{ii});
      covs{ii}=NaNv(ones(chn,chn,s));
    end %for ii
    if length(covs)==1, covs=covs{1}; end
  elseif isempty(value)&isempty(covs)
    return
  end
  %
  indp=findstr('put',prop);
  if ~isempty(indp), io=prop(1:indp(1)+2);
  else io='';
  end
  if iscell(value)
    if isempty(io)&~any(size(value,1)==[1,get(dat,'chnumber')])
      error(['Wrong number of channels'])
    elseif ~any(size(value,1)==[1,get(dat,[io,'chnumber'])])
      error(['Wrong number of ',lower(io),' channels'])
    elseif ~any(size(value,2)==[1,get(dat,'expnumber')])
      error(['Wrong number of experiments'])
    end
  elseif isnumeric(value)
    value={value};
  end
  if isnumeric(covs), covs={covs}; end
  while size(covs,2)<size(value,2), covs=[covs,covs(1,1)]; end
  while size(value,1)<length(chi), value=[value;value(1,:)]; end
  while size(value,2)<size(covs,2), value=[value,value(:,1)]; end
  if isempty(expi), expi=1:size(value,2); end
  fp=get(dat,['freqpoints']); if isnumeric(fp), fp={fp}; end
  for ic=1:size(value,1)
    for ie=1:size(value,2)
      lvi=length(value{ic,ie});
      Fi=length(fp{min(chi(ic),size(fp,1)),min(expi(ie),size(fp,2))});
      if ~any(lvi==[0,1,Fi])
        error([io,'Variance is inconsistent with frequency points']) 
      elseif lvi==1
        value{ic,ie}=value{ic,ie}*ones(Fi,1);
      end
    end
  end
  %
  while get(dat,[io,'chnumber'])>size(value,1), value=[value;value(1,:)]; end
  for ie=1:length(expi)
    for ic=1:length(chi) %channels
      fi=get(dat,['Freqind']); if isnumeric(fi), fi={fi}; end
      isv=0; 
      for is=fi{min(chi(ic),end),min(expi(ie),end)} %freqpoints
        if size(value{ie},1)==1, isv=1; else isv=isv+1; end
        if ~isempty(value{ic,ie}), covs{ie}(chi(ic),chi(ic),is)=value{ic,ie};
        else covs{ie}(chi(ic),chi(ic),is)=NaN*covs{ie}(chi(ic),chi(ic),is);
        end
      end %for is
    end %for ic
  end %for ie
  if isnumeric(covs)&all(all(isnan(covs))), covs=[]; end
  if any(findstr(prop,'putVar'))|strcmp(prop,'AllVariances')
    dat.Covariance=covs;
  else
    dat.NewProperties.NonlinCovariance=covs; %full nonlin covariance array, ch x ch x freq
  end
%elseif strcmp(prop,'NonlinCovarianceMatrix')
  %dat.NewProperties.NonlinCovariance=value; if isempty(value), dat.NewProperties.nonlinM=[]; end
elseif strcmp(prop,'CovVector')|strcmp(prop,'CohVector')|strcmp(prop,'NonlinCovVector')|...
    strcmp(prop,'CovarianceMatrix')|strcmp(prop,'NonlinCovarianceMatrix')
  if strncmp(prop,'Cov',3), covs=dat.Covariance;
  elseif strncmp(prop,'Coh',3), covs=dat.Coherence;
  elseif strncmp(prop,'NonlinCov',9)
    if isfield(dat.NewProperties,'NonlinCovariance')
      covs=dat.NewProperties.NonlinCovariance; %full nonlin covariance array, ch x ch x freq
    else
      covs=[];
    end
  end
  %
  if ~isempty(value)&isempty(covs)
    %make skeleton
    afp=dat.AllFreqPoints;
    if ~iscell(afp), afp={afp}; end
    covs=cell(size(afp));
    NaNv=NaN; chn=get(dat,'ChNumber');
    for ii=1:length(afp)
      s=length(afp{ii});
      covs{ii}=NaNv(ones(chn,chn,s));
      if strncmp(prop,'Coh',3)
        for iii=1:chn
          covs{ii}(iii,iii)=1;
        end
      end
    end %for ii
    if length(covs)==1, covs=covs{1}; end
  end  
  %
  if ~strcmp(prop,'CovarianceMatrix')&~strcmp(prop,'NonlinCovarianceMatrix')&...
      ((length(chi)~=2)|isequal(diff(chi),0))
    error(['Not 2 different channels are selected to set ''',prop,''''])
  end
  if ~iscell(covs), covs={covs}; end
  if ~iscell(value), value={value}; end
  while size(covs,2)<size(value,2), covs=[covs,covs(1,1)]; end
  if (strcmp(prop,'CovarianceMatrix')|strcmp(prop,'NonlinCovarianceMatrix'))&...
      (length(value)==1)&isempty(value{1})
  else
    while size(value,2)<size(covs,2), value=[value,value(:,1)]; end
  end
  if isempty(expi), expi=1:get(dat,'expn'); end
  chn=get(dat,'ChNumber');
  iev=0;
  ievect=expi(:)';
  if (length(covs)==1)&(length(value)==1)&(get(dat,'expnumber')==length(expi))
    ievect=1;
  end
  for ie=ievect
    iev=iev+1;
    if strcmp(prop,'CovarianceMatrix')|strcmp(prop,'NonlinCovarianceMatrix')
      %while length(covs)<max(expi), covs=[covs,covs(end)]; end
      if ((length(value)==1)&isempty(value{1}))&(length(chi)==chn)
        covs{ie}=[];
      elseif (size(covs{ie},2)>=max(chi))&(size(covs{ie},2)>length(chi)) 
        if isempty(value{iev})
          covs{ie}(chi,chi,:)=NaN*covs{ie}(chi,chi,:);
        else
          covs{ie}(chi,chi,:)=value{iev};
        end
      else
        covs{ie}=value{iev};
      end
      if strcmp(prop,'CovarianceMatrix')
        dat.NewProperties.M=[];
      elseif strcmp(prop,'NonlinCovarianceMatrix')
        dat.NewProperties.NonlinM=[];
      end
    else %vector
      fiall=get(dat,'freqind');
      if ~iscell(fiall), fiall={fiall}; end
      fi=fiall{chi(1),min(ie,end)};
      ind=find(ismember(fi,fiall{min(chi(2),end),min(ie,end)}));
      fi=fi(ind);
      NaNv=NaN;
      if length(covs)<ie, break, end
      if isempty(covs{ie})&~isempty(value{min(iev,end)})
        covs{ie}=NaNv(ones(size(covs)));
      elseif ~isempty(covs{ie})&isempty(value{iev})
        covs{ie}(chi(1),chi(2),:)=NaNv(ones(1,1,size(covs{ie},3)));
        covs{ie}(chi(2),chi(1),:)=NaNv(ones(1,1,size(covs{ie},3)));
      end
      if ~isempty(value{iev})
        covs{ie}(chi(1),chi(2),fi)=value{iev};
        covs{ie}(chi(2),chi(1),fi)=conj(value{iev});
      end
    end
  end %for ie
  %
  covsempty=1;
  for ii=1:length(covs), if ~isempty(covs{ii}), covsempty=0; break, end, end
  if covsempty, covs={[]}; end
  if length(covs)==1, covs=covs{1}; end
  %
  if strncmp(prop,'Cov',3), dat.Covariance=covs;
  elseif strncmp(prop,'Coh',3), dat.Coherence=covs;
  elseif strncmp(prop,'NonlinCov',9)
    dat.NewProperties.NonlinCovariance=covs; %full nonlin covariance array, ch x ch x freq
  end
elseif strcmp(prop,'SisoVariance')|strcmp(prop,'SisoNonlinError')
  if length(chi)~=2, error('Two channels must be given for Variance'), end
  if isnumeric(value)
    if isempty(value)
      if strcmp(prop,'SisoVariance')
        set(dat,'covariance',[],'M',[],'noconsistency')
      elseif strcmp(prop,'SisoNonlinError')
        set(dat,'NonlinCovariance',[],'NonlinM',[],'noconsistency')
      end
      assignin('caller',inputname(1),dat)
      return
    else
      value={value};
    end
  end
  if ~iscell(value) error('Invalid Variance value'), end
  vu=cell(size(value)); vy=vu; cuy=vu;
  for ii=1:length(value)
    varii=value{ii};
    if size(varii,2)==1, error('Only output variances are given'), end
    if ~isempty(varii)
      vu{ii}=varii(:,2); vy{ii}=varii(:,1);
      if size(varii,2)==3, cuy{ii}=varii(:,3); end
    end
  end %for ii
  if length(vu)==1, vu=vu{1}; vy=vy{1}; cuy=cuy{1}; end
  if strcmp(prop,'SisoVariance')
    set(dat,'inputvariance',vu,'outputvariance',vy,'covvect',cuy,...
      'noconsistency')
  else %nonlinerr
    set(dat,'inputNonlinError',vu,'outputNonlinError',vy,'nonlincovvect',cuy,...
      'noconsistency')
  end
elseif strcmp(prop,'N')
  dat.NewProperties.N=value;
elseif strcmp(prop,'M')
  dat.NewProperties.M=value;
elseif strcmp(prop,'NonlinM')
  dat.NewProperties.NonlinM=value;
elseif strcmp(prop,'Type')
  dat.NewProperties.Type=value;
elseif strcmp(prop,'Speciality')
  dat.NewProperties.Speciality=value;
elseif strcmp(prop,'InterExpCovariance')
  dat.NewProperties.InterExpNonlinCovariance=value;
  if isfield(dat.NewProperties,'InterExpCovariance')
    dat.NewProperties=rmfield(dat.NewProperties,'InterExpCovariance');
  end
elseif strcmp(prop,'EvenOutputNonlinError')|strcmp(prop,'OddOutputNonlinError')|...
    strcmp(prop,'EvenNonexcFrequencies')|strcmp(prop,'OddNonexcFrequencies')
  dat.NewProperties=setfield(dat.NewProperties,prop,value);
else
  error(['Unrecognized property ',prop])
end
%
assignin('caller',inputname(1),dat)
%
%end @fiddata/setloc.m