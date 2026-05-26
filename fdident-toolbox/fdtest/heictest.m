%HEICTEST Test expcov, impcov, loadasc, fnamanal

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Dec-2000

disp('File heictest')
echo on
%Check expcov, impcov, loadasc and fnamanal
%
echo off
%global expimpmessages, expimpmessages='no';
Cp=[1.1,-1.2,1.3;-1.2,2.2,-2.3;1.3,-2.3,3.3];
comments=sprintf(['This is a comment of three lines\n',...
        'this is the second line\nand this is the third one']);
fdate='';
fn='heictest';
fixpind=[4];
for i=1:4
  if i==1, filen=''; ext=''; lim=1e-10;
    fprintf('\nChecking write to and read from data vector\n')
  elseif i==2, [filen,fns,ext]=fnamanal(fn,'cbn'); lim=1e-10;
    fprintf('\nChecking write to and read from binary file\n')
    fixpind=[2,3,4]';
  elseif i==3, [filen,fns,ext]=fnamanal(fn,'cnt'); lim=1e-4;
    fprintf('\nChecking write to and read from flat ascii file\n')
  elseif i==4, [filen,fns,ext]=fnamanal(fn,'cov'); lim=1e-4;
    fprintf('\nChecking write to and read from ascii file with comments\n')
  end
  data=expcov(Cp,fixpind,filen,comments,fdate);
  if i==1, [Cpc,fixpindc,commentsc,fdate]=impcov(data,'nofixp');
  else
    [Cpc,fixpindc,commentsc,fdate]=impcov(filen,'nofixp');
  end
  if any(fixpindc-fixpind), error('fixpind is not correct after impcov'), end
  if any(any(abs(Cp-Cpc)>lim))
    fprintf('Warning! The regained covariance differs significantly from\n')
    fprintf('the original one:\n')
    Cp, Cpc
    pause
    error('Fatal error in heictest')
  end
  fprintf('Press a key to continue...'), pause, disp(' ')
  if i==4
    eval(['type ',filen])
    fprintf('Press a key to continue...'), pause, disp(' ')
    [dataload,datline,header,commentsload,comline]=loadasc(filen)
    clear dataload datline header commentsload comline
  end
  if ~isempty(filen), eval(['delete ',filen]), end
end %for
%
tfid=fopen('heictest.tmp','a+');
fprintf(tfid,'%%comment\n1 2 3\n4 5 6 %%comment2\n%%comment3');
data=loadasc('heictest.tmp','array');
if (size(data,1)~=2)&(size(data,2)~=3), error('Size of data is not (2,3)'), end
try, fclose(tfid); catch, end, clear tfid
delete heictest.tmp
%
clear Cp Cpc data commentsc fdate nofixp filen lim fn fdate comments ext fns i
%%%%%%%%%%%%%%%%% End of heictest %%%%%%%%%%%%%%%%%%%
