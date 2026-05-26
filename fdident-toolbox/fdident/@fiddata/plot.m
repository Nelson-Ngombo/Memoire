function handles=plot(varargin)
%PLOT Plot fiddata object (maybe with fidmodel object) in a similar way as plot
%
%       A handle of an axes (or a column vector of two handles of two axes)
%          can be passed at the end preceded by argument 'parent', and the
%          horizontal scaling ('lin' or 'log') after 'xscale'
%       A plot modifier argument (a single character) can take the following
%       values:
%       '+' means that only the amplitudes are plotted,
%       '-' that only the phases.
%       '=' allows to show both the amplitude and the phase.
%       '*' shows the FRF and the variances (if any).
%       '@' shows the FRF and the var + nonlinear errors (if any) for non-av data.
%       '2' shows the output/input and the var + nonlinear errors (if any) for non-av data.
%       '1' shows the output and the var + nonlinear errors (if any) for non-av data.
%       'w' shows the 'nonlinear variances', used in estimation
%       'v' shows the FRF and the variances.
%       '&' lets an f-U, f-Y pair plotted.
%       '#' allows to show both input and output with variances.
%       'N' lets the noise-to-signal ratio plotted along with the frf.
%       'n' lets the noise-to-signal ratio plotted along with the f-U, f-Y pairs.
%       Default: '*'
%       objtype can be 'linear','nonlinear','interpnonlinear'
%
%       Usage:
%         h=plot(fdata,model,plotmod,'objtype',objtype,'parent',hax,'xscale',xsc)
%       Examples:
%         plot(fdata)
%         h=plot(fdata,model,'parent',hax)
%         plot(fdata,'=')

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1997-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Apr-2004

no=nargout; ni=nargin;
model=[]; msc='';
for ii=length(varargin):-1:1
  if isa(varargin{ii},'fidmodel')
    model=varargin{ii};
    varargin(ii)=[];
  elseif isstr(varargin{ii})&(length(varargin{ii})==1)
    msc=varargin{ii};
  end
end
if isempty(model)
  model=fidmodel;
  %Plot with '&' if one channel is empty
  Fdat=varargin{1};
  u=get(Fdat,'input');
  y=get(Fdat,'output');
  if isempty(msc)&(isempty(u)|isempty(y))
    varargin=[varargin,{'&'}];
  end
end
h=plot(model,varargin{:});
if no, handles=h; end

%End of @fiddata/plot