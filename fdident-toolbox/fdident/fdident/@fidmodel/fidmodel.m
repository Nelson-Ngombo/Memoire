function model = fidmodel(varargin)
%       FIDMODEL Creator function for the FIDMODEL data object.
%       If strucv is given, it is transformed into an fidmodel object.
%       If all arguments are missing, a 'skeleton' fidmodel object is created.
%       Basic calls:
%           model=fidmodel;
%           model=fidmodel(struct)
%           model=fidmodel(tfmodel) %tf object
%           model=fidmodel(theta,N,freqv) %Model conversion from the
%                   System Identification Toolbox theta format
%               N = length of the data record (number of FFT points)
%               freqv = vector of frequencies where the variance is required
%           model=fidmodel(oldobject);
%           model=fidmodel(variable,num,denom,delay,fs,CR,...
%                      fp,ntr,Znum,Zdenom,Zntr,freqvect);
%       In the case of the last call form the input arguments are:
%       variable = 's' or 'z^-1' or 'w' or 'r' or 'p', depending on the domain;
%       num = numerator vector, coefficients of 1/z in ascending order,
%           or coefficients of s in descending order
%           for orthopol, Znum contains the weights to calculate
%               the numerator polynomial, but this is should be avoided
%               because it is usually very badly conditioned
%       denom = denominator vector, coefficients of 1/z in ascending order,
%           or coefficients of s in descending order
%           for orthopol, Zdenom contains the weights to calculate
%               the numerator polynomial, but this is should be avoided
%               because it is usually very badly conditioned
%       delay = additional delay
%       fs = sampling frequency in the z-domain
%           In the s-, r-, and w-domain, fs is the scaling frequency between the
%           internal representation, and the object, given in Hz.
%       CR = Cramer-Rao bound of estimated parameters
%       fp = vector of indices of fixed parameters in the vector [num denom ntr delay]
%           in ntr is not incorporated into the model, it is treated as empty vector
%       ntr = numerator of the transient numerator
%       Two (three) arguments for orthogonal polynomial representation
%          for regular polynomial coefficients, they are empty:
%       Znum = orthogonal polynomial weights for numerator (see orthopol)
%       Zdenom = orthogonal polynomial weights for denominator (see orthopol)
%       Zntr = orthogonal polynomial weights for transient numerator (see orthopol)
%       freqvect = vector of non-scaled frequencies (necessary for orthopol)
%
%       Usage: model = fidmodel(variable,num,denom,delay,fs,CR,fp,...
%                              ntr,Znum,Zdenom,Zntr,freqvect);
%       Examples:
%          pvect=fidmodel('s',[1,1],[1,2,3,4]);
%          type 'tiddata examples'
%
%       See also: EXPPAR, IMPPAR.
%
%       For mode detailed help, type help(fidmodel) or help(fidmodel,<property>)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2010
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Aug-2010

if (nargin==1)&isstr(varargin{1})
  if strncmp(varargin{1},'examples',2)
    type fidmodel_examples.m, return
  elseif strncmpi(varargin{1},'date',3)
    fid=fopen(which(['@fidmodel',filesep,'Contents.m']),'r');
    e=setstr(fread(fid,2000)'); fclose(fid);
    ind=findstr('Version',e);
    if isempty(ind), error('String ''Version'' not found'), end
    ee=e(ind(1)+[1:50]);
    ind=find(isspace(ee)); d=ee(ind(2)+1:ind(3)-1);
    if (length(d)~=11)|(sum(~isletter(d))~=8)|~strcmp(d([3,7:8]),'--2')
      %06-Jan-2001
      error('Date is not found')
    end
    if nargout>0
      pdat=d;
    else
      disp(['Date of the fidmodel object directory: ',d])
      w=which(['@fidmodel',filesep,'fidmodel.m']);
      dd=dir(w);
      %fprintf(['Date of the file fidmodel.m: ',dd.date,'\n'])
    end
    return    
  end
end
mversion=2.2; %current version of model object
%
ni = nargin;
conschk=1; %consistency check on
if (ni>0)&isstr(varargin{end})&strcmp(varargin{end},'noconsistency')
  varargin(end)=''; ni=ni-1; conschk=0;
end
if ni==1 %strucv is converted
  strucv=varargin{1};
  if isempty(strucv)&isa(strucv,'double'), model=strucv; return, end
  if isa(strucv,'struct')&~isfield(strucv,'lti') %lti means tf converted to struct
    if length(strucv)==1
      %maybe earlier model (idmodel): rearrange fields
      if ~isfield(strucv,'num')|~isfield(strucv,'denom')
        error('There is no field num in the structure')
      end
      fnames=fieldnames(strucv);
      if isfield(strucv,'Variable') %exported without object present
        model=fidmodel(strucv.Variable,strucv.num,strucv.denom);
        for fn={'Variable','num','denom'}
          ind=strmatch(fn{1},fnames); fnames(ind)=[]; 
        end
        for ii=1:length(fnames)
          Prop=fnames{ii}; Value=getfield(strucv,Prop);
          if strcmp(Prop,'Data')&isstruct(Value)
            Value=fiddata(Value);
            %Value=[];
          end
          set(model,Prop,Value,'noconsistency');
        end
      else %old object
        strucv2=[];
        if isfield(strucv,'version'), vfdm=strucv.version; else vfdm=mversion; end
        if any(vfdm==[2.0,2.1])
          warning(sprintf(['Earlier fidmodel object version %.1f is converted ',...
              'to current fidmodel'],vfdm))
        elseif ~any(vfdm==[2.2])
          error(sprintf('Unknown input version: %.4g',strucv.version))
        end
        if vfdm==2.0
          strucv2=[];
          strucv.version=2.1;
          for ii=1:size(fnames,1)
            if strcmpi(fnames{ii},'chdelays')
            elseif strcmpi(fnames{ii},'chgroups')
            elseif strcmpi(fnames{ii},'chnames')
            elseif strcmpi(fnames{ii},'chtypes')
            elseif strcmpi(fnames{ii},'units')
            elseif strcmpi(fnames{ii},'delays')
              strucv2=setfield(strucv2,'delay',getfield(strucv,fnames{ii}));
              strucv2=setfield(strucv2,'outputdelay',[]);
              strucv2=setfield(strucv2,'inputdelay',[]);
              strucv2=setfield(strucv2,'outputgroup',cell(0,2));
              strucv2=setfield(strucv2,'inputgroup',cell(0,2));
              strucv2=setfield(strucv2,'outputname','');
              strucv2=setfield(strucv2,'inputname','');
              strucv2=setfield(strucv2,'outputunit','');
              strucv2=setfield(strucv2,'inputunit','');
            else
              strucv2=setfield(strucv2,fnames{ii},getfield(strucv,fnames{ii}));
            end
          end %for ii
          strucv=strucv2;
        end
        if vfdm==2.1
          if ~isempty(strucv.data), strucv.data=fiddata(strucv.data); end  
          strucv.version=mversion;        
          strucv.newproperties=[];  
        end
        model=class(strucv,'fidmodel');
      end
      if (conschk==1)&~get(model,'consistency'); %consistency check
        error('fidmodel object given in strucv is inconsistent: see the warning message above for the reason')
      end
    else %struct array
      if ndims(strucv)>2, error('Cannot handle multidimensional arrays'), end
      [sv,sh]=size(strucv);
      model=fidmodel;
      for ii=2:sh, model=stack(2,model,fidmodel); end
      for ii=2:sv, model=stack(1,model,model(1,:)); end
      for ii=1:prod(size(strucv)), model(ii)=fidmodel(strucv(ii)); end 
    end
    %
    return
  elseif isa(strucv,'fidmodel')
    if length(strucv)==1
      if any(strucv.version==[1.2,2.0,2.1])
        %This is a temporary branch only: old versions will load as structures
        warning(sprintf('Obsolete model version %.1f is detected',strucv.version))
        %fixing here:
        model=fidmodel(struct(strucv));
      elseif strucv.version==mversion %current
        model=strucv; %return without anything to do
      else
        error('Unknown model version')
      end
    else %object vector or array
      ss=struct(strucv); vmd=[];
      for ii=1:prod(size(ss)), vmd=[vmd;ss(ii).version]; end
      model=strucv;
      if all(vmd==mversion)
        %OK, nothing to do
      else
        warning('Obsolete model version detected')
        for ii=1:prod(size(model)), model(ii)=fidmodel(strucv(ii)); end
      end
    end
    return
  elseif isa(strucv,'lti') | (isstruct(strucv)&isfield(strucv,'lti'))
    %lti object (or structure) is converted
    if isa(strucv,'frd')
      error('Cannot convert frd object to fidmodel')
    else
      %s=struct(strucv); slti=struct(s.lti); 
      %try, Version=slti.Version; catch, Version=4; end 
      %if Version>4
      %  warning('New lti model version: conversion routine fidmodel may need updating')
      %end
      if exist('tf'), ml=tf(strucv); else ml=strucv; end
      variable=ml.Variable;
      convz=0;
      if strcmp(variable,'z')
        if isstruct(ml)
          variable='z^-1';
          convz=1;
        else
          set(ml,'Variable','z^-1') %conversion
          variable=ml.Variable;
        end
      end
      num=ml.num;
      if length(num)==1, num=num{1};
      elseif isempty(num), num=[];
      else %error('MIMO conversion from lti to fidmodel is not yet ready')
      end
      if strcmp(variable,'z^-1')
        if isnumeric(num)
          while (length(num)>1)&(num(end)==0), num(end)=[]; end
        else
          for ii=1:prod(size(num))
            while (length(num{ii})>1)&(num{ii}(end)==0), num{ii}(end)=[]; end
          end
        end
      else %s
        if isnumeric(num)
          while (length(num)>1)&(num(1)==0), num(1)=[]; end
        else
          for ii=1:prod(size(num))
            while (length(num{ii})>1)&(num{ii}(1)==0), num{ii}(1)=[]; end
          end
        end
      end
      denom=ml.den;
      if length(denom)==1, denom=denom{1};
      elseif isempty(denom), denom=[];
      else 
        CD=1;
        for ii=2:prod(size(denom))
          if ~isequal(denom{1},denom{ii}), CD=0; break, end
        end
        if CD
          denom=denom{1};
        else
          error('MIMO conversion from lti to fidmodel is not yet ready')
        end
      end
      if convz==1
        ln=length(num); ld=length(denom);
        num=[num,zeros(1,ld-ln)];
        denom=[denom,zeros(ln-ld)];
      elseif strcmp(variable,'s')
        while (length(denom)>1)&(denom(1)==0), denom(1)=[]; end
      end
      if isstruct(ml), ml=ml.lti; end 
      Ts=ml.Ts; if Ts==0, fs=1; else fs=1/Ts; end
      %if Version==1
      %  OutputDelay=ml.Td; InputDelay=0;
      %  InputGroup=cell(0,2); OutputGroup=cell(0,2);  
      %else %Version 2
        InputDelay=ml.InputDelay;
        if iscell(InputDelay)&(length(InputDelay)==1)&isempty(InputDelay{1})
          InputDelay=[];
        end
        OutputDelay=ml.OutputDelay;
        if iscell(OutputDelay)&(length(OutputDelay)==1)&isempty(OutputDelay{1})
          OutputDelay=[];
        end
        InputGroup = ml.InputGroup;
        OutputGroup = ml.OutputGroup;
      %end
      InputName=ml.InputName; if length(InputName)==1; InputName=InputName{1}; end
      OutputName=ml.OutputName; if length(OutputName)==1; OutputName=OutputName{1}; end
      Notes=ml.Notes; if isempty(Notes), Notes=''; end
      UserData=ml.UserData;
      %
      model=fidmodel(variable,num,denom,OutputDelay-InputDelay,fs);
      if ~isempty(InputName)|~isempty(OutputName)
        set(model,'OutputName',OutputName,'InputName',InputName,'noconsistency');
      end
      if ~isempty(InputGroup)|~isempty(OutputGroup)
        set(model,'OutputGroup',OutputGroup,'InputGroup',InputGroup,'noconsistency');
      end
      set(model,'Notes',Notes,'UserData',UserData,'noconsistency')
      if (conschk==1)&~get(model,'consistency')
        error('Inconsistent model after conversion: see the warning message above for the reason')
      end
    end
  elseif isa(strucv,'idmodel') %SITB model
    model=idmodel2fidmodel(varargin{:});  
  elseif isa(strucv,'idarx') %SITB model
    model=idmodel2fidmodel(varargin{:});  
  elseif isa(strucv,'double')&(size(strucv,2)>=9)
    model=fidmodel(strucv,[],[]);
  else %other classes
    %Check type - strucv may be an old structure version (column vector or string)
    if isa(strucv,'double')&(size(strucv,1)>1)&(size(strucv,2)==1) %maybe imppar vect
    elseif isa(strucv,'char')&(size(strucv,2)>1)&(size(strucv,1)==1) %maybe file name
    elseif isa(strucv,'char')
      error('Single argument may not be a character')
    else
      error(['Invalid strucv'])
    end
    %Maybe imppar data?
    eval(['[domain,num,denom,delay,fs,Znum,Zdenom,cms,fdate,ntr,Zntr]=',...
        'imppar(strucv); imppok=1;'],'imppok=0;')
    if imppok==1 %indeed imppar
      if strcmp(domain,'z'), variable='z^-1';
      elseif strcmp(domain,'p'), variable='s';
      else variable=domain;
      end
      model=fidmodel(variable,num,denom,delay,fs,[],[],ntr,Znum,Zdenom,Zntr);
      return
    else %unusable strucv
      fprintf(lasterr)
      error('Cannot convert input into fidmodel')
    end
  end %if strucv
  return
end
%
if ni>=1
  strucv=varargin{1};
  if isa(strucv,'double')&(size(strucv,2)>=9)&(nargin<=3)
    %Probably theta-format
    if (ni==1)|isempty(varargin{2})
      vc=0; varargin{2}=128; varargin{3}=[0.05:0.05:0.45]/strucv(1,2);
    else
      vc=1;
    end
    delay=0;
    [num,denom,delay,fs,vary,ccovar,domain]=tha2elis(varargin{:});
    if strcmp(domain,'s'), variable='s';
    else variable='z^-1';
    end
    model=fidmodel(variable,num,denom,delay,fs,ccovar);
    if vc==1
      fv=varargin{3};
      NaNv=NaN;
      data=fiddata(NaNv(size(fv)),ones(size(fv)),fv,2*vary,0*vary);
      model.data=data;
    end
    return
  end
end %theta format?
%
%Now new model is generated from parameters
%
%All props
props = ['|name|version|date|notes|history|data|algorithm|userdata|',...
    'variable|representation|num|denom|C|D|F|ntr|',...
    'Znum|Zdenom|Zntr|freqvect|fs|',...
    'delay|outputdelay|inputdelay|outputgroup|inputgroup|',...
    'outputname|inputname|outputunit|inputunit|',...
    'covariance|fixedpars|fitinfo|varet|newproperties|'];
ind=find(props=='|');
model=[]; fs=[];
for ii=1:length(ind)-1
  if any(findstr(['|',props(ind(ii)+1:ind(ii+1)-1),'|'],...
      ['|name|date|notes|history|',...
        'variable|representation|',...
        'outputname|inputname|outputunit|inputunit|']))
    propv='';
  elseif strcmpi(props(ind(ii)+1:ind(ii+1)-1),'inputgroup')|...
    strcmpi(props(ind(ii)+1:ind(ii+1)-1),'outputgroup')
    propv=cell(0,2);
  else
    propv=[]; 
  end
  model=setfield(model,props(ind(ii)+1:ind(ii+1)-1),propv);
end
%
model.version=mversion;
model.representation='polynomial';
model.variable='s'; %set default
%
if ni==0 %nothing to do
elseif ni==1, error('Programming error: one argument is already done')
elseif ni==2, error('Two arguments are not allowed')
else %ni>=3
  %Define property values.
  variable=varargin{1};
  if ~isstr(variable)
    error('variable is not a string')  
  elseif strcmp(variable,'z')
    warning('Variable is ''z'' instead of ''z^-1'': value has been corrected')
    variable='z^-1';
  elseif strcmp(variable,'p')
    variable='s';
    if (nargin<9)|isempty(varargin{9})
      error('Domain is ''p'', but Znum is empty')
    end
  elseif strcmp(variable,'q')
    variable='z^-1';
    if (nargin<9)|isempty(varargin{9})
      error('Domain is ''q'', but Znum is empty')
    end
  elseif any(findstr(['|',variable,'|'],'|z^-1|s|w|r|'))
  else
    error(['Illegal variable ''',variable,''''])
  end
  model.variable=variable;
  num=varargin{2};
  denom=varargin{3};
  if iscell(num)&iscell(denom)
    if any(size(num)~=size(denom))
      if length(denom)==1, denom=denom{1};
      else error('Sizes of num and denom do not match')
      end
    end
  end
  model.num=num; model.denom=denom;
  for ii=length(varargin)-1:-1:4 %check if argument 'Coefficients' or 'tauR' is given
    if isstr(varargin{ii})&strncmpi(varargin{ii},'Coefficients',5)&(length(varargin)>ii)
      if isstr(varargin{ii+1})
        if strncmpi(varargin{ii+1},'complex',1)
          model.newproperties.Coefficients='complex';
        elseif strncmpi(varargin{ii+1},'real',1)
          model.newproperties.Coefficients='real';
        elseif isempty(varargin{ii+1})
          %nothing to do
        else
          error('''Coefficients'' value is invalid')
        end
        varargin(ii:ii+1)=[]; ni=ni-2;
      else
        error('''Coefficients'' value is invalid')
      end
    else
      if isstr(varargin{ii})&strncmpi(varargin{ii},'tauR',4)&(length(varargin)>ii)
        if isnumeric(varargin{ii+1})
          if ~isempty(varargin{ii+1})&(variable=='r')
            model.newproperties.tauR=varargin{ii+1};
          end
          varargin(ii:ii+1)=[]; ni=ni-2;
        else
          error('''tauR'' value is invalid')
        end
      end
    end
  end %for ii
  %
  if (variable=='r')&~isfield(model.newproperties,'tauR')
    error('tauR is not given for variable ''r''')
  end
  %
  if ni<4, delay=[]; else delay=varargin{4}; end, if isempty(delay), delay=0; end
  model.delay=delay;
  fsc=1; fscp=1;
  if ni>=5
    fs=varargin{5};
    if isempty(fs), fs=[]; end
    if any(findstr('z',variable))|(fs>0), model.fs=fs; end
    fsc=model.fs;
    if strcmp(variable,'s'), fscp=model.fs;
    elseif strcmp(variable,'w'), fscp=sqrt(model.fs);
    elseif strcmp(variable,'r')
      model.newproperties.tauR=model.newproperties.tauR/fs;
    end
  end
  if any(findstr('z',variable))&isempty(fs)
    if ~any(isnan(num))&~any(isnan(denom))
      error('For discrete models fs must be given')
    else
      fs=NaN;
    end
  end
  if (ni>=6)&~isempty(varargin{6}), CR=varargin{6}; else CR=[]; end
  if (ni>=8)&~isempty(varargin{8}), ntr=varargin{8}; model.ntr=ntr; else ntr=[]; end
  if (ni>=7)&~isempty(varargin{7})
    fp=varargin{7}; model.fixedpars=fp;
    if length(fp)+size(CR,1)==(length(num)+length(denom)+length(ntr)+1)
      for ii=sort(fp(:))'
        CR=[CR(:,1:ii-1),zeros(size(CR,1),1),CR(:,ii:end)];   
        CR=[CR(1:ii-1,:);zeros(1,size(CR,2));CR(ii:end,:)];   
      end
    end
  end
  if ~isempty(CR), model.covariance=CR; end
  if (ni>=9)&~isempty(varargin{9}), model.Znum=varargin{9}; end
  if ~isempty(model.Znum), model.representation='orthopol'; end
  if (ni>=10)&~isempty(varargin{10}), model.Zdenom=varargin{10}; end
  if (ni>=11)&~isempty(varargin{11}), model.Zntr=varargin{11}; end
  if (ni>=12)&~isempty(varargin{12}), model.freqvect=varargin{12}; end
  if ~isequal(fsc,1)&~isempty(fsc)
    if (strcmp(model.variable,'s')|strcmp(model.variable,'w'))&...
        strcmp(model.representation,'polynomial')
      on=length(model.num); model.num=model.num./fscp.^[on-1:-1:0];
      od=length(model.denom); model.denom=model.denom./fscp.^[od-1:-1:0];
      model.delay=model.delay/fsc;
      fscv=[fscp.^[od-1:-1:0],fscp.^[od-1:-1:0]];
      ont=length(model.ntr);
      if ont>0
        model.ntr=model.ntr./fscp.^[ont-1:-1:0];
        fscv=[fscv,fscp.^[ont-1:-1:0]];
      end
      fscv=[fscv,1/fsc];
      if ~isempty(model.covariance)
        model.covariance=model.covariance./(fscv'*fscv);
      end
      model.freqvect=fsc*model.freqvect;
    end
  end
end %ni=3
model.date=datestr(now);
%
model=class(model,'fidmodel');
%
if ni>=3
  %save scaling
  if (strcmp(variable,'s')|strcmp(variable,'w'))&...
      strcmp(model.representation,'polynomial')
    fscale=1;
    %
    sctype='roots';
    fscale=fdident('private','optfscale',model.num,model.denom,model.variable,sctype);
    %
    if strcmp(variable,'s'), set(model,'fscale',fscale);
    elseif strcmp(variable,'w'), set(model,'fscale',fscale^2);
    end
  end
end
%
if (conschk==1)&~get(model,'consistency'); %consistency check
  error('Generated fidmodel object is inconsistent: see the warning message above for the reason')
end
%  
%End @fidmodel/fidmodel

function model=idmodel2fidmodel(varargin)
%IDMODEL2FIDMODEL  Convert models from SITB to FDIDENT
lv=length(varargin);
theta=varargin{1};
if lv<2, N=1024; else N=varargin{2}; end
if lv<3, freqv=[1:10]'; else freqv=varargin{3}; end
[num,denom,delay,fs,vary,ccovar,domain]=tha2elis(theta,N,freqv);
if ndims(num)==3
  num=permute(num,[3,1,2])';
elseif ndims(num)>3
  error('num is at least 4-dimensional')
end
if ndims(denom)==3
  denom=permute(denom,[3,1,2])';
elseif ndims(denom)>3
  error('denom is at least 4-dimensional')
end
if strcmp(domain,'s'), fs=1;
elseif strcmp(domain,'z')
else error(['Unknown domain ''',domain,''''])
end
model=fidmodel(domain,num,denom,delay,fs);
set(model,'Covariance',ccovar)
%
%End of file @fidmodel/fidmodel.m