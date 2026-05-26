function dat = tidin(varargin)
%TIDIN Creation function for the TIDDATA data object with only input.
%
%       Examples: tidin(tiddata,u,Ts);
%                 tidin(tiddata,u,Ts,iname,iunit);
%
%       See also: TIDDATA, TIDOUT

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-99
%       All rights reserved.
%       $Revision: $
%       Last modified: 29-Aug-1998

Ts=[]; u=[]; y=[]; oname=''; iname=''; ounit=''; iunit='';
ni=nargin;
if ni>5, error('Wrong number of input arguments'), end

%Creator function: read inputs
if ni>=2, u=varargin{2}; end
if ni>=3, Ts=varargin{3}; end
if ni>=4, iname=varargin{4}; end
if ni>=5, iunit=varargin{5}; end
dat=tiddata(y,u,Ts,oname,iname,ounit,iunit);
%
%end ../@tiddata/tidin.m
