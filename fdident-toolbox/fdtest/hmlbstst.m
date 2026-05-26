%HMLBSTST Test mlbs

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
clf, hold off
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
echo on
%Check mlbs
%
n=5;
x=mlbs(n);
[x1,nextstnum]=mlbs(n,2^(n-1));
x1=[x1;mlbs(n,2^(n-1)-1,nextstnum)];
if any(x-x1), error('Incorrect continuation in mlbs'), end
echo off
t1=0:2^n-2; t1=[t1;t1+1]; t1=t1(:);
x1=[x(:)';x(:)']; x1=x1(:);
clf, hold off
axis([-2^n/10,1.1*2^n,-1.1,1.1]);
plot(t1,x1)
axis([-2^n/10,1.1*2^n,-1.1,1.1]);
title(sprintf('Maximum length binary sequence, n=%.0f',n))
graphnumber=grapause('hmlbstst',graphnumber,testsavegraphst);
%
r=real(ifft(1/length(x)*abs(fft(x)).^2));
rid=[1;-1/(2^n-1)*ones(2^n-2,1)];
if all(abs(r-rid)<1e-10)
  fprintf('mlbs seems to be OK\n\n')
else
  plot(0:length(x)-1,r)
  error('incorrect value of autocorrelation function')
end
fprintf('Press a key to continue...'), pause, disp(' ')
clear t1 x1 r rid x n graphnumber
%%%%% End of hmlbstst %%%%%%%
