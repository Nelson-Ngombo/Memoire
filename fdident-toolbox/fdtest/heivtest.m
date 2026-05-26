%HEIVTEST Test expvar and impvar

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-Jun-2001

disp('File heivtest')
echo on
%Check expvar and impvar
%
echo off
%global expimpmessages, expimpmessages='no';
freqvect=[1:5]';
varx=freqvect;
comments=sprintf(['This is a comment of three lines\n',...
        'this is the second line\nand this is the third one']);
fdate='';
fn='heivtest';
for i=0:4
  if i==0, filen=''; ext=''; lim=1e-10;
    fprintf('\nChecking read from data array\n')
    covxy=(1+j)*varx(:,1); vary=varx; data=[vary,varx,covxy];
  elseif i==1, filen=''; ext=''; lim=1e-10;
    vary=[2*freqvect,3*freqvect];
    fprintf('\nChecking write to and read from data vector\n')
    covxy=[];
  elseif i==2, [filen,fns,ext]=fnamanal(fn,'vbn'); lim=1e-10;
    fprintf('\nChecking write to and read from binary file\n')
    covxy=sqrt(-1)*varx;
  elseif i==3, [filen,fns,ext]=fnamanal(fn,'vnt'); lim=1e-4;
    fprintf('\nChecking write to and read from flat ascii file\n')
    covxy=sqrt(-1)*vary;
  elseif i==4, [filen,fns,ext]=fnamanal(fn,'var'); lim=1e-4;
    fprintf('\nChecking write to and read from ascii file with comments\n')
  end
  if i>=1, data=expvar(varx,vary,covxy,filen,comments,fdate); end
  if i<=1, [varxv,varyv,covxyv]=impvar(data);
  else
    [varxv,varyv,covxyv]=impvar(filen);
  end
  if any(abs(varxv-varx)>lim)
    fprintf('Warning! The regained input variance vector differs\n')
    fprintf('the original one:\n')
    varxv, varx
    pause
    error('Fatal error in heivtest')
  end
  if any(abs(varyv-vary)>lim)
    fprintf('Warning! The regained output variance vector differs\n')
    fprintf('the original one:\n')
    varyv, vary
    pause
    error('Fatal error in heivtest')
  end
  if any(any(abs(covxyv-covxy)>lim))
    fprintf('Warning! The regained covariance array differs\n')
    fprintf('the original one:\n')
    varyv, vary
    pause
    error('Fatal error in heivtest')
  end
  fprintf('Press a key to continue...'), pause, disp(' ')
  clear varxv varyv covxyv
  if i==4
    eval(['type ',filen])
    fprintf('Press a key to continue...'), pause, disp(' ')
  end
  if ~isempty(filen), eval(['delete ',filen]), end
end
clear freqvect varx vary varxv varyv data comments fn fdate ext filen fns i lim
clear covxy covxyv
clear expvar impvar
%%%%%%%%%%%%%%%%% End of heivtest %%%%%%%%%%%%%%%%%%%
