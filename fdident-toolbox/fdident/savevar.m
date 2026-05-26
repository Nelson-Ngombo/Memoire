function savevar(matfile,varname,varvalue)
%SAVEVAR Save a single variable to an existing mat-file.
%
%       SAVEVAR(matfile,varname,varvalue)
%
%       Side effects: string variable in the file: donotusethisnamefns,
%       variables in the file: donotusethisnamevns,donotusethisnamevvs
%
%       Input arguments:
%       matfile = full name of the mat-file
%       varname = name of the variable in the mat-file
%       varvalue = the desired value of the variable. If varvalue is not
%           given, the variable will be deleted from the file.
%
%       Usage: savevar(matfile,varname,varvalue)
%       Example: x=1; save savevtst.mat x, savevar('savevtst.mat','x',10)
%                savevar('savevtst.mat','y',20)
%
%       See also: LOADVAR.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 04-Oct-1996

if nargin<2, error('not enough input arguments'), end
if isempty(varname), error('varname is empty'), end
if ~isstr(varname), error('varname is not a string'), end
donotusethisnamefn=matfile;
donotusethisnamevn=varname;
if nargin==3, donotusethisnamevv=varvalue; end
clear matfile, clear varname, clear varvalue
if isempty(find(donotusethisnamefn=='.'))
  disp(['Warning! File name ''',donotusethisnamefn,...
        ''' has no extension in savevar'])
end
if exist(donotusethisnamefn)~=2
  error(['file ''',donotusethisnamefn,''' does not exist'])
end
load(donotusethisnamefn,'-mat') %may spoil donotusethisnamefns
if ~exist('donotusethisnamevv') %variable to be deleted
  if exist(donotusethisnamevn)~=1
    error(['variable ''',donotusethisnamevn,''' does not exist in file'])
  end
  clear(donotusethisnamevn)
else
  eval([donotusethisnamevn,'=donotusethisnamevv;'])
  %The next lines restore the actual arguments if these are just variables
  %Not used from Matlab 4.0
  donotusethisnamevns=donotusethisnamevn; clear donotusethisnamevn
  donotusethisnamevvs=donotusethisnamevv; clear donotusethisnamevv
end
delete(donotusethisnamefn) %try to delete old file
if exist(donotusethisnamefn)==2
  error(['file ''',donotusethisnamefn,''' is in a wrong directory'])
end
donotusethisnamefns=donotusethisnamefn; %restore value
clear donotusethisnamevn, clear donotusethisnamevv, clear donotusethisnamefn
clear nargin, clear nargout
save(donotusethisnamefns)
%
%Restore the actual arguments (for PC-Matlab, 386-Matlab)
matfile=donotusethisnamefns;
if exist('donotusethisnamevns')==1,
  varname=donotusethisnamevns;
end
if exist('donotusethisnamevvs')==1,
  varvalue=donotusethisnamevvs;
end
%%%%%%%%%%%%%%%%%%%%%%%% end of savevar %%%%%%%%%%%%%%%%%%%%%%%%
