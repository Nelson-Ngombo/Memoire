% Frequency Domain System Ident Tb Tests
% Version 4.0d (R2019a) 28-June-2019
%
% Utilities
%   hblzohfg    - Plot band-limited and zoh iterpolation illustration
%   hecmptst    - Compile many functions of the toolbox to C
%   hesemfig    - Generate illustrations for seminar presentation
%   hesyntax    - Load all function m-files into workspace (syntactic check)
%   hfdexamp    - Run examples given by helps and in the manual
%   hfdflyer    - Generate figures for flyer
%   hfdhelps    - List all help messages
%   hfdusage    - List all usage information if usage.m exists
%   hloadmat    - Try to load all MAT-files to check integrity
%   hyiad       - Define global variable to accept default answers in yesinput
%   hyiadclr    - Clear global variable to accept default answers in yesinput
%   hfdallsh    - Test all playshows
%
% Test scripts
%   testfd      - Frame program for testing
%   tfdiddem    - Test demonstrations
%   tfdfiles    - Test existence of files
%   tfdhelp     - Test all helps
%   testaod     - Test automatic order selection demos
%
% Object tests
%   testfobj    - Test all fdident objects
%   testiddat   - Test fiddata and tiddata objects
%   testfidm    - Test fidmodel objects
%   testplots   - Test object plots
%
% Helper functions
%   hconfetst   - Test of confidence ellipses
%   hdibstst    - Test of dibs and dibsimpr
%   he2thtst    - Test of elis2tha and tha2elis
%   heictest    - Test of expcov, impcov and loadasc
%   heiftest    - Test of expfou and impfou
%   heiptest    - Test of exppar and imppar
%   heittest    - Test of exptim and imptim
%   heivtest    - Test of expvar and impvar
%   helcptst    - Test of approximate covariance matrix in elis
%   helqtest    - Test of elisqa, fnamanal, elrpf2v and elrpv2f
%   helistst    - Test of elis and simfou
%   helisfix    - Test of parameter fixing in elis
%   helmltst    - Test of elisml
%   heltptst    - Test of elistper
%   helttest    - Test of run time of elis
%   hechk       - Long-running elis call
%   hevcttst    - Test of expvect
%   hecovtst    - Test of fdcovpzp
%   hfdidrun    - Run selected demonstration from function
%   hitctest    - Test of iterctrl
%   hstftest    - Test of simtime and tim2fou
%   hstfmtst    - Test of stdtfm
%   hgmeants    - Test of gmean
%   hldvtest    - Test of loadvar and savevar
%   hlqlgtst    - Test of lin2qlog and log2qlog
%   hmlbstst    - Test of mlbs
%   hmodfvts    - Test of modifyfv
%   hmscltst    - Test of msinclip and crestmin
%   hmsprtst    - Test of msinprep
%   hoptxtst    - Test of optexcit
%   hortptst    - test of orthopol
%   htstc2arr   - Test conversion of contraints to arrays cp*[num,denom]'=cb
%   hpairsts    - Test of pairs
%   hpltfpts    - Test of ploteltf, plotelpz, stdtf, stdpz, stdtfm
%   hrduetst    - Test of rdueelis
%   htestfidm   - Test fidmodel plots
%   hvarants    - Test of varanal
%   hvatsobj    - Test of varanal with objects
%   hywalkts    - Test of ywalk
%
%   hinittest    - Test and compare initial settings
%   hseefigs     - See figures saved by inittest

% Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2002
% All rights reserved.
% $Revision: $
