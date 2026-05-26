function Out = getloc(dat,prop,chi)
%GETLOC  Get property value of non-field child properties

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 23-Nov-2003

if nargin<3, chi=[]; end
Out=[]; s=struct(dat); id=s.iddat; s2=struct(id); chtypes=s2.ChTypes;
indi=find([chtypes;0]==('i'+0)); in=length(indi);
indo=find([chtypes;0]==('o'+0)); on=length(indo);
if any(findstr(['|',prop],['|','Input'])), ind=indi; n=in;
elseif any(findstr(['|',prop],['|','Output'])), ind=indo; n=on;
else n=length(chtypes); ind=[1:n]';
end
%
if strcmp(prop,'InputFreqPoints')|strcmp(prop,'OutputFreqPoints')|...
    strcmp(prop,'FreqPoints')
  fi=dat.FreqIndices; afp=dat.AllFreqPoints;
  if ~iscell(fi), fi={fi}; end, if ~iscell(afp), afp={afp}; end
  ifp=cell(size(fi));
  for ii=1:size(fi,1)
    for iii=1:size(fi,2)
      ifp{ii,iii}=afp{1,min(iii,end)}(fi{ii,iii});
    end
  end
  if length(ifp)==1, ifp=ifp{1}; end
  if ~isempty(ifp)&isempty(ind)&strcmp(prop,'FreqPoints'), Out=ifp;
  elseif ~isempty(ifp)&~isempty(ind)
    if isnumeric(ifp)
      if n==1, Out=ifp;
      elseif strcmp(prop,'FreqPoints'), Out=ifp;
      else
        Out={ifp};
        for ii=2:length(ind), Out{ii,1}=ifp; end
      end
    else %cell array
      if ~strcmp(prop,'FreqPoints')
        while size(ifp,1)<length(chtypes)
          ifp=[ifp;ifp(1,:)];  
        end
        Out=ifp(ind,:);
      else
        Out=ifp;
      end
      if size(Out,2)==1
        if size(Out,1)==2
          if isequal(Out{1},Out{2}), Out(2)=[]; end
        end
      end
      if length(Out)==1, Out=Out{1}; end
    end
  end
elseif strcmp(prop,'InputDelay')|strcmp(prop,'OutputDelay')
  delays=dat.Delays;
  if ~isempty(delays)
    Out=delays(ind,:);
  end
  if iscell(Out)&(length(Out)==1), Out=Out{1}; end
elseif strcmp(prop,'CovarianceMatrix')
  Out=dat.Covariance; %full covariance array, ch x ch x freq
elseif strcmp(prop,'InputVariance')|strcmp(prop,'OutputVariance')|...
    strcmp(prop,'InputNonlinError')|strcmp(prop,'OutputNonlinError')|...
    strcmp(prop,'InputNonlinVariance')|strcmp(prop,'OutputNonlinVariance')
  if any(findstr('Nonlin',prop))
    if israndomized(dat)
      if strcmp(prop,'InputNonlinError')|strcmp(prop,'InputNonlinVariance')
        Out=[];
        return
      elseif strcmp(prop,'OutputNonlinError')|strcmp(prop,'OutputNonlinVariance')
        Out=[];
        fo=get(dat,'OddNonexcFrequencies');
        erro=get(dat,'OddOutputNonlinError');
        if ~isempty(erro)
          Out=interp1([-2*max(abs(fo));fo;10*max(fo)],[erro(1);erro;erro(end)],...
            get(dat,'freqpoints'));
          if 0 %test with nearest neighbors rather than interpolating
            freqs=get(dat,'freqpoints');
            Out=zeros(size(freqs));
            for ii=1:length(freqs)
              [dummy,ind]=min(abs(freqs(ii)-fo)); Out(ii)=erro(ind);
            end
          end
        end
        return
      end
    elseif isfield(dat.NewProperties,'NonlinCovariance')
      covs=dat.NewProperties.NonlinCovariance; %full nonlin covariance array, ch x ch x freq
      if strcmp(prop,'InputNonlinError')|strcmp(prop,'OutputNonlinError')
        M=get(dat,'nonlinM');
        % *** For nonlinear analysis, errors do not average out ***
        if ~isempty(M)
          if isnumeric(covs), covs=covs*M;
          else for ii=1:prod(size(covs)), covs{ii}=covs{ii}*M; end
          end
        end
      end
    else
      covs=[];
    end
  else
    covs=dat.Covariance; %full covariance array, ch x ch x freq
  end
  Out=[]; 
  if ~isempty(covs)
    if ~iscell(covs), covs={covs}; end
    fi=dat.FreqIndices;
    if ~iscell(fi), fi={fi}; end
    %while size(covs,2)>size(fi,2), fi=[fi,fi(:,1)]; end  
    %while size(covs,1)>size(fi,1), fi=[fi;fi(1,:)]; end  
    Out=cell(length(ind),max(size(covs,2),size(fi,2)));
    for ie=1:size(Out,2)
      for ic=1:size(Out,1)
        covm=covs{1,min(ie,end)};
        if ~isempty(covm)
          fim=fi{min(ind(ic),end),min(ie,end)};
          dc=permute(covm(ind(ic),ind(ic),:),[3,1,2]);
          if length(dc)==1, Out{ic,ie}=dc;
          else Out{ic,ie}=dc(fim);
          end
        end
        if all(isnan(Out{ic,ie})), Out{ic,ie}=[]; end
        if all(~isnan(Out{ic,ie}))&all(all(~diff(Out{ic,ie})))&~isempty(Out{ic,ie}) %make variance scalar
          Out{ic,ie}=Out{ic,ie}(1,:);
        end
      end %for ic
    end %for ie
    if length(Out)==1, Out=Out{1}; end
    if iscell(Out)
      emp=1;
      for ii=1:length(Out)
        if ~isempty(Out{ii}), emp=0; return, end
      end
      if emp==1, Out=[]; end
    end
  end %~isempty(covs)
elseif strcmp(prop,'CovVector')|strcmp(prop,'CohVector')|strcmp(prop,'NonlinCovVector')|...
    strcmp(prop,'AllVariances')
  Out={};
  if strncmp(prop,'Cov',3)|strcmp(prop,'AllVariances'), covs=dat.Covariance;
  elseif strncmp(prop,'Coh',3), covs=dat.Coherence;
  elseif strncmp(prop,'NonlinCovVector',10)
    if isfield(dat.NewProperties,'NonlinCovariance'), covs=dat.NewProperties.NonlinCovariance;
    else covs=[];
    end
  end
  if ~isempty(covs)
    if strcmp(prop,'AllVariances')
      if ~iscell(covs), covs={covs}; end
      fi=get(dat,'freqind'); if ~iscell(fi), fi={fi}; end
      for ie=1:length(covs)
        Outie={};
        for ic=1:size(covs{ie},1)
          Outie=[Outie;{permute(covs{ie}(ic,ic,:),[3,1,2])}];
          %eliminate NaN's
          %ind=find(isnan(Outie{ic})); if ~isempty(ind), Outie{ic}(ind)=[]; end
          ind=fi{min(ic,end),min(ie,end)}; 
          if length(Outie{ic})>length(ind), Outie{ic}=Outie{ic}(ind); end
        end
        Out=[Out,Outie];
      end
      if length(Out)==1, Out=Out{1}; end
    else %all properties, not AllVariances
      if isempty(chi)&(in==1)&(on==1), chi=[1,2];
      elseif isempty(chi)&(in+on==2), chi=[1,2];
      end
      if (in+on)~=2
        error(sprintf(['Number of channels is %.0f instead of 2, ',prop,...
            ' cannot be returned'],in+on))
      end
      %Now length(chi)==2
      fi=get(dat,'freqind'); if ~iscell(fi), fi={fi}; end
      if ~iscell(covs)
        Out=permute(covs(chi(1),chi(2),:),[3,2,1]);
        fi1=fi{min(chi(1),end)}; fi2=fi{min(chi(2),end)};
        ind=find(ismember(fi1,fi2));
        if length(Out)>length(ind), Out=Out(ind); end
      else
        Out=cell(size(covs));
				c0=1;
        for ii=1:length(covs)
          if ~isempty(covs{ii})
            Out{ii}=permute(covs{ii}(chi(1),chi(2),:),[3,2,1]);
          else
            Out{ii}=[];
          end
          fi1=fi{min(chi(1),end),min(ii,end)}; fi2=fi{min(chi(2),end),min(ii,end)};
          ind=find(ismember(fi1,fi2));
          if ~isempty(Out{ii}), Out{ii}=Out{ii}(ind); end
					if ~any(Out{ii}), Out{ii}=[]; else c0=0; end
				end %for ii
				if c0, Out=[]; end
      end
    end
  end
  if iscell(Out)
    outnan=1;
    for ii=1:prod(size(Out))
      if any(~isnan(Out{ii})), outnan=0; break, end
    end
    if outnan==1
      for ii=1:prod(size(Out)), Out{ii}=[]; end
    end
    if isempty(Out), Out=[]; end
  elseif all(isnan(Out))
    Out=[];
  end
elseif strcmpi(prop,'SisoVariance')|strcmp(prop,'OldTbSisoVariance')|...
    strcmp(prop,'SisoNonlinError')
  if strcmp(prop,'OldTbSisoVariance'), vp2=1; else vp2=0; end %divide result by 2
  if (in>1)|(on>1)
    error([prop,' has a meaning for SISO systems only'])
  end
  if strcmp(prop,'SisoNonlinError')
    vx=get(dat,'InputNonlinErr'); vy=get(dat,'OutputNonlinErr');
    if isempty(vx)&~isempty(vy), vx=0*vy; end
    if isempty(vy)&~isempty(vx), vy=0*vx; end
    cxy=get(dat,'NonlinCovVect');
  else %linear
    vx=get(dat,'inputvar'); vy=get(dat,'outputvar'); 
		cxy=get(dat,'covvect');
    if isempty(vx)&~isempty(vy), vx=0*vy; end
    if isempty(vy)&~isempty(vx), vy=0*vx; end
  end
  if isempty(vx)&isempty(vy)
    Out=[];
    return
  elseif ~iscell(vx)&~iscell(vy)&~iscell(cxy)
    if (size(vx,1)==1)&(size(vy,1)>1)
      vx=vx*ones(size(vy));
    elseif (size(vx,1)>1)&(size(vy,1)==1)
      vy=vy*ones(size(vx));
    end
    if (size(vx,1)==1)&(size(cxy,1)>1)
      if any(diff(cxy)~=0)
        vx=vx*ones(size(cxy)); vy=vy*ones(size(cxy));
      else
        cxy=cxy(1);
      end
    end
    Out=[vy,vx,cxy];
    if vp2, Out=Out/2; end
    return
  elseif iscell(vx)&iscell(vy)
    Out=cell(size(vx));
    for ii=1:length(vx)
      if (size(vx{ii},1)==1)&(size(vy{ii},1)>1)
        vx{ii}=vx{ii}*ones(size(vy{ii}));
      elseif (size(vx{ii},1)>1)&(size(vy{ii},1)==1)
        vy{ii}=vy{ii}*ones(size(vx{ii}));
      end
      if iscell(cxy)
        if (size(vx{ii},1)==1)&(size(cxy{ii},1)>1)
          if any(diff(cxy{ii})~=0)
            vx{ii}=vx{ii}*ones(size(cxy{ii})); vy{ii}=vy{ii}*ones(size(cxy{ii}));
          else
            cxy{ii}=cxy{ii}(1);
          end
        end
        Out{ii}=[vy{ii},vx{ii},cxy{ii}];
      else
        Out{ii}=[vy{ii},vx{ii}];
      end %vy,vx cell
      if vp2, Out{ii}=Out{ii}/2; end
    end
    return
  else
    error('Cannot return reasonable SisoVariance')
  end
elseif strcmp(prop,'Fdat')
  freq=get(dat,'freqpoints');
  x=get(dat,'input');
  y=get(dat,'output');
  if iscell(freq)
    warning('Only one frequency vector may be present')
    Out=[];
    return
  end
  if iscell(x)
    if size(x,1)>1
      warning('Multiple input channels')
      Out=[];
      return
    else
      x=cat(1,x{:});
    end
  end
  if iscell(y)
    if size(x,1)>1
      warning('Multiple output channels')
      Out=[];
      return
    else
      y=cat(1,y{:});
    end
  end
  if (length(x)>length(freq))|(length(y)>length(freq))|isempty(x)|isempty(y)
    Out=expfou(freq,x,y);
  else
    %Out=[freq,x,y];
    Out=expfou(freq,x,y);
  end
  
elseif strcmp(prop,'FreqNumber')
  dats=struct(dat);
  if isa(dat,'fiddata'), dats=struct(dats.iddat); end
  if ~isempty(dats.Data)&iscell(dats.Data)
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
    fp=get(dat,'allfreqpoints');
    if isnumeric(fp), Out=length(fp);
    else error('Missing data, cell freqpoints')
    end
  end
  return
elseif strcmp(prop,'N')|strcmp(prop,'M')|strcmp(prop,'NonlinM')|...
    strcmp(prop,'Type')|strcmp(prop,'Speciality')
  if isfield(dat.NewProperties,prop)
    Out=getfield(dat.NewProperties,prop);
  else
    Out=[]; 
  end
  return
elseif strcmp(prop,'NonlinCovarianceMatrix')
  if isfield(dat.NewProperties,'NonlinCovariance')
    Out=getfield(dat.NewProperties,'NonlinCovariance');
  else
    Out=[]; 
  end
  return
elseif strcmp(prop,'EvenOutputNonlinError')|strcmp(prop,'OddOutputNonlinError')
  if isfield(dat.NewProperties,prop)
    Out=getfield(dat.NewProperties,prop);
  else
    Out=[]; 
  end
  return
elseif strcmp(prop,'EvenNonexcFrequencies')|strcmp(prop,'OddNonexcFrequencies')
  if isfield(dat.NewProperties,prop)
    Out=getfield(dat.NewProperties,prop);
  else
    Out=[]; 
  end
  return
elseif strcmp(prop,'InterExpNonlinCovariance')
  if isfield(dat.NewProperties,'InterExpNonlinCovariance')
    Out=getfield(dat.NewProperties,'InterExpNonlinCovariance');
  else
    Out=[]; 
  end  
else
  error(['Unknown fiddata property ''',prop,''''])
end
%
%end @fiddata/getloc.m
