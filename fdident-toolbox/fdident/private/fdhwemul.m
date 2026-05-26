function [outdata,msg]=fdhwsim(Action,VIname,varargin)
%       System simulator
%
%       Simulate steady-state output of system, assuming repetitive 
%       excitation. The expected value of the input is generally NOT
%       equal with the excitation signal (because of the effect of the
%       actuator, etc). The input amplitude is hard-limited.
%
%        Input argument:
%          excit_signal = tiddata object of excitation signal (time sequence in
%              the property 'input')
%              fs=1/excit_signal.ts must be in the range [10 Hz, 51.2 kHz]
%
%        Output argument:
%          outdata = tiddata object of measured output signal
%
%       Usage: data = fdhwemul(excit_signal);
%
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 01-Dec-1999, IK

%Secret means to plot noiseless transfer function:
%'noise0' means noise-free (but nonlinear) simulation
%'clean' means nonlinearity-free data
global modifyemul
if ~exist('modifyemul'), modifyemul=''; end

if nargin==0, error('No input argument'), end
outdata=[]; msg=''; props=[];
Nmax=inf; %number of requested points
fmin=10; fmax=51.2e3; %frequency range

myname1='Emulated Data';
myname2='Emulated Data (freq. domain)';
myname={myname1,myname2};
myhwname='System emulator';

if strcmpi(Action,'Instruments')
  outdata=myname;
  return
elseif strcmpi(Action,'Hardware')
  outdata={myhwname};
  return
elseif strcmpi(Action,'Type')
  if nargin<2, error('No instrument given'), end
  if strcmp(VIname,myname1)
    outdata.domain='TIME';
  elseif strcmp(VIname,myname2)
    outdata.domain='FREQ';
  elseif strcmp(VIname,myhwname)
    outdata.domain='TIMEFREQ';
  end
  outdata.input='needed';
  outdata.tooltipstring='Simulated (noisy) system to identify';
  return
elseif strcmpi(Action,'hw_chk')
  outdata=-1; %Simulation info is already in the name
  return  
elseif strcmpi(Action,'isopen')
  outdata=0; msg=''; %Cannot stay open
  return
elseif strcmpi(Action,'close_all_instruments')
  outdata=0; msg=''; %Cannot stay open
  return
elseif strcmpi(Action,'information')
  msg='';
  txt1={'This is an emulator of a system for frequency domain';
    'system identification.'};
  txt2={'';
    ['The allowed range for excitation clock frequency is ',...
        '[',sprintf('%.4g',fmin),' Hz - ',sprintf('%.4g',fmax),' Hz].'];
    'The actuator has dynamics, thus measurement of the input signal is ';
    'necessary to eliminate its effects.';
    'Nonlinearity occurs for certain internal signal levels (this depends ';
    'on the frequency content), so limited excitation signal level is recommended.';
    ' ';
    'Presence of an excitation signal is required for operation.';
    ' ';
    'The emulator automatically returns the simulated data after ';
    'pressing ''Goto VI'', so the button ''Take data'' need not be used.'};
  if strcmp(VIname,myname1) %time domain
    txtl1={'Noise-contaminated time domain input-output data are returned.'};
    outdata={VIname,[txt1;txtl1;txt2]};
  elseif strcmp(VIname,myname2) %frequency domain
    txtl1={'Noise-contaminated frequency domain input-output data are returned.'};
    outdata={VIname,[txt1;txtl1;txt2]};
  else
    outdata=[]; msg='Instrument not found in fdhwemul';
  end
  return
elseif strcmpi(Action,'Measure')
  if strcmp(VIname,myname1)|strcmp(VIname,myname2)
    %Standard GUI call
    exdata=varargin{1};
    if nargin>=4, props=varargin{2}; end
  else
    outdata=[]; msg='Unknown instrument in fdhwemul'; return
  end
elseif strcmpi(Action,'Properties')
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(2,100); %Matlab 2016a or later
  else ni=nargin; error(nargchk(2,100,ni)), %earlier
  end   if nargin==2, msg='Property list not yet implemented'; return, end
  %nargin>2
  if ~isstr(varargin{1})
    msg='Property name is not a string'; return
  end
  lv=length(varargin);
  if lv==1 %return allowed values 
    msg='Property value returning not yet implemented';
    %eval(['outdata=',Action,';']) %return value
    return
  else %lv>1
    if rem(lv,2)==1, error('Odd number of elements in varargin'), end
    outdata=[]; recfilt=0; aafilt=0;
    for ii=1:2:length(varargin)-1
      prop=varargin{ii}; pval=varargin{ii+1};
      if ~isstr(prop)
        msg='Property name is not a string'; return
      end
      switch prop
      case 'A'
        if ~isnumeric(pval), error('Value of A is not numeric'), end
        outdata.A=abs(pval);
      case 'fe'
        if ~isnumeric(pval), error('Value of fe is not numeric'), end
        if length(pval)~=1, error('Value of fe is not a scalar'), end
        if ~isfinite(pval), error('Value of fe is not finite'), end
        pval=max(pval,fmin); pval=min(fmax,pval);
        outdata.fe=pval;
      case 'Ne'
        if ~isnumeric(pval), error('Value of Ne is not numeric'), end
        if length(pval)~=1, error('Value of Ne is not a scalar'), end
        if ~isfinite(pval), error('Value of Ne is not finite'), end
        outdata.Ne=min(Nmax,pval);
      case 'BWe'
        if ~isnumeric(pval), error('Value of BWe is not numeric'), end
        if length(pval)~=1, error('Value of BWe is not a scalar'), end
        if ~isfinite(pval), error('Value of BWe is not finite'), end
        outdata.BWe=pval;
      case 'fs'
        if ~isnumeric(pval), error('Value of fs is not numeric'), end
        if length(pval)~=1, error('Value of fs is not a scalar'), end
        if ~isfinite(pval), error('Value of fs is not finite'), end
        pval=max(pval,10); pval=min(51.2e3,pval);
        outdata.fs=pval;
      case 'Ns'
        if ~isnumeric(pval), error('Value of Ns is not numeric'), end
        if length(pval)~=1, error('Value of Ns is not a scalar'), end
        if ~isfinite(pval), error('Value of Ns is not finite'), end
        outdata.Ns=min(Nmax,pval);
      case 'reconstruction_filter'
        recfilt=1; %reconstruction filter property is set
        recfiltval=pval;
        if ~strcmp(recfiltval,'on')&~strcmp(recfiltval,'off')
          error(['reconstruction filter value ''',recfiltval,''' not allowed'])
        end
        outdata.reconstruction_filter=recfiltval;
      case 'antialias_filter'
        aafilt=1; %antialias filter property is set
        aafiltval=pval;
        if ~strcmp(aafiltval,'on')&~strcmp(aafiltval,'off')
          error(['Antialias filter value ''',aafiltval,''' not allowed'])
        end
        outdata.antialias_filter=aafiltval;
      case 'BWs'
        if ~isnumeric(pval), error('Value of BWs is not numeric'), end
        if length(pval)~=1, error('Value of BWs is not a scalar'), end
        if ~isfinite(pval), error('Value of BWs is not finite'), end
        outdata.BWs=pval;
      case 'expno'
        outdata.expno=pval;
      case 'repno'
        outdata.repno=pval;
      otherwise
        %error(['Unknown property ''',prop,''''])
        warning(['Property ''',prop,''' not yet handled in fdhwsigl'])
        outdata=setfield(outdata,prop,pval);
      end
    end %for ii
  end %lv=1
  return  
elseif strcmp(Action,'take_data')
  outdata=[];
  msg='Error: measurement emulator can only ''Measure'', does not stay open';
  return
elseif strcmp(Action,'close_all_instruments')
  outdata=[];
  msg='';
  return
else
  outdata=[];
  msg=['First argument ''',Action,''' is not implemented'];
  warning(msg)
  msg='';
  return
end

if ~isempty(exdata)
  ug=exdata.input;
  fs=1/exdata.ts;
  if isfield(props,'repno')
    for ii=2:props.repno, ug=[ug;exdata.input]; end
  end
  if isfield(props,'expno')
    if props.expno>1
      %outdata=[]; msg='Error: more than one experiment requested';
      %return
    end
    expno=props.expno;
  else
    expno=1;
  end
  if isfield(props,'delay')
    if isfinite(props.delay)
      outdata=[]; msg='Error: Finite delay is not yet implemented'; return
      %
      tags=props.delay*fs;
      if abs(rem(tags+0.5,1)-0.5)>0.001
        outdata=[]; msg='Error: Fractional number of tags in delay'; return
      end
      tags=round(tags);
      ind=[1:length(ug)];
      indm=rem(ind+tags-1,length(ug))+1;
      ug=ug(indm);
    elseif isnan(props.delay)
      outdata=[]; msg='Error: Delay is NaN'; return  
    end
  end
  if isfield(props,'character')
    if ~strcmp(props.character,'Periodic')
      outdata=[]; msg='Error: Application of input signal is not ''Periodic'''; return
    end
  end
else
  outdata=[]; msg='Error: no excitation signal is given'; return
end
%
%Maximum number of points:
%Nmax
if length(ug)>Nmax
  outdata=[];
  msg=sprintf('Error: More than %.0f samples are requested',Nmax);
  return
end
%
%Poles and zeros of system:
n1=-100+200*j;
nums=real(poly(2*pi*[n1,conj(n1)]));
p1=-120+250*j;
p3=-200;
denoms=real(poly(2*pi*[p3,p1,conj(p1)]));
%set dc gain to 1
nums=10*nums/nums(length(nums));
denoms=denoms/denoms(length(denoms));
%
nums0 = [ 5.0661e-006  6.3662e-003  1.0000e+001 ];
denoms0 = [ 2.6212e-010  7.2466e-007  1.2925e-003  1.0000e+000 ];
fs0 = 2048;
%sysc=tf(nums,denoms); sysd=c2d(sysc,1/fs); sysd.num{1}, sysd.den{1}
numz = [ 0  6.4244e+000 -7.6736e+000  3.4614e+000 ];
denomz = [ 1.0000e+000 -1.5379e+000  1.0184e+000 -2.5927e-001 ];
%
%set noise levels in time domain: standard deviations
sigmax=0.5;
sigmay=2;
%
% check fs
if nargin<2, error('not enough input arguments'), end
fmin=10; fmax=51.2e3;
if (fs>fmax*(1+1000*eps)) | (fs<fmin)
  outdata=[];
  msg=sprintf('fs=%.3g Hz is out of range [%.3g Hz,%.3g Hz]',fs,fmin,fmax);
  return
end

%define noise filters:
%Input noise
numni=sigmax;
denomni=1;
%Output noise is not white:
numno=[.9 .8 .6 .1]; denomno=1;
numno=sigmay*numno/norm(numno);
%
%Calculate filtered actuator output: not the same as desired one
pz1=1-pi/4;
numactz=1-pz1; denomactz=[1,-pz1];
Z=zeros(1,length(denomactz)-1);
for i=1:(1+ceil(pz1^length(ug)/0.0001)) %Wait until end of transients
  [ugact,Z]=filter(numactz,denomactz,ug,Z);
end
ugact=ugact(:);
%
%Hard limit maximum input value
magmax=20;
ind=find(abs(ugact)>magmax);
if length(ind)>0
  ugact(ind)=sign(ugact(ind))*magmax.*ones(size(ind));
end
%
%Introduce nonlinearity
ugactnl=nonlin(ugact);
%
%randomize random generator
randn('seed',100*pi*sum(clock));
%
for ii=1:expno
  %Calculate input and output:
  if ~strcmp(modifyemul,'noise0')&~strcmp(modifyemul,'clean') %regular case
    [um,ym]=simtime(exppar('s',nums,denoms),ugactnl,...
      numni,denomni,numno,denomno,'',fs);
    um=ugact+sigmax*randn(size(ugact)); %Nonlinearity is not measured
  elseif ~isempty(modifyemul), error(['Illegal modifyemul: ''',modifyemul,''''])
  elseif strcmp(modifyemul,'noise0')
    [um,ym]=simtime(exppar('s',nums,denoms),ugactnl,0,1,0,1,fs);
    um=ugact;
  elseif strcmp(modifyemul,'clean')
    [um,ym]=simtime(exppar('s',nums,denoms),ugact,0,1,0,1,fs);
    um=ugact;
  end
  %
  %Return output object
  outdatai=tiddata(ym,um,1/fs);
  outdatai.frequencies=exdata.frequencies;
  outdatai.periodlength=exdata.periodlength;
  if ii==1, outdata=outdatai;
  else outdata=[outdata,outdatai];
  end
  if (ii==expno)&(expno>1), outdata.synchronization='on'; end
end
if strcmp(VIname,myname2)
  pl=get(outdata,'periodlength');
  if ~isfinite(pl), pl=1/dfcalc(get(outdata,'frequencies')); end
  N=get(outdata,'samplen'); ts=get(outdata,'ts');
  if (expno==1)&isfinite(pl)&(pl<N*ts/2*(1-1000*eps))
    outdata=segment(outdata);
  end
  outdata=tim2fou(outdata,'','coeff');
end


function ugactnl=nonlin(ugact)
%
Amax=3;
ugactnl=ugact;
ind=find(abs(ugact)>Amax);
if ~isempty(ind)
  %lind=length(ind) %number of nonlinearly distorted points
  ugm=ugact(ind); lin=sign(ugm)*Amax;
  ugm=ugm-lin;
  C=Amax/2;
  ugm=C*asinh(ugm/C);
  ugactnl(ind)=ugm+lin;
end

%End of file
