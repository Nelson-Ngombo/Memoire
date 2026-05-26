%TESTFINITESAMP

clear
%delete testfinitesamples.mat
if exist('testfinitesamples.mat'), load testfinitesamples.mat, mtypefile=mtype; end
m=fidmodel('s',1,[1,1]);
cases=1000; %number of experiments
%
mtypev={'linear','nonlinear','interpolated'};
if exist('mtypefile')
  ind=strmatch(mtypefile,mtypev);
  mtypev(1:ind)=[]; 
else
  %mtypev={'nonlinear'};
  %for mtypev={'interpolated'};
  mtypefile=mtypev{1};
end
for mtype=mtypev
  mtype=mtype{1};
  if strcmp(mtype,'linear'), Mv=[2,4,7];
  elseif strcmp(mtype,'nonlinear'), Mv=7;
  elseif strcmp(mtype,'interpolated'), Mv=[1,7];
  else error(['mtype ''',mtype,''' not allowed'])
  end
  if ~strcmp(mtype,'interpolated')
    F=100; fv=[1:F]/F;
    u=ones(F,1); y=tfcalc(m,fv);
    f0=fiddata(y,u,fv);
    f0.outputvar=1e-4;
    m0=elis(f0,'s',0,1,struct('plotdens',inf),struct('displaymessages','off'));
    cov0=m0.covariance; f0.outputvar=[];
    %plot(f0)
  else %interpolated
    F=150; fvall=[1:F]/F; [fv,fvind]=randomize(fvall);
    u=zeros(F,1); y=u; yexc=tfcalc(m,fv);
    u(fvind)=ones(size(fvind)); y(fvind)=yexc;
    f0=fiddata(y,u,fvall); f0.frequencies=fv;
    f0.outputvar=1e-4;
    m0=elis(f0(fvind),'s',0,1,struct('plotdens',inf),struct('displaymessages','off'));
    cov0=m0.covariance; f0.outputvar=[];
    %plot(f0)
  end
  if exist('M')&strcmp(mtypefile,mtype)
    ind=find(ismember(M,Mv));
    if ~isempty(ind)
      if isequal(ic,cases), Mv(1:ind)=[]; clear ic
      else Mv(1:ind-1)=[];
      end
    end
  end
  for M=Mv
    if isequal(M,Mv(1))&exist('ic'), icstart=ic+1;
    else icstart=1; cfav=[]; pav=[]; covav=[]; cv=zeros(cases,1); pv=zeros(cases,3);
    end
    for ic=icstart:cases
      if strcmp(mtype,'linear')
        f0.outputvar=1e-4*M;
        fM=simfou(f0,[],M); fM.outputvar=[];
        fav=varanal(fM);
      elseif strcmp(mtype,'nonlinear')
        fM=[];
        stdnlvar=1e-4*M;
        for ie=1:M
          ph=exp(j*2*pi*rand(size(f0.inputdata)));
          fie=f0;
          fie.input=fie.input.*ph; 
          fie.Ref=fie.input;
          fie.output=fie.output.*ph+sqrt(stdnlvar/2)*(randn(size(ph))+j*randn(size(ph)));
          fM=merge(fM,fie);
        end %for fie
        fM.synchronization='samepower';
        fav=nonlinvar(fM);
      elseif strcmp(mtype,'interpolated')
        f00=f0; f00.covariance=[]; f0.outputvar=1e-4*M;
        fM=simfou(f00,f0,M);
        if M>1, fMv=varanal(fM); else fMv=fM; end
        y=fMv.y;
        nnl=sqrt((1e-3)/2)*(randn(size(y))+j*randn(size(y)));
        fMv.y=y+nnl;
        fav=interpvar(fMv);
      end
      %plot(fav)
      pmi=elis(fav,'s',0,1,struct('plotdens',inf,'errorweighting',mtype),...
        struct('displaymessages','off'));
      if strcmp(mtype,'linear'), Md=pmi.data.M;
      elseif strcmp(mtype,'nonlinear'), Md=pmi.data.nonlinM;
      else Md=NaN;
      end
      pmip=[pmi.num,pmi.denom]; if any(pmip<0), pmip=-pmip; end
      %plot(pmi)
      %
      cv(ic)=pmi.fitinfo.cf; cfav=rmeanvar(ic,cv(ic),cfav);
      cfth=pmi.fitinfo.cfth; cf95=pmi.fitinfo.cf95; cf05=pmi.fitinfo.cf05;
      if ic==1, disp(sprintf(['Model type: ',mtype,', M = %.0f, ',date],M)), end
      txt1=sprintf(['  cyc = %.0f, M=%.0f, Meq = %.0f, cost function: %.5g < %.5g < %.5g,\n',...
        '                  theoretical: %.5g, manual: %.5g'],...
        ic,M,Md,cfav-2*std(cv(1:ic))/sqrt(ic),cfav,cfav+2*std(cv(1:ic))/sqrt(ic),cfth,(Md-1)/(Md-2)*(F-1));
      disp(txt1)
      %
      pv(ic,:)=pmip; pav=rmeanvar(ic,pv(ic,:),pav);
      if ic>=2
        txt2=sprintf('    Params: %.4g+-%.3e, %.4g+-%.3e, %.4g+-%.3e',...
          reshape([mean(pv(1:ic,:));2*std(pv(1:ic,:))/sqrt(ic)],6,1)); %±
        disp(txt2)
      end
      %
      covav=rmeanvar(ic,pmi.covariance,covav);
      txt3=sprintf('    2*standard deviations (from pcov file): %.3e, %.3e, %.3e',...
        2*sqrt(diag(covav(1:3,1:3)))/sqrt(ic)); %corrected for smoothing
      disp(txt3)
      %[cov0,covav,abs(cov0-covav)./cov0]
      if rem(ic,10)==0
        mts=mtypefile; clear mtypefile, save testfinitesamples.mat, mtypefile=mts; 
      end
    end %for ic
    diary testfinitesamples.diary
    disp(sprintf(['Model type: ',mtype,', M = %.0f, ',date],M))
    disp(txt1), disp(txt2), disp(txt3)
    if strcmp(mtype,'linear')
      clf, hist(cv), hold on, ax=axis; plot(cf05*[1,1],ax(3:4),cf95*[1,1],ax(3:4)), hold off, shg
    elseif strcmp(mtype,'nonlinear')

    elseif strcmp(mtype,'interpolated')

    end
    diary off
  end %for ic
end %for mtype