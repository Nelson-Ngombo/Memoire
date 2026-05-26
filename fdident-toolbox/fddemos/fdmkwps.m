function h=fdmkwps(title,title2)
%FDMKWPS  Open working window for playshow in fdident

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 17-Jun-2000, I. Kollar

if nargin<1, error('Not enough input arguments'), end
if nargin<2, title2=''; end
h=findall(0,'name',title);
if isempty(h)&~isempty(title2), h=findall(0,'name',title2); end
if isempty(h), h=figure; end
set(h,'name',title,'numbertitle','off')
figure(h), clf
iterctrl('initialize',h); %iterctrl will not duplicate
%
%End of file