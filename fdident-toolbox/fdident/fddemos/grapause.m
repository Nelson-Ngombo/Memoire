function grnoout=grapause(tfile,grnoin,printstm,xp,yp)
%GRAPAUSE Utility to stop at graphs, save plot etc.
%
%        The name of the calling file (tfile) is shown if yesinput is
%        automatic, or printstm contains the string 'print' in any form.
%
%       Input arguments:
%       tfile = name of the test file
%       grnoin = actual value of graph number
%       printstm = print statement
%       xp,yp = position of pause message in absolute coordinates
%
%       Usage: grnoout=grapause(tfile,grnoin,printstm,xp,yp);

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 08-Sep-1997

if nargin<1, error('no input argument'), end
if nargin<2, grnoin=[]; end, if isempty(grnoin), grnoin=0; end
if nargin<3, printstm=''; end
if nargin<4, xp=[]; end, if isempty(xp), xp=0.82; end
if nargin<5, yp=[]; end, if isempty(yp), yp=0; end

txth=axes('Position',[0,0,1,1]); axis('off')
grnoout=grnoin+1;
%
yf=0;
%Look for text at position 0,0
hf=get(gcf,'children'); hf4=zeros(size(hf));
for i=length(hf):-1:1
  if strcmp(get(hf(i),'type'),'axes')
    pos=get(hf(i),'Position'); hf4(i)=pos(4);
  else pos=[j,j,j,j];
  end
  if ~all(pos(1:2)==[0,0]), hf(i)=[]; hf4(i)=[]; end
end
for hi=1:length(hf)
  t=findobj(hf(hi),'type','text');
  for ti=1:length(t)
    pos=get(t(ti),'position');
    if (pos(1)==0)&(pos(2)*hf4(hi)<0.9), yf=max(pos(2)*hf4(hi)+0.04,yf); end
  end
end
%
putfilename=0;
MatlV=version;
if strcmp(MatlV(1:3),'4.0')|strcmp(MatlV(1:3),'4.1')
  putfilename=1;
  fprintf(['Plot ',tfile,'/%.0f...\n'],grnoout)
else
  if ~isempty(findstr(printstm,'print '))|~isempty(findstr(printstm,'print('))
    putfilename=1;
  end
  global yesinpacceptdef
  if strcmp(yesinpacceptdef,'yes'), putfilename=1; end
  if (putfilename==1)&~isempty(printstm)
    fprintf(['Saving plot ',tfile,'/%.0f to file...\n'],grnoout)
  else fprintf(['Plot ',tfile,'/%.0f...\n'],grnoout)
  end
end
%
if putfilename==1
  texth=text(0,yf,sprintf([tfile,'/%.0f'],grnoout),...
                'Verticalalignment','bottom');
end
%
delete(findobj(gcf,'tag','fdident_dismiss'))
eval(printstm)
%
text(1,yp,'Press a key...','Verticalalignment','bottom',...
      'HorizontalAlignment','right')
fprintf('Press any key to continue ...')
if length(printstm)<10, figure(gcf), end
pause, disp(' ')
delete(txth)
%remove message 'Press a key...'
figure(gcf), drawnow
%
% End of grapause
