function tdatm=mtimes(tdat,term)
%MTIMES Multiplication of tiddata object by scalar(s)
%
%       If term is a scalar, it multiplies the output;
%       if it is a cell column vector, each channel is 
%       multiplied by the corresponding element.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 19-Aug-1999

if isa(tdat,'double')|isa(tdat,'cell')
  tmp=tdat; tdat=term; term=tmp;
end

if isa(term,'numeric')
  if any(size(term)~=1), error('Number in @tiddata/mtimes must be a scalar'), end
  if ~isfinite(term), error('term is not finite'), end
  if term==0, warning('term is zero in @tiddata/mtimes'), end
  if imag(term)~=0, error('term is complex'), end
  if isequal(term,1), tdatm=tdat; return, end
  set(tdat,'output',term*get(tdat,'output'),'noconsistency');
  sc=get(tdat,'outputscale');
  if ~isempty(sc)
    set(tdat,'output',sc*get(tdat,'output'),'noconsistency');
    set(tdat,'outputscale','','noconsistency');
  end
  set(tdat,'outputunit','')
  tdatm=tdat;
elseif isa(term,'cell')
  if (size(term,1)~=get(tdat,'chnumber'))|(size(term,2)~=1)
    error('The size of the cell does not correspond to the channel number')
  end
  chn=get(tdat,'chnumber');
  for ii=1:chn
    t=term{ii};
    if ~isnumeric(t)|(length(t)~=1)
      error('An element of the cell array is not a scalar')
    end
  end %for ii
  data=get(tdat,'data');
  if isnumeric(data), nd=1; data={data}; else nd=0; end
  for iv=1:chn
    for ih=1:size(data,2)
      data{iv,ih}=term{iv}*data{iv,ih};
    end %for ih
    ty=get(tdat,[sprintf('ch:%.0f',iv)],'chtype');
    if setstr(ty)=='i',
      sc=get(tdat,'inputscale');
      if ~isempty(sc)
        for ih=1:size(data,2)
          data{iv,ih}=sc*data{iv,ih};
        end %for ih
        set(tdat,'inputscale',[],'noconsistency')
      end
    elseif setstr(ty)=='o'
      sc=get(tdat,'outputscale');
      if ~isempty(sc)
        for ih=1:size(data,2)
          data{iv,ih}=sc*data{iv,ih};
        end %for ih
        set(tdat,'outputscale',[],'noconsistency')
      end
    end
  end %for iv
  set(tdat,'inputunit','','outputunit','','noconsistency')
  if nd==1, data=data{1}; end
  set(tdat,'data',data,'noconsistency');
  termv=cat(1,term{:});
  c=get(tdat,'consistency');
  tdatm=tdat;
else
  error(['Multiplication of a ''tiddata'' object by an ''',class(term),''' object is not implemented'])
end

%
%End of @tiddata/mtimes