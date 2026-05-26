function num=svdsolve(vnum,Nf,mode);
%SVDSOLVE Solve Nf=vnum*num' for num using svd.
%
%       Input arguments: 
%         vnum: F x *nN array, real or complex
%         Nf: F x 1 array, real or complex
%         mode: mode of computation [optional]
%           'real' or 'complex', property of num, default: real.
%       Output argument:
%         num: column array

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2003

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,3,ni)), %earlier
end
if nargin<3, mode=''; end, if isempty(mode), mode='real'; end
if size(vnum,1)~=size(Nf,1), error('vnum and Nf are incompatible'), end
if strncmp(mode,'real',1)
  if any(any(imag(vnum)))|any(any(imag(Nf)))
    vnum=[real(vnum);imag(vnum)]; Nf=[real(Nf);imag(Nf)]; 
  end
end
F=size(vnum,1);
num=zeros(size(vnum,2),1);
[U,S,V]=svd(vnum,0);
Sv=diag(S); Sn=length(Sv); invSv=zeros(size(Sv));
ind=Sv>F*10*eps*Sv(1);
if length(ind)<Sn
  warning(sprintf('Singularity of order %.0f in svdsolve',Sn-length(ind)))
end
invSv(ind)=1./Sv(ind); invS=diag(invSv);
num=V*invS*U'*Nf;
%
num=num.'; %row vector
%End of svdsolve
