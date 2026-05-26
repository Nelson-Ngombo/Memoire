function tdatm=mrdivide(tdat,term)
%MRDIVIDE Division of tiddata object by scalar(s)
%
%       If term is a scalar, it divides the output;
%       if it is a cell column vector, each channel is 
%       divided by the corresponding element.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 29-Nov-2000

if isa(tdat,'double')|isa(tdat,'cell')
  error('Division by a ''tiddata'' object is not implemented')
end

if isa(term,'numeric')
  if any(size(term)~=1), error('Number in @tiddata/mtimes must be a scalar'), end
  if ~isfinite(term)&~isnan(term), warning('term is not finite'), end
  if term==0, error('term is zero in @tiddata/mrdivide'), end
  if imag(term)~=0, error('term is complex'), end
  if isequal(term,1), tdatm=tdat; return, end
  tdatm=mtimes(tdat,1/term);    
elseif isa(term,'cell')
  if (size(term,1)~=get(tdat,'chnumber'))|(size(term,2)~=1)
    error('The size of the cell does not correspond to the channel number')
  end
  chn=get(tdat,'chnumber');
  termout=term;
  for ii=1:chn
    t=term{ii};
    if ~isnumeric(t)|(length(t)~=1)
      error('An element of the cell array is not a scalar')
    end
    termout{ii}=1/t;
  end %for ii
  tdatm=mtimes(tdat,termout);    
elseif isa(term,'fidmodel')
  if size(tdat,2)==1
    tdatm=tdat;
    y=get(tdatm,'output');
    if iscell(y), error('Cannot handle multiple outputs')
    elseif isempty(y), tdatm=tdat; return
    end
    ts=get(tdatm,'ts'); ichar=get(tdatm,'inputcharacter');
    N=length(y); Y=fft(y); fs=1/ts; freqv=[0:N/2]/N*fs;
    h=tfcalc(term,freqv); h(end)=abs(h(end));
    h=[h;conj(flipud(h(2:end-1)))];
    Ym=Y./h;
    ym=real(ifft(Ym));
    set(tdatm,'output',ym);
  else %several experiments
    tdatm=tdat;
    for ii=1:size(tdat,2)
      tdatm=subsasgn(tdatm,struct('type','{}','subs',{{':',ii}}),...
        mrdivide(subsref(tdatm,struct('type','{}','subs',{{':',ii}})),term));  
    end %for ii
  end 
else
  error(['Division of a ''tiddata'' object by an ''',class(term),''' object is not yet implemented'])
end

%
%End of @tiddata/mrdivide