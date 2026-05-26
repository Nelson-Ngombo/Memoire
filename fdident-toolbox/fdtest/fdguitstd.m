function fdguitstd
%Test all fdident GUI demos in User mode

cl0=clock; assignin('base','cl0',cl0);
for ic=1:2
  if ic==2
    rmpathfr control
    rmpathfr \ident
  end
  fdguitst c U
  fdguitst c
  if exist('testfd.m')
    pause(10)
    testfd
  end
end
%End of fdguitstd

function rmpathfr(string,type)
%RMPATHFR Remove all directories containing string or cell of strings
%
%        type = '-end' means that the string is at the end of the path element.
%
%        Example: rmpathfr('control')
%
%	      Written by I. Kollar
%	      Last modified: 07-Jan-1998

if nargin<2, type=''; end
if strcmp(type,'-end'), string=[string,pathsep]; end
dirc=findpath(string);
for ii=1:size(dirc,1)
  disp(['Removing ''',dirc{ii},''' from path ...'])
  rmpath(dirc{ii})
end
%
%End of rmpathfr

function dirs=findpath(string,type)
%FINDPATH Find all directories containing given string
%
%        type = '-end' means that the string is at the end of the path element.
%
%        Example: findpath('control'); findpath('test','-end');

%	Written by I. Kollar
%	Last modified: 07-Jan-1998

if nargin<2, type=''; end
if strcmp(type,'-end'), string=[string,pathsep]; end
p=[pathsep,lower(path),pathsep];
ind=max(findstr(lower(string),p)); 
indci=0; %dirs=char;
dirs={};
while ~isempty(ind)
  indl=max(find(p(1:ind)==pathsep));
  indh=min(find(p(ind-1+length(string):length(p))==pathsep))+...
    ind-2+length(string);
  indci=indci+1;
  %dirs=char(dirs,p(indl+1:indh-1));
  dirs{indci,1}=p(indl+1:indh-1);
  p(indl:indh-1)='';
  ind=max(findstr(lower(string),p)); 
end
%
%End of findpath

