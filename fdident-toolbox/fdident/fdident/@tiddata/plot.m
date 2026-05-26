function handles=plot(varargin)
%PLOT Plot tiddata object in a similar way as plot
%
%       A handle of an axes (or a column vector of two handles of two axes)
%          can be passed at the end preceded by argument 'parent'
%       overlap specifies the overlap between successive experiments
%          (only nonpositive values are allowed). Default: 0.2
%
%       Usage:
%         h=plot(tdata,overlap,'parent',hax)
%       Examples:
%         plot(tdata)
%         h=plot(tdata,[],'parent',hax)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 29-Aug-2003

no=nargout; ni=nargin;
tdata=varargin{1};
delvar=[inf];
smooth='';

haxtmp=[]; ovl=[]; h=[];
for ii=2:length(varargin)
  if ~any(ii==delvar)
    if isstr(varargin{ii})&strcmp(varargin{ii},'parent')
      if ii==length(varargin), error('''parent'' is the last argument'), end
      haxtmp=varargin{ii+1};
      delvar=[delvar;ii;ii+1]; %these arguments are finished
    %elseif strncmpi(varargin{ii},'smoothed',6)
      %smooth=varargin{ii};
      %smooth='smoothed';
      %delvar=[delvar;ii]; %these arguments are finished
    elseif isnumeric(varargin{ii})&(length(varargin{ii})==1)
      ovl=varargin{ii};
      if ovl>0, error('There is positive overlap between the experiments'), end  
    else
      error('invalid argument')
    end
  end
end
if isempty(ovl), ovl=-0.2; end
if isempty(haxtmp)
  hax1given=0;
  hf=gcf;
  if strcmp(get(hf,'handlevisibility'),'off')
    hf=figure(99); %Something is wrong... to be sure, make a new figure
  end
  if strcmp(get(hf,'nextplot'),'add')
    %children are deleted to avoid erroneous plots later
    delete(get(hf,'children'))
  elseif strcmp(get(hf,'nextplot'),'replacechildren')
    delete(get(hf,'children'))
  elseif strcmp(get(hf,'nextplot'),'replace')
    delete(hf), hf=figure(hf);
  else
    error(['Value of ''nextplot=''',get(hf,'nextplot'),''' is not yet programmed'])
  end
  hax1=subplot(2,1,2); hax2=subplot(2,1,1);
else
  hax1given=1;
  if isa(haxtmp,'matlab.graphics.axis.Axes')|...
          (isnumeric(haxtmp)&(size(haxtmp,2)==1)&(size(haxtmp,1)<3))
    %hax1=haxtmp(1); hf=get(hax1,'parent'); 
    %hax2=[];
    %if length(haxtmp)>1, hax2=haxtmp(2);
    %else error('Handle vector does not contain 2 elements')
    %end
  %elseif isnumeric(haxtmp)&(size(haxtmp,2)==1)&(size(haxtmp,1)<3)
    %maybe axes handle(s)
    for ii=1:prod(size(haxtmp))
      if ~ishandle(haxtmp(ii))
        error('axhand contains non-handle element(s)')
      end
    end
    hax1=haxtmp(1); hf=get(hax1,'parent'); 
    hax2=[];
    if length(haxtmp)>1, hax2=haxtmp(2);
    else error('Handle vector does not contain 2 elements')
    end
  else
    error('Invalid handle')
  end
end

chn=get(tdata,'chn');
if chn>2, error('Channel number is greater than 2'), end
input=get(tdata,'input'); output=get(tdata,'output');
if (chn==2)&(isempty(input)|isempty(output))
  error('Only one input and one output can be handled')
end
N=get(tdata,'samplen');
tviii=[]; tvoii=[];
for ic=1:2 %input and output
  if ic==1 %input
    dtype='Input';
    hax=hax1;
    data=input;
  else %output
    dtype='Output';
    hax=hax2;
    data=output;
  end
  Ts=[];
  tv=get(tdata,[dtype,'SamplingInstants']);
  ch=get(tdata,[dtype,'Character']);
  if isempty(tv)
    Ts=tdata.Ts;
    tv=[1:N]*Ts;
    tstart=get(tdata,[dtype,'TStart']);
    if ~isempty(tstart)&isnumeric(tstart)
      tv=tv-Ts+tstart;
    elseif iscell(tstart)
      tv1=tv; tv=cell(size(tstart));
      for ii=1:length(tstart)
        tst=tstart{ii}; if isempty(tst), tst=0; end
        tv{ii}=tv1-Ts+tst;
      end %for ii
    end
  elseif iscell(tvi)
    error([dtype,' sampling instants is a cell, not yet ready'])
  elseif isempty(Ts)
    Ts=mean(diff(tv));
  end
  if isempty(Ts), error('Cannot determine Ts from object'), end
  ytext=get(tdata,[dtype,'name']);
  titletext=dtype;
  delete(get(hax,'children'))
  if ~isempty(data)
    if ~iscell(data), data={data}; end
    if ~iscell(ch), ch={ch}; end
    maxd=-inf; mind=inf;
    %axes(hax)
    axv1=[]; axv2=[]; b=[]; bm='';
    delete(get(hax,'children'))
    %
    for ii=1:length(data)
      if iscell(tv), tvii=tv{ii};
      else tvii=tv+(ii-1)*length(tv)*Ts*(1-ovl);
      end
      if size(ch,2)==1, chii=1; else chii=ii; end
      uf=[]; hx=[]; hZ=[]; hi=[];
      hx=plot(tvii,data{ii},'b+','parent',hax); %regular plot of points
      axv1=min([axv1;tvii(:)]); axv2=max([axv2;tvii(:)]);
      set(hax,'nextplot','add')
      if strncmpi(ch{chii},'ZOH',3) %ZOH or ZOHf
        %here comes the ZOH plot
        tvii2=[tvii(:)';tvii(:)'+Ts]; tvii2=tvii2(:);
        data2=[data{ii}';data{ii}']; data2=data2(:);
        hZ=plot(tvii2,data2,'b','parent',hax);
        axv1=min([axv1;tvii(:)+Ts]); axv2=max([axv2;tvii(:)+Ts]);
      end
      %
      if strcmpi(ch{chii},'FOH') %FOH
        %here comes the FOH plot
        tvii2=[tvii(:)';tvii(:)'+Ts]; tvii2=tvii2(:);
        dd=diff(data{ii});
        data2=[data{ii}';[data{ii}+[dd(1);dd]]']; data2=data2(:);
        hZ=plot(tvii2,data2,'b','parent',hax);
        mind=-max([-mind;abs(data2)]); maxd=max([maxd;abs(data2)]);
        axv1=min([axv1;tvii(:)+Ts]); axv2=max([axv2;tvii(:)+Ts]);
      end
      %
      if strcmp(ch{chii},'ZOHf')
        set(hZ,'linestyle',':','color','g')
        %Now plot interpolation for filtered ZOH
        u=data{ii}; N=length(u);
        interp=16; Nip=N*interp;
        indcN=get(tdata,[dtype,'frequencies'])*Ts*N+1;
        if isempty(indcN), indcN=[1:floor(N/2)]; end
        if ~isempty(indcN)&any(abs(rem(indcN+0.3,1)-0.3)>1e5*eps)
          warning('Signal is nonperiodic')
        end
        indcN=round(indcN); indcNip=(indcN-1)*interp+1;
        uf=u(:,ones(1,interp))'; uf=uf(:);
        UF=fft(uf); cx=UF(indcN);
        UF=zeros(Nip,1); UF(indcN)=cx;
        uf=2*real(ifft(UF)); %clear UF
        tvs=min(tvii)+[0:Nip-1]*(Ts/Nip*N);
        hi=plot(tvs,uf,['-','b'],'parent',hax);
        mind=-max([-mind;abs(uf)]); maxd=max([maxd;abs(uf)]);
        axv1=min([axv1;tvs(:)]); axv2=max([axv2;tvs(:)]);
      end %Interpolated plot for ZOHf
      %
      %if strcmpi(ch{chii},'Discrete')
      %  hi=plot(tvii,data{ii},':','parent',hax);
      %end
      %
      if strcmpi(ch{chii},'BL')%|strcmpi(ch{chii},'Samples')
        if strcmpi(ch{chii},'BL'), marker='-'; else marker=':'; end        
        st=tvii(1); dt=mean(diff(tvii));
        u=data{ii}; N=length(u); U=fft(u);
        fv=get(tdata,'frequencies'); if isempty(fv), fv=[]; end
        ind=fv*get(tdata,'Ts')*get(tdata,'samplenumber')+1;
        %ind=[];
        if isempty(ind)
          ind=find(abs(U(1:floor(end/2)-1))>eps*1e5*max(abs(U(1:floor(end/2)-1))));
        end
        interp=pow2(round(log2(16/((N/2)/max(ind+1)))));
        if interp>=4
          if rem(N,2)==0
            %N even
            U=[U(1:N/2);U(N/2+1)/2;zeros((interp-1)*N-1,1);U(N/2+1)/2;U(N/2+2:end)];
          else
            %N odd
            U=[U(1:(N+1)/2);zeros((interp-1)*N,1);U((N+1)/2+1:end)];
          end
          uf=real(ifft(U))*interp;
        end
        %delete(allchild(hax))
        if interp>=4
          hi=plot(dt/interp*[0:N*interp-1]+st,uf,[marker,'b'],'parent',hax);
        else
          hi=plot(tvii,u,[marker,'b'],'parent',hax);
          %hi=plot(tvii,u,'+','markersize',3,'parent',hax);
        end
        axv1=min([axv1;tvii(:)]); axv2=max([axv2;tvii(:)]);    
      end %BL, Samples
      h=[h;hi;hZ];
      %
      if ii>1
        tviimin=min(tvii);
        if abs(tviimin-tviimax-Ts)<0.2*Ts, bmii=':'; 
        else bmii='-';
        end
        b=[b,(tviimax+tviimin)/2];
        bm=[bm,bmii];
      end
      tviimax=max(tvii);
      %
      maxd=max(maxd,max(data{ii})); mind=min(mind,min(data{ii}));
      if ~isempty(uf)
        maxd=max(maxd,max(uf)); mind=min(mind,min(uf));
      end
%      if ii==1, set(hax,'nextplot','add'), end
    end %for ii (length of data)
    axv=[0,0,0,0]; axv(2)=axv2+Ts;
    if (axv1<0)|(axv1>N/2*Ts)
      axv(1)=axv1;
    end
    axv(3:4)=[mind,maxd]+0.05*(maxd-mind)*[-1,1];
    if axv(3)==axv(4), axv(3:4)=axv(3)+[-1,1]*1e-4*max(eps,abs(axv(3))); end
    if axv(1)==axv(2), axv(1:2)=axv(1)+[-1,1]*1e-4*max(eps,abs(axv(1))); end
    set(hax,'xlim',axv(1:2),'ylim',axv(3:4))
    %
    for iii=1:length(b)
      plot([b(iii),b(iii)],axv(3:4),[bm(iii),'k'],'parent',hax)
    end
    %
    if ii>1, xtxt=sprintf(' (N=%.0f, %.0f experiments)',length(tvii),ii);
    else xtxt=sprintf(' (N=%.0f)',length(tvii));
    end
    set(get(hax,'xlabel'),'string',['Time, s',xtxt])
    if ~isempty(ytext)
      set(get(hax,'ylabel'),'string',ytext)
    end
  else %empty data
    shtxt=['The ',lower(dtype),' is empty in the object'];
    text(0.5,0.5,shtxt,'units','normalized','horizontalalignment','center',...
      'verticalalignment','middle','parent',hax)
  end %~isempty(data)
  set(get(hax,'title'),'string',titletext)
  set(hax,'nextplot','replacechildren')
end %for ic
%zoom(hf,'on'), figure(get(hax,'parent'));
set(get(hax,'parent'),'WindowButtonDownFcn','zoom down','WindowButtonUpFcn','ones;')
if no>0, handles=h; end

%End of @tiddata/plot