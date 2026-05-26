%FIDDATA_EXAMPLES

%SISO, one experiment:
fobj1=fiddata(2*ones(5,1),ones(5,1),[1:5]');
set(fobj1,'name','mydata')

%7 experiments:
yarr=5+randn(15,7); uarr=3+randn(15,7); u=ones(15,1);
fobj=fiddata(num2cell(yarr,1),num2cell(uarr,1),[1:15]'); %'Regular' multiexperiment call
fobjsame=fiddata(num2cell(yarr,1),u,[1:15]'); %Same excitation in each experiment 
fobj.synchronization='on'; %Average without extra synchronization
get(fobj)

%Combine one-experiment objects to several experiments:
fobj2=fiddata(3*ones(5,1),ones(5,1),[1:5]');
ff=merge(fobj1,fobj2,fobj1);
ff.synchronization='on'; %Average without extra synchronization

%Subsample experiment
fobjsampled=fobj([1:2:15])

%Separate object into input and output
fobj
inpobj=fobj{2,:}; %second channel
outpobj=fobj{1,:}; %first channel
%or 
inpobj2=fobj(:,[],1); %first input channel
outpobj2=fobj(:,1,[]); %first output channel

%Recombine
fobjcomb=addchannels(outpobj,inpobj);
fobjcomb2=addchannels(outpobj2,inpobj2);
fobjcomb2.date=fobjcomb.date; %Make sure date is not different
if fobjcomb~=fobjcomb2, diff(fobjcomb,fobjcomb2), error('Objects differ'), end

%Nonlinear experiments with random excitation phases
yarr=5+randn(15,7); uarr=3*exp(j*2*pi*rand(15,7)); uref=uarr; uarr=uarr+randn(15,7);
fobj=fiddata(num2cell(yarr,1),num2cell(uarr,1),[1:15]'); %'Regular' multiexperiment call
fobj.reference=num2cell(uref,1); %reference signal for experiment synchronization
get(fobj)
