function [Harr,frarr,vararr]=frf(Fdat)
%FRF  Calculate object which contains FRF objects for each input 
%
%       [Harr,frarr,vararr]=frf(dat,outputs,inputs)
%
%       Each output argument is an  Ny x Nu  cell array

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 2002-2004
%       All rights reserved.
%       $Revision: $
%       Last modified: 24-Apr-2004

expnumb=get(Fdat,'ExpNumber');
uv=get(Fdat,'u');
yv=get(Fdat,'y');
freq=get(Fdat,'freqpoints');
covmx=get(Fdat,'covariancematrix');

if ~iscell(uv), uv={uv}; end
if ~iscell(yv), yv={yv}; end
sX=size(uv,1);                                          % number of input channels
sY=size(yv,1);                                          % number of output channels

if ~iscell(freq)
    f_v=freq;
    freq=cell(sX+sY,expnumb);
    for ie=1:expnumb
        for iA=1:sY
            if ~isempty(yv{iA,ie}), freq{iA,ie}=f_v; end
        end
        for iA=1:sX
            if ~isempty(uv{iA,ie}), freq{iA+sY,ie}=f_v; end
        end
    end
end                                                     % sure?


f_union=[];
for iii=1:expnumb    % for all the selected experiments
  for ii=1:sX+sY
    f_union=union(f_union,freq{ii,iii});  % all the frequencies used
  end
end
f_sum=size(f_union,1);

frf_measured=zeros(sY,sX);
frarr=cell(sY,sX);
Harr=cell(sY,sX);

for iii=1:size(f_union,1)
    u_f=NaN*ones(sX,expnumb);
    y_f=NaN*ones(sY,expnumb);

    for ii=1:expnumb                                        
        
        for iiii=1:sY                                   % outputs
            I=find(f_union(iii)==freq{iiii,ii});
            if ~isempty(I)                              % if the output is measured at the actual frequency 
                y_f(iiii,ii)=yv{iiii,ii}(I);
            end
        end
        
        for iiii=1:sX                                   % inputs
            I=find(f_union(iii)==freq{iiii+sY,ii});
            if ~isempty(I)                              % if the input is measured at the actual frequency 
                u_f(iiii,ii)=uv{iiii,ii}(I);
            end
        end
    end
  
    I_exper=find(any(~isnan(u_f),1));     % which experiment is non-used
    %I_exper=union(any(~isnan(u_f),1),I_exper); %ZOLI! Ezt kommenteztem, nem
                                                %tudom jó-e...

    u_f=u_f(:,I_exper);
    y_f=y_f(:,I_exper);
    
    I_u=find(any(~isnan(u_f),2));   % an input is non-used in every experiment (current freq)
    I_y=find(all(~isnan(y_f),2));   % an output is non-used in any experiment
    
    u_f=u_f(I_u,:);                 % only excited inputs, measuerd outputs
    y_f=y_f(I_y,:);
    
    u_f(isnan(u_f))=0;              % make NaN-s az zeros
    y_f(isnan(y_f))=0;
    
    if (size(u_f,2)>=size(u_f,1))    % non-less experiment than inputs
        frf_f=y_f/u_f;                                  
        for iY=1:length(I_y)
            for iX=1:length(I_u)
                frarr{I_y(iY),I_u(iX)}(end+1,1)=f_union(iii);
                Harr{I_y(iY),I_u(iX)}(end+1,1)=frf_f(iY,iX);
            end
        end
    end
end
%
vararr=cell(sY,sX);
