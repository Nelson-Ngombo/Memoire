%HINITTEST

figure(1), set(1,'name','hinittest')
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
if ~exist('savefigs'), savefigs='n'; end
fprintf('To save figures, set ''savefigs'' to ''y''')
savefigs=yesinput('Save figures to files',savefigs,'y|n');
graphnumber=0;
aut=0; %manual run
if ~exist('d')|(length(d)~=1), d=1; end
dmin=d;
for d=dmin:14
  aut=1; %automatic run
  clear runmod, xscale='lin';
  Fdatstr='';
  domain='s';
  representation='polynomial';
  runmod=struct('itmax',0,'representation',representation);
  runmod.plotdens=inf;
  runmod.plotdens=1;
  runmod.transients='off';
  if d==1, numord=11; denomord=12; Fdat='inpchan';
  elseif d==2, numord=4; denomord=6; Fdat='robotarm(f)';
  elseif d==3, numord=4; denomord=6; Fdat='bandpass(bandpass_agv)';
  elseif d==4, numord=8; denomord=10; Fdat='aluplate';
  elseif d==5, numord=6; denomord=6; load crankcas; Fdat=crankcas{:,1}; Fdatstr='crankcas{1}';
  elseif d==6, numord=8; denomord=10; Fdat='glassfib';
  elseif d==7, numord=3; denomord=2; Fdat='emachine';
    runmod.plotfreq='logarithmic'; xscale='log';
  elseif d==8, numord=38; denomord=38; Fdat='cabin(arrowdata_agv)';
  elseif d==9, numord=5; denomord=6; Fdat='lowpass(lowpass_lowlevel_avg)'; domain='z';
    runmod.fs=8e4;
  elseif d==10, numord=0; denomord=6; Fdat='lowpass(lowpass_lowlevel_avg)';
  elseif d==11, numord=5; denomord=6;
    Fdat=fdident('private','getobjf','lowpass(lowpass_wideband)','fiddata');
    Fdat.SiSoVariance=[1,1]*1e-6;
    domain='z'; runmod.fs=8e4; Fdatstr='lowpass(lowpass_wideband)';
  elseif d==12, numord=50; denomord=50; Fdat='wilkins(w50_1m3_1em7)';
  elseif d==13, numord=4; denomord=6; Fdat='bandpass(bandpass_nonstationary)';
    runmod.transients='on';
  elseif d==14, numord=2; denomord=2;
    Fdat=fdident('private','getobjf','corros(dat)','fiddata');
    Fdat.SiSoVariance=[0,1]; Fdatstr='corros(dat)';
    domain='w';
    runmod.plotfreq='logarithmic'; xscale='log';
  else d=1; error(sprintf('Invalid d:%.4g',d))
  end
  if isempty(Fdatstr)
    Fdatstr=Fdat;
  end
  fprintf(['d=%.0f, ',Fdatstr,'\n'],d)
  Fdatstrm=Fdatstr;
  ind_=find(Fdatstrm=='_');
  for in=length(ind_):-1:1
    ind=ind_(in); Fdatstrm=[Fdatstrm(1:ind-1),'\\',Fdatstrm(ind:end)];
  end
  figure(1), clf, set(gcf,'position',[401,21,400,540])
  if ~strncmp(version,'5.2',3), set(gcf,'toolbar','none'), end
  h2=subplot(2,1,2);
  plot(fdident('private','getobjf',Fdat),'parent',h2,'xscale',xscale)
  xlabel(sprintf(['Data %.0f: ',Fdatstrm],d))
  %if aut==1, hgsave(2,['data',int2str(d)]), drawnow, end
  figure(1), drawnow
  devrunmod=struct('displaymessages','off','calculateCR','off');
  %devrunmod=struct('calculateCR','off');
  ii=1; isv='sSaAuUrRvVyYeiI'; %wl';
  if strcmp(runmod.transients,'on')|(domain=='w'), ind=find(isv=='e'); isv(ind)=[]; end
  cf=[]; ialg=cell(2,1); isvtrue='';
  for initset=isv
    if ('A'<=initset)&(initset<='Z')
      runmod.representation='orthopol';
    else
      runmod.representation='polynomial';
    end
    if ~(strcmp(runmod.representation,'orthopol')&any(domain=='wz'))
      if strcmpi(initset,'i')
        [dummy,ind]=min(cf);
        runmod.initmodel=pvmin;
        %disp(['Doing iqml from initset=''',initset,''' ...'])
      end
      %fprintf(['d=%.0f, initset=''',initset,''', representation=''',...
      %    runmod.representation,'''\n'],d)
      runmod.initset=initset;
      if finite(runmod.plotdens)
        figure(2), clf, p=get(2,'position'); p(1)=1; p(3)=400; p(2)=600-p(4)-39;
        set(2,'position',p)
        if ~strncmp(version,'5.2',3), set(gcf,'toolbar','none'), end
        figure(2)
      end
      %disp('Starting elis ...')
      pv=elis(Fdat,domain,numord,denomord,runmod,devrunmod);
      figure(1)
      if ~strcmpi(initset,'l')&~strcmpi(initset,'w')&...
          ~strcmp(initset,'output-weighted least squares')
        %Save only if algorithm was not changed
        cfii=pv.fitinfo.cf;
        if all(cfii<[cf,inf])&~strcmpi(initset,'i')
          pvmin=pv;
          iimin=ii;
          initmin=initset;
        end
        cf(ii)=cfii;
        ialg{ii,1}=initset;
        ialg{ii,1}=['',initset,''': ',pv.algorithm.initset];
        if strcmp(runmod.representation,'orthopol')
          ialg{ii,1}=[ialg{ii,1},', orthopol'];
        end
        isvtrue(ii,1)=initset;
        ii=ii+1;
      else
        isv(ii)=[];
      end
      figure(1), h1=subplot(2,1,1);
      semilogy([1:length(cf)],cf,'x',[1:length(cf)],cf,':')
      set(gca,'xlim',[0,length(cf)+1],'xtick',[1:length(cf)],...
        'xticklab',isvtrue)
      hold on
      plot([0,length(cf)+1],cf(1)*[1,1],':')
      plot(iimin,cf(iimin),'*')
      [mincf,ind]=min(cf); plot(ind,mincf,'o')
      hold off
      title(sprintf(['Data: ',Fdatstrm,', ',domain,'-domain, %.0f/%.0f'],numord,denomord))
      xlabel('Initial value setting')
      ylabel('Initial cost function')
      zoom on
      figure(gcf), drawnow, %pause(1)
      %disp(ialg) %show explanations of algorithms
    end
  end %for initset
  if aut==1, hgsave(1,['fig',int2str(d)]), end
  disp(['   hinittest for ''',Fdatstr,''' has been done'])
  d=d+1;
  graphnumber=grapause('helistst',graphnumber,testsavegraphst);
end %for d
d=1;
