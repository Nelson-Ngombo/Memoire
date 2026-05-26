%FDSYNCHR Sample script file for synchronization of experiments
%       The experiments are given in a Fourier file.
%       Synchronized experiments are also put at the end into a file.
%       For general applications, the use of files is not necessary.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
disp('Input variable - file(variable): bandpass(bandpass)');
%
synch_obj=varanal('bandpass(bandpass)','delayed');
%
[freqv,x,y]=impfou('bandpass(bandpass)');
[freqv,xm,ym]=impfou(synch_obj);
%
%Plot for checking
clf, hold off
subplot(221), plot(x,['x',white]), title('Old input amplitudes')
axis('square'), axis('equal')
subplot(222), plot(y,['x',white]), title('Old output amplitudes')
axis('square'), axis('equal')
subplot(223), plot(xm,['x',white]), title('New input amplitudes')
axis('square'), axis('equal')
subplot(224), plot(ym,['x',white]), title('New output amplitudes')
axis('square'), axis('equal')
%
%%%%%%%%%%%%%%%%% End of convert %%%%%%%%%%%%%%%%%%%
