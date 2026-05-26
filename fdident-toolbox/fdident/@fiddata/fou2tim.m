function tdat=fou2tim(Fdat,N,fs,scaling)
%FOU2TIM Convert frequency domain data to time domain for checks.
%
%       tdat=fou2tim(Fdat,N,fs,scaling)
%
%       Input arguments:
%       Fdat = fequency domain data object
%       optional arguments:
%       N = number of the time samples
%       fs = sampling frequency
%       scaling = 'fft' for scaling with the usual ifft scaling (1/N),
%                 'coeff' for no scaling (Fourier coefficients)
%
%       Output argument:
%       tdat = time domain data object
%
%       See also: TIM2FOU.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 21-Feb-2001

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,4); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,4,ni)), %earlier
end
if nargin<2, N=[]; end, if isempty(N), N=[]; end
if isstr(N), error('N is a string'), end
if length(N)>1, error('N is a vector'), end
if nargin<3, fs=[]; end, if isempty(fs), fs=[]; end
if isstr(fs), error('fs is a string'), end
if length(fs)>1, error('fs is a vector'), end
if nargin<4, scaling=''; end
inp=get(Fdat,'input'); if ~iscell(inp), inp={inp}; end
outp=get(Fdat,'output'); if ~iscell(outp), outp={outp}; end
inpf=get(Fdat,'inputfreqpoints');
if ~iscell(inpf), inpf={inpf}; end
outpf=get(Fdat,'outputfreqpoints');
if ~iscell(outpf), outpf={outpf}; end
fv=get(Fdat,'allfreqpoints');
df=dfcalc(Fdat,6);
if df<max(fv)/0.5e5, df=max(fv)/0.5e5; end %if dfcalc fails
Nmin=round(max(fv)/df+1)*2;
if ~isempty(N)&(N<Nmin), error('Given N is too small to properly sample data'), end
Nmin=max(Nmin,1024); %A reasonable assumption
if isempty(N), N=pow2(nextpow2(Nmin)); end
fsd=get(Fdat,'fs');
if ~isempty(fsd)
  if isempty(fs), fs=fsd; end
  if ~isequal(fsd,fs)
    warning(sprintf('fs deviates from the sampling frequency given in the data: %.4g ~= %.4g',fs,fsd))
  end
else
  if isempty(fs), fs=N*df; end
end
if fs<max(fv+df)*2, error('Sampling frequency is not sufficient'), end
if strncmp(scaling,'coeff',5)
  sc=N;
elseif isempty(scaling)|strcmpi(scaling,'fft')|strcmpi(scaling,'ifft')
  sc=1;
end
%
df=fs/N;
inpt=cell(size(inp));
for ii=1:prod(size(inp))
  data=inp{ii};
  if size(inpf,2)==1, fii=1; else fii=ii; end
  fv=inpf{fii};
  ind=round(fv/df)+1;
  X=zeros(N,1);
  X(ind)=data;
  xt=sc*2*real(ifft(X));
  inpt{ii}=xt;
end %for ii
if length(inpt)==1, inpt=inpt{1}; end
%
outpt=cell(size(outp));
for ii=1:prod(size(outp))
  data=outp{ii};
  if size(outpf,2)==1, fii=1; else fii=ii; end
  fv=outpf{fii};
  ind=round(fv/df)+1;
  X=zeros(N,1);
  X(ind)=data;
  xt=sc*2*real(ifft(X));
  outpt{ii}=xt;
end %for ii
if length(outpt)==1, outpt=outpt{1}; end
%
tdat=tiddata(outpt,inpt,1/fs);
set(tdat,'inputname',get(Fdat,'inputname'),...
  'outputname',get(Fdat,'outputname'),'noconsistency')
set(tdat,'frequencies',get(Fdat,'freqpoints'))
%%%%%%%%%%%%%%%%%%%%%%%% end of fou2tim %%%%%%%%%%%%%%%%%%%%%%%%