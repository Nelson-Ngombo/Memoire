Help on frequency domain system identification model objects
Last modified: 29-May-2004

Foreword
--------
Any kinds of dynamic model objects should be related to the LTI object.
This makes it possible to use the existing methods, seamlessly
pass identification results to the control environment, and to easily
exchange data not only at the input of identification, but also
at the output of it.

Many functions are programmed to be overloaded to handle first
the specialties, then go to LTI if it is installed, or do a local
solution. Thus, many useful things are preserved, without being paralyzed
without them.
Models are seamlessly converted by fidmodel(), tf(), zpk() and ss().  
Also, the SYSID toolbox objects are converted in both directions: fidmodel(), idpoly(), idarx().
--------------------------
FIDMODEL Frequency Domain System Identification Model Object
Creator: fidmodel
Overloaded functions: get, set, field references (like m.input), indexing,
  plot, display, cloud, stack
  Future plans:
    [ ; ] or cat(1,...) (add by output channel to make MIMO), 
    [ , ] or cat(2,...) (add by input channel to make MIMO),
    * (series connection)
Subscripting fidmodel arrays: model(:,:,2),
  subscripting by output and input channels: model(2:3,1)
Relation to (by call from overloaded functions): tf/LTI

Properties:
--------------------
'General' properties
--------------------
.Name  string, name of the system (e.g. for plots)
.Version  version number, e.g. 1.0 to allow proper handling of earlier versions
.Date  string, data and time of measurement or construction 
.Notes  string, textual information provided by the constructor
.History  string, description of how the model was generated
.Data  optional, data of estimation
.Algorithm  structure, describing the algorithm and all the settings (not yet
    implemented)
.UserData  user-defined information
-----------------------
'Model' properties
-----------------------
.Variable  | z^-1 | s | w |
.Representation  | polynomial | orthopol |
.Type  This shows the type of representation: 
    SISO for SISO systems
    CD for common denominator (MIMO)
    LMFD for left matrix fraction description (MIMO)
    TFS for a set of individual transfer functions (MIMO)
.num  cell array of numerators (also referred to as 'B')
.denom  cell array of denominators (also referred to as 'A') 
.C  cell array of noise numerators (currently not used)
.D  cell array of denominators (currently not used)
.F  cell array of left polynomials (currently not used)
.Ntr  transient numerator
.Znum  weight vectors of numerator orthogonal polynomial set
.Zdenom  weight vectors of denominator orthogonal polynomial set
.Zntr  weight vectors of transient numerator orthogonal polynomial set
.Freqvect  vector of excitation frequencies; freqlength x channels if
    different for different channels 
.Fs  sampling frequency (in z^(-1)-domain)
.Fscale  suggested scaling frequency (in s- or w-domain), for representation
    'polynomial'; scaling frequency for representation 'orthopol'
.Delay  matrix of delay values for each input/output pair
    for z-domain these are given in taps
.ioDelayMatrix  alternative name of delay
.OutputChNumber  read-only: number of output channels (used for MIMO)
.InputChNumber  read-only: number of input channels (used for MIMO)
.OutputDelay  Output delays (transport delays in the output channels).        
                 Content:  Ny-by-1 vector of time delays for each output.
.InputDelay  Input delays (transport delays in the input channels).        
                 Content:  Nu-by-1 vector of time delays for each input.
.OutputGroup  Groups of output channels.                                    
                 Content:  M-by-2 cell array when M output groups (see ltiprops)
.InputGroup  Groups of input channels.                                     
                 Content:  M-by-2 cell array when M input groups
.OutputName  Output channel names.                                         
                 Content:  Ny-by-1 cell array of strings.
.InputName  Input channel names.                                         
                 Content:  Nu-by-1 cell array of strings.
.OutputUnit  Output channel units
                 Content:  Ny-by-1 cell array of strings.
.InputUnit  Input channel units
                 Content:  Nu-by-1 cell array of strings.
.Covariance  covariance matrix of all coefficients
.FixedPars  fixed parameters
.FitInfo  structure of various fit information
.ErrorWeighting  type of weighting used: 'Linear', 'Nonlinear', or 'Interpolated nonlinear'
.Varet  estimated virtual noise variance (currently not used)
.Info  short information on model

In general, nondefined properties return either
- property if it can be calculated from other properties
- if it cannot be calculated, then either as empty, or if it can be
     misunderstood, as NaN 

Consistency is checked after each command, in order to assure that illegal
data are not generated. Therefore, those settings that require the change of
several properties, should be done in one longer set command.

Available methods are listed by helpc(fidmodel)
