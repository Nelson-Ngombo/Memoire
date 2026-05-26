%README info, tests of the Frequency Domain System Identification Toolbox
%Last modified: 30-Oct-2001
%
%The  fdtest  subdirectory (folder) contains the test suite for the Frequency
%Domain System Identification Toolbox (not intended for general distribution,
%however, beta test sites may receive it). The m-file fdtest.m is an automatic
%frame for all tests, requiring no human intervention, if no file  fdtest.mat
%is present in the path of Matlab.
%    However, some options will be offered if the file fdtest.mat is present.
%A diary with name  diaryfdt  can be generated, and the most important plots
%can be saved into the postscript files fdtest.ps and fddemos.ps. The
%statement  prtsc  can also be automatically executed for the important plots.
%fdtest may even stop after each important plot, in order to provide an easy
%way for comparison of the display plots with the reference set of the
%printouts (see below). At some points of the program the user may choose from
%several options, if no automatic acceptance of the default answers is chosen.
%     At the beginning of the general test, it is recommended to generate
%a reference printout set, e.g. using Sun-Matlab, because this
%provides a rather reliable comparison basis for other platforms. The
%differences between implementations show up most often in handling of the
%Graph window. It may even be useful to compare each display with the
%reference printouts, by selecting the stop option of fdtest.

% Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
% All rights reserved.
% $Revision: $
