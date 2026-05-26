function obj=getobjf(fvstr,modtype)
%GETOBJF Get object if given as string (file or variable in file)
%
%       Simply return if fvstr is not a string
%
%       Example: getobjf(rarmmods(m)','fidmodel')

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision
%       Last modified: 03-Jul-1999

obj=fvstr;
if ~isstr(fvstr)|isempty(fvstr)
  return
else
  if nargin<2, modtype=''; end
  if isempty(modtype), modtype='fiddata'; end
  subsstr='';
  if any(findstr(fvstr,'('))
    ind1=findstr(fvstr,'('); ind2=findstr(fvstr,')');
    fn=fvstr(1:ind1(1)-1); vn=fvstr(ind1(1)+1:ind2(1)-1);
    subsstr=fvstr(ind2(1)+1:end);
    [fvstrmat,dummy,ext]=fnamanal(fn,'mat');
    if exist(fvstrmat)&strcmpi(ext,'mat')
      obj=loadvar(fn,vn);
      %if isstruct(obj), obj=feval(modtype,obj); end
      if isa(obj,modtype)
      elseif iscell(obj)&~isempty(obj)&isa(obj{1},modtype)
        warning('Cell of objects is obsolete')
      else
        obj=fvstr;
      end
    end
  else
    ind3=[find(fvstr=='{'),find(fvstr=='(')];
    if ~isempty(ind3)
      fn=fvstr(1:min(ind3)-1); subsstr=fvstr(min(ind3):end);
    else
      fn=fvstr; subsstr='';
    end
    [fvstrmat,dummy,ext]=fnamanal(fn,'mat');
    if exist(fvstrmat)&strcmpi(ext,'mat')
      vnl=whos('-file',fvstrmat);
      if isempty(vnl)
        error(['No variable found in file ''',fvstrmat,''''])
      end
      obj=loadvar(fvstrmat,vnl(1).name);
      if isa(obj,modtype)
      elseif iscell(obj)&~isempty(obj)&isa(obj{1},modtype)
        warning('Cell of objects is obsolete')
      else
        obj=fvstr;
      end
    end
  end
  if isa(obj,'iddat')&~isempty(subsstr)
    eval(['obj=obj',subsstr,';'])
  end
end
%End