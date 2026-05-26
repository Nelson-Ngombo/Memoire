function polevect=pole(imodel)
%POLE  Calculate poles of fidmodel object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1999-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 29-Jan-2000

fs=[];
if length(imodel)==1
  if ~isempty(imodel.num)&~isempty(imodel.denom)
    [d1,n1,denom,d2,fs]=imppar(imodel,fs);
  else 
    d1='s'; n1=[]; denom=[]; d2=0; fs=[];
  end
else
  denom=cell(size(imodel));
  for ii=1:prod(size(imodel))
    [d1,n1,denomii,d2,fs]=imppar(imodel,fs);
    denom{ii}=denomii;
  end
end
if ~iscell(denom), denom={denom}; end
polevect=cell(size(denom));
if any(findstr(imodel(1).variable,'z')), fsc=1;
elseif strcmp(d1,'w'), fsc=sqrt(fs);
else fsc=fs;
end
for ii=1:prod(size(denom))
  if strcmp(imodel(ii).representation,'orthopol')
    if ii==1, Zdenom=imodel.Zdenom; end
    if iscell(Zdenom), Zdenomi=Zdenom{ii};
    else Zdenomi=Zdenom;
    end
    polevect{ii}=fdident('private','ortroots',denom{ii},Zdenomi)*fsc;
  else
    if ~isempty(denom{ii})&~isempty(fsc)
      polevect{ii}=roots(denom{ii})*fsc;
    else
      polevect{ii}=[];
    end
  end
end
if length(polevect)==1, polevect=polevect{1}; end

%End of @fidmodel/pole
