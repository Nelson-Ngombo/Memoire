function mserr=mstotalerr(Fdat,ryx)
%MSTOTALERR  Calculate mean square of errors

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2006
%       All rights reserved.
%       $Revision: $
%       Last modified: 31-Mar-2006

if nargin==2
  if ~isa(Fdat,'fiddata') %ryx is given in place of Fdat
    tmp=Fdat; Fdat=ryx; ryx=tmp;
  end
  if ~isempty(ryx)&~isequal(get(Fdat,'chnumber'),0)
    error('Two unempty arguments are given')
  elseif isempty(ryx), ryx=frf(Fdat); if iscell(ryx), ryx=ryx{1}; end
  else %ryx not empty, it is OK
  end
  if isa(ryx,'fiddata')
    if ~isequal(get(Fdat,'chnumber'),0)&~isequal(get(ryx,'chnumber'),0)
      error('Cannot decide what to do with two fiddata arguments')
    elseif ~isequal(get(ryx,'chnumber'),0)
      ryx=frf(ryx); if iscell(ryx), ryx=ryx{1}; end
    elseif ~isequal(get(Fdat,'chnumber'),0)
      ryx=frf(Fdat); if iscell(ryx), ryx=ryx{1}; end
    end
  elseif isa(ryx,'fidmodel')
    if ~isequal(get(Fdat,'chnumber'),0)
      error('Cannot decide what to do with nonempty fiddata and fidmodel arguments')
    else
      ryx=frf(rdueelis(ryx)); if iscell(ryx), ryx=ryx{1}; end
    end    
  end
elseif nargin==1
  ryx=frf(Fdat); if iscell(ryx), ryx=ryx{1}; end
end
%
F=length(ryx);
if length(ryx)>=3
  filtryx=filter([-0.5,1,-0.5],1,ryx);
  len=floor(max(min(F,21),sqrt(F-2)+1));
  smoothfilt=1/len*ones(1,len);
  varryx=[0;1/1.5*filter(smoothfilt,1,abs(filtryx(3:end)).^2);0];
  varryx(1:len-1)=varryx(len)*ones(len-1,1);
  varryx(end-[1:len-1]+1)=varryx(end-len+1)*ones(len-1,1);
  %Const:
  %varryx=1/1.5/(F-2)*sum(abs(filtryx(3:end)).^2);
else
  varryx=1/F*sum(abs(ryx).^2);
end
mserr=varryx;
%stderr=sqrt(varryx);

%End of @fiddata/mstotalerr