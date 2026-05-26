function dat = tidout(varargin)
%TIDOUT Creation function for the TIDDATA data object with only output.
%
%       Examples: tidout(tiddata,y,Ts);
%                 tidinp(tiddata,y,Ts,oname,ounit);
%
%       See also: TIDDATA, TIDIN

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 28-Aug-1998

Ts=[]; u=[]; y=[]; oname=''; iname=''; ounit=''; iunit='';
ni=nargin;
if ni>5, error('Wrong number of input arguments'), end

%Creator function: read inputs
if ni>=2, y=varargin{2}; end
if ni>=3, Ts=varargin{3}; end
if ni>=4, oname=varargin{4}; end
if ni>=5, ounit=varargin{5}; end
dat=tiddata(y,u,Ts,oname,iname,ounit,iunit);
%
%end ../@tiddata/tidout.m
