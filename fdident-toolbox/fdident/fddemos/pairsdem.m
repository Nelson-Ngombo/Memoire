%PAIRSDEM Demonstration of pairs (geometric mean of complex numbers)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 09-Aug-2002

echo off
ds=dbstack; n=ds(1).name; disp(['File ',n])
ind=find(n==filesep); if ~isempty(ind), name=n(ind(end)+1:end-2); else name=n; end
clf, set(gcf,'name',name), clear ds n ind name
rand('seed',5)
if ~exist('demosavegraphst'), demosavegraphst=''; end %save graph statement
if ~exist('textpause'), textpause=''; end %mode to show text in Command Window
graphnumber=0;
if mean(get(gcf,'Color'))<=0.5, white='w'; else white='k'; end
if get(0,'ScreenDepth')<4, blue=white; red=white; green=white;
else blue='b'; red='r'; green='g';
end
echo on, clc
%PAIRS is an implementation of the Hungarian Method for the determination
%of the optimum pairing between two sets of points, where the cost function
%is the sum of weights associated with the edges between points.
%This routine can be used e. g. for the selection of poles closest to given
%zeros, or for exploring the movement of poles and zeros caused by small
%perturbations of the polynomial coefficients: the original and perturbed
%poles and zeros can be coupled to each other. If the perturbations are very
%small, this coupling is straightforward: each point can be paired to its
%nearest neighbor. For somewhat larger deviations, when the nearest
%neighbors strategy does not give a solution, and an 'optimal' pairing can
%be looked for. For large deviations an optimum can still be found, but the
%pairing will be useless for the pole/zero following problem.
%     It is easy to see that for weights equal to the length of the distances,
%the optimum pairing may not contain any crossing connections.
%First let us demonstrate this statement.
echo off
%fdidpaus(textpause)
fprintf('Press a key to continue...'), pause, disp(' ')
hold off
clf, subplot(1,2,1), axis('off')
axis([0,1,0,1]), axis('square')
plot([.4,.6],[.35,.35],['x',white],[.4,.6],[.65,.65],['o',white],...
        [.4,.6],[.35,.65],[':',red],[.6,.4],[.35,.65],[':',red])
title('Non-optimal connection')
axis([0,1,0,1]), axis('square'), axis('on'), grid off
%
subplot(1,2,2), axis('off')
plot([.4,.6],[.35,.35],['x',white],[.4,.6],[.65,.65],['o',white],...
        [.4,.4],[.35,.65],[':',red],[.6,.6],[.35,.65],[':',red])
title('Optimal connection')
axis([0,1,0,1]), axis('square'), axis('on'), grid off, drawnow
%
graphnumber=grapause('pairsdem',graphnumber,demosavegraphst);
%
disp('******************')
echo on
%This was a trivial example. However, if the number of points is larger, it is
%not trivial at all to find the appropriate pairs. The routine pairs can do it
%for us.
%     An indication of the proper pairing is that no crossing edges are
%selected. However, it should be mentioned that the absence of crossings is an
%illustration, and not a proof of the optimum, since several pairings may exist
%with no crossing edges.
%     Two sets of random points will be generated above [0,1]x[0,1], and the
%optimum pairing will be determined using pairs.
echo off
fdidpaus(textpause)
%fprintf('Press a key to continue...'), pause, disp(' ')
if ~exist('N'), N=10; end
N=min(N,15);
N=yesinput('Number of points in each set',N,[2,inf]);
%
demomore='y';
%global pairsmessages
while strcmp(demomore,'y')
  demomore='n';
  a=rand(N,1)+sqrt(-1)*rand(N,1); b=rand(N,1)+sqrt(-1)*rand(N,1);
  echo off
  fprintf('The number of points in each set is %.0f\n',N)
  fprintf(['The ''maximum cover'' must contain %.0f edges ',...
                'at the end of the iterations.\n\n'],N)
  pairsmessages='yes';
  [indab,cycle,digits]=pairs(a,b,1,inf,4);
  clear pairsmessages
  clf, subplot(1,1,1), clf, axis('off')
  axis([-0.1,1.1,-0.1,1.1])
  plot(a,['o',white]), hold on, plot(b,['x',white]), axis('square')
  axis([-0.1,1.1,-0.1,1.1]), axis('on'), grid off, drawnow
  for i=1:N
    if indab(i)~=0
      plot(real([a(i);b(indab(i))]),imag([a(i);b(indab(i))]),[':',red])
    end
  end
  drawnow
  hold off
  graphnumber=grapause('pairsdem',graphnumber,demosavegraphst);
  demomore=yesinput('Do you want another run with different data','n','y|n');
  if strcmp(demomore,'y')
    N=yesinput('Number of points in each set',N,[2,100]);
  end
  disp(' ')
end %while
rand('seed',0)
%%%%%%%%% End of pairsdem %%%%%%%%%%%%%%%%%%
