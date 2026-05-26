% Frequency Domain System Identification Toolbox
% Version 4.0d (R2019a) 28-June-2019
%
% New Features
%   Readme      - Important release information about the Toolbox 
%                 (type 'whatsnew fdident' to display this file).
%
% Graphical User Interface
%   fdtool      - Start Graphical User Interface, or launch utilities (help fdtool)
%   fdident     - Alternative call to fdtool
%   fdunique    - Check uniqueness of function file names on path
%
% Objects
%   fiddata     - Frequency domain data for system identification
%   fidprops    - Properties of fiddata objects
%   helpc(fiddata) - Avaliable methods for fiddata objects
%   fidmodel    - Model object in frequency domain system identification
%   fidmprops   - Properties of fidmodel objects
%   helpc(fidmodel) - Avaliable methods for fiddata objects
%   tiddata     - Time domain data for system identification
%   tidprops    - Properties of tiddata objects
%   helpc(tiddata) - Avaliable methods for tiddata objects
%
% Excitation Signal Design
%   crestmin    - Crest factor minimization of a multisine by Polya's method
%   dfcalc      - Calculation of max. commmon divisor (rec. of period length)
%   dibs        - Discrete interval binary sequence design.
%   dits        - Discrete interval ternary sequence design.
%   dibsimpr    - Improve discrete interval binary sequence.
%   lin2qlog    - Quasi-logarithmic frequency set from linear grid
%   log2qlog    - Quasi-logarithmic frequency set from logarithmic grid
%   mlbs        - Maximum length binary sequence
%   msinclip    - Multisine crest factor minimization by time domain clipping
%   msinprep    - Time domain multisine for downloading
%   optexcit    - Excitation signal with optimum power spectrum
%   randomize   - Randomized odd subset of a frequency vector.
%
% Preprocessing of Data
%   coh2var     - Variance of transfer function from coherence values
%   modifyfv    - Prefiltering of data by inverse of known partial tf
%   tim2fou     - Time domain to frequency domain conversion
%   varanal     - Variance analysis
%
% Estimation
%   autoorder   - Automatic order selection
%   elis        - General parameter estimation routine
%   eliscost    - Value of the elis cost function
%   elisml      - Simple interface to elis for common estimation problems
%   elistper    - Identify system, starting from time domain periodic i/o data
%   elisqa      - Generate run parameter settings for elis
%   elrpf2v     - List run parameter file or convert to run parameter vectors
%   elrpv2f     - List run parameter vectors or convert to run parameter file
%   gmean       - Geometric mean of complex vectors and numbers
%
% Presentation of Results
%   expvect     - Export vectors to ASCII files for plotting etc.
%   gmean       - Geometric mean of complex vectors and numbers
%   ploteltf    - Plot transfer functions and confidence intervals
%   plotelpz    - Plot pole/zero patterns with uncertainty ellipses
%   pzcalc      - Calculate poles and zeros of model
%   tfcalc      - Calculate transfer function values of model
%
% Model Validation
%   corrtest    - Correlation test of residuals
%   fdcovpzp    - Transfer function parameters and covariances from poles/zeros
%   simfou      - Simulate frequency domain data
%   simtime     - Simulate time domain data
%   rdueelis    - Residuals after identification
%   stdpz       - Standard deviations of poles and zeros of tf
%   stdtf       - Standard deviations of magnitude and phase of tf
%   stdtfm      - Empirical standard deviations of Y/X points
%
% Data Vector and File Read/Write
%   tiddata     - Creator of time domain data object
%   fiddata     - Creator of frequency domain data object
%   fidmodel    - Creator of model object
%   fdobjwin    - Open window which helps to generate fdident objects.
%   expcov      - Write data to covariance vector or file
%   expfou      - Write data to Fourier vector or file
%   exppar      - Write data to parameter vector or file
%   exptim      - Write data to time domain data vector or file
%   expvar      - Write data to variance vector or file
%   expvect     - Export vectors to ASCII files for plotting etc.
%   impcov      - Read data from covariance vector or file
%   impfou      - Read data from Fourier vector or file
%   imppar      - Read data from parameter vector or file
%   imptim      - Read data from time domain data vector or file
%   impvar      - Read data from variance vector or file
%   loadasc     - Load contents of ASCII file into variable
%
% Model and Data Conversions
%  MATLAB 6.x and later:
%   fidmodel    - Conversion of Identification Toolbox models to fidmodel objects
%   fiddata     - Conversion of Identification Toolbox iddata/frd/idfrd object to fiddata object
%   frd         - Conversion of fiddata objects to Identification Toolbox frd objects
%   idarx       - Conversion of fidmodel objects to Identification Toolbox arx models
%   idfrd       - Conversion of fiddata objects to Identification Toolbox idfrd objects
%   idpoly      - Conversion of fidmodel objects to Identification Toolbox idpoly models
%   idmodel     - Conversion of fidmodel objects to Identification Toolbox idpoly models
%   tiddata     - Conversion of Identification Toolbox data object to tiddata object
%   iddata      - Conversion of tidmodel object to Identification Toolbox data object
%   nmrdata     - create data object for NMR processing
%  MATLAB 5.3, 5.2:
%   elis2tha    - ELiS to theta format conversion (Identification Toolbox)
%   tha2elis    - Theta format to ELiS conversion
%
% Other
%   digitnum    - Number of mantissa digits necessary to represent numbers
%   fdguitst    - Automatically run all demos and tests of the GUI
%   fdiddemo    - Demonstrations for the toolbox
%   gmean       - Geometric mean of complex vectors and numbers
%   iterctrl    - Iteration control using pull-down menu
%   loadvar     - Load value of single variable from mat file
%   mfilenames  - List all M-files in directory (works also for class and private dirs)
%   oldhelp     - Help on older call forms of functions
%   pairs       - Find closest point pairs in two complex vectors
%   savevar     - Save variable into existing mat file
%   usage       - Show call forms of function
%   yesinput    - "Intelligent" input function with default value
%   ywalk       - yulewalk without windowing

% Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2006
% All rights reserved.
% $Revision: $
