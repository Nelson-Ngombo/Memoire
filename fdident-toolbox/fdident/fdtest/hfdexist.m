function hfdexist
%HFDEXIST Existence of all the function M-files of the fdident toolbox

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Mar-2000

disp('Existence of all the fdident function M-files ...')
%
if exist(['fdident',filesep,'Contents'])~=2,
  disp(['Warning: Contents is missing: exist(''fdident',filesep,...
      'Contents'')=',int2str(exist(['fdident',filesep,'Contents']))])
end
if exist(['fdident',filesep,'Readme'])~=2,
  disp(['Warning: Readme is missing: exist(''fdident',filesep,...
      'Readme'')=',int2str(exist(['fdident',filesep,'Readme']))])
end
%
mfiles=hfdfiles;
for ii=1:length(mfiles)
  if exist(mfiles{ii})==6, delete([mfiles{ii},'.p']), end
  if exist(mfiles{ii})==6, error([mfiles{ii},'.p is on the path']), end
  if exist(mfiles{ii})~=2, error([mfiles{ii},' is missing']), end
end
%
if exist('corrtest.m')
  if exist('inpchan.mat')~=2, error('File ''inpchan.mat'' is missing'), end
  if exist('robotarm.mat')~=2, error('File ''robotarm.mat'' is missing'), end
  if exist('bandpass.mat')~=2, error('File ''bandpass.mat'' is missing'), end
else
  if exist('inpchan.fbn')~=2, error('File ''inpchan.fbn'' is missing'), end
end
%
if exist('corrtest.m')
  if exist('fdtool.m')~=2, error('File ''fdtool.m'' is missing'), end
  if exist(['private',filesep,'guirecrd.m'])~=2
    error(['File ''private',filesep,'guirecrd.m'' is missing'])
  end
end
%
%Check for proper place of loadasc.m
whichloadasc=which('loadasc');
whichploteltf=which('ploteltf');
%Check if path is identical
if ~strcmp(whichloadasc(1:end-9),whichploteltf(1:end-10))
  errm=sprintf(['loadasc is not in the fdident toolbox:\n  ',whichloadasc]);
  error(errm)
end
%
%End of hfdexist
