function Out = get(dat,Property)
%GET  Access/query fidmodel property values.
%
%   OUT = GET(SYS,'Property')  returns the value of the specified
%   property of the model SYS.
%   
%   STRUCT = GET(fidmodel)  converts the object fidmodel into 
%   a structure STRUCT with the property names as subfield names and
%   the property values as subfield values.
%   Without left-hand argument,  GET(fidmodel)  displays all properties 
%   of fidmodel and their values.
%
%   See also  SET.
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 20-Jun-2001
ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,2,ni)), %earlier
end
if ni>=2, Propertyfull=idpvpstr(dat,Property); else Propertyfull=''; end
if strcmpi(Propertyfull,'Fscale')
  if any(strmatch('z',get(dat,'variable'))), Out=[]; return
  else Propertyfull='Fs';
  end
elseif strcmpi(Propertyfull,'fs')
  if ~any(strmatch('z',get(dat,'variable'))), Out=[]; return, end
end
dats=struct(dat);
if (length(dat)>1) %array of fidmodels
  if ~strcmpi(Propertyfull,'Information')
    if ni>1
      Outc=cell(size(dats));
      dats=struct(dat);
      for ii=1:prod(size(dats))
        Outc{ii}=get(fidmodel(dats(ii),'noconsistency'),Propertyfull);
      end
      if ~strcmpi(Propertyfull,'Consistency')
        %Out=reshape(Outc,size(dats,1),size(dats,2),size(dats,3));
        Out=Outc;
      else
        Out=1;
        for ii=1:prod(size(dats))
          Out=Out*Outc{ii};
        end %for ii
      end
      return
    else %ni==1 (list of props)
      Out='';
      Props=idpvpget(dat);
      if ~strncmp(get(dat,'variable'),'z',1)
        ind=strmatch('InterSample',Props); end, if ~isempty(ind), Props(ind)=[]; end
      chn=1;
      for ii=prod(size(dats))
        num=dats(ii).num; if iscell(num)&(length(num)>1), chn=2; end
        denom=dats(ii).denom; if iscell(denom)&(length(denom)>1), chn=2; end
      end
      if chn==1
        ind=strmatch('inputchnumber',Props,'exact'); Props(ind)='';
        ind=strmatch('outputchnumber',Props,'exact'); Props(ind)='';
      end
      for ii=1:length(Props)
        val=get(dat,Props{ii});
        needed=0;
        for iii=1:length(val)
          if ~isempty(val{iii}), needed=1; end
        end
        if needed
          Out=setfield(Out,Props{ii},val);
        end
      end
      if isempty(Out)
        warning('Cannot return properties of fidmodel array')
      end
      return
    end %if ni>1
  end %if ~strcmpi(Propertyfull,'Information')
end %if (length(dat)>1)
if ni>=2 %get(dat,Property...)
  %[Pno,Propertyfull]=idpvpstr(dat,Property);
  if isempty(Propertyfull), error(['Invalid property ''',Property,'''']), end
  Property=Propertyfull;
  if findstr(['|',Property,'|'],['|Consistency|Information|Coefficients|tauR|InterSample|ErrorWeighting|'])
    %Properties with special handling
    if strcmpi(Property,'Coefficients')
      if isfield(dat.newproperties,'Coefficients')
        Out=dat.newproperties.Coefficients;
      else
        Out=[];
      end
    elseif strcmpi(Property,'tauR')
      if isfield(dat.newproperties,'tauR')
        Out=dat.newproperties.tauR;
      else
        Out=[];
      end
    elseif strcmpi(Property,'InterSample')
      if any(findstr(get(dat,'Variable'),'z'))
        if isfield(dat.newproperties,'InterSample')
          Out=dat.newproperties.InterSample;
        else
          Out='';
        end
      else
        error('Intersample is only defined for z-domain')
      end
    elseif strcmpi(Property,'ErrorWeighting')
      fiti=get(dat,'Fitinfo');
      if isfield(fiti,'errorweighting')
        Out=fiti.errorweighting;
      else
        Out='';
      end
    elseif strcmpi(Property,'Information')
      info='';
      if length(dat)>1
        info=sprintf('%.0f x %.0f ',size(dat,3),size(dat,4));
        for ii=3:ndims(dat)
          info=[info,sprintf('x %.0f ',size(dat,ii+2))];
        end
      end
      info=[info,dat.variable,'-domain '];
      info=[info,'fidmodel object'];
      if length(dat)==1
        mtype=get(dat,'type');
        if strcmp(mtype,'CD')|strcmp(mtype,'TFS'), info=[info,', type: ',mtype]; end
        if isempty(mtype)|strcmp(mtype,'SISO')|strcmp(mtype,'CD')
          num=dat.num;
          if isempty(dat.num), numstr='[]';
          elseif isnumeric(num), numstr=num2str(length(num)-1);
          elseif prod(size(num))<=6
            numstr='{';
            for ih=1:size(num,2)
              for iv=1:size(num,1)
                if ih>1, numstr=[numstr,' ']; 
                elseif iv>1, numstr=[numstr,' ; '];
                end
                numstr=[numstr,num2str(length(num{iv,ih})-1)];  
              end
            end
            numstr=[numstr,'}'];
          else
            numstr=sprintf('{%.0f x %.0f}',size(num,1),size(num,2));
          end
          if isempty(dat.denom), denomstr='[]';
          else denomstr=num2str(length(dat.denom)-1);
          end
          info=[info,', ',numstr,'/',denomstr];
        else %TFS
          info=[info,' display not yet ready for type TFS'];
        end
        if strcmp(dat.variable,'r')
          info=[info,sprintf(', tauR=%.3g s',get(dat,'tauR'))];
        end
        if ~isempty(dat.fitinfo)
          fiti=dat.fitinfo;
          if isstruct(fiti), cf=fiti.cf; else cf=fiti(1); end
          info=[info,sprintf(', cost: %.4g',cf)];
        end
        del=get(dat,'delay'); if isempty(del), del=0; end
        if ~isequal(del,0)
          if any(findstr(dat.variable,'z')), delunit='samples';
          else delunit= 's';
          end
          info=[info,sprintf(', delay: %.0g %s',del,delunit)];
        end
        den=get(dat,'den');
        if ~isnumeric(den), 
        elseif any(isnan(den)), info=[info,', undetermined coeffs'];
        elseif ~isstable(dat), info=[info,', unstable'];
        end
        if ( exist('@tf/display.m')&(length(dat)==1) )|...
            ( ~strcmp(dat(1).variable,'w')&...
            ~strcmp(dat(1).representation,'orthopol') )
          if exist('@tf/tf')&(nargout==0)&...
              (strcmp(dat.variable,'s')|any(dat.variable=='z'))
            display(tf(dat))
          end
        end
      else
        for ii=1:length(dat)
          infoii=sprintf('   %.0f/%.0f',...
            length(dat(ii).num)-1,length(dat(ii).denom)-1);
          fiti=dat(ii).fitinfo;
          if ~isempty(fiti)
            if isstruct(fiti), cf=fiti.cf; else cf=fiti(1); end
            infoii=[infoii,sprintf(', cost: %.4g',cf)];
          end
          del=get(dat(ii),'delay');
          if ~isequal(del,0), infoii=[infoii,sprintf(', delay: %.0g',del)]; end
          if ~isstable(dat(ii)), infoii=[infoii,', unstable']; end
          %
          info=str2mat(info,infoii);
        end
      end
      if no>0, Out=info; else disp(info); end      
    elseif strcmpi(Property,'Consistency')
      if ~isstr(dat.name)
        warning('name is not a string')
        if ~isempty(dat.name)
          Out=0; return
        end
      elseif size(dat.name,1)>1
        Out=0; warning('name is not an 1xN string'), return        
      end
      if ~isnumeric(dat.version)
        Out=0; warning('version is invalid'), return
      end
      if isempty(dat.version)
        error('version is empty')
      elseif dat.version~=2.2
        if dat.version<2.2
          Out=0; warning(sprintf('Old version: %.1f',dat.version)), return
        else
          Out=0; warning(sprintf('Too new version: %.1f',dat.version)), return
        end
      end
      if ~isstr(dat.date)
        Out=0; warning('date is not a string'), return
      end
      if ~isstr(dat.notes)
        warning('notes is not a string')
        if ~isempty(dat.notes)
          Out=0; return
        end
      end
      if ~isstr(dat.history)&~iscell(dat.history)
        warning('history is not a string or cell array')
        if ~isempty(dat.history)
          Out=0; return
        end
      end
      if ~isempty(dat.data)
        if ~isa(dat.data,'fiddata')
          Out=0; warning('data is not fiddata')
          return
        end
        Out=get(dat.data,'consistency');
        if Out==0, warning('Inconsistent fiddata: see the warning message above for the reason')
          return
        end
      end
      coeffs=get(dat,'Coefficients');
      num=dat.num;
      if ~strncmp(coeffs,'c',1)
        if iscell(num)
          for ii=1:prod(size(num))
            if ~isreal(num{ii})
              Out=0; warning('Numerator is complex')
              return
            end
          end
        elseif ~isreal(num)
          Out=0; warning('Numerator is complex')
          return
        end
      end
      if any(findstr(dat.variable,'z'))
        is=get(dat,'InterSample');
        if any(strmatch(is,...
            {'ZOH','band-limited','discrete'}))
        else 
          Out=0; warning('Value of property ''InterSample'' is not allowed')  
          return
        end 
      end
      if ~isnumeric(num)&~iscell(num), Out=0; warning('num is not numeric or cell'), return, end
      if isnumeric(num), num={num}; end
      for ii=1:prod(size(num))
        if isempty(num{ii}), %Out=0; warning('num is empty'), return
        elseif size(num{ii},1)~=1, Out=0; warning('size(num,1)~=1'), return
        end
        if any(~isfinite(num{ii})&~isnan(num{ii}))
          Out=0; warning('Nonfinite element in num'), return
        end
      end
      %
      denom=dat.denom;
      if ~strncmp(coeffs,'c',1)
        if iscell(denom)
          for ii=1:prod(size(denom))
            if ~isreal(denom{ii})
              Out=0; warning('Denominator is complex')
              return
            end
          end
        elseif ~isreal(denom)
          Out=0; warning('Denominator is complex')
          return
        end
      end
      if ~isnumeric(denom)&~iscell(denom), Out=0; warning('denom is not numeric or cell'), return, end
      if isnumeric(denom), denom={denom}; end
      for ii=1:prod(size(denom))
        if isempty(denom{ii}), %Out=0; warning('denom is empty'), return
        elseif size(denom{ii},1)~=1, Out=0; warning('size(denom,1)~=1'), return
        end
        if any(~isfinite(denom{ii})&~isnan(denom{ii}))
          Out=0; warning('Nonfinite element in denom'), return
        end
      end
      %
      if (prod(size(denom))>1)&(prod(size(denom))~=prod(size(num)))
        Out=0; warning('num-denom mismatch'), return
      end
      %C|D|F
      ntr=dat.ntr;
      if ~isempty(ntr)
        if ~isnumeric(ntr), Out=0; warning('ntr is not numeric'), return, end
        if ~strncmp(coeffs,'c',1)&~isreal(ntr)
        Out=0; warning('Transient numerator is complex')
        return
      end
        if size(ntr,1)~=1, Out=0; warning('size(ntr,1)~=1'), return, end
        if any(~isfinite(ntr)&~isnan(ntr)), Out=0; warning('Nonfinite element in ntr'), return, end
      end
      %
      for ii=1:3
        if ii==1, Z=dat.Znum; p=dat.num;
        elseif ii==2, Z=dat.Zdenom; p=dat.denom;
        elseif ii==3, Z=dat.Zntr; p=dat.ntr;
        end
        if ~isempty(Z)&isempty(p), 
          Out=0; warning('empty polynomial, nonempty orthogonal basis')
          return
        end
        if strcmp(dat.representation,'polynomial')
          if ~isempty(Z)
            Out=0; warning('representation polynomial, but orthogonal basis is given')
            return
          end
        elseif strcmp(dat.representation,'orthopol')
          if ~isempty(p)
            if length(Z)~=length(p)
              Out=0;
              warning(sprintf('Orthogonal basis inconsistent with polynomial: ii=%.0f',ii))
              return
            end
            if any(~isfinite(Z(:)))
              Out=0;
              warning(sprintf('Nonfinite element in orthogonal basis: ii=%.0f',ii))
              return
            end              
          end
        else
          Out=0; warning(['Illegal representation: ''',dat.representation,''''])
          return
        end
      end %for ii
      %|fixedpar|varet|
      fiti=dat.fitinfo;
      if ~isempty(fiti)
        if isstruct(fiti)
          %structure
        elseif (length(fiti)<15)|(size(fiti,2)~=1)|~isnumeric(fiti)
          Out=0; warning('Invalid fitinfo')
          return
        else
          warning('Obsolete form of fitinfo')
        end
      end
      %
      var=dat.variable;
      if ~any(findstr(['|',var,'|'],'|z^-1|s|r|w|'))
        Out=0; warning(['Illegal variable ''',var,'''']), return
      end
      if strcmp(var,'r')
        tauR=get(dat,'tauR');
        if ~isnumeric(tauR)|(length(tauR)~=1)|(tauR<=0)
          Out=0; warning('tauR value is illegal'), return
        end
      end
      %|freqvect|fs|delay|
      %outputdelay|inputdelay|outputgroup|inputgroup|outputname|inputname|',...
      %outputunit|inputunit|
      cov=dat.covariance;
      if ~isempty(cov)
        num=dat.num; lnum=0;
        if iscell(num), for ii=1:length(num(:)), lnum=lnum+length(num{ii}); end
        else lnum=length(num); 
        end
        denom=dat.denom; ldenom=0;
        if iscell(denom), for ii=1:length(denom(:)), ldenom=ldenom+length(denom{ii}); end
        else ldenom=length(denom); 
        end
        ntr=dat.ntr; lntr=0;
        if iscell(ntr), for ii=1:length(ntr(:)), lntr=lntr+length(ntr{ii}); end
        else lntr=length(ntr); 
        end
        pl=lnum+ldenom+lntr+1;
        if ~all(size(cov)==pl)
          Out=0; warning('Wrong size of covariance'), return
        end
      end
      %
      %disp('Checking consistency of fidmodel ... (not yet complete)')
      Out=1; return
    end %consistency
  elseif ~isempty(dat)&strcmp(dat.representation,'orthopol')&strcmpi(Property,'delay')
    if strcmp(dat.variable,'s')
      Out=dat.delay/get(dat,'fscale');
    else
      Out=dat.delay/get(dat,'fs');
    end
  else %this is a regular case: return value of property
    dats=struct(dat);
    if isfield(dats,lower(Property)), if ~isempty(dats), Out=getfield(dats,lower(Property)); else Out=[]; end
    elseif isfield(dats,Property), Out=getfield(dats,Property);
    elseif strcmp(Property,'A'), Out=dats.denom;
    elseif strcmp(Property,'B'), Out=dats.num;
    elseif strcmpi(Property,'InputChNumber')|strcmpi(Property,'OutputChNumber')
      num=dats(1).num;
      %if isnumeric(num), num={num}; end
      if strcmpi(Property,'InputChNumber'), Out=size(num,2);
      elseif strcmpi(Property,'OutputChNumber'), Out=size(num,1);
      end
    elseif strcmpi(Property,'Type')
      if issiso(dat)
        Out='SISO';
        %Out='';
      else %MIMO type
        num=dats(1).num; if isnumeric(num), num={num}; end
        denom=dats(1).denom; if isnumeric(denom), denom={denom}; end
        Nnum=prod(size(num)); Ndenom=prod(size(denom));
        MD=0;
        for ii=1:prod(size(num))
          numii=num{ii};
          if (size(numii,1)>1)|(size(numii,3)>1), MD=1; end
        end
        for ii=1:prod(size(denom))
          denomii=denom{ii};
          if (size(denomii,1)>1)|(size(denomii,3)>1), MD=1; end
        end
        if MD==1, Out='LMFD';
        elseif (Nnum>1)&(Ndenom==1), Out='CD';
        elseif Nnum==Ndenom, Out='TFS';
        else error('type unknown')
        end
      end
    else
      Out=[];  
    end
    %
  end
  if strcmp(Property,'denom')&iscell(Out)&(length(Out)==1), Out=Out{1}; end
  return
end %ni>1
Props = idpvpget(dat);
variable=get(dat,'variable');
if ~any(findstr(variable,'z'))
  ind=strmatch('Fscale',Props,'exact'); Props(ind)='';
  ind=strmatch('InterSample',Props,'exact'); Props(ind)='';
  ind=strmatch('Fs',Props,'exact'); Props{ind}='Fscale'; 
else %z
  ind=strmatch('Fscale',Props,'exact'); Props(ind)='';
end
chn=1;
for ii=1:prod(size(dats))
  num=dats(ii).num; if iscell(num)&(length(num)>1), chn=2; end
  denom=dats(ii).denom; if iscell(denom)&(length(denom)>1), chn=2; end
end
if chn==1
  ind=strmatch('InputChNumber',Props,'exact'); Props(ind)='';
  ind=strmatch('OutputChNumber',Props,'exact'); Props(ind)='';
end
ind=strmatch('ioDelayMatrix',Props,'exact'); Props(ind)='';
ind=strmatch('ErrorWeighting',Props,'exact'); if ~isempty(ind), Props(ind)=''; end
%Props = [Props;{'Information'}];
PValues=Props;
for ii=length(Props):-1:1
  PValues{ii}=get(dat,Props{ii});
  if isempty(PValues{ii})|(strcmp(Props{ii},'Type')&strcmp(PValues{ii},'SISO'))
    %Do not show empty information
    PValues(ii)=[]; Props(ii)=[];
  end
end
% Handle various cases
if ni==2,
  %  Out = PValues(ind);
  %  Out=cell2struct(Out,'tmp');
  %  Out=Out.tmp;
  error('ni=2')
else %ni~=2
   if no,
     Out = cell2struct(PValues,Props,1);
   else
     shprops(Props,PValues,' = ',fidmodel);
   end
   if get(dat,'consistency')==0
     error('Inconsistent object')
   end
end
%End @fidmodel/get.m