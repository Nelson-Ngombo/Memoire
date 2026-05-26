function out=guicolor(p1);
% GUICOLOR FDtool color manager
%
%       Input arguments:
%       p1 - tag of object
%            Possibilities:
%
%
%       See also: GUIBAR3, FDTOOL.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Roman
%       Last modified: 05-Apr-2000, IK

c=MakeColors;
dampc=0.5; %damp colors to be able to print

switch p1
case 'BAR_SELECTED'
   out=[1 dampc dampc];
case 'BAR_NORMAL'
  out=[dampc-0.15 dampc-0.15 1];
case 'BAR_BEST'
   out=[dampc dampc 1];
   out=[dampc 1 1];
case 'BAR_CUT'
  out=[dampc dampc 1]; 
case 'BAR_NaN'
   out=c.mygrey;
   
case 'BOX_COLOR_SELECTABLE'
   out=c.myblue;
case 'BOX_COLOR_DONE'
   out=c.mygreen;
case 'BOX_COLOR_UNSELECTABLE'
   out=c.mygrey;
case 'BOX_COLOR_BUSY'
   out=c.mycyan;
   
   
case 'COLOR_ARR_ACTIVE_DATA'
   out=c.mygreen;
case 'COLOR_ARR_PASSIVE_DATA'
   out=c.mylightgreen;
case 'COLOR_ARR_NODATA'
   out=c.mygrey;
case 'COLOR_ARR_ACTIVE_LOADED_DATA'
   out=c.mydarkgreen;
   
otherwise
   out='y';
%   warning(['Bad Color Manager call: ' p1])
end




function c=MakeColors
% factory color settings for FDTool

%c.myblue= [0.2 0.7 0.8];
c.myblue= [0 0.7 .7];
c.myred= [0.9 0.2 0.2];
c.mykhak= [0.7 0.8 0];
c.myyel= [1 0.8 0];
c.mycyan= 'c';
c.mygreen= [0 1 0];
c.mylightgreen= [0.8 1 0.8];
%c.mydarkgreen= [0.2 .75 .14];
c.mydarkgreen= [.3 .75 0];
%c.mygrey= [0.5647 0.6902 0.6588];
c.mygrey= [1 1 1]/sqrt(2);
