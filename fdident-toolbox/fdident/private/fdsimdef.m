%FDSIMDEF Settings for fdsimul

%Last modified: 08-May-1998, IK

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

fdsimulpb_dx    = donepb_dx;
fdsimulpb_dy    = pushbh;
%fdsimulpb_offsx = donepb_offsx-fdsimulpb_dx-50;
fdsimulpb_offsx = cancelpb_offsx;
fdsimulpb_offsy = cancelpb_offsy+donepb_dy+pbdy;

modelframe_dx    = (fig_dx-50)/2;
modelframe_dy    = (fig_dy-cancelpb_offsy-cancelpb_dy-60)-ymod;
modelframe_offsx = 20;
modelframe_offsy = cancelpb_offsy+cancelpb_dy+40+ymod;

varframe_dx    = modelframe_dx;
varframe_dy    = modelframe_dy;
varframe_offsx = fig_dx-modelframe_dx-20;
varframe_offsy = modelframe_offsy;

varhdtext_dx    = 70;
varhdtext_dy    = textbh;
varhdtext_offsx = varframe_offsx+varframe_dx/2-varhdtext_dx/2;
varhdtext_offsy = varframe_offsy+varframe_dy-varhdtext_dy/2;

var1rb_dx    = 80;
var1rb_dy    = radiobh;
var1rb_offsx = varframe_offsx+10;
var1rb_offsy = varframe_offsy+varframe_dy-var1rb_dy-15;

dbintext_dx    = 20;
dbintext_dy    = textbh;
dbintext_offsx = varframe_offsx+varframe_dx-dbintext_dx-5;
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

var2rb_dx    = (varframe_dx-40)*0.6;
var2rb_dy    = radiobh;
var2rb_offsx = var1rb_offsx;
var2rb_offsy = var1rb_offsy-2*rbdy-2*radiobh+5; 

var3rb_dx    = var2rb_dx;
var3rb_dy    = radiobh;
var3rb_offsx = var1rb_offsx;
var3rb_offsy = var2rb_offsy-rbdy-radiobh;

var4rb_dx    = var2rb_dx; 
var4rb_dy    = radiobh;
var4rb_offsx = var1rb_offsx;
var4rb_offsy = var3rb_offsy-rbdy-radiobh;

muledit_dx    = inedit_dx+20;
muledit_dy    = editbh;
muledit_offsx = inedit_offsx-20;
muledit_offsy = var3rb_offsy;

multext_dx    = 10;
multext_dy    = textbh-7;
multext_offsx = muledit_offsx-multext_dx-2;
multext_offsy = muledit_offsy+4;

alltext_dx    = 2*inedit_dx;
alltext_dy    = textbh;
alltext_offsx = multext_offsx;
alltext_offsy = multext_offsy+multext_dy;

savetext_dx    = var2rb_dx; 
savetext_dy    = radiobh;
savetext_offsx = muledit_offsx-30;
savetext_offsy = muledit_offsy-radiobh-8;

modelhdtext_dx    = 55;
modelhdtext_dy    = textbh;
modelhdtext_offsx = modelframe_offsx+modelframe_dx/2-modelhdtext_dx/2;
modelhdtext_offsy = varhdtext_offsy;

mg5rb_dx    = var2rb_dx; 
mg5rb_dy    = radiobh; 
mg5rb_offsx = modelframe_offsx+10; 
mg5rb_offsy = var1rb_offsy+rbdy+radiobh-radiobh; 

mg1rb_dx    = var2rb_dx+20;
mg1rb_dy    = radiobh;
mg1rb_offsx = modelframe_offsx+10;
mg1rb_offsy = var1rb_offsy-radiobh; 

mg2rb_dx    = mg1rb_dx;
mg2rb_dy    = radiobh;
mg2rb_offsx = mg1rb_offsx;
mg2rb_offsy = mg1rb_offsy-rbdy-radiobh;

mg3rb_dx    = mg1rb_dx;
mg3rb_dy    = radiobh;
mg3rb_offsx = mg1rb_offsx;
mg3rb_offsy = mg2rb_offsy-rbdy-radiobh;

mg4rb_dx    = mg1rb_dx;
mg4rb_dy    = radiobh;
mg4rb_offsx = mg1rb_offsx;
mg4rb_offsy = mg3rb_offsy-rbdy-radiobh;


hlp1pb_dx    = 50;
hlp1pb_dy    = radiobh;
hlp1pb_offsx = modelframe_offsx+modelframe_dx-55;
hlp1pb_offsy = mg4rb_offsy; 

hlp2pb_dx    = hlp1pb_dx;
hlp2pb_dy    = hlp1pb_dy;
hlp2pb_offsx = hlp1pb_offsx;
hlp2pb_offsy = hlp1pb_offsy+rbdy+radiobh; 

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
%tdtext_offsy = fdsimulpb_offsy;
tdtext_offsy = fdsimulpb_offsy+donepb_dy+pbdy;

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
ptpop_offsy  = fdsimulpb_offsy;

pttext_dx    = 120;
pttext_dy    = textbh;
pttext_offsx = 20;
pttext_offsy = ptpop_offsy;

