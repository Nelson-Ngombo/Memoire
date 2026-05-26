function showinits(Fdat,numord,denomord,runmod,devrunmod)
%SHOWINITS  Show initial value setting results.
%
%       lower case: polynomial, upper case: orthopol
%       Use: showinits(Fdat,numord,denomord,runmod,devrunmod)

if nargin<1, Fdat=[]; end
if isempty(Fdat), d=load('robotarm.mat'); Fdat=d.f; clear d, end
Fdat=fdident('private','getobjf',Fdat,'fiddata');
if nargin<2, numord=[]; end, if isempty(numord), numord=4; end
if nargin<3, denomord=[]; end, if isempty(denomord), denomord=6; end
if nargin<4, runmod=[]; end
if nargin<5, devrunmod=[]; end
%
domain='s';
if ~isfield(runmod,'itmax'), runmod.itmax=0; end
if ~isfield(runmod,'plotdens'), runmod.plotdens=inf; end
if ~isfield(devrunmod,'displaymessages'), devrunmod.displaymessages='off'; end
Fdatstrm=Fdat.name;
ii=1; isv='sSaAuUrRvVyYewl'; %wliI';
cf=[]; ialg=cell(2,1); isvtrue='';
if isfield(runmod,'representation')
  if strcmp(runmod.representation,'polynomial')
    ind=find(('a'<=isv)&(isv<='z')); isv=isv(ind);
  elseif strcmp(runmod.representation,'orthopol')
    ind=find(('A'<=isv)&(isv<='Z')); isv=isv(ind);
  end
end
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
		if isfinite(runmod.plotdens)
			figure(2), clf, p=get(2,'position'); p(1)=1; p(3)=400; p(2)=600-p(4)-39;
			set(2,'position',p)
			if ~strncmp(version,'5.2',3), set(gcf,'toolbar','none'), end
			figure(2)
		end
		%disp('Starting elis ...')
		pv=elis(Fdat,domain,numord,denomord,runmod,devrunmod);
		figure(1)
		if (~strcmpi(initset,'l')&~strcmpi(initset,'w')&...
				~strcmp(initset,'output-weighted least squares')) | ...
      (isfield(runmod,'fixedpars')&...
        (strcmp(runmod.fixedpars,'a_n')|strcmp(runmod.fixedpars,'a_0')))
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
		figure(1), hl=gca; %h1=subplot(2,1,1);
		rcf=1.1; cf1=min(cf)/rcf; cf2=max(cf)*rcf;
		semilogy([1:length(cf)],cf,'x',[1:length(cf)],cf,':')
		set(gca,'xlim',[0,length(cf)+1],'xtick',[1:length(cf)],...
			'xticklab',isvtrue)
    ylim=get(gca,'ylim');
    if cf1<ylim(1), ylim(1)=cf1; end
    if cf2>ylim(2), ylim(2)=cf2; end
    set(gca,'ylim',ylim);
    hold on
		plot([0,length(cf)+1],min(cf)*[1,1],':k')
		plot(iimin,cf(iimin),'*')
		[mincf,ind]=min(cf); plot(ind,mincf,'o')
		hold off
		if ~isempty(Fdatstrm), dn=['Data: ',Fdatstrm,', ']; else dn=''; end
		title(sprintf([dn,domain,'-domain, %.0f/%.0f'],numord,denomord))
		xlabel('Initial value setting')
		ylabel('Initial cost function')
		zoom on
		figure(gcf), drawnow, %pause(1)
	end
end %for initset
disp(' ')
disp(ialg) %show explanations of algorithms
