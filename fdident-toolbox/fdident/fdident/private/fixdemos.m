function fixdemos(demo)
%FIXDEMOS Restore demo file(s) to be loadable from Matlab 5.2

if nargin<1, demo='';
elseif ~any(findstr(lower(demo),'.mat')), demo=[demo,'.mat'];
end
fullfn=which('aluplate.mat','-all');
if length(fullfn)>1, error('Several aluplate.mat files found')
end
demodir=fullfn{1}(1:length(fullfn{1})-13);

if isempty(demo), allfiles=dir(demodir);
else
  allfiles=dir([demodir,filesep,demo]);
  if isempty(allfiles), error(['File ',demodir,filesep,demo,' not found']), end
  ind=find([allfiles.name,' ']==filesep);
  if ~isempty(ind)
    allfiles.name=allfiles.name(ind(length(ind))+1:length(allfiles.name));
  end
end

for ii=1:length(allfiles)
  name=allfiles(ii).name;
  if ~strcmp(name(1),'.')&any(findstr('.mat ',[lower(name),' ']))
    fullfn=[demodir,filesep,name];
    disp(['Fixing ',fullfn])
    RecoverFile(fullfn)
  end
end %for ii

function RecoverFile(fullfilename1234567890)
% load and save file, attempt to bypass MATLAB's save -append bug 
% RecoverFile makes save possible when files move between different platforms
a1234567890=load(fullfilename1234567890);
VarNames1234567890=fieldnames(a1234567890);
%delete(fullfilename1234567890) % not necessary, save replaces
eval([VarNames1234567890{1} '= getfield(a1234567890, VarNames1234567890{1});' ]);
save(fullfilename1234567890, VarNames1234567890{1})
for ii=2:length(VarNames1234567890)
   eval([VarNames1234567890{ii} '= getfield(a1234567890, VarNames1234567890{ii});' ]);
   save(fullfilename1234567890, VarNames1234567890{ii}, '-append')
end
load(fullfilename1234567890) %test loadability again
%
