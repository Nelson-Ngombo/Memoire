function Out = listnot(obj,fun)
%List properties not to be listed by fun

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998
%       All rights reserved.
%       $Revision: $
%       Last modified: 07-Nov-1998

if nargin<2, fun=''; end, if isempty(fun), fun='get'; end
if strcmp(fun,'get')
  Out=['|Channels|Data|ChTypes|Characters|SisoVariance|Variance|OldTbSisoVariance|',...
      'SisoNonlinError|NonlinCovVector|Fdat|',...
      'Names|Delays|iddat|'];
elseif strcmp(fun,'diff')
  Out=['|Channels|CohVector|CovVector|SisoVariance|Variance|OldTbSisoVariance|',...
    'SisoNonlinError|NonlinCovVector|Fdat|'];
else
  error(['fun ''',fun,''' is not recognized'])
end
% end of file @fiddata/listnot