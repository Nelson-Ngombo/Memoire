%MSPRDEMO Demonstration of msinprep

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
graphnumber=0;
echo on, clc
%We shall take an optimized multisine (lines 1-15, uniform amplitudes),
%and demonstrate the effect of zero-order hold precompensation.
%This effect will be significant only if the highest frequency is close
%to the half of the data output rate of the DAC.
%Settings for this demonstration:  fv=[1:15],  dt=1/32.
%
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
load crestmin.mat, cx=cxvect15; fv=[1:15]'; df=1;
N=32; dt=1/N*df;
tf=exp(-j*pi*fv*dt).*sin(pi*fv*dt)./(pi*fv*dt);
msinclip(fv,cx,tf,'',0,N/32); %resol=N/32
graphnumber=grapause('msprdemo',graphnumber,demosavegraphst);
echo on, clc
%With this resolution the crest factor cannot be evaluated.
%Significant oversampling is required.
%
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
msinclip(fv,cx,tf,'',0,32);
graphnumber=grapause('msprdemo',graphnumber,demosavegraphst);
%
echo off
clc
disp('The differences of the peak amplitudes and also of the crest factors')
disp('are not too large: about 11%, which is not worth of much ado.')
fprintf('Press any key to continue ...'), pause, disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of msprdemo %%%%%%%%%%%%%%%%%%%%%%%%
