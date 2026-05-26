function rbtag(sender)
% FDID GUI radio button group fcn
% Private function of the FDID Toolbox

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon 1997-1999
%       Last modified: 18-Mar-1999, GYS

me = findall(0, 'tag',sender);
if isempty(me)&strcmp(sender,'essd_uic_fgrb(3)')
  me = findall(0, 'tag','essd_uic_fgrb(3)_randomized');
end
fig=get(me, 'Parent');
if length(me)>1
   % trouble: more rb's with the same tag; try to find the right one
   tGoodFig=evalin('caller','Me');
   ii=1;ix=[];
   while ii<=length(fig)&isempty(ix)
      if strcmp(get(fig{ii}, 'tag'), tGoodFig)
         ix=ii;
      end
      ii=ii+1;
   end
   me=me(ix); fig=get(me, 'parent');  
end

groupID=get(me,'userdata');
others=findobj(allchild(fig),'flat','userdata',groupID);
if ~any(findstr(class(others),'matlab.ui.control.WebComponent')), set(others,'Value',0); end
set(me,'Value',1);

