%GETTIDEF  Settings of graphics objects for GETTIME
%
%       See also: GETTIME.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Roman
%       Last modified: 19-August-1998

figure_col = [192 192 192]/255;
figure_col = get(0,'defaultuicontrolbackground');
frame_bgr_col = 'default';
frame_fg_col  = 'default';
checkb_bgr_col = 'default';
checkb_fg_col  = [ 0 0 0 ];
pushb_bgr_col = 'default';
pushb_fg_col  = [ 0 0 0 ];
radiob_bgr_col = 'default';
radiob_fg_col  = [ 0 0 0 ];
edit_bgr_col = 'default';
edit_fg_col  = [ 0 0 0 ];
text_bgr_col = 'default';
text_fg_col  = [ 0 0 0 ];
axes_bgr_col = [ 0.3 0.3 0.3 ];
axes_fg_col  = [ 0.7 0.7 0.7 ];
popup_bgr_col = 'default';
popup_fg_col  = [ 0 0 0 ];

axes_font_name = 'times'; %'Helvetica';
axes_font_size = 10;
text_font_size='default'; %10;

textbh     =  18;
pushbh     =  20;
radiobh    =  18;
poph       =  18;
editbh     =  18;
tdy        =   6;
pbdy       =   6;
rbdy       =   6;
ebdy       =   6;
 

fig_dx    = 530;
fig_dy    = 310;
fig_offsx = 50;
fig_offsy = 250;

statusframe_dx    = fig_dx;
statusframe_dy    = 24;
statusframe_offsx = 1;
statusframe_offsy = 1;

statustext_dx    = statusframe_dx-6;
statustext_dy    = statusframe_dy-6;
statustext_offsx = statusframe_offsx+3;
statustext_offsy = statusframe_offsy+3;

dataframe_dx    = 400;
dataframe_dy    = 150;
dataframe_offsx =  10;
dataframe_offsy =  statusframe_dy+20;

axes_dx    = 400;
axes_dy    = 115;
axes_offsx = 0;
axes_offsy = fig_dy-axes_dy;

infotext51_dx    = (dataframe_dx-20)/4; %maximum /2
infotext51_dy    = textbh;
infotext51_offsx = dataframe_offsx+5;
infotext51_offsy = dataframe_offsy+5;

infotext52_dx    = infotext51_dx;
infotext52_dy    = textbh;
infotext52_offsx = dataframe_offsx+dataframe_dx-5-infotext52_dx;
infotext52_offsy = infotext51_offsy;

infotext41_dx    = infotext51_dx;
infotext41_dy    = textbh;
infotext41_offsx = infotext51_offsx;
infotext41_offsy = infotext51_offsy+infotext51_dy+tdy;

infotext42_dx    = infotext51_dx;
infotext42_dy    = textbh;
infotext42_offsx = infotext52_offsx;
infotext42_offsy = infotext41_offsy;

infotext31_dx    = infotext51_dx;
infotext31_dy    = textbh;
infotext31_offsx = infotext51_offsx;
infotext31_offsy = infotext41_offsy+infotext41_dy+tdy;

infotext32_dx    = infotext51_dx;
infotext32_dy    = textbh;
infotext32_offsx = infotext52_offsx;
infotext32_offsy = infotext31_offsy;

infotext21_dx    = infotext51_dx;
infotext21_dy    = textbh;
infotext21_offsx = infotext51_offsx;
infotext21_offsy = infotext31_offsy+infotext31_dy+tdy;

infotext22_dx    = infotext51_dx;
infotext22_dy    = textbh;
infotext22_offsx = infotext52_offsx;
infotext22_offsy = infotext21_offsy;

infotext1_dx    = dataframe_dx-10;
infotext1_dy    = 2*textbh;
infotext1_offsx = dataframe_offsx+5;
infotext1_offsy = dataframe_offsy+dataframe_dy-infotext1_dy-10;

donepb_dx    = 80;
donepb_dy    = pushbh;
donepb_offsx = fig_dx-donepb_dx-20;
donepb_offsy = statusframe_dy+20;

cancelpb_dx    = donepb_dx;
cancelpb_dy    = pushbh;
cancelpb_offsx = donepb_offsx;
cancelpb_offsy = donepb_offsy+donepb_dy+pbdy;

autocb_dx    = cancelpb_dx+10;
autocb_dy    = cancelpb_dy;
autocb_offsx = cancelpb_offsx;
autocb_offsy = dataframe_dy+dataframe_offsy-autocb_dy;

zohcb_dx    = cancelpb_dx+30;
zohcb_dy    = cancelpb_dy;
zohcb_offsx = 190;
zohcb_offsy = autocb_offsy+autocb_dy+5;

memorycb_dx    = cancelpb_dx+10;
memorycb_dy    = autocb_dy;
memorycb_offsx = autocb_offsx;
memorycb_offsy = autocb_offsy-autocb_dy-5;