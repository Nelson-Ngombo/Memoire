%SMEDEF  Settings of graphics objects for SME
%
%       See also: SME.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Roman
%       Last modified: 1-Jun-2001, GYS

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


textbh     =  18;
pushbh     =  20;
popbh      =  18;
editbh     =  19;
checkbh    =  18;
tdy        =   6;
pbdy       =  10;
cbdy       =   6;
ebdy       =   6;
 

fig_dx    = 620;
fig_dy    = 385;
fig_offsx = 10;
fig_offsy = 20;


statusframe_dx    = 620;
statusframe_dy    = 24;
statusframe_offsx = 1;
statusframe_offsy = 1;

statustext_dx    = 614;
statustext_dy    = 18;
statustext_offsx = 4;
statustext_offsy = 4;

donepb_dx    = 80;
donepb_dy    = pushbh;
donepb_offsx = 520;
donepb_offsy = 44;

cancelpb_dx    = 80;
cancelpb_dy    = pushbh;
cancelpb_offsx = 520;
cancelpb_offsy = 74;

collectpb_dx    = 80;
collectpb_dy    = pushbh;
collectpb_offsx = 520;
collectpb_offsy = 104;

showcb_dx    = 80;
showcb_dy    = checkbh;
showcb_offsx = 160;
showcb_offsy = 114;

lframe_dx    = 330;
lframe_dy    = 100;
lframe_offsx = 10;
lframe_offsy = 44;

finishpb_dx    = 80;
finishpb_dy    = pushbh;
finishpb_offsx = 250;
finishpb_offsy = 54;

pausepb_dx    = 80;
pausepb_dy    = pushbh;
pausepb_offsx = 250;
pausepb_offsy = 84;


abortpb_dx    = 80;
abortpb_dy    = pushbh;
abortpb_offsx = 160;
abortpb_offsy = 54;

skippb_dx    = 80;
skippb_dy    = pushbh;
skippb_offsx = 160;
skippb_offsy = 84;

autopb_dx    = 40;
autopb_dy    = pushbh;
autopb_offsx = 290;
autopb_offsy = 295;


startpb_dx    = 80;
startpb_dy    = pushbh;
startpb_offsx = 250;
startpb_offsy = 114;

elispb_dx    = 90;
elispb_dy    = pushbh;
elispb_offsx = 20;
elispb_offsy = 54;


iterationtext_dx     = 60;
iterationtext_dy     = textbh;
iterationtext_offsx  = 20;
iterationtext_offsy  = 114;

uframe_dx    = 330;
uframe_dy    = 211;
uframe_offsx = 10;
uframe_offsy = 154;

ax_dx    = 200;
ax_dy    = 203;
ax_offsx = 400;
ax_offsy = 162;

varpop_dx    = 80;
varpop_dy    = popbh;
varpop_offsx = 400;
varpop_offsy = 44;

transientcb_dx    = 190;
transientcb_dy    = textbh;
transientcb_offsx = 20;
transientcb_offsy = 164;

slowertext_dx    = 190;
slowertext_dy    = textbh;
slowertext_offsx = 38;
slowertext_offsy = 188;

improvedcb_dx    = 190;
improvedcb_dy    = textbh;
improvedcb_offsx = 20;
improvedcb_offsy = 205;

sectext_dx   = 60; %It is defined again later.
aboveimproved=7; %Start other buttons upper

raztext_dx    = 40;
raztext_dy    = textbh;
raztext_offsx = 20;
raztext_offsy = 235;

pophmod=0;
razpop_dx    = 75;
%razpop_dy    = popbh-pophmod;
razpop_dy    = popbh;
razpop_offsx = 60;
razpop_offsy = 235;

razedit_dx    = 60;
razedit_dy    = editbh;
razedit_offsx = 222;
razedit_offsy = 235;


raztext2_dx    = 50;
raztext2_dy    = textbh;
raztext2_offsx = 137;
raztext2_offsy = 235;

fsoffsxmod=2;
fsedit_dx    = 60;
fsedit_dy    = editbh;
fsedit_offsx = 222;
fsedit_offsy = 235;

fstext_dx    = 70;
fstext_dy    = textbh;
fstext_offsx = 150;
fstext_offsy = 235;

fstext2_dx    = 30;
fstext2_dy    = textbh;
fstext2_offsx = 284;
fstext2_offsy = 235;

delaytext_dx    = 40;
delaytext_dy    = textbh;
delaytext_offsx = 20;
delaytext_offsy = 259;

delpop_dx    = 75;
delpop_dy    = popbh;
delpop_offsx = 60;
delpop_offsy = 259;

sectext_dx    = 53; %It has been defined before.
sectext_dy    = textbh;
sectext_offsx = 284;
sectext_offsy = 259;

deledit_dx    = 60;
deledit_dy    = editbh;
deledit_offsx = 222;
deledit_offsy = 259;

valuetext_dx    = 78;
valuetext_dy    = textbh;
valuetext_offsx = 142;
valuetext_offsy = 259;

orddentext_dx    = 135;
orddentext_dy    = textbh;
orddentext_offsx = 20;
orddentext_offsy = 283;

odedit_dx    = 60;
odedit_dy    = editbh;
odedit_offsx = 222;
odedit_offsy = 283;

ordnumtext_dx    = 135;
ordnumtext_dy    = textbh;
ordnumtext_offsx = 20;
ordnumtext_offsy = 307;
 
onedit_dx    = 60;
onedit_dy    = editbh;
onedit_offsx = 222;
onedit_offsy = 307;

domaintext_dx    = 135;
domaintext_dy    = textbh;
domaintext_offsx = 20;
domaintext_offsy = 331;

dompop_dx    = 60;
dompop_dy    = popbh;
dompop_offsx = 222;
dompop_offsy = 335;

zsdspop_dx    = 105;
zsdspop_dy    = popbh;
zsdspop_offsx = 400;
zsdspop_offsy = 74;

complexcb_dx    = 100;
complexcb_dy    = transientcb_dy;
complexcb_offsx = dompop_offsx;
complexcb_offsy = improvedcb_offsy;

linloghpop_dx    = 80;
linloghpop_dy    = popbh;
linloghpop_offsx = 400;
linloghpop_offsy = 74;

deselpb_dx    = 105;
deselpb_dy    = pushbh;
deselpb_offsx = 400;
deselpb_offsy = 44;

trordtext_dx = valuetext_dx;
trordtext_dy = valuetext_dy;
trordtext_offsx = valuetext_offsx;
trordtext_offsy = transientcb_offsy;

trordedit_dx = onedit_dx;
trordedit_dy = onedit_dy;
trordedit_offsx = onedit_offsx;
trordedit_offsy = transientcb_offsy;
