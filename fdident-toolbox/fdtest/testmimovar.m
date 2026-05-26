%TESTMIMOVAR Test of MIMO variance handling
%
y={ones(5,1);ones(6,1)};
u=ones(5,1);
freqs={1:5;2:7;2:6};
f=fiddata(y,u,freqs)
%
vyset={ones(5,1);2*ones(6,1)};
f.outputvariance=vyset;
vyset=[{vyset{1}(1)};{vyset{2}(1)}]; %constant variances
vy=f.outputvariance
if ~isequal(vyset,vy), error('vy wrongly set'), end
fav=f.allvariances
f.inputvariance
get(f)
vuset=3+[0.1:0.1:0.5]';
f.inputvariance=vuset;
vu=f.inputvariance
if ~isequal(vuset,vu), error('vu wrongly set'), end
get(f)
f{2,1}.outputvariance=3;
vy=f.outputvariance
vyset=[vyset(1);{3}]; %constant variances
if ~isequal(vyset,vy), error('vy wrongly set'), end
%
f{[1,3]}.covvect=0.01*ones(4,1);
f(:,1,1).covvect=0.01*ones(4,1);
ff=merge(f,f);
cv=ff{1:2,2}.covvect
cv=ff(:,1:2,[],2).covvect
ff(:,1:2,[],2).covvect=0.02*ones(4,1);
cv2=ff(:,1:2,[],2).covvect
%
M=128;
u={ones(M,1);[]};
y={ones(M,1);ones(M,1)};
fr=1:M;
f={fr;fr;fr;[]};
Fdat=fiddata(y,u,f);
Fdat(:,:,1).inputvariance=ones(M,1);
Fdat(:,1,:).outputvariance=ones(M,1);        % set up variances
Fdat(:,2,:).outputvariance=ones(M,1);
%
load robotarm
ff=merge(f,f); 
ff(:,1,1,2).covvect=[];
ff(:,1,1,2).covariancematrix=[]
%
ff=merge(f,f);
ff{:,2}.covvect=[];
ff{1:2,2}.covariancematrix=[]