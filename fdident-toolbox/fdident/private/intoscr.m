function intoscr (taglist)
% intoscr(taglist) 'draws' the figures specified with their tags
% into the display area.
% taglist is a single element or a cell array.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 22-Nov-2003, IK

%    'freqsel2fig'
%    'fdtool_main'
%    'average_main'

yrec_base=100; % This is the base y position of the recorder.
recpb_dy=40;  % This is the height the recorder button.

if ~iscell(taglist)
   taglist={taglist};
end
unit=get(0,'unit'); set(0, 'unit', 'pixel');
screen=get(0,'ScreenSize'); set(0, 'unit', unit);
maxx=screen(3); % in pixels
maxy=screen(4);

if isrecon
   %old+new tags...
   h=[findall(0, 'tag','fdtool_recorder_fig');
     findall(0, 'tag','guirecrd_fdtool')];
   pos=get(h, 'position');
   yrec=pos(2);
else
   yrec=0;
end;

for i=1:length(taglist)
   h=findobj(allchild(0),'flat','tag', taglist{i});
   if isempty(h)
      pause(1), 
      h=findobj(allchild(0),'flat','tag', taglist{i});
   end
   if ~isempty(h)
      unit=get(h, 'unit'); set(h, 'unit', 'pixel');
      pos=get(h, 'position');
      x=pos(1);
      y=pos(2);
      dx=max(1,pos(3));
      dy=max(1,pos(4));
      
      % If the recorder is on, and it is in the original y position,
      % then the function will uncover the recorder buttons.
      
      if (isrecon & (yrec <= yrec_base))
         if (y < yrec_base+recpb_dy+20)
            yn=yrec+recpb_dy+20;
            if yn+dy<maxy
               y=yn;
            end;
         end;
      end;
      
      if x < 0 x=3; end;
      % isrecord returns TRUE if the recorder is active, FALSE otherwise
      if (y < 0)
         y=3;
      end;
      if (x+dx > maxx), x=maxx-dx; end;
      extray=40;
      extray=75;
      if (y+dy > maxy-extray), y=maxy-dy-extray; end;
      y=max(y,35);
      % Here the external size of the window would be needed.
      % However, the position coordinates give back the interior size.
      % For this purpose the header and menu height has to be compensated.
      set(h,'position', [x y dx dy]);
      set(h, 'unit', unit);
   else
      warning(['Cannot find figure with tag ''',taglist{i},''''])
   end
end %for i
   

function b=isrecon()

%old+new tags...
h=[findall(0, 'tag','fdtool_recorder_fig');
  findall(0, 'tag','guirecrd_fdtool')];
if isempty(h)
   b=0;
else
   b=1;
end;
