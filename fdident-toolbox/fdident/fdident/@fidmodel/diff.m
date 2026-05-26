function Out = diff(obj1,obj2)
%DIFF  List differences between objects
%
%       See also  @IDDAT/GET, @IDDAT/SET.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-May-1999

ni = nargin;
no = nargout;
v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,2); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,2,ni)), %earlier
end
if ~isa(obj1,'fidmodel')
  error('First argument is not an fidmodel object')
end
%
if isstr(obj2)&strcmp(obj2,'ListAllObjectProperties')
  makelist=1;
elseif ~strcmp(class(obj1),class(obj2))
  error('Classes of objects differ')
else
  makelist=0;
end
%
%Get all properties in the form props='|prop1|prop2|...|'
%or as a cell array props={prop1,prop2,...}
props=idpvpstr(obj1);
%
if isstr(props)
  ind=find(props=='|'); propch={};
  for ii=1:length(ind)-1
    propch{ii,1}=props(ind(ii)+1:ind(ii+1)-1);
  end %for ii
else
  propch=props;
end
%
v2='';
if isa(obj2,'fidmodel')
  v2=get(obj2,'variable');
  props2=idpvpget(obj2);
  for ii=1:length(props2)
    if ~any(strmatch(props2{ii},propch))
      if ~strcmp(props2{ii},'A')&~strcmp(props2{ii},'B')
        propch=[propch(:);{props2{ii}}];
      end
    end
  end
end
%
v1=get(obj1,'variable');
if any(findstr(v1,'z'))&any(findstr(v2,'z'))
  ind=strmatch('fscale',propch,'exact');
  if ~isempty(ind), propch(ind)=[]; end
elseif ~any(findstr(v1,'z'))&~any(findstr(v2,'z'))
  ind=strmatch('fs',propch,'exact');
  if ~isempty(ind), propch(ind)=[]; end
end
%
for ii=length(propch):-1:1
  if any(findstr(['|',propch{ii},'|'],'|Consistency|ExpNumber|ChNumber|Channels|'))
    %Move these properties to the end of the list
    propii=propch{ii}; propch(ii)=[]; propch{end+1}=propii;
  end
end
%
diffc={}; l1=0; l2=0; l3=0; datadiff=0;
for ii=1:length(propch)
  prop=propch{ii};
  if ~strcmp(prop,'Channels')&~strcmp(prop,'CohVector')&...
      ~strcmp(prop,'CovVector')&~strcmp(prop,'information')&...
      ~(~any(findstr(v1,'z'))&strcmp(prop,'InterSample'))
    %Properties one by one
    value1=get(obj1,prop);
    if makelist==0
      value2=get(obj2,prop);
      if ~isequala(value1,value2)&~strcmp(prop,'Date') %list the difference
        dn=size(diffc,1)+1;
        diffc{dn,1}=[prop,':'];
        diffc{dn,2}=showvalue(value1);
        diffc{dn,3}=showvalue(value2);
        l1=max(l1,length(diffc{dn,1}));
        l2=max(l2,length(diffc{dn,2}));
        l3=max(l3,length(diffc{dn,3}));
        if strcmp(prop,'data'), datadiff=1; end
      end
    else %make list of properties of obj1
      dn=size(diffc,1)+1;
      diffc{dn,1}=[prop,':'];
      diffc{dn,2}=showvalue(value1,50);
      l1=max(l1,length(diffc{dn,1}));
      l2=max(l2,length(diffc{dn,2}));
    end
  end
end
%
diffarr='';
for ii=1:size(diffc,1)
  if makelist==0
    if ii==1
      fprstr=['%',num2str(l1),'s  %',num2str(l2),'s  %-',num2str(l3),'s'];
    end
    diffarr=str2mat(diffarr,...
      sprintf(fprstr,diffc{ii,1},diffc{ii,2},diffc{ii,3}));
  else %make list
    if ii==1
      fprstr=['%',num2str(l1),'s  %-',num2str(l2),'s'];
    end
    diffarr=str2mat(diffarr,...
      sprintf(fprstr,diffc{ii,1},diffc{ii,2}));
  end
end %for ii
if size(diffarr,1)>1, diffarr(1,:)=''; end
if (makelist==0)&~isempty(diffarr)
  objname1='obj1'; objname2='obj2';
  name1=get(obj1,'Name'); name2=get(obj2,'Name');
  if ~isempty(name1), objname1=[objname1,': ',name1]; end
  if ~isempty(name2), objname2=[objname2,': ',name2]; end
  objname1=[objname1,'   ']; objname2=['   ',objname2];
  diffarr=str2mat(sprintf(fprstr,' ',objname1,objname2),diffarr);   
end
%
if datadiff
  if (length(obj1)==1)&(length(obj2)==1)
    diffarr=str2mat(diffarr,'data difference details:');
    if isa(obj1.data,'fiddata')&isa(obj2.data,'fiddata')  
      diffarr=str2mat(diffarr,diff(obj1.data,obj2.data));
    else
      diffarr=str2mat(diffarr,...
        ['      data:                ',class(obj1.data),...
          '           ',class(obj2.data)]);
    end
  end
end
%
if no, Out=diffarr;
elseif ~isempty(diffarr), disp(diffarr)
else disp('Objects are identical')
end
%
% end of @iddat/diff.m


function Out=isequala(v1,v2)
%Check equality of two arbitrary objects

Out=0;
if (isempty(v1)&isstruct(v2)&isempty(fieldnames(v2))) | ...
    (isempty(v2)&isstruct(v1)&isempty(fieldnames(v1)))
  %empty equals no field structure
  Out=1; return
end
if ~strcmp(class(v1),class(v2)), return, end
s1=size(v1); s2=size(v2);
if length(s1)~=length(s2), return
elseif any(s1~=s2), return
end
%Now sizes are equal
if isnumeric(v1)
  v1nani=find(isnan(v1)); v2nani=find(isnan(v2));
  Out1=isequal(v1nani,v2nani); if Out1==0, Out=0; return, end
  NaNv=NaN;
  if ~isempty(v1nani)
    v1(v1nani)=ones(size(v1nani)); v2(v2nani)=ones(size(v2nani));
  end
  Out=isequal(v1,v2);
  return
elseif isstr(v1), Out=strcmp(v1,v2); return
elseif iscell(v1)
  l=prod(s1);
  for ii=1:l
    if ~isequala(v1{ii},v2{ii}), return, end
  end %for ii
elseif isstruct(v1)
  f1=fieldnames(v1); f2=fieldnames(v2);
  if ~isequala(f1,f2), return, end
  for ii=1:length(f1)
    if ~isequala(getfield(v1,f1{ii}),getfield(v2,f2{ii})), return, end
  end
elseif isa(v1,'iddat')|isa(v1,'fidmodel')
  v1=struct(v1); v2=struct(v2);
  Out=isequala(v1,v2); return
else
  warning(['Unknown class ''',class(v1),'''']), Out=0; return
end
Out=1; %everything is the same


function str=showvalue(v,strmax)
%Describe the variable for listing

if nargin<2, strmax=[]; end, if isempty(strmax), strmax=30; end
c=class(v);
if strcmp(c,'char'), c='string, ';
elseif strcmp(c,'cell'), c=[c,',   '];
else c=[c,', '];
end
[s1,s2,s3]=size(v);
if s3==1, sstr=sprintf('%.0f x %.0f',s1,s2);
else sstr=sprintf('%.0f x %.0f x %.0f',s1,s2,s3);
end
%
strtmp=[c,sstr];
if length(v)==0
  str=[c,sstr];
elseif isstr(v)&(s1==1)&(s2<=strmax)&(s3==1)
  str=[c,'''',v,''''];
elseif isnumeric(v)&(length(v)==1)
  str=[c,sprintf('[ %.4g ]',v)];   
elseif isnumeric(v)&((s1==1)&(s2==2)&(s3==1))
  str=[c,sprintf('[ %.4g %.4g ]',v(1),v(2))];   
elseif isnumeric(v)&((s1==1)&(s2==3)&(s3==1))
  str=[c,sprintf('[ %.4g %.4g %.4g ]',v(1),v(2),v(3))];
  if length(str)>strmax+2, str=strtmp; end  
else
  str=strtmp;
end

% end of file @fidmodel/diff.m
