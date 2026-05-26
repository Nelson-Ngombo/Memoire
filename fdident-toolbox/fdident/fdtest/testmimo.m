function testmimo(expnall)
%TESTMIMO Test of MIMO handling
%
%Bilau tests
if nargin<1, expnall=''; end
if isempty(expnall), expnall=[1,2]; end 
if isstr(expnall), expnall=str2num(expnall); end
%
for expn=expnall
  u=ones(110,1); freq=[1:110]';
  
  Y={}; U={}; fr={};
  for ii=1:expn
    Y{1,ii}=ones(110,1); Y{2,ii}=ones(110,1);
    U{1,ii}=u;
    fr{1,ii}=freq; fr{2,ii}=freq; fr{3,ii}=freq;
  end
  
  Fdat1=fiddata(Y,U,fr);
  Fdat1(:,1,:).outputvariance=ones(110,1)/100;
  Fdat1(:,2,:).outputvariance=ones(110,1)/100;
  set(Fdat1,'outputname',{'Y1';'Y2'});
  set(Fdat1,'inputname',{'U1'});
  Y={}; U={}; fr={};
  for ii=1:expn;
    Y{1,ii}=ones(110,1); Y{2,ii}=ones(110,1);
    U{1,ii}=u;
    fr{1,ii}=freq; fr{2,ii}=freq; fr{3,ii}=freq;
  end
  Fdat2=fiddata(Y,U,fr);
  Fdat2(:,1,:).outputvariance=ones(110,1)/100;
  Fdat2(:,2,:).outputvariance=ones(110,1)/100;
  set(Fdat2,'outputname',{'Y1';'Y2'});
  set(Fdat2,'inputname',{'U2'});
  Fdat=merge(Fdat1,Fdat2);
  disp(sprintf('testmimo is OK for expn = %.0f',expn)) 
end %for expn