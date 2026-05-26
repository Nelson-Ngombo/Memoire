function infstr=info(obj)
%INFO  Display information on the object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 03-Mar-2001

tabs=''; infoarr='';
cl=class(obj);
infoarr=sprintf([cl,' object\n']);
if isa(obj,'tiddata')
  fs=1/get(obj,'ts');
elseif isa(obj,'fiddata')
  fs=get(obj,'fs');
else
  error('info is not available for iddat objects')
end
time=get(obj,'date');
infoarr=sprintf('%s\nDate: %s',infoarr,time);

if isa(obj,'tiddata')
  atype='time';
  tv=get(obj,'SamplingInstants');
  if isempty(tv)
    tv=[0:get(obj,'samplen')-1]'*get(obj,'ts');
  end
  fs=1/get(obj,'ts');
  Tr=length(tv)*get(obj,'ts');
  fv=get(obj,'frequencies');
elseif isa(obj,'fiddata')
  atype='frequency';
  fv=get(obj,'frequencies');
  fp=get(obj,'freqpoints');
end
charr=get(obj,'channels');
infoarr=sprintf('%s\n%s\n', infoarr,'Channel characteristics:');
for ii=1:size(charr,1)
  infoarr=sprintf('%s%s\n', infoarr, ['   ',deblank(charr(ii,:))]);
end
infoarr=sprintf('%s%sParameters:\n', infoarr, tabs);

if strcmp(atype,'time')
  infoarr=sprintf('%s%s   Record length: %.4g s\n', infoarr, tabs,Tr);
  synch=get(obj,'Synchronization');
  if isempty(synch), synch='not given'; end
  if get(obj,'expn')>1
    infoarr=sprintf('%s%s   Synchronization among experiments: %s\n',...
      infoarr, tabs, synch);
  end
  if ~isempty(get(obj,'Reference'))
    infoarr=sprintf('%s%s   Reference signals are given\n', infoarr, tabs);
  end
  infoarr=sprintf('%s%s   Sampling frequency: %.4g Hz\n', infoarr, tabs, fs);
  pl=get(obj,'periodlength');
  if isempty(pl)&~isempty(fv), pl=1/dfcalc(fv); end
  if ~isempty(pl)
    dfi=1/pl;
    infoarr=sprintf('%s%s   Period length: %.4g s, periods: %.0f\n', infoarr, tabs,...
      pl,Tr/pl);
    infoarr=sprintf('%s%s   Frequency resolution in DFT of a period: %.4g Hz\n',...
      infoarr, tabs, 1/pl);
  else
    dfi=1/Tr;
    infoarr=sprintf('%s%s   Frequency resolution in DFT of the record: %.4g Hz\n',...
      infoarr, tabs, 1/Tr);
  end
  if ~isempty(fv)
    if isnumeric(fv)
      infoarr=sprintf('%s%s   Excited frequencies: %.0f, from %.4g Hz to %.4g Hz\n', infoarr, tabs,...
        length(fv),min(fv), max(fv));
      dfifv=dfcalc(fv);
      infoarr=sprintf('%s%s   Frequency steps in excitation: %.4g Hz, max. harmonic number: %.0f\n',...
        infoarr, tabs, dfifv, max(fv)/dfifv);
      dfistr=sprintf('%.0f',round(fv(1)/dfi));
      dnum=4; %show dnum indices
      for ii=2:min(dnum,length(fv))
        dfistr=[dfistr,sprintf(', %.0f',fv(ii)/dfi)];  
      end
      if length(fv)>dnum, dfistr=[dfistr,', ...']; end
      if ~isempty(pl)
        infoarr=sprintf('%s%s   Harmonic numbers in DFT of period: %s\n',...
          infoarr, tabs, dfistr);
      elseif ~isemtpy(Tr)
        infoarr=sprintf('%s%s   Harmonic numbers in DFT of record: %s\n',...
          infoarr, tabs, dfistr);
      end
    else
      infoarr=sprintf('%s%s   Frequencies: %.0f x %.0f cell\n', infoarr, tabs,...
        size(fv,1),size(fv,2)); 
    end
  end
  %expno=get(obj,'expn');
  %infoarr=sprintf('%s%s   Experiments: %.0f\n', infoarr, tabs, expno);
  inp=get(obj,'input');
  if ~isempty(inp)
    if isnumeric(inp)
      infoarr=sprintf('%s%s   Input amplitudes: [%.4g,%.4g], RMS value: %.4g, max(|u|): %.4g\n',...
        infoarr, tabs, min(inp),max(inp),sqrt(mean(inp(:).^2)),max(abs(inp(:))));
    else
      infoarr=sprintf('%s%s   Input RMS values:',infoarr, tabs);
      comma='';
      for ii=1:prod(size(inp))
        infoarr=sprintf(['%s%s',comma,' %.4g'],infoarr, tabs, sqrt(mean(inp{ii}.^2)));
        comma=',';
      end
      infoarr=sprintf('%s%s\n',infoarr, tabs);
      infoarr=sprintf('%s%s      max(|u|)''s:',infoarr, tabs);
      comma='';
      for ii=1:prod(size(inp))
        infoarr=sprintf(['%s%s',comma,' %.4g'],infoarr, tabs, max(abs(inp{ii})));
        comma=',';
      end
      infoarr=sprintf('%s%s\n',infoarr, tabs);
    end
  end
  outp=get(obj,'output');
  if ~isempty(outp)
    if isnumeric(outp)
      infoarr=sprintf('%s%s   Output amplitudes: [%.4g,%.4g], RMS value: %.4g, max(|y|): %.4g\n',...
        infoarr, tabs, min(outp),max(outp),sqrt(mean(outp(:).^2)),max(abs(outp(:))));
    else
      infoarr=sprintf('%s%s   Output RMS values:',infoarr, tabs);
      comma='';
      for ii=1:prod(size(outp))
        infoarr=sprintf(['%s%s',comma,' %.4g'],infoarr, tabs, sqrt(mean(outp{ii}.^2)));
        comma=',';
      end
      infoarr=sprintf('%s%s\n',infoarr, tabs);
      infoarr=sprintf('%s%s      max(|y|)''s:',infoarr, tabs);
      comma='';
      for ii=1:prod(size(outp))
        infoarr=sprintf(['%s%s',comma,' %.4g'],infoarr, tabs, max(abs(outp{ii})));
        comma=',';
      end
      infoarr=sprintf('%s%s\n',infoarr, tabs);
    end
  end
elseif strcmp(atype,'frequency')
  %fs=get(obj,'fs'); if ~isempty(fs), fsstr=sprintf(', fs = %.4g Hz',fs); else fsstr=''; end
  if isnumeric(fp)
    infoarr=sprintf('%s%s   Frequencies: %.0f, from %.4g Hz to %.4g Hz\n', infoarr, tabs,...
      length(fp),min(fp), max(fp));
    dfi=dfcalc(fp);
    infoarr=sprintf('%s%s   Frequency steps: %.4g Hz, max. harmonic number: %.0f\n',...
      infoarr, tabs, dfi, max(fp)/dfi);
    %expno=get(obj,'expn');
    %infoarr=sprintf('%s%s   Experiments: %.0f\n', infoarr, tabs, expno);
  else
    infoarr=sprintf('%s%s   Frequencies: %.0f x %.0f cell\n', infoarr, tabs,...
      size(fp,1),size(fp,2)); 
  end
  if ~isempty(fv)&~isequal(fv,fp)
    if isnumeric(fv)
      infoarr=sprintf('%s%s   Excited frequencies: %.0f, from %.4g Hz to %.4g Hz\n', infoarr, tabs,...
        length(fv),min(fv), max(fv));
      dfi=dfcalc(fv);
      infoarr=sprintf('%s%s   Frequency steps in excitation: %.4g Hz, max. harmonic number: %.0f\n',...
        infoarr, tabs, dfi, max(fv)/dfi);
      %expno=get(obj,'expn');
      %infoarr=sprintf('%s%s   Experiments: %.0f\n', infoarr, tabs, expno);
    else
      infoarr=sprintf('%s%s   Excited frequencies: %.0f x %.0f cell\n', infoarr, tabs,...
        size(fv,1),size(fv,2));
    end
  end
  synch=get(obj,'Synchronization');
  if isempty(synch), synch='not given'; end
  if get(obj,'expn')>1
    infoarr=sprintf('%s%s   Synchronization among experiments: %s\n',...
      infoarr, tabs, synch);
  end
  if ~isempty(get(obj,'Reference'))
    infoarr=sprintf('%s%s   Reference signals are given\n', infoarr, tabs);
  end
  if ~isempty(get(obj,'Fs'))
    infoarr=sprintf('%s%s   Time domain sampling frequency: %.0f Hz\n',...
      infoarr,tabs,get(obj,'Fs'));
  end
  infoarr=sprintf('%s%s   Variances: %s\n', infoarr, tabs, varinfo(obj));    
  M=get(obj,'M');
  if ~isempty(M)
    if M>=4
      infoarr=sprintf('%s%s   %.0f experiments (segments) were processed\n',...
        infoarr, tabs, M);        
    else
      infoarr=sprintf('%s%s   %.0f experiments (segments) were processed - WARNING: at least 4 experiments should have been\n',...
        infoarr, tabs, M);        
    end
  end
  if ~isempty(get(obj,'outputNonlinErr'))
    infoarr=sprintf('%s%s   Nonlinear errors: %s\n', infoarr, tabs, varinfo(nonlinvar2var(obj)));
  end
  NonlinM=get(obj,'NonlinM');
  if ~isempty(NonlinM)
    if NonlinM>=6
      infoarr=sprintf('%s%s   %.0f experiments were processed for nonlinear analysis\n',...
        infoarr, tabs, NonlinM);        
    else
      if isempty(get(obj,'OddOutputNonlinError'))|~isequal(NonlinM,2)
        infoarr=sprintf(['%s%s   %.0f experiments were processed for nonlinear analysis - \n',...
          '   WARNING: at least 6 experiments should have been necessary\n'],...
          infoarr, tabs, NonlinM);
      else
        infoarr=sprintf(['%s%s   Interpolation is equivalent to processing only %.0f experiments for nonlinear analysis - \n',...
          '   WARNING: at least 6 experiments would be necessary\n'],...
          infoarr, tabs, NonlinM);
      end
    end
  end
  Ref=get(obj,'Reference'); if ~iscell(Ref), Ref={Ref}; end
  if ~isempty(Ref)
    infoarr=sprintf('%s%s   %.0f reference amplitude sets are given\n',...
      infoarr, tabs, length(Ref));        
  end
end
%
notes=get(obj,'notes');
history=get(obj,'history');
if ~isempty(notes)
  if isstr(notes)
    infoarr=sprintf('%sNotes:\n', infoarr);
    for ii=1:size(notes,1)
      notesii=notes(ii,:);
      infoarr=sprintf('%s%s%s   %s\n', infoarr, tabs, tabs, notesii);
    end %for ii
  elseif iscell(notes)
    infoarr=sprintf('%sNotes:\n', infoarr);
    for ii=1:size(notes,1)
      notesii=notes{ii};
      if isstr(notesii)
        infoarr=sprintf('%s%s%s   %s\n', infoarr, tabs, tabs, notesii);
      end
    end %for ii
  end
end
if ~isempty(history)
   infoarr=sprintf('%s%sHistory:\n',infoarr, tabs);
   if iscell(history)
      for ix=1:length(history)
         infoarr=sprintf('%s%s   %s\n', infoarr, tabs, history{ix});
      end
   else
      infoarr=sprintf('%s%s   %s\n', infoarr, tabs, history);
   end
end
%
if nargout>=1
  infstr=infoarr;
else
  helpwin(infoarr,'Information on object')
end

function infostr=varinfo(data)
%VARINFO Textual information about variance contents of object

if isa(data,'fiddata')
   var=get(data,'sisovariance');
   if iscell(var), var=cat(1,var{:}); end
   if size(var,2)==3, cuy=var(:,3); var=var(:,1:end); else cuy=[]; end
   infostr='';
 elseif isa(data,'tiddata')
   infostr=''; return
end
if ~isempty(var)
  if size(var,2)>=2
    if all(var(:,2)==0), vutxt='vu=0'; else vutxt='vu'; end
    if all(var(:,1)==0), vytxt='vy=0'; else vytxt='vy'; end
    infostr=[infostr,vytxt,', ',vutxt];
  else
    if all(var(:,1)==0), vytxt='vy=0'; else vytxt='vy'; end
    infostr=[infostr,', ',vytxt,'vu=[]'];
  end
  if ~isempty(cuy)
    if all(cuy(:,1)==0), cuytxt='cuy=0'; else cuytxt='cuy'; end
    infostr=[infostr,', ',cuytxt];
  else infostr=[infostr,', cuy=[]'];
  end
elseif ~isempty(get(data,'coherence'))
  infostr=[infostr,sprintf('Coherence in [%.2f,%.2f]',...
      min(get(data,'coherence')),max(get(data,'coherence')))];
else %empty var, empty coherence
  infostr=[infostr,'No variance given'];
end

%End of file @iddat/info
