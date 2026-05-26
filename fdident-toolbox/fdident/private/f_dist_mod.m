function factor=f_dist_mod(M,percent)
%F_DIST_MOD  Modifying factor for confidence limits of residuals with sample variances
%
%       M is the number of periods, that is, the degrees of freedom is 
%       df = 2*(M-1)

%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 27-Apr-2005

if nargin<=0, M=[]; end, if isempty(M), M=inf; end
if ~isfinite(M), factor=1; return, end
if nargin<=1, percent=[]; end, if isempty(percent), percent=0.95; end

exp95=5.9915; %inv(0.95,2)
exp50=1.3863;
df = 2*(M-1);
%2*ncfinv(0.95,2,df,0)
%[0.95,0.5]
mf=[  399.0000    3.0000
   38.0000    2.0000
   19.1042    1.7622
   13.8885    1.6569
   11.5723    1.5975
   10.2865    1.5595
    9.4748    1.5331
    8.9179    1.5137
    8.5130    1.4988
    8.2056    1.4870
    7.9646    1.4774
    7.7706    1.4695
    7.6111    1.4629
    7.4778    1.4573
    7.3646    1.4524
    7.2674    1.4481
    7.1831    1.4444
    7.1091    1.4411
    7.0438    1.4381
    6.9857    1.4355
    6.9336    1.4331
    6.8867    1.4309
    6.8443    1.4289
    6.8057    1.4271
    6.7704    1.4255
    6.7380    1.4239
    6.7083    1.4225
    6.6808    1.4212
    6.6553    1.4200
    6.6317    1.4188
    6.6096    1.4178
    6.5891    1.4168
    6.5698    1.4158
    6.5518    1.4149
    6.5348    1.4141
    6.5189    1.4133
    6.5038    1.4126
    6.4896    1.4119
    6.4762    1.4112
    6.4635    1.4106];
if percent<0.5, percent=0.5; end; if percent>0.95, percent=0.95; end
if df>size(mf,1), df=size(mf,1); end
[X,Y]=meshgrid([1:size(mf,1)]',[0.95,0.5]);
factor=sqrt( interp2(X,Y,mf',df,percent) / (-log((1-percent))/0.5) );
1;
%End of file f_dist_mod.m