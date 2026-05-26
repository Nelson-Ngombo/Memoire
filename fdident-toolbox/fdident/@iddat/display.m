function display(dat)
%DISPLAY  Short info on iddat object

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2003
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Jul-2003

c=class(dat);
disp([sprintf('\n%s =\n\n',inputname(1)),...
        '        ',c,' object',sprintf('\n')])
disp(get(dat,'channel'))
if isa(dat,'fiddata')
  M=get(dat,'M');
  if ~isempty(M)&(length(M)==1)
    disp(sprintf('Variances were calculated from %.0f experiments (segments)',M))
  end
  NonlinM=get(dat,'NonlinM'); tfeven=get(dat,'EvenOutputNonlinError');
  if ~isempty(NonlinM)
    disp(sprintf('Nonlinear errors were calculated from %.0f experiments',NonlinM))
  end
  if ~isempty(tfeven)
    disp('Nonlinear error levels were interpolated from randomized experiment')
  end
end
en=get(dat,'ExperimentName');
if ~isempty(en)
  fprintf('Experiment name(s): ')
  disp(en)
end
% end ../@fidmodel/display.m
