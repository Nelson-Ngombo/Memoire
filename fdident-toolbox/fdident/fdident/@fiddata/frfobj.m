function outobj=frfobj(obj)
%FRFOBJ  Calculate object with ones at the inputs and FRF's at the outputs 
%
%      outobj=frfobj(obj)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Apr-2004

[Harr,frarr,vararr]=frf(obj);
outobj=[];
for ii=1:size(Harr,2)
  u=cell(size(Harr,1),1); u{ii}=ones(size(Harr{1,ii}));
  frarru=cell(size(u)); frarru{ii}=frarr{ii,1};
  outobj=merge(outobj,fiddata(Harr(:,ii),u,[frarr(:,ii);frarru]));
end
cht=get(obj,'chtype');
indo=find(cht=='o'+0);
indi=find(cht=='i'+0);
[dummy,ind]=sort([indo;indi]);
Struc.type='{}'; Struc.subs={ind,':'};
outobj=subsref(outobj,Struc);
%
%End of frfobj