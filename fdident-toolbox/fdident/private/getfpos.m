function [pos,units]=getfpos
%GETFPOS  Return position of plot figure

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 30-Sep-1998

ss=get(0,'screensize');
if any(ss(3:4)<[640,480])
   warning('The resolution is not enough for proper GUI plots')
end
if any(ss(3:4)<=[640,480])&isequal(guirecrd('getlecturemode'),1)
   pos=[2,29,638,414];
   units='pixels';
else
   pos=get(0,'defaultfigureposition');
   units=get(0,'defaultfigureunits');
end
%