%HEIPTEST Test exppar and imppar

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Jun-2001

disp('File heiptest')
echo on
%Check exppar and imppar
%
echo off
%global expimpmessages, expimpmessages='no';
num=[5,6]; on=length(num)-1;
denom=[10,-11,12]; od=length(denom)-1;
delay=1.111;
fs=10;
comments=sprintf(['This is a comment of three lines\n',...
        'this is the second line\nand this is the third one']);
fdate='';
fn='heiptest';
dvect='pszwr';
for domain=dvect
  tauR=2;
  if domain=='p', Znum=[1:length(num)]'; Zdenom=10+[1:length(denom)]';
  else Znum=[]; Zdenom=[];
  end
  fprintf(['\nTest for ',domain,'-domain\n'])
  for i=1:4
    coeffsv={''};
    if i==1, filen=''; ext=''; lim=1e-10;
      fprintf('\nChecking write to and read from data vector\n')
      coeffsv={'','real','complex'};
    elseif i==2, [filen,fns,ext]=fnamanal(fn,'pbn'); lim=1e-10;
      fprintf('\nChecking write to and read from binary file\n')
      coeffsv={'','real','complex'};
    elseif i==3, [filen,fns,ext]=fnamanal(fn,'pnt'); lim=1e-4;
      fprintf('\nChecking write to and read from flat ascii file\n')
    elseif i==4, [filen,fns,ext]=fnamanal(fn,'par'); lim=1e-4;
      fprintf('\nChecking write to and read from ascii file with comments\n')
    end
    for coeffs=coeffsv
      if iscell(coeffs), coeffs=coeffs{1}; end
      fprintf(['  coefficients: ''',coeffs,'''\n'])
      if strncmp(coeffs,'c',1)&isreal(denom), denom=denom+j*denom;
      else denom=real(denom);
      end
      data=exppar(domain,num,denom,delay,fs,Znum,Zdenom,filen,comments,fdate,[],[],coeffs,tauR);
      if i==1
        if domain=='s' %test of frequency scaling
          [domainp,nump,denomp,delayp,fsp]=imppar(data,[]); %suggested scaling
          fprintf('Suggested scaling frequency: %.2e\n',fsp);
          if abs(delay-delayp/fsp*fs)>100*eps
            error('Erroneously scaled delay')
          end
          if any(abs(num-nump./((fsp/fs*ones(1,on+1)).^[on:-1:0]))>100*eps)
            error('Erroneously scaled numerator')
          end
          if any(abs(denom-denomp./((fsp/fs*ones(1,od+1)).^[od:-1:0]))>100*eps)
            error('Erroneously scaled denominator')
          end
        end
        [domainp,nump,denomp,delayp,fsp,Znump,Zdenomp]=imppar(data,fs);
      else
        [domainp,nump,denomp,delayp,fsp,Znump,Zdenomp]=imppar(filen,fs);
      end
      if ~strcmp(domain,domainp)
        error(['Domain ''',domain,''' is returned as ''',domainp,''' from file'])
      end
      if any(abs(num-nump)>lim)
        fprintf('Warning! The regained numerator differs significantly\n')
        fprintf(' from the original one:\n')
        nump, num
        pause
        error('Fatal error in heiptest')
      end
      if any(abs(denom-denomp)>lim)
        fprintf('Warning! The regained denominator differs significantly\n')
        fprintf(' from the original one:\n')
        denomp, denom
        pause
        error('Fatal error in heiptest')
      end
      if abs(delayp-delay)>lim
        fprintf('Warning! The regained delay differs significantly\n')
        fprintf(' from the original one:\n')
        delayp, delay
        pause
        error('Fatal error in heiptest')
      end
      if abs(fsp-fs)>lim
        if strcmp(domain,'z')
          fprintf('Warning! The regained sampling frequency differs\n')
        else
          fprintf('Warning! The regained scaling frequency differs\n')
        end
        fprintf('significantly from the original one:\n')
        fsp, fs
        pause
        error('Fatal error in heiptest')
      end
      if length(Znum)>0
        if any(Znum~=Znump)
          fprintf('Warning! The regained vector Znum is wrong for orthopol')
          pause
          error('Fatal error in heiptest')
        end
        if any(Zdenom~=Zdenomp)
          fprintf('Warning! The regained vector Zdenom is wrong for orthopol')
          pause
          error('Fatal error in heiptest')
        end
      end
      fprintf('Press a key to continue...'), pause, disp(' ')
      if i==4
        eval(['type ',filen])
        fprintf('Press a key to continue...'), pause, disp(' ')
      end
      if ~isempty(filen), eval(['delete ',filen]), end
    end %for coeffs
  end %i
end %for domain
clear filen fsp fs delayp delay num nump denom denomp domainp domain
clear exppar imppar on od dvect Znum Zdenom Znump Zdenomp
%%%%%%%%%%%%%%%%% End of heiptest %%%%%%%%%%%%%%%%%%%
