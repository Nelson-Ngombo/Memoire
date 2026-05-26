%MKD  Make short robotarm data for testing
clear
tmp=load('robotarm.mat');
d5=resample(tmp.robotarm_rawdata(1:4.7*4096),8);
clear tmp
d3=d5(1:3*512)
d4=d5(1:4*512)
d4nf=d4; d4nf.frequencies=[];
d5