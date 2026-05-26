function emachtst(object)
%EMACHTST  Test conversions in emach

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 01-Nov-1998

load emachine, emachcoll=collapse(emachine);
%load emachold; emachcoll=emachine;

u=get(emachcoll,'input');
u1=u(1:39); u2=u(40:78); u3=u(79:88);
y=get(emachcoll,'output');
y1=y(1:39); y2=y(40:78); y3=y(79:88);
fp=get(emachcoll,'inputfreqpoints');
fp1=fp(1:39); fp2=fp(40:78); fp3=fp(79:88);
vu=get(emachcoll,'inputvar');
vu1=vu(1:39); vu2=vu(40:78); vu3=vu(79:88);
vy=get(emachcoll,'outputvar');
vy1=vy(1:39); vy2=vy(40:78); vy3=vy(79:88);

emachnew=emachcoll;
set(emachnew,'input',{u1,u2,u3},'output',{y1,y2,y3},...
  'freqpoints',{fp1,fp2,fp3},'frequencies',[],...
  'covariance',[],...
  'inputvar',{vu1,vu2,vu3},'outputvar',{vy1,vy2,vy3})
diff(emachine,emachnew)

%End of @fiddata/emachtst