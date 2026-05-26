function shprops(Props,Values,schar,obj)
%SHPROPS Displays properties and their values (for internal use only)
%
%       Both Props and Values are cell arrays of one-line strings
%       schar can be a separator character or empty
%       obj allows to use shprops as a class method

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 20-Jun-1999

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(2,4); %Matlab 2016a or later
else ni=nargin; error(nargchk(2,4,ni)), %earlier
end
for ii=1:size(Props,1),
  strii=Values{ii};
  cellexists=0;
  if iscell(strii)&isequal(size(strii),[1 1]),
    strii1=strii{1};
    if (isstr(strii1)|isa(strii1,'double'))&(ndims(strii1)==2)&...
        (size(strii1,1)<=1)
      strii=strii1; cellexists=1;
    end
  end
  
  maxwidth=30+30*strcmp(schar(1),':');
  if isstr(strii)&(ndims(strii)==2)&(size(strii,1)<=1)&...
      (size(strii,2)<maxwidth)
    if strcmp(schar(1),':') %SET
      strii2=strii;
    else %GET
      strii2=['''' strii ''''];
    end
  elseif isa(strii,'double')&(ndims(strii)==2)&(isempty(strii) |...
      ((size(strii,1)<=1)&(size(strii,2)<maxwidth)))
    if isempty(strii)&~isequal(size(strii),[0 0]),
      strii2=sprintf('[%dx%d double]',size(strii,1),size(strii,2));
    else
      strii2=mat2str(strii,5); %5-digit precision
    end
  elseif iscell(strii)&isempty(strii)
    if isequal(size(strii),[0,0])
      strii2='{}';
    else
      strii2=sprintf('{%dx%d cell}',size(strii,1),size(strii,2));
    end
  else
    %Too long
    strii2=mat2str(size(strii));
    strii2=[strrep(strii2(2:end-1),' ','x') ' ' class(strii)];
    if isa(strii,'cell')
      strii2=['{' strii2 '}'];
    else
      strii2=['[' strii2 ']'];
    end
  end
  if cellexists, strii2=['{' strii2 '}']; end
  disp(['        ',Props{ii},schar,strii2]);
end
disp(' ')
%
%end @iddat/shprops.m
