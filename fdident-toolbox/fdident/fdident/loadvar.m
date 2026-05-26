function variable=loadvar(matfile,varname)
%LOADVAR Read the value of a single variable from a mat-file.
%
%       variable=LOADVAR(matfile,varname)
%
%       Output argument:
%       variable = the variable to take the value of the loaded one
%
%       Input arguments:
%       matfile = name of the mat-file. Default extension: .mat
%       varname = name of the variable in the mat-file
%           if varname is 'who' or 'whos', the command will be executed.
%
%       The file has to be somewhere within the path of matlab, or the
%       path is to be explicitly given.
%
%       Usage: variable=loadvar(matfile,varname);
%       Example: model=loadvar('inpchmod','inpchanz');
%
%       See also: SAVEVAR.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 30-Oct-2001

if nargin<2, error('not enough input arguments'), end
if isempty(varname), error('varname is empty'), end
if ~isstr(varname), error('varname is not a string'), end
donotusethisnamemf=matfile;
donotusethisnamev=varname;
if any(findstr('.',donotusethisnamemf))
  load(donotusethisnamemf,'-mat')
else
  load([donotusethisnamemf,'.mat'],'-mat')
end
clear donotusethisnamemf varname
if strcmp(donotusethisnamev,'who')
  clear donotusethisnamev matfile
  who
elseif strcmp(donotusethisnamev,'whos')
  clear donotusethisnamev matfile
  whos
else
  if exist(donotusethisnamev)==0
    error(['Variable ''',donotusethisnamev,''' does not exist in file ''',...
        matfile,''''])
  end
  eval(['variable=',donotusethisnamev,';'])
end
%%%%%%%%%%%%%%%%%%%%%%%% end of loadvar %%%%%%%%%%%%%%%%%%%%%%%%
