function infstr=info(models,userlevel)
%INFO  Display information on fit of model to data
%
%       userlevel: 'automatic', 'interactive', or 'advanced', default: 'automatic'
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1999-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 16-Dec-2002

if nargin<2, userlevel=''; end
if strncmp(userlevel,'Poles and zeros',4), userlevel=''; pzlist=1;
else pzlist=0;
end
tabs=''; infstri='';
n=prod(size(models));
if n>1
  infstri=sprintf('fidmodel array, %.0f x %.0f\n\n',size(models,3),size(models,4));
else
  infstri=sprintf('fidmodel object\n\n');
end
%
for mii=1:n
  model=models(mii);
  if mii>1, infstri=sprintf('%s\n',infstri); end
  if n>1, infstri=sprintf('%s%sModel #%.0f\n',infstri, tabs, mii); end
  infstri=sprintf('%s%sDate: %s\n',infstri, tabs, model.date);
  %
  notesm=get(model,'notes'); if isempty(notesm), notesm=''; end
  if iscell(notesm), notesm=cat(2,notesm{:}); end
  if size(notesm,1)>1, notesm=notesm'; notesm=notesm(:)'; end
  notesd=get(model.data,'notes'); if isempty(notesd), notesd=''; end
  if iscell(notesd), notesd=cat(2,notesd{:}); end
  if size(notesd,1)>1, notesd=notesd'; notesd=notesd(:)'; end
  if ~pzlist
    if strncmp(get(model.data,'Type'),'NMR',3)|...
        any(findstr('nmr',lower(get(model.data,'outputname'))))|...
        any(findstr('nmr',lower(notesm)))|...      
        any(findstr('nmr',lower(notesd)))      
      ps=nmrparam(model);  
      f=ps.Frequency;
      stdf=ps.StdFreq;
      d=ps.Decay;
      stdd=ps.StdDecay;
      a=ps.Amplitude;
      stda=ps.StdAmpl;
      ph=ps.Phase;
      stdph=ps.StdPhase;
      %
      infstri=sprintf(['%s%s\n'], infstri, sprintf('\nNMR data, %.0f peaks',length(f)));
      infstri=sprintf(['%s%s\n'], infstri,...
        'Frequencies                   Decays                    Amplitudes                Phases');
      for ii=1:length(f)
        infstri=sprintf(['%s%s\n'], infstri, ...
          sprintf(['%+.3e ',setstr(177),' %.3e Hz',...
            '   %.3e ',setstr(177),' %.3e',...
            '   %.3e ',setstr(177),' %.3e',...
            '   %+6.1f ',setstr(177),' %4.1f deg'],...
          f(ii),stdf(ii),d(ii),stdd(ii),a(ii),stda(ii),ph(ii),stdph(ii)));
      end %for ii
      infstri=sprintf(['%s\n'], infstri);
    end
  end
  %  
  num=model.num;
  denom=model.denom;
  domain=model.variable;
  if any(findstr(domain,'z'))
    delunit='samples';
    fs=model.fs;
  else
    delunit='s';
  end
  if isempty(num), numstr='[]'; else numstr=num2str(length(num)-1); end
  if isempty(denom), denomstr='[]'; else denomstr=num2str(length(denom)-1); end
  order=[numstr '/' denomstr];
  delay=get(model,'delay');
  if ~isstable(model), unsttxt=', unstable'; else unsttxt=' '; end
  if strcmp(get(model,'Coefficients'),'complex'), cmplxtxt=', complex parameters';
  else cmplxtxt='';
  end
  infstri=sprintf('%s%sOrder: %s%s%s\n', ...
    infstri, tabs, order, cmplxtxt,unsttxt);
  infstri=sprintf('%s%sDomain: %s', infstri,tabs, domain);
  repr=model.representation;
  if ~strcmp(repr,'polynomial')
    if ~pzlist
      infstri=sprintf('%s, representation: %s', infstri, repr);
    end
    sctxt=' (unscaled)';
  else
    sctxt='';
  end
  if ~pzlist
    if any(findstr(domain,'z'))
      infstri=sprintf('%s, sampling frequency: %.4g Hz\n', infstri, fs);
    else
      infstri=sprintf('%s\n', infstri);     
    end
    if ~isempty(model.ntr)
      infstri=sprintf('%s%sTransients are modeled\n', infstri, tabs);
    end
    if ~isempty(delay)
      if any(findstr(repr,'orthopol'))&(domain=='s')
        %delay=delay/get(model,'fscale');
        infstri=sprintf('%s%sScaling frequency of the bases and the delay: %g Hz (fscale)\n',...
          infstri, tabs, get(model,'fscale'));
        infstri=sprintf('%s%sDelay: %g %s (unscaled value, independent of fscale)\n',...
          infstri, tabs, delay, delunit);
      else
        infstri=sprintf('%s%sDelay: %g %s\n', infstri, tabs, delay, delunit);
      end  
    end
    in=model.inputname;
    if ~isempty(in)
      if iscell(in), in=in{1}; end
      infstri=sprintf('%s%sInputname: %s', infstri, tabs, in);
    end
    on=model.outputname;
    if ~isempty(on)
      if iscell(on), on=on{1}; end
      infstri=sprintf('%s%s   Outputname: %s  ', infstri, tabs, on);
    end
    if ~isempty(in)|~isempty(on)
      infstri=sprintf('%s\n', infstri);
    end
  else
    infstri=sprintf('%s\n', infstri);     
  end
  if (fdident('private','fdcfs','lic')>1) 
    if ~isempty(model.covariance)&...
        (strcmp(repr,'polynomial')|~isempty(model.data))&...
        ~strcmp(get(model,'coefficients'),'complex')
      zpkdata=stdpz(model);
      zerov=zpkdata.zv;
    else
      if strcmp(repr,'polynomial')
        zerov=roots(num);
      else %orthopol
        fs=model.fs;
        zerov=fdident('private','ortroots',num,model.Znum)*fs;
      end
    end
    if strcmp(domain,'s'), fdim='radHz';
    elseif strcmp(domain,'w'), fdim='sqrt(radHz)';
    else fdim='';
    end
    infstri=sprintf('%s%sZeros%s (with positions also given in Hz):\n', infstri, tabs,sctxt);
    for ii=1:length(zerov)
      if imag(zerov(ii))==0
        infstri=sprintf(['%s%s   %+.4e ',fdim,'\n'], infstri, tabs, zerov(ii));
      else %complex
        infstri=sprintf(['%s%s   %+.4e %+.4e*j ',fdim], infstri, tabs,...
          real(zerov(ii)),imag(zerov(ii)));
        if (strcmp(domain,'s')|strncmp(domain,'z',1))&...
            (strcmp(get(model,'coefficient'),'complex')|(imag(zerov(ii))>0))
          stdf=[];
          if strcmp(domain,'s')
            fHz=sprintf('%+.5g',imag(zerov(ii))/(2*pi));
            if exist('zpkdata'), stdf=zpkdata.stdz(ii,2); end
          elseif strncmp(domain,'z',1)
            fHz=sprintf('%+.5g',angle(zerov(ii))/(2*pi)*fs);
            if exist('zpkdata')
              stdz=zpkdata.stdz(ii,:);
              C=zeros(2,2);
              C(1,1)=stdz(1); C(2,2)=stdz(2);
              C(1,2)=stdz(3)*sqrt(stdz(1)*stdz(2)); C(2,1)=C(1,2);
              v=zerov(ii)*j; v=v/norm(v);
              stdf=norm(C*[real(v);imag(v)])/(2*pi)*fs;
            end
          end
          if ~isempty(stdf)
            infstri=sprintf(['%s%s   (%s ',setstr(177),' %.5g Hz)\n'], infstri, tabs,...
              fHz,stdf); 
          else
            infstri=sprintf(['%s%s   (%s Hz)\n'], infstri, tabs,fHz);        
          end
        elseif strcmp(domain,'w')&(imag(zerov(ii)^2)>0)
          infstri=sprintf(['%s%s   (%.5g Hz)\n'], infstri, tabs,...
            imag(zerov(ii)^2)/(2*pi));
        else
          infstri=sprintf(['%s%s\n'], infstri, tabs);
        end
      end
    end
    infstri=sprintf('%s%sPoles%s (with positions also given in Hz): \n', infstri, tabs,sctxt);
    if exist('zpkdata')
      polev=zpkdata.pv;
    else
      if strcmp(model.representation,'polynomial')
        polev=roots(denom);
      else %orthopol
        fs=model.fs;
        polev=fdident('private','ortroots',denom,model.Zdenom)*fs;
      end
    end
    for ii=1:length(polev)
      unsttxt='';
      if (strcmp(domain,'w')&(abs(angle(polev(ii)))<=pi/4)) |...
        (strcmp(domain,'s')&(real(polev(ii))>=0)) |...
        (strcmp(domain,'z')&(abs(polev(ii)))>=1)
        unsttxt='   unstable'; 
      end
      if imag(polev(ii))==0
        infstri=sprintf(['%s%s   %+.4e ',fdim,'%s\n'], infstri, tabs, polev(ii),unsttxt);
      else %complex
        infstri=sprintf(['%s%s   %+.4e %+.4e*j ',fdim], infstri, tabs,...
          real(polev(ii)),imag(polev(ii)));
        if (strcmp(domain,'s')|strncmp(domain,'z',1))&...
            (strcmp(get(model,'coefficient'),'complex')|(imag(polev(ii))>0))
          stdf=[];
          if strcmp(domain,'s')
            fHz=sprintf('%+.5g',imag(polev(ii))/(2*pi));
            if exist('zpkdata'), stdf=zpkdata.stdp(ii,2); end
          elseif strncmp(domain,'z',1)
            fHz=sprintf('%+.5g',angle(polev(ii))/(2*pi)*fs);
            if exist('zpkdata')
              stdp=zpkdata.stdp(ii,:);
              C=zeros(2,2);
              C(1,1)=stdp(1); C(2,2)=stdp(2);
              C(1,2)=stdp(3)*sqrt(stdp(1)*stdp(2)); C(2,1)=C(1,2);
              v=polev(ii)*j; v=v/norm(v);
              stdf=norm(C*[real(v);imag(v)])/(2*pi)*fs;
            end
          end
          if ~isempty(stdf)
            infstri=sprintf(['%s%s   (%s ',setstr(177),' %.5g Hz)%s\n'], infstri, tabs,...
              fHz,stdf,unsttxt); 
          else
            infstri=sprintf(['%s%s   (%s Hz)%s\n'], infstri, tabs,fHz,unsttxt);        
          end
        elseif strcmp(domain,'w')
          if imag(polev(ii)^2)>0
            infstri=sprintf(['%s%s   (%.5g Hz)%s\n'], infstri, tabs,...
              imag(polev(ii)^2)/(2*pi),unsttxt);
          else
            infstri=sprintf(['%s%s%s\n'], infstri, tabs, unsttxt);
          end
        else
          infstri=sprintf(['%s%s%s\n'], infstri, tabs,unsttxt);
        end
      end
    end
    if ~pzlist
      infstri=sprintf(['%s%sDC gain: %.3g \n'], infstri, tabs,tfcalc(model,0));
    end
  else
    pmg=[80,111,108,101,115, 32, 97,110,100, 32,122,101,114,111,115, 32,119,105,108,108,32,...
        98,101, 32,108,105,115,116,101,100, 32,104,101,114,101,32,105,110, 32,116,104,101,32,...
        108,105,99,101,110,115,101,100, 32,116,111,111,108,98,111,120,32,118,101,114,115,105,111,110,46];
    pmg=setstr(pmg);
    infstri=sprintf(['%s%s%s\n'], infstri, tabs,pmg);
  end
  %
  if ~pzlist
    fitinfo=model.fitinfo;
    if ~isempty(fitinfo)
      if isstruct(fitinfo)
        cf=fitinfo.cf;
        if ~isnan(cf), cfth=fitinfo.cfth; AIC=fitinfo.AIC; mmerror=fitinfo.mmerror;
          condnum=fitinfo.condnum;
          try, MDL=fitinfo.MDL; catch, MDL=NaN; end
        else cfth=NaN; AIC=NaN; mmerror=NaN; MDL=NaN; condnum=NaN;
        end
      else
        warning('Old form of fitinfo found')
        cf=fitinfo(1); cfth=fitinfo(2); AIC=fitinfo(12); mmerror=fitinfo(10);
        condnum=fitinfo(13);
        MDL=NaN;
      end
      infstri=sprintf('%s%sFit info: \n', infstri, tabs);
      if isfield(fitinfo,'errorweighting')&strncmpi(fitinfo.errorweighting,'nonlinear',4)
        M=get(model.data,'NonlinM');
      else
        M=get(model.data,'M');
      end
      if ~isempty(M)
        infstri=sprintf('%s%s   Cost Fcn: %.4g, theoretical expected value, N/2*(M-1)/(M-2): %.4g\n', infstri, tabs, cf,cfth);
        infstri=sprintf('%s%s   Number of experiments used earlier to determine variances, M: %.0f\n', infstri, tabs,M);
      else
        infstri=sprintf('%s%s   Cost Fcn: %.4g, theoretical expected value: %.4g\n', infstri, tabs, cf,cfth);
      end
      if strcmpi(userlevel,'advanced')
        infstri=sprintf('%s%s   Condition number: %.2e\n', infstri, tabs, condnum);
      end
      infstri=sprintf('%s%s   Akaike, cf*(1+Nfp/F): %.4g\n', infstri, tabs, AIC);
      if ~isnan(MDL)
        mix=2;
        if ~isempty(model.data)
          varx=model.data.inputvariance;
          if (isnumeric(varx)&any(varx))|(iscell(varx)&any(varx{1})), mix=4; end
        else
          mix=4;
        end
        infstri=sprintf('%s%s   MDL, cf*(1+Nfp/(2F)*ln(%.0fF)): %.4g\n', infstri, tabs, mix, MDL);
      end
      F=model.fitinfo.F;
      %F=get(model.data,'freqnumber');
      Nfp=model.fitinfo.freepar;
      %Nfp=round((AIC/cf-1)*F);
      N=2*F-Nfp;
      %N=2*cfth; Nfp=N-2*F;
      infstri=sprintf(['%s%s   Frequencies, F = %.0f \nFree parameters, Nfp = %.0f \n',...
          'Degrees of freedom, N = 2*F-Nfp = %.0f\n'], infstri, tabs,F, Nfp,N);
      if imag(mmerror), mmerror=NaN; end
      infstri=sprintf('%s%s   Mean model error: %.4g\n', infstri, tabs, mmerror);
    end
    if ~isempty(model.notes)
      infstri=sprintf('%s%s   Notes: %s\n', infstri, tabs, model.notes);
    end
    if ~isempty(model.data)
      charr=model.data.channels;
      infstri=sprintf('%s%s\n', infstri,'Channel characteristics in data:');
      for ii=1:size(charr,1)
        infstri=sprintf('%s%s\n', infstri, ['   ',deblank(charr(ii,:))]);
      end
    end
    M=get(model.data,'M');
    if ~isempty(M)
      infstri=sprintf('%s%s   Variances were calculated from M = %.0f experiments (segments).\n', infstri, tabs, M);
    end
    NonlinM=get(model.data,'NonlinM');
    if ~isempty(NonlinM)
      infstri=sprintf('%s%s   Nonlinear errors" were calculated from NLM = %.0f experiments.\n', infstri, tabs, NonlinM);
    end
  end
end %for mii
%
if nargout>=1
  infstr=infstri;
else
  helpwin(infstri,'Information on model')
end

%End of @fidmodel/info
