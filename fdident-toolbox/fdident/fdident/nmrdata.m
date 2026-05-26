function dat = nmrdata(y,u,freqpoints,fs,vary,N,delay)
%NMRDATA Creation function for nuclear magnetic resonance (NMR) data.
%
%       Examples: nmrdata(y,u,freqpoints,fs,vary,N,delay);
%                 nmrdata(y,u,freqpoints,fs);
%
%       Arguments:
%       y - Output data (column vector, cell array or empty)
%       u - Input data (column vector, cell array or empty)
%       freqpoints - frequency points where amplitudes are given
%              (vector for SISO, cell array for ALL channels for MIMO)
%       vary - variances of outputs (cell array, or vector, or scalar if constant)
%       N - number of samples in the measurement
%       delay - the delay of the beginning oof measurement in samples
%
%       In order to obtain a detailed list of properties and possibilities,
%       type 'help(fiddata)','help(fiddata,<property>)', or 'helpc(fiddata)'

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 16-Jun-2001

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(5,20); %Matlab 2016a or later
else ni=nargin; error(nargchk(5,20,ni)), %earlier
end
%
dat=fiddata(y,u,freqpoints,vary,0,'frequencies','negative');
if nargin<6, N=[]; end
if ~isempty(N), set(dat,'N',N,'noconsistency'); end
if nargin<7, delay=[]; end
if ~isempty(delay), set(dat,'inputdelay',delay,'outputdelay',delay,'noconsistency'); end
set(dat,'fs',fs,'Type','NMR');
%
%end nmrdata.m
