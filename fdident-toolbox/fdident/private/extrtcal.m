function [CallerFcn, hCurObj, hCurWin, SelType, XtraParam]=extrtcal(varargin)
% extract fdtool callback parameters
% helper function of FDTOOL

% input:  callback parameters from wrapper
% output: callback parameters

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 14-Febr-2000, GYS

if length(varargin)==7 % special call, seltype is forced (used in caem's rotate3d)
  CallerFcn=varargin{1};
  XtraParam=varargin{3};
  CurObj=varargin{6};
  SelType=varargin{7};
  hCurObj=findall(0, 'tag', CurObj);
  [hCurObj,hCurWin]=FindCaller(CurObj);
else
  CallerFcn=varargin{1};
  CurObj=varargin{end};
  [hCurObj,hCurWin]=FindCaller(CurObj);
  ObjType=get(hCurObj, 'type');
  if isempty(ObjType),ObjType='';end
  SelType=get(hCurWin, 'selectiontype');
  if strncmp(computer,'MAC2',4)&strncmp(version,'5.2',3)&strncmp(CurObj,'rect',4)&strcmp(SelType,'normal')
    %For some reason, on a Mac SelType is wrongly normal, not alt...
    SelType='alt';
  end
  % find extraparam if necessary (and modify seltype, if necessary)
  switch ObjType
    case 'uicontrol'
      switch get(hCurObj, 'style')
        case 'edit'
          SelType='normal';
          XtraParam=(get(hCurObj, 'string'));
          if iscell(XtraParam)
            if isempty(XtraParam), XtraParam={''}; end
            XtraParam=XtraParam{1};
            if guiinfos('isdevelopment')& ~any(findstr(CurObj, 'fdtool_recorder'))
              warning('Possibly bad edit string !')
            end
          end
        case {'togglebutton', 'checkbox'}
          SelType='normal';
          XtraParam=num2str(get(hCurObj, 'value'));
        case 'listbox'
          % seltype may be open !!!  (doubleclick in import window on varname)
         %XtraParam=popupstr(hCurObj);
         %XtraParam=get(hCurObj,'String'); % modified by Zoltan 13/11/2004 multiple selection!
         %Corrected by Istvan
         objstr=get(hCurObj,'string');
         XtraParam=objstr(get(hCurObj,'value'));
         if iscell(XtraParam)&(length(XtraParam)==1), XtraParam=XtraParam{1}; end
      case 'frame'
         % seltype may be open !!!  (doubleclick on caem info text) 
         XtraParam=[];
      case 'popupmenu'
         SelType='normal';
         XtraParam=popupstr(hCurObj);
      otherwise
         SelType='normal';
         XtraParam=[];
      end
   case 'axes'
      XtraParam= varargin{end-1}; %used in freqsel
   case 'uimenu'   
      XtraParam=[]; 
      SelType='normal';
   otherwise
      XtraParam=[];
   end
end   
   
   
function [hCurObj, hCurWind]=FindCaller(tCurObj)
hCurObj=findall(0,'tag',tCurObj);
%Correction for window menu -> pulldown menu transition
if isempty(hCurObj)&any(findstr(tCurObj,'fdtool_menu_userlevel_'))
  hCurObj=findall(0,'tag','fdtool_menu_userlevel');
end
if isempty(hCurObj)   
   hCurObj=[];hCurWind=[];
   return
elseif length(hCurObj)>1 
   % we're in trouble, more objects with the same tag (name clash with another GUI)
   % find the real one here
   ix=[];
   WinTagList=guiinfos('allchild', 'fdtool_main');
   for ii=1:length(hCurObj)
      hFig=GetParentWin(hCurObj(ii));
      tFig=get(hFig, 'tag');
      if isInList(tFig, WinTagList)
         ix=[ix, ii];
      end
   end
   if isempty(ix)
      % parent window is missing from the list, very unlikely event
      error('Internal error: Name clash can not be resolved (1).')
   elseif length(ix)>1
      % more windows are open with the same tag -- shouldn't happen
      error('Internal error: Name clash can not be resolved (2).')
   else
      % we've found the real one !!
      hCurObj=hCurObj(ix);
   end
end
hCurWind=GetParentWin(hCurObj);



function hFig=GetParentWin(hObj)
h=hObj;
while ~strcmp(get(h, 'type'), 'figure')
   h=get(h, 'parent');
end
hFig=h;

function out=isInList(elem, list)
ii=1;out=0;
while ii<=length(list) & out==0
   out=strcmp(elem, list{ii}); ii=ii+1;
end