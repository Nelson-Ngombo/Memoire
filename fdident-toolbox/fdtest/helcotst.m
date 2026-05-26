%HELCOTST Test eliscost

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 06-Mar-1999

disp('File helcotst')
%
for domaint='szw' %p ???
  if (domaint~='p')|exist('orthopol')
    if any(domaint=='wp'), dom='s'; else dom=domaint; end
    load inpchan
    var=inpchan.SiSoVariance;
    varx=var(:,2); vary=var(:,1);
    if domaint=='z', ord=14; fs=51200; else ord=12; fs=51200; end
    for delayt=[0,fs/1000/pi], for covxy=[0,sqrt(varx*vary)/2]
      fprintf(['domain=',domaint,', delay=%.4g, covxy=%.4g\n'],delayt,covxy)
      vdat=[vary,varx,covxy]/2; %correct for old call
      [domain,num,denom,delay,fs]=imppar(['inpchmod(inpchan',dom,')']);
      if domaint=='p'
        fs=[];
        pvc=elis('inpchan',vdat,['p',12,12]);
      else
        pvc=exppar(domaint,num,denom,delayt,fs);
      end
      costf=eliscost(pvc,'inpchan',vdat);
      NaNv=NaN;
      [pvect,fit]=elis('inpchan',vdat,[domaint+0,ord,ord,fs],...
            'f',['gf'+0,0],[-1,NaNv(:,ones(1,12))],pvc);
      fprintf('  costf=%.4g, fit(1)=%.4g, rel. diff=%.4g\n',costf,fit(1),...
            (costf-fit(1))/costf)
      if abs(fit(1)-costf)>2e5*eps*costf
        error(sprintf('eliscost is wrong: costf=%.4g, fit(1)=%.4g',costf,fit(1)))
      end
    end
  end, end %for delayt, for covxy
end %for domaint
clear varx vary costf NaNv pvect fit
