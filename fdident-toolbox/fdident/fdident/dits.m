function [bitser,Puf,Ptot]=dits(varargin)
%DITS   Discrete interval three-level sequence with given amplitude distribution.
%
%       bitser=DITS(Fdat,N,fs);
%       [bitser,Puf,Ptot]=DITS(Fdat,N,fs,runmod);
%
%       The iterations are based on flipping between frequency domain (amplitudes
%       combined with iterated phases), and time domain, where quantization operations
%       are performed. The output is the generated series for which the minimum ratio
%       of the designed and desired amplitudes in a signal is maximal.
%
%       Output arguments:
%       bitser = tiddata, containing the generated series (values +1,0,-1)
%         bitser.userdata contains the complex amplitudes of the optimal series
%         (coefficients of the complex Fourier series) at the given frequencies.
%           The amplitudes are scaled in such a way that the total
%           power of the designed signal is set to be equal to the total
%           desired power prescribed.
%       Puf = useful power (as a fraction of the total power)
%       Ptot = total desired signal power
%
%       Input arguments:
%       Fdat = fiddata object (see 'help fiddata' and 'help(fiddata)', 
%          e.g. the output of msinclip, containing the
%          frequency points and the complex Fourier amplitudes as input.
%          the frequency points must be integer multiples of 1/(N*dt),
%          0 <= freqv <= 0.5*fs, minimum length: 1.
%          If any of the amplitudes is complex, one trial will be made using
%          the phases as starting value.
%          Default: all ones at the given frequenc points
%       N = length of the series to be generated, minimum: 2
%       fs = repetition frequency of successive bits (Hz)
%       runmod = structure of run modifiers. Fields:
%         trialno = number of trials, default: 25.
%           Each loop starts from a random phase multisine.
%         state = value of the state of the uniform random generator for 
%           generating the starting phases. If this is not given, the
%           state will be continuously modified as new phase sets are generated.
%           Possible values: an integer, or a 35-element vector (see 'help rand').
%         cyclemax = maximum number of iterations for a trial, default: inf.
%         graphmod = if this is given with the value 'nograph', iteration
%           results will not be plotted, otherwise they will be plotted.
%         reconstr = 'discr' or 'd' for discrete-time, 'cont' or 'c' for
%           continuous-time modeling. In the latter case, the amplitudes
%           are predistorted by reciprocal of the transfer function of the
%           zero-order hold, nothing special is done for discrete time.
%           Default: 'c'.  tf_ZOH = sin(pi*freqv*dt)./(pi*freqv*dt).
%         type = if given as 'odd', then an odd dits is designed (no even harmonics,
%           the second half of the signal is a repetition of the first one);
%           when 'nothird', there are no third harmonics;
%           'oddnothird' or 'nothirdodd' mean the combination of the two
%         mean = mean value imposed on the signal
%         neglevel = value of negative level (if different from -1)
%
%       Usage:
%         [bitser,Puf,Ptot]=dits(Fdat,N,dt,runmod);
%       Example: bits0=dits(fiddata([],[1,1,1,.5]',[2:5]/1e-3/64),64,1e3);
%
%       See also: DIBS, MLBS.

%       For consistency of programming, this routine calls the function dibs
%       with a special combination of input arguments.
%       Algorithm: A. S. McCormack, K. R. Godfrey and J. O. Flower, "Design of
%       multilevel multiharmonic signals for system identification," IEE Proc.
%       of Control Theory and Appl., Vol. 142, No. 3, pp. 247-252, May 1995.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
%       All rights reserved.
%       $Revision: $
%       Last modified: 29-Nov-2002

if (nargin==1)&isstr(varargin{1})&strcmp(varargin{1},'secret')
  fprintf(['  ''Secret'' way of setting the number of trials:\n',...
      '    global dits_trialno\n    dits_trialno=<trials>;\n'])
  return
end
global dits_trialno
if (length(dits_trialno)==1)&(dits_trialno>0)
  global dibs_trialno
  dibs_trialno_save=dibs_trialno;
  dibs_trialno=dits_trialno;
end
while length(varargin)<4, varargin=[varargin,{[]}]; end
varargin{4}=setfield(varargin{4},'levels',3);
[bitser,Puf,Ptot]=dibs(varargin{:});
if (length(dits_trialno)==1)&(dits_trialno>0)
  dibs_trialno=dibs_trialno_save;
end
%%%%%%%%%%%%%%%%%%%%%%%%%% end of dits %%%%%%%%%%%%%%%%%%%%%%%%%%
