function [freqv,x,y]=hgetftst(i)
%HGETFTST User-defined m-file for testing varanal

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Oct-2001

num=[5,5]; denom=[4,3,2,1];
pdat=exppar('z',num,denom,0,1);
N=32;
freqv=[1:N/2-1]'/N; fl=length(freqv);
cx=ones(fl,1);
vdat=1e-4*[1,1];
expno=10;
[x,y]=simfou(pdat,freqv,cx,vdat);
