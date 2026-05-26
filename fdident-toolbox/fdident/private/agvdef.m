%AGVDEF  Settings of graphics objects for AGV
%
%       See also: AGV.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Roman
%       Last modified: 26-June-2000


% General constants used for window setup.

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

%axes_font_name = 'times'; %'Helvetica';
%axes_font_size = 'default';
%text_font_size='default'; %10;

% Constants used for vertical spacing of various gui controls.

textbh     =  18;
pushbh     =  20;
radiobh    =  18;
poph       =  18;
editbh     =  19;
tdy        =   6;
pbdy       =   6;
rbdymod    =   4;
rbdy       =   6-rbdymod;
ebdy       =   6;
 
 
fromsframe_y = 20;

% First comes the wondow size definition. 
 
fig_dx    = 638;
fig_dy    = 425;
fig_offsx = 2;
fig_offsy = 2;

% From here on the cornerstones of the window are defined. If there is a gui control
% to which another control is relatively positioned to, it should preceed the other.
% The definition order reflects the logical structure of the window.

% statusframe is of fig_dx width, i.e. full window.

statusframe_dx    = fig_dx;
statusframe_dy    = 20;
statusframe_offsx = 1;
statusframe_offsy = 1;

% statustext is positioned relative to statusframe

statustext_dx    = statusframe_dx-6;
statustext_dy    = statusframe_dy-6;
statustext_offsx = statusframe_offsx+3;
statustext_offsy = statusframe_offsy+3;

% dataframe has a defined size, it is positioned vertically relative to statusframe.
% The offset is set prviously in the file, so that the layout can be easily modified.

dataframe_dx    = 280;
dataframe_dy    = 127;
dataframe_offsx =  10;
dataframe_offsy =  statusframe_dy+fromsframe_y;

% infotext5 is positioned relative to the dataframe. 

infotext5_dx    = (dataframe_dx-20)/2;
infotext5_dy    = textbh;
infotext5_offsx = dataframe_offsx+5;
infotext5_offsy = dataframe_offsy+5;

% infotext10 is positioned relative to infotext5. 

infotext10_dx    = infotext5_dx;
infotext10_dy    = textbh;
infotext10_offsx = dataframe_offsx+dataframe_dx-5-infotext5_dx;
infotext10_offsy = infotext5_offsy;

% etc.

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

% datatext is positioned relative to the dataframe. 

datatext_dx    = 70;
datatext_dy    = textbh;
datatext_offsx = dataframe_offsx+dataframe_dx/2-datatext_dx/2;
datatext_offsy = dataframe_offsy+dataframe_dy-datatext_dy/2;

% getvframe horizontally is of the same size as dataframe, and is positioned 
% relative to dataframe.

getvframe_dx    = dataframe_dx;
getvframe_dy    = 125-4*rbdymod;
getvframe_offsx = dataframe_offsx;
getvframe_offsy = dataframe_offsy+dataframe_dy+textbh;

% getrb5 is positioned in the bottom left corner of getvframe. 

getrb5_dx    = 140; %Perform Var. Anal.
getrb5_dy    = radiobh;
getrb5_offsx = getvframe_offsx+5;
getrb5_offsy = getvframe_offsy+5;

% getrb2 is positioned horizontally algined with getrb5, vertically it is placed
% right above the provious control. The vertical separation is defined at the beginning
% of the file (rbdy)

getrb2_dx    = getrb5_dx; %Import..
getrb2_dy    = radiobh;
getrb2_offsx = getrb5_offsx;
getrb2_offsy = getrb5_offsy+getrb5_dy+rbdy;

getrb4_dx    = getrb5_dx; %Previous
getrb4_dy    = radiobh;
getrb4_offsx = getrb5_offsx;
getrb4_offsy = getrb2_offsy+getrb2_dy+rbdy;

getrb3_dx    = getrb5_dx; %From data
getrb3_dy    = radiobh;
getrb3_offsx = getrb4_offsx;
getrb3_offsy = getrb4_offsy+getrb4_dy+rbdy;

% vyedit is horizontally positioned to the right side of getvframe with a reasonable margin.

vyedit_dx    = 60;
vyedit_dy    = editbh;
vyedit_offsx = getvframe_offsx+getvframe_dx-5-vyedit_dx;
vyedit_offsy = getrb3_offsy;
%vyedit_offsy = getrb3_offsy+getrb4_dy+rbdy;

% vytext is vertically aligned with the respective edit control, horozontally it is 
% positioned just before it
vytext_dx    = 20;
vytext_dy    = textbh;
vytext_offsx = vyedit_offsx-vytext_dx-5;
vytext_offsy = vyedit_offsy;

getrb1_dx    = getrb5_dx; %Set to Constant
getrb1_dy    = radiobh;
getrb1_offsx = getrb4_offsx;
getrb1_offsy = vyedit_offsy+18+ebdy-rbdy-3;
%getrb1_offsy = getrb2_offsy+getrb2_dy+rbdy;

% vxtext is vertically aligned with the respective edit control, horozontally it is 
% positioned just before it

vxedit_dx    = vyedit_dx;
vxedit_dy    = editbh;
vxedit_offsx = vyedit_offsx;
vxedit_offsy = getrb1_offsy;

vxtext_dx    = vytext_dx;
vxtext_dy    = textbh;
vxtext_offsx = vxedit_offsx-vxtext_dx-5;
vxtext_offsy = vxedit_offsy;

gettext_dx    = 100;
gettext_dy    = textbh;
gettext_offsx = getvframe_offsx+getvframe_dx/2-gettext_dx/2;
gettext_offsy = getvframe_offsy+getvframe_dy-gettext_dy/2;

muledit_dx    = vyedit_dx; %Scaling factor
muledit_dy    = editbh;
muledit_offsx = vyedit_offsx;
muledit_offsy = getrb4_offsy;

multext_dx    = vytext_dx; %Scaling factor text
multext_dy    = textbh;
multext_offsx = vytext_offsx;
multext_offsy = muledit_offsy;

alltext_dx    = muledit_dx+10;
alltext_dy    = textbh;
alltext_offsx = muledit_offsx-10;
alltext_offsy = muledit_offsy+18;

% averageframe is of the same width as dataframe and horizontally positioned just above 
% the getvframe. Ist height is calculated just to fit in the remaining spaci with
% a reasonable margin.

averageframe_dx    = dataframe_dx;
averageframe_dy    = fig_dy-(getvframe_offsy+getvframe_dy+textbh)-20;
averageframe_offsx = dataframe_offsx;
averageframe_offsy = getvframe_offsy+getvframe_dy+textbh;

avrb3_dx    = 180;
avrb3_dy    = radiobh;
avrb3_offsx = getrb4_offsx;
avrb3_offsy = averageframe_offsy+5  +avrb3_dy+rbdy+2;

avrb2_dx    = avrb3_dx;
avrb2_dy    = radiobh;
avrb2_offsx = avrb3_offsx;
avrb2_offsy = avrb3_offsy+avrb3_dy+rbdy;

avrb1_dx    = avrb3_dx;
avrb1_dy    = radiobh;
avrb1_offsx = avrb2_offsx;
avrb1_offsy = avrb2_offsy+avrb2_dy+rbdy;

avrb4_dx    = avrb3_dx; %
avrb4_dy    = radiobh;
avrb4_offsx = avrb1_offsx;
avrb4_offsy = avrb3_offsy-(avrb1_dy+rbdy);

enedit_dx    = 60;
enedit_dy    = editbh;
enedit_offsx = averageframe_offsx+averageframe_dx-5-enedit_dx;
enedit_offsy = avrb1_offsy;

averagetext_dx    = 90;
averagetext_dy    = textbh;
averagetext_offsx = averageframe_offsx+averageframe_dx/2-averagetext_dx/2;
averagetext_offsy = averageframe_offsy+averageframe_dy-averagetext_dy/2;

% This pushbutton is positioned to the bottom right corner of the screeen.

donepb_dx    = 80;
donepb_dy    = pushbh;
donepb_offsx = fig_dx-donepb_dx-20;
donepb_offsy = statusframe_dy+fromsframe_y;

% cancel button is right above the done button.

cancelpb_dx    = donepb_dx;
cancelpb_dy    = pushbh;
cancelpb_offsx = donepb_offsx;
cancelpb_offsy = donepb_offsy+donepb_dy+pbdy;

% freqpb is above the cancelpb, horizontall ypositioned somewhat to the left.

freqpb_dx    = 130;
freqpb_dy    = pushbh;
freqpb_offsx = donepb_offsx-(freqpb_dx-donepb_dx);
freqpb_offsy = cancelpb_offsy+cancelpb_dy+pbdy;

% evalpb is above the freqpb.

evalpb_dx    = freqpb_dx;
evalpb_dy    = pushbh;
evalpb_offsx = freqpb_offsx;
evalpb_offsy = freqpb_offsy+freqpb_dy+pbdy;

% the two axes fill in the space available to them. 

laxes_dx    = fig_dx-(averageframe_offsx+averageframe_dx+60+40);
laxes_dy    = fig_dy-(dataframe_offsy+dataframe_dy)-20;
laxes_offsx = averageframe_offsx+averageframe_dx+60;
laxes_offsy = dataframe_offsy+dataframe_dy;

uaxes_dx    = laxes_dx;
uaxes_dy    = (laxes_dy-45)/2;
uaxes_offsx = laxes_offsx;
uaxes_offsy = laxes_offsy+uaxes_dy+45;

% the controls below are positioned relative to the axes.

frffxfypop_dx    = 80;
frffxfypop_dy    = poph;
frffxfypop_offsx = laxes_offsx;
frffxfypop_offsy = freqpb_offsy+3;

varpop_dx    = 80;
varpop_dy    = poph;
varpop_offsx = laxes_offsx;
varpop_offsy = cancelpb_offsy+3;

linloghpop_dx    = frffxfypop_dx;
linloghpop_dy    = poph;
linloghpop_offsx = laxes_offsx;
linloghpop_offsy = evalpb_offsy+3;

windowpop_dx    = frffxfypop_dx-23+10;
windowpop_dy    = poph;
windowpop_offsx = averageframe_dx+averageframe_offsx-4-frffxfypop_dx+21-10;
windowpop_offsy = avrb4_offsy;

windowtext_dx    = frffxfypop_dx-23;
windowtext_dy    = poph-3;
windowtext_offsx = windowpop_offsx-windowpop_dx+4;
windowtext_offsy = avrb4_offsy;

suggestpb_dx    = donepb_dx;
suggestpb_dy    = pushbh;
suggestpb_offsx = frffxfypop_offsx;
suggestpb_offsy = donepb_offsy;
%
%End of file