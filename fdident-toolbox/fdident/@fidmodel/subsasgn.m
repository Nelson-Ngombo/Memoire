function result = subsasgn(idmod,Struct,rhs)
%SUBSASGN  Assignment for fidmodel objects.
%
%            idmod(no) = rhs
%            idmod.fieldname = rhs
%            idmod.fieldname(indices) = rhs
%
%       Input arguments:
%       idmod = fidmodel object
%       Struct = structure of indices etc.
%       rhs = value assigned

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Nov-1998
%
%       See also  SET.

%return object if only one argument is given
if nargin==1,
  result = idmod;
  return
elseif nargin~=3
  error('Wrong number of inputs')
end

StructL = length(Struct);
switch Struct(1).type %determine which operand is used
case '.' %subfield
  %idmod.fieldname...=rhs
  fieldname = Struct(1).subs;
  if StructL>1,
    Value = get(idmod,fieldname);
    Value = subsasgn(Value,Struct(2:end),rhs);
  else
    %Just idmod.fieldname=rhs
    Value = rhs;
  end
  %set will check if valid idmod
  result = idmod;
  set(result,fieldname,Value)
  return
case '()'
  % idmod(index)... = rhs
  if StructL>1,
    modeliorig = subsref(idmod,Struct(1));
    modeli = subsasgn(modeliorig,Struct(2:end),rhs);
    if (length(Struct)==1)&~isempty(rhs)&any(size(modeliorig)~=size(modeli))
      error('In an assignment  A(I) = B, the sizes must be the same')
    end
  else
    %Just idmod(index) = rhs
    if ~isempty(rhs)&~isa(rhs,'fidmodel')
      error('Right side is not an fidmodel object')
    end
    modeli = rhs;
  end
  result =idmod;
  %
  %First perform some error checks
  indices = Struct(1).subs;
  
  if length(indices)>=1
    if ~strcmp(indices{1},':')
      error('Subs assignment is not yet ready for channel indexing')
    end
  elseif length(indices)>=2
    if ~strcmp(indices{2},':')
      error('Subs assignment is not yet ready for channel indexing')
    end
  end
  error('Subs assignment is not yet ready for channel indexing')
  
  lind = length(indices);
  if lind>3,
    error('Index exceeds model array dimensions')
  elseif lind==0,
    error('Missing index')
  end
  %lind = 1 or 2
  %Now set result(i) to modeli
  if ndims(result)>3, error('Model array is not handled with dimensions > 3'), end
  [d1,d2,d3]=size(result);
  [m1,m2,m3]=size(modeli);
  l1=indices{1}; l2=1; l3=1;
  if lind>=2, l2=indices{2}; end
  if lind>=3, l3=indices{3}; end
  for ii=1:3
    if ii==1, l=l1; elseif ii==2, l=l2; else l=l3; end
    if isstr(l)
      if strcmp(l,':'), eval(['l=[1:d',num2str(ii),'];'])
      else
        ind=findstr(l,'end');
        if isempty(ind), error('Invalid index'), end
        l=[l(1:ind-1),'endv',l(ind+3:end)];
        eval(['endv=d',num2str(ii),'; l=',l,';'])
      end
    end
    if ii==1, l1=l; elseif ii==2, l2=l; else l3=l; end
  end %for ii
  %Extend input model if allowed
  if (lind==1)&(max(l1)>max([d1,d2,d3]))&...
      (sum([~isequal(d1,1),~isequal(d2,1),~isequal(d3,1)])==1)
    %Extend vector
    if sum([~isequal(m1,1)&~isequal(m3,1)&~isequal(m3,1)])>1
      error('right side must be a vector of fidmodels to extend')
    end
    %modeli=modeli(:); [m1,m2,m3]=size(modeli);
    [maxd,im]=max([d1,d2,d3]);
    for i=1:max(l1)-maxd, result=cat(im,result,fidmodel); end
  elseif (length(l1)==1)&(l1>d1)&all(l2<=d2)&all(l3<=d3)&(m2==d2)&(m3==d3)
    for i=1:l1-d1, result=cat(1,result,result(1,:,:)); end
  elseif (length(l2)==1)&(l2>d2)&all(l1<=d1)&all(l3<=d3)&(m1==d1)&(m3==d3)
    for i=1:l2-d2, result=cat(2,result,result(:,1,:)); end
  elseif (length(l3)==1)&(l3>d3)&all(l1<=d1)&all(l2<=d2)&(m1==d1)&(m2==d2)
    for i=1:l3-d3, result=cat(3,result,result(:,:,1)); end
  end
  [d1,d2,d3]=size(result);
  result=result(:);
  if length(l1)*length(l2)*length(l3)~=m1*m2*m3
    error('Assignment number mismatch')
  end
  if lind>=3
    if any(l3>d3)
      error('Assignment dimension mismatch: dim3')
    end
  end
  if lind>=2
    if any(l2>d2)|any(l1>d1)
      error('Assignment dimension mismatch')
    end
  end
  l=[];
  if lind==1, l=l1;
  else
    for i1=l1(:)'
      for i2=l2(:)'
        for i3=l3(:)'
          l=[l;i3+(i2-1)*d2+(i1-1)*d2*d3];
        end
      end
    end
  end
  newmodel=0; %new model place introduced
  if length(l)~=length(modeli(:))
    error('Assignment mismatch')
  end
  for i=1:length(l)
    li=l(i);
    %result(li)=modeli(i);
    result=[result(1:li-1);modeli(i);result(li+1:end)];
  end %for i
  result=reshape(result,d1,d2,d3);
  return
case '{}'
  error('Cell contents reference from a non-cell array object')
otherwise
  error(['Unknown type: ' Struct(1).type])
end
%
% End of @fidmodel/subsasgn