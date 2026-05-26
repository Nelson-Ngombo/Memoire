%MSCLDEMO Demonstration of msinclip

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
if ~exist('textpause'), textpause=''; end %mode to show text in Command Window
graphnumber=0;
echo on, clc
%Let us minimize the crest factors of different signals.
%(Book, Subsection 4.2.2/3: Multisine)
%
%Possibilities:
%     0) Uniform lines 1-15, no optimization, fixed, zero phases
%     1) Uniform lines 1-15, no optimization, random phases
%     2) Uniform lines 1-15, no optimization, Schroeder multisine
%     3) Uniform lines 1-15, show already optimized result
%     4) Uniform lines 1-15
%     5) Uniform lines 1-255
%     6) Uniform lines 15-31
%     7) Linearly increasing lines 1-36
%     8) Logtone: 100 lines 20-511
%     9) Dual signal, uniform lines 16-63, integrator
%
echo off
if ~exist('mno'), mno=[]; end, if isempty(mno), mno=4; end
mno=rem(abs(mno),10);
mno=yesinput('Your choice',mno,[0,9]);
if mno~=3
  disp(' ')
  disp('There are three options for crest factor minimization:')
  disp('  Bandlimited multisine design (b)')
  disp('  Zero-order hold design for ZOH-identification (z)')
  disp('  Zero-order hold design for band-limited measurement (zb)')
  disp(['    For ''zb'', the amplitudes will be predistorted by the ',...
        'inverse of the ZOH tf.'])
  dtype=yesinput('Your choice','b','b|z|zb');
else
  dtype='b';
end
if strcmp(dtype,'b'), dtype=''; overs=[];
elseif strcmp(dtype,'z'), dtype='ZOHd'; overs=1;
elseif strcmp(dtype,'zb'), dtype='ZOHc'; overs=1;
end
N=100;
itno=50;
if mno==8, itno=10; end
if mno>3, itno=yesinput('Number of iterations',itno,[1,240]); end
if itno<5, dtype=[dtype,'graph']; end
if mno==0
  fv=[1:15]; fl=length(fv); ampv=(1+j*eps)*ones(1,fl); tf=[];
  [cx,crestx]=msinclip(fv,ampv,tf,dtype,0,overs,N);
elseif mno==1
  fv=[1:15]; fl=length(fv); ampv=exp(j*rand(1,fl)*2*pi).*ones(1,fl); tf=[];
  [cx,crestx]=msinclip(fv,ampv,tf,dtype,0,overs,N);
elseif mno==2
  fv=[1:15]; fl=length(fv); ampv=ones(1,fl); tf=[];
  [cx,crestx]=msinclip(fv,ampv,tf,dtype,0,overs,N);
elseif mno==3
  fv=[1:15]; fl=length(fv); load crestmin.mat, cx=cxvect15; tf=[];
  [cx,crestx]=msinclip(fv,cx,tf,dtype,0,64,N);
elseif mno==4
  fv=[1:15]; fl=length(fv); ampv=ones(1,fl); tf=[];
elseif mno==5
  fv=[1:255]; fl=length(fv); ampv=ones(1,fl); tf=[]; N=1024;
elseif mno==6
  fv=[15:31]; fl=length(fv); ampv=ones(1,fl); tf=[];
elseif mno==7
  fv=[1:36]; fl=length(fv); ampv=fv; tf=[];
elseif mno==8
  fv=lin2qlog([20:511],1.0333); fl=length(fv); ampv=ones(1,fl); tf=[]; N=2048;
elseif mno==9
  fv=[16:63]; fl=length(fv); ampv=0.2*ones(1,fl);
  tf=100*ones(1,fl)./(j*2*pi*fv);
  disp(' ')
  disp(['First the input signal alone will be optimized, then the',...
       ' input-output pair.']), disp(' ')
  fdidpaus(textpause)
  [ampv,crestx]=msinclip(fv,ampv,[],dtype,itno,overs,N);
  graphnumber=grapause('mscldemo',graphnumber,demosavegraphst);
else
  error('Wrong choice')
end
if (mno>3)&(mno~=8), [cx,crestx]=msinclip(fv,ampv,tf,dtype,itno,overs,N); end
if mno==8, [cx,crestx]=msinclip(fv,ampv,tf,['graph',dtype],itno,overs,N); end
mno=rem(mno+1,10);
%
graphnumber=grapause('mscldemo',graphnumber,demosavegraphst);
%%%%%%%%%%%%%%%%%%%%%%%% end of mscldemo %%%%%%%%%%%%%%%%%%%%%%%%
