function handles=plot(varargin)
%PLOT Plot model (maybe along with fiddata object) in a similar way as plot
%
%       A handle of an axes (or a column vector of two handles of two axes)
%          can be passed at the end preceded by argument 'parent', and the
%          horizontal scaling ('lin' or 'log') after 'xscale'
%       A plot modifier argument (a single character) can take one of the following
%       values:
%       '+' means that only the amplitudes are plotted,
%       '-' that only the phases,
%       '=' allows to show both the amplitude and the phase.
%       '&' allows to show both input and output.
%       '#' allows to show both input and output with variances.
%       'n' lets the noise-to-signal ratio plotted along with the f-U, f-Y pairs.
%       's' lets the signal-to-noise ratio plotted along with the f-U, f-Y pairs.
%       The following options plot a large plot of the the magnitude response with
%       extensions.
%       'm' plot parametric model only
%       '*' model+FRF+errors.
%       '@' model+FRF+errors of non-av data.
%       '2' shows the output/input and the var + nonlinear error (if any) for non-av data.
%       '1' shows the output and the var + nonlinear error (if any) for non-av data.
%       'w' shows the 'nonlinear variances', used in estimation
%       'v' shows the FRF and the variances.
%       'c' makes the std's of the fitted model also be calculated from the
%           parameter covariance matrix, and plotted.
%       'C' plots cloud of models simulated from the parameter covariance matrix.
%       'r' makes the model, FRF and complex residuals be plotted.
%       'a' the same as 'r', but also the 50% and 95% bounds of the magnitudes
%           of the residuals (calculated from the given variances) are plotted.
%       'b' the same as 'a' but also with nonlinear errors
%       'S' lets the signal-to-noise ratio plotted along with the frf.
%       'N' lets the noise-to-signal ratio plotted along with the frf.
%       'd' the combination of 'a' and 'c'
%       'A' or 'B' numerator and denominator of model 
%       Default: 'r'
%       For MIMO objects, the pair 'channels',stringcell can define the subplots:
%       e.g. 'ch',{'1/2,'','2/1'} define the 1st and 3rd subplots
%       The handle defines not the axes, but the figure.
%       objtype can be 'linear','nonlinear','interpnonlinear'
%
%       For pole/zero plots, see 'help plotelpz'
%
%       Usage:
%         h=plot(model,fdata,plotmod,'objtype',objtype,'parent',hax)
%       Examples:
%         plot(model)
%         h=plot(model,fdata,'parent',hax,'flim',[fmin,fmax])
%         plot(model,'*')

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Mar-2005

if nargin>=2, data=varargin{2}; else data=[]; end
mimodata=0;
if isa(data,'fiddata')&~isempty(data)
  if (get(data,'inputchnumber')>1)|(get(data,'outputchnumber')>1)
    mimodata=1;
  end
end
if ~issiso(varargin{1})|mimodata
  dbs=dbstack; 
  if exist('plotm.m')|exist([dbs(1).name(1:end-6),'plotm.m'])
    if nargout==0, plotm(varargin{:});
    else handles=plotm(varargin{:});
    end
  else
    if nargout==0, mimoplot(varargin{:});
    else handles=mimoplot(varargin{:});
    end
  end
  return
end
no=nargout; ni=nargin;
model=varargin{1};
delvar=1; %varargin elements to be deleted
for ii=1:length(model)
  if isempty(model(ii).num), model(ii)=[]; end %This is a plot call without model
end
Fdat=[]; mscp=[]; mscii=[];
fullfig=1;
haxtmp=[]; xscale=''; flim=[]; mlim=[]; objtype='';
for ii=2:length(varargin)
  if isstr(varargin{ii})&~any(ii==delvar)
    if strcmpi(varargin{ii},'parent')
      fullfig=0;
      if ii==length(varargin), error('''parent'' is the last argument'), end
      haxtmp=varargin{ii+1};
      if strcmp(get(haxtmp,'type'),'figure')
        delete([findobj(haxtmp,'type','axes');findobj(haxtmp,'type','uicontrol')])
        figure(haxtmp);
        %haxtmp=subplot(1,1,1);
      end
      delvar=[delvar;ii;ii+1]; %these arguments are finished
    elseif strncmpi(varargin{ii},'xscale',3)
      xscale=varargin{ii+1};
      if strncmp(xscale,'li',2), xscale='lin';
      elseif strncmp(xscale,'lo',2), xscale='log';
      end
      delvar=[delvar;ii;ii+1]; %these arguments are finished
    elseif strncmpi(varargin{ii},'objtype',4)
      objtype=varargin{ii+1};
      delvar=[delvar;ii;ii+1]; %these arguments are finished
    elseif strncmpi(varargin{ii},'lin',3)|strncmpi(varargin{ii},'log',3)
      xscale=varargin{ii}(1:3);
      delvar=[delvar;ii]; %these arguments are finished
    elseif strncmpi(varargin{ii},'menu',4)
      if strcmp(varargin{ii+1},'on'), fullfig=1; end
      delvar=[delvar;ii;ii+1]; %these arguments are finished
    elseif strcmp(varargin{ii},'flim')
      flim=varargin{ii+1};
      delvar=[delvar;ii;ii+1]; %these arguments are finished
      if ~isempty(flim)
        if length(flim)~=2, error('flim is not a 2-element vector'), end
        if any(~isfinite(flim))|any(imag(flim))|any(flim<0)
          error('flim has illegal value')
        end
      end
    elseif (ii>2)&(length(varargin{ii})>1)
      error(['Illegal argument ',varargin{ii}])
    end
  end
end
if isempty(haxtmp)|((length(haxtmp)==1)&strcmp(get(haxtmp,'type'),'figure'))
  if isempty(haxtmp)
    hax1given=0;
    if strcmp(get(gcf,'handlevisibility'),'off')
      for ii=1:999
        if ~ishandle(ii), figure(ii), break, end
      end
    end
    hf=gcf;
  else %figure given
    hf=haxtmp; hax1given=1;
  end
  if strcmp(get(hf,'nextplot'),'add')
    %children are deleted to avoid erroneous plots later
    delete(get(hf,'children'))
  elseif strcmp(get(hf,'nextplot'),'replacechildren')
    delete(get(hf,'children'))
  elseif strcmp(get(hf,'nextplot'),'replace')
    delete(hf), hf=figure(hf);
  else
    error(['Value of ''nextplot=''',get(hf,'nextplot'),''' is not yet programmed'])
  end
  h=plot(1); delete(h)
  is2=0;
  for ii=2:length(varargin)
    if isstr(varargin{ii})&strcmp(varargin{ii},'2'), is2=1; break
    elseif isstr(varargin{ii})&strcmp(varargin{ii},'&'), is2=1; break
    elseif isstr(varargin{ii})&strcmp(varargin{ii},'#'), is2=1; break
    elseif isstr(varargin{ii})&strcmp(varargin{ii},'n'), is2=1; break
    elseif isstr(varargin{ii})&strcmp(varargin{ii},'s'), is2=1; break
    end
  end
  if is2
    hax1=subplot(2,1,2); hax2=subplot(2,1,1);
  else
    hax1=gca; hax2=[];
  end
else %given handle
  hax1given=1;
  %if isnumeric(haxtmp)&...
  if    ( ((size(haxtmp,2)==1)&(size(haxtmp,1)<3)) | ...
      ((size(haxtmp,1)==1)&(size(haxtmp,2)<3) ))
    %maybe axes handle(s)
    for ii=1:prod(size(haxtmp))
      if ~ishandle(haxtmp(ii))
        error('axhand contains non-handle element(s)')
      end
    end
    hax1=haxtmp(1); hax2=[];
    if length(haxtmp)>1, hax2=haxtmp(2); end
  else
    %error('Invalid handle')
  end
end
for ii=1:length(varargin)
  pari=varargin{ii};
  if ~isempty(delvar)&any(ii==delvar)
    %this is parent definition
  elseif isstr(pari)&(length(pari)==1)&any(findstr(pari,'+-*=rcNSnsabmd&#ABv@w12C'))
    %set msc
    mscp=pari; delvar=[delvar;ii];
    mscii=ii;  
  elseif isa(pari,'fiddata')
    Fdat=pari; delvar=[delvar;ii];
  else
    if ~isempty(pari)&~isa(pari,'fiddata')
      warning(['Invalid input parameter ''',pari,''''])
    end
  end
end %for ii
if isempty(objtype)
  if length(model)>1
    subs={':'  ':'  [1]}; strucref.type='()'; strucref.subs=subs;
    m1=subsref(model,strucref);
  else
    m1=model;
  end
  if length(m1)==1, objtype=get(m1,'errorweighting'); end
  if isempty(objtype)
    if fdtool('callback','guiinfos','islinear'), objtype='linear'; 
    else
      if israndomized(Fdat)&isempty(get(Fdat,'NonlinCovarianceMatrix')), objtype='interpnonlin';
      else objtype='Nonlinear';
      end
    end
  end
end
if (length(model)==0), data=get(model,'data');
else data=model(1).data;
end
if isempty(Fdat)&~isempty(data)&~isequal(mscp,'m'), Fdat=model(1).data; end
msc=mscp;
if isequal(msc,'m'), Fdat=[]; msc=''; end 
if isempty(msc)
  if isempty(Fdat)|isempty(model), msc='*';
  else msc='r'; 
  end
  %mscp=msc;
end
%if ~isempty(delvar), varargin(delvar)=[]; end
xlimmode='';
xlimmode=get(hax1,'xlimmode');
if strcmp(xlimmode,'manual')&isempty(flim)
  %flim=get(hax1,'xlim'); mlim=get(hax1,'ylim');
end
if strcmp(get(hax1,'xscale'),'log')
  xsc='log';
else
  xsc='lin';
end
if ~isempty(xscale), xsc=xscale; end
flim=[xsc+0,flim];
if hax1given, ntx='nomesg';
else ntx='nomesg'; 
end
var=[];
if ~isempty(model)&any(findstr(msc,'c'))
  if length(model)==1, var=model.covariance; end
  if any(isnan(var)), error('Covariance matrix contains NaN''s'), end
  ind=find(msc=='c'); msc(ind)='*';
elseif ~isempty(Fdat)&any(findstr(msc,'*NSnsabdv@w12'))
  if (Fdat.inputchnumber>1)|(Fdat.outputchnumber>1)
    warning('Plot of variances in not implemented for MIMO systems')
    var=[];
  %elseif any(findstr(msc,'b@w12'))
  %  var=sisononlinerror(Fdat);
  else
    var=Fdat.SisoVariance;
    freqs=get(Fdat,'frequencies');
    if ~isempty(freqs)&(size(var,1)>1)
      fp=get(Fdat,'freqpoints');
      ind=~ismember(fp,freqs);
      %var=var(ind,:); %eliminate nonexcited frequencies
      if ~isempty(ind), var(ind,:)=NaN*zeros(size(var(ind,:))); end
    end
  end
else
  var=[];
end
if isnumeric(var)&any(~isfinite(var(:))), var=[]; end
if isempty(model)&isempty(Fdat)
  error('Neither proper model, nor proper Fourier data are given')
end
%
if any(findstr(msc,'db'))
  if isempty(model)  
    warning(['No model given: plot modifier changed from ''',msc,''' to ''*'''])
    msc='*'; mscp=msc;
  elseif isempty(model(1).covariance)  
    warning(['No covariance given: plot modifier changed from ''',msc,''' to ''a'''])
    msc='a'; mscp=msc;
  elseif isempty(Fdat)
    warning(['No Fourier data given: plot modifier changed from ''',msc,''' to ''c'''])
    msc='*'; mscp=msc;
    var=model(1).covariance;
  elseif isempty(Fdat.SisoVariance)
    warning(['No variance given: plot modifier changed from ''',msc,''' to ''c'''])
    msc='*'; mscp=msc;
    var=model(1).covariance;
  end
end
if isempty(Fdat) & (any(findstr(msc,'r'))|any(findstr(msc,'a'))|...
    any(findstr(msc,'N'))|any(findstr(msc,'n'))|any(findstr(msc,'S'))|any(findstr(msc,'s')))
  warning(['No Fourier data given: plot modifier changed from ''',msc,''' to ''+'''])
  msc='+'; mscp=msc;
end
if ~isempty(Fdat)&isempty(var) & (any(findstr(msc,'a'))|any(findstr(msc,'N'))|...
    any(findstr(msc,'n'))|any(findstr(msc,'S'))|any(findstr(msc,'s')))
  warning(['No Fourier data given: plot modifier changed from ''',msc,''' to ''r'''])
  msc='r'; mscp=msc;
end
%
if strcmp(msc,'d')
  devplot=1; msc='a';
else
  devplot=0;
end
if msc=='#', msc='&'; var=Fdat.SiSoVariance; end
if (strcmp(msc(end),'1')|strcmp(msc(end),'2'))&isa(Fdat,'fiddata'), var=Fdat.SiSoVariance; end
if ~strcmp(msc,'A')&~strcmp(msc,'B')
  [h1,h2,fsc]=ploteltf(model,[],Fdat,flim,msc,var,[],[],[],[],ntx,[hax1;hax2],[],objtype);
else %A or B
  if isempty(model), error('The model object is empty')
  elseif ~isa(model,'fidmodel'), error('The object is not of class fidmodel')
  end
  hax1=subplot(2,1,1); hax2=subplot(2,1,2);
  if ~isempty(Fdat)
    fp=Fdat.freqpoints; if iscell(fp), fp=cat(1,fp{:}); end
    if length(flim)==3
      flim=[flim+0,min(fp),max(fp)];
    end
  end
  mm=model; mm.covariance=[]; mm.denom=[1];
  [h1,h2,fsc]=ploteltf(mm,[],[],flim,'',var,[],[],[],[],ntx,hax1);
  title(['B(',model.variable,')'],'parent',hax1)
  mm.num=model.denom;
  [h1,h2,fsc]=ploteltf(mm,[],[],flim,'',var,[],[],[],[],ntx,hax2);
  title(['A(',model.variable,')'],'parent',hax2)
end
%
if fullfig
  if ishandle(hax1), hf=get(hax1,'parent');
  elseif ishandle(hax2), hf=get(hax2,'parent');
  else hf=gcf;
  end
  if isempty(get(hf,'tag')), set(hf,'tag','fdident_object_plot'); end
  delete(findobj(hf,'tag','fdident_object_plot_menu'));
  set(hf,'UserData',{varargin,mscii,msc});
  hm=uimenu(hf,'label','&Type of Figure','tag','fdident_object_plot_menu');
  %
  if ~isempty(Fdat)|(~isempty(model)&~isempty(get(model,'data')))
    submenu(hm,'Amplitudes only','+',mscp,'amplitude')  
    submenu(hm,'Phases only','-',mscp,'phase')  
    submenu(hm,'Amplitudes and Phases','=',mscp,'amplitude_phase')  
    submenu(hm,'Input-Output Data','&',mscp,'input_output')  
    if (~isempty(Fdat)&~isempty(Fdat.covariance))|...
        (~isempty(model)&~isempty(get(model,'data'))&~isempty(get(get(model(1),'data'),'covariance')))
      submenu(hm,'Input-Output Data with std''s','#',mscp,'input_output_std')  
      submenu(hm,'Magnitudes and all std''s','*',mscp,'magnitude_std_nonlin')  
      submenu(hm,'Magnitudes and errors','@',mscp,'magnitude_errors')  
      submenu(hm,'Magnitudes and errors','w',mscp,'magnitude_weighting')  
      submenu(hm,'Output magnitudes and errors','1',mscp,'magnitude_errors_output')  
      submenu(hm,'I/O magnitudes and errors','2',mscp,'magnitude_errors_I/O')  
      submenu(hm,'Magnitudes and std''s','v',mscp,'magnitude_std')  
    end
  end
  if ~isempty(model)
    if isempty(mscp), mscp='r'; end %this is the default
    submenu(hm,'Parametric model only','m',mscp,'model')
    if ~isempty(get(model,'covariance'))
      submenu(hm,'Cloud of models','C',mscp,'model_cloud')  
    end      
    submenu(hm,'Model and std''s','c',mscp,'model_std')  
    if ~isempty(Fdat)|~isempty(get(model,'data'))
      submenu(hm,'Model with complex residuals','r',mscp,'model_residual')  
      if ~isempty(model)&~isempty(get(model,'data'))
        if ~isempty(get(get(model(1),'data'),'covariance'))
          submenu(hm,'Model with complex residuals + bounds','a',mscp,'model_residual_bound')
        end
        if ~isempty(get(get(model(1),'data'),'outputnonlinerror'))
          submenu(hm,'Model with complex residuals + bounds','b',mscp,'model_residual_bound')
        end
      end
    end
  end
  if ~isempty(Fdat)|~isempty(get(model,'data'))
    if isempty(mscp), mscp='*'; end %this is the default
    if (~isempty(Fdat)&~isempty(Fdat.covariance))|...
        (~isempty(model)&~isempty(get(model,'data'))&~isempty(get(get(model(1),'data'),'covariance')))
      submenu(hm,'FRF and SNR','S',mscp,'frf_snr')  
      submenu(hm,'FRF and NSR','N',mscp,'frf_nsr')  
      submenu(hm,'f-Y/f-U and SNR''s','s',mscp,'io_snr')  
      submenu(hm,'f-Y/f-U and NSR''s','n',mscp,'io_nsr')  
    end
    if ~isempty(model)
      submenu(hm,'Model, std''s and complex residuals','d',mscp,'model_std_residual')  
      uimenu(hm,'label','Poles/zeros','tag','fdident_object_plot_menu_poles_zeros',...
        'callback',['h_plot_obj=findobj(0,''tag'',''fdident_object_plot_menu'');',...
          'set(get(h_plot_obj,''children''),''checked'',''off''),',...
          'set(findobj(0,''tag'',''fdident_object_plot_menu_poles_zeros''),''checked'',''on''),',...
          'tmpmod=get(get(h_plot_obj,''parent''),''userdata'');',...
          'subplot(1,1,1); plotelpz(tmpmod{1}{1}),',...
          'clear tmpmod h_plot_obj']);
      if ~isempty(model(1).covariance)
        uimenu(hm,'label','Poles/zeros with confidences','tag','fdident_object_plot_menu_pzcov',...
          'callback',['h_plot_obj=findobj(0,''tag'',''fdident_object_plot_menu'');',...
            'set(get(h_plot_obj,''children''),''checked'',''off''),',...
            'set(findobj(0,''tag'',''fdident_object_plot_menu_pzcov''),''checked'',''on''),',...
            'tmpmod=get(get(h_plot_obj,''parent''),''userdata'');',...
            'subplot(1,1,1); plotelpz(tmpmod{1}{1},tmpmod{1}{1}.covariance),',...
            'clear tmpmod h_plot_obj']);
      end
    end
  end
end

if devplot==1
  hf=figure('visible','off');
  ha=subplot(1,1,1); set(ha,'visible','off')
  h1m=ploteltf(model(1),[],[],[flim,fsc*max([get(h1,'xlim');0,0])],'*',model(1).covariance);
  set(h1m,'visible','off'), set(hf,'visible','off')
  he=findobj(h1m,'tag','errorplot');
  %y=get(he,'ydata');
  if ~isempty(he)
    ymin=min(get(h1m,'ylim'));
    set(he,'parent',h1)
    yl=get(h1,'ylim'); yl(1)=min(yl(1),ymin(1)); set(h1,'ylim',yl)
    %y2=get(he,'ydata');
    %1;
    %set(h1,'ylimmode','auto')
  else
    warning('errorplot not found')
  end
  delete(hf)
end
%
if ~isempty(mlim), set(hax1,'ylim',mlim), end
if no>=1, handles=findobj([h1;h2],'type','line','visible','on'); end
%
%End of function @fidmodel/plot

function submenu(hm,label,mark,mscp,tagend)
hp=uimenu(hm,'label',[label,' (',mark,')'],...
  'tag',['fdident_object_plot_menu_',tagend],...
  'callback',['fdtool(''callback'',''plotwrap'',''',['uic_',mark],''',''fdident_object_plot_menu_',tagend,''');']);
if mark=='&', set(hp,'label',[label,' (',mark,mark,')']); end
if strcmp(mscp,mark), set(hp,'checked','on'); end
  
function handles=mimoplot(varargin)
handles=[];
no=nargout; ni=nargin;
delvar=1; %varargin elements to be deleted
model=varargin{1}; hftmp=[]; chcell={};
fullfig=1;
for ii=2:length(varargin)
  if ~any(ii==delvar)
    if isstr(varargin{ii})&strcmp(varargin{ii},'parent')
      fullfig=0;
      if ii<length(varargin)
        hftmp=varargin{ii+1}; delvar=[delvar;ii;ii+1];
      else
        error('parent'' without value')
      end
    elseif isstr(varargin{ii})&strncmp(varargin{ii},'ch',2)
      if ii<length(varargin)
        hftmp=varargin{ii+1}; delvar=[delvar;ii;ii+1];
      else
        error('''channels'' without value')
      end
      if ii<length(varargin)
        chcell=varargin{ii+1}; delvar=[delvar;ii;ii+1];
      else
        error('''channel'' without value')
      end      
    elseif isstr(varargin{ii})&strcmp(varargin{ii},'=')
      warning('msc is not allowed to be ''='' for MIMO, changed to ''*''')
      varargin{ii}='*';
    end
  end
end %for ii
varargin(delvar)=[];
if isempty(hftmp), hftmp=gcf; end
delete([findobj(gcf,'type','axes');findobj(gcf,'type','uicontrol')])
if ~isempty(get(model,'num'))
  ic=size(get(model,'num'),2);
  oc=size(get(model,'num'),1);
else
  ic=get(varargin{1},'inputchnumber');
  oc=get(varargin{1},'outputchnumber');
end
if isempty(chcell)
  cii=0;
  for oci=1:min(2,oc)
    for ici=1:min(2,ic)
      cii=cii+1;
      chcell{1,cii}=sprintf('%.0f/%.0f',oci,ici);
    end
  end
end
for ii=1:length(chcell)
  if ~isempty(chcell{ii})
    ind=findstr(chcell{ii},'/');
    oci=str2num(chcell{ii}(1:ind-1));  
    ici=str2num(chcell{ii}(ind+1:end));
    h=subplot(2,2,ii);
    %str=struct('type','()'); str.subs={oci,ici,':'};
    if ~isempty(get(model,'num'))
      modi=subsref(model,struct('type','()','subs',{{oci,ici,':'}}));
      vararginpl=[varargin,{'parent',h}];
      hi=plot(modi,vararginpl{:});
    else %empty model
      if isa(varargin{1},'fiddata')
        fdi=subsref(varargin{1},struct('type','()','subs',{{':',oci,ici}}));
      end
      vararginpl=[varargin(2:end),{'parent',h}];
      hi=plot(fdi,vararginpl{:});
    end
    handles=[handles;hi];
    str=get(get(h,'title'),'string');
    set(get(h,'title'),'string',[sprintf('o%.0f/i%.0f: ',oci,ici),str]);
  end
end
%