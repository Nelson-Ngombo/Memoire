function [fod,bound,fraction]=corrtest(varargin)
%CORRTEST  Correlation test of residuals with bounds
%
%       CORRTEST(model) obtains the complex residuals (the difference between
%       the model and model.data), and then calculates the correlation
%       function of them, in order to test the quality of the fit.
%       CORRTEST(model,freepar) uses the number of free parameters
%       during estimation for more exact calculation.
%       CORRTEST(model,freepar,'parent',h) makes a plot to the given axes.
%
%       Output arguments:
%       fod = function of dependency: correlation of the residuals
%             normalized by estimated variances (noise+nonlinear)
%       bound = F x 3 array, containing the theoretical bounds for
%               50%, 95% and 99.5%, respectively
%       fraction = 3 x 1 vector, giving the fraction of the residuals
%               outside the 50%, 95% and 99.5 % bounds, respectively
%
%       Usage: [fod,bound,fraction]=corrtest(model,freepar,'parent',h);
%       Example: corrtest('rarmmods(m)',12);
%
%       See also: RDUEELIS.

%Old fdident help
%CORRTEST  Correlation test of residuals with bounds
%
%       [fod,bound,fraction]=corrtest(ryx,vryx,freepar,h)
%
%       Output arguments:
%       fod = function of dependency: correlation of the residuals
%             normalized by estimated variances (noise+nonlinear)
%       bound = F x 3 array, containing the theoretical bounds for
%               50%, 95% and 99.5%, respectively
%       fraction = 3 x 1 vector, giving the fraction of the residuals
%               outside the 50%, 95% and 99.5 % bounds, respectively
%
%       Input arguments:
%       ryx = complex residuals
%       vryx = half of the complex variance of the complex residuals,
%              the same as that of the frf: (vary+varu*|H|^2)/|X|^2
%       freepar = number of free parameters
%       h = handle of axes, zero means no plot
%
%       Usage: [fod,bound,fraction]=corrtest(ryx,vryx,freepar,h);
%       Example:
%         load inpchold %load variables Fdat, pvect, Cp
%         [rx,ry,ryx,vryx]=rdueelis(pvect,Cp,Fdat,[9.61e-12,9.61e-10]);
%         corrtest(ryx,vryx,26)
%
%       See also: RDUEELIS.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2006
%       All rights reserved.
%       $Revision: $
%       Last modified: 31-Mar-2006

h=[]; freepar=[];
if nargin<1, error('No input argument'), end
linear=1;
model=getobjf(varargin{1},'fidmodel');
if isa(model,'fidmodel')
  %new call
  if isfield(model.fitinfo,'errorweighting')
    linear=~any(findstr(get(model,'errorweighting'),'onlin'));
  end
  if nargin>1
    for ii=2:length(varargin)
      if ii>length(varargin), break, end
      if strcmp(varargin{ii},'parent')
        h=varargin{ii+1};
        varargin(ii+1)=[];
      else
        freepar=varargin{ii};
      end
    end
  end
  c=model.covariance; 
  dc=diag(c); ldc=length(dc);
  if isempty(freepar)
    freepar=sum(dc~=0)-all(dc(1:end-1)~=0);
  end
  if (freepar>=ldc)&(ldc>0), error('Too many free parameters given'), end
  if isempty(h)&(nargout==0)
    hp=plot(1); h=gca; delete(hp)
  end
  %Old-form rdueelis call:
  [domain,num,denom,delay,fs,Znum,Zdenom,comments,fdate,ntr,Zntr]=imppar(model);
  if ~any(findstr(domain,'z')), fs=1; end
  %pdat=exppar(domain,num,denom,delay,fs,Znum,Zdenom,'','',ntr,Zntr);
  if linear
    %[rx,ry,ryx,vryx]=rdueelis(pdat,model.covariance,model.data,model.data.OldTBSisoVariance);
    ryxobj=rdueelis(model);  
    M=model.data.M;
  else
    %[rx,ry,ryx,vryx]=rdueelis(pdat,model.covariance,model.data,model.data.SisoNonlinError/2);
    ryxobj=rdueelis(nonlinvar2var(model));  
    M=model.data.nonlinM;
  end
  ryx=ryxobj.outputdata; vryx=ryxobj.outputvariance/2;
  1;
elseif isa(model,'iddat')
  error(['model is an object of class ',class(model)])
else
  %Old call
  if nargin<4
    hp=plot(1); h=gca; delete(hp)
  else h=varargin{4};
  end
  if nargin<3, error('Not enough input arguments'), end
  ryx=varargin{1};
  vryx=varargin{2};
  freepar=varargin{3};
  M=[];
end
%
F=length(ryx); %Number of points in residual
% calculation of the standard deviations
%global CORRTESTBASE
if 0&~strcmp(CORRTESTBASE,'nlvar') %algorithm until 2005
  %Scaling of the residuals to have the variance of real and imaginary parts be 1
  F=length(vryx); Fa=length(ryx);
  vryxl=kron(ones(length(ryx)/length(vryx),1),vryx);
  ryx=ryx./sqrt(vryxl*2)*sqrt(2*F/(2*F-freepar));
  if Fa>F %multiple experiments fitted
    ryx=reshape(ryx,F,Fa/F);
    ryx=ryx.';
    ryx=ryx(:);
  end
  %
  for k=1:F
    l=k-1;
    dummy=sum(abs(ryx(1:F-l)).^2)+sum(abs(ryx(k:F)).^2);
    % Noise contribution
    varNoise=1/(F-l)+max(dummy-2*(F-l),0)/(F-l)^2;
    varBase=max(sum((abs(ryx(1:F-l)).*...
      abs(ryx(k:F))).^2)-dummy+(F-l),0)/(F-l)^2;
    stdAll(1,k)=sqrt(varNoise+varBase);
  end
  stdAll(1)=NaN; %This is new
  stdAll=[fliplr(stdAll(2:F)) stdAll]';
  bound(:,1)=sqrt(0.7)*stdAll; %0.8367
  bound(:,2)=sqrt(3)*stdAll; %1.7321
  bound(:,3)=sqrt(5.3)*stdAll; %2.3022
  %mul=-log(1-[0.5,0.95,0.995])
  %
  %correction
  if ~isempty(M)
    fodn0mod=(M-5/3)/(M-11/12);
    fod0mod=(M-2)/(M-1);
  end
else %This is the new part
  %disp('M2 value is determined from double differentiating')
  if 1 %call new routine
    mserr=mstotalerr(ryx,fiddata)'; %empty fiddata, to call class method
    stdAll=mean(abs(ryx).^2)*sqrt([2/(F),1./(F-[1:F-1])]);
  else %call old routine
    filtryx=filter([-0.5,1,-0.5],1,ryx);
    if length(filtryx)>=3
      varryx=1/1.5/(F-2)*sum(abs(filtryx(3:end)).^2);
    else
      varryx=1/(F)*sum(abs(ryx).^2);
    end
    if 0&(length(filtryx)>=23)
      %attempt to whiten
      Bm=max(21,sqrt(length(filtryx)-2)); if rem(Bm,2)==0, Bm=Bm+1; end
      B=ones(Bm,1)/Bm;
      mavarryxm=1/1.5*filter(B,1,abs(filtryx(3:end)).^2);
      mavarryxm(1:(Bm-1)/2)=[];
      mavarryxm=[ones((Bm+1)/2,1)*mavarryxm((Bm+1)/2);...
        mavarryxm((Bm+1)/2:end);...
        ones((Bm+1)/2,1)*mavarryxm(end)];
      ryxm=ryx./sqrt(mavarryxm);
      filtryxm=filter([-0.5,1,-0.5],1,ryxm);
      varryxm=1/1.5/(F-2)*sum(abs(filtryxm(3:end)).^2);
      ryx=ryxm/varryxm*varryx; %restore level
      stdAll=mavarryxm'.*sqrt([2/(F),1./(F-[1:F-1])]);
    else
      stdAll=varryx*sqrt([2/(F),1./(F-[1:F-1])]);
    end %if length(filtryx)>=23
  end
  stdAll(1)=NaN;
  stdAll=[fliplr(stdAll(2:F)) stdAll]';
  bound(:,1)=sqrt(0.7)*stdAll; %0.8367
  bound(:,2)=sqrt(3)*stdAll; %1.7321
  bound(:,3)=sqrt(5.3)*stdAll; %2.3022
  fodn0mod=1;
  fod0mod=1;
end

%Autocorrelation
if (length(mserr)>1)&any(mserr)
  msryx=mean(abs(ryx.^2));
  ryx=ryx(:)./sqrt(mserr(:));
  ryx=sqrt(msryx/mean(abs(ryx.^2)))*ryx;
end
signaltb=0;
if signaltb
  disp('Use Signal Processing Toolbox')
  fodi=abs(xcorr(ryx,'unbiased'));
else
  ryxl=[ryx;zeros(F-1,1)];
  fftryxl=fft(ryxl);
  fodi=abs(ifft(1/F*fftryxl.*conj(fftryxl)));
  fodi=[fodi(F+1:2*F-1);fodi(1:F)];
  fodi=fodi./([1:F,F-1:-1:1]'/F);
end
fodi0=fodi(F);
fodi=fodn0mod*fodi;
fodi(F)=fod0mod*fodi0; %take out expected value
%fodi(F)=fodi0-1; %take out expected value
if nargout>0, fod=fodi; end

fodi(F)=NaN; %new: avoid plot and count at center
samples=[floor(-F/2):1:ceil(F/2)]';
fraction(1)=sum(abs(fodi(floor(F/2):ceil(3*F/2)))>...
  bound(floor(F/2):ceil(3*F/2),1))/(length(samples)-1);
fraction(2)=sum(abs(fodi(floor(F/2):ceil(3*F/2)))>...
  bound(floor(F/2):ceil(3*F/2),2))/(length(samples)-1);
fraction(3)=sum(abs(fodi(floor(F/2):ceil(3*F/2)))>...
  bound(floor(F/2):ceil(3*F/2),3))/(length(samples)-1);
%check:
%sum(abs(fodi(floor(F/2):ceil(3*F/2)))>=0)/(length(samples)-1) = 1

if ~isempty(h)&(h>0) % plot required
   %cla, hold off
   delete(allchild(h))
   set(h,'xscale','linear')
   %Plot fod with 50% and 95% bounds
   hfig=get(h,'parent'); name=get(hfig,'name');
   if linear
     bcolor=[1,0.3,1]; %light magenta
   else
     bcolor=[0.4,0.4,1]; %light blue
     %bcolor=[0.4,0.4,1]; %light blue
   end
   hlines=plot(samples,abs(fodi(floor(F/2):ceil(3*F/2))),'+c',...
     samples,bound(floor(F/2):ceil(3*F/2),1),':m',...
     samples,bound(floor(F/2):ceil(3*F/2),2),':m',...
     'parent',h);
   if ~strncmp('5.2',version,3), set(get(h,'parent'),'toolbar','none'); end
   set(hlines(2:3),'color',bcolor);
   set(hfig,'name',name,'numbertitle','off')
   ax(1)=min(samples)*1.05; ax(2)=max(samples)*1.05;
   max_y=max(max(abs(fodi(floor(F/2):ceil(3*F/2)))), ...
      max(abs(bound(floor(F/2):ceil(3*F/2),2))));
   ylim=get(h,'ylim'); ylim(1)=0; ylim(2)=max_y*1.08;
   if isfinite(min(abs(fodi)))
     ylim(1)=min(abs(fodi))-(max_y-min(abs(fodi)))*0.08;
     ylim(1)=min(median(sqrt(0.2)*stdAll),ylim(1));
   end
   set(h,'xlim',ax,'ylim',ylim);
   if nargin<4 %temporary fix, to bypass bug
      set(get(h,'title'),'string','Correlation test')
   end
   %
   %set(h,'nextplot','add')
   %plot([-1:1],fodi(F+[-1:1]),'-r','parent',h)
   %set(h,'nextplot','replace')
end % of plot
%+ : measured    __bound 50 %  _ _bound 95%')
% calculation of fractions |fod| > % level

%End of corrtest
