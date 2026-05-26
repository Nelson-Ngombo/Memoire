figure_col = [192 192 192]/255;
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

axes_font_name = 'Helvetica';
axes_font_size = 12;

texth      =  18;
edith      =  20;
pushbh     =  20;
radiobh    =  18;
checkbh    =  18;
poph       =  18;
tdy        =   6;
pbdy       =   6;
rbdy       =   6;
cbdy       =   6;
 

fig_dx    = 530;
fig_dy    = 110;
fig_offsx = 100;
fig_offsy = 200;

donepb_dx    = 80;
donepb_dy    = pushbh;
donepb_offsx = fig_dx-20-donepb_dx;
donepb_offsy = 10;

cancelpb_dx    = donepb_dx;
cancelpb_dy    = pushbh;
cancelpb_offsx = donepb_offsx-cancelpb_dx-10;
cancelpb_offsy = donepb_offsy;

edit_dx    = fig_dx-20;
edit_dy    = edith;
edit_offsx = 10;
edit_offsy = cancelpb_offsy+pushbh+30;

text_dx    = edit_dx;
text_dy    = texth;
text_offsx = 10;
text_offsy = edit_offsy+edit_dy+5;

errtext_dx    = cancelpb_offsx-20;
errtext_dy    = edit_offsy-10;
errtext_offsx = 10;
errtext_offsy = 5;

