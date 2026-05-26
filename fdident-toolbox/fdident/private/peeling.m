function [outmodel,msg,allmodels]=peeling(fdata,InitModel,modeMaxCf,modeFoDTest,hFig)
%PEELING Fine order estimation step ('peeling')
%       Helper function of autoorder
%
%       [outmodel,msg]=peeling(fdata,InitModel,modeMaxCf,modeFoDTest,hFig);
%
%       Output arguments:
%       outmodel: estimated model (fidmodel object)
%       msg: messages about performed operations
%       allmodels: all tried models
%
%       Input arguments:
%         fdata =     Input freqvency domain measurement data (fiddata object)
%         InitModel = Initial model
%         modeMaxCf = Calculation method and constant for the max. allowed Cf
%             during fast peeling step. 
%             Structure with fields 'mode' and 'const', maybe 'errorweighting'.
%                mode = 'c' - MaxCf=Const;
%                       's' - MaxCf=Cf+Const*std(Cf);
%                       'm' - MaxCf=Const*Cf;
%                  If mode is in lowercase, MaxCf is not updated during the
%                  iteration (MaxCf is calculated only once in the initialization
%                  phase), otherwise updated after each reestimation step.
%                const: Contains variable Const.
%                errorweighting: 'lin' or 'nonlin', depending on the model type
%                Defaults: mode='s', const=2.
%                optional: plotfreq = 'linear' or 'log'
%         modeFoDTest = Constant for FoD tests (0 or 0.6..0.9). If zero, FoD test 
%                    is disabled, Cf is used instead.
%                    Default is 0.75.
%         hFig = Figure handle (optional). If missing, gcf is used. 
%              If 0, no graphical action performed
%
%       See also AUTOORDER, ORDERST1.

%       The algorithm is based on:
%       Yves Rolain, Johan Schoukens, Rik Pintelon, "Order Estimation for Linear
%          Time-Invariant Systems Using Frequency Domain Identification Methods,"
%          IEEE Trans. Autom. Contr., Vol.42, No.10, Oct. 1997, pp.1408-1417.

%       Written by Gyula Simon, 1998
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2005
%       All rights reserved.
%       $Revision: $
%       Last modified: 27-Apr-2005

if (nargin==1)&isstr(fdata)&strcmp(fdata,'preload'), return, end
%First set default values
if nargin<3, modeMaxCf='';     end
if isfield(modeMaxCf,'delay'), delay=modeMaxCf.delay; else delay=0; end
if isfield(modeMaxCf,'errorweighting'), errorweighting=modeMaxCf.errorweighting; else errorweighting='linear'; end
if nargin<4, modeFoDTest='';   end
if nargin<5, hFig='';          end
allmodels=[];

if isempty(hFig), hFig=gcf; end
if isempty(modeMaxCf), modeMaxCf=struct('mode', 'S', 'const', 2,'delay',0); end  % 2 * std
plotfreq='lin';
if isfield(modeMaxCf,'plotfreq'), plotfreq=modeMaxCf.plotfreq; end
if isempty(modeFoDTest), modeFoDTest=0.75; end  
if isempty(hFig)|(hFig==0), ElisPlotDens=inf; else, ElisPlotDens=10; end

Alg='NG'; % 'LMsvd' for LM svd, 'NG' for Gauss-Newton

% elis run modifier structures:
ElisRunmod=struct(...
  'representation', 'orthopol',...
  'algorithm', Alg, ...
  'initset', 'object', ...
  'plotdens', ElisPlotDens,...
  'delay',delay);
ElisRunmod1=struct('displaymessages', 'off');


%===============================================================================
%                               State Machine Description
%===============================================================================
%                                   States:
% ------------------------------------------------------------------------------
% I:      Init, no order reduction. 
% r:      Ranking of roots, no order reduction. Fails if order is 0/0.
% R:      Ranking of roots based on info gained in phases 'a', 'b', 'c'.
%         No order reduction. Fails if order is 0/0.
% E:      Estimation without order reduction. If the previous improvement was
%         in any of states 'A', 'B', 'C', 'E', it fails (no reestimation is made
%         in this case), otherwise tries to reestimate last successful model gained 
%         in 'a', 'b', or 'c'. If reestimated model in not acceptable, replaces it
%         with the last successful model and fails, otherwise succeeds.
% a,b,c:  Order reduction without reestimation. The type of roots to be eliminated
%         are chosen according to the result of the last 'r' state.
%         'a' tries the first, 'b' tries the second, 'c' tries the third
%         best suggestion by 'r'.
%         Fails, if no improvement was acchived in order reduction, otherwise succeeds.
% A,B,C:  Order reduction with model reestimation, similarly to 'a', 'b', and 'c'.
% O:      Final state, no more reductions possible
%
%
%                             State transitions:
%     ----------------------------------------------------------------
%      |Current State | Next state on success | Next state on failure |
%     ----------------------------------------------------------------
st={...
    {     'I'       ,          'r'         ,         'r'           },...
    {     'r'       ,          'a'         ,         'E'           },...
    {     'a'       ,          'r'         ,         'b'           },...
    {     'b'       ,          'r'         ,         'c'           },...
    {     'c'       ,          'r'         ,         'R'           },...
    {     'R'       ,          'A'         ,         'E'           },...
    {     'A'       ,          'r'         ,         'B'           },...
    {     'B'       ,          'r'         ,         'C'           },...
    {     'C'       ,          'r'         ,         'E'           },...
    {     'E'       ,          'r'         ,         'O'           },...
  };
%===============================================================================
%                      End of State Machine Description
%===============================================================================

% build transiton description structures
for ix=1:length(st)
  states{ix}      =st{ix}{1};
  next_success{ix} =st{ix}{2};
  next_failure{ix}=st{ix}{3};
end
NextStateSuccess =cell2struct(next_success,  states,2);
NextStateFailure=cell2struct(next_failure, states,2);


freqv=fdata.freqpoints;

PeelingState='I';  % init phase


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Perform peeling                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while PeelingState ~='O'
  LastStepSuccessful=1; %  this flag is cleared later if attempt fails
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                            Initialization                              %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if findstr(PeelingState, 'I') 
    % set domain
    domain='s';
    
    Pole=0; Zero=0;
    LastImprovement='E';
    RootToElim='-';
    ElisMethod=' '; FodInfo='';
    LastStepSuccessful=1; 
    LastCfValues=[inf inf inf];   
    model=InitModel; 
    [MaxDev, ContrZero, ContrPole, Pole, Zero]=RankPoleZero(model, fdata);
    CurrentNumOrder=length(model.num)-1;
    CurrentDenOrder=length(model.den)-1;
    [tf,N,D]=tfcalc(model, freqv);  % Numerator and denominator values
    m=max(max(abs(N)), max(abs(D)));
    N=N/m; D=D/m;
    [Cf, MCf, NCf]=cfncall(fdata, model,errorweighting); % cost function
    MaxEnabledCf=CalcMaxEnabledCf(fdata, model, modeMaxCf, 0,errorweighting);
    msg={'Peeling started'};
    autoomsg(msg{1}, hFig)
    TrialIx=1;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %             Rank and decide which roots to try to eliminate            %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if findstr(PeelingState, 'r') 
    [BestZeroIx, BestPoleIx, BestPairZeroIx, BestPairPoleIx, TrialOrder]=KickOffIx(MaxDev, ContrZero, ContrPole);
    % TrialOrder contains a string which describes the best possible order 
    % ( in the current situation) to eliminate roots
    RootToElim='-';
    LastCfValues=[inf, inf, inf];
    if strcmp(TrialOrder, '---');
      LastStepSuccessful=0; % finish, order is 0/0
    else
      LastStepSuccessful=1; 
    end
    
  elseif findstr(PeelingState, 'R')
    % ranking is based on previous results (Cf) of the latest 'abc' phases
    [tmp, OrdIx]=sort(LastCfValues);
    tmpstr='pzd'; 
    % now check, if some of the elimination methods is illegal because of low order
    if ~any(findstr(TrialOrder, 'p'))
      tmpstr(1)='-';
    end
    if ~any(findstr(TrialOrder, 'z'))
      tmpstr(2)='-';
    end
    if ~any(findstr(TrialOrder, 'd'))
      tmpstr(3)='-';
    end
    TrialOrder=tmpstr(OrdIx);
    RootToElim='-';
    if strcmp(TrialOrder, '---');
      LastStepSuccessful=0; % finish, order is 0/0
    else
      LastStepSuccessful=1; 
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %     try to delete pole and/or zero without reestimating the model      %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if findstr(PeelingState, 'abcABCE') 
    switch PeelingState
    case 'a'
      RootToElim=TrialOrder(1);
    case 'b'
      RootToElim=TrialOrder(2);
    case 'c'
      RootToElim=TrialOrder(3);
    case 'A'
      RootToElim=upper(TrialOrder(1));
    case 'B'
      RootToElim=upper(TrialOrder(2));
    case 'C'
      RootToElim=upper(TrialOrder(3));
    case 'E'
      RootToElim='E';
    end
    if RootToElim=='-'
      % it will fail
    end
    numord_try=CurrentNumOrder;
    denord_try=CurrentDenOrder;
    
    if    ((lower(RootToElim)=='z')& CurrentNumOrder>0)                     | ...
        ((lower(RootToElim)=='p')&                     CurrentDenOrder>0) | ...
        ((lower(RootToElim)=='d')& CurrentNumOrder>0 & CurrentDenOrder>0) | ...
        ((     (RootToElim)=='E'))
      
      % determine which root(s) to eliminate (temporarily)
      if findstr(RootToElim, 'dD')  % pole/zero pair
        KickOffIxZero=BestPairZeroIx;
        KickOffIxPole=BestPairPoleIx;
      elseif findstr(RootToElim, 'zZ') % peel a single zero
        KickOffIxZero=BestZeroIx;
        KickOffIxPole=[];
      elseif findstr(RootToElim, 'pP') % peel a single pole
        KickOffIxZero=[];
        KickOffIxPole=BestPoleIx;
      else % 'E': order doesn't change
        KickOffIxZero=[];
        KickOffIxPole=[];
      end
      % find new pole-zero pattern
      GuessZeros=Zero(setdiff(1:length(Zero), KickOffIxZero));
      GuessPoles=Pole(setdiff(1:length(Pole), KickOffIxPole));
      %   GuessAllZeros=[GuessZeros; conj(GuessZeros(find(imag(GuessZeros))))];
      %   GuessAllPoles=[GuessPoles; conj(GuessPoles(find(imag(GuessPoles))))];
      
      
      if ~isempty(KickOffIxZero)  % determine new numord & zeros
        if imag(Zero(KickOffIxZero))  % complex pair
          ZeroPoly=[1, -2*real(Zero(KickOffIxZero)), abs(Zero(KickOffIxZero))^2];
          numord_try=CurrentNumOrder-2; 
        else % real zero
          ZeroPoly=[-1/Zero(KickOffIxZero), 1];
          numord_try=CurrentNumOrder-1; 
        end
      else
        ZeroPoly=1; numord_try=CurrentNumOrder; 
      end
      
      if ~isempty(KickOffIxPole) % determine new denord & poles
        if imag(Pole(KickOffIxPole))  % complex pair
          PolePoly=[1, -2*real(Pole(KickOffIxPole)), abs(Pole(KickOffIxPole))^2];
          denord_try=CurrentDenOrder-2;
        else % real pole
          PolePoly=[-1/Pole(KickOffIxPole), 1];
          denord_try=CurrentDenOrder-1;
        end
      else
        PolePoly=1; denord_try=CurrentDenOrder;
      end
      
      % build new N,D
      if findstr(domain,  'ps') % 's' or 'p' domain
        N_try=N./polyval(ZeroPoly, freqv*2*pi*j);
        D_try=D./polyval(PolePoly, freqv*2*pi*j);
      elseif findstr(model.variable, 'z') % 'z^-1' domain
        error(['Domain ' model.variable ' is not implemented'])
      else
        error(['Domain ' model.variable ' is not implemented'])
      end
      %Normalize N_try and D_try
      m=max(max(abs(N)),max(abs(D)));
      N_try=N_try/m; D_try=D_try/m;
      %
      Cf=cfncall(fdata, {N_try, D_try, numord_try, denord_try},errorweighting);
      switch RootToElim
      case 'p'
        LastCfValues(1)=Cf;
      case 'z'
        LastCfValues(2)=Cf;
      case 'd'
        LastCfValues(3)=Cf;
      otherwise
      end
      if findstr(PeelingState, 'abc') 
        if Cf<=MaxEnabledCf 
          if ~isempty(KickOffIxZero)
            Zero=GuessZeros;
            MaxDev(:,KickOffIxZero)=[];
            ContrZero(KickOffIxZero)=[];
          end
          if ~isempty(KickOffIxPole)
            Pole=GuessPoles;
            MaxDev(KickOffIxPole,:)=[];
            ContrPole(KickOffIxPole)=[];
          end
          N=N_try; D=D_try;
          CurrentNumOrder=numord_try;
          CurrentDenOrder=denord_try;
        else   % Cf too large
          LastStepSuccessful=0;
        end
      elseif isequal(PeelingState, 'E') & any(findstr(LastImprovement, 'ZPDE'))
        LimitMode= 'auto';
        switch LimitMode
        case 'auto'
          % Last improvement was made by elis. No further trial is meaningful.
          % Either it is the global minimum or we are stuck in a local minimum from
          % which neither attempt helped to escape.
          LastStepSuccessful=0; % This is the very end.
        case 'forcedown'  % test only !!!!
          % test, if desired order reached
          if CurrentNumOrder > 20  % test only
            [tmp, OrdIx]=sort(LastCfValues);
            tmpstr='pzd'; 
            TrialOrder=tmpstr(OrdIx);
            model=LastEstimatedModel{OrdIx(1)}; 
            [MaxDev, ContrZero, ContrPole, Pole, Zero]=RankPoleZero(model, fdata);
            CurrentNumOrder=length(model.num)-1;
            CurrentDenOrder=length(model.den)-1;
            [tf,N,D]=tfcalc(model, freqv);  % Numerator and denominator values
            m=max(max(abs(N)), max(abs(D)));
            N=N/m; D=D/m;
            [Cf, MCf, NCf]=cfncall(fdata, model,errorweighting); % cost function
            MaxEnabledCf=Cf+2*sqrt(NCf+2*MCf); % 95% cf interval 
            
            RootToElim=tmpstr(OrdIx(1));
            LastStepSuccessful=1; % Continue iteration
          else
            LastStepSuccessful=0; % OK, we can finish now
          end
        end
      else % findstr(PeelingState, 'ABCE')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                               Reestimate Model                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ElisMethod: 
        %           'NormalMode': No initialization done, ELiS starts with option 'a'
        %           'InitMode'  : Tries to initialize ELiS with a good model using 
        %                         the estimated N and D
        if Cf < MaxEnabledCf*10 % it may be worth to use it as an initial guess
          ElisMethod='InitMode';
        else                    % use previous passed model as init
          ElisMethod='NormalMode';
        end
        switch ElisMethod
        case 'InitModeOld'  % not used any more, use faster 'InitMode' instead
          % try to generate good starting for ELiS from peeled model
          initdata=fdata; initdata.output=N_try./D_try.*fdata.input;
          set(initdata, 'inputvar', 0, 'outputvar', 1e-9, 'covv', 0);
          [initmodel]=...
            elis(initdata, '', [domain+0, numord_try, denord_try, inf], ...
            '', [Alg, 'a'+0, 10], ...
            [ElisPlotDens, nan, nan, nan, nan, 'icca   '+0, 1, 'n'+0] );
          
          [trymodel, fit]=...
            elis(fdata, '', [domain+0, numord_try, denord_try, inf], ...
            '', [Alg, 'f'+0], ...
            [ElisPlotDens, nan, nan, nan, nan, 'icca   '+0, 1, 'n'+0], initmodel );
          if nargout>=3, allmodels=stack(2,allmodels,trymodel);, end
        case  'NormalModeOld'  % NOT USED ANY MORE
          % try to generate good starting for ELiS from previous passed model
          W=fdata.inputvar.*abs(N).^2 + fdata.outputvar.*abs(D).^2 - 2*real(D.*conj(N).*fdata.covvect);
          W=1./sqrt(W); 
          [trymodel, fit]=...
            elis(fdata, '', [domain+0, numord_try, denord_try, inf], ...
            '', [Alg, 'i'+0], ...
            [ElisPlotDens, nan, nan, nan, nan, 'icca   '+0, 1, 'n'+0], '', '', W);   
          if nargout>=3, allmodels=stack(2,allmodels,trymodel);, end
          
        case 'InitMode'  
          %W=fdata.inputvar.*abs(N_try).^2 + fdata.outputvar.*abs(D_try).^2 - 2*real(D_try.*conj(N_try).*fdata.covvect);
          %W=1./W; 
          %[trymodel, fit]=...
          %   elis(fdata, '', [domain+0, numord_try, denord_try, inf], ...
          %   '', [Alg, 'i'+0], ...
          %   [ElisPlotDens, nan, nan, nan, nan, 'icca   '+0, 1, 'n'+0], '', '', W);   
          
          % ^^^^^^^^^^^^^^^^^^^^  NOT good for high orders, Elis fails  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
          %                                 use my init instead
          %                               vvvvvvvvvvvvvvvvvvvvvvv
          
          W=fdata.inputvar.*abs(N_try).^2 + fdata.outputvar.*abs(D_try).^2 - 2*real(D_try.*conj(N_try).*fdata.covvect);
          W=1./sqrt(W); 
          initmodel=wgtsini(fdata, numord_try, denord_try, 1./W,errorweighting);
          % OLD CALL
          %[trymodel, fit]=...
          %   elis(fdata, '', [domain+0, numord_try, denord_try, inf], ...
          %   '', [Alg, 'f'+0], ...
          %   [ElisPlotDens, nan, nan, nan, nan, 'icca   '+0, 1, 'n'+0], initmodel);
          ElisRunmod.initmodel=initmodel;
          ElisRunmod.plotfreq=plotfreq;
          ElisRunmod.delay=modeMaxCf.delay;
          ElisRunmod.errorweighting=errorweighting;
          try
            [trymodel]=...
              elis(fdata, domain, numord_try, denord_try, ElisRunmod, ElisRunmod1);
          catch
            outmodel=[]; allmodels=[]; msg='Run aborted';
            return
          end
          if nargout>=3, allmodels=stack(2,allmodels,trymodel);, end

        case  'NormalMode'  
          % try to generate good starting for ELiS using WGTLS or TLS and W gained from previous good result
          if strncmpi(errorweighting,'linear',3)
            Cxx=fdata.inputvariance;
            Cyy=fdata.outputvariance;
            Cxy=fdata.covvector;
          else
            Cxx=fdata.InputNonlinError;
            Cyy=fdata.OutputNonlinError;
            Cxy=fdata.nonlincovvector;
          end
          W=Cyy.*abs(D).^2;
          if ~isempty(Cxx), W=Cxx.*abs(N).^2 + W; end
          if ~isempty(Cxy), W=W - 2*real(D.*conj(N).*Cxy); end
          W=1./sqrt(W);
          fdatam=fdata;
          if delay, fdatam.outputdelay=delay; end
          initmodel=wgtsini(fdatam, numord_try, denord_try, 1./W,errorweighting);
          if delay, initmodel.delay=delay; end
          % OLD CALL
          %[trymodel, fit]=...
          %   elis(fdata, '', [domain+0, numord_try, denord_try, inf], ...
          %   '', [Alg, 'f'+0], ...
          %   [ElisPlotDens, nan, nan, nan, nan, 'icca   '+0, 1, 'n'+0], initmodel);
          ElisRunmod.initmodel=initmodel;
          ElisRunmod.plotfreq=plotfreq;
          ElisRunmod.delay=modeMaxCf.delay;
          ElisRunmod.errorweighting=errorweighting;
          ind=[];
          if nargout>=3
            if isa(allmodels,'fidmodel')
              ind=strmatch(sprintf('%.0f/%.0f',numord_try,denord_try),order(allmodels));
            else
              ind=[];
            end
          end
          if isempty(ind)
            try
              trymodel=...
                elis(fdata, domain, numord_try, denord_try, ElisRunmod, ElisRunmod1);
            catch
              outmodel=[]; allmodels=[]; msg='Run aborted';
              return
            end
            if nargout>=3
              allmodels=stack(2,allmodels,trymodel);
            end
          else
            trymodel=allmodels(:,:,ind);  
          end
          % end of test %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        end               
        Cf=cfncall(fdata, trymodel,errorweighting); % cost function
        switch RootToElim
        case 'P'
          LastCfValues(1)=Cf;
          LastEstimatedModel{1}=trymodel;
        case 'Z'
          LastCfValues(2)=Cf;
          LastEstimatedModel{2}=trymodel;
        case 'D'
          LastCfValues(3)=Cf;
          LastEstimatedModel{3}=trymodel;
        otherwise
        end
        [fodOK, tmp, tmp, f1, f2]=chkfod(fdata, trymodel ,modeFoDTest,errorweighting, 0); % no plot now
        FodInfo=sprintf('[%3.0f  %3.0f] ', 100*f1(1), 100*f2(2));
        if modeFoDTest==0
          ModelOK=(Cf<=MaxEnabledCf);
        else %  FoD test
          ModelOK=fodOK & (Cf<=MaxEnabledCf*2); % FoD AND a loose Cf check
        end
        if ~ModelOK % trymodel is not acceptable
          if isequal(PeelingState, 'E') %
            % last improvement acchieved in the fast phase, but this guess was wrong
            % the story will end here...
            CurrentNumOrder=length(model.num)-1;
            CurrentDenOrder=length(model.den)-1;
          else
            % continue, there is still hope... 
          end
          LastStepSuccessful=0; 
        else % improvement in last estimation
          model=trymodel; % keep this model
          [MaxDev, ContrZero, ContrPole, Pole, Zero]=RankPoleZero(model, fdata);
          CurrentNumOrder=length(model.num)-1;
          CurrentDenOrder=length(model.den)-1;
          [tf,N,D]=tfcalc(model, freqv);  % Numerator and denominator values
          m=max(max(abs(N)), max(abs(D)));
          N=N/m; D=D/m;
          MaxEnabledCf=CalcMaxEnabledCf(fdata, model, modeMaxCf, MaxEnabledCf,errorweighting);
        end % ABC or meaningful E
      end % ABCE
    else  % order is too low
      LastStepSuccessful=0;
      % no more zero or pole remained to eliminate
    end 
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                           Determine next state                         %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  TrialIx=TrialIx+1;
  if any(findstr(PeelingState, 'ABCE'))
    Method=ElisMethod(1);
  else
    Method=' ';
  end
  msg{TrialIx}=['    Peeling step #', num2str(TrialIx-1), ': ', ...
      ' State: ', PeelingState, RootToElim, Method, ...
      ' (', LastImprovement, ')'];
  
  if findstr(PeelingState, 'abcABCE')
    msg{TrialIx}=[msg{TrialIx}, ...
        ', Trial: ' , num2str(numord_try), '/', num2str(denord_try), ...
        ', Success: ', num2str(LastStepSuccessful), ...
        ', Cf: ', num2str(floor(Cf)), ...
        '/', num2str(floor(MaxEnabledCf))];
    if LastStepSuccessful
      msg{TrialIx}=[msg{TrialIx}, ...
          ', ord: ', num2str(CurrentNumOrder), '/', num2str(CurrentDenOrder)];
    end
  end
  if any(findstr(PeelingState, 'ABCE')) 
    msg{TrialIx}=[msg{TrialIx}, ', FodInfo: ', FodInfo];
    if modeFoDTest==0
      msg{TrialIx}=[msg{TrialIx}, '(na)'];
    end
  end
  if any(findstr(PeelingState, 'rR'))
    msg{TrialIx}=[msg{TrialIx}, ...
        ', TrialOrder: ', TrialOrder];
  end
  autoomsg(msg{TrialIx}, hFig)
  if LastStepSuccessful
    if findstr(RootToElim, 'pzdPZDE')
      LastImprovement=RootToElim;
    end
    PeelingState=getfield(NextStateSuccess, PeelingState);
  else
    PeelingState=getfield(NextStateFailure, PeelingState);
  end
  
end
outmodel=model;








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Local functions                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [MaxDev, ContrZero, ContrPole, Pole, Zero]=RankPoleZero(model, fdata)
% calculate poles, zeros, and their possible contribution to the transfer function
% function [MaxDev, ContrZero, ContrPole, Pole, Zero]=RankPoleZero(model, fdata)
%   Output variables:
%             MaxDev:    pole-zero cancellation measure 
%                          (small values suggest cancelling paires)
%             ContrZero: Contribution of zeros to the tf
%             ContrPole: Contribution of poles to the tf
%                          (values close to 1 suggest noncontributing root)
%             Pole:      Poles of the model
%             Zero:      Zeros of the model
%                          (only those with real part > 0 included)
%   Input variables:
%             model:     fidmodel object
%             fdata:     fiddata object

freqv=fdata.freqpoints;
if strcmp(model.variable, 's')
  if strcmp(model.representation, 'orthopol')
    fs=model.fscale;
    %AllZeros=ortroots(model.num,  model.Znum)  *fs; 
    %AllPoles=ortroots(model.denom,model.Zdenom)*fs;
    AllZeros=fdident('private', 'ortroots', model.num,  model.Znum)  *fs; 
    AllPoles=fdident('private', 'ortroots', model.denom,model.Zdenom)*fs;
  else % polynomial representation
    AllZeros=roots(model.num); 
    AllPoles=roots(model.denom);
  end
elseif findstr(model.variable, 'z')
  if strcmp(model.representation, 'orthopol')
    fs=model.fs;
    AllZeros=fdident('private', 'ortroots', model.num,  model.Znum); 
    AllPoles=fdident('private', 'ortroots', model.denom,model.Zdenom);
  else % polynomial representation
    AllZeros=roots(model.num); 
    AllPoles=roots(model.denom);
  end
else
  error(['Domain ' model.variable ' is not implemented'])
end



% positive frequencies only
Zero=AllZeros(find(imag(AllZeros)>=0));
Pole=AllPoles(find(imag(AllPoles)>=0));

numZero=length(Zero);
numPole=length(Pole);
%plot(Zero, 'ro'), hold on, plot(Pole, 'rx'), hold off
% distances between poles and zeros
DeltaPoleZero=abs(kron(Pole(:), ones(1,numZero))-...
  kron(ones(numPole,1), Zero(:).'));

% distances between poles and freq grid
DeltaPoleF=abs(kron(Pole(:), ones(1,length(freqv)))-...
  kron(ones(numPole,1), j*2*pi*freqv(:).'));

% distances between zeros and freq grid
DeltaZeroF=abs(kron(Zero(:), ones(1,length(freqv)))-...
  kron(ones(numZero,1), j*2*pi*freqv(:).'));

% min and max distance of the poles and zeros from the freq grid: 
% min|jw-b|
minDeltaPoleF=min(DeltaPoleF')';
maxDeltaPoleF=max(DeltaPoleF')';
minDeltaZeroF=min(DeltaZeroF')';
maxDeltaZeroF=max(DeltaZeroF')';

% Now calculate Pole/Zero ranking criteria (in the measured band !)
% Crit 1. max deviation of the tf caused by a pole-zero pair 
%         (Small values suggest paires which can be eliminated)
MaxDev=DeltaPoleZero./kron(minDeltaPoleF, ones(1, numZero));

% Crit 2. Contribution of pole or zero to the tf 
%         (Values close to 1 suggest roots which can be eliminated)
ContrZero=minDeltaZeroF./maxDeltaZeroF;
ContrPole=minDeltaPoleF./maxDeltaPoleF;



function [BestZeroIx, BestPoleIx, BestPairZeroIx, BestPairPoleIx, TrialOrder]=KickOffIx(MaxDev, ContrZero, ContrPole)
% Return indeces of pole(s) and zero(s) of which contribution to the tf are most likely the smallest
% function [BestZeroIx, BestPoleIx, BestPairZeroIx, BestPairPoleIx, TrialOrder]=KickOffIx(MaxDev, ContrZero, ContrPole)
% Output variables:
%            BestZeroIx    : index of a zero (or a complex pair)
%            BestPoleIx    : index of a pole (or a complex pair)
%            BestPairZeroIx: index of a zero (or a complex pair) in a pole-zero pair
%            BestPairPoleIx: index of a pole (or a complex pair) in a pole-zero pair
%            TrialOrder    : 1x3 string containing chars 'p','z', and 'd'. The order of
%                            the chars indicates the best possible order of elimination
% Input variables:
%            MaxDev   : measure matrix of pole-zero contributions
%            ContrZero: measure vector of zero contributions
%            ContrPole: measure vector of pole contributions
% Note: only those roots with non-negative imag part are represented

% pole/zero pair
mindev=min(min(MaxDev)); 
if isempty(mindev), mindev=inf; MaxDev=0; end % avoid error & warning, result is not important
% try to transform mindev to the domain 0..1 so that it would be comparable with pole and zero meas
pairmeas=1/(mindev+1);  
[BestPairPoleIx, BestPairZeroIx]=find(MaxDev==mindev);
if length(BestPairPoleIx)>1
  BestPairPoleIx=BestPairPoleIx(1);
end
if length(BestPairZeroIx)>1
  BestPairZeroIx=BestPairZeroIx(1);
end
% single zero
[zeromeas, BestZeroIx]=max(ContrZero);
% single pole
[polemeas, BestPoleIx]=max(ContrPole);

tmpstr='pzd'; 
if isempty(polemeas)
  polemeas=0; tmpstr([1,3])='--';
end
if isempty(zeromeas)
  zeromeas=0; tmpstr([2,3])='--';
end

[tmp, OrdIx]=sort([polemeas, zeromeas, pairmeas]);
% reverse order now, since sort provides ascending order
TrialOrder=tmpstr(OrdIx(end:-1:1));


function MaxEnabledCf=CalcMaxEnabledCf(fdata, model, modeMaxCf, OldMaxEnabledCf,errorweighting);
% calculate MaxEnabledCf for the fast peeling process

[Cf, MCf, NCf]=cfncall(fdata, model,errorweighting); % cost functions

MaxCfUpdate=modeMaxCf.mode;
Const=modeMaxCf.const;
if (lower(MaxCfUpdate)==MaxCfUpdate) & OldMaxEnabledCf~=0
  MaxEnabledCf=OldMaxEnabledCf;
else
  switch lower(MaxCfUpdate)
  case 'c'
    % Constant mode
    MaxEnabledCf=Const;
  case 's'
    % Use Cf, standard deviation, and Const
    MaxEnabledCf=Cf+Const*sqrt(NCf+2*MCf); % 95% cf interval, if Const=2 
  case 'm'
    % Use multiple of Cf 
    MaxEnabledCf=Cf*Const;
  end
end

function model=wgtsini(fdata, NumOrd, DenOrd, W,errorweighting)
% WGTSINI Weighted Generalized Total Least Squares
%
%    function model=wgtsini(fdata, NumOrd, DenOrd,errorweighting)
%
%    Output:   
%           model : result of WGTLS or TLS initial step, fidmodel object ('p' domain)
%    Input: 
%           fdata : frequency data
%           NumOrd: Order of model's numerator
%           DenOrd: Order of model's denominator
%           W     : Weighting vector (as appears in the Cf's denominator)
%                   Optional, if missing, QML weighting is used

%         Written by Gyula Simon, 1998.
%         Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-98
%         All rights reserved.
%         $Revision: $
%         Last modified: 15-Jul-1999


if nargin<3
  DenOrd=NumOrd;
end

X=fdata.input;  % measured input data
Y=fdata.output; % measured output data

if strncmpi(errorweighting,'linear',3)
  Cxx=fdata.inputvariance;
  Cyy=fdata.outputvariance;
  Cxy=fdata.covvector;
else
  Cxx=fdata.InputNonlinError;
  Cyy=fdata.OutputNonlinError;
  Cxy=fdata.nonlincovvector;
end
fv=fdata.freqpoints; % frequencies, where measurements were performed
% normalize freq now:
fv = 1/pi*fv /(max(fv)+min(fv));  % normalize frequencies
%    ^^^^^   It's a miracle... Why is it necessary ? Only Istvan may know...

K=length(fv); % # of freq points

if nargin<4
  % weight calculation
  W=qmlw(fdata, NumOrd, DenOrd);
end


% orthonormal polinomail basis calculation
%[Qn, Zn]=orthopol(NumOrd, 'p', fv, X./W);
%[Qd, Zd]=orthopol(DenOrd, 'p', fv, Y./W);
[Qn, Zn]=fdident('private', 'orthopol', NumOrd, 'p', fv, X./W);
[Qd, Zd]=fdident('private', 'orthopol', DenOrd, 'p', fv, Y./W);

% The currect orthopol (26.11.1998) fulfills the following test. 
% Check, if orthopol changed in the meantime
%vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
QnTest=Qn.*kron(ones(1,size(Qn,2)),X./W);
TestRes=2*real(QnTest'*QnTest); %This should be identity
if any(any(abs(TestRes-eye(NumOrd+1))>1800*eps*(NumOrd+1)))
  max(max(abs(TestRes-eye(NumOrd+1)))), 1800*eps*NumOrd
  error('Orthopol changed or orthopol generation failure.')
end        
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^end of test

Qn=Qn*sqrt(2); Qd=Qd*sqrt(2);  % bypass; 

J=[diag(X./W)*Qn, -diag(Y./W)*Qd]; 
J=[real(J); imag(J)]; % real Jacobian

% Column Covariance Matrix calculation
C=colcov(Cxx, Cyy, Cxy, W, Qn, Qd);
C=real(C); % real covariance matrix

%Now calculate WGTLS estimate
%First line looking after svd/multipication error
[u,s,v]=svd(C,0);
s2=diag(sqrt(diag(s)));
sqrtC=u*s2*v';
if ~isequal(sqrtC,u*s2*v') %Something wrong, but I cannot catch...
  if strncmp(version,'7.0.4',5) %try to make fix in Matlab 7.0.4
    disp('Trying to save and load some matrices ...')
    save USV_temp_save_in_peeling.mat u s2 v
    clear u s2 v
    load USV_temp_save_in_peeling.mat, delete USV_temp_save_in_peeling.mat, pause(1)
  end
  disp('Evaluating product pairwise ...')
  sqrtC=v'; sqrtC=s2*sqrtC; sqrtC=u*sqrtC;
  %sqrtC=u*s2*v';
  if any(any(isnan(sqrtC))) %error persists after second multiplication
    dbs=dbstack;
    NaNsC=find(isnan(sqrtC)), NaNsproduct=find(isnan(u*s2*v')),
    maxs=[max(max(abs(u))),max(max(abs(s2))),max(max(abs(v)))]
    cl=clock; assignin('base','cl',cl),
    try, evalin('base','elapsed_time=sprintf(''%.1f min'',etime(cl,cl0)/60)'), catch, end
    command='dbtype private\peeling 802:827';
    save(['peeling-error-',date,sprintf('_%.0f-%.0f',cl(4),cl(5)),'.mat'])
    warning('Numerical error in peeling: see saved file and messages above.')
    error('Numerical error in peeling: see saved file and messages above.')
  end
end %last line
[U1,U2,X,S1,S2]=gsvd(J, sqrtC);
Xi=inv(X'); theta=Xi(:,1);
Num=theta(1:NumOrd+1);
Den=theta(NumOrd+2:end);
% bypass: model should contain this (otherwise default) value for fs
fs=(max(fdata.freqpoints)+min(fdata.freqpoints))*pi;
model1=fidmodel('s',Num.',Den.', 0, fs, '', '', ...
  '', Zn, Zd, '', fdata.freqpoints);


% now calculate TLS estimate
[U,S,V]=svd(J);
theta=V(:,end);
Num=theta(1:NumOrd+1);
Den=theta(NumOrd+2:end);
% bypass: model should contain this (otherwise default) value for fs
fs=(max(fdata.freqpoints)+min(fdata.freqpoints))*pi;
model2=fidmodel('s',Num.',Den.', 0, fs, '', '', ...
  '', Zn, Zd, '', fdata.freqpoints);
model=model2;

Cf1=cfncall(fdata, model1,errorweighting);
Cf2=cfncall(fdata, model2,errorweighting);
% return best model
if Cf1 < Cf2
  model=model1;
  %disp(['WGTLS won ', num2str([Cf1 Cf2])])
else
  model=model2;
  %disp(['TLS won ', num2str([Cf1 Cf2])])
end

function autoomsg(msg,hFig)
%AUTOOMSG temporary solution for auto order messages
%       Helper function of autoorder
%
%       Usage: autoomsg(msg,hFig)

if ~isempty(hFig)
  hBar=findobj(allchild(hFig), 'tag', 'autoorder_message_bar');
  if isempty(hBar) % create message bar
    hBar=uicontrol('parent', hFig, ...
      'style', 'text', ...   
      'horizontal', 'left', ...
      'unit', 'normal', ...
      'position', [0 0 1 .05], ...
      'string', msg,...
      'tag', 'autoorder_message_bar');
    %   ext=get(hBar, 'extent');
    %   set(hBar, 'position', [0 0 1 ext(4)])
  else
    set(hBar, 'string', msg)
  end
end
disp(msg)

%WARNING: substituted by tfcalc
function [N,D]=calcnd(model, freqv)
%      Calculate normalized numerator and denominator values of a tf specified by model
%      at frequency points in freqv
%       Helper function of autoorder
%
%      [N,D]=calcnd(model, freqv)
%
%      output arguments:
%         N = numerator values
%         D = denominator values
%      input arguments:
%         model = fidmodel with fields num, denom, variable, and representation
%         freqv = frequency vector
 
%       Written by Gyula Simon, 1998
%       Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1991-2001
%       All rights reserved.
%       $Revision: $
%       Last modified: 13-Oct-2001

if strcmp(model.variable, 's') % 's' or 'p' domain
   if strcmp(model.representation, 'orthopol')  % 'p' domain
      %N=orthpval(model.num, model.Znum,freqv/model.fscale);
      %D=orthpval(model.denom, model.Zdenom,freqv/model.fscale);
      N=fdident('private', 'orthpval', model.num, model.Znum,freqv/model.fscale);
      D=fdident('private', 'orthpval', model.denom, model.Zdenom,freqv/model.fscale);
   else
      N=polyval(model.num,   freqv*j*2*pi);
      D=polyval(model.denom, freqv*j*2*pi);
   end
elseif findstr(model.variable, 'z') % 'z^-1' domain
      N=polyval(model.num(end:-1:1),   exp(-freqv/model.fs*j*2*pi));
      D=polyval(model.denom(end:-1:1), exp(-freqv/model.fs*j*2*pi));
else
   error(['Domain ' model.variable ' is not implemented'])
end
%Normalize numerator and denominator of tf
m=max(max(abs(N)), max(abs(D)));
N=N/m; D=D/m;

%End of file peeling.m