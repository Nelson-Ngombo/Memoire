% GUI for the Frequency Domain System Identification Toolbox
% Version 3.1, 31-May-2001
%
% agv       - Variance and/or Averaging main file
% agvdef    - Definition file for agv
% arrplot   - Plot arrow data
% boxmgr    - Box manager for fdtool and gettime
% caem      - Evaluate or Compare Plant models main file
% caemdef   - Definition file for caem
% compinp   - Compose input for time or frequency domain data
% conv2frd  - Convert time data to freq domain data
% demos     - Return demo information to the main MATLAB demo
% dismispb  - Place and handle Close pushbutton in figure
% emachsmk  - Prepare session with log freq settings for emachdem and others
% essd      - Excitation Signal Design
% essddef   - Definition file for essd
% extrcall  - Extract FDTool callback parameters
% fddemutl  - Utility file for demos: execute nonstandard actions
% fddgui1   - Open window to run all fdident GUI demonstrations
% fdgprint  - Utility to print figures to printer or into file
% fdguidw   - Utility for fddgui: create window to play fdident GUI demos
% fdguitst  - Test routine which runs all fdident GUI demos
% fdhlpstr  - Help file for fdtool (generated from word file fdidhelp)
% fdhwcall  - 'Wrapper': call existing file fdhwfun or spec. file
% fdhwf0    - handler for generic "hardware": 'Generic' and 'Discrete'
% fdhwsigl  - SigLab hw handler and sample file for fdhwcall
% fdhwemul  - Emulator for measurement
% fdident   - alternative for fdtool
% fdmeasw   - Handle measurement window for time or frequency domain 
% fdmeadef  - Definition file for fdmeasw
% fdmodord  - Return model order in string format
% fdsimul   - Handle simulation window for time or frequency domain 
% fdsimdef  - Definition file for fdsimul
% fdtool    - Main file of fdtool (fdident GUI)
% fdtstplt  - Test plot for fdtool (in test mode only)
% fdunique  - Check uniqueness of each toolbox file
% fdwindef  - Set fdtool window default properties 
% fixdemos  - load and save all demo MAT-files: fix error between PC and Sun
% freqsel   - Select frequencies in VA or in RMTDD boxes
% freqsdef  - Definition file for freqsel
% garrinfo  - Generate textual info on a given arrow, or internal data
% getfpos   - Return desired figure position for plots
% gettdata  - Get time domain data box
% gettidef  - Definition file for gettdata
% gettime   - Read Time Domain Data (no def file necessary)
% gfdd      - Read Frequency Domain Data
% gfdddef   - Definition file for gfdd
% glstatus  - Status bar handler in fdtool
% gmexp     - Get Matlab Expression dialog
% gmexpdef  - Definition file for gmexp
% guibar3   - Extended bar3 function for fdtool
% guiclose  - Close window function in fdtool
% guicolor  - Color handler in fdtool
% guidbfcn  - Debug function in fdtool - used only in development test mode
% guidtard  - Data read function in fdtool
% guidtawr  - Data write function in fdtool
% guifreez  - Freeze/unfreeze gui (and handle hourglass)
% guiimpv   - Import dialog in fdtool
% guiinfos  - Info/status handler in fdtool
% guimenus  - Global menu handler in fdtool
% guiready  - Global status handler in fdtool (prints Ready text)
% guirecrd  - Action Recorder for fdtool
% guititle  - Adjust text width tool
% helpmgr   - Help manager in fdtool
% infotext  - Display info text on time andfreq domain data
% intoscr   - Place window into screen
% makehist  - Event generator for the Recorder
% plotsegm  - Illustrate time domain data segmentation on existing plot
% prepzoom  - Prepare wide/tall plot for zoom from standard plot
% questarr  - Arrow action dialog
% rbtag     - Radiobutton manager file
% segmdata  - Segment data
% segmdef   - Definition file for segmdata
% sesload   - Load session
% sessave   - Save session
% sme       - Estimate Plant Model box
% smedef    - Definition file for sme
% storewin  - Window status store/restore for sessave/sesload
% ulevctrl  - User level control
% varinfo   - Textual information about variance contents of object
% windspos  - Window position generator
% 
% MAT files
% fdtlogo.mat - logo screen

% Word files
% fdidhelp.doc - word tables of helps
% fdidhelp.dot - style file with preparation macro

% Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2000
% All rights reserved.
% $Revision: $
