%OPTEXDE2 Demonstration of optexcit: Book, Sect. 4.2, Ex. 2: 1st-order system

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 19-May-1996

echo off
clc, echo on
%The Cramer-Rao bound, calculated by OPTEXDEM, will be compared to the
%theoretical value in a simple case (1st order system).
echo off
disp('First let us define the system: num=1, denom=b1*s+b0')
b1=yesinput('Value of b1',1,[eps,inf]);
b0=yesinput('Value of b0',1,[eps,inf]);
disp(' ')
w=yesinput('Angular frequency',1,[eps,inf]);
fprintf(['num=[1]; denom=[b1,b0];\n',...
         'parvect=exppar(''s'',num,denom);\n'])
clc, echo on
num=[1]; denom=[b1,b0]
parvect=exppar('s',num,denom);
freqv=w/2/pi;
%
%The theoretical value of the Cramer-Rao bound:
%
cf=b0^2+w^2*b1^2; format long e
CRtheor=[cf*(1+cf)/w^2,     0    ;
               0      , cf*(1+cf)]
%
echo off
fprintf('Press any key to continue ...'), pause, disp(' ')
%
[X,CR]=optexcit(parvect,freqv,[1,1],[1,4],1,1);
disp(' ')
echo on
%The theoretical value of the Cramer-Rao bound can now be compared
%to the one calculated by OPTEXCIT:
CRtheor, CR
echo off
format short
disp('The difference is in the order of magnitude of the roundoff errors.')
fprintf('Press a key ...'), pause, disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of optexde2 %%%%%%%%%%%%%%%%%%%%%%%%
