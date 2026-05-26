function [timev,x,y]=hgetttst(i)
%HGETFTST User-defined m-file for testing tim2fou

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 18-May-1996

timev=[0:31]';
x=i*ones(32,1);
y=[0.1*i*ones(32,1),10*i*ones(32,1)];
%%%%%%% End of HGETFTST %%%%%%%%%%%%%%%%%%
