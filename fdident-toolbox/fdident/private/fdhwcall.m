function [outdata,msg] = fdhwcall(varargin)
%FDHWCALL  Call fdhwfun if available, or special file, or emulator

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 25-May-2004, IK

%Files which handle special hardware
specfiles={'fdhwsigl','fdhwsharc'};
if ~exist('homework')|exist('emulation_on.mat')
  specfiles=[specfiles,{'fdhwemul'}];
else
  specfiles=[specfiles,{'homework'}];
end
%specfiles=[specfiles,{'hazifel'}];
%specfiles=[specfiles,{'homework_prof','hazifel_okt'}];
%
if strcmpi(varargin{1},'Hardware')&~guiinfos('ismeasurement')
  %No measurement, no hardware
  outdata=''; msg='';
  return
end
%
if nargin<1, error('No input argument'), end
if strncmpi(varargin{1},'info',4), varargin{1}='Information'; end
if ~any(findstr(['|',lower(varargin{1}),'|'],...
    lower(['|Instruments|Hardware|Type|Properties|HW_chk|',...
      'Information|Measure|take_data|close_all_instruments|isopen|',...
      'Calibration|'])))
  error(['Action ''',varargin{1},'''not allowed'])  
end
%
%Eliminate name of nonexistent or buggy file
for ii=length(specfiles):-1:1
  if ~exist(specfiles{ii}), specfiles(ii)=[];
  else
    try
      hw=feval(specfiles{ii},'Hardware');
      if ~exist('hw')|isempty(hw), specfiles(ii)=[]; end
    catch
      specfiles(ii)=[];
    end
  end
end %for ii
%
outdata=[]; msg='No information yet';
if any(findstr('fdhwfun.m',lower(which('fdhwfun'))))
  %user-defined function M-file exists
  specfiles={'fdhwfun'};  
  %OK, user-defined file found
elseif exist('fdhwfun')>2
  %Something other than M-file found
  msg='fdhwfun is not an M-file'; return
end
%
hwnames={};
for ii=length(specfiles):-1:1
  if ~exist(specfiles{ii})
    specfiles(ii)=[];
  else 
    hwnames=[feval(specfiles{ii},'Hardware'),hwnames];
    while length(hwnames)>length(specfiles)-ii+1, specfiles=[specfiles,specfiles(end)]; end
  end
end  
%
%Remove hardware name and text ', emulated' from VIname (varargin{2})
hwname='';
if length(varargin)>=2
  if strcmpi(varargin{1},'Instruments')
    hwname=varargin{2};
  else
    ind=findstr(varargin{2},'/');
    if isempty(ind) %nothing to do
      %hwname=varargin{2};
    else
      hwname=varargin{2}(1:ind(1)-1);
      varargin{2}(1:ind(1))='';
      %varargin{2}(ind(1):end)='';
    end
    ind=findstr(varargin{2},', emulated');
    if ~isempty(ind), varargin{2}=varargin{2}(1:ind(1)-1); end
  end
else
  varargin{2}='';
end

lasterr='';
hwn0=fdhwf0('Hardware'); %default hardware names
outdataall={};
for isp=1:length(hwnames)
  domf=1; %Do this file
  if ~isempty(hwname)
    ihw=strmatch(hwname,hwnames,'exact');
    if isempty(ihw)|~isequal(ihw(1),isp), domf=0; end
  end
  %if (isp>1)&~strcmp(specfiles{isp},specfiles{isp-1}), domf=0; end
  if domf==1
    mfname=specfiles{isp};
    if exist(mfname)
      if strcmp(mfname,'homework')
        vin=feval(mfname,'Instruments',hwnames{isp});
      else
        vin=feval(mfname,'Instruments');
      end
      if strcmpi(varargin{1},'instruments')
        %add text ', emulated' to VIname (varargin{2}) if relevant
        %do not add text if following string is contained in name
        emultxts={'mulator';'mulated';'mulator';'mulal'};
        eval(['chk=',mfname,'(''hw_chk'');'],'chk=0;')
        if isequal(chk,-1)
           for ii=1:length(vin)
              addemul=1;
              for iii=1:length(emultxts)
                 if any(findstr(emultxts{iii},lower(vin{ii})))
                    addemul=0; break
                 end
              end
              if addemul==1, vin{ii}=[vin{ii},', emulated']; end
           end % for ii
        end %chk,-1
      end %instruments
      %
      hwn=hwnames(isp);
      if strcmpi(varargin{1},'Hardware')
        if isempty(outdata), outdata=hwn(:)';
        else outdata=[outdata,hwn(:)'];
        end
      elseif (nargin<2)|(length(strmatch(hwname,hwn,'exact'))==1)
        %eval is necessary to bypass error if e.g. a called function is missing
        vamod=varargin; %if length(vamod)>=2, vamod{2}=hwname; end
        try
          [outdata,msg]=feval(mfname,vamod{:});
        catch
          msg=['Error: ',mfname,' failed'];
        end
      elseif length(strmatch(hwname,hwn0(:),'exact'))==1
        %nargin>=2, generic hardware  
        eval('[outdata,msg]=fdhwf0(varargin{:});',...
          'msg=''Error: fdhwf0 failed'';')
      end
      if strcmpi(varargin{1},'Hardware')|strcmpi(varargin{1},'Instruments')
        if ~isempty(outdata), outdataall=[outdataall,outdata]; outdata={};
        elseif ~isempty(msg), break
        end
      end
    end %exist(mfname)
  end
end %for isp
if ~isempty(outdataall), outdata=outdataall; end
if isempty(outdata)&~isempty(lasterr)&~any(findstr(lasterr,'mauifun'))
  msg=lasterr;
end
%
if isempty(outdata)
  exany=exist('fdhwfun');
  for isp=1:length(specfiles)
    exany=exany|exist(specfiles{isp});
    if exany, break, end
  end %for isp
  if exany %previous call failed
    if strcmpi(varargin{1},'instruments')|strcmpi(varargin{1},'hardware')%|...
        %((length(varargin)==2)&(strcmp(varargin{1},'isopen')|strcmp(varargin{1},'hw_chk'))&strcmp(varargin{2},'none'))|...
        %((length(varargin)>=2)&strcmpi(varargin{1},'properties')&strcmp(varargin{2},'none'))
      %Call should not error out: we have to stop
      guifreez('fdmeasurement_main', 'unfreeze', 'fdmeas_measurement');
      disp(msg)
      if strcmpi(varargin{1},'information')
        msg='Information is not yet implemented';
      end
      %if (length(varargin)==2)&(strcmp(varargin{1},'isopen')|strcmp(varargin{1},'hw_chk'))&strcmp(varargin{2},'none')
      %  outdata=1; %homework vi always open
      %elseif ((length(varargin)>=2)&strcmpi(varargin{1},'properties')&strcmp(varargin{2},'none'))
      %  outdata=[];
      %  for ii=3:2:length(varargin)-1
      %    outdata=setfield(outdata,varargin{ii},varargin{ii+1});
      %  end %for ii
      %else
        outdata=[];
      %end
      return  
    end
  elseif strcmpi(varargin{1},'hw_chk')&(isequal(outdata,1)|isequal(outdata,-1))
    %hardware or emulator, we can return
    return  
  end
end
%
return

%The rest will probably never used again...
%Now either the call failed, or Action is 'Instruments' or 'Hardware'
%
%Names of demo/homework emulator files:
hwsnlist={'homework','hazifel'};
hwsnlist=[hwsnlist,{'fdhwemul'}]; %This line adds the standard emulator
%
for ii=length(hwsnlist):-1:1
  if ~exist(hwsnlist{ii}), hwsnlist(ii)=''; end
end
%
if isstr(hwsnlist)
  if size(hwsnlist,2)==1, hwsnlist={hwsnlist};
  else error('hwsnlist is a string array')
  end
end
%
msgs='';
for hwsimname=hwsnlist(:)' %each element of cell array of names
  hwsimname=hwsimname{1}; %make string
  if ~isstr(hwsimname), error('An element of hwsnlist is not a string'), end
  if ~isempty(hwsimname)
    ind=find(hwsimname=='.');
    if ~isempty(ind), hwsimname=hwsimname(1:ind(1)-1); end
    ind=find(hwsimname==filesep);
    if ~isempty(ind), hwsimname=hwsimname(ind(1)+1:end); end
  end
  %Now hwsimname is a simple file name, without extension
  ex=exist(hwsimname);
  if any(ex==[3,6]) %MEX or P
    %MEX or P found
  elseif ex==2 %M?
    ex=exist([hwsimname,'.m']);
    if ex==2  %M-file found
    else
      hwsimname='';
    end
  else
    hwsimname=''; %not found
  end
  %
  if ~isempty(hwsimname)
    %There is a file to try
    sOK=NaN;
    vin=feval(hwsimname,'Instruments');
    hwn=feval(hwsimname,'Hardware');
    if (nargin<2)|(length(strmatch(varargin{2},[vin(:);hwn(:)],'exact'))==1)
      %no instrument name or instrument name corresponds to file
      eval(['[outdatas,msgs]=',hwsimname,'(varargin{:}); sOK=1;'],...
        ['outdatas=[]; msgs=[''Error: File '''''',hwsimname,'''''' failed.'']; sOK=0;'])
    else
      outdatas=[]; msgs='Instrument not found';
    end
    if isequal(outdatas,0), outdatas=[]; end
    if strcmpi(varargin{1},'instruments')|strcmpi(varargin{1},'hardware')
      %list is requested
      if ~isempty(outdatas)
        %use results from simulator file
        if ~isempty(outdata) %proper contents from hardware
          if iscell(outdata)
            outdata=[outdata,outdatas]; msg='';
          %else %old branch
          %  warning('Call to be modified')
          %  outdata.instruments=[outdata.instruments,outdatas.instruments];
          %  outdata.tooltipstrings=[outdata.tooltipstrings,outdatas.tooltipstrings];
          %  msg='';
          end
        else %outdata is empty: not useful result
          outdata=outdatas; msg=msgs;
        end
      else %outdatas is empty
        showerror(sOK,msgs,hwsimname,varargin)
      end
    elseif isempty(outdata)&~isempty(msg)
      %Regular call: HW instrument was missing (error in call),
      %try result of emulators
      if ~isempty(msgs) %error
        vin=feval(hwsimname,'instruments');
        hwn=feval(hwsimname,'hardware');
        if length(strmatch(varargin{2},[vin(:);hwn(:)],'exact'))==1
          %Instrument belongs here: first look if call can be substituted
          if strcmpi(varargin{1},'Properties')&(length(varargin)>=3)
            for ii=3:2:length(varargin)
              eval(['outdatas.',varargin{ii},'=varargin{ii+1};'])
              msgs='';
            end
            outdata=outdatas; msg=msgs; return
          elseif strcmpi(varargin{1},'hw_chk')
            outdata=-1; msg=''; return %'regular' demo or homework
          elseif strcmpi(varargin{1},'isopen')
            outdata=0; msg=''; return
          elseif strcmpi(varargin{1},'Information')
            outdata=[]; msg=msgs; return
          else
            %proper emulator is called, but in vain
            showerror(sOK,msgs,hwsimname,varargin)
          end
        end
      else %good call happened to emulator: replaces bad hw call
        outdata=outdatas; msg=msgs; return
      end
    end
  end
end %for hwsimname
%
if ~isempty(msgs)&~isempty(msg) %return error message from emulator
  outdata=outdatas; msg=msgs;
end

function showerror(sOK,msgs,hwsimname,varargincell)
if isequal(sOK,0)
  %call of homework or emulator failed
  %return with true error message
  disp(msgs) 
  s=dbstack;
  for ii=1:length(s)
    if strcmp(which('fdmeasw'),s(ii).name)
      guifreez('fdmeasurement_main', 'unfreeze', 'fdmeas_measurement');
      fdmeasw('status',msgs)
      break
    end
  end
  [outdatas,msgs]=feval(hwsimname,varargincell{:});
end
