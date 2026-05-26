function [fqlog,df,cdmax,freqind]=log2qlog(freqv,mhno,df0)
%LOG2QLOG Quasilogarithmic approximation of a logarithmic set of points.
%
%       [fqlog,df,cdmax,freqind]=LOG2QLOG(freqv,mhno,df0)
%
%       The routine starts from the given, supposedly logarithmic frequency set
%       freqv, and rounds these frequencies to values of the linear (DFT)
%       frequency grid. The harmonic number mhno will be associated to the
%       highest frequency. If df0 is given, the frequency vector will be scaled
%       to make the maximum frequency equal to mhno*df0.
%
%       Algorithm: the points of fqlog will be the points of the grid
%       max(freqv)*[1:mhno]/mhno,  closest to any of the points of freqv.
%
%       Output arguments:
%       fqlog = quasi-log frequency vector (column vector)
%       df = (optional) minimum common divider of the values in freqv
%           The harmonic numbers in fqlog can be calculated as
%           harmno=round(fqlog/df);
%       cdmax = maximum common divider of the harmonic numbers
%       freqind = (optional) column vector, indices of the selected
%           frequency points in freqv
%
%       Input arguments:
%       freqv = logarithmic frequency vector
%           (the algorithm works also for non-logarithmic inputs)
%       mhno = maximum harmonic number (harmonic number of the highest
%           frequency).
%       df0 = frequency steps in the FFT grid (optional).
%           df0 is typically given as fs/N, with N being the FFT point length,
%           and fs the sampling frequency.
%
%       Usage: [fqlog,df,cdmax,freqind]=log2qlog(freqv,mhno,df0);
%       Example: [fqlog,df]=log2qlog(logspace(log10(1),log10(256),17),256);
%
%       See also: LIN2QLOG, LOGSPACE.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2000

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
if min(size(freqv))>1, error('freqv is not a vector'), end
freqv=freqv(:); %column vector
if any(imag(freqv)), error('freqv is complex'), end
if any(freqv<0), error('freqv contains negative elements'), end
if any(diff(freqv)<=0), error('freqv is not strictly increasing'), end
if length(mhno)~=1, error('mhno is not a scalar'), end
if mhno<=0, error('mhno is not positive'), end
if rem(mhno,1)~=0, error('mhno is not an integer'), end
if nargin<3, df0=[]; end, if isempty(df0), df0=max(freqv)/mhno; end
if length(df0)~=1, error('df0 is not a scalar'), end
if ~isfinite(df0), error('df0 is not finite'), end
if imag(df0)~=0, error('df0 is complex'), end
if df0<=0, error('df0 is not positive'), end
if abs(df0*mhno-max(freqv))>0.1*max(freqv)
  error(sprintf(['mhno*df0 = %.4g differs significantly from ',...
        'max(freqv) = %.4g'],mhno*df0,max(freqv) ))
else %rescale frequency vector
  freqv=freqv/max(freqv)*mhno*df0;
end
%
df=max(freqv)/mhno;
fqlog=df*round(freqv/df);
if abs(df-round(df))<eps, fqlog=round(fqlog); end
ind=find((fqlog==0)|(diff([fqlog;-1])==0));
fqlog(ind)=[];
freqind=[1:length(freqv)]'; freqind(ind)=[];
cdmax=1;
harmno=round(fqlog/df); if harmno(1)==0, harmno(1)=[]; end
for ind=2:min(harmno), if all(rem(harmno,ind)==0), cdmax=ind; end, end
%%%%%%%%%%%%%%%%%%%%%%%% end of log2qlog %%%%%%%%%%%%%%%%%%%%%%%%
