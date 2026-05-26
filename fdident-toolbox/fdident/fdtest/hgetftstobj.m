function Fdat=hgetftstobj(i)
%HGETFTSTOBJ User-defined m-file for testing varanal

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Jan-2004

num=[5,5]; denom=[4,3,2,1];
pdat=fidmodel('z^-1',num,denom,0,1);
N=32;
freqv=[1:N/2-1]'/N; fl=length(freqv);
cx=ones(fl,1);
vdat=1e-4*[1,1];
expno=10;
Fdat=simfou(pdat,fiddata(zeros(size(cx)),cx,freqv,2*vdat(2),2*vdat(1)));
