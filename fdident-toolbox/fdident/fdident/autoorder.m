function [models,msg]=autoorder(fdata,domain,hFig,runmod)
%AUTOORDER  Automatic order selection
%
%       [models,msg]=autoorder(fdata,domain,hFig);
%
%       Output arguments:
%         models = estimated model(s) (fidmodel object or cell array)
%           first one: verified model
%           second one (if different): loose model (not verified)
%         msg = history of the estimation process
%       Input arguments:
%         fdata = fiddata object with variance data
%         domain: now only 's' is valid (optional)
%         hFig = figure handle (optional), if 0, no plot
%         runmod = (optional) structure of run modifiers
%            mode: if 'all', then all calculated models are returned between the suggested
%                and the loose one.
%            plotfreq: 'linear' or 'log'
%            delay: value of the delay for elis
%
%       See also: ORDERST1, PEELING, ELIS.

%       Algorithm:
%       Yves Rolain, Johan Schoukens, Rik Pintelon, "Order Estimation for Linear
%          Time-Invariant Systems Using Frequency Domain Identification Methods,"
%          IEEE Trans. Autom. Contr., Vol.42, No.10, Oct. 1997, pp.1408-1417.

%       Written by Gyula Simon.
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Aug-2002, IK

%NOTE: This algorithm can handle s-domain and z-domain data
%(orthopol representation is used)

if (nargin==1)&isstr(fdata)&strcmp(fdata,'preload')
  peeling preload
  autoorder_demo preload
  return
elseif (nargin>=1)&isstr(fdata)&strcmp(fdata,'autoorder_uic_advice')
  hadv=findobj(0,'type','uimenu','tag','ui_advice-menu_item');
  model=get(hadv,'userdata');
  advice(model)
  return
end
if nargin<4, runmod=''; end, mode=''; plotfreq=''; delay=[]; errorweighting='Linear';
if isfield(runmod,'mode'), mode=runmod.mode; end
if isfield(runmod,'plotfreq'), plotfreq=runmod.plotfreq; end
if isfield(runmod,'errorweighting'), errorweighting=runmod.errorweighting; end
if isempty(plotfreq)|strncmpi(plotfreq,'Linear',3), plotfreq='lin';
elseif strncmpi(plotfreq,'log',3), plotfreq='log';
else error(['plotfreq is invalid as ''',plotfreq,''''])
end
if isfield(runmod,'delay'), delay=runmod.delay; end
if isempty(delay), delay=0; end
if strncmpi(errorweighting,'linear',3), errorweighting='Linear';
elseif strncmpi(errorweighting,'nonlinear',4), errorweighting='Nonlinear';
end
%
if isempty(mode)|strcmp(mode,'all')
else error(['mode =''',mode,''' not allowed'])
end
if nargin<2, domain=''; end, if isempty(domain), domain='s'; end
if strcmp(domain,'s')|strcmp(domain,'p')
else error(['''',domain,''' is not allowed for domain'])
end
RealMode=1; % use real Jacobian
if nargin<3, hFig=''; end
if isempty(hFig)|isequal(hFig,0)
  hFig=findall(0,'type','figure','tag','elis_window');
  if isempty(hFig), hFig=gcf; set(hFig,'tag','elis_window'), end
end

if ~isempty(hFig)
  set(hFig, 'name', 'Info on Automatic Model Selection', ...
    'numbertitle', 'off','tag','elis_window')
  if ~strncmp('5.2',version,3), set(hFig,'toolbar','none'); drawnow, end
  delete(findobj(hFig,'type','axes'))
  vers=version;
  
  hAxes=axes('parent', hFig);
  if isfield(runmod,'errorweighting')&any(findstr(runmod.errorweighting,'onlinear'))
    msc='w';
  else
    msc='';
  end
  plot(fdata, msc,'parent', hAxes,'xscale',plotfreq)
  drawnow, pause(1)
  autoomsg('Automatic Order Selection in Progress...', hFig)
end

if (strncmpi(errorweighting,'Linear',3)&isempty(fdata.outputvariance)) | ...
    (any(findstr(errorweighting,'onlinear'))&isempty(fdata.OutputNonlinError))
  error('Errorweighting is not properly given, order determination is impossible')
end
if strncmpi(errorweighting,'Linear',3)&isempty(fdata.covvect)
  fdata.covvect=0;
elseif strncmpi(errorweighting,'Nonlinear',4)&isempty(fdata.nonlincovvect)
  fdata.nonlincovvect=0;
end

MaxInitOrd=min(200, floor(length(fdata.freqpoints)/2)); % max value of initorder
InitOrd=min(50,floor(length(fdata.freqpoints)/5)); % try from here, it is automatically increased if too low

DenOrd=inf; NumOrd=inf;  % order of denomenator
EstNumOrd=InitOrd; EstDenOrd=InitOrd;
LastSuccessfulNumInit=inf;
LastSuccessfulDenInit=inf;

DECREASE_LIMIT=1; 
% if the estimated order is decreased at least by DECREASE_LIMIT, then 
% estimate again with new initial order, else peeling does the rest

msg_coarse={};
CoarseReady=0;
cix=1;
msg_coarse{cix}=['Coarse estimation started with initial order: ', ...
    num2str(EstNumOrd), '/' num2str(EstDenOrd), ...
    ' (Max. allowed order for this data: ', num2str(MaxInitOrd), '/', num2str(MaxInitOrd), ')'];
autoomsg(msg_coarse{1}, hFig)
while ~CoarseReady
  cix=cix+1;
  NumOrd=EstNumOrd;
  DenOrd=EstDenOrd;
  [EstNumOrd, EstDenOrd]=orderst1(fdata, NumOrd, DenOrd,domain,errorweighting);
  
  msg_coarse{cix}=['    Coarse step #', num2str(cix-1), ': ', ...
      num2str(NumOrd), '/' num2str(DenOrd), ' -> ', ...
      num2str(EstNumOrd), '/' num2str(EstDenOrd)];
  
  if EstNumOrd > NumOrd  % initial order was too low
    if isinf(LastSuccessfulNumInit) % no successful trials before
      if NumOrd<MaxInitOrd  % can be increased
        EstNumOrd=ceil(NumOrd*1.3); % try to increase order
        EstDenOrd=ceil(DenOrd*1.3);
        if EstNumOrd > MaxInitOrd
          EstNumOrd=MaxInitOrd;
        end
        if EstDenOrd > MaxInitOrd
          EstDenOrd=MaxInitOrd;
        end
        msg_coarse{cix}=[msg_coarse{cix}, ...
            ' -- Increased to: ', num2str(EstNumOrd), '/' num2str(EstDenOrd)];
        CoarseReady=0;
      else
        NumOrd=MaxInitOrd;
        DenOrd=MaxInitOrd;
        msg_coarse{cix}=[msg_coarse{cix}, ...
            ' -- Max allowed order reached: ', num2str(NumOrd), '/' num2str(DenOrd)];
        CoarseReady=3;
      end
    else % the were successful trials before, reset to old value, and finish coarse step
      NumOrd=LastSuccessfulNumInit;
      DenOrd=LastSuccessfulDenInit;
      CoarseReady=2;
    end
  else % improvement or the same order
    LastSuccessfulNumInit=NumOrd;
    LastSuccessfulDenInit=DenOrd;
    CoarseReady=(EstNumOrd > (NumOrd - DECREASE_LIMIT));
    if EstNumOrd<0
      %Stop if EstNumOrd is negative: makes no sense
      CoarseReady=4;
    elseif (EstNumOrd==0)&(LastSuccessfulNumInit==0)&(LastSuccessfulDenInit==0)
      CoarseReady=5;
    end
  end
  autoomsg(msg_coarse{cix}, hFig)
end %while ~CoarseReady

% CoarseReady:
%    1. OK
%    2. Strange, but may be OK
%    3. MaxInitOrd was not enough
%    4. EstNumOrd went negative
%    5. EstNumOrd stays zero

msg_coarse{end+1}=['Estimated order after coarse step: ' num2str(NumOrd), '/' num2str(DenOrd), ...
    ' (status: ' num2str(CoarseReady) ')'];
autoomsg(msg_coarse{end}, hFig)

% check here if coarse guess is OK
if ~isempty(hFig), ElisPlotDens=10;
else ElisPlotDens=inf;
end

fodOK=0; fix=1; msg_fod={['FoD check started']};
autoomsg(msg_fod{1}, hFig)

allmodels=[];
while ~fodOK
  fix=fix+1;
  if ~isempty(hFig)
    set(hFig, 'name', 'Info on Automatic Model Selection')
    delete(findobj(hFig,'type','axes'))
  end
  runmod=struct(...
    'fscale', inf, ...
    'representation', 'orthopol',...
    'algorithm', 'LMsvd', ...
    'initset', 'AML', ...
    'plotdens', ElisPlotDens,...
    'plotfreq',plotfreq,...
    'delay',delay,...
    'errorweighting',errorweighting);
  drunmod=struct('displaymessages', 'off');
  if isa(allmodels,'fidmodel')
    ind=strmatch(sprintf('%.0f/%.0f',NumOrd,DenOrd),order(allmodels));
  else
    ind=[];
  end
  if isempty(ind)
    try
      model=elis(fdata, domain, NumOrd, DenOrd, runmod, drunmod);   
    catch
      models=[]; msg='Run aborted';
      return
    end
    if strcmp(mode,'all')
      allmodels=stack(2,allmodels,model);
    end
  else
    model=allmodels(:,:,ind);  
  end
  msg_fod{fix}=['    FoD check step #', num2str(fix-1), ...
      ': Order: ', num2str(NumOrd), '/' num2str(DenOrd)];
  
  if ~isempty(hFig)
    hAxes=MakeClearAxes(hFig);
  else
    hAxes=0;
  end
  [pass, tmp, tmp, f1, f2]=chkfod(fdata, model, 0.75, errorweighting,hAxes);
  if pass
    fodOK=1;
  else 
    if NumOrd >= MaxInitOrd
      % that's the end: max allowed order reached, and fod is still not satisfied
      % with the result: nothing to do ...
      fodOK=2;
      msg_fod{fix}=[msg_fod{fix}, ' -- Max order reached, sorry...'];
    else
      NumOrd=ceil(NumOrd*1.1+eps); % increase NumOrd by 10% but at least by 1
      DenOrd=ceil(DenOrd*1.1+eps); % increase DenOrd by 10% but at least by 1
      if NumOrd > MaxInitOrd
        NumOrd=MaxInitOrd;
      end
      if DenOrd > MaxInitOrd
        DenOrd=MaxInitOrd;
      end
      fodOK=0;
      msg_fod{fix}=[msg_fod{fix}, ...
          ' -- Increased to: ', num2str(NumOrd), '/' num2str(DenOrd)];
    end
  end
  msg_fod{fix}=[msg_fod{fix},...
      ', status: ', num2str(fodOK), ' (' num2str([f1, f2]) ')'];
  
  autoomsg(msg_fod{fix}, hFig)
end
% fodOK: 
%   1: OK
%   2: Max order reached, not OK

msg_fod{end+1}=['FoD check finished. Order: ' num2str(NumOrd), '/' num2str(DenOrd)];
autoomsg(msg_fod{end}, hFig)

% call peeling
if fodOK==1
  msg_peeling={'Estimation of the verified model:'};
  autoomsg(msg_peeling{end}, hFig);
  if ~isempty(hFig)
    set(hFig, 'name', 'Info on Automatic Model Selection')
    delete(findobj(hFig,'type','axes'))
  end
  % calculate verified model
  if strcmp(mode,'all')
    [model, msg_peeling1,allmodels_peeling]=...
      peeling(fdata, model, struct('mode', 'S', 'const', 2,'plotfreq',plotfreq,...
      'delay',runmod.delay,'errorweighting',errorweighting), '',hFig);
    allmodels=stack(2,allmodels,allmodels_peeling);    
  else
    [model, msg_peeling1]=...
      peeling(fdata, model, struct('mode', 'S', 'const', 2,'plotfreq',plotfreq,...
      'delay',runmod.delay,'errorweighting',errorweighting), '', hFig);
  end  
  if isempty(model)
    msg=msg_peeling;
    models=[];
    return
  end
  msg_peeling=[msg_peeling, msg_peeling1];
  msg_peeling{end+1}= 'Estimation of the "loose" model:';
  autoomsg(msg_peeling{end}, hFig);
  
  % calculate 'loose' model
  [Cf, MCf, NCf]=cfncall(fdata, model,errorweighting); % cost function
  CfMax=2*Cf-NCf;
  % call peling with constant MaxCf and disabled FoD test
  if strcmp(mode,'all')
    [model2, msg_peeling2,allmodels_peeling]=...
      peeling(fdata, model, struct('mode', 'c', 'const', CfMax,...
      'plotfreq',plotfreq,'delay',runmod.delay,'errorweighting',errorweighting), 0, hFig);
    allmodels=stack(2,allmodels,allmodels_peeling);    
  else
    [model2, msg_peeling2]=...
      peeling(fdata, model, struct('mode', 'c', 'const', CfMax,'plotfreq',plotfreq,...
      'delay',runmod.delay,'errorweighting',errorweighting), 0, hFig);
  end
  msg_peeling=[msg_peeling, msg_peeling2];
  
else
  % no peeling necessary, MaxOrder is too small
  msg_peeling={'No peeling performed, model is too complex, maximum order reached.'};
  autoomsg(msg_peeling{1}, hFig)
  model2='';
end

stmsg='Automatic order detection finished.';
omsg=[' Estimated Orders: ', ...
        num2str(length(model.num)-1), '/' num2str(length(model.den)-1)];
msg=[msg_coarse'; msg_fod'; msg_peeling'; ...
    {omsg}];
if ~isempty(model2)
  o2msg=[', loose: ', num2str(length(model2.num)-1), '/' num2str(length(model2.den)-1)];
  msg{end}=[msg{end},o2msg];
else
  o2msg='';
end

if isempty(hFig)
  hFig=findall(0,'type','figure','Tag', 'elis_window');
end
if isempty(hFig)
  [pos,units]=getfpos;
  hFig=figure('Units',units, 'position',pos,'Tag', 'elis_window','numbertitle','off');
end

if ~isempty(hFig)
  drawnow, pause(1)
  figure(hFig), delete(findobj(hFig,'type','axes'))
  h1=subplot(121); plot(fdata, model, 'parent', h1)
  if strncmp(plotfreq,'log',3), set(h1,'xscale','log'), end
  title(sprintf('Verified model: %.0f/%.0f, Cfcn: %.4g',length(model.num)-1,length(model.denom)-1,...
    model.fitinfo.cf),'parent',h1)
  if ~isempty(model2)
		h2=subplot(122); plot(fdata, model2, 'parent', h2)
		if strncmp(plotfreq,'log',3), set(h2,'xscale','log'), end
		title(sprintf('Loose model: %.0f/%.0f, Cfcn: %.4g',length(model2.num)-1,length(model2.denom)-1,...
			model2.fitinfo.cf),'parent',h2)
		ylim2=get(h2,'ylim');
	else
		h2=[]; ylim2=[inf,-inf];
	end
	ylim1=get(h1,'ylim');
  ylim=[min(ylim1(1),ylim2(1)),max(ylim1(2),ylim2(2))];
  set([h1;h2],'ylim',ylim);
  set(hFig,'tag','elis_window')
  iterctrl('delete','elis_window')
end
autoomsg([stmsg,omsg,o2msg], hFig)
model.note='This model is the verified result of Automatic Model Selection.';
model.data=fdata;
if ~isempty(model2) &...
    ~strcmp(fdtool('callback','fdmodord',model), fdtool('callback','fdmodord',model2))
  model2.note='This model is the not verified (lower order) result of Automatic Model Selection';
  model2.data=fdata;
  %model(2)=model2; % not good for new model objects
  model={model,model2};
end
hadv=findobj(hFig,'type','uimenu','tag','ui_advice-menu_item');
if isempty(hadv)
  hadv=uimenu(hFig,'tag','ui_advice-menu_item','label','&Advice');
end
%set(hadv,'callback','fdtool(''callback'',''autoorder'',''autoorder_uic_advice'');')
set(hadv,'callback','fdtool(''callback'',''autoorder'',''autoorder_uic_advice'',''autoorder'',''ui_advice-menu_item'');')
%fdtool('callback','autoorder','autoorder_uic_advice','autoorder','ui_advice-menu_item');
set(hadv,'userdata',model)

if nargout>0, models=model; end
if strcmp(mode,'all')
  if isempty(allmodels), return, end
  if isa(models,'fidmodel')
    n=length(models.num)-1; d=length(models.denom)-1;
    nmin=n; dmin=d;
  elseif iscell(models)
    n=length(models{1}.num)-1; d=length(models{1}.denom)-1;
    nmin=n; dmin=d;
    if length(models)>=2
      nmin=length(models{2}.num)-1; dmin=length(models{2}.denom)-1;
    end
  else
    return
  end
  ams=struct(allmodels);
  ns={ams.num};
  ds={ams.denom};
  keep=[];
  for ii=3:length(ns)
    ni=length(ns{ii})-1; di=length(ds{ii})-1;
    if ((ni==n)&(di==d)) | ((ni==nmin)&(di==dmin)) |...
        (ni>n) | (ni<nmin) | (di>d) | (di<dmin)
    else
      keep=[keep,ii];
    end
  end %for ii
  if ~isempty(keep)
    %models=stack(2,models,allmodels(:,:,keep));
    for ii=1:length(keep)
      models=[models,{allmodels(:,:,keep(ii))}];
    end
  end
end
%
%End of function autoorder

function hAxes=MakeClearAxes(hFig)
% find axes objects
hAllAx=findobj(allchild(hFig), 'flat', 'type', 'axes');
delete(hAllAx)
% find uicontrols
hAllUi=findobj(allchild(hFig), 'flat', 'type', 'uicontrol');
delete(hAllUi)
hAxes=axes('parent', hFig);


function [EstNumOrd, EstDenOrd]=orderst1(fdata, NumOrd, DenOrd, domain,errorweighting)
% ORDERST1   Order estimation step 1 (coarse step)
% 
%    function [EstNumOrd, EstDenOrd]=orderst1(fdata, NumOrd, DenOrd,domain,errorweighting)
% 
%    Output: 
%            EstNumOrd: estimated order of the numerator
%            EstDenOrd: estimated order of the denomerator
%
%    Input:
%            fdata    : fiddata object with variance data
%            NumOrd   : initial order of the numerator
%            DenOrd   : initial order of the denomerator
%            domain   : (optional) domain can be 's' (default) or 'z'
%
%    See also: AUTOORDER, PEELING.

%    Algorithm:
%       Yves Rolain, Johan Schoukens, Rik Pintelon, "Order Estimation for Linear
%          Time-Invariant Systems Using Frequency Domain Identification Methods,"
%          IEEE Trans. Autom. Contr., Vol.42, No.10, Oct. 1997, pp.1408-1417.
%
%       Written by Gyula Simon, 1998.
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Jul-1999

%       Z-Orthopol added for test purposes 12-Jul-1999

%    Coarse order estimation based on the svd of the whitened Jacobian

if nargin<3
  DenOrd=NumOrd;
end
if nargin < 4
  domain='p';
end

RealMode=1; % use real Jacobian

X=fdata.input;  % measured input data
Y=fdata.output; % measured output data

if strncmpi(errorweighting,'Linear',3)
  Cxx=fdata.inputvariance;
  Cyy=fdata.outputvariance;
  Cxy=fdata.covvector;
elseif strncmpi(errorweighting,'Nonlinear',4)
  Cxx=fdata.InputNonlinError;
  Cyy=fdata.OutputNonlinError;
  Cxy=fdata.nonlincovvector;
end

fv=fdata.freqpoints; % frequencies, where measurements were performed
% normalize freq now:
fv = 2*fv /(max(fv)+min(fv))  / 2 /pi;  % normalize frequencies
K=length(fv); % # of freq points

% weight calculation
W=qmlw(fdata, NumOrd, DenOrd,errorweighting);
%[pv, fit, Cp, CR, cfv, Jelis, We]=
%  elis(fdata, '', ['p'+0, NumOrd,DenOrd, inf], '', ['m'+0, 'a'+0, 3]);


switch domain
case {'s','p'}
  % orthonormal polynomial basis calculation
  % new calls thru wrapper
  Qn=fdident('private', 'orthopol', NumOrd, 'p', fv, X./W);
  Qd=fdident('private', 'orthopol', DenOrd, 'p', fv, Y./W);
  
  % The currect orthopol (26.11.1998) fulfills the following test. 
  % Check, if orthopol changed in the meantime
  %vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  QnTest=Qn.*kron(ones(1,size(Qn,2)),X./W);
  TestRes=2*real(QnTest'*QnTest); %This should be identity
  if any(any(abs(TestRes-eye(NumOrd+1))>1000*eps*NumOrd))&(NumOrd>0),
    %modification: only if NumOrd>0 
    max(max(abs(TestRes-eye(NumOrd+1)))), 1000*eps*NumOrd
    error('Orthopol changed or orthopol generation failure.')
  end        
  %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^end of test
  
  Qn=Qn*sqrt(2); Qd=Qd*sqrt(2);  % bypass; 
  
  % construct jacobian
  J=[diag(X./W)*Qn, -diag(Y./W)*Qd]; 
  Jr=[real(J); imag(J)]; % real Jacobian
  J=Jr; % use real Jacobian
  
  % Column Covariance Matrix calculation
  C=colcov(Cxx, Cyy, Cxy, W, Qn, Qd);
  C=real(C); % real covariance matrix
case {'z','q'}
  %vector-orthopol:
  %[QQz, tmp2, Jc]=orthopoz(NumOrd, DenOrd, fv, X./W, Y./W);
  %Reg. orthopol:
  Qn=fdident('private', 'orthopol', NumOrd, 'q', fv, X./W);
  Qd=fdident('private', 'orthopol', DenOrd, 'q', fv, Y./W);
  QQz=[];
  Jc=[Qn.*kron(ones(1,size(Qn,2)),X./W),-Qd.*kron(ones(1,size(Qd,2)),X./W)];
  
  %here is the difference: calculate Jc
  Jr=[real(Jc); imag(Jc)]; % real Jacobian
  J=Jr; % use real Jacobian
  
  % Column Covariance Matrix calculation
  %   C=colcov([Cxx; Cxx], [Cyy; Cyy], [Cxy; conj(Cxy)], [W;W], QQz(:,1:size(QQz,2)/2), QQz(:,size(QQz,2)/2+1:end), 2);
  C=colcov(Cxx, Cyy, Cxy, W, QQz(:,1:size(QQz,2)/2), QQz(:,size(QQz,2)/2+1:end), 2);
  C=real(C); % real covariance matrix 
end

%Cm2=sqrtm(pinv(C));
%Jw=J*Cm2;

LIMIT=1;
%DimNoiseSpace1=length(find(svd(Jw)<=LIMIT));  
[u,s,v]=svd(C);
s2=diag(sqrt(diag(s)));
sqrtC=u*s2*v';
DimNoiseSpace=length(find(gsvd(J, sqrtC)<=LIMIT));

EstNumOrd=1+NumOrd-DimNoiseSpace;
EstDenOrd=1+DenOrd-DimNoiseSpace;

function autoomsg(msg,hFig)
%AUTOOMSG temporary solution for auto order messages
%       Helper function of autoorder
%
%       Usage: autoomsg(msg,hFig)

if ~isempty(hFig)
  hBar=findobj(allchild(hFig), 'tag', 'autoorder_message_bar');
  if isempty(hBar) % create message bar
    hBar=uicontrol('parent', hFig, ...
      'style', 'text', ...   
      'horizontal', 'left', ...
      'unit', 'normal', ...
      'position', [0 0 1 .05], ...
      'string', msg,...
      'tag', 'autoorder_message_bar');
    %ext=get(hBar, 'extent');
    %set(hBar, 'position', [0 0 1 ext(4)])
  else
    set(hBar, 'string', msg)
  end
end
disp(msg)

%End of file autoorder.m