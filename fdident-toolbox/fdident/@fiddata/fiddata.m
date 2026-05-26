function dat = fiddata(varargin)
%FIDDATA Creation function for the FIDDATA data object (frequency domain data).
%
%       Arguments:
%       y - Output data, Fourier coefficients (column vector, cell array or empty)
%          Multiexperiment arrays (samples x expno) can be given as num2cell(yarr,1)
%       u - Input data, Fourier coefficients (column vector, cell array or empty)
%          Multiexperiment arrays (samples x expno) can be given as num2cell(yarr,1)
%       freqpoints - frequency points where amplitudes are given
%              (vector for SISO, cell array for ALL channels for MIMO,
%               vector or  Ny x Nu  cell array for y='frf')
%       vy - variances of outputs (cell array, or vector, or scalar if constant)
%       vu - variances of inputs (cell array, or vector, or scalar if constant)
%       cuy - covariances between I/O for SISO systems only (vector or empty)
%                 mean( conj(u-mean(u)).*(y-mean(y)) )
%          The above variances and covariances belong to the COMPLEX amplitudes.
%       oname - Name(s) of output channel(s) (string, cell or empty)
%       iname - Name(s) of input channel(s) (string, cell or empty)
%       ounit - Name(s) of output unit(s) (string, cell or empty)
%       iunit - Name(s) of input unit(s) (string, cell or empty)
%       By default, the input/output characters of the generated object are
%         'BL'; if the last argument is 'zero-order hold', the characters
%         are: InputCharacter - 'ZOH', OutputCharacter - Samples'.
%
%       If y='frf', u is a cell array of FRF function points (Ny x Nu)
%            and vy is a cell array of the variances of the frf's
%
%       In order to obtain a detailed list of properties and possibilities,
%       type 'help(fiddata)','help(fiddata,<property>)', or 'helpc(fiddata)'
%
%       Usage: Fd=fiddata(y,u,freqpoints);
%              fiddata(y,u,freqpoints,vy,vu,cuy,oname,iname,ounit,iunit);
%              fiddata(obj); %This is conversion e.g. from iddata objects
%              fiddata('frf',frfcell,freqpoints,varcell)
%       Examples: type 'fiddata examples'

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 26-Apr-2005

dversion=1.3; %Current version of object
ni=nargin;
inchar='BL'; outchar='BL';
if (ni>=1)&isstr(varargin{end}) %maybe 'zero-order hold' is given
  if strcmpi(varargin{end},'zero-order hold')
    inchar='ZOH'; outchar='Samples';
    varargin(end)=[]; ni=ni-1;
  elseif strcmpi(varargin{end},'band-limited')|...
      strcmpi(varargin{end},'bandlimited')
    varargin(end)=[]; ni=ni-1;
  end
end
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(0,10); %Matlab 2016a or later
else ni=nargin; error(nargchk(0,10,ni)), %earlier
end
%
if ni==1 %one input argument given: convert struct to object or fix object
  if isstr(varargin{1})&strncmp(varargin{1},'examples',2)
    type fiddata_examples.m, return
  end
  strucv=varargin{1}; %convert structure to object
  if isa(strucv,'fiddata')
    if length(strucv)>1, error('strucv is an array'), end
    fid=fiddata; id=iddat; s=struct(strucv); sid=s.iddat;
    if (get(strucv,'Version')==fid.Version)&(get(sid,'Version')==id.Version)
      dat=strucv; return %nothing to do
    end
    strucv=struct(strucv); %Maybe old fiddata? Handle as structure
    return
  elseif isa(strucv,'iddata')
    dom=get(strucv,'domain');
    if strcmpi(dom,'frequency')
      dat=iddat(strucv);
      return
    else
      error(['Cannot transform iddata object of domain ''',dom,''' to fiddata'])
    end
  elseif isa(strucv,'struct')
    %Either result of load of old version, or structure to be converted
    %Here handle earlier versions loaded from MAT-files
    %
    if isfield(strucv,'Version'), sversion=strucv.Version; else sversion=[]; end
    if sversion<dversion
      warning(sprintf(['Earlier fiddata object version %.1f is found, ',...
          'converted to current fiddata'],sversion))
    end
    if isempty(sversion)|any(sversion==[1.1,1.2,1.3])|(sversion>1.3)
      fnames=fieldnames(strucv);
      if isfield(strucv,'FreqPoints')|isfield(strucv,'InputFreqPoints') %exported from object
        fp=strucv.FreqPoints; if isempty(fp), fp=strucv.InputFreqPoints; end
        dat=fiddata(strucv.Output,strucv.Input,fp);
        for fn={'Output','Input','FreqPoints','InputFreqPoints','OutputFreqPoints','Information','ChNumber'}
          ind=strmatch(fn{1},fnames); if ~isempty(ind), fnames(ind)=[]; end 
        end
        for ii=1:length(fnames)
          Prop=fnames{ii}; Value=getfield(strucv,Prop);
          set(dat,Prop,Value,'noconsistency');
        end
      else %struct(obj)
        if ~isfield(strucv,'Fs')
          error('There is no field Fs in the structure')
        elseif ~isfield(strucv,'iddat')
          error('There is no field iddat in the structure')
        end
        p=strucv.iddat; strucv=rmfield(strucv,'iddat');
        if ~isfield(strucv,'NewProperties'), strucv.NewProperties=[]; end
        strucv.Version=dversion;
        if ~isa(p,'iddat'), p=iddat(p); end
        dat=class(strucv,'fiddata',p); %set class
        set(dat,'Version',get(dat,'Version')); %consistency check
        %elseif any(strucv.Version==1.4)
        %warning('Earlier fiddata object is found, converted to current fiddata')
      end
    else
      error(sprintf('fiddata version %.3g cannot be converted',strucv.Version))
    end
    return
  elseif isa(strucv,'frd') %conversion from frd object
    if length(strucv)>1, error('Cannot convert frd data array'), end
    ResponseData=strucv.ResponseData;
    [s1,s2,s3]=size(ResponseData);
    if any([s1,s2]~=1), error('frd is not SISO'), end
    ResponseData=permute(ResponseData,[3,1,2]);
    freqv=strucv.frequency;
    if strcmp(strucv.units,'rad/s'), freqv=freqv/2/pi;
    elseif strcmp(strucv.units,'Hz') %nothing to do
    else error('Unknown units in object')
    end
    dat=fiddata(ResponseData,ones(size(ResponseData)),freqv);
    Ts=strucv.Ts;
    if Ts>0, set(dat,'fs',1/strucv.Ts,'noconsistency')
    elseif Ts==-1 %unknown sampling frequency
    else set(dat,'fs',inf,'noconsistency')
    end
    set(dat,'InputDelay',strucv.InputDelay,'noconsistency')
    set(dat,'OutputDelay',strucv.OutputDelay,'noconsistency')
    set(dat,'InputName',strucv.InputName,'noconsistency')
    set(dat,'OutputName',strucv.OutputName,'noconsistency')
    set(dat,'Notes',strucv.Notes,'noconsistency')
    set(dat,'UserData',strucv.UserData)
    return
  elseif isa(strucv,'idfrd') %conversion from idfrd object
    if length(strucv)>1, error('Cannot convert idfrd data array'), end
    ResponseData=strucv.ResponseData;
    [s1,s2,s3]=size(ResponseData);
    if any([s1,s2]~=1), error('frd is not SISO'), end
    ResponseData=permute(ResponseData,[3,1,2]);
    freqv=strucv.frequency;
    if strcmp(strucv.units,'rad/s'), freqv=freqv/2/pi;
    elseif strcmp(strucv.units,'Hz') %nothing to do
    else error('Unknown units in object')
    end
    dat=fiddata(ResponseData,ones(size(ResponseData)),freqv);
    Ts=strucv.Ts;
    if Ts>0, set(dat,'fs',1/strucv.Ts,'noconsistency')
    elseif Ts==-1 %unknown sampling frequency
    else set(dat,'fs',inf,'noconsistency')
    end
    set(dat,'InputDelay',strucv.InputDelay,'noconsistency')
    set(dat,'InputName',strucv.InputName,'noconsistency')
    set(dat,'OutputName',strucv.OutputName,'noconsistency')
    cd=get(strucv,'CovarianceData');
    cd=permute(cd,[3,4,5,1,2]);
    set(dat,'inputvariance',zeros(size(cd,1),1),'noconsistency')
    set(dat,'outputvariance',cd(:,1,1)+cd(:,2,2),'noconsistency')
    set(dat,'Notes',strucv.Notes,'noconsistency')
    set(dat,'UserData',strucv.UserData)
    return
  elseif isa(strucv,'tiddata')
    dat=tim2fou(strucv);
    return
    %error('For the conversion of a tiddata object, use tim2fou')
  elseif (isstr(strucv)&(size(strucv,1)==1)) | ...
      (isnumeric(strucv)&(size(strucv,2)==1))
    %maybe file of parameter vector
    if isstr(strucv)
      [filenl,fn,ext]=fnamanal(strucv);
      if ~strncmpi(ext,'f',1)&~strncmp(ext,'t',1)
        error('File is not Fourier or time file')
      end
    end
    OK=1;
    if isnumeric(strucv)|strncmpi(ext,'f',1)
      try
        [freqvect,x,y,expno,vdat,comments,fdate]=impfou(strucv);
        F=size(freqvect,1);
        [v,h]=size(y); expno=round(v/F); chno=h; 
        yc=y;
        if (chno>1)|(expno>1)
          yc=cell(chno,expno);
          for ii=1:chno
            for iii=1:expno
              yc{ii,iii}=y((iii-1)*F+[1:F],ii);
            end
          end
        end
        [v,h]=size(x); expno=round(v/F); chno=h; 
        xc=x;
        if (chno>1)|(expno>1)
          xc=cell(chno,expno);
          for ii=1:chno
            for iii=1:expno
              xc{ii,iii}=x((iii-1)*F+[1:F],ii);
            end
          end
        end
        dat=fiddata(yc,xc,freqvect);
        if ~isempty(vdat), set(dat,'SiSoVariance',vdat); end
        set(dat,'notes',comments,'date',fdate)
        OK=1;
      catch
        OK=0;
      end

      if OK==1, return, end
    end
    if isnumeric(strucv)|strncmpi(ext,'t',1)
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
              xc{ii,iii}=xt((iii-1)*F+[1:F],ii);
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
        if ~isempty(vdat), set(dat,'SiSoVariance',vdat); end
        set(dat,'notes',comments,'date',fdate)
        dat=tim2fou(dat);
        return
      catch
        OK=0;
      end
      if OK==0
        error(['Class of strucv is ''',class(strucv),''', cannot convert it'])
      end
    else
      error('Programming error')
    end
  else
    error(['Class of strucv is ''',class(strucv),''', cannot convert it'])
  end
end %ni==1

%Creator function: read input arguments
if ni==2, error('freqpoints is not given'), end
y=[]; u=[]; freqpoints=[]; vy=[]; vu=[]; cuy=[];
oname=''; iname=''; ounit=''; iunit='';
nocons=0;
if (ni>=1)&strcmpi(varargin{1},'frf')
  frfform=1; varargin(1)=[];
else
  frfform=0;
end
compact=1; %unifiy all experiments belonging to one input
if frfform
  %Temporarily make y/u object
  y=varargin{1};
  if isnumeric(y), y={y}; end
  fp=varargin{2}; if iscell(fp)&(length(fp)==1), fp=fp{1}; end
  %
  if compact, expno=size(y,1); else expno=prod(size(y)); end
  inpno=size(y,1); outpno=size(y,2);
  yc=cell(outpno,expno); %outputs x inputs (each experiment belongs to one input)
  uc=cell(inpno,expno); %inputs x inputs (inputs x inputs*outputs)
  if iscell(fp), fpc=cell(inpno+outpno,expno); else fpc=fp; end
  if nargin>=4, vy=varargin{3}; end
  if ~isempty(vy)&iscell(vy), vyc=cell(outpno,expno); else vyc=vy; end
  ei=0;
  for iv=1:size(y,1) %Inputs
    ei=ei+1;
    fpu=[];
    for ih=1:outpno %Outputs
      if ~compact&(ih>1), ei=ei+1; end
      yc{ih,ei}=y{iv,ih}; %set output
      if iscell(vyc), vyc{ih,ei}=vy{iv,ih}; end
      if iscell(fp) %if numeric, nothing to do
        fpc{ih,ei}=fp{iv,ih}; %output freqpoints
        if compact
          fpy=fp{iv,ih};
          if all(diff(sort(fpy)))
            ism=ismember(fpy,fpu);
            if ~all(ism), ind=find(~ism); fpu=[fpu(:);fpy(ind)]; end
          else %repeated frequencies
            [fpyord,ordind]=sort(fpy);
            ind=find(diff(fpyord)==0);
            while ~isempty(ind) %repetition still exists
              fpyi=fpyord(ind(1));
              indo=find(fpyi==fpyord); %all repetitions
              indi=[];
              if ~isempty(fpu)&~isempty(fpyi)
                indi=find(fpyi==fpu); %all repetitions
              end
              for ii=1:length(indo)-length(indi)
                fpu=[fpu;fpyi];
              end
              fpyord(indo)=[]; fpy(ordind(indo))=[]; 
              ind=find(diff(fpyord)==0); %prepare next cycle
            end %while
          end %repeated frequencies
          fpu=sort(fpu);  
        else %not compact
          fpu=fp{iv,ih};
        end
      end %if iscell(fp)
      if iscell(fpc)
        if compact|(ih==1)
          fpc{outpno+iv,ei}=fpu; %input freqpoints
          uc{iv,ei}=ones(size(fpu));
        end
      else
        if compact|(ih==1)
          uc{iv,ei}=ones(size(fpc));
        end
      end
    end %for ih (output)
  end %for iv (input)
  varargin=[{yc},varargin];
  varargin{2}=uc;
  varargin{3}=fpc;
  varargin{4}=vyc;
  vu=[];
  cuy=[];
  varargin=[varargin(1:4),{vu},{cuy},varargin(5:end)];
  dat=fiddata(varargin{:});
  return
end %frfform
%
if ni>=2, y=varargin{1}; end, if isempty(y), y=[]; end
chout=0; nsy=0; expnoy=0;
if ~isempty(y)
  if size(y,3)>1, error('y is a 3-D array'), end
  if isa(y,'double')
    %if any(imag(y(:))), error('Complex element in y'), end
    [nsy,chout]=size(y); yd=y; y={yd(:,1)};
    if (nsy==1)&(chout>1)
      warning(sprintf('y contains %.0f samples x %.0f channels',nsy,chout))
    end
    for ii=2:chout, y{ii,:}=yd(:,ii); end %Make cell array
    expnoy=size(y,2);
  elseif iscell(y)
    [chout,expnoy]=size(y);
    for ii=1:chout*expnoy
      %if any(imag(y{ii}(:))), error('Complex element in y'), end
      if all(size(y{ii},2)~=[0,1]), error('An element in y is not a vector'), end
      if ii==1, nsy=size(y{ii},2); end
      if size(y{ii},2)~=nsy, nsy=nan; end
    end
  else
    error('y must be a double or a cell')
  end
end
%
if ni>=2, u=varargin{2}; end, if isempty(u), u=[]; end
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
    %if any(imag(u(:))), error('Complex element in u'), end
    [nsu,chin]=size(u); ud=u; u={ud(:,1)};
    if (nsu==1)&(chin>1)
      warning(sprintf('u contains %.0f samples x %.0f channels',nsu,chin))
    end
    for ii=2:chin, u{ii,:}=ud(:,ii); end %Make cell array
    expnou=size(u,2);
  elseif iscell(u)
    [chin,expnou]=size(u);
    for ii=1:chin*expnou
      %if any(imag(u{ii}(:))), error('Complex element in u'), end
      if ~isempty(u{ii})&(size(u{ii},2)~=1), error('An element in u is not a vector'), end
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
freqtype='';
for ii=ni-1:-1:4
  if isstr(varargin{ii})&strncmp(varargin{ii},'frequencies',4)
    if isstr(varargin{ii+1})&strncmp(varargin{ii+1},'negative',3)
      freqtype='neg';
      varargin(ii:ii+1)=[]; ni=ni-2;
    end
  end
end
if (ni==3)&strcmp(varargin{3},'noconsistency'), nocons=1; ni=ni-1; end
if ni>=3, freqpoints=varargin{3}; end
if isnumeric(freqpoints)
  if ~isempty(freqpoints)
    if min(size(freqpoints))>1, error('freqpoints is not a vector'), end
    if size(freqpoints,2)>1, freqpoints=freqpoints(:); end
    if any(freqpoints<0)&~strcmp(freqtype,'neg'), warning('A freqpoints element is negative'), end
    if any(imag(freqpoints)), error('A freqpoints element is complex'), end
  end
  F=length(freqpoints);
elseif iscell(freqpoints)
  if all(size(freqpoints,1)~=[1,(chin+chout)])
    error('Wrong vertical size of cell freqpoints')
  end
  F=zeros(size(freqpoints));
  for ii=1:prod(size(freqpoints))
    if ~isnumeric(freqpoints{ii})
      error('Non-numeric freqpoints cell element')
    end
    if min(size(freqpoints{ii}))>1, error('A freqpoints element is not a vector'), end
    if size(freqpoints{ii},2)>1, freqpoints{ii}=freqpoints{ii}(:); end
    if any(freqpoints{ii}<0), error('A freqpoints element is negative'), end
    if any(imag(freqpoints{ii})), error('A freqpoints element is complex'), end
    if length(freqpoints)>1 %if cell array, inconsistency may happen from nonmonotonicity
      if any(diff(freqpoints{ii})<0)
        error('cell element of freqpoints is not monotonic')
      elseif any(~diff(freqpoints{ii}))
        warning('cell element of freqpoints is not strictly monotonic')
      end
    end
    F(ii)=length(freqpoints{ii});
  end %for ii
  if length(freqpoints)==1, freqpoints=freqpoints{1}; end
else
  error('freqpoints is not a double or a cell')
end    
%
if (ni==4)&strcmp(varargin{4},'noconsistency'), nocons=1; ni=ni-1; end
if ni>=4, vy=varargin{4}; end
if isnumeric(vy)
  if ~isempty(vy)
    if min(size(vy))~=1, error('vy is a 2-D array'), end
    if any(vy(:)<0), error('A vy element is negative'), end
    if any(imag(vy(:))), error('A vy element is complex'), end
    if ~any(size(vy,1)==[1,F])
      error('length of vy is inconsistent with freqpoints')
    end
    if size(vy,2)>1 %make it a cell array
      vyold=vy; vy={};
      for ii=1:length(vyold), vy{ii}=vyold(:,ii); end
    end
  end
elseif iscell(vy)
else
  error('vy is not numeric or cell array')
end
if iscell(vy)
  if size(vy,1)~=chout, error('Wrong channel number in vy'), end
  if length(F)==1, Fv=F*ones(chout,1); else Fv=F; end
  vu=cell(size(vy));
  for ii=1:size(vy,1)
    for iii=1:size(vy,2)
      if ~isnumeric(vy{ii,iii}), error('Non-numeric vy cell element'), end
      if all(min(size(vy{ii,iii}))~=[0,1]), error('A vy element is not a vector'), end
      if any(vy{ii,iii}<0), error('A vy element is negative'), end
      if any(imag(vy{ii,iii})), error('A vy element is complex'), end
      if ~any(size(vy{ii,iii},1)==[0;1;Fv(ii,min(iii,end))])
        error('length of vy is inconsistent with freqpoints')
      end
      vu{ii,iii}=zeros(size(vy{ii,iii}));
    end %for iii
  end %for ii
elseif isnumeric(vy)
  vu=zeros(size(vy));
end
%
if (ni==5)&strcmp(varargin{5},'noconsistency'), nocons=1; ni=ni-1; end
if ni>=5, vu=varargin{5}; end
if isnumeric(vu)
  if ~isempty(vu)
    if min(size(vu))~=1, error('vu is a 2-D array'), end
    if any(vu(:)<0), error('A vu element is negative'), end
    if any(imag(vu(:))), error('A vu element is complex'), end
    if ~any(size(vu,1)==[1,F])
      error('length of vu is inconsistent with freqpoints')
    end
    if size(vu,2)>1 %make it a cell array
      vuold=vu; vu={};
      for ii=1:length(vuold), vu{ii}=vuold(ii,:); end
    end
  end
elseif iscell(vu)
else
  error('vu is not numeric or cell array')
end
if iscell(vu)
  if size(vu,1)~=chin, error('Wrong channel number in vu'), end
  if length(F)==1, Fv=F*ones(chin,1); else Fv=F; end
  for ii=1:size(vu,1)
    for iii=1:size(vu,2)
      if ~isnumeric(vu{ii,iii}), error('Non-numeric vu cell element'), end
      if ~any(min(size(vu{ii,iii}))~=[0,1]), error('A vu element is not a vector'), end
      if any(vu{ii,iii}<0), error('A vu element is negative'), end
      if any(imag(vu{ii,iii})), error('A vu element is complex'), end  
      if ~any(size(vu{ii,iii},1)==[0;1;Fv(ii,min(iii,end))])
        error('length of vu is inconsistent with freqpoints')
      end
    end
  end
end
%
if (ni==6)&strcmp(varargin{6},'noconsistency'), nocons=1; ni=ni-1; end
if ni>=6, cuy=varargin{6}; end
if ~isempty(cuy)
  if (chin~=1)|(chout~=1), error('cuy is not empty, but system is not SISO'), end
  if isempty(vy)|isempty(vu)
    error('cuy is not empty, while vu or vy is empty')
  end  
  if min(size(cuy))~=1, error('cuy is a 2-D array'), end
  if size(cuy,2)>1, cuy=cuy.'; end
  if iscell(freqpoints) %check if two vectors are identical
    if ~isequal(freqpoints{1},freqpoints{2})
      error('cuy is given, but freqpoints defines two different frequency grids')
    end
  end
  if length(cuy)~=F, error('Length of cuy differs from number of frequencies'), end
end
if ~iscell(cuy)&~isnumeric(cuy)
  error('cuy is not numeric or cell array')
end
%
if (ni==7)&strcmp(varargin{7},'noconsistency'), nocons=1; ni=ni-1; end
if ni>=7, oname=varargin{7}; end
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
if (ni==8)&strcmp(varargin{8},'noconsistency'), nocons=1; ni=ni-1; end
if ni>=8, iname=varargin{8}; end
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
if (ni==9)&strcmp(varargin{9},'noconsistency'), nocons=1; ni=ni-1; end
if ni>=9, ounit=varargin{9}; end
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
if (ni==10)&strcmp(varargin{10},'noconsistency'), nocons=1; ni=ni-1; end
if ni>=10, iunit=varargin{10}; end
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
  'FreqIndices',[],...
  'AllFreqPoints',[],...
  'Delays',[],...
  'Fs',[],...
  'Covariance',[],...
  'Coherence',[],...
  'NewProperties',[]);
%
p=iddat;
dat=class(dat,'fiddata',p);
set(dat,'Output',y,'Input',u,'FreqPoints',freqpoints);
charu=cell(size(u,1),1);
for ii=1:size(u,1), charu{ii}=inchar; end %for ii
chary=cell(size(y,1),1);
for ii=1:size(y,1), chary{ii}=outchar; end %for ii
set(dat,'InputCharacter',charu,'OutputCharacter',chary,...
  'OutputName',oname,'Inputname',iname,'OutputUnit',ounit,'InputUnit',iunit,...
  'noconsistency');
%
if ~isempty(vy), set(dat,'OutputVariance',vy,'noconsistency'), end
if ~isempty(vu), set(dat,'InputVariance',vu,'noconsistency'), end
if ~isempty(vu)|~isempty(vy)
  if ~isempty(cuy), set(dat,'ch:1,2','CovVector',cuy,'noconsistency'); end
else %both vy and vu are empty: cuy may be given as 3-dim array
  if ~isempty(cuy), set(dat,'Covariance',cuy,'noconsistency'); end
end
%
if (nocons==0)&~get(dat,'consistency')
  error('Inconsistent data generated by fiddata: see the warning message above for the reason')
end

%end @fiddata/fiddata.m
