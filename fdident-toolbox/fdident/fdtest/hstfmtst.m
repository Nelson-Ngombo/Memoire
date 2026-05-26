%HSTTFMTS Test stdtfm

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
echo off
rand('seed',0), randn('seed',0)
%
echo on
%Check stdtfm
%
%Simplest cases
%y=H*x, var(tf)=vy+vx*abs(H)^2-2*real(cxy*conj(H)), cxy=E{conj(x)*y}
vx=ones(10,1);
H=0.01*(ones(10,1)+j*[0:9]');
vy=vx.*abs(H).^2;
cxy=vx.*H;
x=ones(10,1);
[tfm,stdAm,stdphm]=stdtfm([[1:10]',x,H],[vy,vx,cxy]);
echo off
if any(abs(tfm-H)>10*eps)
  error('false tfm values from stdtfm')
end
if any(abs(stdAm)>10*sqrt(eps))|any(abs(stdphm)>10*sqrt(eps))
  error('false std values from stdtfm')
end
echo on
[tfm,stdAm,stdphm]=stdtfm([[1:10]',x,H],[vy,zeros(10,1)]);
echo off
if any(abs(stdAm-sqrt(vy)./abs(x))>10*sqrt(eps))
  error('false stdAm values from stdtfm')
end
disp('stdtfm seems to be OK')
clear x H vx vy cxy tfm stdAm stdphm
rand('seed',0), randn('seed',0)
%%%%% End of stdtfmts %%%%%%%
