function testiddat(otype)
%TESTIDDAT  Check tiddata and fiddata objects
%
%       testiddata(otype)
%
%       otype: 'f...' or 't...', for fiddata and tiddata, respectively

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 13-Mar-2005

echo off
%
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
try
  h=findall(0,'type','figure');
  while ~isempty(h), delete(h(1)); drawnow, h=findall(0,'type','figure'); end
catch
  pause(1)
  try, close all force, catch, pause(1), end
end
close all force
figure(1), set(1,'name',name), clear ds n ind name
clear ds n ind
ver=fdtool('version');
if nargin<1, otype=[]; end
if isempty(otype)
  otype={'fiddata','tiddata'};
  clear functions %Reset functions
elseif isstr(otype)
  if strcmp(otype(1),'t'), otype={'tiddata'};
  elseif strcmp(otype(1),'f'), otype={'fiddata'};
  else
    error(['otype = ',otype,' is not allowed'])
  end
else
  error('otype is not allowed')
end
%
for objtype=otype
  objtype=objtype{1};
  disp(' '), disp(['Test of ',objtype,' objects'])
  %dbstop if warning, dbstop if error
  %
  echo on
  feval(objtype,'examples')
  %
  obj=feval(objtype);
  echo off
  disp(['Class: ',class(obj)])
  echo on
  %
  %Examples:
  if strcmp(objtype,'tiddata') %TIDDATA test
    t=tiddata(randn(5,1),ones(5,1),1e-3);
    t2=tiddata(randn(5,1),ones(5,1),1e-3,'Output','Input','ZOH');
  end
  %
  %Basic calls
  sg=get(obj);
  if length(struct2cell(sg))~=6, error('Bad length of empty object'), end
  obj=feval(objtype,1,2,3);
  sg=get(obj)
  %
  if strcmp(objtype,'tiddata') %TIDDATA test
    obj=tiddata([1;1;1],{[1;2;3];[4;5;6]},1e-3,'',{'I1';'I2'},'A',{'','Hz'});
    if ~isequal(obj.ts,1e-3), error('ts error'), end
  else
    obj=fiddata([1;1;1],{[1;2;3];[4;5;6]},[11:13],[],[],[],'',...
      {'I1';'I2'},'A',{'','Hz'});
    if ~isequal(obj.freqpoints,[11:13]'), error('freqpoints error'), end
  end
  if ~isequal(obj.output,[1;1;1]), error('Output error'), end
  if ~isequal(obj.input,{[1;2;3];[4;5;6]}), error('Input error'), end
  if ~isempty(obj.outputname), error('Outputname error'), end
  if ~all(strcmp(obj.inputname,{'I1';'I2'})), error('Inputname error'), end
  if ~isequal(obj.Outputunit,'A'), error('Outputunit error'), end
  if ~all(strcmp(obj.Inputunit,{'';'Hz'})), error('Inputunit error'), end
  %
  obj.name='First test';
  if ~strcmp(obj.Name,'First test'), error('Name error'), end
  get(obj)
  set(obj)
  synch=get(obj,'synchronization')
  set(obj,'synchronization')
  set(obj,'periodlength',5)
  if ~isequal(obj.periodl,5), error('Periodlength error'), end
  set(obj)
  check(obj)
  set(obj,'periodlength',[])
  if ~isequal(obj.periodl,[]), error('Periodlength error'), end
  %
  %Add new channels one by one to object
  set(obj,'ch:4','Input',[1,3,5]')
  if obj.chn~=4, error('Fail to add channel #4'), end
  set(obj,'ch:5','Output',[1,inf,NaN]','Outputname','Dataset1','Outputunit','Idea')
  if obj.chn~=5, error('Fail to add channel #5'), end
  obj.channels
  set(obj,'ch:6','Output',[21;22;23],'OutputName',''), obj.channels
  if obj.chn~=6, error('Fail to add channel #6'), end
  %
  %Subscripting
  objs=obj{[1,3]}; objs.channels
  if objs.chn~=2, error('Failure to subscript to 2 channels'), end
  nams=obj{[4,5],1}.outputname
  if ~strcmp(nams,'Dataset1'), error('Name error'), end
  nams=obj{:,1}.inputname
  if any(~strcmp(nams,{'I1';'I2';''})), error('Name error 2'), end
  nams=obj{:,1}.inputname{2};
  if ~strcmp(nams,'I2'), error('Name error 3'), end
  obj{3}=[]; obj.channels
  if obj.chn~=5, error('Cannot delete channel from object'), end
  objd=obj; objd(3)=[]; objd.channels
  if strcmp(objtype,'tiddata') %TIDDATA test
    if objd.samplen~=(obj.samplen-1), error('Cannot delete one point'), end
  else %FIDDATA
    if objd.freqn~=(obj.freqn-1), error('Cannot delete one point'), end
  end
  obj.inputname{2}='Newname'; obj.channels
  obj.inputname(1)={'Second'}, obj.channels
  nams=obj.inputname;
  if any(~strcmp(nams,{'Second';'Newname'})), error('Name error 4'), end
  obj.output, d=obj.output{2}(2)
  if isfinite(d)|isnan(d), error('Infty point not obtained'), end
  obj.output{2}(2)=0.1; d2=obj.output{2}(2)
  if d2~=0.1, error('Modified point not obtained'), end
  %Obsolete obj3=[obj,obj,obj]; obj3.channels
  obj3=merge(obj,obj,obj); obj3.channels
  set(obj3,'synchronization','on')
  if ~strcmp(obj3.synchr,'on'), error('Synchronization error'), end
  set(obj3,'synchronization','')
  if ~strcmp(obj3.synchr,''), error('Synchronization deleting error'), end
  if obj3.expn~=3, error('Horizontal concatenation error'), end
  objs=obj3{:,2}; objs.channels
  if objs.expn~=1, error('Subscript by experiment error'), end
  obj3{:,3}=objs;
  p=obj3.input{2,1}(2)
  if p~=3, error('p-error'), end
  obj3.input{2,1}(2)=11;
  p=obj3.input{2,1}(2)
  if p~=11, error('p-error'), end
  v=obj3.input{2,3}(:)
  if ~isequal(v,[1;3;5]), error('Get vector error'), end
  obj3.input{2,3}=[11;112;1112];
  v=obj3.input{2,3}
  if ~isequal(v,[11;112;1112]), error('Get vector error #2'), end
  obj1=obj; obj2=obj; obj2.input={[1;2;3];[4;5;6]};
  if ~isequal(obj2.input,{[1;2;3];[4;5;6]}), error('Cell assignment error'), end
  %
  %Examples (check that they run)
  obje=merge(obj1,obj2); %add experiments
  obje{:,2}; %object with all channels but only experiment 2
  obje{2}; %object containing channel #2 only (see channel number by t.channels)
  obje{2,1}; %object with channel 2 and experiment 1
  obj2=obje{:,1}; %one-experiment object
  obje{:,2}=obj2; %replace exp 2 by data in one-experiment object obj2
  obj{1}=[]; %delete channel #1
  obj{1}(1:2); %select channels/samples
  obj{1}(2:3).input %return property of selected object
  obje{:,2}=[]; %delete experiment #2
  set(obj,'ch:2','Input',randn(3,1)); %replace 2nd channel (or add new one)
  %
  %New syntax (subscript)
  obje(1,1,1,1)
  obje(1,[],1,1)
  obje(1,1,[],:)
  obje(1:2,[],2)
  %
  %Generate object with only input or only output data
  if strcmp(objtype,'tiddata') %TIDDATA test
    %obj is tiddata
    obj=tidin(tiddata,[],[],'',''); obj.channels
    obj=tidin(tiddata,[1;2;3],[],'','A'); obj.channels
    obj=tidin(tiddata,[1;2;3],1,'x','A'); obj.channels
    %
    obj=tidout(tiddata,[],[],'',''); obj.channels
    obj=tidout(tiddata,[1;2;3],[],'','A'); obj.channels
    obj=tidout(tiddata,[1;2;3],1,'x','A'); obj.channels
  end
  %
  if strcmp(objtype,'tiddata') %TIDDATA test
    %Lennart's examples:
    obj2=tiddata(ones(5,1),randn(5,1),0.1);
    obj2.channels
    obj3=addchannels(obj2,tiddata([],obj2.inputdata,0.1,'',obj2.inputname,'','Volt'));
    obj3.channels
    obj2c=tiddata(ones(300,1),{randn(300,1);randn(300,1)},0.1,...
      'Current',{'Voltage';'Voltage2'},'A',{'V';'mV'});
    obj2c.channels
    objs=obj2c{[1 3],1}(200:300); objs.channels
    z=tiddata(randn(100,1),[],0.1);
    z.channels
    obj=tiddata(randn(100,1),randn(100,1),0.1);
    obj.channels
    %
    y={randn(50,1),randn(50,1)};
    u={randn(50,1),randn(50,1)};
    ll=tiddata(y,u,0.1);
    ll.channels
  else %fiddata
    obj2=fiddata(ones(5,1),randn(5,1),[11:15]);
    obj2.channels
    obj3=addchannels(obj2,fiddata([],obj2.input,obj2.inputfreqpoints,[],[],[],'',obj2.inputname,'','Volt'));
    obj3.channels
    obj2c=fiddata(ones(300,1),{randn(300,1);randn(300,1)},[1:300],...
      [],[],[],'Current',{'Voltage';'Voltage2'},'A',{'V';'mV'});
    obj2c.channels
    objs=obj2c{[1 3],1}(200:300); objs.channels
    %
    load emachine
    d=emachine;
    di=iddat(d); s=diff(d,di);
    if ~isempty(s), error('Objects differ'), end
    emachtst(fiddata)
    %
    %fddemosn
  end
  %
  if exist('robotarm.mat')
    load robotarm
    if strcmp(objtype,'tiddata') %TIDDATA test
      t=robotarm_rawdata;
      if ~isa(t,'tiddata'), error('load error'), end
      get(t), check(t)
      %
      t0=robotarm_rawdata;
      figure(1), plot(t0), drawnow
      f=fiddata(t0);
      figure(2), plot(f), drawnow
      t=tiddata(f,40960);
      figure(3), plot(t), drawnow
      %pause
      %
      t0=robotarm_per1_rawdata;
      figure(1), plot(t0), drawnow
      f=fiddata(t0);
      figure(2), plot(f), drawnow
      t=tiddata(f,4096);
      figure(3), plot(t), drawnow
      %pause
      %
      t0=robotarm_5segm;
      figure(1), plot(t0), drawnow
      f=fiddata(t0);
      figure(2), plot(f), drawnow
      t=tiddata(f,4096);
      figure(3), plot(t), drawnow
      %pause
      if ishandle(1), delete(1), end
      if ishandle(2), delete(2), end
      if ishandle(3), delete(3), end
      %      
    else %FIDDATA
      if ~isa(f,'fiddata'), error('load error'), end
      get(f), check(f)
      av=mean(robotarm_freqdata);
    end
    %
    load robotarm %data
    figure(1), plot(f)
    %
    t=[1:32]'/32;
    u=cos(2*pi*(t)*2);
    d=tiddata(2*u,u,1/32);
    d.frequencies=2;
    f=fiddata(d);
    plot(f,'='), shg
    d.tstart={(1/2)/4;0}; f=fiddata(d); plot(f,'='), shg
    %Phase: 90 degrees
    %
    if strcmp(objtype,'tiddata') %TIDDATA test
      plot(d), drawnow  
    end
    %
    help fiddata %help on creator
    help(fiddata) %description of object
    helpc(fiddata) %contents of class directory
    help tiddata %help on creator
    help(tiddata) %description of object
    helpc(tiddata) %contents of class directory
  end
  %
  %Test object conversions from/to SITB
  if exist(['@iddata',filesep,'iddata'])
    if strcmp(objtype,'tiddata') %TIDDATA test
      %Explore all MAT-files
      fp=which('iddata1.mat');
      dn=fp(1:end-12);
      fall=dir([dn,filesep,'*.mat']);
			%for in=length(fall):-1:1
			%  if strcmp(fall(in).name,'iddata8.mat'), fall(in)=[]; end
			%  if strcmp(fall(in).name,'steamdata.mat'), fall(in)=[]; end
			%end
      for ii=1:length(fall)
        fn=fall(ii).name;
        v=load(fn);
        vn=fieldnames(v);
        for iii=1:length(vn)
          idobj=getfield(v,vn{iii});
          if isa(idobj,'iddata')
            figure(1), plot(idobj)
            obj=iddat(idobj);
            figure(2), clf, if obj.chnumber<=2, plot(obj), end
            try, idobj2=iddata(obj); figure(3), plot(idobj2), 
						catch, disp('Cannot convert to iddata'), 
						end
            dom=get(idobj,'Domain');
            if strcmpi(dom,'time')|strcmpi(dom,'frequency'), typ=dom(1);
            else error('Unknown Domain in iddata object')
            end
            disp(['Object ',fn,'(',vn{iii},...
                    ') has been converted from iddata to ',typ,'iddata and back'])
          end
        end %for iii
      end %for ii
      %
      load dry2.mat
      d=tiddata(dry2);
      if ~isequal(dry2.u,d.input)|~isequal(dry2.y,d.output)|...
          ~isequal(dry2.ts,d.ts)|~strcmp(d.inputcharacter,'ZOH')
        error('Converted data differ')
      end
      %
      y=10+rand(5,1); u=5+rand(5,1); ts=0.001;
      dat=iddata(y,u,ts,'inputname','testinput','outputname','testoutput');
      dt=iddat(dat);
      dt2=tiddata(dat);
      dt.date='';
      dt2.date='';
      if ~isempty(diff(dt,dt2)), error('Converted objects differ'), end
      if any(abs(dt.input-dat.u)>0)|any(abs(dt.output-dat.y)>0)|...
          any(abs(dt.ts-dat.ts)>0)|...
          ~strcmp(dt.inputname,'testinput')|~strcmp(dt.outputname,'testoutput')
        error('Converted model differs')
      end
      %
      try, dt3=fiddata(dat); OK=1;
      catch, OK=0;
      end
      if OK==1, error('Error message is missing'), end
      %
      dat2=iddata(dt);
      fn=fieldnames(dat);
      for ii=1:length(fn)
        if strcmpi(fn{ii},'timeunit')&strcmp(getfield(dat2,fn{ii}),'s')
        elseif strcmp(fn{ii},'Utility') %error in iddata
				elseif strcmp(fn{ii},'Version') %error in iddata
        elseif strcmp(fn{ii},'Domain')&strcmpi(getfield(dat,fn{ii}),getfield(dat2,fn{ii}))
        else
          if ~isequal(getfield(dat,fn{ii}),getfield(dat2,fn{ii}))
            dat_field=getfield(dat,fn{ii})
            dat2_field=getfield(dat2,fn{ii})
            error(['Fields ',fn{ii},' differ'])
          end
        end
      end
      %
      load robotarm
      dat=iddata(robotarm_rawdata);
      dt=tiddata(dat);
      if ~isequal(dt.input,robotarm_rawdata.input)|...
          ~isequal(dt.output,robotarm_rawdata.output)|...
          ~isequal(dt.ts,robotarm_rawdata.ts)|...
          ~isequal(dt.SamplingInstants,robotarm_rawdata.SamplingInstants)
        error('Restored model differs')
      end
      %
      %Several experiments
      load robotarm
      plot(robotarm_5segm)
      dat=iddata(robotarm_5segm);
      plot(dat)
      dt=tiddata(dat);
      if ~isequal(robotarm_5segm.input,dt.input)|...
          ~isequal(robotarm_5segm.output,dt.output)|...
          ~isequal(robotarm_5segm.ts,dt.ts)|...
          ~isequal(robotarm_5segm.inputname,dt.inputname)|...
          ~isequal(robotarm_5segm.outputname,dt.outputname)
        error('Converted data differ')
      end
      %
      %Test cell tstart
      d=tiddata({randn(5,1),randn(5,1)},{ones(5,1),ones(5,1)},1);
      set(d,'tstart',{1,2;30,400})
      id=iddata(d);
      get(id);
      %
      disp('Comparing artificial objects')
      t=tiddata([1:5]',[1:5]');
      set(t,'samplinginstants',[1,2,4,5,6]');
      dat=iddata(t);
      dt=tiddata(dat);
      %
      dt.names={}; dt.history=''; 
      dt.inputunit=''; dt.outputunit='';
      t.inputunit=''; t.outputunit='';
      if isstr(dt.inputcharacter)&strcmp(dt.inputcharacter,'AASamples')
        dt.inputcharacter='BL';
      end
      dt.experimentname='';
      t.date=''; dt.date='';
      diff(t,dt)
      if ~isequal(t,dt)
        warning('iddata objects differ')
      end
      %
      disp('File to tiddata object')
      exptim([1:5]',randn(5,1),randn(5,1),1,1,'tmp.tim');
      if str2num(ver(1:3))>=3.1, obj=tiddata('tmp.tim'); end
      delete tmp.tim
    else %fiddata
      load robotarm
      load bandpass
      load emachine
      load aluplate
      fnall={'robotarm_per1_freqdata','robotarm_freqdata_agv','robotarm_freqdata',...
          'aluplate','emachine','bandpass','bandpass_synch'};
      for ii=1:length(fnall)
        disp(['Comparing objects f and ff, for ',fnall{ii}])
        eval(['f=',fnall{ii},';'])
        plot(f)
        dat=iddata(f); %figure(1), plot(dat)
        ff=fiddata(dat); figure(2), plot(ff), %pause
        f.SiSoVariance=[]; f.covariancematrix=[]; ff.SiSoVariance=[];
        f.notes=''; ff.notes='';
        if isempty(f.inputname)&isempty(f.outputname)
          f.names=''; ff.names=''; 
        end
        f.history=''; ff.history='';
        f.synchronization='';
        if isempty(f.periodlength)|isnan(f.periodlength)
          f.periodlength=[]; 
          if isnan(ff.periodlength), ff.periodlength=[]; end
        end
        if isstr(ff.inputcharacter)&strcmp(ff.inputcharacter,'AASamples')
          ff.inputcharacter='BL';
        end
        f.frequencies={};
        fp=f.allfreqpoints; ffp=ff.allfreqpoints;
        if isnumeric(fp)&(abs(fp-ffp)<100*eps*fp), ff.freqpoints=fp; end
        f.fs=[]; ff.fs=[];
        if isempty(get(f,'ExperimentName'))
          set(f,'ExperimentName','')
        end
        set(f,'character',get(f,'character')) %Change AASamples to BL
        set(ff,'ExperimentName','')
        if isa(f,'fiddata'), f.M=[]; ff.M=[]; end 
        f.date=''; ff.date='';
        diff(f,ff)
        if ~isequal(f,ff)
          save
          error(['Converted data differ: ',fnall{ii}])
        end
      end %for ii
      %
      disp('File to fiddata object')
      expfou([1:5]',randn(5,1),randn(5,1),1,1,'tmp.fou');
      if str2num(ver(1:3))>=3.1, obj=fiddata('tmp.fou'); end
      delete tmp.fou
      %
      disp('Comparing artificial objects')
      f=fiddata([1:5]',[1:5]',[1,2,4,5,6]');
      dat=iddata(f);
      df=fiddata(dat);
      df.names={}; f.names={}; df.history=''; 
      df.inputunit=''; df.outputunit='';
      f.inputunit=''; f.outputunit='';
      if isstr(df.inputcharacter)&strcmp(df.inputcharacter,'AASamples')
        df.inputcharacter='BL';
      end
      df.ExperimentName='';
      f.date=''; df.date='';
      diff(f,df)
      if ~isequal(f,df)
        error('iddata objects differ')
      end
    end %tiddata/fiddata
    if ishandle(2), close 2, end
    if ishandle(3), close 3, end
  end %exist iddata
  %
  %Test groups
  htestgroups(objtype)
  %
  if strcmp(objtype,'fiddata') %FIDDATA test
    %MIMO variance handling
    testmimo %test mimo objects
    testmimovar %test variance handling in mimo objects
    testdecouple
    %
    %Test frf
    testfrf %test frf method  
  end
  %
  testplots(objtype)
  %
  %Tests of export
  if strcmp(objtype,'tiddata') %TIDDATA test
    load robotarm
    s=export(robotarm_rawdata); ds=tiddata(s);
    disp('Test of tiddata is OK')
  else %fiddata
    load robotarm
    s=export(f); ds=fiddata(s);
    disp('Test of fiddata is OK')
  end
end %for objtype
%
echo off
%dbclear if warning, dbclear if error
%
%end testiddat.m
