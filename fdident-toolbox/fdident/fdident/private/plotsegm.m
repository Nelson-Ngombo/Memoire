function plotsegm(Tr,segmno,ovl,ha,pos,dpos,dv)
%PLOTSEGM Plot segment illustration to window with existing time plot
%
%       Input arguments:
%       Tr = segment length in s
%       segmno = number of segments, default: 1
%       ovl = overlap (under 1), default: 0
%       ha = handle of axis, default: gca
%       pos = vertical position, default: center of axis
%       dpos = vertical difference between overlapped segments, percent of ylim
%       dv = vertical bar from segment line, percent of ylim
%
%       Example: clf, plotsegm(0.1,9,0.3)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-8
%       All rights reserved.
%       $Revision: $
%       Last modified: 02-Oct-1998

if nargin<4, ha=[]; end, if isempty(ha), ha=gca; end
if nargin<3, ovl=[]; end, if isempty(ovl), ovl=0; end 
if nargin<2, segmno=[]; end, if isempty(segmno), segmno=1; end 
%ax=axis;
ax=[get(ha,'xlim'),get(ha,'ylim')];
if ovl>=1, error('overlap>=1'), end
if nargin<6, dpos=[]; end
if (ovl>0)&isempty(dpos), dpos=0.05; elseif ovl<=0, dpos=0; end
if nargin<5, pos=[]; end, if isempty(pos), pos=(ax(4)+ax(3))/2; end
if nargin<7, dv=[]; end, if isempty(dv), dv=0.035; end
%
if segmno*Tr*(1-ovl)+Tr*ovl>(1+100*eps)*(ax(2)-ax(1))
  %error('Segment plot length is larger than axis width') 
end
if Tr<=0, error('Tr is not positive'), end
if (pos>ax(4))|(pos<ax(3)), error('Position out of range'), end
c='m'; lw=2;
npl=get(ha,'nextplot');
if strcmp(npl,'replace'), delete(get(ha,'children')), end
%hold on
set(ha,'nextplot','add')
for i=1:segmno
  lpos(1)=(i-1)*Tr*(1-ovl);
  lpos(2)=pos-rem(i-1,ceil(1/(1-ovl)))*dpos*diff(ax(3:4));
  rpos(1)=lpos(1)+Tr;
  rpos(2)=pos-rem(i-1,ceil(1/(1-ovl)))*dpos*diff(ax(3:4));
  plot([lpos(1),rpos(1)],[lpos(2),rpos(2)],c,'linewidth',lw,'parent',ha)
  plot(lpos(1)+[0,0],lpos(2)+[-dv,dv]*diff(ax(3:4)),c,...
     'linewidth',lw,'parent',ha)
  plot(rpos(1)+[0,0],rpos(2)+[-dv,dv]*diff(ax(3:4)),c,...
     'linewidth',lw,'parent',ha)
end
%
%hold off, axis(ax)
set(ha,'nextplot',npl);
%set(ha,'xlim',ax(1:2)), set(ha,'ylim',ax(3:4)) 
%
%End of plotsegm
