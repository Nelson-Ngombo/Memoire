function Out = set(dat,varargin)
%SET  Set properties of IDDAT (and TIDDATA and FIDDATA) objects.
%
%   SET(DAT,'Property',VALUE)  sets the property of DAT specified
%   by the string 'Property' to the value VALUE.
%
%   SET(DAT,'Property1',Value1,'Property2',Value2,...)  sets multiple 
%   property values with a single statement.
%
%   SET(DAT,'Property')  displays possible values for the specified
%   property of DAT.
%
%   SET(DAT,'ch:<number>',...) sets the properties of channel #<number>
%   only. In this case, all the properties must be either all input or
%   all output properties, like e.g. 'Input', 'Inputname' and 'Inputunit'.
%   SET(DAT,'ch:<name>',...) refers to the channel with name <name>.
%   SET(DAT,'ch:<number>','Inputname','') adds a new channel with NaN data
%   to the existing ones, if <number> is larger by just 1 than # of channels.
%
%   SET(DAT)  displays all properties of DAT and their admissible 
%   values.
%
%   See also  GET.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Aug-2003

ni = nargin;
no = nargout;
%
if (ni>=3)&~isa(dat,'iddat')&isstr(varargin{1})
  %call was initiated for built-in set: set(fighandle,string,value...)
  %Initiate built-in set
  setstr=['builtin(''set'',dat'];
  for ii=1:length(varargin)
    setstr=[setstr,',varargin{',num2str(ii),'}'];
  end
  setstr=[setstr,');'];
  if no==1, setstr=['Out=',setstr]; end
  %disp(setstr)
  eval(setstr)
  return
end

if ~isa(dat,'iddat'),
   error('The first argument of SET must be an IDDAT or TIDDATA or FIDDATA object.');
elseif no & ni>1,
   error('Output argument allowed only in Out=SET(DAT)');
end

% Get properties and their admissible values
[props,valuesc] = idpropch(dat,'','set');
ind=find(props=='|'); propsc=cell(length(ind)-1,1);
pl=dat.PeriodLength;
%
for ii=length(ind)-1:-1:1
  %Eliminate periodic properties if irrelevant
  if findstr(['|',props(ind(ii)+1:ind(ii+1)-1),'|'],...
      ['|InputFrequencies|OutputFrequencies|Frequencies|State|Synchronization|',...
        'ReferenceData|Groups_Synchronized|Groups_Delayed|Groups_SamePower|Groups_FullMIMO|'])&...
      (isempty(pl)|(~isfinite(pl)&~isnan(pl)))&isa(dat,'tiddata')
    propsc{ii}=props(ind(ii)+1:ind(ii+1)-1);
    %The next is the line which hides periodic properties in set
    %propsc(ii)=[]; valuesc(ii)=[];
  elseif findstr(['|',props(ind(ii)+1:ind(ii+1)-1),'|'],...
      '|InputScale|OutputScale|ChTypes|Characters|Data|Names|Delays|iddat|')
    propsc(ii)=[]; valuesc(ii)=[];    
  else
    propsc{ii}=props(ind(ii)+1:ind(ii+1)-1);
  end 
end %for ii

if ni==1,
  if no,
    Out = cell2struct(valuesc,propsc,1);
  else
    shprops(propsc,valuesc,':  ',dat)
  end
  return
elseif ni==2,
  str = varargin{1};
  if ~isstr(str),
    error('Property names must be single-line strings');
  else
    if strncmp(str,'ch:',3)
      error('Properties of selected channel are missing')
    end
  end

   % Return admissible property value(s)
   [Property,value] = idpropch(dat,str,'set');
   if no, Out = value;
   else disp(value)
   end
   return
elseif no,
  error('No output argument when called with PV pairs.')
end
%
%Now ni>=3: we have to set values of properties
chm=0; chi=0;
chp=varargin{1};
chtypes=dat.ChTypes; cno=length(chtypes);
%
if strncmp(chp,'ch:',3) %only one channel or two channels are selected
  if ni==2, error('Properties of selected channel are missing'), end
  %Preparation: set chi and chm
  chm=1;
  %
  %Check possibility of name with digits only
  names=dat.Names;
  chi=getchi(dat,chp,cno,names);
end
%Now chi contains the number(s) of the selected channel(s), chm is 0 or 1
%
if (chm==1)&(ni==3) %return property possibilities for selected channel
  datchi=dat{chi}; chtypes=get(dat,'chtypes');
  if ( (chtypes(chi)==('i'+0))&any(findstr(lower(varargin{2}),'output')) )| ...
      ( (chtypes(chi)==('o'+0))&any(findstr(lower(varargin{2}),'input')) )

    error(['Property ',varargin{2},' does not match channel type'])  
  end
  if no, Out=set(datchi,varargin{2});
  else set(datchi,varargin{2})
  end
  return
elseif rem(ni-1-chm,2)~=0,
  if ~strcmp(varargin{ni-1},'noconsistency')
    if isstr(varargin{ni-1}), disp(['Last property: ',varargin{ni-1}]), end
    error('Property/Value pairs must come in even number.')
  end  
end

% Now we have set(dat,P1,V1, ...)
name = inputname(1);
if isempty(name),
   error('First argument to set must be a named variable.')
end

dats=struct(dat);
importance=0; %change in object is important enough to change date
for i=[1+chm:2:ni-1]
  % Set each PV pair in turn
  if strcmp(varargin{i},'noconsistency')
    Property=varargin{i}; break
  end %Jump to end
  [Property,Valueposs]=idpropch(dat,varargin{i},'set');
  if (length(chi)==1)&(chi(1)>0)&...
      ~strncmp(Property,'Input',5)&~strncmp(Property,'Output',6)
    error('For individual channel setting only i/o properties may be used')
  end
  Value = varargin{i+1};
  if (length(Property)>5)&any(findstr(Property,'putCharacter'))
    if ~iscell(Value), Value={Value}; end
    for iv=1:length(Value)
      if ~any(findstr(lower(Valueposs),lower(Value{iv})))&~strcmp(Value{iv},'AASamples')
        error(['Property value ''',Value{iv},''' not allowed for ''',Property,'''.'])
      elseif strcmp(Value{iv},'AASamples')
        warning(['Property ',Property,' is given as AASamples. This is obsolete: use BL instead.'])
      end
    end
  end
  if ~strcmp(class(dat),'iddat')&isfield(dats,Property)
    %child property which is field
    setloc(dat,Property,Value,chi)   
  elseif ~strcmp(class(dat),'iddat')&isfield(dats,Property)
    %child property which is field
    setloc(dat,Property,Value,chi)   
  elseif ~strcmp(class(dat),'iddat')&...
      isfield(struct(dats.iddat),Property) %iddat property which is field
    if strcmpi(Property,'Frequencies')
      if isnumeric(Value)&(size(Value,1)==1)&(size(Value,2)>1)
        Value=Value(:);
      end
    end
    if ~strcmp(Property,'Synchronization')
      eval(['dat.',Property,'=Value;'])
    else
      %For synchronization, set the objs rather
      if (get(dat,'expnumber')<=1)&~isempty(Value)&~strcmp(Value','off')
        error(sprintf(['Setting ''Synchronization'' to ''',Value,''' makes no sense for %.0f experiment'],get(dat,'expnumber')))
      end
      if ~isempty(get(dat,'synchronization'))
        set(dat,'Groups_Synchronized',{},'Groups_Delayed',{},'Groups_SamePower',{},...
          'Groups_FullMIMO',{})
        dat.Synchronization='';
      end
      if strcmp(Value,'on')
        set(dat,'Groups_Synchronized',[1:get(dat,'expnumber')])
      elseif strncmpi(Value,'delayed',3)
        set(dat,'Groups_Delayed',[1:get(dat,'expnumber')])
      elseif strncmp(Value,'samepower',5)|strncmp(Value,'power',3)
        set(dat,'Groups_SamePower',[1:get(dat,'expnumber')])
      elseif strncmpi(Value,'mimo',4)|strncmpi(Value,'fullmimo',5)
        set(dat,'Groups_FullMIMO',[1:get(dat,'expnumber')])
      elseif isempty(Value)|strcmpi(Value,'off')
        dat.Synchronization='';
      else
        error(['Bad value for Synchronization: ''',Value,''''])
      end
    end
  elseif any(strmatch(Property,...
      {'ExperimentName','ReferenceData',...
        'Groups_Synchronized','Groups_Delayed','Groups_SamePower','Groups_FullMIMO','Groups'},...
      'exact'))
    %if iscell(Value)&(size(Value,1)>1)&(size(Value,2)==1), Value=Value'; end
    if any(strmatch(Property,...
        {'Groups_Synchronized','Groups_Delayed','Groups_SamePower','Groups_FullMIMO','Groups'},'exact'))
      dat.Synchronization='';
      if strcmp(Property,'Groups')
        if isempty(Value)
          set(dat,'Groups_Synchronized',{},'Groups_Delayed',{},'Groups_SamePower',{},...
            'Groups_FullMIMO',{})
        elseif isequal(fieldnames(Value),{'Groups_Synchronized';...
              'Groups_Delayed';...
              'Groups_FullMIMO';...
              'Groups_SamePower'})
          set(dat,'Groups_Synchronized',Value.Groups_Synchronized,...
            'Groups_Delayed',Value.Groups_Delayed,...
            'Groups_SamePower',Value.Groups_SamePower,...
            'Groups_FullMIMO',Value.Groups_FullMIMO,'noconsistency')
        else error('Property ''Groups'' can only be set to an earlier got or an empty value')
        end
      end
      if ~isempty(Value)
        if ~iscell(Value), Value={Value}; 
        else
          for ii=1:prod(size(Value))
            if iscell(Value{ii})&(length(Value{ii})==1), Value{ii}=Value{ii}{1}; end
          end %for ii
        end
        if size(Value,2)==1
          Value=[Value,cell(size(Value,1),1)];
          for ii=1:size(Value,1), Value{ii,2}=''; end
        elseif size(Value,2)==2
          for in=1:size(Value,1)
            if ~isempty(Value{in,2})&~ischar(Value{in,2})
              error(sprintf([Property,'{%.0f,2} is not a string'],in))
            end
          end %for in
        elseif size(Value,2)>2
          error(sprintf('Group value is a %.0fx%.0f cell, while 0<=width<=2 is required',size(Value,1),size(Value,2))) 
        end
        if ~strcmp(Property,'Groups')
          for ii=1:size(Value,1)
            grp=Value{ii,1}; if ~iscell(grp), grp={grp}; end
            if strcmp(Property,'Groups_Synchronized')|strcmp(Property,'Groups_Delayed')
              vn=lower(Property(8));
            else
              vn=lower(Property(12));
            end
            for iii=1:length(grp)
              if any(strmatch([vn,'('],grp{iii}))
                error(['Recursive group definition in group ''',Property,''''])
              end
            end
          end %for ii
        end
      end %~isempty(Value)
    end %group(s)
    if ~strcmp(Property,'Groups')
      if strcmp(class(dat),'fiddata')|strcmp(class(dat),'tiddata')
        data_iddat=get(dat,'iddat');
        data_iddat.NewProperties=setfield(data_iddat.NewProperties,Property,Value);
        if strncmp(Property,'Groups_',7)
          groupsold=get(dat,Property);
        end
        set(dat,'iddat',data_iddat,'noconsistency');
        if strncmp(Property,'Groups_',7)
          groups=get(dat,Property);
          remname={}; remname2={};
          for ii=1:size(groupsold,1)
            gname=groupsold{ii,2};
            if ~isempty(gname)&~isempty(groups)
              ind=strmatch(gname,groups(:,2),'exact');
              if isempty(ind), remname=[remname;{gname}]; remname2=[remname2;{''}]; end
            end
          end %for ii
          if strcmp(Property,'Groups_Synchronized')|strcmp(Property,'Groups_Delayed')
            vn=lower(Property(8));
          else
            vn=lower(Property(12));
          end
          for ii=size(groups,1)+1:size(groupsold,1)
            dname=[vn,'(',num2str(ii),')'];
            remname=[remname;{''}]; remname2=[remname2;{dname}];
          end %for ii
          stck=dbstack;
          if ~any(findstr('fixgroups.m',stck(2).name))
            if isempty(remname), fixgroups(dat),
            else fixgroups(dat,[remname,remname2]) %remove deleted groups
            end
          end
        end
      else %iddat
        dat.NewProperties=setfield(dat.NewProperties,Property,Value);
      end
    end
  elseif ~strcmp(class(dat),'iddat')&...
      any(findstr(idpropch(dat,'','childset'),['|',Property,'|']))
    %child property which is not a field
    setloc(dat,Property,Value,chi) %set non-field child property
  elseif any(findstr(Property,'Input'))|any(findstr(Property,'Output'))
    %iddat property begins with Input or Output
    chtypes=dat.ChTypes; %'i'+0=105 (input), 'o'+0=115 (output)
    if isempty(chtypes), indi=[]; indo=[];
    else indi=find(chtypes==('i'+0)); indo=find(chtypes==('o'+0));
    end
    %
    if strncmp('Input',Property,5), ind=indi; io='i'+0;
    else ind=indo; io='o'+0;
    end
    if chi>0 %one individual channel
      ind=chi;
      if chi<=size(chtypes,1), repl=1; else repl=0; end
      if size(chtypes,1)>=chi
        if chtypes(chi)~=io
          error('Property name does not match channel type')
        end
      end
    end %individual channel
    if strncmp('Input',Property,5)|strncmp('Output',Property,6)
      %any I/O property
      if (chi>0)&(repl==0)&...
          ~strcmp('Input',Property)&~strcmp('Output',Property)
        %new channel, not I/O data
        %Extend data in each experiment to maximum
        if strncmp('Input',Property,5), iop='Input';
        else iop='Output';
        end
        Data=dat.Data;
        if ~iscell(Data), Data={Data}; end
        [ic,expno]=size(Data);
        chtype=dat.ChTypes;
        dnewall=cell(1,expno);
        set(dat,['ch:',num2str(chi)],iop,dnewall)
      end
      if strcmp('Input',Property)|strcmp('Output',Property)
        Data=dat.Data;
        if ~iscell(Data)&~isempty(Data), Data={Data}; end
        if ~iscell(Value)&~isempty(Value), Value={Value}; end
        %for ii=1:prod(size(Value))
        %  if (chi>0)&isempty(Value(:){ii})
        %    Value{ii}(:)=NaN; %replace empty vectors by NaN's
        %  end
        %end %for ii
        if ((chi==0)|((chi>0)&(repl==1)))&~isempty(Value)&~isempty(Value{1})&...
            (length(ind)==size(Value,1))%&(size(Data,2)==size(Value,2))
          %replacement
          idd=get(dat,'iddat'); sc=idd.Scales;
          for iic=1:length(ind)
            for ii=1:max(size(Data,2),size(Value,2)) %all experiments
              %delete what is not needed
              if ii>size(Value,2)
                Data(:,ii:end)=[]; break 
              else
                if isempty(sc), sci=1; else sci=sc{ind}; end
                Data{ind(iic),ii}=Value{iic,ii}/sci; 
              end
            end
          end %for ii
        else %not replacement; maybe adding channels
          if isa(dat,'fiddata')
            covar=get(dat,'CovarianceMatrix');
            coh=get(dat,'Coherence');
          end
          for ii=1:size(Data,2)
            if chi==0 %maybe several channels
              %eliminate old inputs:
              if (ii==1)&~isempty(ind)
                Data(ind,:)=[];
                if ~isempty(covar), covar(ind,:,:)=[]; covar(:,ind,:)=[]; end  
                if ~isempty(coh), coh(ind,:,:)=[]; coh(:,ind,:)=[]; end  
              end
              for iii=1:size(Data,1)
                %eliminate problems with 0 x s matrices
                if isempty(Data{iii,ii}), Data{iii,ii}=[]; end
              end
            end
          end %for ii
          if isempty(Data), Data=Value; %Bypass Matlab 5.2 error
          elseif isempty(Value) %nothing to do
          else
            if size(Data,2)<size(Value,2)
              Data=[Data,cell(size(Data,1),size(Value,2)-size(Data,2))];
            elseif size(Data,2)>size(Value,2)
              Data(:,size(Value,2)+1:end)=[];
            end
            Data=[Data;Value];
            if isa(dat,'fiddata')
              if ~isempty(covar)
                covar=[covar,NaN*ones(size(covar,1),size(Value,1),size(covar,3))];
                covar=[covar;NaN*ones(size(Value,1),size(covar,2),size(covar,3))];
              end
              if ~isempty(coh)
                coh=[coh,NaN*ones(size(coh,1),size(Value,1),size(coh,3))];
                coh=[coh;NaN*ones(size(Value,1),size(coh,2),size(coh,3))];
              end
            end
          end
          %
          ns=dat.Names;
          ch=dat.Characters;
          un=dat.Units;
          sc=dat.Scales;
          fr=dat.Frequencies;
          %
          if isempty(ns), ns={}; elseif ~iscell(ns), ns={ns}; end          
          if isempty(ch), ch={}; elseif ~iscell(ch), ch={ch}; end          
          if isempty(un), un={}; elseif ~iscell(un), un={un}; end          
          if isempty(sc), sc={}; elseif ~iscell(sc), sc={sc}; end          
          if isempty(fr), fr={};
          elseif ~iscell(fr)
            fr={fr};
            for ii=2:length(chtypes), fr=[fr;fr(1)]; end
          end          
          %
          if ~isempty(ind)&(chi==0) %channels were deleted
            chtypes(ind)=[];
            if ~isempty(ns), ns(ind)=''; end
            if ~isempty(ch), ch(ind)=''; end
            if ~isempty(un), un(ind)=''; end
            if ~isempty(sc), sc(ind)=''; end
            if ~isempty(fr), fr(ind)=''; end
          end
          for ii=1:size(Value,1) %add new cells for each property
            chtypes=[chtypes;io];
            if ~isempty(ns), ns=[ns;{''}]; end 
            if ~isempty(ch)
              chstr='';
              %if strcmp(class(dat),'tiddata')
                chstri=''; chstro='';
                for iii=1:length(ch)
                  if chtypes(iii)==('i'+0)
                    if strcmp(ch{iii},'ZOH')|strcmp(ch{iii},'ZOHf')
                      chstri=ch{iii};
                    elseif isempty(chstri)&...
                        (strcmp(ch{iii},'AASamples')|strcmp(ch{iii},'BL'))
                      chstri='BL';
                    end
                  elseif chtypes(iii)==('o'+0)
                    if strcmp(ch{iii},'Samples')
                      chstro=ch{iii};
                    elseif isempty(chstro)&...
                        (strcmp(ch{iii},'AASamples')|strcmp(ch{iii},'BL'))
                      chstro='BL';
                    end
                  end
                end %for iii
                if isempty(chstri)
                  if strcmp(chstro,'BL')|strcmp(chstro,'AASamples'), chstri='BL';
                  else chstri='ZOH';
                  end
                end
                if isempty(chstro)
                  if strcmp(chstri,'BL')|strcmp(chstri,'AASamples'), chstro='BL';
                  else chstro='Samples';
                  end
                end
                if io==('i'+0), chstr=chstri; else chstr=chstro; end
              %end
              ch=[ch;{chstr}];
            end 
            if ~isempty(un), un=[un;{''}]; end 
            if ~isempty(sc), sc=[sc;{''}]; end
            if ~isempty(fr)&(size(fr,1)>1)
              fr=[fr;{''}];
              %fr=[fr;fr(1)];
            end
            if iscell(fr)&(length(fr)==1), fr=fr{1}; end
          end %for ii
          dat.Names=ns;
          dat.Characters=ch;
          dat.Units=un;
          dat.Scales=sc;
          dat.Frequencies=fr;
          if isa(dat,'fiddata')
            set(dat,'CovarianceMatrix',covar,'Coherence',coh,'noconsistency');
          end
        end
        dat.ChTypes=chtypes;
        if length(Data)==1, Data=Data{1}; end
        dat.Data=Data;
      elseif findstr(['Name','|'],[Property,'|'])
        prop=dat.Names;
        setvalio(prop,ind,Value,chtypes,Valueposs)
        dat.Names=prop;
      elseif findstr(['Character','|'],[Property,'|'])
        prop=dat.Characters;
        setvalio(prop,ind,Value,chtypes,Valueposs)
        dat.Characters=prop;
      elseif findstr(['Unit','|'],[Property,'|'])
        prop=dat.Units;
        setvalio(prop,ind,Value,chtypes,Valueposs)
        dat.Units=prop;
      elseif findstr(['Scale','|'],[Property,'|'])
        prop=dat.Scales;
        setvalio(prop,ind,Value,chtypes,Valueposs)
        dat.Scales=prop;
      elseif findstr(['Frequencies','|'],[Property,'|'])
        prop=dat.Frequencies;
        if isnumeric(Value)&(size(Value,1)==1)&(size(Value,2)>1)
          Value=Value(:);
        end
        setvalio(prop,ind,Value,chtypes,Valueposs)
        dat.Frequencies=prop;
      else
        error('Programming error: Input or Output not found')
      end
    end
  %else
  %  error(['Unrecognized property ''',Property,''''])  
  end
  if ~any(findstr(['|',Property,'|'],...
     ['|Name|Date|Notes|History|Instrumentation|UserData|InputName|OutputName|',...
           'InputCharacter|OutputCharacter|InputUnit|OutputUnit|',...
           'PeriodLength|PeriodNumber|PeriodSamples|InputFrequencies|OutputFrequencies|Frequencies|',...
           'State|Synchronization|']))
     %These would be the not-date-updating properties
     %otherwise:
    importance=1;
  end
end % for
%
if ~strcmp(Property,'noconsistency')
  if ~get(dat,'consistency')
    error(sprintf(['Inconsistent data after setting the properties:\n  ',lastwarn]))
    %'see the warning message above for the reason'
  end
end
%
if importance==1, dat.Date=datestr(now); end
%
% Finally, assign data in caller's workspace
assignin('caller',name,dat)
%
% end @iddat/set.m

function setvalio(prop,ind,newvalue,chtypes,Valueposs)
%Set property value for io properties
%       prop: property cell array from object
%       ind: indices of channels to be replaced
%       newvalue: cell array of new properties
%       chtypes: internal vector of channel types
%       Valueposs: possible values of property

if ~iscell(newvalue)&~isempty(newvalue), newvalue={newvalue}; end
if (length(ind)~=length(newvalue))&~isempty(newvalue)
  error('Property values are inconsistent with object')  
%elseif isempty(newvalue), prop={};  
end
if isstr(prop), str=1; else str=0; end
if isempty(prop)
  prop=cell(length(chtypes),1);
end
if ~isempty(prop)&~iscell(prop), prop={prop}; end
while size(prop,1)<length(chtypes), prop=[prop;prop(1,:)]; end
if (str==1)|any(findstr(Valueposs,'string'))|any(Valueposs=='|')
  for ii=1:length(prop), prop{ii}=setstr(prop{ii}); end
end
for ii=1:length(ind)
  if ~isempty(newvalue)
    vind=findstr(['''',lower(newvalue{ii}),''''],lower(Valueposs));
    if length(vind)==1, newvalue{ii}=Valueposs(vind+[1:length(newvalue{ii})]); end
  end
  if iscell(newvalue), prop{ind(ii)}=newvalue{ii};
  elseif (length(ind)>1)&~isempty(newvalue)
    error('Strange inconsistency in redefinition')
  else prop{ind(ii)}=newvalue;
  end
end %for ii
if iscell(prop)&(length(prop)==1), prop=prop{1}; end
assignin('caller',inputname(1),prop)
%
% end of setvalio
