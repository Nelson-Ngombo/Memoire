%CAEMDEF  Settings of graphics objects for CAEM
%
%       See also: CAEM.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-98
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Roman
%       Last modified: 31-Oct-1998

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
edith      =  18;
pushbh     =  20;
radiobh    =  18;
checkbh    =  18;
poph       =  18;
tdy        =   6;
pbdy       =   6;
rbdy       =   6;
cbdy       =   6;
bmtext_dxo =  70; 

fig_dx    = 640;
fig_dy    = 480;
fig_offsx = 10;
fig_offsy = 30;


axdiff_dx = 40;
fromframe_dy = 75;
pbdiff_dx = 10;

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
donepb_offsy = statusframe_dy+5;
donepb_offsy = statusframe_dy+20;


ssizez = (get(0,'screensize'));

if ssizez(3) == 640
  
  fig_dy    = 440;
  fig_offsy = 35;
  
  donepb_offsy = statusframe_dy+20;  
  cancelpb_dx    = donepb_dx;
  cancelpb_dy    = pushbh;
  cancelpb_offsx = donepb_offsx-cancelpb_dx-20;
  cancelpb_offsy = donepb_offsy;

else
  
  cancelpb_dx    = donepb_dx;
  cancelpb_dy    = pushbh;
  cancelpb_offsx = donepb_offsx;
  cancelpb_offsy = donepb_offsy+donepb_dy+pbdy;

end;

loadmpb_dx    = donepb_dx;
loadmpb_dy    = pushbh;
loadmpb_offsx = donepb_offsx-loadmpb_dx-pbdiff_dx;
loadmpb_offsy = cancelpb_offsy;

frame1_dy    = 140;
frame1_offsy = cancelpb_offsy+cancelpb_dy+10;

if ssizez(3) == 640
frame1_offsy = cancelpb_offsy+cancelpb_dy+10;
end;

axes1_dx    = (fig_dx-20-axdiff_dx-2*axdiff_dx)/3;
axes1_dy    = (fig_dy-20-frame1_offsy-frame1_dy-fromframe_dy);
axes1_offsx = axdiff_dx;
axes1_offsy = fig_dy-20-axes1_dy;

fr1ttext_dx    = axes1_dx;
fr1ttext_dy    = texth;
fr1ttext_offsx = axes1_offsx;
fr1ttext_offsy = axes1_offsy+axes1_dy;

axes2_dx    = axes1_dx;
axes2_dy    = axes1_dy;
axes2_offsx = axes1_offsx+axes1_dx+axdiff_dx;
axes2_offsy = axes1_offsy;

fr2ttext_dx    = axes1_dx;
fr2ttext_dy    = texth;
fr2ttext_offsx = axes2_offsx;
fr2ttext_offsy = fr1ttext_offsy;

axes3_dx    = axes1_dx;
axes3_dy    = axes1_dy;
axes3_offsx = axes2_offsx+axes2_dx+axdiff_dx;
axes3_offsy = axes1_offsy;

fr3ttext_dx    = axes1_dx;
fr3ttext_dy    = texth;
fr3ttext_offsx = axes3_offsx;
fr3ttext_offsy = fr1ttext_offsy;

frame1_dx    = axes1_dx;
frame1_dy    = 140;
frame1_offsx = axes1_offsx;
frame1_offsy = frame1_offsy;

modeltext_dx    = 40;
modeltext_dy    = texth;
modeltext_offsx = frame1_offsx+frame1_dx-10-modeltext_dx;
modeltext_offsy = frame1_offsy+frame1_dy-modeltext_dy-10;

bmtext_dx    = frame1_dx-modeltext_dx-5;
bmtext_dy    = texth;
bmtext_offsx = frame1_offsx+10;
bmtext_offsy = modeltext_offsy;

f1text_dx    = frame1_dx-10;
f1text_dy    = frame1_dy-bmtext_dy-22;
f1text_offsx = frame1_offsx+5;
f1text_offsy = frame1_offsy+3;

frame2_dx    = frame1_dx;
frame2_dy    = frame1_dy;
frame2_offsx = axes2_offsx;
frame2_offsy = frame1_offsy;

m1text_dx    = bmtext_dxo;
m1text_dy    = texth;
m1text_offsx = frame2_offsx+10;
m1text_offsy = bmtext_offsy;

modelpop2_dx    = bmtext_dxo;
modelpop2_dy    = poph;
modelpop2_offsx = frame2_offsx+frame2_dx-10-modelpop2_dx;
modelpop2_offsy = bmtext_offsy;

f2text_dx    = f1text_dx;
f2text_dy    = f1text_dy;
f2text_offsx = frame2_offsx+10;
f2text_offsy = f1text_offsy;

frame3_dx    = frame1_dx;
frame3_dy    = frame1_dy;
frame3_offsx = axes3_offsx;
frame3_offsy = frame1_offsy;

frame4_dx    = (frame2_offsx+frame2_dx-frame1_offsx)+10;
frame4_dy    = frame1_dy+10;
frame4_offsx = frame1_offsx-5;
frame4_offsy = frame1_offsy-5;

m2text_dx    = bmtext_dxo;
m2text_dy    = texth;
m2text_offsx = frame3_offsx+10;
m2text_offsy = bmtext_offsy;

modelpop3_dx    = bmtext_dxo;
modelpop3_dy    = poph;
modelpop3_offsx = frame3_offsx+frame3_dx-10-modelpop3_dx;
modelpop3_offsy = bmtext_offsy;

f3text_dx    = f1text_dx;
f3text_dy    = f1text_dy;
f3text_offsx = frame3_offsx+10;
f3text_offsy = f1text_offsy;

critpop_dx    = 115;
critpop_dy    = poph;
critpop_offsx = frame1_offsx+frame1_dx-critpop_dx;
critpop_offsy = frame1_offsy+frame1_dy+10;

comptext_dx    = bmtext_dxo-25;
comptext_dy    = texth;
comptext_offsx = frame1_offsx;
comptext_offsy = critpop_offsy;

typepop_dx    = 175;
typepop_dy    = poph;
typepop_offsx = axes2_offsx+(axes3_offsx+axes3_dx-axes2_offsx)/2-typepop_dx/2;
typepop_offsy = critpop_offsy;

linlogpop_dx    = 80;
linlogpop_dy    = poph;
linlogpop_offsx = axes1_offsx;
linlogpop_offsy = critpop_offsy;

couplepop_dx    = 80;
couplepop_dy    = poph;
couplepop_offsx = fig_dx-20-couplepop_dx;
couplepop_offsy = critpop_offsy;

centerx=frame3_offsx-(frame2_offsx+frame2_dx);
fromfrbot=5;
disply=(frame2_dy-2*fromfrbot-5*pushbh)/4;

%movepb_dx    = 20; %x>
%movepb_dy    = pushbh;
%movepb_offsx = centerx-movepb_dx/2;
%movepb_offsy = frame2_offsy+frame2_dy-fromfrbot-movepb_dy;

copypb_dx    = 20; %>
copypb_dy    = pushbh;
copypb_offsx = centerx-copypb_dx/2;
copypb_offsy = frame2_offsy+frame2_dy-fromfrbot-copypb_dy;

copysetpb_dx    = copypb_dx; %>>
copysetpb_dy    = copypb_dy;
copysetpb_offsx = copypb_offsx;
copysetpb_offsy = copypb_offsy-copypb_dy-disply;

%remmovepb_dx    = movepb_dx; %<x
%remmovepb_dy    = movepb_dy;
%remmovepb_offsx = movepb_offsx;
%remmovepb_offsy = copysetpb_offsy-copysetpb_dy-disply;

remcopypb_dx    = copypb_dx; %<
remcopypb_dy    = copypb_dy;
remcopypb_offsx = copypb_offsx;
remcopypb_offsy = copysetpb_offsy-copysetpb_dy-disply;

remcopysetpb_dx    = copypb_dx; %<<
remcopysetpb_dy    = copypb_dy;
remcopysetpb_offsx = copypb_offsx;
remcopysetpb_offsy = remcopypb_offsy-remcopypb_dy-disply;

comparepb_dx    = copysetpb_dx;
comparepb_dy    = copysetpb_dy;
comparepb_offsx = copysetpb_offsx;
comparepb_offsy = remcopysetpb_offsy-remcopysetpb_dy-disply;

crosspop_dx    = 110;
crosspop_dy    = poph;
crosspop_offsx = axdiff_dx;
crosspop_offsy = cancelpb_offsy;

crosspb_dx    = donepb_dx;
crosspb_dy    = pushbh;
crosspb_offsx = crosspop_offsx+crosspop_dx+pbdiff_dx;
crosspb_offsy = cancelpb_offsy;

%
