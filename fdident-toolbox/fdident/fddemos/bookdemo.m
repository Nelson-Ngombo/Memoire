%BOOKDEMO Demonstrations of the FDIDENT Toolbox using measured data.
%       The data are the same as used in the following book:
%       J. Schoukens and Rik Pintelon, Identification of Linear Systems.
%       London, Pergamon Press, 1991.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Mar-1999

echo off
%bookdemono=9;
if exist('bookdemono')~=1, bookdemono=1; end
if isempty(bookdemono), bookdemono=1; end, if bookdemono==0, bookdemono=1; end
%
clc
disp('The measured data of the book: Johan Schoukens and Rik Pintelon,')
disp('Identification of Linear Systems - A Practical Guideline to')
disp('Accurate Modeling, Pergamon Press, 1991, are available in files,')
disp(['and the data processing described in the book can be reproduced.'])
disp(['The results are usually not exactly the same, since the ',...
        'programs used here'])
disp('are slightly different, however, the essence is identical.')
disp('WARNING: most of the experimental data are rather extensive: these')
disp(['demonstrations may not run on a small computer',...
        ' (PC-AT, Macintosh Plus).'])
fprintf('Press any key to continue ...'), pause, disp(' ')
%
while bookdemono~=0
  clc
  nex=[-1];
  disp(['     Available demonstrations, based on the same data as used in ',...
                'the book'])
  disp('     of Schoukens and Pintelon:')
  disp(' ')
  disp('     1) Identification of a system: passive bandpass (octave) filter')
  if exist('lowpass.mat')
    disp('     2) Identification of a system: active lowpass filter')
  else
    nex=[nex;2];
  end
  if exist('emachine.mat')
    disp('     3) Compensation of an input channel')
  else
    nex=[nex;3];
  end
  disp('     4) Identification of a system: electrical machine')
  if exist('crankcas.mat')
    disp('     5) Identification of a system: crankcase')
  else
    nex=[nex;5];
  end
  disp('     6) Identification of a system: aluminum plates glued together')
  disp('     7) Identification of a system: rectangular glass fiber plate')
  disp('     8) Elaborated example: Transfer function estimation (Chapter 9)')
  disp('     9) Cable fault location')
  disp(' ')
  disp('     0) Exit')
  %
  echo off
  bookdemos=['bandpdem';'lowpdemo';'inpchdem';'emachdem';'crankdem';...
             'alupldem';'glfibdem';'lpelabex';'cabledem'];
  bookdemono=yesinput('Your choice',bookdemono+0,[0,length(bookdemos(:,1))]);
  if any(bookdemono==nex), error('This is not a valid choice'), end
  if bookdemono~=0
    disp(['File ',bookdemos(bookdemono,:)])
    clc, clf, hold off, iterctrl
    clear graphnumber
    eval(bookdemos(bookdemono,:))
    %next one will be offered
    bookdemono=rem(bookdemono+1,length(bookdemos(:,1))+1);
  else
    break
  end
end %while
%%%%%%%%%%%%%%%%%%%%%%%% end of bookdemo %%%%%%%%%%%%%%%%%%%%%%%%
