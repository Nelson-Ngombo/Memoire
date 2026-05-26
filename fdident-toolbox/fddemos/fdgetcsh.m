%FDGETCSH %Open dialog box and get data in an fdident playshow

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-Mar-2000, I. Kollar

if ~exist('fdcoursdef'), fdcoursdef=''; end
command=' '; csugg=''; hps=gcf;
while ~isempty(command)
   hftitle='Your plots';
   hf=findall(0,'name',hftitle);
   if isempty(hf), hf=findall(0,'name','ELiS Run'); end
   if isempty(hf), hf=figure; end
   set(hf,'name',hftitle,'numbertitle','off'), pause(0)
   figure(hf), clf,
   iterctrl('initialize',hf); %iterctrl will not duplicate
   if strcmp(mode,'cont')
      command=fdcoursdef;
      eval(command)
      drawnow, pause(0)
   else
      ok=0;
      titl='Your attempts'; q={'Your command'};
      while ok==0,
         figure(hf)
         command=inputdlg(q,titl,1,{csugg});
         ok=1; if isempty(command), command=''; else command=command{1}; end,
         if strcmp(command,' '), csugg=fdcoursdef; command='   ';
         elseif isempty(command), command=fdcoursdef;
         else csugg='';
         end,
         eval(command,'ok=0;'), %disp(['Command: ''',command,'''']),
         if ok==0, csugg=command; q={'Error: correct it please'};
         else
            delete(findall(hf,'string','Close')); %delete Close button
            if length(get(hf,'children'))>1 %something in addition to iterctrl
               ha=findall(hps,'type','axes'); delete(allchild(ha))
               figure(hf)
            end,
         end,
      end,
   end,
   if ~isempty(command)&~strcmp(command,'   ')&(length(get(hf,'children'))>1)
      pause,
   end,
   if strcmp(command,fdcoursdef), command=''; end
end
