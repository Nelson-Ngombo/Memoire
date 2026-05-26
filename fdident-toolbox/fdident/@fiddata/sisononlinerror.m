function out=sisononlinerror(dat)
%SISONONLINERROR  Return [outputnonlinerr,inputnonlinerr,nonlincov*nonlinM]

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2001-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 06-Mar-2005

out=sisononlinvariance(dat);
if ~isempty(get(dat,'nonlincovariance'))
  if ~isempty(get(dat,'OddOutputNonlinError'))
    %error('Cannot decide what kind of data is this')
  else %robust
    nonlinM=get(dat,'nonlinM');
    if ~isempty(nonlinM)
      out=out*nonlinM;
    end
  end
end
%
%end @fiddata/sisononlinerror.m