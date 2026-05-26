%FDSIMDEF Settings for fdmeasw

%Last modified: 27-Mar-1999, IK

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
radiobh    =  18;
popuph          =  18;
checkbh    =  18;
editbh     =  19;
tdy        =   6;
pbdy       =   6;
rbdy       =   6;
cbdy       =   6;
popdy      =  14; 

ymod=30;
fig_dx    = 500;
fig_dy    = 280+ymod;
fig_offsx = 10;
fig_offsy = 20+20;


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
donepb_offsx = fig_dx-donepb_dx-20;
donepb_offsy = statusframe_offsy+statusframe_dy+20;

cancelpb_dx    = donepb_dx;
cancelpb_dy    = pushbh;
cancelpb_offsx = donepb_offsx;
cancelpb_offsy = donepb_offsy+donepb_dy+pbdy;

fdtakepb_dx    = donepb_dx;
fdtakepb_dy    = pushbh;
fdtakepb_offsx = cancelpb_offsx;
fdtakepb_offsy = cancelpb_offsy+donepb_dy+pbdy;

gotovipb_dx    = donepb_dx;
gotovipb_dy    = pushbh;
gotovipb_offsx = cancelpb_offsx;
gotovipb_offsy = cancelpb_offsy+donepb_dy+pbdy+donepb_dy+pbdy;

viframe_dx    = (fig_dx-50)/2;
viframe_dy    = (fig_dy-cancelpb_offsy-cancelpb_dy-60)-ymod;
viframe_offsx = 20;
viframe_offsy = cancelpb_offsy+cancelpb_dy+40+ymod;

ipsframe_dx    = viframe_dx;
ipsframe_dy    = viframe_dy;
ipsframe_offsx = fig_dx-viframe_dx-20;
ipsframe_offsy = viframe_offsy;

exftext_dx    = 90;
exftext_dy    = textbh;
exftext_offsx = ipsframe_offsx+ipsframe_dx/2-exftext_dx/2;
exftext_offsy = ipsframe_offsy+ipsframe_dy-exftext_dy/2;

var1rb_dx    = ipsframe_dx-20;
var1rb_dy    = textbh;
var1rb_offsx = ipsframe_offsx+10;
var1rb_offsy = ipsframe_offsy+ipsframe_dy-var1rb_dy-15;

dbintext_dx    = 20;
dbintext_dy    = textbh;
dbintext_offsx = ipsframe_offsx+ipsframe_dx-dbintext_dx-5;
dbintext_offsy = var1rb_offsy;

dbouttext_dx    = dbintext_dx;
dbouttext_dy    = textbh;
dbouttext_offsx = dbintext_offsx;
dbouttext_offsy = dbintext_offsy-rbdy-radiobh;

inedit_dx    = 40;
inedit_dy    = editbh;
inedit_offsx = dbintext_offsx-inedit_dx-5;
inedit_offsy = var1rb_offsy;

outedit_dx    = inedit_dx;
outedit_dy    = editbh;
outedit_offsx = inedit_offsx;
outedit_offsy = dbouttext_offsy;

intext_dx    = 40;
intext_dy    = textbh;
intext_offsx = inedit_offsx-intext_dx-10;
intext_offsy = var1rb_offsy;

outtext_dx    = intext_dx;
outtext_dy    = textbh;
outtext_offsx = intext_offsx;
outtext_offsy = dbouttext_offsy;

var2rb_dx    = var1rb_dx;
var2rb_dy    = textbh;
var2rb_offsx = var1rb_offsx;
var2rb_offsy = var1rb_offsy-rbdy-textbh; 

var3rb_dx    = var2rb_dx;
var3rb_dy    = textbh;
var3rb_offsx = var1rb_offsx;
var3rb_offsy = var2rb_offsy-rbdy-textbh;

var4rb_dx    = var2rb_dx; 
var4rb_dy    = radiobh;
var4rb_offsx = var1rb_offsx;
var4rb_offsy = var3rb_offsy-rbdy-radiobh;

muledit_dx    = inedit_dx+20;
muledit_dy    = editbh;
muledit_offsx = inedit_offsx-20;
muledit_offsy = var3rb_offsy;

multext_dx    = 10;
multext_dy    = textbh;
multext_offsx = muledit_offsx-multext_dx-5;
multext_offsy = muledit_offsy;

alltext_dx    = 2*inedit_dx;
alltext_dy    = textbh;
alltext_offsx = multext_offsx;
alltext_offsy = multext_offsy+multext_dy;

vihdtext_dx    = 55;
vihdtext_dy    = textbh;
vihdtext_offsx = viframe_offsx+viframe_dx/2-vihdtext_dx/2;
vihdtext_offsy = exftext_offsy;

hwpop_dx    = viframe_dx-40; 
hwpop_dy    = radiobh; 
hwpop_offsx = viframe_offsx+10; 
hwpop_offsy = var1rb_offsy+rbdy+radiobh-radiobh; 

vipop_dx    = hwpop_dx;
vipop_dy    = radiobh;
vipop_offsx = hwpop_offsx;
vipop_offsy = hwpop_offsy-radiobh-rbdy; 

viinfo_dx    = donepb_dx;
viinfo_dy    = radiobh;
viinfo_offsx = hwpop_offsx;
viinfo_offsy = vipop_offsy-2*radiobh-rbdy;

netext_dx    = 120;
netext_dy    = textbh;
netext_offsx = 20;
netext_offsy = donepb_offsy;

needit_dx    = donepb_dx;
needit_dy    = editbh;
needit_offsx = netext_offsx+netext_dx;
needit_offsy = netext_offsy;

retext_dx    = 120;
retext_dy    = textbh;
retext_offsx = 20;
retext_offsy = cancelpb_offsy;

reedit_dx    = donepb_dx;
reedit_dy    = editbh;
reedit_offsx = retext_offsx+retext_dx;
reedit_offsy = retext_offsy;

tdtext_dx    = 120; 
tdtext_dy    = textbh;
tdtext_offsx = 20;
%tdtext_offsy = gotovipb_offsy;
tdtext_offsy = cancelpb_offsy+2*(donepb_dy+pbdy);

tdedit_dx    = needit_dx; 
tdedit_dy    = editbh;
tdedit_offsx = tdtext_offsx+tdtext_dx;
tdedit_offsy = tdtext_offsy;

tdtext2_dx    = 40; 
tdtext2_dy    = textbh;
tdtext2_offsx = tdedit_offsx+tdedit_dx+5;
tdtext2_offsy = tdtext_offsy;

ptpop_dx     = tdedit_dx;
ptpop_dy     = pushbh;
ptpop_offsx  = tdedit_offsx;
ptpop_offsy  = cancelpb_offsy+donepb_dy+pbdy;

pttext_dx    = 120;
pttext_dy    = textbh;
pttext_offsx = 20;
pttext_offsy = ptpop_offsy;

calpop_dx     = 1.3*tdedit_dx;
calpop_dx     = donepb_dx+10;
calpop_dy     = pushbh;
calpop_offsx  = needit_offsx+needit_dx+40;
calpop_offsy  = donepb_offsy;

calpb_dx     = calpop_dx;
calpb_dy     = pushbh;
calpb_offsx  = calpop_offsx;
calpb_offsy  = calpop_offsy+donepb_dy+pbdy;
