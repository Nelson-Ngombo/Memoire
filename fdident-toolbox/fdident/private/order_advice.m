function order_advice(model,fdata)
% ORDER_ADVICE tells you how good your estimated model is
%       msg=order_advice(model, fdata)
% 
%       Usage:  order_advice(model,fdata) 
%
%       Output arguments:
%         msg = idbeard's opinion
%       Input arguments:
%         model = fidmodel object containing the estimated model
%         fdata = fiddata object containing the measured data 
%        
%         Note:  If model contains the measurement data, fdata can be omitted.

%       Written by Gyula Simon, 1998
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 14-Oct-2001

%if fdtool('callback','guiinfos','islinear'), variance='lin'; else variance='nonlin'; end
if iscell(model)|isa(model, 'fidmodel')  % init phase
  if ~iscell(model)
    if (size(model,3)==2)|(size(model,4)==2), model={model(:,:,1),model(:,:,2)};
    else model={model(:,:,1)};
    end
  end
  if nargin<2, fdata=''; end
  
  if isempty(fdata)
    if ~isempty(model{1}.data) & isa(model{1}.data, 'fiddata')
      fdata=model{1}.data;
    else
      error('Input data ''fdata'' is missing!')
    end
  end
  
  [hFig, hAxes1, hAxes2, hList]=InitGraphics(length(model));
  fv=fdata.freqpoints; ind=find(fv<=0); if ~isempty(ind), fv(ind)=[]; end  
  if max(fv)/min(fv)>5e3, xscale='log'; else xscale=''; end
  %if ~isempty(gcbo) %callback
  %objtype=get(model{1},'errorweighting'); objtype=lower(objtype(1:6));
  %end
  variance=model{1}.errorweighting; if isempty(variance), variance='linear'; end
  if strncmpi(variance,'lin',3)|isempty(variance), plottype='a'; else plottype='b'; end
  %plottype='a'; objtype='lin';
  plot(model{1},fdata, plottype,'parent', hAxes1,'xscale',xscale,'objtype',variance)
  h=findall(0,'tag','AutoModelSelectionDemoFig');
  hlb=findobj(h,'tag','popupmenu'); dn=get(hlb,'string');
  axh=get(hAxes1,'xlim'); axv=get(hAxes1,'ylim');
  if strcmp(xscale,'log'), txtoffs=sqrt(prod(axh)); else txtoffs=mean(axh); end
  if ishandle(h)
    text(txtoffs,axv(1)-0.12*diff(axv),...
      [dn{get(hlb,'value')},': ',num2str(length(model{1}.num)-1),'/',num2str(length(model{1}.denom)-1)],...
      'horizontalalignment','center','verticalalignment','top','parent',hAxes1)
  end
  if length(model)>1
  variance=model{2}.errorweighting; if isempty(variance), variance='linear'; end
  if strncmpi(variance,'lin',3)|isempty(variance), plottype='a'; else plottype='b'; end
    plot(model{2},plottype,'parent', hAxes2,'xscale',xscale)
    axh=get(hAxes2,'xlim'); axv=get(hAxes2,'ylim');
    if strcmp(xscale,'log'), txtoffs=sqrt(prod(axh)); else txtoffs=mean(axh); end
    if ishandle(h)
      text(txtoffs,axv(1)-0.12*diff(axv),...
        [dn{get(hlb,'value')},': ',num2str(length(model{2}.num)-1),'/',num2str(length(model{2}.denom)-1)],...
        'horizontalalignment','center','verticalalignment','top','parent',hAxes2)
    end
  end
  
  %Experimentation...
  %dbstackstr=dbstack; mfn=dbstackstr(1).name;
  %ind1=findstr('(',mfn);
  %if length(ind1)==1, ind2=findstr(')',mfn); mfn=mfn(ind1+1:ind2-1);
  %else error('Something is fishy')
  %end
  %feval(mfn, 'ADVICE')
  %
  %feval(mfilename, 'ADVICE')
  order_advice('ADVICE')
  
  if exist('setappdata')
    setappdata(hFig, 'MODELS', model);
    setappdata(hFig, 'FDATA', fdata);
  else
    setuprop(hFig, 'MODELS', model);
    setuprop(hFig, 'FDATA', fdata);
  end

else  % callback
  hFig =findobj(allchild(0), 'flat', 'tag', 'idbeard_tells_his_opinion');
  hList=findobj(allchild(hFig), 'flat', 'tag', 'explain_listbox');
  ax=[findobj(allchild(hFig), 'flat', 'tag', 'explain_1_axes'), ...
      findobj(allchild(hFig), 'flat', 'tag', 'explain_2_axes')];
  ColPassive=[1 1 1];
  ColActive=[1 1 0];
  if any(findstr(model, 'MODEL'))|strcmp(model,'copy')
    if exist('setappdata')
      models=getappdata(hFig, 'MODELS');
      fdata=getappdata(hFig, 'FDATA');
    else
      models=getuprop(hFig, 'MODELS');
      fdata=getuprop(hFig, 'FDATA');
    end
    %
    if strcmp(model,'copy')
      fdtool
      if 0
        fdtool('ui_forget_all', 'fdtool_menu_forget_all')
        fdtool('ui_userlevel_set', 'Interactive', 'fdtool_menu_userlevel_intermediate')
        %
        fdtool('load_an_arrow', 7, fdata)
        fdtool('forward_data', 'average')
        fdtool('callback','boxmgr',['end_of_average'], 'fdtool_main', 'LOADEDDATA')
        %
      end
      %Load model to arrow:
      fdtool('load_an_arrow', 9, models{1})
      fdtool('forward_data', 'select')
      fdtool('callback','boxmgr',['end_of_select'], 'fdtool_main', 'LOADEDDATA')
      %
      fdtool( 'click_on_compare','rect_compare')
      if length(models)>1
        fdtool('callback','guidtawr','compare_main','IMPORTED_VAR','direct',models{2})
        fdtool('callback','caem','from_load_model_paste_replace_2')
      end
      %***
      return
    end
    
    switch model
    case 'MODEL1'
      ixa=1; ixp=2;
    case 'MODEL2'
      ixa=2; ixp=1;
    end
    set(ax(ixp), 'color', ColPassive) % white for passive axes
    set(ax(ixa), 'color', ColActive)
    variance=get(models{ixa},'errorweighting'); if isempty(variance), variance='linear'; end

    % set buttondown properties:
    % active axes may zoom, passive axes calls me if clicked on
    set(ax(ixa),'buttondownfcn','set(get(gcbo, ''parent''), ''handlevisibility'', ''callback''),  zoom down');
    set(ax(ixp), 'buttondownfcn', get(ax(ixp), 'userdata'))  % set passiv axes' buttondownfcn
    msgi=CreateMessage(fdata, models, variance,ixa);
    TopLine=get(hList, 'listboxtop'); Val=get(hList, 'value');
    if Val>length(msgi), set(hList, 'value', length(msgi)), end
    set(hList, 'string', msgi, 'listboxtop', TopLine)
  elseif findstr(model, 'ADVICE')
    set(ax, 'color', ColPassive) % white for passive axes
    set(ax(1), 'buttondownfcn', get(ax(1), 'userdata'))  % set passiv axes' buttondownfcn
    set(ax(2), 'buttondownfcn', get(ax(1), 'userdata'))
    msg={'I.D. Beard''s opinion:', ...
        '', ...   
        'The plot(s) above show the estimated transfer function with the measurement data, ', ...   
        'and the residuals with their 50% and 95% confidence bounds.'};
    if ~isempty(gcbo)
      msg=[msg, ...
        {'Left is the verified model, right is the loose model (if this is different).'}];
    end
      msg=[msg, ...
        {'',...   
        'A model can be activated by clicking on the corresponding plot.',...
        'I.D. Beard tells his opinion on the quality of the active model here.',...
        '',...   
        'On the active model''s plot zoom is also active.',...
        '',...
        'Click on a plot...',...
      }];
    set(hList, 'string', msg, 'listboxtop', 1, 'value', 1)
    
  else % other possible callbacks here:
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         L O C A L    F U N C T I O N S                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [hFig, hAxes1, hAxes2, hList]=InitGraphics(num_ax);

hFig=findobj(allchild(0), 'flat', 'tag', 'idbeard_tells_his_opinion');
if ishandle(hFig)
  ax=findobj(allchild(hFig), 'type', 'axes');
  gui=findobj(allchild(hFig), 'type', 'uicontrol');
  delete([ax(:);gui(:)])
else
  hFig=figure('name', 'I.D. Beard tells his opinion', ...
    'unit', 'pixel', ...   
    'position', [30 100, 660 450], ...
    'numbertitle', 'off', ...
    'resize', 'off', ...
    'defaultlinehittest', 'off', ...
    'handlevisibility', 'off', ...
    'windowbuttonupfcn','ones; set(gcbo, ''handlevisibility'', ''off'')', ...
    'windowbuttonmotionfcn','',...
    'buttondownfcn','', ...
    'tag', 'idbeard_tells_his_opinion');
end

%mfilename -> order_advice
hAxes1=axes('parent', hFig, ...
  'unit', 'pixel', ...
  'position', [40+10 250 280-10 170], ...
  'buttondownfcn', ['fdident(''private'',''order_advice'',''MODEL1'')'], ...
  'userdata', ['fdident(''private'',''order_advice'',''MODEL1'')'], ...
  'interrupt', 'off', ...
  'tag', 'explain_1_axes');

hAxes2=axes('parent', hFig, ...
  'unit', 'pixel', ...
  'position', [360+10 250 280-10 170], ...
  'buttondownfcn', ['fdident(''private'',''order_advice'',''MODEL2'')'], ...
  'userdata', ['fdident(''private'',''order_advice'',''MODEL2'')'], ...
  'interrupt', 'off', ...
  'tag', 'explain_2_axes');

hList=uicontrol('parent', hFig, ...
  'style', 'list',...
  'unit', 'pixel', ...
  'position', [40 25 500 180], ...
  'tag', 'explain_listbox');


hClosePush=uicontrol('parent', hFig, ...
  'style', 'push',...
  'unit', 'pixel', ...
  'position', [640-70 25 70 20], ...
  'string', 'Close', ...
  'callback', 'delete(get(gcbo, ''parent''))',... 
  'tag', 'explain_fod_axes');

hCopyPush=uicontrol('parent', hFig, ...
  'style', 'push',...
  'unit', 'pixel', ...
  'position', [640-70 25+25 70 20], ...
  'string', 'Copy to GUI', ...
  'callback', 'fdident(''private'',''order_advice'',''copy'')',... 
  'tooltipstring','Copy models into GUI for further investigation',...
  'tag', 'explain_copy');

if num_ax<2, set(hAxes2, 'visible', 'off'), end

set(hFig, 'color', get(hClosePush, 'backgroundcolor'));
% generate picture
%pict=imread('\temp\idbeard3.bmp');
load beardpic
sp=size(pict);
% redefine background color
col=floor(255*get(hFig, 'color'));
% set(hFig, 'color', col/255)
cc=pict(1,1,:);
for ix1=1:sp(1)
  for ix2=1:sp(2);
    if isequal(pict(ix1, ix2, :), cc)
      pict(ix1, ix2, :)=col;
    end
  end
end

hAxesPict=axes('parent', hFig, ...
  'unit', 'pixel', ...
  'position', [650-sp(2) 80 sp(2) sp(1)], ...
  'visible', 'off', ...
  'tag', 'explain_fod_axes');
hImage=image(pict, 'tag','I.D.Beard image','parent', hAxesPict);
%mfilename -> order_advice
set(hImage,    'buttondownfcn', ['fdident(''private'',''order_advice'',''ADVICE'')']);
set(hAxesPict, 'visible', 'off', 'interrupt', 'off');


function msg=CreateMessage(fdata, models, variance,ix);
% create expert's opinion on the model

model=models{ix};

NumOrd=length(model.num)-1; DenOrd=length(model.den)-1;
% check fit
fit=model.fit;

%Cf=fit(1);
%CfTh=fit(2);
Cf=fit.cf;
CfTh=fit.cfth;

CNoise=length(fdata.freqpoints)-(NumOrd+DenOrd+1)/2;
CModel=max(0, Cf-CNoise);
varCf=CNoise; % suppose there is no modelling error...
MaxCf=CfTh+2*sqrt(varCf);

% The decision levels may be adjusted in the future:
%                            vvvvvv
if     Cf       <            CfTh/2  % it's too low
  Q_cf=-1;
elseif Cf       <            MaxCf   % it's more than good !!!!
  Q_cf= 1;
elseif Cf       <            2*CfTh  % may be OK
  Q_cf= 2;
elseif Cf       <            6*CfTh  % poor
  Q_cf= 3;
else                                 % very poor
  Q_cf= 4;
end


% now check fod
[pass, fodv, bound, fraction]=chkfod(fdata, model, [], variance,0); % default criterion, no plot

% The decision levels may be adjusted in the future:
%                            vvvvv
if     fraction(1)     <      0.2  % it's too low
  Q_fod=-1;
elseif fraction(1)     <      0.65 % fod level is approximately what we expect
  Q_fod= 1;
elseif fraction(1)     <      0.8  % may be OK
  Q_fod= 2;
else
  Q_fod= 3;           % too high
end



% now check fit using residuals and vartf
x=fdata.input; y=fdata.output;
fv=fdata.freqpoints;

vx=fdata.inputvar; vy=fdata.outputvar; cyx=fdata.covvect;

[H,N,D]=tfcalc(model, fv);
%H=N./D;
varH=vy + vx.*abs(H.^2);
if ~isempty(cyx)
  varH=varH-2*real(cyx.*conj(H));
end
varH=varH./abs(x.^2); 

stdH=sqrt(varH);
resid=abs(y./x-H);

MeanErrPow=mean(abs(resid).^2);
MeanVarH=mean(varH);
RelMeans=MeanErrPow/MeanVarH;
MeanRelErrPow=fodv(length(fv));   % mean(abs(resid./stdH).^2) ~=~ fod(0)

msg={['Model ' num2str(ix)],''};
if ~isempty(model.note), msg=[msg, {model.note}]; end

%msg=[msg, {sprintf('    Order:  %d/%d', )}];
ew=model.errorweighting; 
if strcmp(ew,'Nonlinear'), nltext=', nonlinear variances were used';
elseif strcmp(ew,'Interpolated nonlinear'), nltext=', interpolated nonlinear variances were used';
else nltext='';
end
msg=[msg, {sprintf('    Order:  %d/%d, domain: %s, representation: %s%s',...
  NumOrd, DenOrd, model.variable,model.representation,nltext)}];
%msg=[msg, {sprintf('', )}];

if isstable(model), stabstr=''; else stabstr=' not'; end
msg=[msg {sprintf('    The model is%s stable.', stabstr)}];
%msg=[msg, {' '}];

msg=[msg, ...
    {sprintf('FoD test:')}, ...
    {sprintf('    %3.1f%% of the FoD values are below the 50%% theoretical level, which indicates that ', 100-100*fraction(1))}];

switch Q_fod
case 1
  msg=[msg,...
      {sprintf('    the linear dynamic behaviour of the system is correctly described by the selected model. ')}];
case 2
  msg=[msg,...
      {sprintf('    the linear dynamic behaviour is described by the selected model, ')}, ...
      {sprintf('    but unmodelled dynamics may be present. ')}];
case 3
  msg=[msg,...
      {sprintf('    the linear dynamic behaviour of the system is not properly described by the selected model. ')}];
case -1
  msg=[msg,...
      {sprintf('    there may be a problem with the variance data. FoD is too low! ')}];
end   

msg=[msg, ...
    {sprintf('    Fod(0): %3.2f', fodv(length(fv)))}];
if (Q_fod<3)&~any(findstr('onlin',ew))  % nonlinear effects
  Q_nl=sqrt(fodv(length(fv)));  % sqrt(Cf/CfTh-1) = sqrt(fod(0))
  msg=[msg,...
      {sprintf('    The level of (possibly) nonlinear errors is %3.1f times higher than the noise level.', Q_nl)}];
  if Q_nl<2
    Q_nl=0;
  end
else
  Q_nl=0;
end

%msg=[msg, {' '}];
msg=[msg, {'Fit info:'}];
msg=[msg, ...
    {sprintf('    Theoretical cf: %3.2f, Cost Fcn: %3.2f ', CfTh, Cf)}];


%msg=[msg, ...
%      {sprintf('    Mean Error Power: %3.2g, Mean tf var: %3.2g , (Ratio: %3.2g)', MeanErrPow, MeanVarH, RelMeans)}];



if RelMeans<0.005
  Q_fit=-1;
elseif RelMeans<2
  Q_fit=1;
elseif RelMeans<5
  Q_fit=2;
elseif RelMeans<10
  Q_fit=3;
else
  Q_fit=4;
end   

if MeanRelErrPow<4
  Q_fit2=1;
elseif MeanRelErrPow<20
  Q_fit2=2;
elseif MeanRelErrPow<50
  Q_fit2=3;
else
  Q_fit2=4;
end   


switch Q_fit
case 1
  msg=[msg,...
      {sprintf('    The overall fit is quite good. ')}];
case 2
  msg=[msg,...
      {sprintf('    The overall fit quality is medium or good. ')}];
case 3
  msg=[msg,...
      {sprintf('    The overall fit is medium or poor. ')}];
case 4
  msg=[msg,...
      {sprintf('    The fit is poor. ')}];
case -1;
  msg=[msg,...
      {sprintf('    Warning: The overall fit is too good. There may be a problem with the variance data. ')}];
end

if Q_fit<3
  switch Q_fit2
  case 1  
    % OK !!
  case 2
    msg=[msg,{''}];
    msg{end}=[msg{end},...
        sprintf('    However, at some frequencies the fit quality may be somewhat poorer.')];
  case 3
    msg=[msg,{''}];
    msg{end}=[msg{end},...
        sprintf('    However, at some frequencies the fit quality is poorer.')];
  case 4
    msg=[msg,{''}];
    msg{end}=[msg{end},...
        sprintf('    Warning: At some frequencies the fit quality is poor. ')];
  end
end
