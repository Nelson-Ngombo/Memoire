function hh = guibar3(inx, iny, inz, axhandle, barwidth, tags, pieces)
%GUIBAR3 Prepare 3-dim plot of cost function values over models

%       Input arguments:
%       ...
%
%       Usage: hh = guibar3(inx, iny, inz, axhandle, barwidth, tags);
%       Example: 
%
%       See also: BAR3.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Roman
%       Last modified: 05-Apr-2000, IK

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(4,7); %Matlab 2016a or later
else ni=nargin; error(nargchk(4,7,ni)), %earlier
end
if nargin<5
   barwidth=0.8;
end;
ExternalMode=(length(axhandle)>1);

edgec = get(get(axhandle(1), 'parent'),'defaultaxesxcolor');
h = []; h1=[];
delete(allchild(axhandle(1)))
if ExternalMode, delete(allchild(axhandle(2))), end
 
set(axhandle, 'nextplot', 'add')

% cut bars which are too high
inz_modified=inz; indn0=find(inz>0);
if ~isempty(indn0), zmin=min(inz(indn0)); else zmin=0; end
limitz=zmin*50;
ix_high=find(inz>=limitz);
inz_modified(ix_high)=zeros(size(inz_modified(ix_high)));
zmax=max(inz_modified)*1.5;
inz_modified(ix_high)=ones(size(inz_modified(ix_high)))*zmax;
base_bar_size = 8;
bar_size = base_bar_size;

for i = 1:length(inx)
   if (pieces{i} ~= 1)
      bar_size = 6; %size of bars, fraction of 8
   end
end


for i = 1:length(inx)
   
   barwidth = bar_size/(9*pieces{i}+1);
   nth = findnth(tags{i});
   if isempty(nth)
      nth = 1;
   end
   
   if (pieces{i}/2 == round(pieces{i}/2))
      ycorr = iny(i) + (nth - round(pieces{i}/2))*(barwidth + barwidth/8) - (barwidth + barwidth/8)/2;
   else
      ycorr = iny(i) + (nth - round(pieces{i}/2))*(barwidth + barwidth/8);
   end
   
   [msg,x,y,xx,yy,linetype,plottype,barwidth,zz] = guimakebars(ycorr, inz_modified(i), barwidth, '3');
   if ~isempty(msg), error(msg); 
   end;
   
   [n,m] = size(y);
   % Create plot

   cc = ones(size(yy,1),4);
   
   if nargin<6  
      order=[num2str(iny(i)) '/' num2str(inx(i))];
   else %  use input 
      order=tags{i};
   end
   tag=['caem_bar3d[' order ']'];
   tag1=['external_caem_bar3d[' order ']'];
   buttonfcn= ['fdtool(''callback'',''caem'',''selectbar'', ''' order ''', ''' tag ''');'];
   buttonfcn1=['fdtool(''callback'',''caem'',''selectbar'', ''' order ''', [], [], ''' tag ''', ' ,... 
         'get(findall(0, ''tag'', ''caem_view_bar_figure''), ''SelectionType'')',...
         ');']; 
   % External window calls with tags of the internal bars !! 
   % Replay works on inner axes
   
   if isnan(inz(i))
      udat=struct('critval', inz(i), 'status', 'NORMAL');
      facec = guicolor('BAR_NaN');
   elseif inz(i) ~= inz_modified(i)
      udat=struct('critval', inz(i), 'status', 'CUT');
      facec = guicolor('BAR_CUT');
   else
      udat=struct('critval', inz(i), 'status', 'NORMAL');
      facec = guicolor('BAR_NORMAL');
   end
   h = [h, ...
         surface('Parent', axhandle(1), ...
         'xdata',xx+inx(i),'ydata',yy(:,(1:4)), ...
         'zdata',zz(:,(1:4)),'cdata',cc, ...
         'FaceColor',facec,'EdgeColor',edgec, ...
         'ButtonDownFcn', buttonfcn, ... 
         'UserData', udat,...
         'Tag',tag)];
   if ExternalMode
   h1 = [h1, ...
         surface('Parent', axhandle(2), ...
         'xdata',xx+inx(i),'ydata',yy(:,(1:4)), ...
         'zdata',zz(:,(1:4)),'cdata',cc, ...
         'FaceColor',facec,'EdgeColor',edgec, ...
         'ButtonDownFcn', buttonfcn1, ... 
         'UserData', udat,...
         'Tag',tag1)];
   end
   if length(h)==1, 
      set(axhandle,'clim',[1 2],...
         'nextplot', 'add',...
         'view', [-37.5,30],...
         'XGrid', 'on', 'YGrid', 'on','ZGrid', 'on',...
         'xdir','reverse','ydir','reverse');
   end

   mx(i)=inx(i);
   my(i)=iny(i);
   mz(i)=inz(i);
end;

%dx = diff(get(axhandle(1),'xlim'));
%dy = size(y,1)+1;
%set(axhandle,'PlotBoxAspectRatio',[dx dy (sqrt(5)-1)/2*dy])

mx=sort(unique(mx));
my=sort(unique(my));

for i=1:length(axhandle)
   set(axhandle(i),'xtick',mx,'xlim',[min(mx)-1 max(mx)+1]);
   set(axhandle(i),'ytick',my,'ylim',[min(my)-1 max(my)+1]);
   set(get(axhandle(i),'xlabel'),'string','den','tag','bar3_numtag');
   set(get(axhandle(i),'ylabel'),'string','num','tag','bar3_dentag');
end;

if nargout==1, hh = h; end

%


function nth = findnth(tag)
start = find(tag == '(');
stop =  find(tag == ')');
nth = str2num(tag(start:stop));

%End of file
