%FREQSDEF  Settings of graphics objects for FREQSEL
%
%       See also: FREQSEL.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2001
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Roman
%       Last modified: 23-Feb-2001

figure_bgr_col = 'default';% [ 0 0 0 ];
figure_fg_col  = 'default';%[ 1 1 1 ];
frame_bgr_col = 'default';%[ 0 0 0 ];
frame_fg_col  = 'default';%[ 1 1 1 ];
checkb_bgr_col = 'default';%[ 0.5 0.5 0.5 ];
checkb_fg_col  = 'default';%[ 0 0 0 ];
pushb_bgr_col = 'default';%[ 0.6 0.6 0.6 ];
pushb_fg_col  = 'default';%[ 0 0 0 ];
radiob_bgr_col = 'default';%[ 0.6 0.6 0.6 ];
radiob_fg_col  = 'default';%[ 0 0 0 ];
edit_bgr_col = 'default';%[ 0.4 0.4 0.4 ];
edit_fg_col  = 'default';%[ 0 0 0 ];
text_bgr_col = 'default';%[ 0.5 0.5 0.5 ];
text_fg_col  = 'default';%[ 0 0 0 ];
axes_bgr_col = 'default';%[ 0.3 0.3 0.3 ];
axes_fg_col  = 'default';%[ 0.7 0.7 0.7 ];
popup_bgr_col = 'default';%[ 0.4 0.4 0.4 ];
popup_fg_col  = 'default';%[ 0 0 0 ];

axes_font_name = 'Helvetica';
axes_font_size = 12;

texth      =  18;
edith      =  18;
pushbh     =  20;
radiobh    =  18;
checkbh    =  18;
poph       =  18;
tdy        =   6;
pbdy       =   6;
rbdy       =   6;
cbdy       =   6;
 

fig_dx    = 530;
fig_dy    = 370;
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

callpb_dx    = donepb_dx;
callpb_dy    = pushbh;
callpb_offsx = donepb_offsx;
callpb_offsy = cancelpb_offsy+donepb_dy+5*pbdy;

sallpb_dx    = donepb_dx;
sallpb_dy    = pushbh;
sallpb_offsx = donepb_offsx;
sallpb_offsy = callpb_offsy+donepb_dy+pbdy;

excpop_dx    = donepb_dx;
excpop_dy    = poph;
excpop_offsx = donepb_offsx;
excpop_offsy = sallpb_offsy+donepb_dy+pbdy+20;

zsdspop_dx    = 100;
zsdspop_dy    = poph;
zsdspop_offsx = 60;
zsdspop_offsy = donepb_offsy;

frffxfypop_dx    = zsdspop_dx;
frffxfypop_dy    = poph;
frffxfypop_offsx = donepb_offsx-frffxfypop_dx-20;
frffxfypop_offsy = zsdspop_offsy;

laxes_dx    = frffxfypop_offsx+frffxfypop_dx-zsdspop_offsx;
laxes_dy    = fig_dy-cancelpb_offsy-cancelpb_dy-40;
laxes_offsx = zsdspop_offsx;
laxes_offsy = cancelpb_offsy+cancelpb_dy;

uaxes_dx    = laxes_dx;
uaxes_dy    = (laxes_dy-45)/2;
uaxes_offsx = laxes_offsx;
uaxes_offsy = laxes_offsy+uaxes_dy+45;

%Change positions
%tmp=laxes_offsy;
%laxes_offsy=uaxes_offsy;
%uaxes_offsy=tmp;
%clear tmp

linloghpop_dx    = 80;
linloghpop_dy    = poph;
linloghpop_offsx = laxes_offsx+laxes_dx/2-linloghpop_dx/2;
linloghpop_offsy = zsdspop_offsy;

linlogvpop_dx    = donepb_dx;
linlogvpop_dy    = poph;
linlogvpop_offsx = donepb_offsx;
linlogvpop_offsy = laxes_offsy+laxes_dy/2-linlogvpop_dy/2;

