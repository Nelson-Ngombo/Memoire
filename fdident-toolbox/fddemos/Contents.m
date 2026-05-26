% Frequency Domain System Ident Tb Demonstrations
% Version 4.0d (R2019a) 28-June-2019
%
% Main demonstration routines
%   bookdemo    - Frame of demonstrations based on measured data
%   demos       - Matlab V5 demonstration interface
%   fddems1     - subroutine for 'demos': list of general demonstrations
%   fddems2     - subroutine for 'demos': list of book demonstrations
%   fdiddemo    - Frame program to call all demonstrations
%
% General demonstrations
%   autoorder_demo - Demonstration of automatic order selection
%   dibsdemo    - Discrete interval binary sequence design
%   eltpexpl    - Sample file for identification based on periodic i/o data
%   fdcourse    - "Course": problems for self-study
%   fdsynchr    - Sample file for experiment synchronization
%   gmeandem    - Geometric mean of complex numbers
%   mscldemo    - Crest factor minimization
%   msprdemo    - Time function preparation
%   mlbsdemo    - Maximum length binary sequence design
%   optexdem    - Optimal excitation signal design (calls optexde1, optexde2)
%   pairsdem    - Optimal one-by-one pairing of two point sets
%   pzdemo      - Plot pole/zero pattern with confidence ellipses
%   simudemo    - Simulation and estimation example of the usage of the Toolbox
%   tfdemo      - Plot transfer functions with confidence intervals
%   varandem    - Variance analysis and synchronization of data
%   wilkdemo    - Orthopol on a Wilkinson-type example
%
% Demonstrations with measured data
%   alupldem    - Identification of a system - glued aluminum plates
%   bandpdem    - Identification of a system - passive bandpass filter
%   bpcordem    - Phase correction of a bandpass filter
%   cabledem    - Cable fault location
%   crankdem    - Identification of a system - crankcase
%   emachdem    - Identification of a system - electrical machine
%   glfibdem    - Identification of a system - rectangular glass fiber plate
%   inpchdem    - Compensation of an input channel
%   lowpdemo    - Identification of a system - active lowpass filter
%   lpelabex    - Elaborated example of the system identification procedure
%   rarmdemo    - Identification of a system - flexible robot arm
%
% Plot and print measured data
%   fdidpaus    - Stop to show messages in Command Window
%   grapause    - Save graph, pause, handle messages
%   hloadmat    - Load all MAT-files to check their integrity
%   plotcabl    - Plot time records of cable measurements
%   plotfou     - Plot Fourier data from file
%   plotrarm    - Plot time domain data from robotarm.mat

% Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
% All rights reserved.
% $Revision: $
