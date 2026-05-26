function result = subsref(model,Struct)
%SUBSREF Referencing for objects.
%          model.fieldname
%          model.fieldname(indices) 
%          model.fieldname(i,j)
%
%       See also: GET.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: I. Kollar, 13-Aug-1999

ni = nargin;
if ni==1,
   result = model;
   return
end

%StructL = length(Struct);
switch Struct(1).type
case '.'
   % At least model.fieldname
   % Output will be a (piece of) one of the system fields
   result = get(model,Struct(1).subs);
   if length(Struct)>1
     result=subsref(result,Struct(2:end));
   end
   return
case '()'
   % model(something)
   % Fall through to code below
case '{}'
   error('Cell contents reference from a non-cell array object')
otherwise
   error(['Unknown type: ' Struct(1).type])
end


% Everything else just handles fidmodel(something)
indices = Struct(1).subs;
if ~strcmp(indices{1},':')|((length(indices)>=2)&~strcmp(indices{2},':'))
  num=model(1).num; denom=model(1).denom;
  if ~iscell(num), num={num}; end, if ~iscell(denom), denom={denom}; end
  endi=length(indices); ind=indices(1:min(2,endi));
  try
    covm=model(1).covariance;
    nums=num; num=num(ind{:});
    if any(size(num)<size(nums))
      ind1=ind{1};
      if isstr(ind1)&(length(ind1)>=3)&any(findstr(ind1(end+[-2:0]),'end')),
        ie=findstr(ind1,'end'); ind1=[ind1(1:ie+2),'1',ind1(ie+3:end)];
        end1=size(num,1); ind1=eval(ind1);
      end
      ind2=ind{2};
      if isstr(ind2)&(length(ind2)>=3)&any(findstr(ind2(end+[-2:0]),'end')),
        ie=findstr(ind2,'end'); ind2=[ind2(1:ie+2),'2',ind2(ie+3:end)];
        end2=size(num,2); ind2=eval(ind2);
      end
      if ~isempty(covm)
        Lc=size(covm,1);
        for i2=size(nums,2):-1:1
          for i1=size(nums,1):-1:1
            if ismember(i1,ind1)&ismember(i2,ind2)
              %
            else
              covm(:,Lc+[0:-1:-length(nums{i1,i2})+1])=[];
              covm(Lc+[0:-1:-length(nums{i1,i2})+1],:)=[];
            end
            Lc=Lc-length(nums{i1,i2});
          end
        end
      end %~isempty(covm)
    end
  catch, index=ind, error('Cannot reference to numerator from index')
  end
  if length(denom)>1, denom=denom(ind{:}); end
  if length(num)==1, num=num{1}; end
  if length(denom)==1, denom=denom{1}; end
  model(1).num=num; model(1).denom=denom;
  model(1).covariance=covm;
  Struct(1).subs=[{':'},Struct(1).subs];
  if ~isempty(model.data), model.data=subsref(model.data,Struct(1)); end
  %error('Subsref according to input or output channels is not implemented yet')
end
%Select I/O channels***

if length(indices)>=3
  models=struct(model);
  models=models(indices{3:end});
  result=fidmodel(models);
end
if length(Struct)>1,
  result=subsref(result,Struct(2:end));
end
% end ../@tf/subsref.m
