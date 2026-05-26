function [outdata,msg] = fdhwsigl(Action,VIname,varargin)
%fdhwsigl  Interface between FDIDENT and hardware (here SigLab)
%       This file also shows the functionalities to be implemented in a
%       user-defined file fdhwfun.m, if calls are implemented to a
%       special hardware.
%
%       Input arguments:
%       Action, and corresponding outdata:
%          'Instruments'  return cell array of names of possible instruments
%          'Hardware'  return cell array of name(s) of hardware
%          'Type' Return structure of properties of instruments whose name
%                  is given as VIname:
%               outdata.domain  'TIME' or 'FREQ' or 'TIMEFREQ'
%               outdata.input   'needed' or 'not needed'
%               outdata.tooltipstring  tooltipstring for instrument
%          'Properties'
%            With more than 2 input arguments: properties to check, e.g.
%              fdhwsigl('Properties',dev,'fe',51200) returns the allowed
%              value closest to 51200, as outdata.fe
%              fdhwsigl('Properties',dev,'fe',51200,'reconstruction_filter,'on')
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
%              outdata.epxno allowed number of repeated experiments
%              outdata.repno allowed number of repetition of downloaded excitation waveform
%            With 3 input arguments: return allowed values of property:
%              e.g. fdhwsigl('Properties','VOS','fs') returns all
%              allowed values of fs
%          'HW_chk'  Return 1 if hardware is on, -1 if it is emulated,
%              else return 0. The cause returned in msg.
%          'Information' Return detailed information on given VI
%              for helpwin: that is, in the form
%              {title1,{line11;line12;...};title2,{line21;line22;...};...}
%              where all variables are strings, lines are at most 70
%              character long, and title1 is the actual virtual instrument.
%              title2 etc are optional items in the array
%              (general information about the hardware, etc).
%               if called with extra argument, then interpretes it as DEBUG MODE
%          'Measure' Open instrument given in VIname, and set parameters
%                    from excsig, and measpars
%                 measpars.expno  number of experiments
%                 measpars.repno  number of repetitions of time domain waveform
%                 measpars.delay  minimum time to wait for end of transients
%                 measpars.character  'One-shot' or 'Periodic', way of application
%                    of excitation
%                 outdata is returned as empty (if measurement is executed
%                    by hand) or a tiddata or an fiddata object (if measurement
%                    is executed automatically)
%          'take_data' Take data from an open virtual instrument.
%                 If it is not open, a warning is returned in msg, and 
%                 outdata is empty.
%          'close_all_instruments'
%                 call: fdhwsigl('close_all_instruments')
%          'isopen' Return 1 if given virtual instrument is already open%                 call: fdhwsigl('isopen',VIname)
%                 returns: 1 or 0
%          'who_using_HW' Who are using the hardware?
%                 call: string = fdhwsigl('who_using_HW')
%                 returns: string e.g. 'vnavfg' (all instruments can only occure once)
%          'SetTag' Set the VI window/control tags
%                 - tags are difined as strings at the begining (Search for TAGS)
%                 - if no tag exists when opening the VI, the defined tags are assigned
%                 - if the same tag exists as defined, no action is taken
%                 - if a different(unknown) tag is found when opening the VI, 
%                   an error is displayed in the command window (Search for TAGS), 
%                   and the 'unknown_tag' user property is set under the 
%                   Measurement window (with tag: 'fdmeasurement_main')
%                call: fdhwsigl('SetTag',VIname,handle,tagstring); VIname is no used
%          In demo files, 'Properties' need not be implemented,
%          but it should not error out, rather return empty outdata and
%          nonempty msg.
%
%          Virtual instruments implemented in this file:
%            'VNA_test'  Opens VNA and measures with chirp excitation
%               with parameter settings from chirpvna.mat
%            'VNA'  Opens VFG and VNA and allows the user to alter the
%               parameter settings
%            'VNA_internal_excitation'  Opens VNA and allows the user to
%                alter the parameter settings
%            'VSS'  Opens Virtual Swept Sine Analyser
%            'VOS'  Opens Virtual oscilloscope      
%
%          If further instrument is added, it might be necesary to add its quit fct
%          to the string variable quitstr at the begining of the file.
%          (all quit fcts should end by an ';' character)
%
%       If an error occurs, which needs to be handled outside, outdata is
%       returned as empty, and msg contains the message.
%
%       Usage: [outdata,msg] = fdhwsigl(Action,VIname,excsig,measpars);
%
%       Modified: 3-May-1999, JN
%       Modified: 28-Jan-1999, IK

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,100); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,100,ni)), %earlier
end
if nargin<2, VIname=''; end %default for VIname
outdata=[]; msg=''; excsig=[];
VIn3=[VIname,'   ']; VIn3=lower(VIn3(1:3)); %In SigLab, all instruments have 3-letter function names


%Treat varargin here
if nargin>2
  if isa(varargin{1},'tiddata')
    excsig=varargin{1};
    if nargin>=4, measpars=varargin{2}; else measpars=''; end
  elseif isstr(varargin{1})|isstruct(varargin{1})|iscell(varargin{1})
     %This is Action 'Properties' or  'setexpno' or 'Information'
     if nargin>=4, measpars=varargin{2}; else measpars=''; end
  elseif ishandle(varargin{1}) %TAGS
     % This action is SetTag
     hin = varargin{1};
     tagin = varargin{2};
  else
    error('varargin{1} is not allowed')
  end
end    

% TAGS for recording and play back
tag_VI_main = [lower(VIn3),'_plot']; % Tag for VI Plot window
tag_VI_uic_avg = [lower(VIn3),'_uic_avg']; % Tag for Avarage pushbutton on VI Plot window
tag_VFG_main = 'vfg_fig'; % Tag for VFG window
tag_VFG_uic_onoff = 'vfg_uic_onoff'; % Tag for All On/Off toggle button on VFG window
% If tags different from these are already adopted when the instruments are opened, 
% the following message is displayed:
Different_Tag_Exists = 'Warning: Found unknown tag assigned to VI window/control. Recording and play back will not be functional.';
% Search for "SetTag"

instruments = {'VNA','VNA_internal_excitation','VNA_test','VSS','VOS'};
quitstr = 'vna(''quit'');vos(''quit'');vss(2);vfg(''quit'');'; % all quit fcts should end by an ';' character


%*** ACTIONS START HERE ***

if strcmpi(Action,'Instruments')
   outdata=instruments;
   return
   
elseif strcmpi(Action,'Hardware')
   outdata={'SigLab'}; %Default possibilities
   return
   
elseif strcmpi(Action,'information')
   msg='';
   % Excitation, Analysis settings, Automatic services, Cancel
   if strcmpi(VIname,'VNA')|strcmpi(VIname,'VOS'),
      txt21={' '; % for VNA, VOS (with VFG use)
         'If excitation signal has been defined, this is loaded to the VFG and';
         'the analysis settings are automatically adjusted according to';
         'the record length and bandwidth of the excitation signal.';
         '(See the topics: Excitation, Analysis settings.)';
         ' ';
         'Standard measurement procedure:';
         '1. Press the ''All off'' toggle button in the VFG to turn on the';
         '   excitation. (Allow time for the transients if necessary.)';
         '2. Press the pushbutton ''Avg'' in the VNA (at the bottom of the ';
         '   larger window) to start the measurement.';};
   elseif strcmpi(VIname,'VNA_internal_excitation'),
      txt21={' ';
         '0. Set the measurement parameters.';
         '1. Turn on the excitation by pressing the ''Off'' toggle button';
         '   in the ''EXCITATION'' box.';
         '   (Allow time for the transient if needed.)';
         '2. Press the ''Avg'' push button on the VNA (at the bottom of the ';
         '   larger window.) to start the measurement.';};
   elseif strcmpi(VIname,'VSS'),
      txt21={' ';
         '1. Select ''Setup'' in the menu of the VSS and make your settings.';
         '2. Press the ''Run'' toggle button on the VNA to start the';
         '   measurement.';};
   end
   
   if strcmpi(VIname,'VNA_test'),
      txt22={' '; % for VNA_test      
         'The virtual instrument automatically returns the measured data'; 
         'once the ''Goto VI'' has been pressed, so the button ''Take data''';
         'need not be used.'};
   else
     txt22={...
         '3. When the measurement is ready, transfer the results by either:';
         '   - selecting ''Quit'' from the ''File'' menu of the VI, or';
         '   - pressing the ''Take data'' push button.';
         'Closing the Measurement window will automatically shut down the VI.'};
   end
   
      txt22int={' '; % VNA_internal_excitation
         'Note that although the VFG is not opened automatically, you can use';
         'external excitation by doing the following:';
         '1. Select Excitation | Independent (Vfg) in the menu of the VNA';
         '2. Select Vfg in the menu. This is goin to open up the VFG.';
         '3. Set the excitation and measurement parameters.';
         '4. Turn the excitation on by pushing the toggle button''All off''';
         '   on the VFG.';
         '5. Start the measurement.'};
   
   % Excitation for VNA, VOS 
   txt41={'If excitation signal has been designed beforehand, this waveform will be ';
      'loaded into the VFG. If more than one repetitions are requested in the';
      'edit box ''# of repetitions'', the excitation signal will be repeated.';
      ' ';
      'The resulting record length of the excitation may not exceed 8192 and';
      'it must be a power of 2.';
      'The bandwidth of the signal may not exceed 1/2.56 of the clock frequency. ';
      'This has to be taken into account at the design of the signal.';
      'The clock frequency of the excitation must take on a value from the';
      'following set: {5.12, 12.8, 25.6, 51.2}*{Hz, 10Hz, 100Hz, kHz}.';
      'If the signal was designed with a different sampling frequency, the '
      'next greater possible clock frequency is selected. ';
      'This results in a proportional modification of the signal''s bandwidth.';
      ' ';
      'Note that an excitation signal, other than the originally designed one,';
      'may also be used for the measurement, but in this case only minimal ';
      'automatic services are provided. (See the topic: Automatic services.)';};
   
   txt42={' '; % Automatic services       
      'The services described below are only provided if an excitation signal';
      'has been designed, and this signal is unaltered in the instrument.';
      'However, the following modifications are allowed:';
      'a) repeated waveform (# of repetititons)';
      'b) different clock frequency and bandwidth';
      'c) different peak value';
      'd) different offset value';
      '  ';
      'The following services are automaticly carried out:';
      'a) The excitation signal is loaded to the VFG in repeated form.';
      'b) The measurement clock frequency (VNA) or time base (VOS) is set to match ';
      '   the clock frequency of the excitation (VFG). (See topic: Analysis settings)';
      '   These are updated for each new setting of the excitation clock frequency.';
      'c) After ''VNA'' measurements, the relevant frequency points are automatically';
      '   selected at the end of the measurement.';
      '   (Note: at frequencies where the excitation signal has no power, no ';
      '   information is available. In the nonparametric FRF, this is exhibited ';
      '   by the division of two values around zero.)';};
   txt23={''; % for VNA
      'If the measurements are carried out keeping the original excitation signal';
      'and settings, analysed frequency points are automatically selected when';
      'results are transfered.(See topic: Automatic services)';};
   % 0/0 in FRF
   txt24={' '; % for VNA and VNA_internal_excitation
      'Note that at frequency points where the excitation is zero,';
      'the transfer function is usually completely faked by the division ~0/~0.';
      'This, however, will not corrupt your parameter estimation if proper ';
      'variance analysis is done, especially if the excited frequencies';
      'are properly selected. (See also the topic: Analysis settings)';};
   % Analysis settings
   txt43={' ';
     'While the excitation record length in the VFG is the length of the record';
     'downloaded into the VFG, the analysis record length in VNA/VOS is the number of ';
      'samples returned, that is, the number of samples after decimation. Hence,';
      ' ';
      'Analysis Record Length / Analysis BW = Excitation Record Length / Excitation BW';
      ' ';
      'should always hold.'
      ' ';
      'If not an ''arbitrary'' waveform is used, the Excitation BW always equals 20 kHz.'};
   % CANCEL
   txt44={'If you want to cancel the results of the measurements, so that data are NOT';
      'transferred from the VI to the FDIDENT toolbox, simply destroy the VI window.';
      };
   if strcmpi(VIn3,'VOS') % VOS
      txtl1={'Noise-contaminated time domain input-output data are returned.'};
   else % VNAx or VSS (for frequency domain measurements)
      txtl1={'Transfer and coherence functions are returned.'};
   end
   
   if ~isempty(varargin), % i.e. DEBUG MODE
      txt22{length(txt22)}=[txt22{length(txt22)},'TXT22'];
      txtl1{length(txtl1)}=[txtl1{length(txtl1)},'TXTl1'];
      txt21{length(txt21)}=[txt21{length(txt21)},'TXT21'];
      txt23{length(txt23)}=[txt23{length(txt23)},'TXT23'];
      txt24{length(txt24)}=[txt24{length(txt24)},'TXT24'];
      txt41{length(txt41)}=[txt41{length(txt41)},'TXT41'];
      txt42{length(txt42)}=[txt42{length(txt42)},'TXT42'];
      txt43{length(txt43)}=[txt43{length(txt43)},'TXT43'];
      txt44{length(txt44)}=[txt44{length(txt44)},'TXT44'];
   end

   switch upper(VIname) % UPPER CASE!!!
   case 'VNA'
      txt1={'Open a Virtual Network Analyser (VNA) and a Function Generator (VFG) ';
         'for frequency domain measurements.'};   
      outdata={VIname,[txt1;txtl1;txt21;txt22;txt23;txt24];'Excitation',txt41; 'Automatic services', txt42; 'Analysis settings', txt43; 'Cancel', txt44};
   case 'VNA_INTERNAL_EXCITATION'
      txt1={'Open a Virtual Network Analyser (VNA) for frequency domain measurements.'};
      txtif={' ';
        'If external excitation is used :'};
      outdata={VIname,[txt1;txtl1;txt21;txt22;txtif;txt24];'Excitation',txt41; 'Analysis settings', [txtif;txt43]; 'Cancel', txt44};
   case 'VNA_TEST'
      txt1={'Test the Virtual Network Analyser (VNA) by an automatically';
         'executed measurement.'};
      outdata={VIname,[txt1;txtl1;txt22]};
   case 'VOS'
      txt1={'Open a Virtual Oscilloscope (VOS) and Function Generator (VFG) ';
         'for time domain measurement.'};
      outdata={VIname,[txt1;txtl1;txt21;txt22;txt24];'Excitation',txt41; 'Automatic services', txt42; 'Analysis settings', txt43; 'Cancel', txt44};
   case 'VSS'
      txt1={'Open a Virtual Stepped Sine analyser (VSS) for frequency domain ';
         'measurements.'};
      outdata={VIname,[txt1;txtl1;txt21;txt22]; 'Cancel', txt44};
   otherwise
      outdata=[]; msg='Instrument not found in fdhwsigl';
   end
   return;

elseif strcmpi(Action,'Type')
   if nargin<2, error('No instrument is given for Action ''Type'''), end
   switch VIname
   case 'VNA'
      outdata.domain='FREQ';
      outdata.input='not needed';
      outdata.tooltipstring='Virtual Network Analyzer';
   case 'VNA_internal_excitation'
      outdata.domain='FREQ';
      outdata.input='not needed';
      outdata.tooltipstring='Virtual Network Analyzer with internal excitation';
   case 'VNA_test'
      outdata.domain='FREQ';
      outdata.input='not needed';
      outdata.tooltipstring='Virtual Network Analyzer automatic test';
   case 'VSS'
      outdata.domain='FREQ';
      outdata.input='not needed';
      outdata.tooltipstring='Virtual Swept Sine Analyzer';
   case 'VOS'
      outdata.domain='TIME';
      outdata.input='needed';
      outdata.tooltipstring='Virtual Oscilloscope';
   otherwise
      outdata=[]; msg='Unknown instrument in fdhwsigl'; return
   end
   return
   
elseif strcmpi(Action,'Properties')
  v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
  if v(1)>='9', narginchk(2,100); %Matlab 2016a or later
  else ni=nargin; error(nargchk(2,100,ni)), %earlier
  end    if iscell(VIname)
      if length(VIname)==1, VIname=VIname{1};
      else error('Only one device can be handled at a time')
      end
   end
   if strcmpi(VIname,'SigLab')|ismember(VIname, instruments)
      Amax=10; A=NaN;
      fe=[51200 25600 12800 5120 2560 1280 512 256 128 51.2 25.6 12.8 5.12];
      Ne=[64:8192];
      reconstruction_filter=NaN;
      BWe=[20000 10000 5000 2000 1000 500 200 100 50 20 10 5 2];
      fs=[51200 25600 12800 5120 2560 1280 512 256 128 51.2 25.6 12.8 5.12];
      Ns=2.^[6:13];
      antialias_filter=NaN;
      BWs=[20000 10000 5000 2000 1000 500 200 100 50 20 10 5 2];
      expno=inf;
      repno=inf;
      if nargin==2
         outdata.A=A;
         outdata.fe=fe;
         outdata.Ne=Ne;
         outdata.reconstruction_filter=reconstruction_filter;
         outdata.BWe=BWe;
         outdata.fs=fs;
         outdata.Ns=Ns;
         outdata.antialias_filter=antialias_filter;
         outdata.BWs=BWs;
         outdata.expno=expno;
         outdata.repno=repno;
      else %nargin>2
         if ~isstr(varargin{1})
            msg='Property name is not a string'; return
         end
         lv=length(varargin);
         if lv==1 %return allowed values 
            eval(['outdata=',varargin{1},';']) %return value
            return
         else %lv>1
            if rem(lv,2)==1, error('Odd number of elemenents in varargin'), end
            outdata=[]; recfilt=0; aafilt=0;
            for ii=1:2:length(varargin)-1
               prop=varargin{ii}; pval=varargin{ii+1};
               if ~isstr(prop)
                  msg='Property name is not a string'; return
               end
               switch prop
               case 'A'
                  if ~isnumeric(pval), error('Value of A is not numeric'), end
                  outdata.A=min(Amax,abs(pval));
               case 'fe'
                  if ~isnumeric(pval), error('Value of fe is not numeric'), end
                  if length(pval)~=1, error('Value of fe is not a scalar'), end
                  if ~isfinite(pval), error('Value of fe is not finite'), end
                  if isfield(outdata,'BWe')
                     pval=2.56*outdata.BWe;
                  end
                  [minv,ind]=min(abs(pval-fe));
                  outdata.fe=fe(ind);
               case 'Ne'
                  if ~isnumeric(pval), error('Value of Ne is not numeric'), end
                  if length(pval)~=1, error('Value of Ne is not a scalar'), end
                  if ~isfinite(pval), error('Value of Ne is not finite'), end
                  [minv,ind]=min(abs(pval-Ne));
                  outdata.Ne=Ne(ind);
               case 'reconstruction_filter'
                  recfilt=1; %reconstruction filter property was set
                  recfiltval=pval;
                  if ~strcmp(recfiltval,'on')&~strcmp(recfiltval,'off')
                     error(['Reconstruction filter value ''',recfiltval,''' not allowed'])
                  end
                  outdata.reconstruction_filter=recfiltval;
               case 'BWe'
                  if ~isnumeric(pval), error('Value of BWe is not numeric'), end
                  if length(pval)~=1, error('Value of BWe is not a scalar'), end
                  if ~isfinite(pval), error('Value of BWe is not finite'), end
                  if isfield(outdata,'fe')
                     pval=outdata.fe/2.56;
                  end
                  [minv,ind]=min(abs(pval-BWe));
                  outdata.BWe=BWe(ind);
               case 'fs'
                  if ~isnumeric(pval), error('Value of fs is not numeric'), end
                  if length(pval)~=1, error('Value of fs is not a scalar'), end
                  if ~isfinite(pval), error('Value of fs is not finite'), end
                  [minv,ind]=min(abs(pval-fs));
                  outdata.fs=fs(ind);
               case 'Ns'
                  if ~isnumeric(pval), error('Value of Ns is not numeric'), end
                  if length(pval)~=1, error('Value of Ns is not a scalar'), end
                  if ~isfinite(pval), error('Value of Ns is not finite'), end
                  [minv,ind]=min(abs(pval-Ns));
                  outdata.Ns=Ns(ind);
               case 'antialias_filter'
                  aafilt=1; %antialias filter property is set
                  aafiltval=pval;
                  if ~strcmp(aafiltval,'on')&~strcmp(aafiltval,'off')
                     error(['Antialias filter value ''',aafiltval,''' not allowed'])
                  end
                  outdata.antialias_filter=aafiltval;
               case 'BWs'
                  if ~isnumeric(pval), error('Value of BWs is not numeric'), end
                  if length(pval)~=1, error('Value of BWs is not a scalar'), end
                  if ~isfinite(pval), error('Value of BWs is not finite'), end
                  [minv,ind]=min(abs(pval-BWs));
                  outdata.BWs=BWs(ind);
               case 'expno'
                  outdata.expno=pval;
               case 'repno'
                  outdata.repno=pval;
               otherwise
                  %error(['Unknown property ''',prop,''''])
                  warning(['Property ''',prop,''' not yet handled in fdhwsigl'])
                  outdata=setfield(outdata,prop,pval);               end
            end %for ii
            if recfilt
               %Reconstruction filter property was set
               if isfield(outdata,'fe')
                  if isequal(outdata.fe,max(fe)) %maximum allows no filter
                     outdata.reconstruction_filter='off';
                  else %otherwise reconstruction filter is always on
                     outdata.reconstruction_filter='on';
                  end
               elseif isfield(outdata,'BWe')
                  if isequal(outdata.BWe,max(BWe)) %maximum allows no filter
                     outdata.reconstruction_filter='off';
                  end
               else %neither fe nor BWe are defined
                  outdata=[];
                  msg=['Error: Cannot determine allowed value of ',...
                        'reconstruction_filter without fe'];
               end
               if strcmp(outdata.reconstruction_filter,'off')
                  %reconstruction filter is off only at highest excitation clock freq
                  outdata.fe=max(fe); outdata.BWe=max(BWe);
               end
            end
            if aafilt
               if isfield(outdata,'fs')
                  if isequal(outdata.fs,max(fs))
                     outdata.antialias_filter='off'; %filter is off under maximum
                  end
               elseif isfield(outdata,'BWs')
                  if isequal(outdata.BWs,max(BWs))
                     outdata.antialias_filter='off'; %filter is off under maximum
                  end
               else %neither fs nor BWs are defined
                  outdata=[];
                  msg='Error: Cannot determine allowed value of antialias_filter without fs';
               end
               if strcmp(outdata.antialias_filter,'off')
                  outdata.fs=max(fs); outdata.BWs=max(BWs);
               end
            end
         end
      end
   else
      msg=['Unknown hardware or instrument ''',VIname,'''']; outdata=[]; return
   end %if VIname
   return
   
elseif strcmpi(Action,'HW_chk')
   if (nargin>1)& ~(ismember(VIname,instruments) | strcmpi(VIname,'Siglab')) 
      outdata=[]; msg='Instrument does not exist';
      return
   end
   if exist('siglab')==2 %M-file emulator
      %simulation case
      outdata=-1;
      msg='Emulated';
   elseif strncmpi(computer,'PCWIN',5)&(exist('siglab')==3)
      %siglab is a MEX-file on a PC: regular siglab may be present
      eval('[drv,ppath] = pathfind(''vbin'');    [nc outnc bw dllver] = siglab(''IOinit'',[drv,ppath,''\siglab.out''],0);');
      if nc==0
         outdata=0;
         msg='No Siglabs found.';
      else
         outdata=1;
      end
   else
      outdata=0;
      msg='Neither SigLab, nor a SigLab emulator is installed';
   end
   return
   
elseif strcmpi(Action,'isopen')
   if nargin<2
      outdata=[]; msg='Virtual instrument is not given'; return
   end
   h_all=findobj('type','figure'); h=[];
   for indx=1:length(h_all),
      eval('namestr=lower(get(h_all(indx),''Name''));','');
      position = findstr(lower(namestr), lower(VIn3));
      if isempty(position), 
      elseif position(1)==1 
         figure(h_all(indx)); % bring it in front
         if ~any(findstr(lower(namestr),'(plot)')) , h=[h h_all(indx)]; end
      end   
   end % end for
   switch length(h)
   case 0, 
      outdata = 0; msg='';
      return;
   case 1
      outdata=1;
      figure(h); % Thus the caller function can get its handle by gcf.
   otherwise
      outdata=0; disp(['Warning: Cannot identify ' VIn3 ' instrument window unambigously.']);
   end % end switch   
   
elseif strcmpi(Action,'getfig') % get figures handle
   if nargin<2
      outdata=[]; msg='Virtual instrument is not given'; return
   end
   h_all=findobj('type','figure'); h=[];
   for indx=1:length(h_all),
      eval('namestr=lower(get(h_all(indx),''Name''));','');
      position = findstr(lower(namestr), lower(VIn3));
      if isempty(position), 
      elseif position(1)==1 
         if ~any(findstr(lower(namestr),'(plot)')) , h=[h h_all(indx)]; end
      end   
   end % end for
   switch length(h)
   case 0, 
      outdata = []; disp(['Warning: Cannot find' VIn3 ' instrument window.']);
      return;
   case 1
      outdata=h;
   otherwise
      outdata=[]; disp(['Warning: Cannot identify ' VIn3 ' instrument window unambigously.']);
      return;
   end % end switch   
   

   
elseif strcmpi(Action,'who_using_HW') % which instrument is using the hardware
   eval('[st owners]=hw_stat(''owners'');','owners='''';') %Hide from Matlab 5.2
   if isempty(owners),
      outdata = '';
   else
      if  owners(1,1)~='_', outdata = owners(1,1:3); end
      if (owners(2,1)~='_' & owners(1,1:3)~=owners(2,1:3)), outdata = [outdata,owners(2,1:3)];   end
   end
   
elseif strcmpi(Action,'close_all_instruments')
   % Calling the quit fcts can cause errors if the corresponding instrument is not opened
   % Otherwise it would be so simple with evaluate, etc. !
   end_positions = findstr(quitstr,';');
   if end_positions(length(end_positions))~=length(quitstr), % a simple check
      disp(['Warning: Check the ''constant'' quitstr in file fdhwsigl for missing ; at the end!']);
      disp(quitstr);
      quitstr = [quitstr ';'];
      end_positions = findstr(quitstr,';');
   end
   open_insts = fdhwsigl('who_using_HW'); % collect the instruments to be closed
   if rem(length(open_insts),3), % a simple check
      disp(['Error: There is some problem with automatic shut down of instruments. Check file fdhwsigl.m']);
      disp(['The following string should contain the name of opened instruments: n*3 characters!']);
      disp(open_insts);
      open_insts = open_insts(mod(length(open_insts),3));
   end
   while length(open_insts),
      curr_inst = open_insts(1:3);
      start_position = findstr(lower(quitstr),lower(curr_inst));
      if isempty(start_position),
         disp(['Error: Quit function for ', curr_inst, ' is not defined in file fdhwsigl.m (quitstr).'])
         outdata =[];msg=['Close the instrument' curr_inst];
         return;
      end
      diffs = end_positions-start_position; 
      [mindiff, index] = min(abs((1-sign(diffs))*1000+diffs));
      quitfct = quitstr(start_position:end_positions(index));
      eval(quitfct,'disp[''Error: calling quit function.''];');
      if length(open_insts)>3, 
         open_insts = open_insts(1:length(open_insts)-3);
      else 
         %disp(['The following instruments are still using the hardware:']);
         %disp(fdhwsigl('who_using_HW'));
         open_insts=fdhwsigl('who_using_HW');
      end
   end; % end while
   
elseif strcmpi(Action,'SetTag')
   tagold = get(hin,'Tag');
   if isempty(tagold)
      set(hin,'Tag',tagin);
   elseif strcmpi(tagold,tagin)
      % no action is taken
   else
      % unknown tag!
      disp(Different_Tag_Exists);
      hmeasw = findall(0,'Tag','fdmeasurement_main');
      if isempty(hmeasw)
         disp('Error:Measurement window is not found.');
      else
         setuprop(hmeasw,'unknown_tag',1);
      end
   end   

   
% *** All measurements and the transfer of the results (take_data) take place in this branch. ***  
elseif strcmpi(Action,'Measure')|strcmpi(Action,'take_data')|strcmpi(Action,'get_meas')
  if ~exist(VIn3) %check if corresponding function exists
    fdmeasw('status',['Error: ',VIn3,'.m does not exist'])
    guifreez('fdmeasurement_main', 'unfreeze', 'fdmeas_measurement');
    outdata=[];
    return
  end % end if ~exist
  
  % TAKE MEASUREMENT RESULT FROM INSTRUMENT (VERSION UNDER DEVELOPMENT)
  % 
  if strcmpi(Action,'get_meas')
     % user properties under VI:
     %    fdhwsigl_avg_callback
     %    fdhwsigl_data
     %    fdhwsigl_data_ready
     %    fdhwsigl_expno
     %    fdhwsigl_counter
     %
     % get_meas STAGE 1.
     % A) Enable clear_data pb, disable Avg pb. (if clear_data pb is pressed they are
     %    going to be set the other way round.)
     % B) If 'fdhwsigl_data_ready' is set, then two cases are possible:
     %    case 1 : Expno=1 and take_data calls get_meas -> CONTINUE
     %    case 2 : Expno>1 , Count<Expno and Stop pb has been pushed -> RETURN
     %     see explanation below and action 'take_data'
     if ~fdhwsigl('isopen',VIname), outdata=0; msg='Error: Instrument not open.'; end; % set VI current figure
     hvi=gcf; % VI's handle
     % control enable/disable
     h_clr=findall(0,'Tag','fdhwsigl_uic_clr');
     set(h_clr,'Enable','On');
     h_avg=findall(0,'String','Avg');
     set(h_avg,'Enable','Off');
     if getuprop(hvi,'fdhwsigl_data_ready') % This is necessary for the stop push buton to work !!!
        if isempty(getuprop(hvi,'fdhwsigl_expno')) | any(getuprop(hvi,'fdhwsigl_expno')==1),
           % CONTINUE
           % Explanation:
           % 1. Because VSS is differnet from VOS and VNA, we kept the old mechanism for
           % taking away data for single measurements, i.e. where Expno=1. (With VSS only 
           % single measurements can be carried out.) This means that instead of using 
           % get_meas uniquely for collecting measurement results from the VI 
           % we also call it from take_data if Expno=1 to take the data (once again)
           % from the VI. (Normally, when Expno>1, take_data uses the 'fdhwsigl_data' user property
           % and do not call get_meas again.)
           % 2. When Expno=1, and take_data calls get_meas, we shall not return, whereas
           % with Expno>1, we are in the case when the push button Stop is pressed, and 
           % 'fdhwsigl_count'<'fdhwsigl_expno'.
        else
           return;   
        end
     end
     
     % get_meas STAGE 2.
     % A) get the result of the current measurement from the VI
     % B) Check measurement setup if VNA
     % C) Select frequencies if VNA was used with predesigned excitation 
     % D) Examine coherence values if freq. domain meas.
     % E) Prepare tidata or fidata object and store it in outdata
     %The caller must make sure that the instrument is open, it is not checked here!
     getmeas=['result = ' ,VIn3, '(''get'',''meas'');'];
     eval(getmeas);
     prop=fdhwsigl('Type',VIname);  
     if prop.domain=='FREQ'
        if isfield(result,'fdxvec') %Extract data + measurement parameters from SLm object
           freqv=result.fdxvec; % get frequency vector
           tf=result.xcmeas(1,2).xfer; % get transfer function vector (lin scale)
           coh=result.xcmeas(1,2).coh; % get coherence vector
           if strcmpi(VIname,'VNA'),
              % select frequencies (This is only needed for VNA measurements)
              fs=1/(result.tdxvec(2)-result.tdxvec(1)); % (needs SLm object)
              hvfg=fdhwsigl('getfig','vfg');%
              if any(getuprop(hvfg,'designed_excitation_in_use')),
                 fe=1/getuprop(hvfg,'excsig_ts');
                 FsCorr=fs/fe;
                 excvec=getuprop(hvfg,'excsig_freqs')*FsCorr;
                 indxs=find(ismember(excvec,freqv));
                 findxs=0;
                 for i=1:length(indxs),
                    findxs(i)=find(~(freqv-excvec(indxs(i))));
                 end
                 freqv=freqv(findxs);
                 tf=tf(findxs);
                 coh=coh(findxs);
              elseif ~isempty(excsig)
                 disp(['Warning: Excitation has been redefined. Frequency selection will not be automatically done.']); 
              else
                 disp(['Warning: Excitation defined on VI. Frequency selection will not be automatically done.']); 
              end % end excitation signal
           end % end VNA->frequ selection
           %Check parameter settings for the measurement
           if result.zpad, fdmeasw('status','Warning: Zero-padding option was selected during FRF measurement.'); end
           if result.ovld, fdmeasw('status','Warning: Overload occured on one of the channels during FRF measurement.'); end
           if result.zoomcf, fdmeasw('status','Warning: Frequency zomming was on during FRF measurement.'); end
        else % obsolete data type (as it is now the case with VSS)
           eval(['[freqv tf xmap coh] =' ,VIn3, '(''get'',''meas'');']) %Hide from Matlab 5.2     
        end % end if: isfield(fdxvec
        % clear interface changed flag & return data
        eval('ls_vna(''clear'',''STATE_CHG'');','disp([''Warning: Could not clear vna dirty flag'']);');   
        outdata=fiddata(tf,ones(size(tf)),freqv);
        set(outdata,'synchronization','on','noconsistency')
        if any(getuprop(hvi,'fdhwsigl_expno')==1)
           %Now make sure that illegal coherence values do not arrive
           cohlim=1-0.00001;
           ind=find(abs(coh)>cohlim);
           ind1=find(abs(coh)>1);
           if ~isempty(ind1)
              warning(sprintf(' %.0f coherence values are over 1',length(ind1)))
           end
           if ~isempty(ind)
              warning(sprintf(' %.0f coherence values are too large',length(ind)))
              coh=coh/max(max(abs(coh)),1)*cohlim;
           end
           set(outdata,'cohvect',coh,'noconsistency');%!!!!!!!!!!!
        end
     elseif isfield(result,'tdxvec') %Extract data + measurement parameters from SLm object
        % VOS is certain to have SLm data structure, hence the difference from the freq.dom. branch
        % Time domain measurement
        hvfg=fdhwsigl('getfig','vfg');
        Ts=result.tdxvec(2)-result.tdxvec(1);
        tf1=result.scmeas(1).tdmeas;
        tf2=result.scmeas(2).tdmeas;
        eval('ls_vos(''clear'',''STATE_CHG'');','disp([''Warning: Could not clear vos dirty flag'']);');   
        outdata=tiddata(tf2,tf1,Ts);
        hvfg=fdhwsigl('getfig','vfg');
        if ~rem(length(tf1),getuprop(hvfg,'excsig_len')) & any(getuprop(hvfg,'designed_excitation_in_use')),
           % case1: excitation exists and measurement has been made using it (with repno)
           %  Remark: the condition underneath (it was a first attempt) could not work, as the returned input data is measured thus the dynamics of the actuator can make problems:
           %  max([excsig.Input]-tf1(1:length(excsig.Input)))<eps*max([excsig.Input]), 
           FsCorr=getuprop(hvfg,'excsig_ts')/Ts; % fs/fe
           excvec=getuprop(hvfg,'excsig_freqs')*FsCorr;
           set(outdata,'Frequencies',excvec,'noconsistency');
           set(outdata,'PeriodLength',...
              getuprop(hvfg,'excsig_periodlen')/FsCorr,'noconsistency');
        elseif ~isempty(excsig)
           % case2: excitation exists but measurement has been made using a different signal
           %set(outdata,'Frequencies',excvec)
           %set(outdata,'InputFrequencies',excvec)
           set(outdata,'PeriodLength',length(tf1)*Ts,'synchronization','on',...
              'noconsistency')
        else
           % case3: excitation does not exist, measurement has been made using any signal
           % rem ide kell meg valami
        end;
     else % else : if neither time domain, nor frequency domain data
        fdhwsigl('close_all_instruments');
        outdata=0;msg=['Error: problem with returned datatype in fdhwsigl.m'];
        % rem Return value is not going to be returned, so
        %     an unvisible object would be good, created by gotoVI
        %     destroyed by Close.
        disp(msg);
        return;
     end % end if prop.domain FREQ (freq. domain / time. domain / else error)
     h_AAF=[findall(0,'String','AA Filters On'),findall(0,'String','AA Filters Off')];
     if isempty(h_AAF) | get(h_AAF,'userdata')
        % AA Filter On
        set(outdata,'InputCharacter','BL','OutputCharacter','BL','noconsistency')
     else
        % AA FIlter Off
        set(outdata,'InputCharacter','Samples','OutputCharacter','Samples','noconsistency')
     end
     outdata.consistency;
     % get_meas STAGE 3. 
     % Now we have the result of the current measurement.
     % A) If Expno=1,  
     % B) append this result to the previous results contained under 
     %    the VI's figure in the fdhwsigl_data property and
     %    rem: Coherence values are superflous
     % C) augment the counter of experiments, display the new value
     % D) If the number of experiments specified in Expno is attained
     %    set the fdhwsigl_data_ready property under the VI to 1, else
     %    call the original avarage callback again. (It is stored in the
     %    user property called fdhwsigl_avg_callback).
     if isempty(getuprop(hvi,'fdhwsigl_expno')) | any(getuprop(hvi,'fdhwsigl_expno')==1)
        % This 'if' statement may be removed together with the appropriate parts in take_data
        % once the problem of VSS is solved.
        h_expno = findall(0,'Tag','fdhwsigl_uic_expno');
        set(h_expno,'String','ExpNo: 1 of 1');
        setuprop(hvi,'fdhwsigl_data', outdata); % just to be correct
        setuprop(hvi,'fdhwsigl_counter',1); % just to be correct
        setuprop(hvi,'fdhwsigl_data_ready',1); % just to be correct
        % This latter one even causes some trouble when we get to STAGE1
        return;
     end
     if isempty(getuprop(hvi,'fdhwsigl_data')),
        setuprop(hvi,'fdhwsigl_data', outdata);
     else
        setuprop(hvi,'fdhwsigl_data',[getuprop(hvi,'fdhwsigl_data'), outdata]);
     end
     counter = getuprop(hvi,'fdhwsigl_counter');
     if isempty(counter), counter=1; else counter=counter+1; end;
     setuprop(hvi,'fdhwsigl_counter',counter);
     expno = getuprop(hvi,'fdhwsigl_expno');
     h_expno = findall(0,'Tag','fdhwsigl_uic_expno');
     set(h_expno,'String',['ExpNo: ', num2str(counter), ' of ', num2str(expno)]);
     if counter>=expno, 
        % end of measurement
        setuprop(hvi,'fdhwsigl_data_ready',1);
     else 
        avgCB = getuprop(hvi,'fdhwsigl_avg_callback');
        eval(avgCB); % 
     end; 
     
     %end if Action is get_meas
     
     % TRANSFER ALL MEASUREMENT RESULTS FROM INSTRUMENT (VERSION UNDER DEVELOPMENT)
  elseif strcmpi(Action,'take_data') % 
     fdhwsigl('isopen',VIname);hvi=gcf;
     if isempty(getuprop(hvi,'fdhwsigl_expno')) | any(getuprop(hvi,'fdhwsigl_expno')==1)
        % This branch may be removed together with the appropriate parts in get_meas
        % once the problem of VSS is solved.
        [outdata,msg]=fdhwsigl('get_meas',VIname);
     else
        if getuprop(hvi,'fdhwsigl_data_ready'),
           outdata=getuprop(hvi,'fdhwsigl_data');
           msg='';
           return;
        else
           outdata=0;
           msg='Measurement data is not yet available.';
           return;
        end
     end
     
     % OBSOLETE!!!
     % TAKE MEASUREMENT RESULTS FROM INSTRUMENT
  elseif strcmpi(Action,'take_data_obsolete') 
     % This part is common for all instruments
     %The caller must make sure that the instrument is open
     getmeas=['result = ' ,VIn3, '(''get'',''meas'');']
     eval(getmeas);
     prop=fdhwsigl('Type',VIname);  
     if prop.domain=='FREQ'
        if isfield(result,'fdxvec') %Extract data + measurement parameters from SLm object
           freqv=result.fdxvec; % get frequency vector
           tf=result.xcmeas(1,2).xfer; % get transfer function vector (lin scale)
           coh=result.xcmeas(1,2).coh; % get coherence vector
           if strcmpi(VIname,'VNA'),
              % select frequencies (This is only needed for VNA measurements)
              fs=1/(result.tdxvec(2)-result.tdxvec(1)); % (needs SLm object)
              fdhwsigl('isopen','vfg'); % gcf
              if any(getuprop(gcf,'designed_excitation_in_use')),
                 fe=1/getuprop(hvfg,'excsig_ts');
                 FsCorr=fs/fe;
                 excvec=getuprop(hvfg,'excsig_freqs')*FsCorr;
                 indxs=find(ismember(excvec,freqv));
                 findxs=0;
                 for i=1:length(indxs),
                    findxs(i)=find(~(freqv-excvec(indxs(i))));
                 end
                 freqv=freqv(findxs);
                 tf=tf(findxs);
                 coh=coh(findxs);
              elseif ~isempty(excsig)
                 disp(['Warning: Excitation has been redefined. Frequency selection will not be automatically done.']); 
              else
                 disp(['Warning: Excitation defined on VI. Frequency selection will not be automatically done.']); 
              end % end excitation signal
           end % end VNA->frequ selection
           %Check parameter settings for the measurement
           if result.zpad, fdmeasw('status','Warning: Zero-padding option was selected during FRF measurement.'); end
           if result.ovld, fdmeasw('status','Warning: Overload occured on one of the channels during FRF measurement.'); end
           if result.zoomcf, fdmeasw('status','Warning: Frequency zomming was on during FRF measurement.'); end
        else % obsolete data type (as it is now the case with VSS)
           eval(['[freqv tf xmap coh] =' ,VIn3, '(''get'',''meas'');']) %Hide from Matlab 5.2     
        end % end if: isfield(fdxvec
        %Now make sure that illegal coherence values do not arrive
        cohlim=1-0.00001;
        ind=find(abs(coh)>cohlim);
        ind1=find(abs(coh)>1);
        if ~isempty(ind1)
           warning(sprintf('Warning: %.0f coherence values are over 1',length(ind1)))
        end
        if ~isempty(ind)
           warning(sprintf('Warning: %.0f coherence values are too large',length(ind)))
           coh=coh/max(max(abs(coh)),1)*cohlim;
        end
        % clear interface changed flag & return data
        eval('ls_vna(''clear'',''STATE_CHG'');','disp([''Warning: Could not clear vna dirty flag'']);');   
        outdata=fiddata(tf,ones(size(tf)),freqv);
        set(outdata,'cohvect',coh)
     elseif isfield(result,'tdxvec') %Extract data + measurement parameters from SLm object
        % VOS is certain to have SLm data structure, hence the difference from the freq.dom. branch
        % Time domain measurement
        Ts=result.tdxvec(2)-result.tdxvec(1);
        tf1=result.scmeas(1).tdmeas;
        tf2=result.scmeas(2).tdmeas;
        eval('ls_vos(''clear'',''STATE_CHG'');','disp([''Warning: Could not clear vos dirty flag'']);');   
        outdata=tiddata(tf2,tf1,Ts);
        fdhwsigl('isopen','vfg'); hvfg=gcf;% to get gcf=vfg handle
        if ~rem(length(tf1),getuprop(hvfg,'excsig_len')) & any(getuprop(gcf,'designed_excitation_in_use')),
           % case1: excitation exists and measurement has been made using it (with repno)
           %  Remark: the condition underneath (it was a first attempt) could not work, as the returned input data is measured thus the dynamics of the actuator can make problems:
           %  max([excsig.Input]-tf1(1:length(excsig.Input)))<eps*max([excsig.Input]), 
           FsCorr=getuprop(hvfg,'excsig_ts')/Ts; % fs/fe
           excvec=getuprop(hvfg,'excsig_freqs')*FsCorr;
           set(outdata,'Frequencies',excvec);
           set(outdata,'PeriodLength',getuprop(hvfg,'excsig_periodlen')/FsCorr);
        elseif ~isempty(excsig)
           % case2: excitation exists but measurement has been made using a different signal
           %set(outdata,'Frequencies',excvec)
           %set(outdata,'InputFrequencies',excvec)
           set(outdata,'PeriodLength',length(tf1)*Ts)
        else
           % case3: excitation does not exist, measurement has been made using any signal
           % ide kell meg valami
        end;
     else % else : if neither time domain, nor frequency domain data
        fdhwsigl('close_all_instruments');
        outdata=0;msg=['Error: Unexpected branch (3) in fdhwsigl.m'];
        disp(msg);
        return;
     end % end if prop.domain FREQ (freq. domain / time. domain / else error)
  end % end if Action is Take_data   
  
  % START MEASUREMENT WITH GIVEN INSTRUMENT (open instrument, etc.)
  if strcmpi(Action,'Measure') 
     % Opens the instrument with the specified init file if exists
     % if instrument is already open, it gets the focus
     % otherwise instruments using the hardware are closed.
     % This part is common for all instruments
     if exist(['init' VIn3 '.mat']), 
        initfile=['init' VIn3 '.mat'];
        ppath=which('fdident'); 
        ppath=[ppath(1:length(ppath)-9), 'private\'];
        if exist(['fdidgui\private\init' VIn3 '.mat']) % developpement configuration
          ppath=which('fdtool'); 
          ppath=[ppath(1:length(ppath)-8), 'private\'];
        end
      else initfile=''; disp(['Warning: initialization file init', VIn3 '.mat is missing.']);
     end
     [isopen, isopenmsg] = fdhwsigl('isopen',VIn3);
     if isopen,
        if ~isempty(initfile), eval([VIn3, '(''open'', ''', ppath,''',''', initfile, ''');'],''); end
     else
        if ~isempty(isopenmsg), disp(isopenmsg);  end % display the warning  
        fdhwsigl('close_all_instruments');   %close all instrument windows
        if ~isempty(initfile),
           eval([VIn3, '(''init'',''', ppath,''',''', initfile, ''');']); 
        else
           eval([VIn3, '(''init'');']);   
        end
     end   
     
     % Expands the Callback for Avg/Run/Stop events
     % set number of experiments under avg callback
     % display it on the screen
     fdhwsigl('SetExpno', VIname, ' ', measpars); % set expno
     
     fdhwsigl('isopen',VIname);hvi=gcf;
     
     % Expands the Callback for Quit event
     h = findobj(hvi,'type','uimenu','label','Quit/E&xit');      
     quitfct = get(h,'callback');      lqf=length(quitfct);
     if quitfct(lqf)==';', quitfct=quitfct(1:lqf-1); end;
     quitcallback = ['fdtool(''callback'',''fdmeasw'',''take_data'',''', VIname, ''');', quitfct];
     set(h,'callback',quitcallback);
     
     if strcmpi(VIname,'VNA_test') % executes measurement and closes VNA automatically
        eval('vna(''avgpb'');');
        outdata = fdhwsigl('Take_data','VNA_test');
        eval('ls_vna(''clear'',''STATE_CHG'');','');   
        eval('vna(''quit'');');
        
     elseif strcmpi(VIname,'VNA') | strcmpi(VIname,'VOS') % measurement with VFG!!!
        if strcmpi(VIname,'VNA'), 
           eval('vna(''menu'',''h_dlg2'');') % set external excitation
           eval([VIn3, '(''menu'',''vfgm'');'], 'disp([''Error: opening vfg''])'); % open vfg
        elseif strcmpi(VIname,'VOS'),
           eval([VIn3, '(''vfgm'');'], 'disp([''Error: opening vfg''])'); % open vfg
        else
           fdhwsigl('close_all_instruments');
           outdata=0;msg=['Error: Unexpected branch in fdhwsigl.m'];
           disp(msg);
           return;
        end
        
        % put tag onto AllOn/Off pb whether or not an excitation is defind (necessary for recorder)
        fdhwsigl('isopen','vfg');
        hvfg=gcf;
        fdhwsigl('SetTag', VIname, hvfg, tag_VFG_main); %TAGS
        honoff=findall(hvfg,'Callback','vfg(''onoff_tog'')'); %TAGS
        if isempty(honoff), honoff=findall(hvfg,'String','All Off'); end
        if isempty(honoff), honoff=findall(hvfg,'String','All On'); end
        if isempty(honoff), 
           disp('Error: All On/Off Toggle button cannot be found on VFG.')
        else
           fdhwsigl('SetTag', VIname, honoff, tag_VFG_uic_onoff); %TAGS
        end              
        
        if ~isempty(excsig),%if excitation exists
           % *** LOAD VFG
           % prepare .arb file from excitation signal
           Arb_Clk = 1/excsig.Ts;
           Arb_Data = excsig.Input;
           if strcmpi(measpars.repno,'')|isempty(measpars.repno), repno = 0; 
           else repno=measpars.repno;
           end % end if
           for ii=2:repno, Arb_Data=[Arb_Data;excsig.Input]; end % repeated excitation
           hwopt=fdhwsigl('Properties','SigLab','fe',Arb_Clk,'Ne',length(Arb_Data)); 
           if hwopt.fe~=Arb_Clk 
              fdmeasw('status','Warning: sampling frequency adjusted to hardware');
              Arb_Clk=hwopt.fe;           
           end;
           if hwopt.Ne~=length(Arb_Data)
              outdata=[];
              msg='Error: Cannot generate exc. signal from given number of samples';
              return
           end
           hwopt=fdhwsigl('Properties','SigLab','fe');         
           [minv Arb_Interp_Index] = min(abs(Arb_Clk - hwopt)); % hwopt is now the vector of possible clock frequencies
           if minv, fdmeasw('status','Warning: check sampling frequency on VFG'); end; 
           Arb_Text = 'Excitation signal ';
           key = 'DSPt arb1';
           delete 'vfg_temp.mat';
           save vfg_temp Arb_Clk Arb_Data Arb_Interp_Index Arb_Text key; % prepare excitation file (fdhwsigl.arb)
           vfg('load_arb','.\','vfg_temp.mat');% load excitation file (fdhwsigl.arb)
           % designed_excitation_in_use FLAG (user property of VFG figure)
           % Appendings to control callbacks in order to keep track of changes to the excitation signal
           % As a consequence, when File|Open,Open Arb or Open Arb Vcap is selected
           % or when the mode:arbitrary is changed on channel 1
           % the designed_excitation_in_use flag is turned to 0, otherwise it is nonexistant i.e. empty
           fdhwsigl('isopen','vfg');
           hvfg=gcf;
           setuprop(hvfg,'designed_excitation_in_use',1);
           setuprop(hvfg,'excsig_ts',excsig.Ts);
           setuprop(hvfg,'excsig_freqs',excsig.Frequencies)
           setuprop(hvfg,'excsig_len',length(excsig.Input))
           h_oa=findall(hvfg,'label','Open Arb');
           h_oav=findall(hvfg,'label','Open Arb (Vcap)');
           h_o=findall(hvfg,'label','Open');
           if isempty(h_o)|isempty(h_oa)|isempty(h_oav), % the menu handles are not OK
              disp(['Warning: VFG menu labels have changed compared to version VFG v3.1']);
              disp(['         Trying to disable VFG File menu. Please, do not use it.']);
              h_f=findall(hvfg,'label','&File');
              set(h_f,'Enable','Off');
           elseif ~any(findstr(lower(get(h_o,'Callback')),'setuprop')), % the menu handles are OK & Appending has not been done
              set(h_o,'Callback',['setuprop(', num2str(hvfg),',''designed_excitation_in_use'',0);' get(h_o,'Callback')]);
              set(h_oa,'Callback',['setuprop(', num2str(hvfg),',''designed_excitation_in_use'',0);' get(h_oa,'Callback')]);
              set(h_oav,'Callback',['setuprop(', num2str(hvfg),',''designed_excitation_in_use'',0);' get(h_oav,'Callback')]);
           end
           h_ch=findall(hvfg,'Callback','vfg(''load'');');
           h_mode=findall(hvfg,'Callback','vfg(''mode'')');
           if ~isempty(h_ch) & ~isempty(h_mode) & ~any(findstr(lower(get(h_mode,'Callback')),'setuprop')),
              set(h_mode,'Callback',['if ~(get(', num2str(h_ch,'%.15f'), ',''value'')-1), setuprop(', num2str(hvfg),',''designed_excitation_in_use'',0); end;' get(h_mode,'Callback')]);
           elseif isempty(h_ch) | isempty(h_mode)
              disp(['Warning: Could not find callbacks based on VFG v3.1']);
           end
           % *** Extend Callback of Excitation BW
           probl_with_fp_list='outdata=0;msg=''problem with fp_list.m'';disp(msg);return;';
           eval('s=fp_list(''bw/Fs_list'');',probl_with_fp_list); % get excitation Bw string
           h=findall(0,'String',s); % get excitation BW handle
           if isempty(h), 
              disp(['Warning: Other than arbitrary excitation is selected or vga is not open']),
           elseif ~any(findstr(lower(get(h,'Callback')),'setcontrols')), % extend callback, if it's not already done
              set(h,'Callback',[get(h,'Callback'), 'fdtool(''callback'',''fdhwsigl'',''setcontrols'', ''', VIname, ''')']); 
           end;

           %*** SET Analysis BandWidth/TimeBase, Recordlength
           fdhwsigl('setcontrols',VIname);
           %*** AVG NUM : set number of avarages on VNA or VOS  to 1
           h=findall(0,'Callback','islider(2,''CBedit'')'); % get analysis record length handle 
           if length(h)~=1, 
              disp(['Warning: Cannot identify Stop (Averaging) at Count control unambiguously.']);
           else
              set(h,'string','   1');
              eval('islider(2,''CBedit'');');
           end;
           % end of VNA or VOS (==excitation from VFG)  
        else
           fdmeasw('status','Warning: No excitation signal was designed.');
           %!!!!!!!!!!!!!!!!!!!!!!!!! DIRTY dirty
           
        end % end: if excitation exists
        eval(['ls_', VIn3,'(''clear'',''STATE_CHG'');'],'disp([''Warning: Could not clear instrument <<changed>> flag'']);');   
        outdata=1;msg='';
        return;
        % end of VNA or VOS
        
     elseif strcmpi(VIname,'VNA_internal_excitation')        
        eval(['ls_', VIn3,'(''clear'',''STATE_CHG'');'],'disp([''Warning: Could not clear instrument <<changed>> flag'']);');   
        outdata=1;msg='';
        return;
        
     elseif strcmpi(VIname,'VSS'),
        outdata=1;msg='';
        return;
        
     else
        error(['VIname ''',VIname,''' is invalid'])
     end % end: Instruments under Measurement  
  end % end if: Action is Measurement     
  %Action is 'Measurement' or 'Taked_data' ,etc. branch
  
elseif any(strcmpi(Action,'Setexpno')),
   % 0. if vna_test or vss then return
   % 1. Get the VI handle
   % 2. The data are cleared and counter is reset to if not 'continued measurement' (see there)
   % 4. gets the 'ovld:' control's handle
   % 5. gets the figure handle (ovld's parent, isopen cannot be used, becasue this is the (plot) figure) / VSS!!!!!?????
   % 6. creates the ExpNo:0 of 1 label
   % 7. gets the vi handle
   % 8. set user properties
   
   if strcmpi(VIname,'VNA_test'), 
      %!! disp(['Comment for debugging: With VNA_test ExpNo and tags are not necessary.']); 
      return; 
   end
   if strcmpi(VIname,'VSS'), 
      disp(['ExpNo is not ready for VSS, yet']);
      % This part is still messy: we should e.g. check for existing tags!!!
      h_dwell = findall(0,'String','Dwell');
      if isempty(h_dwell), disp('Pb Dwell not found'); return; end; % error msg !!!!!
      pos_dwell=get(h_dwell,'Position');
      pos_expno = pos_dwell + [0,-25,90,3];
      hvipl=get(h_dwell,'Parent'); % hvipl stands for: handle VI (plot)
      fdhwsigl('SetTag', VIname, hvipl, tag_VI_main); %TAGS
      h_avg = findall(0,'String','Run');
      if isempty(h_avg), return; disp('Pb Run not found'); end; % error msg !!!!!
      fdhwsigl('SetTag', VIname, h_avg, tag_VI_uic_avg); %TAGS
      return;
   end
   
   fdhwsigl('isopen',VIname); hvi=gcf;
   if isempty(getuprop(hvi,'fdhwsigl_expno')) % VI has just been opened
      setuprop(hvi,'fdhwsigl_counter',0);
   elseif measpars.expno < getuprop(hvi,'fdhwsigl_expno'), % VI re-entered after ExpNo has been increased (='continued measurement')
      clruprop(hvi,'fdhwsigl_data');
      clruprop(hvi,'fdhwsigl_data_ready');
      setuprop(hvi,'fdhwsigl_counter',0);
   end
   setuprop(hvi,'fdhwsigl_expno',measpars.expno);
   
   if strcmpi(VIn3,'vss')
      %return; 
      % THE REST OF THIS BRANCH IS GARBAGE
      % find Ovld control and get figure handle
      h_dwell = findall(0,'String','Dwell');
      if isempty(h_dwell), disp('Pb Dwell not found'); return; end; % error msg !!!!!
      pos_dwell=get(h_dwell,'Position');
      pos_expno = pos_dwell + [0,-25,90,3];
      hvipl=get(h_dwell,'Parent'); % hvipl stands for: handle VI (plot)
      fdhwsigl('SetTag', VIname, hvipl, tag_VI_main); %TAGS
      h_avg = findall(0,'String','Run');
      if isempty(h_avg), return; disp('Pb Run not found'); end; % error msg !!!!!
      fdhwsigl('SetTag', VIname, h_avg, tag_VI_uic_avg); %TAGS
      
   elseif strcmpi(VIn3,'vna') | strcmpi(VIn3,'vos')
      % find Ovld control and get figure handle
      h_ovl = findall(0,'String','Ovld:');
      pos_ovl=get(h_ovl,'Position');
      pos_expno = pos_ovl+[0,25,113,3];
      if isempty(h_ovl), return; end; % error msg !!!!!
      hvipl=get(h_ovl,'Parent'); % hvipl stands for: handle VI (plot)
      fdhwsigl('SetTag', VIname, hvipl, tag_VI_main); %TAGS
   else
      disp('Error: Unknown instrument. Expno will not work.'); return;
   end
   
   % destroy Expno control if exists
   h_old=findall(hvipl,'Tag','fdhwsigl_uic_expno');
   if ~isempty(h_old), delete(h_old); end;
   % create Expno control
   h_expno=  uicontrol(hvipl,'Style','text','visible','on',...
      'Position', pos_expno,...
      'string',['ExpNo: ', num2str(getuprop(hvi,'fdhwsigl_counter')) ,' of ', num2str(measpars.expno)],...
      'BackGroundColor', [0.7529    0.7529    0.7529],...   
      'UserData',[0 1],...
      'HorizontalAlignment','left',...
      'FontUnits', 'points',...   
      'FontSize', [10], ...
      'FontWeight', 'bold',...
      'Tag','fdhwsigl_uic_expno');%'BackGroundColor',(80/255)*[1,3,1],...
   % set AVG / Run Callback   
   h_avg = findall(hvipl,'String','Avg'); % hvipl
   set(h_avg,'Enable','On'); % for continued measurement (i.e. expno number is increased in the measurement window: e.g. 6 measurement is ready and expno is set from 6 to 10) after GoToVI
   setuprop(hvi,'fdhwsigl_data_ready',0);  % for continued measurement after GoToVI
   if ~any(getuprop(hvi,'fdhwsigl_avg_callback'))
      h_avg = findall(hvipl,'String','Avg'); % hvipl
      if ~any(h_avg), findall(hvipl,'String','Run'); end %hvipl ( if 'Avg' not found, tries with 'Run')
      if ~any(h_avg), outdata=0; msg='Could not find Avg/Run button'; return; end;
      fdhwsigl('SetTag', VIname, h_avg, tag_VI_uic_avg); %TAGS
      CB_avg = get(h_avg,'Callback');
      if CB_avg(length(CB_avg))~=';', CB_avg=[CB_avg,';']; end
      set(h_avg,'Callback',[CB_avg, 'fdtool(''callback'',''fdhwsigl'',''get_meas'', ''', VIname, ''');']);
      setuprop(hvi,'fdhwsigl_avg_callback',get(h_avg,'Callback'));
   end
   % set STOP Callback
   h_stop = findall(hvipl,'String','Stop'); 
   if ~any(h_stop), outdata=0; msg='Could not find Stop button'; return; end;
   CB_stop = get(h_stop,'Callback');
   if CB_stop(length(CB_stop))~=';', CB_stop=[CB_stop,';']; end
   set(h_stop,'Callback',[CB_stop, 'setuprop(', num2str(hvi), ', ''fdhwsigl_data_ready'', 1);']);
   
   % Clear data pushbutton
   h_clr = uicontrol(hvipl,'Style','Pushbutton',...
      'Position',pos_ovl+[58,-4,58,5],...
      'String','Clear data',...
      'Tag', 'fdhwsigl_uic_clr', ...
      'Enable','on',...
      'Callback',['fdtool(''callback'',''fdhwsigl'',''clear_data'', ''',VIname , ''');'],...
      'Interruptible','on',...
      'FontWeight', 'bold'); %[[62,30],[84,20]],
   
    
elseif strcmpi(Action,'clear_data'), % when Clear Data is pressed
   hvi=fdhwsigl('getfig',VIname);
   clruprop(hvi,'fdhwsigl_data');
   setuprop(hvi,'fdhwsigl_data_ready',0);
   setuprop(hvi,'fdhwsigl_counter',0);
   h_expno = findall(0,'Tag','fdhwsigl_uic_expno');
   set(h_expno,'String',['ExpNo: 0 of ', num2str(getuprop(hvi,'fdhwsigl_expno'))]);
   h_clr=findall(0,'Tag','fdhwsigl_uic_clr');
   set(h_clr,'Enable','Off');
   h_avg=findall(0,'String','Avg');
   set(h_avg,'Enable','On');
   
   % end if Action is 'clear_data'
elseif strcmpi(Action,'pause'),
   % end if Action is 'pause'
   
elseif strcmpi(Action,'setcontrols'),
   %xxxxx SET CONTROLS ON VNA/VOS xxxxx
   %*** GET EXCITATION BANDWIDTH on VFG
   fdhwsigl('isopen','vfg'); hvfg=gcf;
   if ~any(getuprop(hvfg,'designed_excitation_in_use')), return; end; % dirty-> no automatic settings
   probl_with_fp_list='outdata=0;msg=''problem with fp_list.m'';disp(msg);return;';
   eval('s=fp_list(''bw/Fs_list'');',probl_with_fp_list); % get excitation Bw string
   h=findall(hvfg,'String',s); % get excitation BW handle
   if isempty(h), 
      disp(['Warning: Other than arbitrary excitation is selected or vga is not open']),
   else
      excBW_val=get(h,'Value'); % get its setting > Excitation BW is directly picked from the screen
   end;
   %*** ANALYSIS BANDWIDTH/TIMEBASE
   if strcmpi(VIn3,'vna'),
      eval('s=fp_list(''bw_list'');',probl_with_fp_list);% get analysis Bw string
   elseif strcmpi(VIn3,'vos')
      eval('s=fp_list(''per_list'');',probl_with_fp_list);
   else outdata=[];msg='Unknown instrument.';return;
   end;
   h=findall(0,'String',s); % find analysis BandW/TimeB handle
   eval('set(h,''Value'',excBW_val);','disp([''Warning: Analysis BW could not be automatically adjusted.''])'); % adjust the setting of the analysis BW according to the excitation BW
   eval(get(h,'Callback'),'disp([''Warning:''])'); % execute its call back
   %*** ANALYSIS RECORD LENGTH
   %  With VNA (frf measurement) recordlength / analysisBW = exc.rec.len. / excBW must hold
   %  In the case of arbitrary waveforms, the excitBW can be selected to = analBW
   h=findall(0,'Callback','islider(4,''CBedit'')'); % get analysis record length handle 
   if length(h)~=1, 
      disp(['Warning: Cannot identify Analysis Record Length control unambiguously. Settings could not be adjusted automatically.']);
   else
      exclen = getuprop(hvfg,'excsig_len');
      set(h,'string',num2str(exclen)); % set record length
      eval('islider(4,''CBedit'');'); % record length Callback (adjust slider according to record length)
   end;
   outdata=1;msg='';return;
   
else % Actions
   outdata=[]; msg=['Action ''',Action,''' is invalid']; return
end % Actions

% End of file
