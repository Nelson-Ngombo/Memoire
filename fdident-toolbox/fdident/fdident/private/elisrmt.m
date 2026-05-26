Possible fields and their values of the elis run modifier structure runmod
==========================================================================
representation - 'orthopol' or 'polynomial' (default: 'polynomial')
coefficients - 'real' or 'complex' (default: 'real')
fs - sampling frequency (for z-domain fits)
fscale - scaling frequency (for non-z-domain fits)
tauR - tau-coefficient (for Richards-domain fits)
allpass - set allpass design ('on')
transients - set transient treatment ('on')
trnumord - order of the transient numerator
delayscale - additional delay scaling time for the delay
stabilization - 'r' for reflection; 
    'c' for contraction, 'l' for step limitation to stability limit
forceminimumphase - 'r' for reflection
    'c' for contraction 'l' for step limitation to stability (minimum phase) limit
stablimit - stability limit, default: 0 for s-domain, 1 for z-domain
errorweighting - 'Linear', 'Nonlinear', or 'Interpolated nonlinear', default: 'Linear'
%
delay - initial value of the delay
delaytreat - way of treating the delay: fixed or variable
   Allowed values: {'variable','v','fixed','f'}
fixedpars - fidmodel object with NaN values in the numerator and the denominator
   where estimation is necessary. E.g. fp=fidmodel('s',[NaN,NaN],[[NaN,NaN,0]);
   Default: all parameters are estimated
   Special possibility: 'a_n' for highest, 'a_0' for smallest-index coefficient
   of denominator fixed at value 1
constraints (not yet ready!) - linear constraints on the parameters in either form:
     {cp,cb} where cp*[num,denom]'=cb
   or cell vector of strings (equations) strictly in the following form 
   (the actual numbers are arbitrary)
     {'5*b_Nb+6.5*a_Na+2*a_(Na-1)+a_1=2';
       'b_0=2'}
algorithm - iteration algorithm:
   Newton-Gauss, NG;
   Levenberg-Marquardt, LM;
   LM with svd, LMsvd;
   singular value decomposition, svd, TLS; 
   Newton-Raphson, NR
itmax - maximum number of iterations
initset - setting of starting (initial) values (alternatives in one line each):
   least squares, LS, l;
   output-weighted least squares, vary-WLS (by 1/vary), w;
   output-weighted singular value decomposition, vary-WLS with svd, y;
   y-weighted svd, ysvd (by reciprocal of total variance reduced to output), v;
   u-weighted svd, usvd (by reciprocal of total variance reduced to input), u;
   singular value decomposition, svd (of Levi), s, tls;
   frequency-weighted svd, approximate maximum likelihood, AML, freq-w svd, a;
   equation-error variance WLS, eevWLS (AML without frequency weight), r
   scan different algorithms, scan, try different algorithms, trials, t
   object (initmodel is needed), o;
   iqml (iterated ML from previous model, initmodel is needed), i;
   equation error method, eem, e (Signal Processing Toolbox)
   Plans (not yet ready):
   generalized total least squares, GTLS, g
   bootstrapped TLS, BTLS, b
   relaxation_factor (iqml) - r in weighting of the cost function with 
        initweight^(2*r), default: r=1.
initweight - weights (linear, denominator)  for the initial setting.
   This is used with the special value 'eW' of the field initset.
%
dcfmax - stop if rel. variation of cost function smaller than this value
dprelmax - stop if rel. variation of parameters smaller than this value
   (These 2 conditions are in OR relationship.
    By default, dcfmax=1e-6, dprelmax=0.)
lambdadecrease - number of consecutive decreases of the cost function before
   trial with lambda=lambdamin in LM iteration. (default: 10)
lambdamin - the minimum value of lambda (by default: 0)
lambda0 - starting value of lambda
lambdalim - value of lambda under which iteration may be stopped
%
plotdens = plot for every plotdens'th iteration, Inf for no plot at all
plot0 = 'off' for no plot of initial setting
plotoffset = start counting plots to screen (offset to plotdens) 
plotdenstime - minimum time to elapse between plots in seconds
plotlevel - 'basic' (less info), or 'advanced'. Default: 'advanced'
plotfreq - 'linear' or 'logarithmic'
freqdim - frequency axis in 'frequency' (Hz) or 'radians' (radHz)
magnitudeaxis - axis vector for magnitude plots (NaN's for nondefined elements)
pzaxis - axis vector for pole/zero plot
   (or 'prop' for the same vertical and horizontal scaling, all poles/zeros shown;
    'all' for all poles/zeros just shown; a number for all zeros and poles with
    limit n*fvmax in s-domain, or with limit n in z-domain
%
initmodel - fidmodel object with the initial values for iteration
reportfile - name of the file where report text will be stored

Examples:
%Run elis with delay set to fixed value 0.01
p=elis('robotarm(robotarm_freqdata_agv)','s',4,6,struct('delay',0.01));
%Run elis with some numerator parameters set to zero, iteration max. 2
fixobj=fidmodel('s',[NaN,NaN,NaN,0,0],NaN*ones(1,7));
p=elis('bandpass(bandpass_agv)','s',4,6,struct('fixedpars',fixobj,'itmax',2))
%Fast run with no plots
load robotarm
p=elis(f,'z',6,8,struct('plotdens',inf));

See also: elis fitinfo, elis devrunmod