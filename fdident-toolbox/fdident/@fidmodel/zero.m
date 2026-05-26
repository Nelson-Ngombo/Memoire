function zerovect=zero(imodel)
%ZERO  Calculate (transmission) zeros of fidmodel object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1999-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 29-May-2004

sm=size(imodel); if length(sm)==3, sm(4)=1; end
fs=[];
if length(imodel)==1
  if prod(sm(1:2))==1
    [d1,num,denom,d2,fs]=imppar(imodel,fs);
    fsii{1}=fs;
  else
    num=get(imodel,'num');
    fsii=cell(size(num));
    for ii=1:prod(size(fsii)), fsii{ii}=1; end
  end
else
  num=cell(sm(3:end)); fsii=num;
  for ii=1:prod(sm(3:end))
    if prod(sm(1:2))==1
      [d1,numii,denom,d2,fs]=imppar(imodel(ii),fs);
      num{ii}=numii;
      if any(findstr(imodel(1).variable,'z')), fsii{ii}=1;
      elseif strcmp(d1,'w'), fsii{ii}=sqrt(fs);
      else fsii{ii}=fs;
      end
    else
      num{ii}=get(imodel(ii)); fsii{ii}=1;
    end
  end
end
if ~iscell(num), num={num}; end
zerovect=cell(sm);
if any(findstr(imodel(1).variable,'z')), fsc=1;
elseif strcmp(d1,'w'), fsc=sqrt(fs);
else fsc=fs;
end
for ii3=1:sm(3)
  for ii4=1:sm(4)
    if strcmp(imodel(ii3,ii4).representation,'orthopol')
      if ii3*ii4==1, Znum=imodel.Znum; end
      if iscell(Znum), Znumi=Znum{ii3,ii4};
      else Znumi=Znum;
      end
      zerovect{ii3,ii4}=fdident('private','ortroots',num{ii3,ii4},Znumi)*fsc;
    else
      for ii1=1:sm(1)
        for ii2=1:sm(2)
          zerovect{ii1,ii2,ii3,ii4}=roots(num{ii1,ii2})*fsii{ii1,ii2};
        end
      end
    end
  end
end
if length(zerovect)==1, zerovect=zerovect{1}; end

%End of @fidmodel/zero
