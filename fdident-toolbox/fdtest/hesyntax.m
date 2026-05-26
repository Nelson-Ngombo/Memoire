%HESYNTAX Load and syntactical check function m-files of the FDIDENT Toolbox
%       Frequency Domain System Identification Toolbox

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 11-Apr-2005

disp('Check syntax of function M-files ...')
MatlV=version;
%
disp('Compiling toolbox functions to pre-parsed pseudo-code (P-file) ...')
for mfs={'elis.m','dibsdemo.m','hesyntax.m'}
  mfs=mfs{1};
  wfun=which(mfs);
  if ~isempty(wfun)
    dirn=wfun(1:end-length(mfs));
    fnames=dir(dirn);
    for ii=1:length(fnames)
      fname=fnames(ii).name;
      dbs=dbstack;
      if length(dbs)>=2
        if str2num(MatlV(1:3))<=6.5, istestfd=any(findstr(dbs(2).name,[filesep,'testfd.m']));
        else istestfd=strcmp(dbs(2).file,'testfd.m');
        end
      else
        istestfd=0;
      end
      if (length(fname)>2)&any(findstr('.m',fname(end-1:end)))&...
          ~strcmp(fname,'helcptst.m')&~strcmp(fname,'hesyntax.m')&...
          (~istestfd|~strcmp(fname,'testfd.m'))&...
          ~strcmp(fname,'fdguitstd.m')
        disp(fname)
        pcode([dirn,fname])
        delete([fname(1:end-2),'.p'])
        %fprintf('.')
      end
    end %for ii
  end %for mfs
end
%fprintf('\n')
%
%clear functions
disp(['Syntax of all Frequency Domain System Identification Toolbox',...
       ' functions OK'])
%%%%%%%%%%%%%%%%%%%%%%%% End of hesyntax %%%%%%%%%%%%%%%%%%%%%%%%%%%%
