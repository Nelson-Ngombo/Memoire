function nf=elisnewfit(fitinfo)
%ELISNEWFIT  Convert old fitinfo vector to new fitinfo structure for comparisons 

nf.cf=fitinfo(1);
nf.cfth=fitinfo(2);
nf.cf95=fitinfo(3);
nf.F=fitinfo(4);
nf.freepar=fitinfo(5);
nf.iterations=fitinfo(6);
nf.dcf=fitinfo(7);
nf.dprel=fitinfo(8);
nf.lambda=fitinfo(9);
nf.mmerror=fitinfo(10);
nf.meanabstf=fitinfo(11);
nf.AIC=fitinfo(12);
nf.MDL=fitinfo(19);
nf.condnum=fitinfo(13);
nf.condnumJ=fitinfo(14);
nf.fscale=fitinfo(16);
termcauses={'itmax','dcf','dp','GUI'};
nf.termcause=termcauses{fitinfo(17)};
nf.runtime=fitinfo(18);
nf.errorweighting='linear';
