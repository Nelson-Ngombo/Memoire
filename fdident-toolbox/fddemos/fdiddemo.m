%FDIDDEMO Demonstrations of the Frequency Domain System Identification Toolbox
%
%       Further: generation of the results and of some figures of the book:
%       Johan Schoukens and Rik Pintelon, Estimation of Linear Systems,
%       London, Pergamon Press, 1991.
%       This frame program calls several demo files, provided in the
%       fddemos subdirectory or folder.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Mar-1999

echo off
%fdiddemono=14;
clf, hold off, gcf, iterctrl
rand('seed',0), randn('seed',0)
echo on, clc
%These demonstrations serve the following purposes:
%  1) To illustrate the possibilities of the Frequency Domain System
%     Identification Toolbox;
%  2) To give examples for the usage of the functions
%  3) To give practical examples of frequency domain identification, using
%     real-life data
%  4) To reproduce the results presented in the book:
%     Johan Schoukens and Rik Pintelon, Estimation of Linear Systems -
%     A Practical Guideline to Accurate Modeling, London, Pergamon Press, 1991.
%
%When running the demonstrations, you may choose from different possibilities,
%or you may define the values of certain parameters. For your convenience, a
%default answer is offered between parentheses. Simply press Enter or Return
%to accept the default answer, or type your choice.
%
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
%
c=computer;
if strcmp(c(1:2),'PC')
  textpause='p';
  disp(' ')
  disp('Mode of showing text in the command window')
  disp(['Stop, don''t stop, or allow change of windows by pressing ',...
      'any key, y|n|p'])
  textpause=yesinput('Your choice',textpause,'y|n|p');
end
%
echo all off, echo off, clc
if ~exist('demosavegraphst'), demosavegraphst=''; end
dmos=''; dtit='';
dmos=[dmos;'eltpexpl'];dtit=[dtit;'Identification example, time domain data'];
dmos=[dmos;'simudemo'];dtit=[dtit;'Simulation example to show usage of TB  '];
dmos=[dmos;'fdcourse'];dtit=[dtit;'Some problems for self-study            '];
dmos=[dmos;'rarmdemo'];dtit=[dtit;'Ident. procedure for flexible robot arm '];
rarmdemono=size(dmos,1);
dmos=[dmos;'optexdem'];dtit=[dtit;'Optimal excitation signal design        '];
dmos=[dmos;'mscldemo'];dtit=[dtit;'Crest factor minimization               '];
dmos=[dmos;'msprdemo'];dtit=[dtit;'Time function preparation: msinprep     '];
dmos=[dmos;'mlbsdemo'];dtit=[dtit;'Maximum length binary sequence design   '];
dmos=[dmos;'dibsdemo'];dtit=[dtit;'Discrete interval binary sequence design'];
dmos=[dmos;'gmeandem'];dtit=[dtit;'Geometric mean of complex numbers       '];
dmos=[dmos;'pairsdem'];dtit=[dtit;'Closest point pairs on the 2D plain     '];
dmos=[dmos;'varandem'];dtit=[dtit;'Synchronization and averaging of data   '];
dmos=[dmos;'wilkdemo'];dtit=[dtit;'Orthopol on a Wilkinson-type example    '];
dmos=[dmos;'bookdemo'];dtit=[dtit;'Processing of measured data of the book '];
demtot=length(dmos(:,1));
%
if exist('fdiddemono')~=1, fdiddemono=[]; end
if isempty(fdiddemono), fdiddemono=1; end
if fdiddemono==0, fdiddemono=1; end
while fdiddemono~=0
  clc, fprintf(['FREQUENCY DOMAIN SYSTEM IDENTIFICATION TOOLBOX',...
           ' demonstrations\n\n'])
  fprintf(['You can choose from the following demonstrations:\n\n'])
  for k=1:size(dmos(:,1))
    fprintf(['     %.0f) ',dtit(k,:),'\n'],k)
  end
  fprintf(['\n     0) Exit from fdiddemo\n'])
  MatlV=version;
  if strcmp(MatlV,'4.0')&(fdiddemono==rarmdemono)
    fdiddemono=rem(fdiddemono,demtot)+1;
  end
  fdiddemono=yesinput(' Your choice',fdiddemono+0,[0,length(dmos(:,1))]);
  if fdiddemono==0, break, end
  echo off
  clc
  demoact=dmos(fdiddemono,:);
  ind=find(demoact==' '); demoact(ind)=[];
  if ~exist([demoact,'.m'])|~exist(demoact), error([demoact,' not found']), end
  disp(['File ',demoact])
  clear graphnumber
  clc, clf, hold off, iterctrl, eval(demoact)
  fdiddemono=rem(fdiddemono+1,length(dmos(:,1))+1);
  echo off
end %while
close(gcf)
%%%%%%%%%%%%%%%%%%%%%%%% end of fdiddemo %%%%%%%%%%%%%%%%%%%%%%%%
