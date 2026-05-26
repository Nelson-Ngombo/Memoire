%HELQTEST Test elisqa and yesinput

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Oct-2001

disp('File helqtest')
echo on
%Check elisqa and yesinput
%
%For the testing of elisqa and yesinput, the question/answer procedure has
%to be followed.
%You may always push Enter to accept the default answers.
%
elisqa('helqtest.ebn')
elrpf2v('helqtest.ebn');
%
num=[5,5]; denom=[4,3,2,1];
no=length(num)-1; nd=length(denom)-1;
pdat=exppar('z',num,denom,0,1);
freqv=[0.01:0.015:0.4]'; fl=length(freqv);
x0=ones(fl,1);
vdat=[1e-5,1e-5];
[x,y]=simfou(pdat,freqv,x0,vdat);
Fdat=[freqv,x,y];
[rppar,fixp,rpalg,rppl,initp,rpfs]=elrpf2v('helqtest.ebn');
rppar(1:4)=['z',no,nd,1];
fixp=[3,4;4,3;6,1];
rppl(1)=10;
initp=0.9;
rpfs=['helistst.par';'helistst.cbn';'helistst.rep'];
elrpv2f('',rppar,fixp,rpalg,rppl,initp,rpfs);
elrpv2f('elisqts2.ebn',rppar,fixp,rpalg,rppl,initp,rpfs);
elrpf2v('elisqts2.ebn');
elis(Fdat,'elisqts2.ebn');
delete helistst.par, delete helistst.cbn, delete helistst.rep
delete helqtest.ebn, delete elisqts2.ebn
echo off
%%%%% End of helqtest %%%%%%%
