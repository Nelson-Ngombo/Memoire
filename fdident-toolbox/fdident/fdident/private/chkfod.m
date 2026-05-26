function [pass,fodv,bound,fraction,fractionCent]=chkfod(fdata,model,criterion,errorweighting,hAxes)
%CHKFOD Check model vs. measured fdata using function of dependency
%       Helper function of autoorder
% 
%       [pass,fodv,bound,fraction,fractionCent]=chkfod(fdata,model,ctiterion,variacne,hAxes)
%
%       Output arguments:
%         pass = 
%         fodv = 
%         bound = 
%         fraction = 
%         fractionCent = 
%       Input arguments:
%         fdata = frequency domain data (fiddata object)
%         model = model (fidmodel object)
%         criterion = 
%         hAxes = handle of the axes to plot in (default: gca)
%
%       See also FOD.

%       Written by Gyula Simon, 1998
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 13-Oct-2001

if nargin <4, hAxes=''; end
if nargin <3, criterion=''; end

if isempty(hAxes), hAxes=gca; end
if isempty(criterion), criterion=0.75; end


x=fdata.input; y=fdata.output;
fv=fdata.freqpoints;

if strncmpi(errorweighting,'linear',3)
  vx=fdata.inputvar;
  vy=fdata.outputvar;
  cyx=fdata.covvect;
else
  vx=fdata.inputNonlinErr;
  vy=fdata.outputNonlinErr;
  cyx=fdata.nonlincovvect;
end

[H,N,D]=tfcalc(model,fv);
%H=N./D;
varH=vy;
if ~isempty(vx), varH=varH + vx.*abs(H.^2); end
if ~isempty(cyx), varH=varH-2*real(cyx.*conj(H)); end
varH=varH./abs(x.^2); 

resid=y./x-H;
NumOrd=length(model.num)-1;
DenOrd=length(model.den)-1;

freepar=NumOrd+DenOrd+1;
[fodv, bound, fraction]=corrtest(resid,varH/2,freepar,hAxes); % fod requires real variance

% now check central behaviour, calculate fractions for lags 1..Nl
Nl=ceil(length(fv)/10);
fractionCent(1)=sum((fodv(length(fv)+1:length(fv)+Nl) > bound(length(fv)+1:length(fv)+Nl,1)))/Nl;
fractionCent(2)=sum((fodv(length(fv)+1:length(fv)+Nl) > bound(length(fv)+1:length(fv)+Nl,2)))/Nl;
fractionCent(3)=sum((fodv(length(fv)+1:length(fv)+Nl) > bound(length(fv)+1:length(fv)+Nl,3)))/Nl;
% make some tests on central part:
CentralOK=(fractionCent(3) < 0.4) & (fractionCent(2) < 0.8);
pass=(fraction(1)<=criterion) & CentralOK;
