% ELIS   Parameter estimation of linear systems.
%% 
%%        pdat=ELIS(Fdat,domain,numord,denomord,runmod)
%% 
%%        Output argument:
%%        pdat = parameters in fidmodel object. Special properties set:
%%           fitinfo = informative column vector about the fit
%%              (request details by 'elis fitinfo' )
%%           The covariance is set to the approximate Cramer-Rao bound of the
%%              covariance matrix (inv(JTJ))
%%        Input arguments:
%%        Fdat = Fourier data (fiddata object). The variance needs to be filled in.
%%           In the object, the variances of the complex Fourier amplitudes are stored.
%%           WARNING! these values are the doubles of the variances of the real parts,
%%           needed in the old call forms of the toolbox. The object generating
%%           functions (e.g.varanal) generate the objects properly for this.
%%           The function fiddata requires the variances of the complex amplitudes.
%%        domain = 's', 'z', 'w', or 'r'
%%        numord = order of the numerator
%%        denomord = order of the denominator
%%        runmod = structure of the run modifiers
%%             (optional, request details by 'elis runmod' )
%% 
%%        Usage:
%%            pdat=elis(Fdat,domain,numord,denomord,runmod);
%%        Examples:
%%            load bandpass, bp1=bandpass{:,1}; bp1.SisoVariance=1.7e-4*[1,1];
%%            elis(bp1,'s',4,6);
%%            pv=elis('inpchan','s',11,12);
%%            %z-domain, free delay:
%%            elis('inpchan','z',14,14,struct('fs',51200,'delaytreat','variable'));
%% 
%%        See also: ELISTPER.
%% 
%%        Remark: the old-form command line call (backward compatible with
%%            the earlier versions of the toolbox) is still usable, type
%%            'oldhelp elis' to see this. The easier-to-use new form is 
%%            recommended, and will be supported in the future.
%%