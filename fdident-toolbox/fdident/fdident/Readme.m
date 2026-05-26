%README info, Frequency Domain System Identification Toolbox
%Last modified: 06-Apr-2005
%
%Version 3.3
%Novelties:
% - Characterization of system nonlinearities
% - Improved object handling
% - Smoothless transition of data and models from/to the 
%   Control and Identification toolboxes
%
%Version 3.1
%Novelties:
% - Automatic order selection for models
% - Graphical generation of data objects
% - possibility of complex coefficients
%
%In order to maintain compatibility with the System Identification Toolbox, 
%[obj1,obj2] and [obj1;obj2] have been temporarily switched off. 
%Use merge(obj1,obj2) and addchannels(obj1,obj2) instead. 
%The simple [...] syntaxes will be restored, compatible with SYSID, in 
%fdident version 3.2.
%
%Version 3.0
%This is an important upgrade compared to the previous versions.
%The command-line calls are upwards compatible, so all old calls work
%untouched, but important improvements have been introduced.
%
%In the graphical user interface of version 3.1, there is one important 
%change. UserLevel has now the selection Automatic/Interactive/Advanced.
%Automatic is somewhat different from the earlier "Basic": if you have 
%action records for this level, we suggest to execute and correct them
%step by step.
%
%1) A Graphical User Interface is available, type 'fdtool' or 'fdident'
%2) Objects help the consistent handling of data and model properties,
%   see 'help fiddata', 'help tiddata', 'help fidmodel'
%   Old data file formats (*.fbn, etc.) are not necessary any more.
%3) Simplified calls can be used for most functions
%   The old form is still available, see 'oldhelp <funcname>'
%4) Important new functionalities are available in elis, e.g. handling
%   of transients or calculations based on orthogonal polynomials for
%   badly conditioned or high-order systems ('help elis')
%
%When you have unzipped your toolbox, and extended the path, your fdident 
%toolbox will function as it is for a week.
%In order to make it working further, you will need a passcode from
%the developers. If you are a subscriber, and have downloaded the toolbox 
%from the WEB, you will get your passcode within 3 working days.
%Otherwise, first you need to obtain a license for the toolbox,
%and the developers need to get your Matlab license number (type 'license'
%in Matlab). They will contact you within 3 working days for the license 
%number, but you can speed up preparations by sending your license number 
%immediately to fdident@x2con.hu. 
%You will receive an email with your passcode and instructions within 
%3 working days again by email. 
%
%Once you have your passcode, type 'fdtool install' in Matlab, and 
%copy the passcode into the command window. Your installation is
%complete now.
%   
%Start the GUI by typing 'fdtool' under Matlab. Different on-line helps
%will guide you further. If you experience any problem, run the test file
%'fdunique', and act according to its messages. With further problems or
%questions turn to fdident@vub.ac.be.
%
%One of the WWW pages contains a list of the new possibilities
%("Usage and examples", http://elecftp.vub.ac.be/fdident/usage.html).

% Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
% All rights reserved.
% $Revision: $
