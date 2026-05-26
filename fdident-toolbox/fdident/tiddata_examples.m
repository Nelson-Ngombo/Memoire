%TIDDATA_EXAMPLES

%SISO, one experiment:
tobj1=tiddata(2*randn(5,1),1*randn(5,1),0.001);

%7 experiments:
yarr=randn(15,7); uarr=randn(15,7); u=ones(15,1);
tobj=tiddata(num2cell(yarr,1),num2cell(uarr,1),0.1); %'Regular' multiexperiment call
tobjsame=tiddata(num2cell(yarr,1),u,0.1,'ZOH'); %ZOH data, same excitation
tobj.synchronization='on'; %Average without extra synchronization
tobj.periodlength=0.5; %set period length
get(tobj)

%Combine one-experiment objects to several experiments:
tobj2=tiddata(3*ones(5,1),ones(5,1),0.001);
tt=merge(tobj1,tobj2,tobj1);
tt.synchronization='on'; %Average without extra synchronization

%Subsample experiment
tobjsampled=tobj([1:2:15])

%Separate object into input and output
tobj
inpobj=tobj{2,:};  %second channel
outpobj=tobj{1,:}; %first channel
%or 
inpobj2=tobj(:,[],1); %first input channel
outpobj2=tobj(:,1,[]); %first output channel

%Recombine
tobjcomb=addchannels(outpobj,inpobj);
tobjcomb2=addchannels(outpobj2,inpobj2);
tobjcomb2.date=tobjcomb.date; %Make sure date is not different
if tobjcomb~=tobjcomb2, diff(tobjcomb,tobjcomb2), error('Objects differ'), end
