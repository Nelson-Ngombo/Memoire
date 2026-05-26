function [nfilename,fnamsh,ext]=fnamanal(filename,stext)
%FNAMANAL Analyze filename (name + extension), extend filename by extension.
%
%       [nfilename,fnamsh,ext]=FNAMANAL(filename,stext)
%
%       filename is splitted to fnamsh + ext, the name of the file without
%       extension, and the extension (after the period). If filename
%       contains no extension, the standard extension (stext) is appended, and
%       nfilename is returned with this, otherwise it is identical with
%       filename. The extensions ext, stext do not contain the period.
%
%       Output arguments:
%       nfilename = file name with extension
%       fnamsh = name without extension
%       ext = extension
%
%       Input arguments:
%       filename = name to be analysed
%       stext = standard extension (optional)
%
%       Usage: [nfilename,fnamsh,ext]=fnamanal(filename,stext);
%       Example: fnam='inpchan'; [fnam,fnshort,ext]=fnamanal(fnam,'mat');

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Oct-1998

if nargin==1, stext=setstr([]); end
point=find(filename=='.');
if isempty(point),
  fnamsh=filename;
  if ~isempty(stext)
    nfilename=[filename,'.',stext];
  else
    nfilename=filename;
  end
  ext=stext;
else
  fnamsh=filename(1:point(1)-1);
  nfilename=filename;
  ext=filename([point(1)+1:length(filename)]);
end
if length(fnamsh)==0
  error(['File name without extension is empty in ''',filename,''''])
end
%%%%%%%%%%%%%%%%%%%%%%%% end of fnamanal %%%%%%%%%%%%%%%%%%%%%%%%
