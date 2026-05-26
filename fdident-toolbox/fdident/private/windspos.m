function pos=windspos(p1, p2, p3)
% fdtool internal function
% returns the screen coordinates of the window in pixels

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 20-Sep-2001

RootUnit=get(0,'units');
set(0,'units', 'pixels');
ScreenSize=get(0,'screensize');
set(0, 'units', RootUnit);

if strcmp(p1, 'fdtool_arrowdlg')
   arrnum=p2;
   if arrnum>100
      arrstr=['arr' num2str(arrnum-100)];
      sender='gettime_main';
   else
      arrstr=['l' num2str(arrnum)];
      sender='fdtool_main';
   end
   ScrCord=GetObjectXY(sender, arrstr);
   dx=140; dy=320;
%   if p2==9 | p2==11
%      dy=360;
%   else
%      dy=320;
%   end
   pos=[ScrCord- [0 dy], [dx dy]];

elseif strcmp(p1, 'gettdatafig')
   ScrCord=GetObjectXY('gettime_main', 'rect_gettdata');
   dx=170; dy= 225;
   pos=[ScrCord- [0 dy], [dx dy]];


elseif strcmp(p1, 'fdtool_getcaldatafig')
   ScrCord=GetObjectXY('fdmeasurement_main', 'fdmeas_uic_calpb');
   dx=170; dy= 200;
   pos=[ScrCord- [0 dy], [dx dy]];

elseif strcmp(p1, 'recorder')
   pos=[ScreenSize(3)-650 100 600 300];
end


function ScrCord=GetObjectXY(tFig, tObj)
% ########################################################
% where is the centre of the object ?
% ########################################################

hFig=findobj(allchild(0), 'flat', 'tag', tFig);
hObj=findobj(hFig, 'tag', tObj);

if isempty(hFig)
   error(['INTERNAL ERROR in windspos: figure not found: ' tFig])
   return
end
if isempty(hObj)
   error(['INTERNAL ERROR in windspos: patch oject is missing' tObj])
   return
end
RootUnit=get(0,'units');
set(0,'units', 'pixels');
ScreenSize=get(0,'screensize');
FigPos=get(hFig, 'position');
switch get(hObj, 'type')
case 'patch'
   Ax=get(hObj,'parent');
   AxUnit=get(Ax, 'units');
   set(Ax, 'units', 'pixels');
   AxPos=get(Ax,'position');
   AxX =get(Ax, 'xlim');
   AxY =get(Ax, 'ylim');
   ObjX=get(hObj, 'xdata'); ObjY=get(hObj, 'ydata');
   CentX=sum(ObjX)/length(ObjX);
   CentY=sum(ObjY)/length(ObjY);
   XPix=(CentX-AxX(1))/diff(AxX)*AxPos(3);
   YPix=(CentY-AxY(1))/diff(AxY)*AxPos(4);
   ScrCord=AxPos(1:2)+FigPos(1:2)+[XPix YPix];
   set(Ax, 'units', AxUnit);
case 'uicontrol'
   ObjUnit=get(hObj, 'unit');
   set(hObj, 'unit', 'pixel');
   ObjPos=get(hObj, 'position');
   set(hObj, 'unit', ObjUnit);

   ScrCord=FigPos(1:2)+ObjPos(1:2);
end


set(0,'units', RootUnit);
