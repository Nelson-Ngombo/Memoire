function parstruc=nmrparam(model)
%
%  parstruc=nmrparam(model)
%  Originally:
%  [Frequency,StdFreq, Decay, StdDecay, Amplitude, StdAmpl, Phase, StdPhase] =...
%          NMRparam(Y, cyy, q, a, b, fs, Delta, N, M);
%
%		NMR mode
%			time domain: 		y(t) = sumr[Amplituder*exp(jPhaser)*exp((-Decayr+j2*pi*Frequencyr)*(t+Delta)]
%			frequency domain:	Y(k) = sumr[Amplituder*exp(jPhaser)*Polesr^Delta*(1-Polesr^N)/(1-Polesr*zk^-1)]
%								with Polesr = exp((-Decayr+j*2*pi*Frequencyr)/fs) and zk = exp(j*2*pi*k/N)
%
% INPUT PARAMETERS :
%
%		Y		=	DFT spectrum output signal, dimensions: number of frequencies x 1
%		U		=	DFT spectrum input signal, dimensions: number of frequencies x 1
%		cyy		=	variance output DFT spectrum, dimensions: number of frequencies x 1
%		q		=	vector of (zk^-1) or (jwk) values, dimension: number of frequencies x 1
%		a		=	estimate coefficients denominator polynomial plant model, dimension 1 x OrderA+1
%		b		=	estimate coefficients numerator polynomial plant model, dimension 1 x OrderB+1 (OrderB = OrderA-1)
%		fs		=	sampling frequency
%		Delta	=	time origin of the measurements
%		N		=	number of samples
%		M		=	number of repeated measurements 
%
% OUTPUT PARAMETERS :
%
%		Frequency	=	estimated frequency 
%		StdFreq		=	standard deviation estimated frequency 
%		Decay		=	estimated decay
%		StdDecay	=	standard deviation estimated decay
%		Amplitude	=	estimated amplitude 
%		StdAmpl		=	standard deviation estimated amplitude
%		Phase		=	estimated phase in degrees
%		StdPhase	=	standard deviation estimated phase in degrees
 
% calculate partial fraction expansion of the rational form b/a where OrderB = OrderA-1, as
%
% 						b/a = sumr(RRr/(1-Polesr*z^(-1)))
%
Y=model.data.output;
cyy=model.data.outputvariance;
fs=model.fs;
q=exp(-j*2*pi*model.data.freqpoints/fs);
a=model.denom;
b=model.num;
Delta=model.data.inputdelay; if isempty(Delta), Delta=0; end
N=model.data.N;
d=struct(model.data);
if isfield(d.NewProperties,'M'), M=model.data.M; else M=inf; end
if ~isfinite(M), M=[]; end
%
[RR,Poles,K] = residue(b,a);

% calculate the NMR parameters
dummy = RR./(Poles.^Delta)./(1-Poles.^N);
Decay = -real(fs*log(Poles));
Frequency = imag(fs*log(Poles))/2/pi;
Amplitude = abs(dummy);
Phase = angle(dummy)*180/pi;   % phase in degrees

% calculate the uncertainty on estimated RR and poles via inv(J^HJ) (RR = Residue /Poles)
F = length(q);
OrderA = length(a)-1;
dummy = ones(F,OrderA) - repmat(q,1,OrderA).*repmat(Poles.',F,1);
% derivative w.r.t. RR = Resid/Poles parameter
Jacob = -repmat(1./(cyy.^0.5),1,OrderA)./dummy;
% derivative w.r.t. Poles
Jacob = [Jacob, -(repmat(q./(cyy.^0.5),1,OrderA).*repmat(RR.',F,1))./(dummy.^2)];
[u,s,v] = svd(Jacob,0);
CovRRPoles = v*diag(diag(s).^(-2))*v';
in1 = [1:OrderA];
in2 = [OrderA+1:2*OrderA];
% covariance matrix poles
CPoles = CovRRPoles(in2,in2);
% covariance matrix modified residues
CRR = CovRRPoles(in1,in1);
% covariance residues, poles
CRR2Poles = CovRRPoles(in1,in2);

% calculate the standard deviation on the decay estimates
StdDecay = fs*sqrt(real(diag(CPoles))/2)./abs(Poles);

% calculate the standard deviation on the frequency estimates
StdFreq = StdDecay/(2*pi);

% calculate the standard deviation on the phase and amplitude estimates
dummy = (Delta - N*(Poles.^N)./(1-Poles.^N))./Poles;
StdPhase = ((abs(dummy).^2).*real(diag(CPoles))/2 + 1./(abs(RR).^2).*real(diag(CRR))/2 - real(diag(CRR2Poles)./RR.*conj(dummy))).^0.5;
StdAmpl = Amplitude.*StdPhase;
StdPhase = 180/pi*StdPhase;			% phase in degrees

% sort the results according to the frequency
[Frequency,index] = sort(Frequency);
Amplitude = Amplitude(index);
Decay = Decay(index);
Phase = Phase(index);
StdFreq = StdFreq(index);
StdDecay = StdDecay(index);
StdPhase = StdPhase(index);
StdAmpl = StdAmpl(index);

if ~isempty(M)
	scale = sqrt((M-1)/(M-3));
	StdFreq = StdFreq*scale;
	StdDecay = StdDecay*scale;
	StdPhase = StdPhase*scale;
	StdAmpl = StdAmpl*scale;
end;
%
parstruc.Frequency=Frequency;
parstruc.StdFreq=StdFreq;
parstruc.Decay=Decay;
parstruc.StdDecay=StdDecay;
parstruc.Amplitude=Amplitude;
parstruc.StdAmpl=StdAmpl;
parstruc.Phase=Phase;
parstruc.StdPhase=StdPhase;
