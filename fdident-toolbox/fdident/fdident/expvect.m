function expvect(file,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,digitnum)
%EXPVECT Export vectors to flat ASCII file for external graphing purposes.
%
%       EXPVECT(file,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,digitnum)
%
%       Prepare a ASCII file for graphing programs.
%       The file will be created in the active subdirectory or folder.
%       Format: digitnum digits + exponent. If digitnum is not given,
%       the default value is 7.
%       Between columns there will be tab characters.
%       The last character in the file is an <end of line> after the last
%       number.
%
%       Input arguments:
%       file: the name of the file (string)
%       v1...v12: vectors to be sent
%           At least 1 vector must be given, the minimum length is 2.
%           The vectors must be of the same length.
%       digitnum (optional): number of digits (1<=digitnum<=16)
%
%       Usage: expvect(file,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,digitnum)
%       Examples:
%         t=[1:100]; x=100*ones(100,2)+rand(100,2)+j*rand(100,2);
%         expvect('data.txt',t,real(x(:,2)),imag(x(:,2)),8)
%
%       See also: SAVE.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 10-Dec-2000

maxnumbervect=12;
if (nargin<2)
  error('Insufficient number of arguments')
end
%
[one,flen]=size(file);
if one~=1,
  error('Improper filename')
end
%
if exist(file)==2,
  delete(file)
  if exist(file)==2, error(['Cannot delete existing file ''',...
       file,'''']), end
end
%
vsize=size(v1);
if min(vsize)~=1
  error('v1 must be a vector')
end
if length(v1)<2
  error('The length of the vectors must be at least 2')
end
if nargin==(maxnumbervect+2)
  vectnum=nargin-2;
elseif (eval(['length(v',int2str(nargin-1),')']))==1
  eval(['digitnum=v',int2str(nargin-1),';'])
  vectnum=nargin-2;
else
  vectnum=nargin-1;
  digitnum=7;
end
if vectnum>maxnumbervect
  error(['Maximum number of input vectors (',...
    int2str(maxnumbervect),') is exceeded'])
end
if length(digitnum)>1
  error('digitnum must be scalar')
end
if (digitnum<1)|(digitnum>16)
  error('Number of digits incorrect')
end
widthvect=[];
lengthvectdiff=[];
complexelement=[];
infNaNelement=[];
for i=1:vectnum
  eval(['widthvect=[widthvect;min(size(v',int2str(i),'))];'])
  eval(['lengthvectdiff=[lengthvectdiff;length(v',int2str(i),')-length(v1)];'])
  eval(['complexelement=[complexelement;',...
         'any(any(imag(v',int2str(i),'))'')];'])
  eval(['infNaNelement=[infNaNelement;',...
         '~all(all(isfinite(v',int2str(i),'))'')];'])
end
if any(widthvect-ones(vectnum,1))
  error('Each vi must be a vector')
end
if any(lengthvectdiff)
  error('Vectors must be of the same length')
end
if any(complexelement)
  error('Vectors contain complex elements')
end
if any(infNaNelement)
  error('Vectors contain infinite or NaN elements')
end
%
nspec=['%',int2str(digitnum+1),'.',int2str(digitnum-1),'e'];
tab=setstr(9);
disp(['expvect is sending data to file ''',file,''' ...'])
%
tenlines='';
fnid=fopen(file,'w');
for j=1:length(v1)   %main cycle
  oneline='';
  for i=1:vectnum
    vs=['v',int2str(i),'(j)'];  %vi(j)
    if i<vectnum
      fspec=[nspec,tab];
    else
      fspec=[nspec,'\n'];  %last in line
    end
    eval(['oneline=[oneline,sprintf(fspec,',vs,')];'])
  end
  tenlines=[tenlines,oneline];
  %fprintf(fnid,oneline);  %send one line
  if (round(j/10)*10==j)|(j==length(v1))
    fprintf(fnid,tenlines);  %send ten lines
    tenlines=setstr([]);
    fprintf('%4.0f rows of %4.0f are ready\n',j,length(v1))
      %information message
  end
end
fclose(fnid);
%%%%%%%%%%%%%%%%%%%%%%%% end of expvect %%%%%%%%%%%%%%%%%%%%%%%%
