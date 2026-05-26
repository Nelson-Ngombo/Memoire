function newh=copyaxes(hfrom,hto)
%COPYAXES  Zoom object in axes (hfrom) to axes (hto)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 29-Mar-1999, IK

pos=get(hto,'position'); units=get(hto,'units'); tag=get(hto,'tag');
hfig=get(hto,'parent');
delete(hto)
newh=copyobj(hfrom,hfig);
set(newh,'units',units,'pos',pos,'tag',tag)
zoom(get(newh,'parent'),'on')
%Set ploteltf texts visible
set(findall(newh,'tag','ploteltftext'),'visible','on')
