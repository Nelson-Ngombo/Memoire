%HDITSTST
%Test dits
echo on
clear d
d=dits(fiddata([],[ones(1,5),.5]',[2:7]/1e-3/64),64,1e3);
pause
d=dits(fiddata([],[ones(1,5),.5]',(1+[3:3:18])/1e-3/63),63,1e3,...
  struct('type','nothird'));
pause
d=dits(fiddata([],[ones(1,5),.5]',sort([1:6:18,5:6:18])/1e-3/63/2),63*2,1e3,...
  struct('type','oddnothird'));
pause
d=dits(fiddata([],[ones(1,5),.5]',[1:6]/1e-3/63),63,1e3,struct('neglevel',-.5));
pause
d=dits(fiddata([],[ones(1,5),.5]',[1:6]/1e-3/63),63,1e3,...
  struct('neglevel',-.5,'meanv',0.2));
meanv=0.2
meand=mean(d.data)
echo off
