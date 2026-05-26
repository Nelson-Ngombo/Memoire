function demos_fdtool_intro
%Run demonstrations which show the basic functionalities 
%of the Frequency Domain System Identification Toolbox.
%
%Push "Run this demo" at the upper right corner to see them.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2006
%       All rights reserved.
%       $Revision: $
%       Last modified: 15-Sep-2006, I. Kollar

fdtool;
fdtool('callback', 'fdtool', 'ui_help_introductions_ident', 'fdtool_menu_intro_ident');
