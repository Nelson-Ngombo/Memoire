function idobj=iddata(obj)
%IDDATA  Transform fiddata or tiddata object to iddata object (ident toolbox)
%
%       idobj=IDDATA(fidobj);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Aug-2001

ni = nargin;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,1); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,1,ni)), %earlier
end
no = nargout;
if no>1, error('Only one output argument is allowed'), end
if exist('@iddata/iddata.m') %iddata found
  icn=1; ocn=1; en=get(obj,'expn');
  input=get(obj,'input');
  %if ~iscell(input), input={input}; end
  if iscell(input), [icn,en]=size(input); end
  output=get(obj,'output');
  %if ~iscell(output), output={output}; end
  if iscell(output), [ocn,en]=size(output); end
    try
      idobj=iddata(output,input);
    catch
      %warning('iddata cannot accept cell array input')
      if iscell(input)
        [v,h]=size(input);
        if (v>1)&(h==1), input=cat(2,input{:}); end
      end
      if iscell(output)
        [v,h]=size(output);
        if (v>1)&(h==1), output=cat(2,output{:}); end
      end
      idobj=iddata(output,input);
    end
  %
  if isa(obj,'fiddata')
    Domain='Frequency';
    fs=get(obj,'fs');
    if isempty(fs), Ts=[]; Fs=[]; else Ts=1/fs; Fs=fs; end
    if isempty(Ts), Tsset=0; else Tsset=Ts; end %temporary value
  elseif isa(obj,'tiddata')
    Domain='time';
    Ts=get(obj,'Ts'); Fs=[];
    Tsset=Ts; 
    SI=get(obj,'SamplingInstants');
    v=version;
    if (str2num(v(1:3))>=7.7)&isempty(Tsset), Tsset=1; end %temporary value
  end
  if isempty(Fs), Fsset=inf; else Fsset=Fs; end %temporary value
  ver=version;
  if isa(obj,'fiddata')&(str2num(ver(1:3))>=6.5)
    if strcmp(ver(1:5),'6.5.1')|(ver(1)>='7')
      %newer than or equal to 6.5.1
      freq=get(obj,'FreqPoints');
      if isnumeric(freq), freq=2*pi*freq;
      elseif iscell(freq)
        for ii=1:prod(size(freq))
          freq{ii}=2*pi*freq{ii};
        end
      end
      idobj=iddata(output,input,Tsset,'FREQ',freq);
      idobj=chgFreqUnit(idobj,'Hz')
    else
      idobj=iddata(output,input,Fsset,'Domain',Domain);
    end
  else
    idobj=iddata(output,input,Tsset,'Domain',Domain,'SamplingInstants',SI);
	end
	%iddata error
	if 0
		try
			%vid=get(idobj,'Version'); %Don't know why
			vid=idobj.Version;
		catch
			%vid=idobj.Version;
			vid=get(idobj,'Version');
		end
		if (isnumeric(vid)&(vid==1)) | ...
				(isstr(vid)&(strcmp(vid(1),'0')|all(vid(1:3)<='1.0')))
			%Conversion OK
		else
			disp('iddata properties may have been changed.')
			if isnumeric(vid), vid=num2str(vid); end
			disp(['  Recent iddata version: ',vid,', known version: 1.0'])
			%error('iddata  conversion error')
		end
	end
  %
  name=get(obj,'name');
  if ~isempty(name), set(idobj,'name',name), end
  enam=get(obj,'ExperimentName');
  if ~isempty(enam)
    if isstr(enam), enam={enam}; end
    set(idobj,'experimentname',enam)
  end
  %
  iu=get(obj,'inputunit');
  if ~isempty(iu), set(idobj,'inputunit',iu), end
  ou=get(obj,'outputunit');
  if ~isempty(ou), set(idobj,'outputunit',ou), end
  in=get(obj,'inputname'); %if isstr(in)&(length(in)>0), in={in}; end
  if ~isempty(in), set(idobj,'inputname',in), end
  on=get(obj,'outputname'); %if isstr(on)&(length(on)>0), on={on}; end
  if ~isempty(on), set(idobj,'outputname',on), end
  pl=get(obj,'periodlength');
  if ~isempty(pl)&~isnan(pl), set(idobj,'period',pl), end
  ic=get(obj,'inputcharacter');
  if ~isempty(ic)
    if strcmpi(ic,'BL')|strcmpi(ic,'AASamples'), ic='bl'; end
    if isstr(ic), ic={lower(ic)}; end
    if (icn>1)|(en>1)
      if isstr(ic), ic={ic}; end
      while size(ic,1)<icn, ic=[ic;ic(end,:)]; end
      while size(ic,2)<en, ic=[ic,ic(:,end)]; end
    end
    if iscell(ic)
      for ii=1:prod(size(ic))
        ic{ii}=lower(ic{ii});
        if strcmpi(ic{ii},'samples')|strcmpi(ic{ii},'discrete'), ic{ii}='bl'; 
        elseif strcmpi(ic{ii},'zohf'), ic{ii}='zoh';
        end
      end
    end
    set(idobj,'intersample',ic);
  end    
  notes=get(obj,'notes');
  if ~isempty(notes), set(idobj,'notes',notes), end
  ud=get(obj,'userdata');
  if ~isempty(ud), set(idobj,'userdata',ud), end
  if isa(obj,'fiddata')
    st=get(obj,'freqpoints');
    vm=version;
    if str2num(vm(1:3))>=6.5
      try, set(idobj,'frequency',st)
      catch, warning('Cannot set frequency')
      end
    else
      try, set(idobj,'samplingfrequencies',st)
      catch warning('Cannot set samplingfrequencies')
      end
    end
    try, idobj=chgFreqUnit(idobj,'Hz');
    catch
      try, set(idobj,'frequencyunit','Hz')
      catch warning('Cannot set frequencyunit')
      end
    end
    %set(idobj,'fs',fs)
    InputDelay=get(obj,'InputDelay');
    OutputDelay=get(obj,'OutputDelay');
    if ~isempty(InputDelay), tst=InputDelay; else tst=0; end
    if ~isempty(OutputDelay), tst=tst-OutputDelay; end
  elseif isa(obj,'tiddata')
    set(idobj,'timeunit','s')
    tst=get(obj,'tstart');
		Ts=get(obj,'Ts'); if isempty(Ts), Ts=1; end
    if isnumeric(tst)|(size(tst,1)==1), set(idobj,'Ts',Ts,'TStart',tst);
    elseif isempty(tst) %nothing to do
    elseif iscell(tst)
      warning('Cannot properly handle different TStart values for different channels')
      [h,v]=size(tst);
      tst=cat(1,tst{:});
      tst=reshape(tst,h,v);
      if h>1, tst=mean(tst); end
      if size(tst,2)>1, tst=num2cell(tst); end
      set(idobj,'TStart',tst);
    end
    %
    st=get(obj,'samplinginstants');
    if ~isempty(st)
      try
        set(idobj,'Ts',Ts,'samplinginstants',st)
      catch
        warning('Something is not OK in iddata')
      end
    end
  end
else %iddata directory is missing, structure is generated
  warning('iddata.m not found: structure is generated')
  error('Not yet ready')
end

% end ../@iddat/iddata.m
