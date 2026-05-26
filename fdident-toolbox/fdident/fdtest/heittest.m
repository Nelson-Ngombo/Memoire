%HEITTEST Test exptim and imptim

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 12-Jun-2001

disp('File heittest')
echo on
%Check exptim and imptim
%
echo off
%global expimpmessages, expimpmessages='no';
timevect=[1:5]'; tl=length(timevect);
x1=2*ones(tl,1)-timevect; x2=x1+100; x=[x1;x2];
y1=[ones(tl,1),10*timevect]; y2=y1+200; y=[y1;y2];
comments=sprintf(['This is a comment of three lines\n',...
        'this is the second line\nand this is the third one']);
fdate='';
fn='heittest';
digitnum=[];
for i=1:5
  if i==1, filen=''; ext=''; lim=1e-10;
    fprintf('\nChecking write to and read from data vector\n')
  elseif i==2, [filen,fns,ext]=fnamanal(fn,'tbn'); lim=1e-10;
    fprintf('\nChecking write to and read from binary file\n')
  elseif i==3, [filen,fns,ext]=fnamanal(fn,'tnt'); lim=1e-4;
    fprintf('\nChecking write to and read from flat ascii file\n')
  elseif i==4, [filen,fns,ext]=fnamanal(fn,'tim'); lim=1e-4;
    fprintf('\nChecking write to and read from ascii file with comments\n')
  elseif i==5, [filen,fns,ext]=fnamanal(fn,'tim'); lim=1e-4;
    fprintf('\nChecking write/read of ascii file with comments, many inputs\n')
    x1=[x1,-x1,x1]; x2=[x2,-x2,x2]; x=[x,-x,x];
    digitnum=9;
  end
  data1=exptim(timevect,x1,y1,1,2,filen,comments,fdate,digitnum);
  if i>1
    filen2=['f',filen];
    exptim(timevect,x1(:,1),y1(:,1),1,1,filen2,comments,fdate,digitnum);
    disp('Now test conversion of SISO file to frequency domain object')
    objf=fiddata(filen2);
  end
  data2=exptim(timevect,x2,y2,2,2,filen,comments,fdate,digitnum);
  data=[data1;data2];
  if i==1, [tvt,xt,yt]=imptim(data);
  else
    [tvt,xt,yt]=imptim(filen);
    disp('Now test conversion of file to object')
    obj=tiddata(filen);
    if (obj.inputchnumber<=1)&(obj.outputchnumber<=1)
      disp('Now test conversion of file to frequency domain object')
      objf=fiddata(filen);
    end
  end
  if any(any(abs(tvt-timevect)>lim))
    fprintf('Warning! The regained time vector differs significantly\n')
    fprintf(' from the original one:\n')
    tvt, timevect
    pause
    error('Fatal error in heittest')
  end
  if any(any(abs(x-xt)>lim))
    fprintf('Warning! The regained x vector differs significantly\n')
    fprintf(' from the original one:\n')
    xt, x
    pause
    error('Fatal error in heittest')
  end
  if any(any(abs(y-yt)>lim))
    fprintf('Warning! The regained y vector differs significantly\n')
    fprintf(' from the original one:\n')
    yt, y
    pause
    error('Fatal error in heittest')
  end
  fprintf('Press a key to continue...'), pause, disp(' ')
  if (i==4)|(i==5)
    eval(['type ',filen])
    fprintf('Press a key to continue...'), pause, disp(' ')
  end
  if exist('filen')&~isempty(filen), eval(['delete ',filen]), end
  if exist('filen2')&~isempty(filen2), eval(['delete ',filen2]), end
end
clear filen filen2
clear timevect x y x1 x2 y1 y2 data data1 data2 tvt xt yt tl digitnum
clear exptim imptim obj objf
%%%%%%%%%%%%%%%%% End of heittest %%%%%%%%%%%%%%%%%%%
