function dat = tiddata(varargin)
%TIDDATA Creation function for the TIDDATA data object (time domain data).
%
%       Arguments:
%       y - Output data, time domain samples (column vector, cell array or empty)
%          Multiexperiment arrays (samples x expno) can be given as num2cell(yarr,1)
%       u - Input data, time domain samples (column vector, cell array or empty)
%          Multiexperiment arrays (samples x expno) can be given as num2cell(yarr,1)
%       Ts - sampling interval
%       oname - Name(s) of output channel(s) (string, cell or empty)
%       iname - Name(s) of input channel(s) (string, cell or empty)
%       ounit - Name(s) of output unit(s) (string, cell or empty)
%       iunit - Name(s) of input unit(s) (string, cell or empty)
%       By default, both the input and output characters of the generated
%       object are 'BL'. To have a 'ZOH'/'Samples' pair, give the
%       last argument as 'BL', or set the properties 'InputCharacter' and
%       'OutputCharacter' after creation.
%
%       In order to obtain a detailed list of properties and possibilities,
%       type 'help(tiddata)' 'help(tiddata,<property>)', or 'helpc(tiddata)'
%
%       Usage: 
%          tiddata(y,u,Ts);
%          tiddata(obj);
%          tiddata(y,u,Ts,oname,iname,ounit,iunit);
%       Examples:
%          t=tiddata(randn(5,1),ones(5,1),1e-3)
%          set(t,'name','mydata')
%          t2=tiddata(randn(5,1),ones(5,1),1e-3,'Output','Input','ZOH')
%          type 'tiddata examples'
%
%       See also: TIDINP, TIDOUTP

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2016
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-May-2016

ni=nargin;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(0,8); %Matlab 2016a or later
else ni=nargin; error(nargchk(0,8,ni)), %earlier
end
dversion=1.3; %Current version of object
%
if (nargin>=1)&isa(varargin{1},'fiddata')
  %conversion of fiddata object to tiddata
  if nargin<3
    fs=get(varargin{1},'Fs');
    if ~isempty(fs)&(length(fs)==1)&isfinite(fs)&(imag(fs)==0)&(fs>0)
      if nargin<2
        error(sprintf(['fiddata object can be converted to tiddata only if N is given, like:\n',...
            '  tdat=tiddata(fdat,N);']))
      end
    else
      error(sprintf(['fiddata object can be converted to tiddata only if N and fs are given, like:\n',...
          '  tdat=tiddata(fdat,N,fs);']))
    end
  else
    fs=varargin{3};
  end
  N=varargin{2};
  dat=fou2tim(varargin{1},N,fs);
  return
end
%
%inchar='ZOH'; outchar='Samples'; %ident toolbox defaults
inchar='BL'; outchar='BL'; %fdident toolbox defaults
if ni>=1, y=varargin{1}; else y=[]; end
if isempty(y), y=[]; end
if ni>=2, u=varargin{2}; else u=[]; end
if isempty(u), u=[]; end
if isnumeric(u)&(length(u)>1)&all(diff(abs(u))==0)
  %inchar='ZOH'; outchar='Samples';
end
if (nargin>=1)&isstr(varargin{end}) %maybe 'ZOH' or 'band-limited' is given
  if strcmpi(varargin{end},'band-limited')|...
      strcmpi(varargin{end},'bandlimited')|...
      strcmpi(varargin{end},'BL')
    inchar='BL'; outchar='BL';
    varargin(end)=[]; ni=ni-1;
  elseif strcmpi(varargin{end},'zero-order hold')|strcmpi(varargin{end},'ZOH')
    inchar='ZOH'; outchar='Samples';
    varargin(end)=[]; ni=ni-1;
  elseif strcmpi(varargin{end},'ZOHf')
    inchar='ZOHf'; outchar='Samples';
    varargin(end)=[]; ni=ni-1;
  end
end
%
if ni==1 %one argument: convert struct to object or fix object
  if isstr(varargin{1})&strncmp(varargin{1},'examples',2)
    type tiddata_examples.m, return
  end
  strucv=varargin{1}; %convert structure to object
  %
  if isa(strucv,'tiddata')
    if length(strucv)>1, error('strucv is an array'), end
    tid=tiddata; id=iddat; s=struct(strucv); sid=s.iddat;
    if (get(strucv,'Version')==tid.Version)&(get(sid,'Version')==id.Version)
      dat=strucv; return %nothing to do
    end
    strucv=struct(strucv); %Maybe old tiddata? Handle as structure
  elseif isa(strucv,'iddata')
    dom=get(strucv,'domain');
    if strcmpi(dom,'time')
      dat=iddat(strucv);
      return
    else
      error([Cannot transform iddata object of domain ''',dom,''' to tiddata'])
    end
  end
  if isa(strucv,'struct')
    %Either result of load of old version, or structure to be converted
    %Here handle earlier versions loaded from MAT-files
    %
    if isfield(strucv,'Version'), sversion=strucv.Version; else sversion=[]; end
    if sversion<dversion
      warning(sprintf(['Earlier tiddata object version %.1f is found, ',...
          'converted to current tiddata'],sversion))
    end
    if isempty(sversion)|any(sversion==[1.1,1.2,1.3])|(sversion>1.3)
      fnames=fieldnames(strucv);
      if ~isfield(strucv,'iddat') %exported from object
        dat=tiddata(strucv.Output,strucv.Input,strucv.Ts);
        for fn={'Output','Input','Ts','Information','ChNumber'}
          ind=strmatch(fn{1},fnames); if ~isempty(ind), fnames(ind)=[]; end 
        end
        for ii=1:length(fnames)
          Prop=fnames{ii}; Value=getfield(strucv,Prop);
          set(dat,Prop,Value,'noconsistency');
        end
      else %struct(obj)
        if ~isfield(strucv,'Ts')
          error('There is no field Ts in the structure')
        elseif ~isfield(strucv,'iddat')
          error('There is no field iddat in the structure')
        end
        p=strucv.iddat; strucv=rmfield(strucv,'iddat');
        if ~isfield(strucv,'NewProperties'), strucv.NewProperties=[]; end
        strucv.Version=dversion;
        if ~isa(p,'iddat'), p=iddat(p); end
        dat=class(strucv,'tiddata',p); %set class
        set(dat,'Version',get(dat,'Version')); %consistency check
        %elseif any(strucv.Version==1.4)
        %warning('Earlier tiddata object is found, converted to current tiddata')
      end
    else
      error(sprintf('tiddata version %.3g cannot be converted',strucv.Version))
    end
    return
  elseif isa(strucv,'cell')
    for ii=1:prod(size(strucv))
      strucv{ii}=tiddata(strucv{ii});
    end
    dat=strucv;
    return
  elseif (isstr(strucv)&(size(strucv,1)==1)) | ...
      (isnumeric(strucv)&(size(strucv,2)==1))
    %maybe file of parameter vector
    if isstr(strucv)
      [filenl,fn,ext]=fnamanal(strucv);
      if ~strncmp(ext,'t',1)
        error('File is not time file')
      end
    end
    try
      [timevect,xt,yt,expno,fv,vdat,comments,fdate]=imptim(strucv);
      N=size(timevect,1);
      [v,h]=size(yt); expno=round(v/N); chno=h; 
      yc=yt;
      if (chno>1)|(expno>1)
        yc=cell(chno,expno);
        for ii=1:chno
          for iii=1:expno
            yc{ii,iii}=yt((iii-1)*N+[1:N],ii);
          end
        end
      end
      [v,h]=size(xt); expno=round(v/N); chno=h; 
      xc=xt;
      if (chno>1)|(expno>1)
        xc=cell(chno,expno);
        for ii=1:chno
          for iii=1:expno
            xc{ii,iii}=xt((iii-1)*N+[1:N],ii);
          end
        end
      end
      dt=mean(diff(timevect));
      if rem(diff(timevect)+dt/2,dt)-dt/2<1e-6*dt
        dat=tiddata(yc,xc,dt);
      else
        dat=tiddata(yc,xc); set(dat,'samplinginstants',timevect);
      end
      if ~isempty(fv), set(dat,'frequencies',fv); end
      if ~isempty(vdat)
        try, set(dat,'SiSoVariance',vdat); 
        catch
          warning('Cannot set SisoVariance')
        end
      end
      set(dat,'notes',comments,'date',fdate)
    catch
      error(['Class of strucv is ''',class(strucv),''', cannot convert it'])
    end
    return
  else
    error(['Class of strucv is ''',class(strucv),''''])
  end
end

%Creator function: read inputs
Ts=[]; oname=''; iname=''; ounit=''; iunit='';
%
chout=0; nsy=0; expnoy=0;
if ~isempty(y)
  if size(y,3)>1, error('y is a 3-D array'), end
  if isa(y,'double')
    if any(imag(y(:))~=0), error('Complex element in y'), end
    [nsy,chout]=size(y); yd=y; y={yd(:,1)};
    if (nsy==1)&(chout>1)
      warning(sprintf('y contains %.0f samples x %.0f experiments',nsy,chout))
    end
    for ii=2:chout, y{ii,:}=yd(:,ii); end %Make cell array
    expnoy=size(y,2);
  elseif iscell(y)
    [chout,expnoy]=size(y);
    for ii=1:chout*expnoy
      if any(imag(y{ii}(:))~=0), error('Complex element in y'), end
      if size(y{ii},2)~=1, error('An element in y is not a vector'), end
      if ii==1, nsy=size(y{ii},1); end
      if size(y{ii},1)~=nsy, nsy=nan; end
    end
  else
    error('y must be a double or a cell')
  end
end
%
chin=0; nsu=0; expnou=0;
if ~isempty(u)
  if size(u,3)>1, error('u is a 3-D array'), end
  %Try to make same excitation for all experiments
  if isa(u,'double')&(size(u,1)>1)&iscell(y)
    if size(u,2)==1, u={u}; elseif size(u,2)>1, u=num2cell(u,1)'; end
  end
  if isa(u,'cell')&(size(u,2)==1), for iu=2:expnoy, u=[u,u(1)]; end, end
  %
  if isa(u,'double')
    if any(imag(u(:))~=0), error('Complex element in u'), end
    [nsu,chin]=size(u); ud=u; u={ud(:,1)};
    if (nsu==1)&(chin>1)
      warning(sprintf('u contains %.0f samples x %.0f experiments',nsu,chin))
    end
    for ii=2:chin, u{ii,:}=ud(:,ii); end %Make cell array
    expnou=size(u,2);
  elseif iscell(u)
    [chin,expnou]=size(u);
    for ii=1:chin*expnou
      if any(imag(u{ii}(:))~=0), error('Complex element in u'), end
      if size(u{ii},2)~=1, error('An element in u is not a vector'), end
      if ii==1, nsu=size(u{ii},1); end
      if size(u{ii},1)~=nsu, nsu=nan; end
    end
  else
    error('u must be a double or a cell')
  end
end
%
if (chin>0)&(chout>0)&(expnou~=expnoy),
  error('Number of experiments in y and u differ')
end
%
if ni>=3, Ts=varargin{3}; end
if ~( (isnumeric(Ts)&(length(Ts)<=1)) | iscell(Ts) )
  if isnumeric(Ts)&(length(Ts)>1)
    error('Ts is numeric, but not a scalar')
  else
    error(['Ts is ''',class(Ts),''', not a scalar or a cell array'])
  end
end
if ~isempty(Ts)
  if isnumeric(Ts), Ts={Ts};
  elseif iscell(Ts)
    if ~any(size(Ts,1)==[1,chin+chout])
      error('Height of cell Ts is wrong')
    end
    if size(Ts,2)~=max(expnou,expnoy)
      error('Width of cell Ts is wrong')
    end
  end
  for ii=1:size(Ts,1)
    for iii=1:size(Ts,2)
      if ~isnumeric(Ts{ii,iii})|(length(Ts{ii,iii})>1)
        error('An element of Ts is not a scalar')
      end
      if Ts{ii,iii}<0, error('An element of Ts is negative'), end
      if imag(Ts{ii,iii})~=0, error('An element of Ts is complex'), end
    end
  end
end
if iscell(Ts)&(length(Ts)>1)
  Tseq=1; Ts1=Ts{1};
  for ii=2:length(Ts)
    if ~isequal(Ts1,Ts{ii}), Tseq=0; end
  end
  if Tseq, Ts=Ts{1}; end
end
%
if ni>=4, oname=varargin{4}; end
if iscell(oname)
  if (size(oname,1)==1), oname=oname'; end %make a column cell vector
  for ii=1:length(oname)
    if ~isstr(oname{ii})|(size(oname{ii},1)>1)
      error(['oname is not allowed for cell index ',num2str(ii)])
    end
  end %for ii
  if length(oname)==1, oname=oname{1}; end %make a string if possible
end
if (chout==0)&~isstr(oname), error('oname is not allowed for empty output'), end
if ~isempty(oname)&(size(oname,1)~=chout)
  error('oname is inconsistent with output y')
end
%
if ni>=5, iname=varargin{5}; end
if iscell(iname)
  if (size(iname,1)==1), iname=iname'; end %make a column cell vector
  for ii=1:length(iname)
    if ~isstr(iname{ii})|(size(iname{ii},1)>1)
      error(['iname is not allowed for cell index ',num2str(ii)])
    end
  end %for ii
  if length(iname)==1, iname=iname{1}; end %make a string if possible
end
if (chin==0)&~isstr(iname), error('iname is not allowed for empty input'), end
if ~isempty(iname)&(size(iname,1)~=chin)
  error('iname is inconsistent with input u')
end
%
if ni>=6, ounit=varargin{6}; end
if iscell(ounit)
  if (size(ounit,1)==1), ounit=ounit'; end %make a column cell vector
  for ii=1:length(ounit)
    if ~isstr(ounit{ii})|(size(ounit{ii},1)>1)
      error(['ounit is not allowed for cell index ',num2str(ii)])
    end
  end %for ii
  if length(ounit)==1, ounit=ounit{1}; end %make a string if possible
end
if (chout==0)&~isstr(ounit), error('ounit is not allowed for empty output'), end
if ~isempty(ounit)&(size(ounit,1)~=chout)
  error('ounit is inconsistent with output y')
end
%
if ni>=7, iunit=varargin{7}; end
if iscell(iunit)
  if (size(iunit,1)==1), iunit=iunit'; end %make a column cell vector
  for ii=1:length(iunit)
    if ~isstr(iunit{ii})|(size(iunit{ii},1)>1)
      error(['iunit is not allowed for cell index ',num2str(ii)])
    end
  end %for ii
  if length(iunit)==1, iunit=iunit{1}; end %make a string if possible
end
if (chin==0)&~isstr(iunit), error('iunit is not allowed for empty input'), end
if ~isempty(iunit)&(size(iunit,1)~=chin)
  error('iunit is inconsistent with input u')
end
%
% Define default property values in new object.
dat=struct(...
  'Version',dversion,...
  'Ts',Ts,...
  'TStart',[],...
  'SampleTimes',[],...
  'NewProperties',[]);
p=iddat;
dat=class(dat,'tiddata',p);
%
if ~isempty(u)|~isempty(y)
  charu=cell(chin,1); for ii=1:chin, charu{ii}=inchar; end
  chary=cell(chout,1); for ii=1:chout, chary{ii}=outchar; end
  set(dat,'Output',y,'Input',u,'InputCharacter',charu,'OutputCharacter',chary,...
    'noconsistency');
end
if ni>3
  set(dat,'OutputName',oname,...
    'Inputname',iname,'OutputUnit',ounit,'InputUnit',iunit,'noconsistency');
end
%
if ~get(dat,'consistency')
  error('Inconsistent data generated: see the warning message above for the reason')
end

%end @tiddata/tiddata.m
