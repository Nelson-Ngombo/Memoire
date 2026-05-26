function hexecshow(file,mode)
%HEXECSHOW Execute commands from slideshow
%
%       mode: 'init' - start run from beginning of file
%             'step' - run show step by step (default)
%             'cont' - run show until end
%
%       Usage: hexecshow(file,mode)
%       See also: PLAYSHOW, MAKESHOW

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Mar-2000, I. Kollar

if nargin<2, mode=''; end, if isempty(mode), mode='step'; end

if ~strcmp(mode,'step')
   if exist('execshow.mat'), delete execshow.mat, end
else %step
   if exist('execshow.mat'),
      filein=file;
      load execshow.mat,
      if ~strcmp(filein,file), clear slidei rowi, end
   end
end
if ~exist('slidei'), slidei=1; end
if ~exist('rowi'), rowi=1; end
slide=eval(file);

phswtitle='PlayHist Simulation Window';
hphsw=findall(0,'Name',phswtitle);
if isempty(hphsw), hphsw=figure; end
set(hphsw,'numbertitle','off','Name',phswtitle,'tag','playhist')
pos=get(hphsw,'position');
pos(1:2)=pos(1:2)-0.1*pos(3:4);
if pos(3)<=0, pos(3)=1; end
if pos(4)<=0, pos(4)=1; end
set(hphsw,'position',pos);

hftitle='Your plots';
hf=findall(0,'Name',hftitle);
if isempty(hf), hf=figure; set(hf,'numbertitle','off','Name',hftitle), end
figure(hphsw), clf, subplot(2,1,1), drawnow

cl=clock; pause(3); cl2=clock;
if etime(cl2,cl)>2, pausestate='on'; else pausestate='off'; end

if strcmp(mode,'cont'), pause off, else pause on, end

for slidei=slidei:length(slide)
   disp(['Slide: ',num2str(slidei)])
   slidecode=slide(slidei).code;
   for rowi=rowi:size(slidecode,1)
      if isempty(slidecode{rowi})
         disp('  Command empty')
      else
         disp(['  Command: ',slidecode{rowi}])
      end
      if ~strcmp(mode,'cont'), save execshow, end
      eval(slidecode{rowi})
      if strcmp(mode,'cont'), drawnow, end
   end %for rowi
   stx=slide(slidei).text;
   if ~isempty(stx)
      disp(['  Slide ',num2str(slidei),' text:'])
      for ii=1:size(stx,1)
         %if isunix, disp(['    ',stx{ii}]) %unix wraps by itself
         %else
            s=stx{ii}; psh='';
            txtl=73;
            while ~isempty(s)
               if length(s)<=txtl, ind=[];
               else ind=max(find(s(1:min(73,length(s)))==' '));
               end
               if isempty(ind), ssh=s; s='';
               else ssh=s(1:ind-1); s(1:ind)='';
               end
               disp([psh,'    ',ssh])
               psh='  ';
            end %while
         %end
      end
   else
      disp('  Slide text empty')
   end
   if ~strcmp(mode,'cont')
      %if slidei<length(slide)
         disp('  Wait for a key...')
      %else
      %   drawnow, pause(0)
      %end
      pause
   else drawnow %plot even for test
   end
   rowi=1;
end %for slidei
if ishandle(hphsw), delete(hphsw), end
if ishandle(hf), delete(hf), end
pause(pausestate)
%
%End of file
