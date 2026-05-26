%HEIFTEST Test expfou and impfou

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Jun-2001

disp('File heiftest')
echo on
%Check expfou and impfou
%
echo off
%global expimpmessages, expimpmessages='no';
freqvect=[1:5]'; fl=length(freqvect);
x1=2*ones(fl,1)-freqvect; x1(4)=x1(4)-j; x2=x1+100; x=[x1;x2];
comments=sprintf(['This is a comment of three lines\n',...
        'this is the second line\nand this is the third one']);
fdate='';
fn='heiftest';
digitnum=[];
for i=0:5
  if i==0, filen=''; ext=''; lim=1e-10;
    fprintf('\nChecking read from data array\n')
    y=(1+sqrt(-1))*x;
    data=[[freqvect;freqvect],x,y];
  elseif i==1, filen=''; ext=''; lim=1e-10;
    y1=[ones(fl,1),sqrt(-1)*ones(fl,1)]; y2=y1+200; y=[y1;y2];
    fprintf('\nChecking write to and read from data vector\n')
  elseif i==2, [filen,fns,ext]=fnamanal(fn,'fbn'); lim=1e-10;
    fprintf('\nChecking write to and read from binary file\n')
  elseif i==3, [filen,fns,ext]=fnamanal(fn,'fnt'); lim=1e-4;
    fprintf('\nChecking write to and read from flat ascii file\n')
  elseif i==4, [filen,fns,ext]=fnamanal(fn,'fou'); lim=1e-4;
    fprintf('\nChecking write/read ascii file with comments\n')
  elseif i==5, [filen,fns,ext]=fnamanal(fn,'fou'); lim=1e-4;
    fprintf('\nChecking write/read ascii file with comments, long lines\n')
    digitnum=3;
  end
  if i>=1
    data1=expfou(freqvect,x1,y1,1,2,filen,comments,fdate,digitnum);
    data2=expfou(freqvect,x2,y2,2,2,filen,comments,fdate,digitnum);
    data=[data1;data2];
  end
  if i<=1, [fvf,xf,yf]=impfou(data);
  else
    [fvf,xf,yf]=impfou(filen);
    disp('Now test conversion of file to object')
    obj=fiddata(filen);
  end
  if i==0, fvf=fvf(1:fl); end
  if any(any(abs(fvf-freqvect)>lim))
    fprintf('Warning! The regained frequency vector differs significantly\n')
    fprintf(' from the original one:\n')
    fvf, freqvect
    pause
    error('Fatal error in heiftest')
  end
  if any(any(abs(x-xf)>lim))
    fprintf('Warning! The regained x vector differs significantly\n')
    fprintf(' from the original one:\n')
    xf, x
    pause
    error('Fatal error in heiftest')
  end
  if any(any(abs(y-yf)>lim))
    fprintf('Warning! The regained y vector differs significantly\n')
    fprintf(' from the original one:\n')
    yf, y
    pause
    error('Fatal error in heiftest')
  end
  fprintf('Press a key to continue...'), pause, disp(' ')
  if (i==4)|(i==5)
    eval(['type ',filen])
    fprintf('Press a key to continue...'), pause, disp(' ')
  end
  if ~isempty(filen), eval(['delete ',filen]), end
end
clear x x1 x2 y y1 y2 freqvect data data1 data2 fvf xf yf fl obj
%%%%%%%%%%%%%%%%% End of heiftest %%%%%%%%%%%%%%%%%%%
