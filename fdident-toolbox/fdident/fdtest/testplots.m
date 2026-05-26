function testplots(objtype)
%TESTPLOTS Make test plots for plot/ploteltf
%
%       testplots(objtype)
%       objtype = 'fiddata', 'fidmodel' or cell array of 

disp('Test file testplots')
if nargin<1, objtype=''; end
if isempty(objtype), objtype={'fiddata','fidmodel'}; end
if isstr(objtype), objtype={objtype}; end
if ~iscell(objtype), error('objtype is not allowed'), end
for ot=objtype
  ot=ot{1};
  disp(['Plots for model type ''',ot,''''])
  if strncmp(ot,'tiddata',4)
    disp(' ')
    disp('Time domain plots')
    for arg={2*pi*[1:10]'/10,2*pi*[0:10]'/11};
      arg=arg{1};
      for chans={'i','o','io'};
        chans=chans{1};
        if strcmp(chans,'i'), id=sin(arg); od=[];
        elseif strcmp(chans,'o'), od=cos(arg); id=[];
        elseif strcmp(chans,'io'), od=cos(arg); id=sin(arg);
        end
        for ch={'BL','ZOH','ZOHf','Samples','Discrete','FOH'}
        %for ch={'FOH'}
          ch=ch{1}; cho=ch;
          if any(strmatch(cho,{'ZOH','ZOHf','FOH'}))&isempty(id)
            %nothing to plot
          else
            if any(strmatch(cho,{'ZOH','ZOHf','FOH'}))&~isempty(id)
              cho='Samples'; %this is the reasonable change
            end
            t=tiddata(od,id,0.1);
            dtxt=['  channels: ',chans];
            if ~isempty(id), set(t,'inputcharacter',ch), dtxt=[dtxt,', inputcharacter: ',ch]; end
            if ~isempty(od), set(t,'outputcharacter',cho), dtxt=[dtxt,', outputcharacter: ',cho]; end
            dtxt=[dtxt,sprintf(', N = %.0f',length(arg))];
            disp(dtxt)
            plot(t), drawnow, shg
            pause
            tt=merge(t,t,t);
            disp([dtxt,', experiments: 3'])
            plot(tt), drawnow, shg
            pause
          end
        end %for ch
      end %for chans
    end %for arg
  elseif strncmp(ot,'fiddata',4)
    disp(' ')
    disp(sprintf('Plots for data type 1: y/u = 20 dB/0 dB, vy/vu = -20 dB/0, nonlin: 0 dB/0'))
    f=fiddata(10*ones(9,1),1*ones(9,1),[1:9],0.01*ones(9,1),zeros(9,1));
    f.M=2;
    f.outputNonlinErr=1*ones(9,1);
    f.inputNonlinErr=0*ones(9,1);
    f.nonlinM=6;
    for msc=['+-=&#SNsn*@12','.']  
      if strcmp(msc,'.'), msc=''; end
      disp(['plot for modifier ''',msc,''', ',msctxt(msc)])
      plot(f,msc), drawnow, shg
      pause
    end
    disp('plot with no modifier')
    plot(f), drawnow, shg
    pause
    hm=findobj(0,'tag','fdident_object_plot_menu');
    cbs=get(get(hm,'children'),'callback');
    disp('Tests of callbacks of the plot type menu')
    for ii=length(cbs):-1:1, eval(cbs{ii}), drawnow, pause, end
    %
    disp(' ')
    disp(sprintf('Ploteltf plots for data type 1: y/u = 20 dB/0 dB, vy/vu = -20 dB/0, nonlin: 0 dB/0'))
    vardata=f.SiSoVariance; f.SiSoVariance=[];
    for msc=['+-=&SNsn*@12','.']  
      if strcmp(msc,'.'), msc=''; end
      disp(['plot for modifier ''',msc,''', ',msctxt(msc)])
      ploteltf([],[],f,[],msc,vardata), drawnow, shg
      %save matlab
      pause
    end
    clear f vardata
    %
    disp(' ')
    disp(sprintf('Plots for data type 2: y/u = 0 dB/20 dB, vy/vu = 0/-20 dB, nonlin: 0/0 dB'))
    f2=fiddata(1*ones(9,1),10*ones(9,1),[1:9],zeros(9,1),0.01*ones(9,1));
    f2.M=2;
    f2.outputNonlinErr=0*ones(9,1);
    f2.inputNonlinErr=1*ones(9,1);
    f2.nonlinM=6;
    for msc=['+-=&#SNsn*@12','.']  
      if strcmp(msc,'.'), msc=''; end
      disp(['plot for modifier ''',msc,''', ',msctxt(msc)])
      plot(f2,msc), drawnow, shg
      pause
    end
    disp('plot with no modifier')
    plot(f2), drawnow, shg
    pause
    disp(' ')
    disp(sprintf('Ploteltf plots for data type 2: y/u = 0 dB/20 dB, vy/vu = 0/-20 dB, nonlin: 0/0 dB'))
    vardata2=f2.SiSoVariance; f2.SiSoVariance=[];
    for msc=['+-=&SNsn*@12','.']  
      if strcmp(msc,'.'), msc=''; end
      disp(['plot for modifier ''',msc,''', ',msctxt(msc)])
      ploteltf([],[],f2,[],msc,vardata2), drawnow, shg
      pause
    end
    clear f2 vardata2
    %
  elseif strncmp(ot,'fidmodel',4)|strncmp(ot,'model',1)
    disp(' ')
    disp(sprintf('Plots for data type 1: y/u = 20 dB/0 dB, vy/vu = -20 dB/0, nonlin: 0 dB/0'))
    f=fiddata([12;10*ones(7,1);12],1*ones(9,1),[1:9],0.01*ones(9,1),zeros(9,1));
    f.M=4;
    f.outputNonlinErr=1*ones(9,1);
    f.inputNonlinErr=0*ones(9,1);
    f.nonlinM=6;
    m=elis(f,'s',0,0,struct('plotdens',inf,'plot0','off'),struct('displaymessages','off'));
    for msc=['+-=&#SNsn*@12','mvcrabdAB','.']
      if strcmp(msc,'.'), msc=''; end
      disp(['plot for modifier ''',msc,''', ',msctxt(msc)])
      plot(m,msc), drawnow, shg
      %save matlab
      pause
    end
    disp('plot with no modifier')
    close all, plot(m), drawnow, shg
    %
    hm=findobj(0,'tag','fdident_object_plot_menu');
    cbs=get(get(hm,'children'),'callback');
    disp('Tests of callbacks of the plot type menu')
    for ii=length(cbs):-1:1, eval(cbs{ii}), drawnow, pause, end
  else
    error(['Invalid model type ',ot])
  end
end

function mst=msctxt(msc)
% +-=&#%SNsn*
mst='';
if strcmp(msc,'+')
  mst='amplitude only plot';
elseif strcmp(msc,'-')
  mst='phase only plot';
elseif strcmp(msc,'=')
  mst='amplitude and phase plot';
elseif strcmp(msc,'&')
  mst='input/output plot';
elseif strcmp(msc,'#')
  mst='input/output plot with variances, no nonlin';
elseif strcmp(msc,'%')
  mst='input/output plot with variances, and nonlin';
elseif strcmp(msc,'S')
  mst='FRF plot with SNR';
elseif strcmp(msc,'N')
  mst='FRF plot with NSR';
elseif strcmp(msc,'s')
  mst='input/output plot with SNR';
elseif strcmp(msc,'n')
  mst='input/output plot with NSR';
elseif strcmp(msc,'*')
  mst='Default: FRF plot with variances, also nonlin; for models, model+FRF+error';
elseif isempty(msc)
  mst='Default: same as *';
elseif strcmp(msc,'m')
  mst='parametric model only';
elseif strcmp(msc,'v')
  mst='model + FRF + variances';
elseif strcmp(msc,'c')
  mst='parametric model + standard deviations';
elseif strcmp(msc,'r')
  mst='parametric model + FRF + residuals';
elseif strcmp(msc,'a')
  mst='parametric model + standard deviations + residuals + 50%-95% bounds';
elseif strcmp(msc,'d')
  mst='parametric model + standard deviations + residuals + 50%-95% bounds';
elseif strcmp(msc,'b')
  mst='parametric model + standard deviations + residuals + 50%-95% bounds + nonlinear if any';
elseif strcmp(msc,'A')
  mst='numerator and denominator from model';
elseif strcmp(msc,'B')
  mst='numerator and denominator from model';
elseif strcmp(msc,'@')
  mst='nonlinear or linear errors of experiment';
elseif strcmp(msc,'1')
  mst='nonlinear or linear errors of experiment, output only';
elseif strcmp(msc,'2')
  mst='nonlinear or linear errors of experiment, I/O';
else
  error(['msc = ''',msc,''' not recognized'])
end
