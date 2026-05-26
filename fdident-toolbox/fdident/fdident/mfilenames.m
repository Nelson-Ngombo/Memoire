function list = mfilenames(dirn)
%MFILENAMES DIR  displays the list of M-files in a directory

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1996-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Aug-2004

dirname={}; priv=0; ind=[];
if nargin==0, dirn=''; end
if isempty(dirn), dirn='.'; end
p=[pathsep,path,pathsep];
%
if any(findstr(dirn(1),'@#')) %class directory
  if any(findstr([dirn,'|'],'private|'))
    priv=1;
    dn=which(dirn(2:end-8));
  else %regular class dir
    dn=which(dirn(2:end));
  end
  if ~isempty(dn)
    indp=findstr(dn,filesep);
    dirname={[dn(1:max(indp)-1)]};
  else
    priv=0;
  end
elseif any(findstr([dirn,'|'],'private|'))
  priv=1; dirn=dirn(1:end-8);
end
if isempty(dirname), ind=findstr(p,[dirn,pathsep]); end
for indi=ind
  indp=findstr(p,pathsep);
  indp1=max(find(indp<indi));
  indp2=min(find(indp>indi));
  dirname=[dirname;{p(indp(indp1)+1:indp(indp2)-1)}];
end
%
if isempty(ind)&isempty(dirname)
  for typ=1:2 %don't add pwd or do add
    if typ==1, dirni=dirn; else dirni=[pwd,filesep,dirn]; end
    indp=findstr(dirni,filesep);
    if ~isempty(indp)
      dirtest=dirni(1:indp(end)-1);
      d=dir(dirtest);
      dn={d.name};
      inds=strmatch(dirni(indp(end)+1:end),dn);
      if ~isempty(inds)
        dirname={dirni};
        break
      end
    end
  end %for typ
end
%
if isempty(dirname), error(['Cannot find directory ''',dirn,'''']), end
%
for ii=1:length(dirname)
  dn=dirname{ii};
  if isempty(dn), error('dn is empty: programming error'), end
  if priv, dn=[dn,filesep,'private']; end
  disp(['M-files in ''',dn,''':'])
  if ~strcmp(dn(end),filesep), dn=[dn,filesep]; end
  dir([dn,'*.m'])
  d=dir([dn,'private']);
  if ~isempty(d)
    disp(['Private directory ''',dn,'private'' also exists'])
  end
end %for ii
