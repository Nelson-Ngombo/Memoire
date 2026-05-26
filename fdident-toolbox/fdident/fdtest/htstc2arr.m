%HTSTC2ARR  Test conversion of contraints to arrays cp*[num,denom]'=cb

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
[cp,cb]=fdident('private','constr2arr',{'-b_Nb=-1'},2,3,'s');
if ~isequal(cp,[-1,zeros(1,6)])|~isequal(cb,-1)
  error('Conversion1 is wrong')
else
  disp('Conversion1 is OK')
end
%
cc={'5*b(Nb)+6.5*a_Na+2*a_(Na-1)+a_1=2';
       'b_0=2.1'};
[cp,cb]=fdident('private','constr2arr',cc,4,5,'s');
if ~isequal(cp,[5,zeros(1,4),6.5,2,0,0,1,0;zeros(1,4),1,zeros(1,6)])|...
    ~isequal(cb,[2;2.1])
  error('Conversion2 is wrong')
else
  disp('Conversion2 is OK')
end
%
cc={'5*b(Nb)+6.5*a(Na)+2*a_(Na-1)+a_1=2';
       'b_0=2.1'};
[cp,cb]=fdident('private','constr2arr',cc,4,5,'s');
if ~isequal(cp,[5,zeros(1,4),6.5,2,0,0,1,0;zeros(1,4),1,zeros(1,6)])|...
    ~isequal(cb,[2;2.1])
  error('Conversion3 is wrong')
else
  disp('Conversion3 is OK')
end
%
[cp2,cb2]=fdident('private','constr2arr',{cp,cb},4,5,'s');
if ~isequal(cp,cp2)|~isequal(cb,cb2)
  error('Conversion4 is wrong')
else
  disp('Conversion4 is OK')
end
clear cc cp cb cp2 cb2
