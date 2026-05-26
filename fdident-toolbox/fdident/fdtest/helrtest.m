%HELRTEST Test of elis with reports after cycle 0

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 16-Mar-2000, I. Kollar

echo on
%
testno=0;
for initset='fl'
  if initset=='f'
    if exist('corrtest.m')
      rfile='inpchmod(inpchans)';
    else
      rfile='inpchans.pbn';
    end
    nno=12;
  else
    rfile=''; nno=11;
  end
  for iterno=[0,1]
    for i=1:3
      testno=testno+1;
      fprintf(['\nhelrtest_no=%.0f, initset=''',initset,''', iterno=%.0f, nargout=%.0f\n'],...
        testno,iterno,i)
      if i==1
        pv=elis('inpchan',[1,1],['s',nno,12],'f',...
          ['g',initset,iterno],[],rfile,'inpchans.rep');
      elseif i==2
        [pv,fit]=elis('inpchan',[1,1],['s',nno,12],'f',...
          ['g',initset,iterno],[],rfile,'inpchans.rep');
      elseif i==3
        [pv,fit,Cp]=elis('inpchan',[1,1],['s',nno,12],'f',...
          ['g',initset,iterno],[],rfile,'inpchans.rep');
      end %if
      %more on
      type inpchans.rep
    end %for i
  end %for iterno
end %for initset
%
more off
delete inpchans.rep
echo off
%
%End of helrtest
