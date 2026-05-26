function heltrtst
%HELTRTST Test elis with transients

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 16-Mar-2000

clf, drawnow
testno=0;
for dtreat='fv'
  for itno=[0,1,10]
    for trtr='tn'
      %dtreat='f'; itno=10; trtr='t';
      if trtr=='t', trtxt='on'; else trtxt='off'; end
      testno=testno+1;
      fprintf(['\nheltrtst_no=%.0f, transients: ',trtxt,', itmax: %.0f, delaytreat: ''',...
        dtreat,'''\n'],testno,itno)
      if exist('corrtest.m')
        if strcmp(trtr,'t'), transients='on'; else transients='off'; end
        [newpv,devitinfo]=...
          elis('bandpass(bandpass_agv)','s',4,6,...
          struct('delaytreat',dtreat,'transients',transients,'itmax',itno));
        [pv,fit,Cp,CR,cfv,pvtr]=...
          elis('bandpass(bandpass_agv)',[],['s'+0,4,6,NaN,'n'+0,trtr+0],dtreat,[NaN,NaN,itno]);
      end
      fprintf('Press a key to continue ...'), pause, disp(' ')
    end
  end
end
%
%End of heltrtst
