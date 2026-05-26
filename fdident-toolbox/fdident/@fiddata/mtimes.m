function Fdatm=mtimes(Fdat,term)
%MTIMES Multiplication of fiddata object
%
%       If term is a scalar, it multiplies the output; if it is an fiddata object,
%       the input and the output are modified by the corresponding complex
%       amplitudes; if it is an fidmodel object, the output is modified by the
%       transfer function; if it is a cell column vector, each channel is 
%       multiplied by the corresponding element.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Jun-1999

if isa(Fdat,'double')|isa(Fdat,'cell')
  tmp=Fdat; Fdat=term; term=tmp;
end
if ~isa(Fdat,'fiddata'), error('Fdat is not ''fiddata'''), end

if isa(term,'numeric')
  if any(size(term)~=1), error('Number in @fiddata/mtimes must be a scalar'), end
  if ~isfinite(term), error('term is not finite'), end
  if term==0, warning('term is zero in @fiddata/mtimes'), end
  if imag(term)~=0, error('term is complex'), end
  if isequal(term,1), Fdatm=Fdat; return, end
  set(Fdat,'output',term*get(Fdat,'output'),'noconsistency');
  sc=get(Fdat,'outputscale');
  if ~isempty(sc)
    set(Fdat,'output',sc*get(Fdat,'output'),'noconsistency');
    set(Fdat,'outputscale','','noconsistency');
  end
  set(Fdat,'outputunit','')
  set(Fdat,'outputvariance',term^2*get(Fdat,'outputvariance'));
  set(Fdat,'covvect',term*get(Fdat,'covvect'));
  Fdatm=Fdat;
elseif isa(term,'cell')
  if (size(term,1)~=get(Fdat,'chnumber'))|(size(term,2)~=1)
    error('The size of the cell does not correspond to the channel number')
  end
  chn=get(Fdat,'chnumber');
  for ii=1:chn
    t=term{ii};
    if ~isnumeric(t)|(length(t)~=1)
      error('An element of the cell array is not a scalar')
    end
  end %for ii
  data=get(Fdat,'data');
  if isnumeric(data), nd=1; data={data}; else nd=0; end
  for iv=1:chn
    for ih=1:size(data,2)
      data{iv,ih}=term{iv}*data{iv,ih};
    end %for ih
    ty=get(Fdat,[sprintf('ch:%.0f',iv)],'chtype');
    if setstr(ty)=='i',
      sc=get(Fdat,'inputscale');
      if ~isempty(sc)
        for ih=1:size(data,2)
          data{iv,ih}=sc*data{iv,ih};
        end %for ih
        set(Fdat,'inputscale',[],'noconsistency')
      end
    elseif setstr(ty)=='o'
      sc=get(Fdat,'outputscale');
      if ~isempty(sc)
        for ih=1:size(data,2)
          data{iv,ih}=sc*data{iv,ih};
        end %for ih
        set(Fdat,'outputscale',[],'noconsistency')
      end
    end
  end %for iv
  set(Fdat,'inputunit','','outputunit','','noconsistency')
  if nd==1, data=data{1}; end
  set(Fdat,'data',data,'noconsistency');
  termv=cat(1,term{:});
  covar=get(Fdat,'covariance');
  if ~isempty(covar)
    for ii=1:size(covar,3)
      covii=covar(:,:,ii);
      if ~isempty(covii)
        covii=covii.*(termv*termv');
        covar(:,:,ii)=covii;
      end %for ii
    end
    set(Fdat,'covariance',covar,'noconsistency')
  end
  c=get(Fdat,'consistency');
  Fdatm=Fdat;
elseif isa(term,'fiddata')
  if ~isempty(get(term,'SiSoVariance'))
    warning('Right-hand term has variance: this variance is not yet handled')
  end
  Fdatm=modifyfv(Fdat,1/term);  
elseif isa(term,'fidmodel')
  if ~isempty(get(term,'covariance'))
    warning('fidmodel object has covariance: not yet handled')
  end
  Fdatm=mrdivide(Fdat,1/term);  
else
  error(['Class of ''term'' is ''',class(term),''''])
end
%
%End of @fiddata/mtimes