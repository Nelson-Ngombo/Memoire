function fdgprint(WinTag,dev,opt, filename)
%FDGPRINT Print fdident GUI window using print command
%
%       Input arguments:
%       WinTag       - tag of the window in question
%       dev      - type of device (optional) [ps is supported]
%       opt      - option (e.g. '-append')
%       filename - destination ps filename. If missing and opt is ps, a dialog is called
%
%       Usage: fdgprint(WinTag,dev,opt,filename)
%       Example: fdgprint('fdtool_main')
%
%       See also: PRINT.

%       Written By I. Kollar
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 03-June-1999, GYS

if nargin<2, dev=''; end
if nargin<3, opt=''; end
if nargin<4, filename=''; end

h=findall(0,'tag',WinTag);
%all units in inches
%desired margins
hoffs=1.2; voffs1=0.6; voffs2=1.2;
%
%a4h=210/25.4; a4v=297/25.4; %a4 paper
%letterh=8.5; letterv=11; %Us letter paper
%
paper='a4';
%paper='usletter';
%
if strcmp(paper,'a4')
   set(h,'papertype','a4')
else
  set(h,'papertype','usletter')
end
%
ps=get(h,'papersize');
paperh=ps(1); paperv=ps(2);
%
pos=get(h,'position'); %position in actual units
posused=pos;
%
u=get(h,'units'); set(h,'units','inches') %somehow misplaces position
posin=get(h,'position'); %This is the position in true inches
%
set(h,'paperunits','inches')
%desired position in inches:
pppos=[hoffs paperv/2+voffs1 paperh-hoffs-hoffs paperv/2-voffs1-voffs2];
%
%This is an attempt to achieve proportionality
%rat=min(abs([pppos(3)/posused(3),pppos(4)/posused(4)]));
%pppossave=pppos;
%Set real figure position ratio
%pppos(3:4)=rat*posused(3:4);

%Cannot print whole figure with different screen and printed figure sizes,
%so set true screen sizes
pppossave=pppos;
pppos(3:4)=posin(3:4); %brute force: copy sizes
%
%reposition figure to center
pppos(1)=pppos(1)+(pppossave(3)-pppos(3))/2;
pppos(2)=pppos(2)+(pppossave(4)-pppos(4))/2;
minmargin=0.5; %Minimum top margin
if pppos(2)+pppos(4)>paperv-minmargin
   pppos(2)=paperv-minmargin-pppos(4);
end
%
set(h,'paperposition',pppos)

if isempty(dev) %if directly using print command
  %find status objects to hide
  hoh=[findall(h,'tag','essd_uic_statustext'),...
      findall(h,'tag','gfdd_uic_statustext'),...
      findall(h,'tag','sme_uic_statustext'),...
      findall(h,'tag','caem_uic_statustext'),...
      findall(h,'tag','fdsimul_uic_statustext'),...
      findall(h,'tag','freqsel_uic_statustext'),...
      findall(h,'tag','status_gettime'),...
      findall(h,'tag','average_main_status'),...
      findall(h,'tag','essd_uic_statusframe'),...
      findall(h,'tag','gfdd_uic_statusframe'),...
      findall(h,'tag','sme_uic_statusframe'),...
      findall(h,'tag','caem_uic_statusframe'),...
      findall(h,'tag','fdsimul_uic_statusframe'),...
      findall(h,'tag','freqsel_uic_statusframe'),...
      findall(h,'tag','frame_status'),...
      findall(h,'tag','average_main_statusframe'),...
      findall(h,'tag','fdtool_dismiss_pb')];
  set(hoh,'visible','off')
  hbc=findall(h,'type','uicontrol');
  if ~isempty(hbc)
    backgsave=get(hbc(1),'background');
    set(hbc,'background',[1,1,1]) %make backgrounds white
  end
  colorsave=get(h,'color'); set(h,'color',[1,1,1]) %figure color
  %
end %if isempty(dev)
%
%Experiments:
%set(h,'paperpositionmode','auto') %This repositions the figure!
%set(h,'units','inches')
%set(h,'resize','off')
%set(h,'clipping','off')
%hall=findall(h,'type','uicontrol'); set([h;hall],'units','inches')

if strncmp(computer,'MAC',3)
   set(h,'PaperPositionMode','auto','PaperOrientation','landscape')
end

if isempty(dev) %use print command
   if ~isunix
      print(['-f',sprintf('%.14f',h)])
   else %temporary bypass for unix error
      warning('Temporary fix for print in unix')
      print(['-f',sprintf('%.14f',h)],'-deps','-loose','tmp.eps')
      !lpr tmp.eps
      %!rm -f tmp.eps
   end
elseif strcmp(dev, 'ps')  %to postscript file
   % find caller's handler fcn
   callerfcn=guiinfos('masterfcn', WinTag);
   if isempty(callerfcn)
      if guiinfos('isdevelopment')
         error(['MasterFcn info missing for window: ' WinTag])
      else
         callerfcn='fdtool';
      end
   end
   if strcmp(callerfcn(1), '*') % remove * if present
      callerfcn=callerfcn(2:end);
   end
   
   if isempty(filename)
      [n,p]=uiputfile('*.ps', 'Print to postcript file');
      if ischar(p)
         filename=fullfile(p,n);
      end
   end
   
   if ~isempty(filename)
      print(['-f',sprintf('%.14f',h)],['-d',dev],opt,filename)
      feval(callerfcn, 'status', 'Print to ps file done.')
   else
      feval(callerfcn, 'status', 'Print to ps file cancelled.')
   end
else %other file type
   print(['-f',sprintf('%.14f',h)],['-d',dev],opt,['fdidgui.',dev])
end %print to printer or file

if isempty(dev) %if directly using print command
  set(hoh,'visible','on')
  if ~isempty(hbc), set(hbc,'background',backgsave), end
  set(h,'color',colorsave) %restore figure color
end %if isempty(dev)
%
%Restore (who knows why this is necessary)
set(h,'units',u), set(h,'position',posused)
%
%End of file
