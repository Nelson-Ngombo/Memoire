function tdatm=uminus(tdat)
%UMINUS  Unitary minus (-1*object.data)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 14-Apr-2000

chn=get(tdat,'chnumber');
term={};
for ii=1:chn
  term=[term;{-1}];
end
tdatm=term*tdat;

%End of @tiddata/uminus