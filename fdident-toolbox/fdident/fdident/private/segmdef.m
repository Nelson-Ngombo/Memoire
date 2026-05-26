scr=get(0,'screensize');

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
editbh     =  19;
tdy        =   6;
pbdy       =   6;
rbdy       =   6;
ebdy       =   6;
 

fig_dx    = 400;
fig_dy    = 245;
fig_offsx = 50;
fig_offsy = scr(4)-360;

statusframe_dx    = fig_dx;
statusframe_dy    = 0;
statusframe_offsx = 1;
statusframe_offsy = 1;

%statustext_dx    = statusframe_dx-6;
%statustext_dy    = statusframe_dy-6;
%statustext_offsx = statusframe_offsx+3;
%statustext_offsy = statusframe_offsy+3;

frame1_dx    = 250;
frame1_dy    = 200;
frame1_offsx =  20;
frame1_offsy =  statusframe_dy+20;

text8_dx    = 20;
splitdown=8;
splitup=20;

text9_dx    = 120; %Segments:/2
text9_dy    = textbh;
text9_offsx = frame1_offsx+15;
text9_offsy = frame1_offsy+10-splitdown;

text10_dx    = 46; %Segments:/1
text10_dy    = textbh;
text10_offsx = frame1_offsx+frame1_dx-15-text8_dx-5-50;
text10_offsy = text9_offsy;

text8_dx    = text8_dx; %Overlap: %
text8_dy    = textbh;
text8_offsx = frame1_offsx+frame1_dx-15-text8_dx;
text8_offsy = text9_offsy+text9_dy+ebdy-4;

edit2_dx    = 50; %Overlap:
edit2_dy    = editbh;
edit2_offsx = text10_offsx;
edit2_offsy = text8_offsy+3;

text7_dx    = text9_dx; %Overlap:
text7_dy    = textbh;
text7_offsx = text9_offsx;
text7_offsy = text8_offsy;

edit1_dx    = edit2_dx; %Segment length
edit1_dy    = editbh;
edit1_offsx = text10_offsx;
edit1_offsy = edit2_offsy+18+ebdy-3;

edit3_dx    = edit2_dx;
edit3_dy    = editbh;
edit3_offsx = text10_offsx;
edit3_offsy = edit1_offsy+18+ebdy+splitup;

edit4_dx    = edit2_dx; %Np:
edit4_dy    = editbh;
edit4_offsx = text10_offsx;
edit4_offsy = edit3_offsy+18+ebdy-3;

edit5_dx    = edit2_dx; %# of periods
edit5_dy    = editbh;
edit5_offsx = text10_offsx;
edit5_offsy = edit4_offsy+18+ebdy-3;

text6_dx    = text9_dx; %Segment length:
text6_dy    = textbh;
text6_offsx = text9_offsx;
text6_offsy = edit1_offsy-3;

text5_dx    = 220; %# of periods
text5_dy    = textbh;
text5_offsx = text9_offsx;
text5_offsy = text6_offsy+18+ebdy+splitup-3;

text4_dx    = text5_dx; %Np:
text4_dy    = textbh;
text4_offsx = text9_offsx;
text4_offsy = text5_offsy+text5_dy+tdy-3;

text3_dx    = text5_dx; %Tp:
text3_dy    = textbh;
text3_offsx = text9_offsx;
text3_offsy = text4_offsy+text4_dy+tdy-3;

text2_dx    = text5_dx; %N = 
text2_dy    = textbh;
text2_offsx = text9_offsx;
text2_offsy = text3_offsy+text3_dy+tdy-3;

text1_dx    = text5_dx; %Tr=
text1_dy    = textbh;
text1_offsx = text9_offsx;
text1_offsy = text2_offsy+text2_dy+tdy-3;

text12_dx    = text8_dx;
text12_dy    = textbh;
text12_offsx = frame1_offsx+frame1_dx-15-text8_dx;
text12_offsy = text3_offsy+3;

donepb_dx    = 80;
donepb_dy    = pushbh;
donepb_offsx = fig_dx-donepb_dx-20;
donepb_offsy = statusframe_dy+20;

cancelpb_dx    = donepb_dx;
cancelpb_dy    = pushbh;
cancelpb_offsx = donepb_offsx;
cancelpb_offsy = donepb_offsy+donepb_dy+pbdy;

checkpb_dx    = donepb_dx;
checkpb_dy    = pushbh;
checkpb_offsx = donepb_offsx;
checkpb_offsy = edit4_offsy;

applypb_dx    = donepb_dx;
applypb_dy    = pushbh;
applypb_offsx = donepb_offsx;
applypb_offsy = cancelpb_offsy+cancelpb_dy+pbdy;

