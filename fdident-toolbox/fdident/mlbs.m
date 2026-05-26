function [bitseries,nextstnum]=mlbs(log2N,varargin)
%MLBS   Maximum length binary sequence (pseudo-random binary sequence, PRBS).
%
%       [bitseries,nextstnum]=MLBS(log2N,runmod)
%
%       Output arguments:
%       bitseries = generated bit series (values +1,-1).
%           If runmod is a structure, or 'tiddata', bitseries is a tiddata object.
%           Else it is a column vector, length: bitno, default length: 2^log2N-1
%       nextstnum = startnum to be used if continued sequence generation
%           follows.
%
%       Input arguments:
%       log2N = bit length of the shift register: integer number 1<=log2N<=30
%       runmod = run modifier structure
%         fs = frequency of samples
%         bitno = number of bits to be generated (length of bitseries)
%           default: 2^log2N-1
%         inverserepeat = 'on' for inverse repeat mlbs (odd spectral lines)
%         startnum = digital equivalent of the start value of the
%           shift register, considered as a regular binary number containing
%           0-s and 1-s.  1<=startnum<2^log2N
%
%       Usage: [bitseries,nextstnum]=mlbs(log2N,bitno,startnum);
%       Example: bitseries=mlbs(10);
%
%       See also: DIBS.

%Old fdident help
%MLBS   Maximum length binary sequence (pseudo-random binary sequence, PRBS).
%
%       [bitseries,nextstnum]=MLBS(log2N,bitno,startnum)
%
%       Output arguments:
%       bitseries = generated bit series (values +1,-1).
%           Column vector, length: bitno, default length: 2^log2N-1
%       nextstnum = startnum to be used if continued sequence generation
%           follows.
%
%       Input arguments:
%       log2N = bit length of the shift register: integer number 1<=log2N<=30
%       bitno = number of bits to be generated (length of bitseries)
%           default: 2^log2N-1
%       startnum = (optional) digital equivalent of the start value of the
%           shift register, considered as a regular binary number containing
%           0-s and 1-s.  1<=startnum<2^log2N
%
%       Usage: [bitseries,nextstnum]=mlbs(log2N,bitno,startnum);
%       Example: bitseries=mlbs(10);
%
%       See also: DIBS.

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2000
%       All rights reserved.
%       $Revision: $
%       Last modified: 22-Nov-2000

%       Algorithm:
%         K. R. Godfrey, ed.: Perturbation Signals for System Identification.
%         Englewood Cliffs, Prentice-Hall, 1993.

v=version; ip=findstr('.',v); if ip(1)==3, v=[setstr('a'-10+str2num(v(1:2))),v(3:end)]; end
if v(1)>='9', narginchk(1,3); %Matlab 2016a or later
else ni=nargin; error(nargchk(1,3,ni)), %earlier
end
if rem(log2N,1)~=0, error('log2N is not integer'), end
%
newcall=0;
if nargin>1
  runmod=varargin{1};
  if isstruct(runmod)|isa(runmod,'tiddata')|strncmp(runmod,'tiddata',5)
    newcall=1;
  else
    newcall=0;
  end
end
if ~newcall
  if nargin<2, bitno=[]; else bitno=varargin{1}; end
  if nargin<3, startnum=[]; else startnum=varargin{2}; end
  invr=0; fs=1;
else
  bitno=[]; startnum=[]; fs=1; invr=0;
  if isstruct(runmod)
    fn=fieldnames(runmod);
    for ii=1:length(fn)
      if strncmp(fn{ii},'bitno',4), bitno=getfield(runmod,fn{ii});
      elseif strncmp(fn{ii},'startnum',6), startnum=getfield(runmod,fn{ii});
      elseif strncmp(fn{ii},'fs',6)|strncmp(fn{ii},'fc',6)
        fs=getfield(runmod,fn{ii});
      elseif strncmp(fn{ii},'inverserepeat',3)
        invrstr=getfield(runmod,fn{ii});
        if strcmpi(invrstr,'on'), invr=1;
        elseif strcmpi(invrstr,'off')|isempty(invrstr)
        else error(['Invalid field ''',fn{ii},''''])
        end
      else error(['Unknown runmod field ''',fn{ii},''''])
      end
    end %for ii
  end
end
reglen=2^log2N-1;
if isempty(bitno), bitno=(invr+1)*reglen; end
if bitno>(invr+1)*reglen
  disp('WARNING! bitno exceeds maximum length of PRBS in mlbs')
end
if bitno<0, error('negative value of bitno'), end
%
if isempty(startnum), startnum=pow2(log2N)-1; end
%
if (startnum<1)|(startnum>pow2(log2N)-1), error('startnum out of range'), end
startnum=round(rem(abs(startnum-1),2^log2N-1))+1;
stn=startnum; reg=zeros(log2N,1);
for i=1:log2N
  reg(i)=rem(stn,2); stn=(stn-reg(i))/2;
end
zind=find(reg==0); reg(zind)=-1*ones(length(zind),1); %values +1,-1
%
if     log2N==1, multind=[1];
elseif log2N==2, multind=[1,2];
elseif log2N==3, multind=[2,3];
elseif log2N==4, multind=[3,4];
elseif log2N==5, multind=[3,5];
elseif log2N==6, multind=[5,6];
elseif log2N==7, multind=[4,7];
elseif log2N==8, multind=[4,5,6,8];
elseif log2N==9, multind=[5,9];
elseif log2N==10, multind=[7,10];
elseif log2N==11, multind=[9,11];
elseif log2N==12, multind=[6,8,11,12];
elseif log2N==13, multind=[9,10,12,13];
elseif log2N==14, multind=[4,8,13,14];
elseif log2N==15, multind=[14,15];
elseif log2N==16, multind=[4,13,15,16];
elseif log2N==17, multind=[14,17];
elseif log2N==18, multind=[11,18];
elseif log2N==19, multind=[14,17,18,19];
elseif log2N==20, multind=[17,20];
elseif log2N==21, multind=[19,21];
elseif log2N==22, multind=[21,22];
elseif log2N==23, multind=[18,23];
elseif log2N==24, multind=[17,22,23,24];
elseif log2N==25, multind=[22,25];
elseif log2N==26, multind=[20,24,25,26];
elseif log2N==27, multind=[22,25,26,27];
elseif log2N==28, multind=[25,28];
elseif log2N==29, multind=[27,29];
elseif log2N==30, multind=[7,28,29,30];
else error(sprintf('log2N=%.0f is not allowed',log2N))
end
bitseries=zeros(min(reglen,bitno),1);
for i=1:length(bitseries)
  bitseries(i)=-prod(reg(multind));
  reg=[bitseries(i);reg(1:log2N-1)];
  %if (rem(i,100)==0)|(i==2^log2N-1)
    %fprintf('mlbs ready with %.0f bits of %.0f\n',i,2^log2N-1)
  %end
end
if (length(reg)==1)&(length(bitseries)>0), bitseries=abs(bitseries); end
if invr
  bitseries=[bitseries;bitseries];
  bitseries(2:2:end)=-bitseries(2:2:end);
end
while length(bitseries)<bitno, bitseries=[bitseries;bitseries]; end
bitseries=bitseries(1:bitno);
if newcall
  bitseries=tiddata([],bitseries,1/fs);
end
%
nextstnum=sum((reg/2+1/2).*(2.0.^[0:log2N-1]'));
%
%end of mlbs
%%%%%%%%%%%%%%%%%%%%%%%% end of mlbs %%%%%%%%%%%%%%%%%%%%%%%%
