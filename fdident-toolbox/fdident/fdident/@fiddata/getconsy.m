function Out = getconsy(dat)
%GETCONSY  Check consistency of special fiddata properties

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Aug-2003

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end
if ~isa(dat,'fiddata'), error('class is not ''fiddata'''), end
%
if (dat.Version~=1.3)
  if (dat.Version<1.3)
    Out=0; warning(sprintf('Old version of fiddata: %.4g',dat.Version)), return
  else
    Out=0; warning(sprintf('Too new version of fiddata: %.4g',dat.Version)), return
  end
end
%
Out=1;
%
chno=get(dat,'ChNumber'); expno=get(dat,'ExpNumber'); F=get(dat,'FreqNumber');
%
fi=dat.FreqIndices;
afp=dat.AllFreqPoints;
if ~iscell(afp), afp={afp}; end, mf=0; mlf=0;
for ii=1:length(afp), mf=max([mf;afp{ii}]); mlf=max([mlf,length(afp{ii})]); end
%
s=struct(dat); ids=struct(s.iddat); data=ids.Data;
if ~isempty(fi)
  if ~iscell(fi), fi={fi}; end
  if ~iscell(data), data={data}; end
  [v,h]=size(fi);
  if ~any(v==[chno,1])
    Out=0; warning('Vertical size of FreqPoints is wrong'), return
  elseif ~any(h==[expno,1])
    Out=0; warning('Horizontal size of FreqPoints is wrong'), return
  end
  for ii=1:v
    for iii=1:h
      if any((fi{ii,iii}<1)|(fi{ii,iii}>mlf))|...
          (~isempty(fi{ii,iii})&any(rem(fi{ii,iii},1)~=0))
        Out=0; warning('Wrong index to AllFreqPoints (internal error)'), return      
      end
    end
  end
  for ii=1:size(data,1)
    if size(fi,1)==1, fii=1; else fii=ii; end
    for iii=1:size(data,2)
      if size(fi,2)==1, fiii=1; else fiii=iii; end
      if ~isequal(size(data{ii,iii}),size(fi{fii,fiii}))
        if ~isempty(data{ii,iii})
          Out=0; warning('FreqPoints - Data mismatch'), return      
        end
      end
    end
  end
else
  if ~isempty(data)
    Out=0; warning('freqind - Data mismatch'), return
  end
end
%
fs=dat.Fs;
if ~isempty(fs)
  if length(fs)~=1
    Out=0; warning('fs is not a scalar'), return    
  end
  if fs<=0
    Out=0; warning('fs is not positive'), return
  end
  if mf>=fs/2*(1+1e-8)
    Out=0; warning('AllFreqPoints surpasses half of the sampling frequency')
    return 
  end
end
%
delays=dat.Delays;
if ~isempty(delays)
  if ~iscell(delays), delays={delays}; end
  [v,h]=size(delays);
  if ~any(v==[chno])
    Out=0; warning('Vertical dimension of Delays is wrong'), return     
  end
  if ~any(h==[expno,1])
    Out=0; warning('Horizontal dimension of Delays is wrong'), return     
  end
  for ii=1:v
    for iii=1:h
      d=delays{ii,iii};
      if length(d)~=1
        Out=0; warning('A delay is not a scalar'), return
      end
    end
  end
end
%
iv=get(dat,'inputvariance');
ic=get(dat,'inputcharacter');
if ~isempty(ic)&~iscell(ic), ic={ic}; end
%
for ivh=0:2 %NonlinCovariance, Covariance, Coherence
  if ivh<=1
    if ivh==0
      if isfield(dat.NewProperties,'NonlinCovariance')
        covs=dat.NewProperties.NonlinCovariance; %full nonlin covariance array, ch x ch x freq
      else
        covs=[];
      end
      cnam='NonlinCovariance';
    elseif ivh==1
      covs=dat.Covariance;
      cnam='Covariance';
    end
    if iscell(covs), cc=covs; else cc={covs}; end
    if ~isempty(cc{1})
      if size(cc,2)>1
        if ~isempty(data)&iscell(data)&~isempty(data{1})
          if size(cc,2)~=size(data,2), warning('covariance-data experiment number mismatch'), Out=0; return, end
        end
      end
      if size(cc{1},1)~=size(data,1), warning('covariance-data channel number mismatch'), Out=0; return, end
    end
    for ic=1:size(cc,2)
      ccii=cc{ic}; w=0;
      for ii=1:size(ccii,3)
        c=ccii(:,:,ii);
        if ~isempty(c)
          dc=diag(c); ind=find(dc==0); if ~isempty(ind), c(ind,:)=[]; c(:,ind)=[]; end
        end
        if ~isempty(c)
          %Check proper values
          for fi=1:size(c,3)
            for iv=2:size(c,1)
              for ih=1:iv-1
                c_sub=c([iv,ih],[iv,ih],fi);
                if any(isnan(diag(c_sub)))&any(~isnan(c_sub([2,3]))&~isequal(c_sub([2,3]),[0,0]))
                  if isnan(c_sub(1,1)), chni=ih; else chni=iv; end
                  warning(sprintf('Nondefined variances while covariances defined: exp=%.0f, ch=%.0f',ic,chni))
                  Out=0; return
                end
              end %for ih
            end  %for iv
          end %for fi
          %Eliminate NaN covariances
          c1=c(:,1); ind=find(isnan(c1));
          if ~isempty(ind), c(ind,:)=[]; c(:,ind)=[]; end
        end
        if size(c,1)>1
          indnan=find(isnan(c)); if ~isempty(indnan), c(indnan)=zeros(size(indnan)); end
          e=eig(c);
          if min(e)<-max(e)*eps*1e3
            if w==0
              wii=ii;
              %warning(sprintf('Covariance matrix is degenerate for ind=%.0f',ii))
            end
            w=w+1;
            %Out=0; return 
          end
        end
      end %for ii
      if w>0
        warning(sprintf('Covariance matrix is degenerate for %.0f indices, e.g. for ind=%.0f',w,wii))
      end
    end %for ic
  elseif ivh==2
    covs=dat.Coherence; cnam='Coherence';
  end
  if ~isempty(covs)
    if ~iscell(covs), covs={covs}; end
    if (length(covs)~=length(afp))&(length(afp)~=1)
      Out=0; warning(['AllFreqPoints - ',cnam,' mismatch']), return
    end
    for ie=1:size(covs,2)
      c=covs{ie}; %This is now a series of covariance matrices
      if ~any(size(c,3)==[1,length(afp{min(ie,length(afp))})])
        Out=0; warning(['AllFreqPoints - ',cnam,' element mismatch']), return
      end
      if ivh<=1, dlim=[0,inf]; else dlim=[0,1]; end
      for iid=1:size(c,1)
        %Main diagonal
        if any( ~isnan(c(iid,iid,:)) &... 
            ( (c(iid,iid,:)<dlim(1)) | c(iid,iid,:)>dlim(2) ) )
          Out=0; warning(['Wrong element in main diagonal of ',cnam]), return
        end
        %Subdiagonal
        for iiid=1:iid-1
          if any( ~isnan(c(iid,iiid,:)) &... 
              (abs(c(iid,iiid,:)).^2>c(iid,iid,:).*c(iiid,iiid,:)*(1+1e-8)) )
            Out=0; warning(['Wrong element in subdiagonal of ',cnam]), return
          elseif any( ~isnan(c(iid,iiid,:)) &... 
              (c(iid,iiid,:)~=conj(c(iiid,iid,:))) )
            Out=0; warning(['Nonconjugate element in subdiagonal of ',cnam]), return
          end  
        end %for iiid
      end %for iid
    end %for ie
  end %~isempty
end %for ivh
%
allvar=get(dat,'allvariances');
if ~isempty(allvar)
  if ~iscell(allvar), allvar={allvar}; end
  allfreq=get(dat,'freqpoints'); if ~iscell(allfreq), allfreq={allfreq}; end
  for ic=1:max(size(allvar,1),size(allfreq,1))
    if ~isempty(allvar{min(ic,end)})
      if ~any(length(allvar{min(ic,end)})==[1,length(allfreq{min(ic,end)})])
        Out=0; warning('Variance - freqpoints mismatch'), return
      elseif ~any(sum(isnan(allvar{min(ic,end)}))==[0,length(allvar{min(ic,end)})])
        Out=0; warning('Nan element in variance vector'), return        
      end
    end
  end
end
%
np=dat.NewProperties;
if isfield(np,'M')
  M=np.M;
  if isempty(M)
  elseif ~any(length(M)==[1,expno])|any(imag(M))|any(M<1)
    Out=0; warning('M is not allowed'), return
  elseif isempty(dat.Covariance)
    Out=0; warning('M is not allowed for no variance'), return
  end
end
if isfield(np,'NonlinM')
  NonlinM=np.NonlinM;
  if isempty(NonlinM)
  elseif (length(NonlinM)~=1)|imag(NonlinM)|~isfinite(NonlinM)|(NonlinM<1)
    Out=0; warning('NonlinM is not allowed'), return
  elseif (~isfield(dat.NewProperties,'NonlinCovariance')|...
      isempty(dat.NewProperties.NonlinCovariance)) & ...
    (~isfield(dat.NewProperties,'OddOutputNonlinError')|...
      isempty(dat.NewProperties.OddOutputNonlinError))
    Out=0; warning('NonlinM is not allowed for no variance'), return
  end
end
if isfield(np,'N')
  N=np.N;
  if isempty(N)
  elseif (length(N)~=1)|imag(N)|~isfinite(N)|(N<1)
    Out=0; warning('N is not allowed'), return
  end
end
if isfield(np,'Type')
  typ=np.Type;
  if isempty(typ)
  elseif ~strcmpi(typ,'FRF')&~strcmpi(typ,'I/O')&~strcmpi(typ,'input/output')&...
      ~strcmpi(typ,'input-output')
    Out=0; warning(['Type ''',typ,''' is not allowed']), return
  end
end
if isfield(np,'Speciality')
  typ=np.Speciality;
  if isempty(typ)
  elseif ~strcmpi(typ,'NMR')
    Out=0; warning(['Type ''',typ,''' is not allowed']), return
  end
end
if isfield(np,'InterExpCovariance')
  iec=np.InterExpCovariance;
  if ~isempty(iec)
    if get(dat,'expnumber')>1
      if ~iscell(iec)
        Out=0; warning('InterExpCovariance is not a cell array'), return
      elseif any(size(iec)~=get(dat,'expnumber'))
        Out=0;
        warning(sprintf('Size of InterExpCovariance: %.0f x %.0f differs from expnumber x expnumber = %.0f x %.0f',...
          size(iec,1),size(iec,2),get(dat,'expnumber'),get(dat,'expnumber')))
        return
      else
        for ie1=1:size(iec,1)
          for ie2=1:size(iec,2)
            if ~isempty(iec{ie1,ie2})
              if ~iscell(iec{ie1,ie2}), Out=0; warning('A cell of InterExpCovariance contains not a cell array'), return
              elseif any(size(iec{ie1,ie2})~=get(dat,'chnumber'))
                Out=0;
                warning(sprintf('Size of cell{%.0f,%.0f} of InterExpCovariance, %.0f x %.0f, differs from chnumber x chnumber = %.0f x %.0f',...
                  ie1,ie2,size(iec{ie1,ie2},1),size(iec{ie1,ie2},2),get(dat,'chnumber'),get(dat,'chnumber')))
                return
              end
            end
          end %for ie2
        end %for ie1
      end
    else
      Out=0; warning('InterExpCovariance is nonempty but there is just one experiment'), return
    end
  end
end
%
return
%
% end @fiddata/getconsy.m