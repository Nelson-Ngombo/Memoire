function [outdata,msg] = fdhwf0(Action,VIname,varargin)
%FDHWF0  Interface between FDIDENT and generic hardware data
%
%       Only certain calls are implemented (for essd)
%
%       Input arguments:
%       Action, and corresponding outdata:
%          'Hardware'  return cell array of name(s) of hardware
%          'Properties'
%            With more than 2 input arguments: properties to check, e.g.
%              fdhwf0('Properties',dev,'fe',51200) returns the allowed
%              value closest to 51200, as outdata.fe
%              fdhwf0('Properties',dev,'fe',51200,'reconstruction_filter,'on')
%              returns the possibilities:
%              outdata.fe=51200, outdata.reconstruction_filter='off'
%            With two input arguments (for internal use and for test only):
%              Return outdata, a structure with possibilities for VIname:
%              outdata.A    Amplitude that can be generated
%              outdata.fe   Vector of possible clock frequencies (signal generator)
%              outdata.Ne   Vector of possible excitation lengths
%              outdata.reconstruction_filter  1 for existing, 0 for
%                 nonexisting, NaN for fc-dependent
%              outdata.BWe   Vector of antialias filter bandlimits
%              outdata.fs   Vector of possible sampling frequencies
%              outdata.Ns   Vector of possible measurement sequence lengths
%              outdata.antialias_filter
%                 1 for existing
%                 0 for nonexisting
%                 -1 for inherent (sigma-delta)
%                 NaN for fc-dependent
%              outdata.BWs   Vector of antialias filter bandlimits
%            With 3 input arguments: return allowed values of property:
%              e.g. fdhwf0('Properties','VOS','fs') returns all
%              allowed values of fs
%          'Information' Return detailed information on given VI or hardware
%              for helpwin: that is, in the form
%              {title1,{line11;line12;...};title2,{line21;line22;...};...}
%              where all variables are strings, lines are at most 70
%              character long, and title1 is the actual virtual instrument.
%              title2 etc are optional items in the array
%              (general information about the hardware, etc).
%
%       If an error occurs, which needs to be handled outside, outdata is
%       returned as empty, and msg contains the message.
%
%       Usage: [outdata,msg] = fdhwf0(Action,VIname,excsig,measpars);
%
%       Last modified: 03-Dec-2002, IK

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,100); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,100,ni)), %earlier
end
if nargin<2, VIname=''; end %default for VIname
outdata=[]; msg=''; excsig=[];

%Treat varargin here
if nargin>2
  if isstr(varargin{1})|isstruct(varargin{1})
    %This is Action 'Properties', there is nothing to do
  else
    error('varargin{1} is not allowed')
  end
end    

if strcmpi(Action,'Hardware')
  outdata={}; %Additional default possibilities
  return
  
elseif strcmpi(Action,'Information')
  msg='';
  if strcmpi(VIname,'Generic')
    txt={'''Generic'' means that there is no restriction caused by the hardware:';
      'only the consistency of the signal parameters is checked or assured';
      'by ''Adjust''.'};
  elseif strcmpi(VIname,'Discrete')
    txt={'???'};
  else
    txt=['Unknown hardware ''',VIname,''''];  
    error(txt)
  end
  outdata={VIname,txt};
  return
  
elseif strcmpi(Action,'Properties')
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(2,100); %Matlab 2016a or later
  else ni=nargin; error(nargchk(2,100,ni)), %earlier
  end
  if iscell(VIname)
    if length(VIname)==1, VIname=VIname{1};
    else error('Only one device can be handled at a time')
    end
  end
  if strcmpi(VIname,'Generic')|strcmpi(VIname,'Discrete Seq.')
    %Built-in default instruments
    Amax=NaN; A=NaN;
    fe=NaN;
    Ne=NaN;
    reconstruction_filter=NaN;
    BWe=NaN;
    fs=NaN;
    Ns=NaN;
    antialias_filter=NaN;
    BWs=NaN;
    if nargin==1
      outdata.A=A;
      outdata.fe=fe;
      outdata.Ne=Ne;
      outdata.reconstruction_filter=reconstruction_filter;
      outdata.BWe=BWe;
      outdata.fs=fs;
      outdata.Ns=Ns;
      outdata.antialias_filter=antialias_filter;
      outdata.BWs=BWs;
    else
      lv=length(varargin);
      if lv==1
        eval(['outdata.',varargin{1},'=',varargin{1},';'])
        return
      else
        if rem(lv,1)==1, error('Odd number of elements in varargin'), end
        outdata=[]; recfilt=0;
        for ii=1:2:length(varargin)-1
          prop=varargin{ii}; pval=varargin{ii+1};
          switch prop
          case 'A'
            if ~isnumeric(pval), error('Value of A is not numeric'), end
            outdata.A=abs(pval);
          case 'fe'
            if ~isnumeric(pval), error('Value of fe is not numeric'), end
            if length(pval)~=1, error('Value of fe is not a scalar'), end
            if ~isfinite(pval), error('Value of fe is not finite'), end
            outdata.fe=pval;
          case 'Ne'
            if ~isnumeric(pval), error('Value of Ne is not numeric'), end
            if length(pval)~=1, error('Value of Ne is not a scalar'), end
            if ~isfinite(pval), error('Value of Ne is not finite'), end
            outdata.Ne=pval;
          case 'reconstruction_filter'
            recfilt=1; recfiltval=pval;
            if ~strcmp(recfiltval,'on')&~strcmp(recfiltval,'off')
              error(['Reconstruction filter value ''',recfiltval,''' not allowed'])
            end
            if strcmpi(VIname,'Generic')
              outdata.reconstruction_filter=recfiltval;
            else
              outdata.reconstruction_filter='off';
            end
          case 'BWe'
            if ~isnumeric(pval), error('Value of BWe is not numeric'), end
            if length(pval)~=1, error('Value of BWe is not a scalar'), end
            if ~isfinite(pval), error('Value of BWe is not finite'), end
            outdata.BWe=pval;
          case 'fs'
            if ~isnumeric(pval), error('Value of fs is not numeric'), end
            if length(pval)~=1, error('Value of fs is not a scalar'), end
            if ~isfinite(pval), error('Value of fs is not finite'), end
            outdata.fs=pval;
          case 'Ns'
            if ~isnumeric(pval), error('Value of Ns is not numeric'), end
            if length(pval)~=1, error('Value of Ns is not a scalar'), end
            if ~isfinite(pval), error('Value of Ns is not finite'), end
            outdata.Ns=pval;
          case 'reconstruction_filter'
            aafilt=1; aafiltval=pval;
            if ~strcmp(aafiltval,'on')&~strcmp(aafiltval,'off')
              error(['Antialias filter value ''',aafiltval,''' not allowed'])
            end
            outdata.antialias_filter=aafiltval;
          case 'BWs'
            if ~isnumeric(pval), error('Value of BWs is not numeric'), end
            if length(pval)~=1, error('Value of BWs is not a scalar'), end
            if ~isfinite(pval), error('Value of BWs is not finite'), end
            outdata.BWs=pval;
          otherwise
            error(['Unknown property ''',prop,''''])
          end
        end
      end
    end
  else
    msg=['Unknown hardware ''',VIname,'''']; outdata=[]; return
  end %if VIname
  return
end  

% End of file
