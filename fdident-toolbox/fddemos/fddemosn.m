function fddemosn(fname,starti)
%FDDEMOSN  Convert all toolbox data files
%
%       fname is the name of a MAT file in the directory
%       starti is the serial number of the first file which will be converted.
%
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 05-Jan-2000

if nargin<1, fname=''; end
if nargin<2, starti=[]; end
if isempty(fname), fname='aluplate.mat'; end
if isempty(starti), starti=1; end
if exist(fname)~=2, error(['File ''',fname,''' does not exist on the path']), end
%
if strcmp(computer,'PCWIN')
  system_dependent(7)
end
disp(['Convert all fiddata, tiddata, fidmodel objects in MAT-files ',...
    'to new format'])
disp(' ')
%
%Convert files from directory containing file given in fname
dirfdn=which(fname);
if strcmp(fname,'aluplate.mat')
   ind=findstr('newfddn',lower(dirfdn)); %check if newfddn is in the path
   if isempty(ind), error('Old file aluplate.mat not found'), end
end
dirfdn=dirfdn(1:end-length(fname));
%
fn=dir([dirfdn,'*.???']);
if isempty(fn), fn=dir([dirfdn,'*.mat']); end
iiv=starti:length(fn); clear starti
%iiv=[1:10];
for ii=iiv
  if (~fn(ii).isdir)&~any(findstr('.m|',[lower(fn(ii).name),'|']))
    str=load([dirfdn,fn(ii).name]);
    disp(' ')
    disp(['Converting file ',fn(ii).name,', for ii = ',num2str(ii),'.'])
    w=fieldnames(str);
    for iii=1:length(w)
      varn=w{iii}; var=getfield(str,varn);
      if isa(var,'tiddata'), var=tiddata(var);
      elseif isa(var,'fiddata'), var=fiddata(var);
      elseif isa(var,'iddat'), var=iddat(var);
      elseif isa(var,'fidmodel'), var=fidmodel(var);
      elseif isstruct(var)
        if isfield(var,'denom')
          var=fidmodel(var);
          obj='fidmodel';
        elseif isfield(var,'Coherence')
          var=fiddata(var);
          obj='fiddata';
        elseif isfield(var,'Ts')
          var=tiddata(var);
          obj='tiddata';
        elseif isfield(var,'Scales')
          var=iddat(var);
          obj='iddat';
        elseif isfield(var,'UserLevel')
          disp(['   Variable ''',varn,''': Contents of history file'])
          clear var %do not save
          obj='';
        elseif length(fieldnames(var))<5
          disp('   Structure, with a few fields:')
          var
          clear var %do not save
          obj='';
        else
          if strcmp(fname,'aluplate.mat')
            var
            error('Structure does not correspond to any fdident class')
          else
            disp('   Variable of unknown type:')
            var
            clear var %do not save
          end
        end
        if ~isempty(obj)
          disp(['   Structure is being converted to object ''',obj,''''])
        end
      else
        disp(['   Variable ',varn,' is of class ''',class(var),''''])
        clear var
      end
      if exist('var')==1
        eval([varn,'=var;'])
        save([dirfdn,fn(ii).name],varn,'-append')
        %save('matlab',varn,'-append')
        disp(['   Saving variable ''',varn,''' to file ''',...
            [dirfdn,fn(ii).name],''''])
      end
    end %for iii
  end
end %for ii
if strcmp(computer,'PCWIN')
  system_dependent(7)
end
clear functions
%
%End
