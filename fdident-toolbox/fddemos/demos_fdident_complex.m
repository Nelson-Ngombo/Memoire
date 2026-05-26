function demos_fdtool_complex
%Run demonstrations which show the complex identification examples 
%with the Frequency Domain System Identification Toolbox.
%
%Push "Run this demo" at the upper right corner to see them.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2006
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Sep-2006, I. Kollar

fdtool;
fdtool('callback', 'fdtool', 'ui_help_examples', 'fdtool_menu_examples');
