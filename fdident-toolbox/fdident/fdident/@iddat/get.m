function Out = get(dat,varargin)
%GET  Access/query iddat (and tiddata, fiddata) property values.
%
%   VALUE = GET(DATA,'Property')  returns the value of the specified
%   property of DATA.
%   
%   STRUCT = GET(DAT)  converts the object DAT into 
%   a structure STRUCT with the property names as subfield names and
%   the property values as subfield values.
%   Without left-hand argument,  GET(DAT)  displays all properties 
%   of DAT and their values.
%
%   See also  @CLASS/SET.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Nov-2003

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
if ni==3 %ch:...
  if ~strncmp(varargin{1},'ch:',3)
    error('3 input arguments without reference ''ch:...''')
  end
  ch=dat.ChTypes; cno=length(ch);
  chi=getchi(dat,varargin{1},cno,dat.Names);
  %dat=dat{chi(:)};
  Struct.type='{}'; Struct.subs={chi(:)};
  dat=subsref(dat,Struct);
  Property=varargin{2};
elseif ni==2 %regular get
  Property=varargin{1};
end
%
if ni>1 %Property given
  [Propertyfull,Pvalue]=idpropch(dat,Property,'noerror');
  if isempty(Propertyfull), error(['Property ''',Property,''' not recognized']), end
  Property=Propertyfull;
  %
  %First properties with special handling
  if any(findstr(['|',Property,'|'],...
      '|InputFrequencies|OutputFrequencies|Frequencies|State|'))
    dats=struct(dat);
    if isa(dat,'tiddata')|isa(dat,'fiddata'), dats=struct(dats.iddat); end
    if (~isfinite(dats.PeriodLength)&~isnan(dats.PeriodLength))|isempty(dats.PeriodLength)
      %Out=[]; return
    end
    %continue if these are valid
  elseif strcmp(Property,'Synchronization') %PROPERTY NAME
    %Construct from groups
    gps=get(dat,'groups'); gp='';
    gns=fieldnames(gps);
    for ii=1:length(gns)
      if ~isempty(getfield(gps,gns{ii}))
        %if ~isempty(gp), error('More than one group is nonempty')
        %else 
        gp=gns{ii}; 
        %end
      end
    end
    if isempty(gp), Out=''; return, end
    gpm=get(dat,gp);
    if ~iscell(gpm), gpm={gpm}; end
    if size(gpm,1)~=1, Out=''; return, end
    gpm=gpm{1};
    if iscell(gpm)|ischar(gpm), gpm=getexpnos(dat,gpm); end
    gpm=sort(gpm);
    if isequal(gpm(:),[1:get(dat,'expnumber')]')
      if strcmp(gp,'Groups_Synchronized'), Out='on';
      elseif strcmp(gp,'Groups_Delayed'), Out='delayed';
      elseif strcmp(gp,'Groups_FullMIMO'), Out='mimo';
      elseif strcmp(gp,'Groups_SamePower'), Out='samepower';
      else error('Something is not OK in the groups')
      end
      synch=dat.Synchronization';
      if ~isempty(synch)
        if ~isempty(Out), 
          if ~strcmp(synch,Out), error('Synchronization and groups differently set'), end
        else
          Out=synch;
        end
      end
    else
      Out='';
    end
    return
  elseif strcmp(Property,'Channels')|strncmpi(Property,'Info',4) %PROPERTY NAME
    dats=struct(dat);
    if isa(dat,'tiddata')|isa(dat,'fiddata'), dats=struct(dats.iddat); end
    names=dat.Names;
    chtypes=dat.ChTypes; chn=length(chtypes);
    ch=dat.Characters;
    chu=dat.Units;
    chf=dat.Frequencies;
    str=str2mat('','No channels defined in object');
    sn=length('ChannelName'); sc=length('Character'); su=length('Unit');
    if isempty(names)|(iscell(names)&(length(names)==1)&isempty(names{1}))
      names=cell(chn,1);
      for ii=1:chn, names{ii}=setstr(names{ii}); end
    else
      if ~iscell(names), names={names}; end
      if ~isempty(names)
        for ii=1:length(names), sn=max(sn,length(names{ii})); end %for ii
      end
    end
    if isempty(ch)
      ch=cell(chn,1);
      for ii=1:chn, ch{ii}=setstr(ch{ii}); end
    else
      if ~iscell(ch), ch={ch}; end
      for ii=1:chn, sc=max(sc,length(ch{ii})+2); end %for ii
    end
    for ii=1:chn, if strcmp(ch{ii},'AASamples'), ch{ii}='BL'; end, end
    if isempty(chu)
      chu=cell(chn,1);
      for ii=1:chn, chu{ii}=setstr(chu{ii}); end
    else
      if ~iscell(chu), chu={chu}; end
      for ii=1:chn, su=max(su,length(chu{ii})); end %for ii
    end
    fn=0;
    pl=dat.PeriodLength;
    if ~isempty(pl)&(isfinite(pl)|isnan(pl))
      if ~iscell(chf)&~isempty(chf), fn=1; end
      if iscell(chf)
        for ii=1:length(chf)
          if ~isempty(chf{ii}), fn=1; end
        end %for ii
      end
      if ~iscell(chf)
        chfv=chf; chf=cell(chn,1);
        for ii=1:chn, chf{ii}=chfv; end
      end
    end
    if chn>9, spn=' '; else spn=''; end
    spstr=['%1s  %-',num2str(sn+2),'s','%-',num2str(sc+2),'s',...
        '%-',num2str(su+2),'s'];
    for ii=1:length(chtypes)
      if ii==1
        str='';
        strii=sprintf(spstr,[spn,'  '],'ChannelName','Character','Unit');
        if fn==1, strii=[strii,'  Freqs']; end
        str=str2mat(str,strii);
      end
      chstr=setstr(chtypes(ii)); %'i' or 'o'
      strii=sprintf(spstr,...
        [spn,sprintf('%.0f.',ii)],names{ii},[chstr,':',ch{ii}],chu{ii});
      if fn==1
        strii=[strii,sprintf('  %.0f',length(chf{ii}))];  
      end
      str=str2mat(str,strii);
      if ii==9, spn=''; end
    end %for ii
    if size(str,1)>=3 %at least 1 channel
      name=dat.Name; Data=dat.Data; expno=get(dat,'ExpN'); chno=get(dat,'ChN');
      if strcmp(class(dat),'fiddata')
        sno=get(dat,'freqn');
      elseif strcmp(class(dat),'tiddata')
        sno=get(dat,'samplen');
      else
        d=dat.Data;
        if iscell(d), sno=size(d{1},1);
        else sno=size(d,1);
        end
      end
      if iscell(sno)
        sno=cat(1,sno{:}); snomin=min(sno); snomax=max(sno);
        if snomin==snomax, snostr=sprintf('%.0f',snomin);
        else snostr=sprintf('%.0f...%.0f',snomin,snomax);
        end
      else 
        snostr=sprintf('%.0f',sno);
      end
      if expno>1, ss='s'; else ss=''; end
      if strcmp(class(dat),'fiddata')
        stre=sprintf(['Data: %s frequency points x %.0f experiment',ss,'.'],...
          snostr,expno);
      elseif strcmp(class(dat),'tiddata')
        stre=sprintf(['Data: %s samples x %.0f experiment',ss,'.'],snostr,expno);
      else
        stre=sprintf(['Data: %s points x %.0f experiment',ss,'.'],snostr,expno);
      end
      if ~isempty(name), stre=['Object name: ',name,', d',stre(2:end)]; end
      str=str2mat(str,[stre]);
    end
    str(1,:)='';
    strg=get(dat,'Groups'); fn=fieldnames(strg);
    for ii=1:length(fn)
      strgii=get(dat,fn{ii});
      if ~isempty(strgii)
        for iii=1:size(strgii,1)
          striii=[fn{ii},': '];
          if iii>1, striii=setstr(32*ones(size(striii))); end
          str=str2mat(str,[striii,showline(strgii(iii,:))]);
        end
      end
    end
    if nargout>0, Out=str;
    else disp(str)
    end
    return
  elseif strcmp(Property,'Groups') %PROPERTY NAME
    groups=[];
    dats=struct(dat);
    if isa(dat,'tiddata')|isa(dat,'fiddata'), dats=struct(dats.iddat); end
    str='';
    for ii=1:4
      if ii==1, grn='Groups_Synchronized';
      elseif ii==2, grn='Groups_Delayed';
      elseif ii==3, grn='Groups_FullMIMO';
      elseif ii==4, grn='Groups_SamePower';
      end
      gr=get(dat,grn); %if isempty(gr), gr={}; end
      groups=setfield(groups,grn,gr);
    end %for ii
    if no>0, Out=groups;
    else disp(groups)
    end
    return
  elseif  strcmp(Property,'ChNumber') %PROPERTY NAME
    dats=struct(dat);
    if ~strcmp(class(dat),'iddat'), dats=struct(dats.iddat); end
    ch=dats.ChTypes;
    Out=length(ch);
    return
  elseif  strcmp(Property,'ExpNumber') %PROPERTY NAME
    dats=struct(dat);
    if isa(dat,'tiddata')|isa(dat,'fiddata'), dats=struct(dats.iddat); end
    if iscell(dats.Data), Out=size(dats.Data,2);
    elseif ~isempty(dats.Data), Out=1;
    else Out=0;
    end
    return
  elseif strcmp(Property,'Consistency') %PROPERTY NAME
    %disp('Checking consistency of iddat ... (not yet fully implemented)')
    Out=1;
    %
    if isa(dat,'tiddata')|isa(dat,'fiddata') %special handling of child properties
      Out=getconsy(dat);
      if Out==0
        warning(sprintf(['Inconsistency in ',class(dat),' object:\n  ',lastwarn]))
        return
      end
    end
    Input=get(dat,'Input'); Output=get(dat,'Output');
    if isnumeric(Input)
      sei=1; [ssi,sci]=size(Input);
      if ~isempty(Input), Input={Input}; end
    elseif iscell(Input)
      [sci,sei]=size(Input); ssi=size(Input{1},1);
    end
    for ii=1:length(Input(:))
      Inputi=Input{ii};
      if size(Inputi,2)>1
        Out=0; warning('Width of Input element is more than 1'), return
      end
    end
    if isnumeric(Output)
      seo=1; [sso,sco]=size(Output);
      if ~isempty(Output), Output={Output}; end
    elseif iscell(Output)
      [sco,seo]=size(Output); sso=size(Output{1},1);
    end
    for ii=1:length(Output(:))
      Outputi=Output{ii};
      if size(Outputi,2)>1
        Out=0; warning('Width of Output element is more than 1'), return
      end
    end
    sc=sci+sco; %number of channels
    if ~any(sc==[0,get(dat,'ChN')]), error('ChNumber mismatch'), end
    if (iscell(Input)&~iscell(Output)&~isempty(Output)) |...
        (~iscell(Input)&~isempty(Input)&iscell(Output)) |...
        ( isnumeric(Input)&isnumeric(Output)&(ssi~=sso)&(ssi>0)&(sso>0) )
      Out=0; warning('Input/Output experiment mismatch'), return
    end
    if isnumeric(Input), Input={Input}; end
    if isnumeric(Output), Output={Output}; end
    chtypes=dat.ChTypes;
    if min(size(chtypes))>1
      Out=0; warning('ChTypes is not a vector (internal error'), return
    end
    for ii=1:length(Input)
      if ~any([length(chtypes),0]==sc)
        Out=0; warning('ChTypes has wrong length (internal error)'), return
      end
    end %for ii
    if ~isempty(chtypes)
      if any((chtypes~=('i'+0))&(chtypes~=('o'+0)))
        Out=0; warning('Contents of ChTypes is wrong (internal error)'), return
      end
    end
    %
    name=dat.Name;
    if ~isempty(name)
      if ~isstr(name)|(size(name,1)~=1)
        Out=0; warning('Name is not a string'), return
      end
    end
    %
    ename=get(dat,'ExperimentName');
    if ~isempty(ename)
      EN=get(dat,'ExpN');
      if (EN==1)&isstr(ename) %OK
      elseif EN~=length(ename)
        Out=0; warning('Size of experiment names is not OK'), return
      end
    end
    %

    if ~isempty(name)
      if ~isstr(name)|(size(name,1)~=1)
        Out=0; warning('Name is not a string'), return
      end
    end
    %
    datversion=dat.Version;
    if ~isnumeric(datversion)|(length(datversion)~=1)
      Out=0; warning('iddat version is wrong'), return
    end
    if datversion<1, Out=0; warning('iddat version is less than 1'), return, end
    if (dat.Version~=1.3)
      if (dat.Version<1.3)
        Out=0; warning(sprintf('Old version of iddat: %.4g',dat.Version)), return
      else
        Out=0; warning(sprintf('Too new version of iddat: %.4g',dat.Version)), return
      end
    end
    %
    date=dat.Date;
    if ~isempty(date)
      if ~isstr(date)|(size(date,1)~=1)
        Out=0; warning('Date is not a string'), return
      end
    end
    %
    notes=dat.Notes;
    if ~isempty(notes)
      if (~isstr(notes)&~iscell(notes))
        Out=0; warning('Notes is not a string or a cell of strings'), return
      end
    end
    %
    history=dat.History;
    if ~isempty(history)
      if (~isstr(history)&~iscell(history))
        Out=0; warning('History is not a string or a cell of strings'), return
      end
    end
    %
    Instrumentation=dat.Instrumentation;
    if ~isempty(Instrumentation)
      if ~isstruct(Instrumentation)
        Out=0; warning('Instrumentation is not a structure'), return
      end
    end
    %
    iname=get(dat,'Inputname'); oname=get(dat,'outputName');
    if ~iscell(iname)
      if ~isempty(iname), iname={iname};
      else iname={}; for ii=1:sci, iname{ii}=''; end, iname=iname(:);
      end
    end
    if ~iscell(oname)
      if ~isempty(oname), oname={oname};
      else oname={};  for ii=1:sco, oname{ii}=''; end, oname=oname(:);
      end
    end    
    if ~isempty([iname;oname])
      if ~any(sci+sco==[0,size([iname;oname])])
        Out=0; warning('Wrong number of channel names'), return
      end
      if ~iscell([iname;oname])
        Out=0; warning('Channel names is not a cell of strings'), return
      end
    end
    names=[iname;oname];
    for ii=1:size(names,1)
      if ~isempty(names{ii})&(length(strmatch(names{ii},names,'exact'))>1)
        Out=0; warning('Repeated name in object'), return
      end
    end
    %
    ci=get(dat,'InputCharacter'); co=get(dat,'OutputCharacter');
    %if isstr(ci), ci={ci}; end
    %if isstr(co), co={co}; end
    if ~iscell(ci)
      if ~isempty(ci), ci={ci};
      else ci={}; for ii=1:sci, ci{ii}=''; end, ci=ci(:);
      end
    end
    if ~iscell(co)
      if ~isempty(co), co={co};
      else co={}; for ii=1:sco, co{ii}=''; end, co=co(:);
      end
    end
    if ~isempty(ci)
      if ~any([0,length(ci)]==sci)
        Out=0; warning('Channel character mismatch'), return
      end
      for ii=1:length(ci)
        if ~any(findstr(['|',ci{ii},'|'],'||ZOH|ZOHf|FOH|BL|Samples|AASamples|Discrete|'))
          Out=0; warning(['Wrong character type: ',ci{ii}]), return
        elseif any(findstr(['|',ci{ii},'|'],'|AASamples|'))
          ci{ii}='BL';
          %warning('InputCharacter is AASamples. This is obsolete: use BL instead')
        end
      end %for ii
    end
    if ~isempty(co)
      if ~any([0,length(co)]==sco)
        Out=0; warning('Channel character mismatch'), return
      end
      for ii=1:length(co)
        if ~any(findstr(['|',co{ii},'|'],'||BL|Samples|AASamples|Discrete|'))
          Out=0; warning(['Wrong character type: ',co{ii}]), return
        elseif any(findstr(['|',co{ii},'|'],'|AASamples|'))
          co{ii}='BL';
          %warning('OutputCharacter is AASamples. This is obsolete: use BL instead')
        end
      end %for ii
    end
    %
    ui=get(dat,'InputUnit'); uo=get(dat,'OutputUnit');
    if ~iscell(ui)
      if ~isempty(ui), ui={ui};
      else ui={}; for ii=1:sci, ui{ii}=''; end, ui=ui(:);
      end
    end
    if ~iscell(uo)
      if ~isempty(uo), uo={uo};
      else uo={}; for ii=1:sco, uo{ii}=''; end, uo=uo(:);
      end
    end
    u=[ui;uo];
    if ~isempty(u)
      if (length(ui)~=sci)|(length(uo)~=sco)
        Out=0; warning('Unit mismatch'), return
      end
    end
    %
    si=get(dat,'InputScale'); so=get(dat,'OutputScale');
    if ~iscell(si)
      if ~isempty(si), si={si};
      else si={}; for ii=1:sci, si{ii}=''; end, si=si(:);
      end
    end
    if ~iscell(so)
      if ~isempty(so), so={so};
      else so={}; for ii=1:sco, so{ii}=''; end, so=so(:);
      end
    end
    s=[si;so];
    if ~isempty(s)&(length(s)>1)
      if (length(si)~=sci)|(length(so)~=sco)
        Out=0; warning('Scale mismatch'), return
      end
    end
    %
    pl=dat.PeriodLength;
    if ~isempty(pl)
      if length(pl)>1, Out=0; warning('PeriodLength is not a scalar'), return, end
      if isfinite(pl)&(pl<=0)
        Out=0; warning('PeriodLength is not positive'), return
      end
    end
    %
    ifr=get(dat,'InputFrequencies'); ofr=get(dat,'OutputFrequencies');
    if ~iscell(ifr)
      if ~any(size(ifr,2)==[0,1])
        error('Wrong second size of numeric input frequencies')
      end
      if ~isempty(ifr), ifr={ifr};
      else ifr={}; for ii=1:sci, ifr{ii}=[]; end, ifr=ifr(:);
      end
    end
    if ~iscell(ofr)
      if ~any(size(ofr,2)==[0,1])
        error('Wrong second size of numeric output frequencies')
      end
      if ~isempty(ofr), ofr={ofr};
      else ofr={}; for ii=1:sco, ofr{ii}=[]; end, ofr=ofr(:);
      end
    end
    fr=[ifr;ofr];
    if ~isempty(fr)
      if isnumeric(ifr)&isnumeric(ofr)
        if (size(ifr,2)>1)|(size(ofr,2)>1)
          Out=0; warning('Frequencies is not a vector or a cell array'), return
        end
      elseif iscell(ifr)&iscell(ofr)
        for ii=1:size(fr,1)
          for iii=1:size(fr,2)
            if ~isnumeric(fr{ii,iii})|(size(fr{ii,iii},2)>1)
              Out=0; warning('Wrong element of Frequencies'), return
            end
          end %for iii
        end %for ii
      end
    end
    fr=dat.Frequencies;
    if isnumeric(fr)
      if ~any(size(fr,2)==[0,1])
        error(['Horizontal size of numeric Frequencies is ',...
            num2str(size(fr,2))])
      end
    elseif iscell(fr)
      if ~isempty(fr)&(size(fr,1)~=get(dat,'ChN'))
        error(['Horizontal size of Frequencies (cell) is ',...
            num2str(size(fr,2))])
      end
    else Out=0; warning('Invalid class of Frequencies'), return
    end
    %
    st=dat.State;
    if ~isempty(st)
      if ~strcmp(st,'steady-state')&~strcmp(st,'transient')
        Out=0; warning(['Wrong State: ''',st]), return
      end
    end
    %
    sy=get(dat,'Synchronization');
    if ~isempty(sy)
      if ~strcmp(sy,'on')&~strcmp(sy,'delayed')&~strcmp(sy,'samepower')&...
          ~strcmp(sy,'mimo')
        Out=0; warning(['Wrong Synchronization: ''',sy,'''']), return
      end
    end
    %
    expno=get(dat,'ExpN');
    if length(expno)~=1
      Out=0; warning('ExpNumber in not a scalar'), return
    end
    if rem(expno,1)~=0
      Out=0; warning('ExpNumber is not an integer'), return
    end
    %
    Ref=get(dat,'ReferenceData');
    inpdata=get(dat,'inputdata');
    if isempty(Ref)
    elseif isnumeric(Ref)&isnumeric(inpdata)&all(size(Ref)==size(inpdata))
    elseif isnumeric(Ref)&iscell(inpdata)&(size(inpdata,2)==1)&...
        (length(Ref)==length(inpdata{1}))
    elseif isnumeric(Ref)&iscell(inpdata)&...
        (length(Ref)==length(inpdata{1}))
    elseif iscell(Ref)&iscell(inpdata)&...
        ( (size(Ref,2)==size(inpdata,2))|(size(Ref,2)==1) )
      for iii=1:size(Ref,1)
        for ii=1:size(Ref,2)
          if any(size(Ref{iii,ii})~=size(inpdata{iii,ii}))
            Out=0; warning(['Reference is not compatible with data']), return
          end
        end
      end
    else
      Out=0; warning(['Reference is not compatible with data']), return
    end
    %
    groups=cell(1,4); names={};
    for ii=4:-1:1
      members=[]; %group members at the same level
      if ii==1, grn='Groups_Synchronized';
      elseif ii==2, grn='Groups_Delayed';
      elseif ii==3, grn='Groups_FullMIMO';
      elseif ii==4, grn='Groups_SamePower';
      end
      gr=get(dat,grn);
      if ~isempty(gr)
        if isnumeric(gr), gr={gr}; end
        if ~iscell(gr), Out=0; warning([grn,' is not a cell']), return, end
        if all(size(gr,2)~=[2]), Out=0; warning([grn,' is not an Mx2 cell']), return, end
        for in=1:size(gr,1)
          if ~isempty(gr{in,2})&~ischar(gr{in,2})
            Out=0; warning(sprintf([grn,'{%.0f,2} is not a string'],in)), return
          end
        end %for in
      end
      grind=cell(size(gr,1),1);
      for ig=1:size(gr,1)
        grind{ii}=getexpnos(dat,gr{ig,1});
        members=[members,grind{ii}];
        if ~isempty(gr{ig,2})
          name=gr{ig,2};
          if strmatch(name,names,'exact')
            warning(['Repeated group name ''',name,'''']), Out=0; return
          else
            names=[names;{name}];
          end
        end
        if any(~diff(sort(grind{ii}))), warning('Repeated index in group'), Out=0; return, end
        for igs=4:-1:ii+1
          for iind=1:length(groups(igs))
            if all(ismember(grind{ii},groups{igs}))|~any(ismember(grind{ii},groups{igs}))
            else warning('Membership inconsistency in groups'), Out=0; return, 
            end
          end %for iind
        end %for igs
        name=gr{ig,2};
        if isempty(name)
          name=[lower(grn(8)),'(',num2str(ig),')'];
          if strcmp(grn,'Groups_SamePower'), name(1)='p'; 
          elseif strcmp(grn,'Groups_FullMIMO'), name(1)='m'; 
          end
        end
        if any(getexpnos(dat,name)>get(dat,'expnumber'))
          exps=getexpnos(dat,name); ind=find(exps>get(dat,'expnumber'));
          warning(['Invalid experiment in: ',grn,', ',name,': ',num2str(exps(ind))])
          Out=0; return
        end
        if ~isempty(members)&~all(diff(sort(members)))
          warning(['Common member among groups in ''',grn,'''']), Out=0; return
        end
      end %for ig
    end %for ii
    return
    %end of consistency
  end
  %
  %This is a regular case for ni>1: return value of property
  Out='Nondetermined value';
  dats=struct(dat);
  if isa(dat,'tiddata')|isa(dat,'fiddata')
    props=idpropch(dat,'','child'); %all properties of child
    if any(findstr(props,['|',Property,'|'])) %child property
      if isfield(dats,Property) %child property field
        Out=getfield(dats,Property);
      else
        Out=getloc(dat,Property); %Get non-field child property
      end
    else %iddat property
      dat=dats.iddat; dats=struct(dat);
    end
  end
  if ~isa(Out,'iddat')&strcmp(Out,'Nondetermined value')
    if any(findstr(['|','Input'],['|',Property]))|...
        any(findstr(['|','Output'],['|',Property]))|...
        strcmp(['|u|'],['|',Property,'|'])|...
        strcmp(['|y|'],['|',Property,'|'])
      %All Input and Output channels are stored together
      %(this is NOT seen from outside!)
      if strcmp('Input',Property)|strcmp('Output',Property)|...
          strcmp(['|u|'],['|',Property,'|'])|...
          strcmp(['|y|'],['|',Property,'|'])
        ioprop=dat.Data;
        if ~iscell(ioprop), ioprop={ioprop}; end
        scales=dat.Scales;
        if ~isempty(scales)
          if ~iscell(scales), scales={scales}; end
          for ii=1:size(ioprop,1)
            if size(scales,1)==1, sc=scales{1}; else sc=scales{ii}; end
            for iii=1:size(ioprop,2)
              if ~isempty(sc)
                ioprop{ii,iii}=sc*ioprop{ii,iii};
              end
            end %for iii
          end %for ii
        end
      elseif any(findstr(['Name','|'],[Property,'|']))
        ioprop=dats.Names;
      elseif any(findstr(['Character','|'],[Property,'|']))
        ioprop=dats.Characters;
        if iscell(ioprop)
          for ii=1:length(ioprop)
            if strcmp(ioprop{ii},'AASamples'), ioprop{ii}='BL'; end
          end
        end
      elseif any(findstr(['Unit','|'],[Property,'|']))
        ioprop=dats.Units;
      elseif any(findstr(['Scale','|'],[Property,'|']))
        ioprop=dats.Scales;
      elseif any(findstr(['Frequencies','|'],[Property,'|']))
        ioprop=dats.Frequencies;
        chtypes=dats.ChTypes;
        if ~isempty(ioprop)&isnumeric(ioprop)
          ioprop={ioprop};
          for ii=2:length(chtypes)
            ioprop{ii,:}=ioprop{1};
          end
        end
      elseif any(findstr(['ChNumber','|'],[Property,'|']))
        ioprop=dats.ChTypes;        
      else
        error('Programming error: Input or Output not found')
      end
      if iscell(ioprop)&(length(ioprop)==1)&isempty(ioprop{1}), ioprop=ioprop{1}; end
      chtypes=dats.ChTypes;
      if isempty(chtypes), indi=[]; indo=[];
      else indi=find(chtypes==('i'+0)); indo=find(chtypes==('o'+0));
      end  
      if strcmp('Input',Property)|strcmp('Output',Property)|...
          strcmp(['|u|'],['|',Property,'|'])|...
          strcmp(['|y|'],['|',Property,'|'])
        Out=[];
        if (strncmp('Input',Property,5)|strcmp('u',Property))
          if ~isempty(ioprop), ioprop=ioprop(indi,:); elseif isempty(indi), ioprop=[]; end
        elseif (strncmp('Output',Property,6)|strcmp('y',Property))
          if ~isempty(ioprop), ioprop=ioprop(indo,:); elseif isempty(indo), ioprop=[]; end
        end
        Out=ioprop;
      else %not just Input or Output
        if ~isempty(ioprop)
           if strncmp('Input',Property,5)
             Out=ioprop(indi,:);
           elseif strncmp('Output',Property,6)
             Out=ioprop(indo,:);
           end
           if any(findstr(Property,'Frequencies'))|any(findstr(Property,'FreqPoints'))
             if iscell(Out)&~isempty(Out)&(size(Out,2)==1)
               Ocell=0;
               for ii=2:size(Out,1)
                 if ~isequal(Out{ii,1},Out{1,1}), Ocell=1; end
               end
               if ~Ocell, Out=Out{1}; end
             end
           end  
           if any(findstr(['ChNumber','|'],[Property,'|']))
             Out=length(Out);
           end
        else %empty ioprop
           if any(findstr('string',Pvalue)), Out='';
           else Out=[];
           end
        end        
      end
      if iscell(Out)&isempty(Out), Out=[]; end
      %
      %Make array or string if one experiment 
      if iscell(Out)&(length(Out)==1), Out=Out{1}; end
    elseif any(strmatch(Property,...
        {'ExperimentName','ReferenceData',...
          'Groups_Synchronized','Groups_Delayed','Groups_SamePower','Groups_FullMIMO'},...
        'exact'))
      Out={};
      if isfield(dats.NewProperties,Property)
        Out=getfield(dats.NewProperties,Property);
        if any(findstr(Property,'Groups_'))&isempty(Out), Out={}; end
      end
      if any(strmatch(Property,{'ExperimentName','ReferenceData'}))
        if iscell(Out)&(length(Out)==1), Out=Out{1}; end
        if ~iscell(Out)&all(isnan(Out)), Out='';
        elseif isempty(Out), Out='';
        end
      end
      if any(strmatch(Property,{'ReferenceData'}))&isempty(Out), Out={}; end
    else %not I/O
      Out=getfield(dats,Property);
      if isempty(Out)&strcmp(Property,'Frequencies'), Out=[]; end
      if strcmp(Property,'Characters')
          %strcmp(Property,'InputCharacter')|strcmp(Property,'OutputCharacter')
        %Change AASamples to BL
        if isstr(Out)
          if strcmp(Out,'AASamples'), Out='BL'; end
        elseif iscell(Out)
          for ii=1:length(Out)
            if strcmp(Out{ii},'AASamples'), Out{ii}='BL'; end
          end
        end
      end
    end %I/O
    %property value returned
  end
  %
  %Now make cells to strings etc if possible
  if iscell(Out)&(length(Out)==1), Out=Out{1}; end
  %
  return
end %ni>1

%Now ni==1 (return or display property values)
dats=struct(dat);
props = idpropch(dat);
ind=find(props=='|'); propsc=cell(length(ind)-1,1); valuesc=propsc;
for ii=length(ind)-1:-1:1
  propsc{ii}=props(ind(ii)+1:ind(ii+1)-1);
  %Eliminate periodic properties if irrelevant
  pl=dat.PeriodLength;
  fr=dat.Frequencies; st=dat.State; sy=dat.Synchronization;
  if any(findstr(['|',propsc{ii},'|'],...
      '|InputFrequencies|OutputFrequencies|Frequencies|State|Synchronization|'))&...
      ( (isempty(pl)&isempty(fr)&isempty(st)&isempty(sy))|...
           (~isfinite(pl)&~isnan(pl)))&isa(dat,'tiddata')
    %Eliminate periodic properties from get list if irrelevant
    propsc(ii)=[]; valuesc(ii)=[];
  elseif (strncmp(propsc{ii},'CovVector',4)|strncmp(propsc{ii},'CohVector',4)) & ...
      (get(dat,'chnumber')~=2)
    %Covvect has no meaning
    propsc(ii)=[]; valuesc(ii)=[];
  elseif (strncmp(propsc{ii},'SisoVariance',5)|strncmp(propsc{ii},'OldTbSisoVariance',6)|...
      strncmp(propsc{ii},'SisoNonlinError',6)) & ...
      (~isequal(get(dat,'inputchnumber'),1)|~isequal(get(dat,'outputchnumber'),1))
    %SisoVariance has no meaning
    propsc(ii)=[]; valuesc(ii)=[];
  elseif any(findstr(['|',propsc{ii},'|'],listnot(dat)))
    %eliminate property from get list
    propsc(ii)=[]; valuesc(ii)=[];
  elseif any(findstr(['|',propsc{ii},'|'],'|Consistency|'))
    cy=get(dat,'consistency');
    propsc(ii)=[]; valuesc(ii)=[];
  elseif any(findstr(['|',propsc{ii},'|'],...
      ['|Consistency|FreqNumber|SampleNumber|ExpNumber|ChNumber|',...
        'InputChNumber|OutputChNumber|Channels|Information|Groups|']))
    %Move these properties to the end of the list
    valuesc{ii}=get(dat,propsc{ii});
    %Here move poperties to the end
    propii=propsc{ii}; propsc(ii)=[]; propsc{end+1}=propii;
    valueii=valuesc{ii}; valuesc(ii)=[]; valuesc{end+1}=valueii;
  elseif isfield(dats,propsc{ii})
    %Quickest access
    valuesc{ii}=getfield(dats,propsc{ii});
  else
    valuesc{ii}=get(dat,propsc{ii});
  end
end %for ii
%First eliminate empty properties for displaying,and also I/O scales
for ii=length(valuesc):-1:1
  %Empty or scales:
  if isempty(valuesc{ii})|any(findstr([propsc{ii},'|'],'Scale|'))|any(findstr([propsc{ii},'|'],'Groups|'))
    valuesc(ii)=[]; propsc(ii)=[];
  elseif strcmp(propsc{ii},'u')
    valuesc{ii}='same as Input';  
  elseif strcmp(propsc{ii},'y')  
    valuesc{ii}='same as Output';  
  end 
end %for ii
%
if no,
  Out = cell2struct(valuesc,propsc,1);
else
  shprops(propsc,valuesc,' = ',iddat);
end
if exist('cy')
  if cy==0, error('Inconsistent object: see the warning message above for the reason'), end
end

function str=showline(grv)
i1=1; ie=1; str='';
if isnumeric(grv)
  grv=sort(grv);
  str=[str,'['];
  while ie<=length(grv)
    while (ie<length(grv))&((grv(ie+1)-grv(i1))==(ie+1-i1))
      ie=ie+1;
    end
    if i1==1, str=[str,sprintf('%.0f',grv(i1))];
    else str=[str,sprintf(',%.0f',grv(i1))];
    end
    if ie>i1, str=[str,sprintf(':%.0f',grv(ie))]; end
    i1=ie+1; ie=i1;
  end %while ie
  str=[str,']'];
elseif ischar(grv)
  str=[str,'''',grv,''''];
elseif iscell(grv)
  str=[str,'{ '];
  for iv=1:length(grv)
    str=[str,showline(grv{iv})];
    if iv<length(grv), str=[str,' ']; end
  end
  str=[str,' }'];
  %str=[str,sprintf('(cell, %.0f x %.0f)',size(grv,1),size(grv,2))];            
end %while grv
%
% end of file @iddat/get.m
