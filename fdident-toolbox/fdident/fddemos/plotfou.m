%PLOTFOU Plot contents of Fourier files one by one

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Oct-1998

if ~exist('Fourierno'), Fourierno=[]; end
if isempty(Fourierno), Fourierno=1; end

dirfdna=which('alupldem.mat');
dirfdn=dirfdna(1:end-13);
fn=dir(dirfdn);
vcount=0;
for ii=1:length(fn)
  if (~fn(ii).isdir)&any(findstr('.mat|',[lower(fn(ii).name),'|']))
    vn=whos('-file',fn(ii).name);
    for iii=1:length(vn)
      Ffile=loadvar(fn(ii).name,vn(iii).name);
      if isa(Ffile,'fiddata')
        vcount=vcount+1;
        if vcount==Fourierno
          if strcmp(lower(fn(ii).name),'emachine.mat')
            ploteltf('','',Ffile,['log',0.9e-2,0.5e3]);
          else
            ploteltf(Ffile);
          end
        end
      end
    end %for iii
  end
end %for ii
%
%eval(['print -deps ',fnam,'.eps'])
%
Fourierno=Fourierno+1;
%%%%%%%%%%%%%%%%%%%%%%%% end of plotfou %%%%%%%%%%%%%%%%%%%%%%%%