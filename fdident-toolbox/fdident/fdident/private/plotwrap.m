function plotwrap(mark,tag, varargin)
%PLOTWRAP  Plot wrapper for changable ploteltf plots
%       See also: @fidmodel/plot.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 28-Jun-2001 GYS

% note: varargin is necessary for correct replay.

mark=mark(end); % remove 'uic_'

try, findhf=get(get(gcbo,'parent'),'parent');
catch, findhf=[];
end
if isempty(findhf), findhf=0; end
hm=findall(findhf,'type','uimenu','tag',tag);
hf=get(get(hm(1),'parent'),'parent');
argall=get(hf,'UserData');
arg=argall{1};
if ~isempty(argall{2}), arg{argall{2}}=mark;
else arg=[arg(1),{mark},arg(2:end)];
end
if (isstr(arg{2})&strcmp(arg{2},'C')) | (length(arg)>2)&(isstr(arg{3})&strcmp(arg{3},'C'))
  cloud(arg{1})
  argall{2}=2; argall{3}='C';
  set(hf,'UserData',argall);
  hm=findall(findhf,'type','uimenu','tag',tag);
  set(allchild(get(hm,'parent')),'checked','off')
  set(hm,'checked','on')
else
  plot(arg{:});
end
dismispb(get(hf,'tag'));
