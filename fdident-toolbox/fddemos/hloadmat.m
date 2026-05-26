function s=hloadmat(runmod)
%HLOADMAT  Load all MAT-files to assure that all files are readable
%
%       If runmod is 'nomesg', it runs without informative messages
%       The result is 1 if everything was OK.

if nargin<1, runmod=''; end
if ~isstr(runmod), error('runmod is not a string'), end
if nargout>0, s=0; end

dirnold='';
for fn={'aluplate.mat','fdtlogo.mat','elec_rawd.mat'}
  fn=fn{1};
  fnl=which(fn,'-all');
  if length(fnl)>1
    fnl
    error('Two MAT-files are found')
  elseif ~isempty(fnl)
    fnl=fnl{1};
    ind=findstr(fn,fnl);
    dirn=fnl(1:ind(end)-1);
    if ~strcmp(dirn,dirnold)
      if ~strncmp(runmod,'nomesg',3)
        disp(['Testing MAT-files in directory ''',dirn,''' ...'])
      end
      dirs=dir([dirn,'*.mat']);
      for ii=1:length(dirs)
        if strcmp(dirs(ii).name,'fdtlogo.mat'), ftype='jpg';
        elseif strcmp(dirs(ii).name,'notch.mat'), ftype='pcx';
        else ftype='MAT-';
        end
        if ~strncmp(runmod,'nomesg',3)
          disp(['  loading ',ftype,'file ''',dirs(ii).name,''' ...'])
        end
        save hreadmat.mat
        if ~strcmp(dirs(ii).name,'fdtlogo.mat')&~strcmp(dirs(ii).name,'notch.mat')
          load([dirn,dirs(ii).name]);
          vars=whos('-file',[dirn,dirs(ii).name]);
          for iii=1:length(vars)
            varn=vars(iii).name;
            eval(['varv=',varn,';']);
            if isa(varv,'fidmodel')|isa(varv,'tiddata')|isa(varv,'fiddata')
              disp(['    Consistency check, file ',dirs(ii).name,', variable ',varn])
              %~varv.consistency
              %Error: Too many out arguments for autoorder_data.mat(z_domain3_orthopol)
              if ~get(varv,'consistency')
                error(['Consistency error, file ',dirs(ii).name,', variable ',varn])
              end
            end
          end
          clear
        else
          logoname=which(dirs(ii).name,'-all');
        logo=imread(logoname{1},ftype);
        end
        load hreadmat.mat
      end %for ii
      delete hreadmat.mat
    end
  end
end
if nargout>0, s=1; end
