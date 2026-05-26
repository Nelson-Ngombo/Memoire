function msg=conv2frd
%CONV2FRD fdtool function to convert time domain data to frequency domain
%
%       See also: TIM2FOU, FCOEFFS.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Simon
%       Last modified: 31-Jul-2003, IK

msg='';
gettime('status','Conversion in progress...')
myname='convert';
Me=[myname 'fig'] ; 
% status data
statusreg=guidtard('gettime_main', ['STATUS_' myname]); 

if strcmp(get(findobj(findall(0,'type','figure','tag','gettime_main'),'tag','arr12'),...
    'visible'),'on')
  %simplified block diagram: arr12 is seen
  rawdataseen=1;
else
  rawdataseen=0;
end

% input data
if rawdataseen
  inpdata=guidtard('gettime_main', 'DATA_gotdata'); 
else
  inpdata=guidtard('gettime_main', 'DATA_segmenteddata'); 
end
%isrand=israndomized(inpdata); %check if indeed randomized
isrand=1;
if ~guiinfos('islinear')&strcmp(get(inpdata,'synchronization'),'on')&isrand
  %remove and store excitation data
  fvsave=inpdata.frequencies; df=dfcalc(inpdata);
  Np=inpdata.periodsamples;
  if isempty(Np), Np=inpdata.samplenumber; end
  allind=[max(round(min(fvsave)/df)-1,1):min(round(max(fvsave)/df)+1,floor(Np/2-1))]';
  inpdata.frequencies=allind*df;
end
if rawdataseen %segmentation skipped
  sol.command='gettime';
  sol.string='#yAutomatic conversion, elapsed time until this message: %.1f min';
  if strcmpi(guiinfos('signaltype'),'all') %use local polynomials
    method=[];
    method.moment = 3;   % internal parameter Rik to combine more freq. lines in local fit
    method.order = 2;    % degree of local polynomial
    if isempty(inpdata.periodlength), inpdata.periodlength=inpdata.samplen*inpdata.ts; end
    Fdata_local=tim2fou(inpdata);
    if isempty(inpdata.ref) %no reference adata given
      Y=Fdata_local.output.'; U=Fdata_local.input.';
      Data=struct('Y',Y,'U',U,'freq',Fdata_local.freqpoints');
      %[CY, CYm, Ym, TY, G, CvecG, M] = localpolyanal(Data, method);
      [CY, Y, TY, G, CvecG, M] = localpolyanal(Data, method);
      N=length(G);
      %Old solution with G
      %Fdat=fiddata(squeeze(G),ones(length(G),1),Fdata_local.freqpoints,squeeze(CvecG));
      Fdat=fiddata((Y.m_nt).',U.',Fdata_local.freqpoints,squeeze(CY.m_nt));
    else %data with reference
      Z=[Fdata_local.output.';Fdata_local.input.'];
      R=Fdata_local.reference.';
      Data=struct('Y',Z,'U',R,'freq',Fdata_local.freqpoints');
      % modelling from r to z
      %[CY, CZ, Ym, Tz, Gz, CvecGz, M] = localpolyanal(Data, method);  % estimate G, ...
      [CY, Y, TY, G, CvecG, M] = localpolyanal(Data, method);  % estimate G, ...
      % frf from u to y
      %[G, CvecG] = frf_eiv(Gz, CvecGz);
      Fdat=fiddata(Y.m_nt(1,:).',Y.m_nt(2,:).',Fdata_local.freqpoints,...
        squeeze(CY.m_nt(1,1,:)),squeeze(CY.m_nt(2,2,:)),squeeze(CY.m_nt(1,2,:)));
      %G = squeeze(G);
      %varG = squeeze(CvecG);
      %varY = squeeze(CZ.n(1,1,:));
      %varU = squeeze(CZ.n(2,2,:));
      %varYU = squeeze(CZ.n(1,2,:));
    end
    %
    Fdat.M=M; Fdat.fs=Fdata_local.fs;
  else %periodic
    try
      df=dfcalc(inpdata);
      N=get(inpdata,'samplenumber'); ts=get(inpdata,'Ts');
      if any(abs(rem(N*ts*df+0.3,1)-0.3)<1e-6)
        if guiinfos('islinear')|(strcmp(get(inpdata,'synchronization'),'on')&isrand)
          Fdat=tim2fou(inpdata);
        else %nonlinear
          Fdat=tim2fou(inpdata,'segment-noreduce');
          1;
        end
      else
        gettime('status','FFT not usable, automatic conversion with resampling is performed')
        [Fdat,msg]=fcoeffs(inpdata,dfcalc(inpdata),sol);
      end
    catch
      warning('tim2fou failed. Trying otherwise ...')
      %if guiinfos('isdevelopment')
      %  dbstack
      %end
      disp(lasterr)
      if isempty(df)
        Fdat=tim2fou(inpdata);
      else
        try
          Fdat=tim2fou(inpdata,'leak');
        catch
          msg=lasterr; while any(msg(end)==[10,13]), msg(end)=''; end
          ind=sort([findstr(msg,10),findstr(msg,13)]);
          if ~isempty(ind), msg=msg(ind(end)+1:end); end
          gettime('status',['Error: ',msg])
          error(lasterr)
        end
      end
    end
  end %signaltype all/periodic
  if ~isempty(msg), gettime('status',msg), end
  fp=Fdat.freqpoints; ind=find(fp==0);
  if ~isempty(ind), Fdat(ind)=[]; end
  fv=inpdata.inputfrequencies;
  if ~isempty(fv) %input frequencies given
    %Fdat=nearest(Fdat,fv);
    %
    fpl=length(Fdat.freqpoints);
    [Fdat,ranks]=nearest(Fdat,fv); %itt romlik el
    fpl2=length(Fdat.freqpoints);
    procent=sum(ranks<=fpl2)/fpl2*100;
    if ~isempty(ranks)
      msgstr=sprintf('%.0f of %.0f lines selected, %.0f%% of best %.0f lines',...
        fpl2,fpl,procent,fpl2);
      if procent>=50, gettime('status',['#y',msgstr]), pause(1)
      else gettime('status',['#r',msgstr]), pause(5)
      end
      disp(msgstr)
    end
  else %selection of good SNR
    F=Fdat.freqpoints; Fdatold=Fdat;
    if ~isempty(get(Fdat,'inputvariance'))
      dBlim=20;
      Fdat=goodsnr(Fdat,'input',dBlim);
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      while Fdat.freqnumber<min(F,10)
        dBlim=dBlim-5;
        Fdat=goodsnr(Fdatold,'input',dBlim);
      end
      if get(Fdat,'freqn')==0
        gettime('status','#yData are too noisy to be automatically select')
        error('Data are too noisy to be automatically selected')
      end
    else %no inputvariance
      dBlim=20;
      Fdat=goodsnr(Fdatold,'tf',dBlim);
      while Fdat.freqnumber<min(F,10)
        dBlim=dBlim-5;
        Fdat=goodsnr(Fdatold,'tf',dBlim);
      end
    end
  end
  fv=Fdat.freqpoints; ind=find(fv==0);
  if ~isempty(ind), Fdat(ind)=[]; end
else %usual processing, segmented data seen
  if isa(inpdata,'iddat')
    N=inpdata.samplen; fv=inpdata.frequencies;
    fs=1/inpdata.ts;
    if isempty(fv)
      fv=[0:floor((N-1)/2)]/N*fs;
    end
  end
  if ~exist('fv')
    gettime('status','Error: no input data for this block')  
    return
  end
  if any(abs(rem(fv/(fs/N)+0.5,1)-0.5)>100*N*eps)
    fmod='leak';
    msg='Segments contain noninteger periods: slow execution';
    gettime('status', ['Warning: ' msg]), drawnow
    warning(msg);
  else fmod='';
  end
  if inpdata.samplenumber<=1
    gettime('status','Error: The number of samples should be at least 2')
    error('The number of samples should be at least 2')
  end
  Fdat=tim2fou(inpdata,fmod,'coeff');
  %set(Fdat,'history',inpdata.history,'noconsistency');
  addhist(inpdata, sprintf('Conversion to freq domain done by fcoeffs/goodsnr'));
end %segmented data seen
%
if ~guiinfos('islinear')&strcmp(get(inpdata,'synchronization'),'on')&isrand
  Fdat.frequencies=fvsave;
  %if ~israndomized(Fdat), error('Randomization information is somehow lost'), end
  nonexcind=find(~ismember(Fdat.freqpoints,fvsave));
  %Ez valószínûleg felesleges?
  covvect=Fdat.covvect;
  if ~isempty(covvect)&isnumeric(covvect)
    covvect(nonexcind)=zeros(size(nonexcind));
    Fdat.covvect=covvect;
  end
  outpvar=Fdat.outputvariance;
  if ~isempty(outpvar)&isnumeric(outpvar)
    outpvar(nonexcind)=zeros(size(nonexcind));
    Fdat.outputvariance=outpvar;
  end
  inpvar=Fdat.inputvariance;
  if ~isempty(inpvar)&isnumeric(inpvar)
    inpvar(nonexcind)=zeros(size(nonexcind));
    Fdat.inputvariance=inpvar;
  end
end
set(Fdat,'history',inpdata.history,'noconsistency');
hzohc=findobj(findall(0,'type','figure','tag','gettime_main'),'tag','gettime_zoh_compensate');
if strcmp(get(hzohc,'visible'),'on')&isequal(get(hzohc,'value'),1)
  Ts=inpdata.Ts;
  data=Fdat.inputdata;
  if ~iscell(data), data={data}; end
  freqs=Fdat.inputfreqpoints;
  if ~iscell(freqs), freqs={freqs}; end
  [ic,en]=size(data);
  while size(freqs,1)<ic, freqs=[freqs;freqs(1,:)]; end
  while size(freqs,2)<en, freqs=[freqs,freqs(:,1)]; end
  for ii=1:ic*en
    if strncmp(inpdata.inputcharacter,'ZOH',3)|strcmp(inpdata.inputcharacter,'discrete')
      %ZOH to BL
      data{ii}=data{ii}.*exp(-j*2*pi*freqs{ii}*Ts/2).*...
        (sin(pi*freqs{ii}*Ts+eps)./(pi*freqs{ii}*Ts+eps));  
      if ii==1
        if Fdat.inputchnumber==1, Fdat.inputcharacter='BL'; 
        else Fdat.inputcharacter='BL';  
        end
      end %ii
    elseif strcmp(inpdata.inputcharacter,'BL')|strcmp(inpdata.inputcharacter,'Samples')
      %BL or Samples to ZOH
      data{ii}=data{ii}./exp(-j*2*pi*freqs{ii}*Ts/2)./...
        (sin(pi*freqs{ii}*Ts+eps)./(pi*freqs{ii}*Ts+eps));  
      if ii==1
        if Fdat.inputchnumber==1, Fdat.inputcharacter='ZOH'; 
        else Fdat.inputcharacter='ZOH';  
        end
      end %ii
    end
  end
  if length(data)==1, data=data{1}; end
  Fdat.inputdata=data;
  addhist(Fdat, 'Compensation for the input ZOH tf has been performed.')
end
addhist(Fdat, 'Conversion to freq domain done.')
%
guidtawr('gettime_main', 'DATA_converteddata', 'direct', Fdat);
if isempty(msg)|any(findstr('Warning',msg))|any(findstr('slow execution',msg))
  gettime('finished_box','rect_convert','done')
end
%
%End of file
