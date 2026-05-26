function fddemutl(param,varargin)
%FDDEMUTL Utilities which perform special demo actions for the recorder 
%
%   Lehetne inkabb GUIRECRD belso parancs??
%       Possibilities for param:
%       'elis_rtimes_cams' - display string with elis run times
%            (call only if CAMS is just finished, otherwise returns empty)
%       'R_est_compare' - show results of resistance measurement (history
%            file 'ruidemo.mat')
%       'makefdata'
%       'addsiglab'
%       'notchplot'
%       'deletehelpwindow'
%
%       See also: GUIRECRD.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Witten by I. Kollar
%       Last modified: 02-Sep-2002, IK

if strcmp(param,'elis_rtimes_cams') %elis run times
  Me='aided_main';
  models=guidtard(Me, 'FINAL_DATA');
  out={}; t=[];
  for ii=1:length(models) %collect all times
    m=models{ii};
    f=m.fitinfo;
    if isstruct(f)
      t(ii,1)=f.runtime; %times in seconds
    else
      warning('Old form of fitinfo found')
      t(ii,1)=f(18); %times in seconds
    end
  end %for ii
  med=median(t);
  for ii=1:length(models)
    m=models{ii};
    f=m.fitinfo;
    if isstruct(f)
      runtime=f.runtime; %times in seconds
    else
      runtime=f(18); %times in seconds
    end
    if runtime>3*med, str=', probable overmodeling';
    else str='';
    end
    out{ii,1}=[sprintf('  model %.0f/%.0f: %.2f min',...
      length(m.num)-1,length(m.denom)-1,runtime/60),str];
  end %for ii
  if isempty(out), error('no model found')
  else
    lo=length(out);
    out=[{'Extreme long iterations usually mean overmodeling. On this computer:'};...
        out;{'';'Press PLAY to continue...'}];
  end
  
  st=dbstack; caller='recorder';
  if length(st)<2, caller='';
  elseif ~any(findstr(lower(st(2).name),'guirecrd.m')), caller='';
  end
  if strcmp(caller,'recorder')
    guirecrd('SetInfoField',out);
  else %test branch
    disp(out)
  end
  
elseif strcmp(param,'R_est_compare') %average and elis results for R
   ccvect=[1;-1;0];
   pv_prop=varargin{1};
   pv_nprop=varargin{2};
   pv_ref=varargin{3};
   vp=pv_prop.covariance; Ip=pv_prop.denom; Up=pv_prop.num;
   %stdRp=sqrt(vp(1,2))/abs(Ip)+sqrt(vp(2,2))*abs(Up)/Ip^2;
   stdRp=sqrt(ccvect'*vp*ccvect);
   vnp=pv_nprop.covariance; Inp=pv_nprop.denom; Unp=pv_nprop.num;
   %stdRnp=sqrt(vnp(1,1))/abs(Inp)+sqrt(vnp(2,2))*abs(Unp)/Inp^2;
   stdRnp=sqrt(ccvect'*vnp*ccvect);
   out=sprintf([...
       'The proper identification procedure shows a somewhat smaller standard deviation in this case: \n',...
       '  R_nominal   = %.5g\n',...
       '  R_proper    = %.5g,  std ~ %.3g\n',...
       '  R_improper = %.5g,  std ~ %.3g'],...
     pv_ref.output/pv_ref.input,Up/Ip,stdRp,Unp/Inp,stdRnp);
   st=dbstack; caller='recorder';
   if length(st)<2, caller='';
   elseif ~any(findstr(lower(st(2).name),'guirecrd.m')), caller='';
   end
   if strcmp(caller,'recorder')
      guirecrd('SetInfoField',out);
      %disp(out)
   else %test branch
      disp(out)
   end
  
elseif strcmp(param,'makefdata')
   f=[1:5]'; u=ones(5,1); y=cos(2*pi*f/30);
   fdat=fiddata(y,u,f,1e-3,1e-3);
   fdat.inputvariance=1e-3;
   fdat.outputvariance=1e-3;
   assignin('base','fdat',fdat)
   
elseif strcmp(param,'makefrfdata')
  F=20; freqv1=[1:F]'/F*1e3; %frequency vector (NOT radian frequencies), 1/20 kHz steps 
  jomega=j*2*pi*freqv1; K=2e-4; %Time constant in seconds
  tf1=1./(1+jomega*K); %Complex amplitudes, 1st order system
  %
  %Here are a few examples how to deal with the vectors:
  tf_mag=abs(tf1); %Magnitude vector
  FRF=tf_mag;
  gain1=20*log10(tf_mag); %This would be the magnitude in decibels
  tf_phase=angle(tf1); %Phase, radians
  phase1=tf_phase/(2*pi)*360; %this would be the phase in degrees
  U=ones(size(tf_mag)); %the input amplitudes are all equal to one with zero phase
  Y=tf_mag.*exp(j*tf_phase); %Complex output Fourier amplitudes
  %or, starting from dB-degrees data:
  %Y=10.^(tf_mag_dB/20).*exp(j*tf_phase_degrees/360*2*pi);
  assignin('base','gain1',gain1)
  assignin('base','phase1',phase1)
  assignin('base','freqv1',freqv1)
  assignin('base','frf',FRF)
 
elseif strcmp(param,'maketdata')
  %Preparations
  t=[1:500]/5e4; au=[1;0.7;0.5]; ay=[0.7;0.3;0.4];
  u=sin(2*pi*[100;200;300]*t)'*au+0.04*randn(500,1);
  y=sin(2*pi*[100;200;300]*t)'*ay+0.3*randn(500,1);
  %Create object
  tdat=tiddata(y,u,1/5e4); %output, input, sampling time
  tdat.inputname='Force'; tdat.outputname='Displacement';
  errorcatch
  figure(1), drawnow
  plot(tdat)
  errorcatch
  assignin('base','tdat',tdat)
  
elseif strcmp(param,'addsiglab')
  if ~exist('siglab')&exist('addsiglab')
    addsiglab('-end')
  end
  
elseif strcmp(param,'notchplot')
  if nargin>1, typ=varargin{1}; else typ='pcx'; end
  if strcmp(typ,'pcx'), hi=imread('notch.mat','pcx');
  elseif strcmp(typ,'jpg'), hi=imread('notch.jpg','jpeg');
  elseif strcmp(typ,'bmp'), hi=imread('notch.bmp','bmp');
  else error(['typ is invalid:''',typ,''''])
  end
  hfig=1; figure(1);
  delete(allchild(hfig))
  h=image(hi);, shg
  set(h,'cdatam','scaled')
  set(gca,'xtick',[],'ytick',[])
  set(gca,'position',[0 0 1 1])
  p=get(hfig,'position');
  p(1)=0; 
  if p(3)>400
    p(3)=440; p(4)=300;
    ps=get(0,'screensize');
    if ps(4)>p(4), p(2)=ps(4)-p(4); end
  end
  set(hfig,'position',p)
  set(gca,'clim',[0.8,1.4])
  
elseif strcmp(param,'deletehelpwindow')
  h=findall(0,'type','figure','tag','MiniHelPFigurE');
  if ~isempty(h), delete(h), end
  
elseif strcmp(param,'compinp')
  if isempty('varargin'), error('varargin is empty'), end
  if ~isstr(varargin{1}), error('varargin{1} is not a string'), end
  fdtool
  %guirecrd('init', 'demo')
  if strcmp(varargin{1},'time')
    guirecrd('LoadHist','compdemo_time.mat')
  elseif strncmp(varargin{1},'freq',4)
    guirecrd('LoadHist','compdemo_freq.mat')
  elseif strcmp(varargin{1},'FRF')
    guirecrd('LoadHist','composefrf.mat')
  else 
    error('Invalid varargin')
  end
  
elseif strcmp(param,'mkd')
  %MKD  Make short robotarm data for testing
  clear
  tmp=load('robotarm.mat');
  d5=resample(tmp.robotarm_rawdata(1:4.7*4096),8);
  assignin('base','d5',d5);
  clear tmp
  assignin('base','d3',d5(1:3*512))
  d4=d5(1:4*512);
  assignin('base','d4',d4)
  d4nf=d4; d4nf.frequencies=[];
  assignin('base','d4nf',d4nf)
elseif strcmp(param,'mkopd')
  fsc=1000;
  poles=fsc*[[-.03+j,-.03-j],100*[-.003+j,-.003-j]];
  m=fidmodel('s',1e6,real(poly(poles))/fsc^4);
  fv=fsc*[.5:1:3,10:10:120]'/2/pi;
  f=fiddata(fv,ones(size(fv)),fv,1e-11,0.0001)
  assignin('base','d',simfou(m,f,1))
  %plot(m,d)
elseif strcmp(param,'nonlinnumbers')
  ha=findall(0, 'tag', 'caem_axes_axes(2)');
  hb=findall(ha,'type','line','tag','ploteltf bounds');
  hl=findall(ha,'type','line','marker','x');
  if ~isempty(hl)&~isempty(hb)
    disp(' ')
    Ntot=length(get(hl,'ydata'));
    Nabove95=length(find(get(hb(1),'ydata')<get(hl,'ydata')));
    Nabove50=length(find(get(hb(2),'ydata')<get(hl,'ydata')));
    disp(sprintf('Total number of points: %.0f',Ntot))
    disp(sprintf('Points above 95%% limit: %.0f',Nabove95))
    disp(sprintf('Points above 50%% limit: %.0f',Nabove50))
    if abs(Nabove50-0.5*Ntot)>0.2*0.5*Ntot
      error(sprintf('Deviation for 50%%, %.0f of %.0f is above %.1f%%',Nabove50,Ntot,0.2*0.5*100))
    end
    if abs(Nabove95-0.05*Ntot)>0.5*0.05*Ntot
      error(sprintf('Deviation for 95%%, %.0f of %.0f is above %.1f%%',Nabove95,Ntot,0.5*0.05*100))
    end
  else
    warning('Cannot find plot with error limits')
  end
else
  error(['Unknown param ''',param,''''])
end
%
%End of fddemutl
%End of file fddemutl
