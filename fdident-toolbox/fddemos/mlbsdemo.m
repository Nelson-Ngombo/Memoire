%MLBSDEMO Demonstration of mlbs

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
graphnumber=0;
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
fprintf('mlbs: maximum length binary sequence design\n\n')
fprintf('The length of the sequence is 2^n-1\n')
n=yesinput('The value of n',5,[2,16]);
fprintf('\nFirst the sequence will be designed.\n\n')
fprintf('Press any key to continue ...'), pause, disp(' ')
x=mlbs(n);
%
t1=0:2^n-2; t1=[t1;t1+1]; t1=t1(:);
x1=[x(:)';x(:)']; x1=x1(:);
clf, hold off
axis([-2^n/10,1.1*2^n,-1.1,1.1]);
plot(t1,x1,['-',red])
axis([-2^n/10,1.1*2^n,-1.1,1.1]);
title(sprintf('Maximum length binary sequence, n=%.0f',n))
graphnumber=grapause('mlbsdemo',graphnumber,demosavegraphst);
clc
fprintf(['Now the autocorrelation function of the result',...
                ' will be plotted\n\n'])
fprintf('Press any key to continue ...'), pause, disp(' ')
if n<=11, x=[x';x';x']; k=3; x=x(:); else k=1; end
r=real(ifft(1/length(x)*abs(fft(x)).^2));
clf, hold off
time=0:1/k:2^n-1-1/k/2;
axis([-2^n/10,1.1*2^n,min(-.1,-1.5/(2^n-1)),1.1]);
if k>1
  plot(time(1:k:length(time)),r(1:k:length(time)),['+',red]...
        ,time,r,[':',white])
else
  plot(time,r,['-',red])
end
axis([-2^n/10,1.1*2^n,min(-.1,-1.5/(2^n-1)),1.1]);
hold off, grid off
xlabel(sprintf('Register length: %.0f, length of bitseries: %.0f',n,2^n-1))
title('Autocorrelation function of mlbs')
graphnumber=grapause('mlbsdemo',graphnumber,demosavegraphst);
clc, fprintf('This is the correlation function you expected, isn''t it?\n')
fprintf('Press any key to continue ...'), pause, disp(' ')
figure(gcf)
pause, disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%% end of mlbsdemo %%%%%%%%%%%%%%%%%%%%%%%%
