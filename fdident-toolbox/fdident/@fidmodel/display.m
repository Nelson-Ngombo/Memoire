function ord=display(model)
%DISPLAY  Displays fidmodel object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2010
%       All rights reserved.
%       $Revision: $
%       Last modified: 21-Apr-2010

if exist('@tf/display.m')&(length(model)==1)&...
    ~strcmp(model.variable,'w')&...
    ~strcmp(model.representation,'orthopol')&...
    (model.delay>=0)&(sum(size(model.num)>1)<=1)%&0
  %The last one is because control/display does not like negative delay...
  %control toolbox exists and is used
  disp([sprintf('\n%s =\n\n',inputname(1)),...
        '        ',get(model,'information')])
  %disp(' '), disp(get(model,'information'))
  if ~isempty(model.num)&~isempty(model.denom)
    try, display(tf(model)), catch, end
    if ~isempty(get(model,'ntr'))
      fprintf('\nTransient ')
      fs=get(model,'fs');
      if isempty(fs), mtf=tf(get(model,'ntr'),get(model,'denom'));
      else mtf=tf(get(model,'ntr'),get(model,'denom'),1/fs);
      end
      set(mtf,'variable',get(model,'variable'));
      if any(findstr(get(model,'variable'),'z')), set(mtf,'Ts',1/get(model,'fs')), end
      set(mtf,'num',get(model,'ntr'),'den',get(model,'denom'));
      try, display(mtf), catch, end
    end
  end
else %fdident type display
  if ~exist('@tf/display.m')
    %warning('Control toolbox is not installed')
  else
    %warning('w-domain has no pretty-print')
  end
  vtxt=''; stxt=''; atxt=''; rtxt=''; otxt=''; smtxt=''; ctxt=''; dtxt='';
  sm=size(model);
  if any([sm(3:end),1]~=1)
    stxt=sprintf(': %.0f-by-%.0f',size(model,3),size(model,4));
    for ii=5:length(sm)
      stxt=[stxt,sprintf('-by-%.0f',size(model,ii))];
    end
  end
  sm=[size(model),1];
  if prod(sm(3:end))==1
    vtxt=[model.variable,'-domain '];
    if strcmp(model(1).representation,'orthopol')
      rtxt=', orthopol';
    end
    num=get(model,'num'); if isnumeric(num), num={num}; end
    denom=get(model,'denom'); if isnumeric(denom), denom={denom}; end    
    otxt=[', '];
    for ii=1:min(prod(size(num)),5)
      if (ii==1)&(prod(size(num))>1), otxt=[otxt,'[ ']; end
      if (ii>1)&(rem(ii,size(num,2))==1), otxt=[otxt,'; ']; end
      if length(denom)>1, denomii=denom{ii}; else denomii=denom{1}; end
      if ~isempty(num{ii})
        otxt=[otxt,sprintf('%.0f',length(num{ii})-1)];
      else
        otxt=[otxt,sprintf('[]')];
      end
      if ~isempty(denomii)
        otxt=[otxt,sprintf('/%.0f ',length(denomii)-1)];
      else
        otxt=[otxt,sprintf('/[] ')];
      end
      if isempty(num{ii}), otxt=', empty tf'; end
    end
    if ii<prod(size(num)), otxt=[otxt,'... ']; end
    if prod(size(num))>1, otxt=[otxt,']']; end
    num=get(model,'num'); if isnumeric(num), num={num}; end
    if model.delay~=0
      dtxt=sprintf(', delay: %.3g ',get(model,'delay'));
      if any(findstr('z',model.variable)), dtxt=[dtxt,'samples'];
      else dtxt=[dtxt,'s'];
      end
    end
  else
    atxt=' array';
    omax=6;
    sm=[size(model),1];
    for ii=1:min(prod(sm(3:end)),omax+1)
      if ii==1, otxt=[otxt,', orders: '];
      else otxt=[otxt,', '];
      end
      if ii<=omax
        if ii==1, ms=struct(model); end
        otxt=[otxt,sprintf('%.0f/%.0f',length(ms(ii).num)-1,...
            length(ms(ii).denom)-1)];
      else
        otxt=[otxt,'...'];
      end
    end %for ii
    if ~exist('ms'), num=[]; 
    else num=ms(1).num;
    end
    if isnumeric(num), num={num}; end
  end
  if ~issiso(model), smtxt=sprintf('MIMO (O=%.0f, I=%.0f) ',size(num,1),size(num,2));
  else
    if (length(model)==1)&~isempty(model.fitinfo)
      fiti=model.fitinfo;
      if isstruct(fiti), cf=fiti.cf; else cf=fiti(1); end
      ctxt=[ctxt,sprintf(', cost: %.4g',cf)];
    end
  end
  disp([sprintf('\n%s =\n\n',inputname(1)),...
      '        ',vtxt,smtxt,'fidmodel object',atxt,stxt,rtxt,otxt,ctxt,dtxt,...
      sprintf('\n')])
end

% end ../@fidmodel/display.m
