function garrinfo(arrnum, p2, p3)
% GARRINFO information on fdidgui arrow data
% arrnum 1..11 on main window, 101..104 on gettime window, 1001 on p2
% If arrnum=1001 then p2 is the data , and p3 will be the first line in the info str

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-99
%       All rights reserved.
%       $Revision: $
%       Written by Gy. Simon
%       Last modified: 07-Jan-2000, GYS

switch arrnum
case {1}
   source='OUTPUT_excitation';
   infoarr='Output arrow of ESSD';
case {2}
   source='OUTPUT_excitation';
   infoarr='Input arrow of RTDD';
case {3}
   source='OUTPUT_excitation';
   infoarr='Input arrow of RFDD';
case {4}
   source='OUTPUT_gettime';
   infoarr='Output arrow of RMTDD';
case {5}
   source='OUTPUT_getfreq';
   infoarr='Output arrow of RMFDD';
case {6, 7, 8}
   source='OUTPUT_average';
   infoarr='Output arrow of VA';
case {9}
   source='OUTPUT_select';
   infoarr='Output arrow of EPM';
case {10}
   source='OUTPUT_aided';
   infoarr='Output arrow of CAMS';
case {11}
   source='OUTPUT_compare';
   infoarr='Output arrow of ECPM';
case {101}
   source='DATA_gotdata';
   infoarr='Output arrow of Get Data';
case {102}
   source='DATA_segmenteddata';
   infoarr='Output arrow of Segmentation';
case {103}
   source='DATA_converteddata';
   infoarr='Output arrow of Convert to Freq. Domain';
case {104}
   source='DATA_selecteddata';
   infoarr='Output arrow of Frequency Select';
case {1001}
   source=p2;
   infoarr=p3;
otherwise
   error(['Internal error. Garrinfo called with incorrect input: ' num2str(arrnum) '.'])
end
if arrnum < 100
   title='Arrow info';
   arrstr=guidtard('fdtool_main', 'ARRMGR'); ix=arrnum;
elseif arrnum < 200
   title='Arrow info';
   arrstr=guidtard('gettime_main', 'ARRMGR'); ix=arrnum-100;
else
   title='Data info';
   % not arrow call
   arrstr='C'; ix=1;
end
arrstatus=arrstr(ix);
switch arrstatus
case 'a'
   infoarr1='This arrow contains active data.';
case 'A'
   infoarr1='This arrow contains imported active data.';
case 'p'
   infoarr1='This arrow contains passive data.';
case 'P'
   infoarr1='This arrow contains imported passive data.';
case 'C'
   infoarr1='';
case '-'
   infoarr1='This arrow contains no data.';
otherwise
   error(['Interal error: bad arrow status of arrow #' num2str(arrnum)])
end
if ~strcmp(arrstatus, '-')
   if arrnum < 100;
      arrdata=guidtard('fdtool_main', source); 
   elseif arrnum < 200
      arrdata=guidtard('gettime_main', source); 
   else
      arrdata=source;
   end
else
   arrdata='';   
end
infoarr=sprintf('%s\n%s\n', infoarr, infoarr1);

if isempty(arrdata)
   infoarr=sprintf('%s\n%s', infoarr, 'Empty.');
elseif isa(arrdata, 'fidmodel')
   infoarr=sprintf('%s\n%s', infoarr, info(arrdata,guiinfos('userlevel')));
elseif isa(arrdata, 'iddat')
   infoarr=sprintf('%s%s',infoarr,info(arrdata));
else
   error(['Unknown class ',class(arrdata)])  
end
helpwin(infoarr, title) % call MATLAB's help window

%End of garrinfo