Help of frequency domain identification data objects (fiddata)
Last modified: 13-Apr-2005

FIDDATA Frequency Domain Identification Data Object
Overloaded functions: get, set, field references (obj.field), ==, ~=
  diff(obj1,obj2) lists differences between objects
  check(obj) lists all properties, freqsel(obj) selects frequency range
  plot(obj) make plot
  add objects by experiment: merge(), add by channel: addchannels()
    The channels are concatenated if they have the same (maybe empty) names,
    and they are assumed to be different (MIMO) of their names are different.
      obsolete functionalities eliminated in this version:
      add: [obj1,obj2] (by experiment), [obj1;obj2] (by channel)
Special second argument in set/get: 'ch:<number>' or 'ch:<chname>'
   which refers to the object reduced to the selected channel
Indexing of object: select {channels, experiments}(samples),
   dat{:,3}(indv) works now for objects, it returns a complete but
   reduced object. The three indices: channels, experiments, samples.
   Examples: see get(iddat)
   Indexing compatible with the SYSID Toolbox:
     dat(samples,outputs,inputs,experiments)
Parent: iddat (see help(iddat) for details)
Basic generation: fiddata(y,u,fv), see 'help fiddata'
Maximum length call: fiddata(y,u,freqpoints,vy,vu,cuy,oname,iname,ounit,iunit);

Child properties:
.Version  version
.InputFreqPoints  Frequencies of input amplitudes (vector or cell array)
.OutputFreqPoints  Frequencies of output amplitudes (vector or cell array)
.FreqPoints  Frequencies where I/O amplitudes are given (vector or cell array)
.InputDelay  Delays of different input channels / experiments (vector/array)
.OutputDelay  Delays of different output channels / experiments (vector/array)
.Fs  sampling frequency (scalar)
.InputVariance  Variances of complex input amplitudes
       (vector or cell array - or scalar for constant)
.OutputVariance  Variances of complex output amplitudes
       (vector or cell array - or scalar for constant)
.AllVariances  Cell column vector of all variance vectors
.CovVector  Vector of covariances between complex amplitudes of two channels
        (for more than 2 channels it is only allowed to read/write this for
        selected two channels at a time, like 
        obj(:,o1,i2).covvect=c; or obj{[1,3]}.covvect=c;
.CovarianceMatrix Covariance matrices of complex I/O amplitudes (3-dim array, 3rd
        index: all different freqs in object, or 1 if variances are constant;
        cell array of these for different experiment frequencies or variances)
.M  number of processed experiments (segments) for variance analysis
.InterExpNonlinCovariance: cell array (expn x expn) of cell array (chn  x chn) of cov vectors
        The main diagonal is empty - this would contain the usual covariance matrix
        The lower triangle is also empty (this would be the complex conjugate)
.InputNonlinError  Nonlinear error squares of complex input amplitudes
       (vector or cell array - or scalar for constant)
.OutputNonlinError  Nonlinear error squares of complex output amplitudes
       (vector or cell array - or scalar for constant)
.InputNonlinVariance  Nonlinear "variances" of complex input amplitudes
       (vector or cell array - or scalar for constant)
         Equals to .InputNonlinError/nonlinM
.OutputNonlinVariance  Nonlinear "variances" of complex output amplitudes
       (vector or cell array - or scalar for constant)
         Equals to OutputNonlinError/nonlinM
.NonlinCovVector  Vector of "nonlinear covariances" between complex amplitudes of two channels
        (for more than 2 channels it is only allowed to read/write this for
        selected two channels at a time)
.NonlinCovarianceMatrix "Nonlinear covariance" matrices of complex I/O amplitudes (3-dim array, 3rd
        index: all different freqs in object, or 1 if variances are constant;
        cell array of these for different experiment frequencies or variances)
.NonlinM  number of processed experiments (segments) for "nonlinear variance" analysis
.EvenOutputNonlinError  Output errors interpolated from nonexcited even lines 
.Coherence  Coherence between inputs/outputs (3-dim array, 3rd index:
        all different freqs in object;
        cell array of these for different experiment frequencies or coherences)
.CohVector  Vector of coherences between two channels
        (for more than 2 channels it is only allowed to read/write this for
        selected two channels at a time)
.AllFreqPoints  combination of all frequency points; length same as of
        Covariance or Coherence for each experiment (read-only)
.N  Number of points in the time domain (before FFT)
.FreqNumber  Number of frequency points
.Type  Data representation (FRF, input-output, I/O, default: input-output)
.Speciality  Data may need special handling (e.g. NMR)
.SisoVariance  Combined [OutputVariance,InputVariance,CovVector] for SISO
Further, parent properties are all inherited, see help(iddat)

Handling functions:
   set(obj,'ch:1,3','CovVector',vect) %set covariances between two channels
   allfpi(obj,1,3) %get frequency indices to get channel frequencies from
      AllFreqPoints
   collapse(obj) %combine results of experiments to one

In general, nonexistent (empty) properties return as empty scalar or string.

Consistency is checked after each command, in order to assure that illegal
data are not generated. Therefore, those settings that require the change of
several properties, should be done in one 'set' command.
However, several settings (like the setting of a channel name) generate
empty strings for the names of the other channels, and thus cause no error
message.

Setting of FreqPoints clears the Covariance property, thus setting of the
Covariance must be later than setting of FreqPoints.

Available methods are listed by helpc(fiddata)
