%HCORTEST

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 14-Mar-1999

if exist('inpchmod.mat')
  pdats=load('inpchmod');
  pdat=pdats.inpchans;
else
  [dom,num,denom,delay,fs]=imppar('inpchans.pbn');
  pdat=exppar(dom,num,denom,delay,fs);
end
%cdat=NaN; Fdat='inpchan'; vdat=[9.61e-12,9.61e-10];
%[rx,ry,ryx,vryx]=rdueelis(pdat,cdat,Fdat,vdat); %old form
%CR=impcov(cdat,'nofixp'); Npar=size(CR,1);
%Res=ryx; stdComp=vryx; corrtest(ryx,vryx,Npar);

if isa(pdat,'fidmodel')
  rdat=rdueelis(pdat);
  Npar=size(pdat.covariance,1)-1;
  corrtest(pdat,Npar);
end

%End