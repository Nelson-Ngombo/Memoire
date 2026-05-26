%HPAIRSTS Test pairs

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
close all, set(gcf,'name',name), clear ds n ind name
if ~exist('testsavegraphst'), testsavegraphst=''; end %save graph statement
graphnumber=0;
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
echo on
%Check pairs
for N=[10,20,30];
  rand('seed',0)
  a=rand(N,1)+sqrt(-1)*rand(N,1); b=rand(N,1)+sqrt(-1)*rand(N,1);
  echo off
  disp('[indab,cycle,digits]=pairs(a,b,1,inf,4);')
  fprintf('Press a key to continue...'), pause, disp(' ')
  global pairsmessages
  pairsmessages='yes';
  [indab,cycle,digits]=pairs(a,b,1,inf,4);
  clear pairsmessages
  fprintf(['\nIt is obvious that an optimum with exponent p=1 may not ',...
      'contain edges\n',...
      'that cross each other. Let us observe this on the graph.\n'])
  disp(' '), fprintf('Press a key to continue...'), pause, disp(' ')
  clf, hold off
  axis([-0.1,1.1,-0.1,1.1]), zoom on
  plot(a,['o',white]), hold on, plot(b,['x',white]), axis('square')
  axis([-0.1,1.1,-0.1,1.1]), axis('on'), grid off
  for i=1:N
    if indab(i)~=0
      plot(real([a(i);b(indab(i))]),imag([a(i);b(indab(i))]),['-',red])
    end
  end
  title(sprintf('N=%.0f',N))
  drawnow
  hold off
  graphnumber=grapause('hpairsts',graphnumber,testsavegraphst);
end
%
%clear a b indab N cycle digits i graphnumber
rand('seed',0)
%%%%% End of hpairsts %%%%%%%
