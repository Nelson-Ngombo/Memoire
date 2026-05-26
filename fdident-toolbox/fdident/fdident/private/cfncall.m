function [Cmdl,CModel,CNoise,CTotal]=cfncall(fdata,model,errorweighting)
%CFNCALL Cost Function calculation
%       Helper function of autoorder
%
%       [Cmdl,CModel,CNoise,CTotal]=cfncall(fdata,model,errorweighting)
%
%       Output arguments:
%         Cmdl = Min description length Cf
%         CModel = Contribution of the modelling error to CTotal
%         CNoise = Contribution of the noise to CTotal
%         CTotal = Total Cost Function
%         Notes: 
%            1. CTotal = CModel + CNoise
%            2. Cmdl=CTotal+#freepar/2*ln(4*#Freqlines) <- OLD VERSION
%               Cmdl=CTotal*(1+#freepar/2*ln(4*#Freqlines)/#Freqlines)  <- NEW VERSION
%       Input arguments:
%         fdata = fiddata object containing input, output, and frequencies
%         model = 
%           1. fidmodel object containing domain, num, denom and delay (and Zxxx for 'p') OR
%           2. 1x4 cell array of N, D, NumOrd, and Denord, delay included in N and D
%              (numerator and denominator values, and the orders of numerator and denominator)

%       Written by Gyula Simon, 1998
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 13-Oct-2001

X=fdata.input;
Y=fdata.output;
freqvect=fdata.freqpoints;

if isa(model, 'fidmodel')
   [tf,N,D]=tfcalc(model, freqvect);
   m=max(max(abs(N)), max(abs(D)));
   N=N/m; D=D/m;
   NumOrd=length(model.num)-1; DenOrd=length(model.den)-1;
   delay=model.delay;
else
   N=model{1}; D=model{2}; NumOrd=model{3}; DenOrd=model{4};
end

% calculate weight
if strncmpi(errorweighting,'linear',3)
  Cxx=fdata.inputvariance;
  Cyy=fdata.outputvariance;
  Cxy=fdata.covvector;
else
  Cxx=fdata.inputNonlinError;
  Cyy=fdata.outputNonlinError;
  Cxy=fdata.nonlincovvector;
end
W=Cyy.*abs(D).^2;
if ~isempty(Cxx), W=Cxx.*abs(N).^2+W; end
if ~isempty(Cxy), W=W-2*real(Cxy.*conj(N).*D); end

freepar=NumOrd+DenOrd+1;
CTotal=sum((abs(N.*X-D.*Y).^2)./W);  
%Cmdl  =CTotal+freepar/2*log(4*length(freqvect)); % OLD (WRONG) MDL RULE
Cmdl  =CTotal*(1+freepar/2*log(4*length(freqvect))/length(freqvect));
CNoise=length(freqvect)-(freepar)/2;
CModel=max(0, CTotal-CNoise);
