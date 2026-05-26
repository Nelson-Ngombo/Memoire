%HGMEANTS test gmean

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
clf, hold off
echo on
%Check gmean
%
jval=sqrt(-1);
phi=[0.7:0.05:1.1]*pi;
x=exp(jval*phi);
n=length(x);
correctm=exp(jval*mean(phi));
gmx=gmean(x)
gmxfalse=[ prod(x.^(1/n)) , prod(x)^(1/n) ]
echo off
if abs(gmx-correctm)>1e-10
  gmx
  correctm
  error('Gmean gives wrong result')
else
  fprintf('gmean gives correct result\n\n')
end
fprintf('Press a key to continue...'), pause, disp(' ')
clear phi x n gmx gmxfalse correctm jval
clear gmean
%%%%% End of hgmeants %%%%%%%
