%GFDDDEF  Settings of graphics objects for GFDD
%
%       See also: GFDD.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Roman
%       Last modified: 25-Sep-2001

figure_col = [192 192 192]/255;
figure_col = get(0,'defaultuicontrolbackground');
frame_bgr_col = 'default'; %[ 0 0 0 ];
frame_fg_col  = 'default'; %[ 1 1 1 ];
checkb_bgr_col = 'default'; %[ 0.5 0.5 0.5 ];
checkb_fg_col  = 'default'; %[ 0 0 0 ];
pushb_bgr_col = 'default'; %[ 0.6 0.6 0.6 ];
pushb_fg_col  = 'default'; %[ 0 0 0 ];
radiob_bgr_col = 'default'; %[ 0.6 0.6 0.6 ];
radiob_fg_col  = 'default'; %[ 0 0 0 ];
edit_bgr_col = 'default'; %[ 0.4 0.4 0.4 ];
edit_fg_col  = 'default'; %[ 0 0 0 ];
text_bgr_col = 'default'; %[ 0.5 0.5 0.5 ];
text_fg_col  = 'default'; %[ 0 0 0 ];
axes_bgr_col = 'default'; %[ 0.3 0.3 0.3 ];
axes_fg_col  = 'default'; %[ 0.7 0.7 0.7 ];
popup_bgr_col = 'default'; %[ 0.4 0.4 0.4 ];
popup_fg_col  = 'default'; %[ 0 0 0 ];

axes_font_name = 'Helvetica';
axes_font_size = 10;
text_font_size='default'; %10;

texth      =  18;
textbh     =  18;
edith      =  18;
pushbh     =  20;
radiobh    =  18;
checkbh    =  18;
poph       =  18;
tdy        =   6;
pbdy       =   6;
rbdy       =   6;
cbdy       =   6;
ebdy       =   6;
popdy      =  10; 

fig_dx    = 570;
fig_dy    = 400;
fig_offsx = 10;
fig_offsy = 20;

statusframe_dx    = fig_dx;
statusframe_dy    = 24;
statusframe_offsx = 1;
statusframe_offsy = 1;

statustext_dx    = statusframe_dx-6;
statustext_dy    = statusframe_dy-6;
statustext_offsx = statusframe_offsx+3;
statustext_offsy = statusframe_offsy+3;

donepb_dx    = 80;
donepb_dy    = pushbh;
donepb_offsx = fig_dx-20-donepb_dx;
donepb_offsy = statusframe_dy+20;

cancelpb_dx    = donepb_dx;
cancelpb_dy    = pushbh;
cancelpb_offsx = donepb_offsx;
cancelpb_offsy = donepb_offsy+donepb_dy+pbdy;

importpb_dx    = donepb_dx;
importpb_dy    = pushbh;
importpb_offsx = 20;
importpb_offsy = fig_dy-pushbh-20;

composepb_dx    = donepb_dx;
composepb_dy    = pushbh;
composepb_offsx = importpb_offsx;
composepb_offsy = importpb_offsy-pbdy-pushbh;

simulatepb_dx    = donepb_dx;
simulatepb_dy    = pushbh;
simulatepb_offsx = composepb_offsx;
simulatepb_offsy = composepb_offsy-pbdy-pushbh;

measurepb_dx    = donepb_dx;
measurepb_dy    = pushbh;
measurepb_offsx = importpb_offsx;
measurepb_offsy = simulatepb_offsy-pbdy-pushbh;


workspacepb_dx    = donepb_dx;
workspacepb_dy    = pushbh;
workspacepb_offsx = measurepb_offsx;
workspacepb_offsy = importpb_offsy-pbdy-pushbh;

dataframe_dx    = 280;
dataframe_dy    = 130;
dataframe_offsx =  10;
dataframe_offsy =  statusframe_dy+20;

infotext5_dx    = (dataframe_dx-20)/2;
infotext5_dy    = textbh;
infotext5_offsx = dataframe_offsx+5;
infotext5_offsy = dataframe_offsy+5;

infotext10_dx    = infotext5_dx;
infotext10_dy    = textbh;
infotext10_offsx = dataframe_offsx+dataframe_dx-5-infotext5_dx;
infotext10_offsy = infotext5_offsy;

infotext4_dx    = infotext5_dx;
infotext4_dy    = textbh;
infotext4_offsx = infotext5_offsx;
infotext4_offsy = infotext5_offsy+infotext5_dy+tdy;

infotext9_dx    = infotext5_dx;
infotext9_dy    = textbh;
infotext9_offsx = infotext10_offsx;
infotext9_offsy = infotext4_offsy;

infotext3_dx    = infotext5_dx;
infotext3_dy    = textbh;
infotext3_offsx = infotext5_offsx;
infotext3_offsy = infotext4_offsy+infotext4_dy+tdy;

infotext8_dx    = infotext5_dx;
infotext8_dy    = textbh;
infotext8_offsx = infotext10_offsx;
infotext8_offsy = infotext3_offsy;

infotext2_dx    = infotext4_dx;
infotext2_dy    = textbh;
infotext2_offsx = infotext4_offsx;
infotext2_offsy = infotext3_offsy+infotext3_dy+tdy;

infotext7_dx    = infotext5_dx;
infotext7_dy    = textbh;
infotext7_offsx = infotext10_offsx;
infotext7_offsy = infotext2_offsy;

infotext1_dx    = infotext4_dx;
infotext1_dy    = textbh;
infotext1_offsx = infotext4_offsx;
infotext1_offsy = infotext2_offsy+infotext2_dy+tdy;

infotext6_dx    = infotext5_dx;
infotext6_dy    = textbh;
infotext6_offsx = infotext10_offsx;
infotext6_offsy = infotext1_offsy;

datatext_dx    = 70;
datatext_dy    = textbh;
datatext_offsx = dataframe_offsx+dataframe_dx/2-datatext_dx/2;
datatext_offsy = dataframe_offsy+dataframe_dy-datatext_dy/2;

laxes_dx    = (fig_dx-measurepb_offsx-measurepb_dx-60-40);
laxes_dy    = (fig_dy-20-dataframe_offsy-dataframe_dy-60);
laxes_offsx = measurepb_offsx+measurepb_dx+60;
laxes_offsy = dataframe_offsy+dataframe_dy+30;

linlogvpop_dx    = 80;
linlogvpop_dy    = poph;
linlogvpop_offsx = measurepb_offsx;
linlogvpop_offsy = laxes_offsy+laxes_dy+20;

uaxes_dx    = laxes_dx;
uaxes_dy    = (laxes_dy-45)/2;
uaxes_offsx = laxes_offsx;
uaxes_offsy = laxes_offsy+uaxes_dy+45;

linloghpop_dx    = linlogvpop_dx;
linloghpop_dy    = poph;
linloghpop_offsx = laxes_offsx+laxes_dx/2-linloghpop_dx/2; %ROMAN GYUSZI
linloghpop_offsx = laxes_offsx+laxes_dx/2-linloghpop_dx/4; %ROMAN GYUSZI
linloghpop_offsy = dataframe_offsy+dataframe_dy-linloghpop_dy;

frffxfypop_dx    = linlogvpop_dx;
frffxfypop_dy    = poph;
%frffxfypop_offsx = measurepb_offsx;
frffxfypop_offsx = linloghpop_offsx;
frffxfypop_offsy = linloghpop_offsy-frffxfypop_dy-popdy;

varonoffpop_dx    = linlogvpop_dx;
varonoffpop_dy    = poph;
%varonoffpop_offsx = measurepb_offsx;
varonoffpop_offsx = linloghpop_offsx;
%varonoffpop_offsy = laxes_offsy;
varonoffpop_offsy = frffxfypop_offsy-varonoffpop_dy-popdy;

freqselpb_dx    = 130;
freqselpb_dy    = pushbh;
freqselpb_offsx = donepb_offsx-(freqselpb_dx-donepb_dx);
freqselpb_offsy = dataframe_offsy+dataframe_dy-freqselpb_dy;

