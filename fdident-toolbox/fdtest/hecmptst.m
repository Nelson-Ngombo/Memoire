%HECMPTST Compile function m-files of the FDIDENT Toolbox to C files
%       Frequency Domain System Identification Toolbox

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1994-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Aug-1999

disp('File hecmptst')
MatlV=version; if length(MatlV)<4, MatlV=[MatlV,'   ']; end
%
if ~(exist('mcc')>=2)
  disp('Warning! Compiler mcc does not exist')
  return
end
%
disp('Compiling toolbox functions to C-code ...')
dirs={};
%for dfn={'elis.m'}
for dfn={'elis.m','orthopol.m','fdtool.m','fddgui1.m',...
      'fidmodel.m','iddat.m','fiddata.m','tiddata.m'}
  dfn=dfn{1};
  dfnall=which(dfn,'-all');
  if length(dfnall)>1, error(['More than one file ''',dfn,''' was found']), end
  dfnall=dfnall{1};
  ind=find(dfnall==filesep);
  dirn=dfnall(1:ind(end)-1);
  if ~any(strmatch(dirn,dirs)) %only if directory was not yet done
    dirs=[dirs;{dirn}];
    fprintf('\n'), disp(['Check M-files in directory ',dirn])
    s=dir([dirn,filesep,'*.m']);
    for ii=1:length(s) %directory cycle
      fn=s(ii).name;
      if ~any(strmatch(lower(fn),{'contents.m','readme.m',...
            'elisrmt.m','elisdrmt.m','elisfiti.m','elisobj.m','fdlicens.m',...
            'fdguitst.m',...
            'fidmodelh.m','iddath.m','fiddatah.m','tiddatah.m'}))&...
          ~any(findstr([fn,'|'],'def.m|'))
        fnl=[dirn,filesep,s(ii).name];
        %disp(['Compiling file ',fn,'...'])
        disp(['Compiling file ',fnl,'...'])
        %feval('mcc','-t','-L','C',fnl)
        mcc('-t','-L','C',fnl)
        fnsh=fn(1:end-2);
        delete(['*',fnsh,'.c'])
      end
    end %for ii
  end %if dir was not yet done
end %for dfn
delete(['*.h'])
%fnl='c:\work\fdident\fdident\@iddat\eq.m'; mcc('-t','-L','C',fnl)
%%%%%%%%%%%%%%%%%%%%%%%% End of hecmptst %%%%%%%%%%%%%%%%%%%%%%%%%%%%