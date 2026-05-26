function idobj = idarx(obj)
%IDARX  Convert fidmodel to idarx.
%

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 16-Apr-2000

if ~exist('@idarx/idarx.m')
  error('Cannot transform to idmodel object without @idarx directory')
end
%error('Conversion from fidmodel to idarx is not possible.')
warning('Conv from fidmodel to idarx with the equation error assumed to be white.')
idobjy=idpoly(obj);
F=idobjy.F; B=idobjy.B; Ts=idobjy.Ts;
%if Ts==0, error('Cannot transform s-domain models to idarx'), end
%
nF=length(idobjy.F); nB=length(idobjy.B);
F=reshape(F,1,1,nF);
B=reshape(B,1,1,nB);
idobj=idarx(F,B,Ts);
idobj.nk=idobjy.nk;
idobj.Name=idobjy.Name;
idobj.InputName=idobjy.InputName;
idobj.InputUnit=idobjy.InputUnit;
idobj.OutputName=idobjy.OutputName;
idobj.OutputUnit=idobjy.OutputUnit;
idobj.InputDelay=idobjy.InputDelay;
idobj.Algorithm=idobjy.Algorithm;
%idobj.EstimationInfo=idobjy.EstimationInfo;
idobj.Notes=idobjy.Notes;
idobj.nk=idobjy.nk;
idobj.nk=idobjy.nk;
cov=idobjy.CovarianceMatrix;
nC=length(cov);
if nC~=nF+nB-1
  error('Incorrect covariance matrix')
else
  cov=[cov(nB+[1:nF-1],nB+[1:nF-1]),cov(nB+[1:nF-1],1:nB);...
          cov(1:nB,nB+[1:nF-1]),cov(1:nB,1:nB)];
end
idobj.CovarianceMatrix=cov;
%End of idarx