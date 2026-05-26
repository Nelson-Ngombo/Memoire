%HFDEXAMP Frequency Domain System Identification Toolbox: Execute examples

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 23-Mar-2005

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
disp('Frequency Domain System Identification Toolbox')
disp('HFDEXAMP - Check examples of m-files and the manual')
disp('File hfdexamp')
clf, hold off, iterctrl
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
rand('seed',0), randn('seed',0)
echo on

%FIDDATA
fiddata_examples
clear *obj* ff

%TIDDATA
tiddata_examples
clear *obj* tt

%FIDDATA
fidmodel_examples
clear fidm*

%CORRTEST
        %
        %Old call
        if exist('corrtest.m')
          load inpchold %load variables Fdat, pvect, Cp
        else
          [freqvect,x,y,expno]=impfou('inpchan.fbn');
          Fdat=expfou(freqvect,x,y);
          [domain,num,denom,delay,fsc]=imppar('inpchans.pbn');
          pvect=exppar(domain,num,denom,delay,fsc);
          Cp=impcov('inpchans.cbn');
        end
        [rx,ry,ryx,vryx]=rdueelis(pvect,Cp,Fdat,[9.61e-10,9.61e-12]);
        if exist('corrtest.m')
          corrtest(ryx,vryx,26)
          %New call
          corrtest('inpchmod(inpchans)');
          corrtest('rarmmods(m)',12);
        end
        iterctrl
%CRESTMIN
        if exist('corrtest.m')
          [cx,crestx]=crestmin(fiddata([],[],[1:15]'/256));
          crestmin(fiddata([],ones(15,1),[1:15]),struct('itmax',50,'N',4096,'pmin',64,...
            'initset','schroeder'))
          %
          load crestmin.mat
          crestmin(vdo15,struct('itmax',50,'N',4096,'pmin',256,'pmax',1024))
          %Schroeder starting phases:
          cx=crestmin(fiddata([],ones(12,1),4:15),struct('initset','Schroeder'));
          %ZOH design:
          cx=crestmin(fiddata([],ones(21,1)/sqrt(42),[0.2:0.01:0.4]),...
            struct('crestmode','ZOH','N',100));
          %Optimize input channel data:
          load inpchan, inpchan.output=[]; crestmin(inpchan,struct('itno',3));
        else
          [cx,crestx]=crestmin(struct('freqpoints',[1:15]'/256,'input',[],'output',[]));
          %Random starting phases:
          cx=crestmin(struct('freqpoints',4:15,'input',ones(12,1),'output',[]),...
            struct('initset','rand'));
          %ZOH design:
          cx=crestmin(struct('freqpoints',[0.2:0.01:0.4],'input',ones(21,1)/sqrt(42),...
            'output',[]),struct('crestmode','ZOH','N',100));
        end
%DFCALC
        if exist('corrtest.m')
          df=dfcalc([5.1:2:16]);
        end
%DIBS
        bits0=dibs(16,1e-3,[2:5]/1e-3/16,[1,1,1,.5]);
        %
        if exist('corrtest.m')
          bitsn=dibs(fiddata([],[1,1,1,.5]',[2:5]/1e-3/64),64,1e3);
        end
%DIBSIMPR
        [bitser,ampopt]=dibsimpr(bits0,1e-3,[2:5]/1e-3/16,[1,1,1,.5]);
        %
        if exist('bitsn'), bitser=dibsimpr(bitsn); end
        %
        freqv=[500:100:2e3];
        fs=4*2e3; N=round(fs/100); %N=80
        bits0=dibs(N,1/fs,freqv,[],10);
        bitser=dibsimpr(bits0,1/fs,freqv);
%ELIS
        %Old call
        if exist('corrtest.m')
          load bandpold %load variable Fvect1
          elis(Fvect1,1.7e-4*[1,1],['s',4,6]);
          load inpchold %load variable Fdat
          elis(Fdat,[9.61e-10,9.61e-12],['s',11,12]);
          %z-domain, free delay:
          if ~strncmp(version,'7.0.4',5)
            elis(Fdat,[9.61e-10,9.61e-12],['z'+0,14,14,51200],'v');
          end
        end
        if exist('bandpass.fbn')
          [freqv,x,y]=impfou('bandpass.fbn',1);
          elis([freqv,x,y],3.4e-4*[1,1],['s',4,6]);
          if exist('inpchans.ebn')
            elis('inpchans.ebn');
            elis('inpchanz.ebn',[],['z',16,16],[35,0]); %fixing the delay
          end
        end
        if exist('corrtest.m')
          %New call
          load bandpass, bp1=bandpass{:,1}; bp1.SiSoVariance=3.4e-4*[1,1];
          elis(bp1,'s',4,6);
          pv=elis('inpchan','s',11,12);
          %z-domain, free delay:
          elis('inpchan','z',14,14,struct('delaytreat','variable'));
        end
%ELISQA
        if exist('inpchans.ebn')
          elisqa('helqtest.ebn','inpchans.ebn');
          delete helqtest.ebn %file yet needed
        else
          elisqa('helqtest.ebn');
        end
%ELRPF2V
        if exist('inpchans.ebn')
          [rppar,fixp,rpalg,rppl,initp,prfs]=elrpf2v('inpchans.ebn');
          elrpf2v('inpchans.ebn')
        else
          [rppar,fixp,rpalg,rppl,initp,prfs]=elrpf2v('helqtest.ebn');
          elrpf2v('helqtest.ebn')
          delete helqtest.ebn
        end
%ELRPV2F
        elrpv2f('newfile.ebn',['z',12,12],[0],'r');
        elrpv2f('',['z',12,12],'0','r');
        delete newfile.ebn
%ELISFCNV
        if exist('inpchans.pbn')
          elisfcnv('inpchans.pbn','inpchans.par')
          delete inpchans.par
        end
%ELIS2THA,THA2ELIS
        if (exist('poly2th')|exist('mktheta'))
          %Check if toolbox is licensed
          ident_license=0;
          if exist('inpchanz.pbn')
            try,
              theta=feval('elis2tha','inpchanz.pbn','inpchanz.cbn',2/256*1e-9);
              ident_license=1;
            catch, ident_license=0;
            end
          else
            try,
              theta=feval('elis2tha','inpchmod(inpchanz)','',2/256*1e-9);
              ident_license=1;
            catch, ident_license=0;
            end
          end
          if ident_license>0
            if exist('inpchanz.pbn')
              theta=elis2tha('inpchanz.pbn','inpchanz.cbn',2/256*1e-9);
              [num,denom,delay,fs]=tha2elis(theta);
              %
              [dom,num,den,delay,fs]=imppar('inpchanz.pbn');
              pdat=exppar(dom,num,den,delay,fs);
              theta=elis2tha(pdat,'',2/256*1e-9);
              [num,denom,delay,fs]=tha2elis(theta);
            else
              theta=elis2tha('inpchmod(inpchanz)','',2/256*1e-9);
            end
            [num,denom,delay,fs]=tha2elis(theta);
          end
        else
          fprintf(['\nWARNING! Cannot find the function m-files',...
          ' ''poly2th'' or ''mktheta'' of the',...
          '\nSystem Identification Toolbox - is this toolbox installed?\n',...
          'The example of elis2tha will be skipped.\n\n'])
        end
%EXPCOV,IMPCOV
        coeffcovar=eye(5); expcov(coeffcovar,[],'data.cbn');
        if exist('corrtest.m')
          inpchans=loadvar('inpchmod','inpchans');
        end
        if exist('inpchans.cbn')
          [coeffcov,fixpind]=impcov('inpchans.cbn','nofixp');
        else
          [coeffcov,fixpind]=impcov(inpchans.covariance,'nofixp');
        end
        delete data.cbn
%EXPFOU,IMPFOU
        expfou([1:20],ones(100,1),0.1*ones(100,1),[1:5],5,'data.fbn');
        delete data.fbn
        if exist('inpchan.fbn')
          [freqvect,x,y]=impfou('inpchan.fbn',[]);
        end
        [freqvect,x,y]=impfou('inpchan',[]);
        %
        x=rand(100,1); y=rand(100,1)+sqrt(-1)*rand(100,1);
        data=expfou([1:20],x(1:100),y(1:100));
        [freqvect,x,y,expno]=impfou(data);
        %
        expfou([1:20],ones(100,1),0.1*ones(100,1),[1:5],5,'data.fbn');
        [freqvect,x,y,expno]=impfou('data.fbn');
        delete data.fbn
        %
        Fvect=expfou([1:20],ones(60,1),0.1*ones(60,1),[1:3],5);
        Fvect=[Fvect;expfou([1:20],ones(40,1),0.1*ones(40,1),[4,5],5)];
        [freqvect,x,y,expno]=impfou(Fvect);
%EXPPAR,IMPPAR
        pvect=exppar('s',[1,1],[1,2,3,4]);
        exppar('z',[1,1],[4,3,2,1],0,1,[],[],'filter.pnt','Trial',date);
        [domain,num,denom,delay,fs]=imppar('filter.pnt');
        delete filter.pnt
        %
        if exist('inpchans.pbn')
          [domain,num,denom,delay,fsc]=imppar('inpchans.pbn',[]);
        else
          [domain,num,denom,delay,fsc]=imppar('inpchmod(inpchans)',[]);
        end
%EXPTIM,IMPTIM
        exptim([1:10],ones(50,1),.1*ones(50,1),[1:5],5,'data.tbn');
        [timevect,xt,yt,expno]=imptim('data.tbn');
        delete data.tbn
        %
%EXPVAR,IMPVAR
        expvar(ones(20,1),0.1*ones(20,1),[],'data.vbn');
        [varx,vary]=impvar('data.vbn');
        delete data.vbn
        %
        if exist('emachine.vbn')
          [varx,vary]=impvar('emachine.vbn');
        end
        if exist('corrtest.m')
          load emachine
          [varx,vary]=impvar(emachine.SiSoVariance);
        end
%EXPVECT
        t=[1:100]; x=100*ones(100,2)+rand(100,2)+j*rand(100,2);
        expvect('data.txt',t,real(x(:,2)),imag(x(:,2)),8)
        delete data.txt
%FDCOVPZP
        if exist('inpchans.pbn')
          [zv,stdz,pv,stdp,g,stdg,rzp]=stdpz('inpchans.pbn','inpchans.cbn');
          subplot(121)
          plotelpz('inpchans.pbn','inpchans.cbn',10,[-6,2,-4,4]*1e5,'nomsg')
          [pvectn,Cpn]=fdcovpzp(zv,stdz,pv,stdp,rzp,g,stdg);
          subplot(122),plotelpz(pvectn,Cpn,10,[-6,2,-4,4]*1e5,'nomsg')
        else
          [zpkdata,rzp,dps]=stdpz('inpchmod(inpchans)');
          [pvectn,Cpn]=fdcovpzp(zpkdata.zv,zpkdata.stdz,zpkdata.pv,zpkdata.stdp,...
            rzp,zpkdata.g,zpkdata.stdg);
          subplot(121)
          plotelpz('inpchmod(inpchans)',NaN,10,[-6,2,-4,4]*1e5,'nomsg')
          subplot(122),plotelpz(pvectn,Cpn,10,[-6,2,-4,4]*1e5,'nomsg')
        end
        drawnow
%FNAMANAL
        fnam='inpchan'; [fnam,fnshort,ext]=fnamanal(fnam,'fbn');
        fnam='inpchan'; [fnam,fnshort,ext]=fnamanal(fnam,'mat');
%GMEAN
        x=-ones(100,2)+0.1*randn(100,2)+j*0.01*randn(100,2);
        mx=gmean(x), mfalse1=prod(x).^(1/100), mfalse2=prod(x.^(1/100))
%LIN2QLOG,LOG2QLOG
        fqlog=lin2qlog([1:128],sqrt(2));
        [fqlog,df]=log2qlog(logspace(log10(1),log10(256),17),256);
%LOADASC
        fid=fopen('lasctest.txt','w');
        fprintf(fid,'%.0f %%N\n%.4e, %.4e %%amp1\n',1,5,6)
        fclose(fid)
        type lasctest.txt, v3=loadasc('lasctest.txt')
        delete lasctest.txt
%LOADVAR,SAVEVAR
        if exist('inpchans.ebn')
          itlimit=loadvar('inpchans.ebn','itmax');
        else
          model=loadvar('inpchmod','inpchanz');
        end
        %
        x=1; save savevtst.mat x
        savevar('savevtst.mat','x',10)
        savevar('savevtst.mat','y',20)
        delete savevtst.mat
%MLBS
        bitseries=mlbs(10);
%MODIFYFV
        if exist('inpchanz.pbn')
          Fdatm=modifyfv('inpchanz.pbn','inpchan.fbn');
        else
          Fdatm=modifyfv('inpchmod(inpchanz)','inpchan');
        end
%MSINCLIP
        %random start phases:
        cx=msinclip(4:15,ones(1,12).*exp(j*2*pi*rand(1,12)));
        %Schroeder multisine:
        [cx,crx]=msinclip([1:15]',[],[],'',0);
        %ZOH design:
        cx=msinclip([0.2:0.01:0.4]',ones(21,1)/sqrt(42),[],'ZOHd',250,1,100);
        %
        [cx,crestx]=msinclip([1:15]'/256,ones(15,1));
        %
        if exist('corrtest.m')
          [cxobj,crestx]=msinclip(fiddata([],[],[1:15]'/256));
          %Random starting phases:
          cxobj2=msinclip(fiddata([],ones(12,1).*exp(j*2*pi*rand(12,1)),4:15));
          %ZOH design:
          cxobj2=msinclip(fiddata([],ones(21,1)/sqrt(42),[0.2:0.01:0.4]),...
             struct('crestmode','ZOH','N',100));
          %
          [cxobj,crestx]=msinclip(fiddata([],[],[1:15]'/256));
          %Schroeder starting phases:
          cxobj=msinclip(fiddata([],ones(12,1),4:15),struct('initset','Schroeder'));
          %ZOH design:
          cxobj=msinclip(fiddata([],ones(21,1)/sqrt(42),[0.2:0.01:0.4]),...
            struct('crestmode','ZOH','N',100));
          %Optimize input channel data:
          load inpchan, inpchan.output=[]; msinclip(inpchan,struct('itno',3));
        end
%MSINPREP
        arbitgen=msinprep([1:15]'/256,cx,512,1,'DAC');
        %
        if exist('corrtest.m')
          arbitgen=msinprep(cxobj,512,1);
        end
%OPTEXCIT
        if exist('inpchans.pbn')
          X=optexcit('inpchans.pbn',[1:50]/50*3e4);
        else
          X=optexcit('inpchmod(inpchans)');
        end
        %see further: optexdem
%PAIRS
        indab=pairs(roots([1,2,3,4]),roots([1.01,2,3,4]),2);
        pind=pairs([-0.1-1.5*j,-0.1+1.5*j],roots([1,2,3,4]));
%PLOTELPZ
        if exist('inpchans.pbn')
          clf, plotelpz('inpchanz.pbn');
          [rnum,rdenom]=plotelpz('inpchans.pbn','inpchans.cbn');
        else
          clf, plotelpz('inpchmod(inpchanz)');
          plotelpz('inpchmod(inpchans)',NaN);
        end
%PLOTELTF
        if exist('inpchans.pbn')
          ploteltf('inpchans.pbn','','inpchan.fbn','linF','full+');
          [ha1,ha2,fsc]=ploteltf(exppar('z',[1.1,1],[4,3,2,1],0,1));
        else
          ploteltf('inpchmod(inpchans)','','inpchan','linF','full+');
        end
        [ha1,ha2,fsc]=ploteltf(exppar('z',[1.1,1],[4,3,2,1],0,1));
%RDUEELIS
        if exist('inpchans.pbn')
          [rx,ry,rymxm,vymxm]=rdueelis('inpchans.pbn','inpchans.cbn',...
            'inpchan.fbn',[9.61e-10,9.61e-12]);
        else
          rdat=rdueelis('inpchmod(inpchans)');
        end
%SIMFOU
        if exist('inpchans.pbn')
          [x,y]=simfou('inpchans.pbn',400*[1:49],[],1e-9*[1,1]);
        else
          load inpchold
          [x,y]=simfou(pvect,400*[1:49],[],1e-9*[1,1]);
          simdata=simfou('inpchmod(inpchans)',...
            fiddata(NaN*ones(49,1),ones(49,1),400*[1:49],1e-9,1e-9));
          sf=simfou('bandpmod(bkfit)',[],10);
          load inpchan
          sf2=simfou(inpchan,{10;2}*inpchan); %add large noise
          %
        end
        freqv=[100:50:1000]';
        num=1; denom=[1e-6,1e-3,1];
        pdat=exppar('s',num,denom);
        vdat=[0.01,0.001];
        [x,y]=simfou(pdat,freqv,[],vdat);
        ploteltf(pdat,'',[freqv,x,y])
        for k=1:5
          [x,y]=simfou(pdat,freqv,[],vdat);
          Fdat=[freqv,x,y];
          [pvect,fit,Cp]=elis(Fdat,vdat,['s',0,2],[],'',100);
          pause
        end
%SIMTIME
        f=400*[1:49];u=msinprep(f,msinclip(f,[],[],'',0),256,51200);
        if exist('inpchanz.pbn')
          [x,y]=simtime('inpchanz.pbn',u,3e-5,1,3e-5,1);
          [xtr,ytr]=simtime('inpchanz.pbn',u,3e-5,1,3e-5,1,'transient');
        else
          [x,y]=simtime('inpchmod(inpchanz)',u,3e-5,1,3e-5,1);
          [xtr,ytr]=simtime('inpchmod(inpchanz)',u,3e-5,1,3e-5,1,'transient');
        end
%STDPZ
        if exist('inpchans.ebn')
          [pvect,fit,Cp]=elis('inpchans.ebn');
          [zv,stdz,pv,stdp,g,stdg,rzp]=stdpz(pvect,Cp);
        else
          [pvect,fit,Cp]=elis('inpchan',[],['s',11,12]);
          zpkdata=stdpz(pvect);
        end
%STDTF
        %[pvect,fit,Cp]=elis('inpchan',[],['s',11,12]); %see above
        [tf,stda,stdph,stdri,rtf]=stdtf([400:400:19600],pvect,Cp);
%STDTFM
        if exist('emachine.fbn')
          [tfm,stdAm,stdphm]=stdtfm('emachine.fbn','emachine.vbn');
        else
          stddat=stdtfm('emachine(emachine)');
        end
%TIM2FOU
        Fdat=tim2fou([[0:63]',cos([0:63]'/64*2*pi*3)]);
%VARANAL
        if exist('bandpass.fbn')
          [vx,vy,cxy,mx,my]=varanal('bandpass.fbn',[1:6],'delayed');
        else
          load bandpass, bp6=bandpass{:,1:6};
          avdata=varanal(bp6,'delayed');
          avdata=varanal('bandpass(bandpass_synch)');
        end
%YESINPUT
        order=yesinput('Order of the filter',10,[0,12]);
        color=yesinput('Color to be used on the plot','red','red|blue|green');
%YWALK
        %hywalkts (invoked in fdtest)
%
%Manual, Tutorial, Section 3.1, Fig. 3.1
        clf, hold off, iterctrl
        f=[0:0.01:1];
        plot(f,sin(pi*f+eps*1e-100)./(pi*f+eps*1e-100),'-',...
                [0,0.5,0.5],sin(pi/2)/(pi/2)*[1,1,0],':')
        title('Transfer function of a zero-order hold'), grid off
        graphnumber=grapause('hfdexamp',graphnumber,testsavegraphst);
%Manual, Tutorial, Section 4.2, Fig. 4.1, leakage
        clf, hold off, iterctrl
        echo on
        N=100; t=[0:N-1]; %N=100 points
        xt=sin(2*pi*10/N*t)+0.5*sin(2*pi*20/(N-1)*t); %sum of two sine waves
        Xfa=abs(fft(xt)); %spectrum
        Xsh=[zeros(1,N);Xfa;zeros(1,N)]; Xsh=[0;Xsh(:);0]; %prep for "bar" plot
        tsh=[t;t;t]/N; tsh=[0;tsh(:);1]; plot(tsh,Xsh)
        echo off
        title('Illustration of leakage'), grid off
        graphnumber=grapause('hfdexamp',graphnumber,testsavegraphst);
        clear t xt Xfa Xsh tsh
%Manual, Tutorial, Section 6.5, Fig. 6.1
        %hywalkts
%
%Manual, Tutorial, Section 8.
        %rarmdemo
%
%Manual, Reference, illustrations of individual commands
%dibs
        %see fdflyern=3; hfdflyer
        %dibsno=3; dibsi='n'; dibsdemo
%elis
        %see fdflyern=1; hfdflyer
        %if exist('inpchans.ebn'), elis('inpchans.ebn'); end
        %elis('inpchan',[],['s',11,12]);
%msinclip
        msinclip(0.2:0.01:0.4,ones(1,21)/sqrt(2*21),[],'graph100',300);
        msinclip(0.2:0.01:0.4,ones(1,21)/sqrt(2*21),[],'graph100ZOHd',300,1.24);
%optexcit
        %optexde1 %interrupt after first plot
        %h=get(gcf,'Children'); delete(h(1)) %delete 'Press a key...'
%plotelpz
        %see fdflyern=4; hfdflyer
        %domain='z'; pzdemo
%ploteltf
        %domain='s'; tfdemo
%
%Manual, Appendix
        %plotfou %type file name at prompt
        %plotcabl %type serial number of experiment at prompt
        %plotvar %type file name at prompt
        %plotrarm %plot robotarm data
%
rand('seed',0), randn('seed',0)
%
clear ans bitser ampopt xp yp Xsh xt yt N f vx vy cxy x y xtr ytr order color
clear coeffcovar pvect fit Cp zv stdz pv stdp rzp
clear rppar fixp rpalg rppl initp prfs num denom delay fs theta
clear Cpn Fdat Fdatm Fvect X arbitgen bits0 bitseries coeffcov crestx crx
clear cx data df domain expno ext fixpind fnam fnshort fqlog freqv
clear ext fsc g ha1 ha2 indab itlimit k mfalse1 mfalse2 mx my pdat pind pvectn
clear rnum rdenom rx ry rymxm stdAm stdg stdphm tfm timevect txth u v3 varx
clear vdat vymxm tf stda stdph stdri rtf vary freqvect
clear emachine
%
%End of hfdexamp
