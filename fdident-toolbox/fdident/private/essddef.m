%ESSDDEF  Settings of graphics objects for ESSD
%
%       See also: ESSD.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2002
%       All rights reserved.
%       $Revision: $
%       Witten by Gy. Roman
%       Last modified: 30-Nov-2002, IK

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
pushbh     =  20;
radiobh    =  18;
popuph     =  18;
checkbh    =  18;
editbh     =  19;
tdy        =   6;
pbdy       =   6;
rbdy       =   6;
cbdy       =   6;
popdy      =  14; 

fig_dx    = 638;
fig_dy    = 425;
fig_offsx = 2;
fig_offsy = 32;
ampheight = 100;
fromtop   = 40;
fromsf_y  = 20;
rbshift=rbdy+radiobh;

statusframe_dx    = fig_dx;
statusframe_dy    = 24;
statusframe_offsx = 1;
statusframe_offsy = 1;

statustext_dx    = statusframe_dx-6;
statustext_dy    = statusframe_dy-6;
statustext_offsx = statusframe_offsx+3;
statustext_offsy = statusframe_offsy+3;

donepb_dx    = 83;
donepb_dy    = pushbh;
donepb_offsx = fig_dx-donepb_dx-17;
donepb_offsy = statusframe_offsy+statusframe_dy+fromsf_y;

cancelpb_dx    = donepb_dx;
cancelpb_dy    = pushbh;
cancelpb_offsx = donepb_offsx;
cancelpb_offsy = donepb_offsy+donepb_dy+pbdy;

designpb_dx    = donepb_dx;
designpb_dy    = pushbh;
designpb_offsx = donepb_offsx;
designpb_offsy = cancelpb_offsy+cancelpb_dy+5*pbdy;

viewpb_dx    = donepb_dx;
viewpb_dy    = pushbh;
viewpb_offsx = donepb_offsx;
viewpb_offsy = designpb_offsy+designpb_dy+pbdy;

adjustpb_dx    = donepb_dx;
adjustpb_dy    = pushbh;
adjustpb_offsx = donepb_offsx;
adjustpb_offsy = viewpb_offsy+2*(viewpb_dy+pbdy);

adjustpbn_dx    = donepb_dx;
adjustpbn_dy    = pushbh;
adjustpbn_offsx = donepb_offsx;
adjustpbn_offsy = viewpb_offsy+(viewpb_dy+pbdy);

allpfreqpb_dx    = donepb_dx;
allpfreqpb_dy    = pushbh;
allpfreqpb_offsx = donepb_offsx;
allpfreqpb_offsy = adjustpb_offsy+adjustpb_dy+pbdy;

roundfpb_dx    = donepb_dx;
roundfpb_dy    = pushbh;
roundfpb_offsx = donepb_offsx;
roundfpb_offsy = viewpb_offsy+viewpb_dy+pbdy;

stsg1rb_dx    = 75;
stsg1rb_dy    = radiobh;
stsg1rb_offsx = 20;
stsg1rb_offsy = fig_dy-radiobh-fromtop;
stsg1rb_offsyorig = stsg1rb_offsy; stsg1rb_offsy = stsg1rb_offsy+15;

stsg2rb_dx    = stsg1rb_dx;
stsg2rb_dy    = radiobh;
stsg2rb_offsx = stsg1rb_offsx;
stsg2rb_offsy = stsg1rb_offsy-rbdy-radiobh;

stsg4rb_dx    = stsg1rb_dx;
stsg4rb_dy    = radiobh;
stsg4rb_offsx = stsg1rb_offsx;
stsg4rb_offsy = stsg2rb_offsy-rbdy-radiobh;

stsg3rb_dx    = stsg1rb_dx;
stsg3rb_dy    = radiobh;
stsg3rb_offsx = stsg1rb_offsx;
stsg3rb_offsy = stsg4rb_offsy-rbdy-radiobh;

startpop_dx    = 87;
startpop_dy    = popuph;
startpop_offsx = stsg1rb_offsx+80;
startpop_offsy = stsg1rb_offsy;

starttext_dx    = startpop_dx;
starttext_dy    = startpop_dy;
starttext_offsx = startpop_offsx;
starttext_offsy = startpop_offsy+startpop_dy;

iteredit_dx    = 60-5-1; %87
iteredit_dy    = popuph;
iteredit_offsx = stsg1rb_offsx+80+27+5;
iteredit_offsy = stsg1rb_offsy-startpop_dy-starttext_dy+11+1;

itertext_dx    = iteredit_dx-35+5;
itertext_dy    = iteredit_dy;
itertext_offsx = iteredit_offsx-25-5-2;
itertext_offsy = iteredit_offsy-4+1; %+stateedit_dy;

stateedit_dx    = 60-5-1; %87
stateedit_dy    = popuph;
stateedit_offsx = stsg1rb_offsx+80+27+5;
stateedit_offsy = stsg1rb_offsy-startpop_dy-starttext_dy-12+2;

statetext_dx    = stateedit_dx-35+5;
statetext_dy    = stateedit_dy;
statetext_offsx = stateedit_offsx-25-5-2;
statetext_offsy = stateedit_offsy-4+2; %+stateedit_dy;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frame_dy    = stsg1rb_offsyorig+stsg1rb_dy-donepb_offsy-ampheight;
mainframe_dx    = 325;
mainframe_dy    = 120;
mainframe_offsx = donepb_offsx-10-mainframe_dx;
mainframe_offsy = donepb_offsy+frame_dy+20;

freqframe_dx    = (mainframe_dx-10)/2;
freqframe_dy    = frame_dy;
freqframe_offsx = mainframe_offsx;
freqframe_offsy = donepb_offsy;

ampframe_dx    = freqframe_dx;
ampframe_dy    = freqframe_dy-rbshift;
ampframe_offsx = mainframe_offsx+ampframe_dx+10;
ampframe_offsy = freqframe_offsy+rbshift;

amphdtext_dx    = ampframe_dx-80;
amphdtext_dy    = texth;
amphdtext_offsx = ampframe_offsx+ampframe_dx/2-amphdtext_dx/2;
amphdtext_offsy = ampframe_offsy+ampframe_dy-amphdtext_dy/2;

ag1rb_dx    = ampframe_dx-20-75; %Constant amplitudes
ag1rb_dy    = radiobh;
ag1rb_offsx = ampframe_offsx+10;
ag1rb_offsy = ampframe_offsy+ampframe_dy-ag1rb_dy-15;

ag2rb_dx    = ag1rb_dx; %1/f
ag2rb_dy    = radiobh;
ag2rb_offsx = ag1rb_offsx;
ag2rb_offsy = ag1rb_offsy-rbdy-radiobh;

ag3rb_dx    = ag1rb_dx; %f
ag3rb_dy    = radiobh;
ag3rb_offsx = ag1rb_offsx;
ag3rb_offsy = ag2rb_offsy-rbdy-radiobh;

ag4rb_dx    = ag1rb_dx; %import amps
ag4rb_dy    = radiobh;
ag4rb_offsx = ag1rb_offsx;
ag4rb_offsy = ag3rb_offsy-rbdy-radiobh;

ag5rb_dx    = ag1rb_dx+50; %Matlab expression
ag5rb_dy    = radiobh;
ag5rb_offsx = ag1rb_offsx;
ag5rb_offsy = ag4rb_offsy-rbdy-radiobh;

ag7rb_dx    = ag1rb_dx; %optimize
ag7rb_dy    = radiobh;
ag7rb_offsx = ag1rb_offsx;
ag7rb_offsy = ag5rb_offsy-rbdy-radiobh;

ag6rb_dx    = ag1rb_dx+20; %follow FRF
ag6rb_dy    = radiobh;
ag6rb_offsx = ag1rb_offsx;
ag6rb_offsy = ag7rb_offsy-rbdy-radiobh;

freqhdtext_dx    = freqframe_dx-120;
freqhdtext_dy    = texth;
freqhdtext_offsx = freqframe_offsx+freqframe_dx/2-freqhdtext_dx/2;
freqhdtext_offsy = amphdtext_offsy;

fg1rb_dx    = ag1rb_dx+50;
fg1rb_dy    = radiobh;
fg1rb_offsx = freqframe_offsx+10;
fg1rb_offsy = ag1rb_offsy;

fg2rb_dx    = fg1rb_dx+10;
fg2rb_dy    = radiobh;
fg2rb_offsx = fg1rb_offsx;
fg2rb_offsy = fg1rb_offsy-rbdy-radiobh;

fg6rb_dx    = fg1rb_dx+32;
fg6rb_dy    = radiobh;
fg6rb_offsx = fg1rb_offsx;
fg6rb_offsy = fg2rb_offsy-rbdy-radiobh;

fg9rb_dx    = fg1rb_dx;
fg9rb_dy    = radiobh;
fg9rb_offsx = fg1rb_offsx;
fg9rb_offsy = fg6rb_offsy-rbdy-radiobh;

fg3rb_dx    = fg1rb_dx+32;
fg3rb_dy    = radiobh;
fg3rb_offsx = fg1rb_offsx;
fg3rb_offsy = fg9rb_offsy-rbdy-radiobh;

fg4rb_dx    = fg1rb_dx;
fg4rb_dy    = radiobh;
fg4rb_offsx = fg1rb_offsx;
fg4rb_offsy = fg3rb_offsy-rbdy-radiobh;

fg5rb_dx    = fg1rb_dx;
fg5rb_dy    = radiobh;
fg5rb_offsx = fg1rb_offsx;
fg5rb_offsy = fg4rb_offsy-rbdy-radiobh;


mainhdtext_dx    = 65;
mainhdtext_dy    = texth;
mainhdtext_offsx = mainframe_offsx+mainframe_dx/2-mainhdtext_dx/2;
mainhdtext_offsy = mainframe_offsy+mainframe_dy-mainhdtext_dy/2;

gentypetext_dx    = 100;
gentypetext_dy    = texth;
gentypetext_offsx = mainframe_offsx+10;
gentypetext_offsy = mainhdtext_offsy-tdy-texth;

genpop_dx    = gentypetext_dx;
genpop_dy    = popuph;
genpop_offsx = gentypetext_offsx;
genpop_offsy = gentypetext_offsy-tdy-popuph;

recfilttext_dx    = gentypetext_dx;
recfilttext_dy    = texth;
recfilttext_offsx = gentypetext_offsx;
recfilttext_offsy = genpop_offsy-popdy-recfilttext_dy;

recfiltrb1_dx    = 40;
recfiltrb1_dy    = radiobh;
recfiltrb1_offsx = gentypetext_offsx;
recfiltrb1_offsy = recfilttext_offsy-rbdy-recfiltrb1_dy;

recfiltrb2_dx    = recfiltrb1_dx;
recfiltrb2_dy    = radiobh;
recfiltrb2_offsx = recfiltrb1_offsx+recfiltrb1_dx+10;
recfiltrb2_offsy = recfiltrb1_offsy;

ncframe_dx    = 190;
ncframe_dy    = 80;
ncframe_offsx = mainframe_offsx+mainframe_dx-ncframe_dx-10;
ncframe_offsy = gentypetext_offsy+gentypetext_dy-ncframe_dy;

cftext_dx    = 100;
cftext_dy    = texth;
cftext_offsx = ncframe_offsx+10;
cftext_offsy = ncframe_offsy+10;

hztext_dx    = 26;
hztext_dy    = texth;
hztext_offsx = ncframe_offsx+ncframe_dx-hztext_dx-5;
hztext_offsy = cftext_offsy;

cfedit_dx    = 60;
cfedit_dy    = editbh;
cfedit_offsx = ncframe_offsx+ncframe_dx-hztext_dx+2-cfedit_dx;
cfedit_offsy = cftext_offsy;

nsstext_dx    = cftext_dx;
nsstext_dy    = 2*texth;
nsstext_offsx = cftext_offsx;
nsstext_offsy = cftext_offsy+texth+tdy;

ssedit_dx    = cfedit_dx;
ssedit_dy    = editbh;
ssedit_offsx = cfedit_offsx;
ssedit_offsy = nsstext_offsy+nsstext_dy-18;

fig1rb_dx    = 185;
fig1rb_dy    = freqframe_dy;
fig1rb_offsx = 10;
fig1rb_offsy = donepb_offsy;

parhdtext_dx    = 100;
parhdtext_dy    = texth;
parhdtext_offsx = fig1rb_offsx+fig1rb_dx/2-parhdtext_dx/2;
parhdtext_offsy = fig1rb_offsy+fig1rb_dy-parhdtext_dy/2;

fig2rb_dx    = 80;
fig2rb_dy    = texth;
fig2rb_offsx = fig1rb_offsx+5;
fig2rb_offsy = fig1rb_offsy+fig1rb_dy-fig2rb_dy-15;

fig3rb_dx    = fig2rb_dx;
fig3rb_dy    = texth;
fig3rb_offsx = fig2rb_offsx;
fig3rb_offsy = fig2rb_offsy-tdy-texth;

fig4rb_dx    = fig2rb_dx;
fig4rb_dy    = texth;
fig4rb_offsx = fig2rb_offsx;
fig4rb_offsy = fig3rb_offsy-tdy-texth;

fig4pm_dx    = fig4rb_dx-15;
fig4pm_dy    = fig4rb_dy-5;
fig4pm_offsx = fig4rb_offsx;
fig4pm_offsy = fig4rb_offsy+5;

fig22rb_dx    = 26;
fig22rb_dy    = texth;
fig22rb_offsx = fig1rb_offsx+fig1rb_dx-5-fig22rb_dx;
fig22rb_offsy = fig2rb_offsy;

fig5rb_dx    = 60;
fig5rb_dy    = editbh;
fig5rb_offsx = fig22rb_offsx-3-fig5rb_dx;
fig5rb_offsy = fig2rb_offsy;

fig23rb_dx    = fig22rb_dx;
fig23rb_dy    = texth;
fig23rb_offsx = fig22rb_offsx;
fig23rb_offsy = fig3rb_offsy;

fig6rb_dx    = fig5rb_dx;
fig6rb_dy    = editbh;
fig6rb_offsx = fig5rb_offsx;
fig6rb_offsy = fig3rb_offsy;

fig7rb_dx    = fig5rb_dx;
fig7rb_dy    = editbh;
fig7rb_offsx = fig5rb_offsx;
fig7rb_offsy = fig4rb_offsy;

fig28rb_dx    = fig22rb_dx;
fig28rb_dy    = texth;
fig28rb_offsx = fig22rb_offsx;
fig28rb_offsy = fig7rb_offsy;

fig8rb_dx    = fig2rb_dx;
fig8rb_dy    = texth;
fig8rb_offsx = fig2rb_offsx;
fig8rb_offsy = fig7rb_offsy-tdy-texth;

fig9rb_dx    = fig5rb_dx;
fig9rb_dy    = radiobh;
fig9rb_offsx = fig5rb_offsx;
fig9rb_offsy = fig8rb_offsy;

fig12rb_dx    = fig2rb_dx;
fig12rb_dy    = texth;
fig12rb_offsx = fig2rb_offsx;
fig12rb_offsy = fig9rb_offsy-tdy-texth;

fig11rb_dx    = fig5rb_dx;
fig11rb_dy    = radiobh;
fig11rb_offsx = fig5rb_offsx;
fig11rb_offsy = fig12rb_offsy-tdy-texth;

fig10rb_dx    = fig2rb_dx;
fig10rb_dy    = texth;
fig10rb_offsx = fig2rb_offsx;
fig10rb_offsy = fig11rb_offsy;

fig13rb_dx    = fig5rb_dx;
fig13rb_dy    = radiobh;
fig13rb_offsx = fig5rb_offsx;
fig13rb_offsy = fig10rb_offsy+tdy+texth;

fig14rb_dx    = fig2rb_dx;
fig14rb_dy    = texth;
fig14rb_offsx = fig2rb_offsx;
fig14rb_offsy = fig13rb_offsy-tdy-texth-tdy-texth;

fig15rb_dx    = fig5rb_dx;
fig15rb_dy    = radiobh;
fig15rb_offsx = fig5rb_offsx;
fig15rb_offsy = fig14rb_offsy;

fig24rb_dx    = fig22rb_dx;
fig24rb_dy    = texth;
fig24rb_offsx = fig22rb_offsx;
fig24rb_offsy = fig10rb_offsy;

fig25rb_dx    = fig22rb_dx;
fig25rb_dy    = texth;
fig25rb_offsx = fig22rb_offsx;
fig25rb_offsy = fig14rb_offsy;

%Bit freq
fig16rb_dx    = fig2rb_dx; 
fig16rb_dy    = texth;
fig16rb_offsx = fig2rb_offsx;
fig16rb_offsy = fig15rb_offsy-tdy-texth;

fig17rb_dx    = fig5rb_dx;
fig17rb_dy    = editbh;
fig17rb_offsx = fig5rb_offsx;
fig17rb_offsy = fig16rb_offsy;

fig26rb_dx    = fig22rb_dx;
fig26rb_dy    = texth;
fig26rb_offsx = fig22rb_offsx;
fig26rb_offsy = fig16rb_offsy;

fig27rb_dx    = fig22rb_dx;
fig27rb_dy    = texth;
fig27rb_offsx = fig22rb_offsx;
fig27rb_offsy = fig12rb_offsy;

%log2(Np+1)
fig18rb_dx    = fig2rb_dx;
fig18rb_dy    = texth;
fig18rb_offsx = fig2rb_offsx;
fig18rb_offsy = fig17rb_offsy-tdy-texth;

fig19rb_dx    = fig5rb_dx;
fig19rb_dy    = editbh;
fig19rb_offsx = fig5rb_offsx;
fig19rb_offsy = fig18rb_offsy;

fig20rb_dx    = fig2rb_dx;
fig20rb_dy    = texth;
fig20rb_offsx = fig2rb_offsx;
fig20rb_offsy = fig19rb_offsy-tdy-texth;

fig21rb_dx    = fig5rb_dx;
fig21rb_dy    = editbh;
fig21rb_offsx = fig5rb_offsx;
fig21rb_offsy = fig20rb_offsy;

%fig22rb_dx    = fig1rb_dx-10;
%fig22rb_dy    = texth;
%fig22rb_offsx = fig2rb_offsx;
%fig22rb_offsy = fig21rb_offsy-tdy-texth;

%fig23rb_dx    = fig1rb_dx-10;
%fig23rb_dy    = texth;
%fig23rb_offsx = fig2rb_offsx;
%fig23rb_offsy = fig22rb_offsy-tdy-texth;

fig_dy    =fig_dy+10; %%% bypass 

%%%%%%%%%%%%%%%%% 11-Mar-1998, IK

ag21edit_dx    = cfedit_dx; %Aeff edit
ag21edit_dy    = editbh;
ag21edit_offsx = ampframe_offsx+ampframe_dx-ag21edit_dx-5;
ag21edit_offsy = ampframe_offsy+10+rbdy+18-rbshift;

ag20text_dx    = 45; %RMS text
ag20text_dy    = texth;
ag20text_offsx = ag21edit_offsx-ag20text_dx; %ag7rb_offsx+10;
ag20text_offsy = ag21edit_offsy;

repedit_dx    = 30; %Rep = edit
repedit_dy    = ag21edit_dy;
repedit_offsx = ampframe_offsx+ampframe_dx/2-repedit_dx-5;
repedit_offsy = donepb_offsy; %ag21edit_offsy-rbshift;

reptext_dx    = ag20text_dx; %Rep =
reptext_dy    = ag20text_dy;
reptext_offsx = repedit_offsx-reptext_dx-3; %ag20text_offsx-ampframe_dx/2+10;
reptext_offsy = repedit_offsy;

expedit_dx    = repedit_dx; %Exp = edit
expedit_dy    = ag21edit_dy;
expedit_offsx = ampframe_offsx+ampframe_dx-expedit_dx-5;
expedit_offsy = donepb_offsy; %ag21edit_offsy-rbshift;

exptext_dx    = ag20text_dx; %Exp =
exptext_dy    = ag20text_dy;
exptext_offsx = expedit_offsx-exptext_dx-3; %ag20text_offsx;
exptext_offsy = expedit_offsy;

cycledit_dx    = repedit_dx; %iter = edit
cycledit_dy    = editbh;
cycledit_offsx = ampframe_offsx+ampframe_dx-cycledit_dx-5;
cycledit_offsy = ag7rb_offsy;

cycltext_dx    = ag20text_dx+5; %iter = text
cycltext_dy    = texth;
cycltext_offsx = cycledit_offsx-cycltext_dx-3;
cycltext_offsy = cycledit_offsy;

rbframe_dx    = fig1rb_dx;
rbframe_dy    = mainframe_dy;
rbframe_offsx = fig1rb_offsx;
rbframe_offsy = mainframe_offsy;

rbhdtext_dx    = 100;
rbhdtext_dy    = texth;
rbhdtext_offsx = rbframe_offsx+rbframe_dx/2-rbhdtext_dx/2;
rbhdtext_offsy = mainhdtext_offsy;
