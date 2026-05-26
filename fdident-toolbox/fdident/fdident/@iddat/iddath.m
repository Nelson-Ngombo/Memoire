Specification of the parent object for the
  time/frequency domain identification data objects for fdident
Do not use this object directly, only its children (tiddata, fiddata)
Dec. 21, 2003

IDDAT Identification Data Object, Version 1.2
Overloaded functions: get, set, field references (obj.field), ==, ~=
  obj1 + obj2 (concatenate samples)
  diff(obj1,obj2) lists differences between objects
  check(obj) lists all properties
  ELIMINATED IN THIS VERSION:
     add: [obj1,obj2] (by experiment), [obj1;obj2] (by channel)
     use instead: merge(), addchannels()
Special second argument in set/get: 'ch:<number>' or 'ch:<chname>'
   which refers to the object reduced to the selected channel
Indexing of object: select {channels, experiments}(sample places: time or freq),
   dat{:,3}(indv) works now for objects, it returns a complete but
   reduced object. The three indices: channels, experiments, samples.
   Indexing compatible with the SYSID Toolbox:
     dat(indv,outputs,inputs,experiments)

Examples: 
obje{:,2}; %object with all channels but only experiment 2
objc{2}; %channel #2 (see channel number by t.info)
obje{2,1}; %object with channel 2 and experiment 1
obj2=obje{:,1}; %one-experiment object
obje{:,2}=obj2; %replace exp 2 by data in one-experiment object obj2
obj{1}=[]; %delete channel #1
obj{1}(1:2); %select channels/samples
obj{1}(2:3).input %return property of selected object
obje{:,2}=[]; %delete experiment #2
set(obj,'ch:2','Input',randn(1,5)); %replace 2nd channel (or add new one)

Properties:
.Name  string, name of the experiment (e.g. for plots)
.Version  version number, e.g. 1.0 to allow proper handling of earlier versions
.Date  string, date and time of measurement or construction 
.Notes  string, textual information provided by the constructor
.History  string or cell array of strings, description of what happened
   to the data until now - addhist adds to it a new line.
.Instrumentation  information about the instruments, settings, etc. (struct)
.Userdata  user-defined information

.Input  Input array, {channels} x (samples). For multiple experiments, it is a
        2D cell array of arrays. Sample series are column vectors.
.u  Same as Input
.Output  Output array, {channels} x (samples). For multiple experiments, it is a
        2D cell array of arrays. Sample series are column vectors.
.y  Same as Output
.InputName  String or cell array of strings: name(s) of input channel(s),
        dimensions: nu x 1
.OutputName  String or cell array of strings: name(s) of output channel(s),
        dimensions ny x 1
.ExperimentName  String or cell array of strings: name(s) of experiment(s)
.InputCharacter cell array of strings, 'ZOH', 'ZOHf', 'FOH', 'BL', 'Samples', or 'Discrete'
     ZOH: zero order hold, 
     ZOHf: zero order hold with lowpass filtering afterwards,
     FOH: first order hold, 
     BL: bandlimited: samples taken from the input signal with antialias filter on, 
        these denote way of generating input signal from samples
     Samples: samples taken from input signal, 
     Discrete: discrete samples for stimulation of a discree system
.OutputCharacter: cell array of strings, 'Samples', 'BL', or 'Discrete'
.InputUnit  cell array of strings: physical unit names
.OutputUnit  cell array of strings: physical unit names
.InputScale  scaling factor for economic storage (hidden property,
      automatically taken into account when reading data). vector.
.OutputScale  scaling factor for economic storage (hidden property,
      automatically taken into account when reading data). vector.
.ReferenceData  Cell array of excitation signals for each experiment and each input channel 
      for synchronization purposes
.Groups_Synchronized  Group of synchronized experiments
.Groups_Delayed  Group of experiments with the same excitation, but measurements not triggered
      from the same instant of the excitation
.Groups_FullMIMO  Group of experiments with full MIMO excitation (linear combinations
      of the experiments give SISO data for each transfer function element)
.Groups_SamePower  Group of experiments with the same power spectrum, but different phases
 In the above groups, the data are cell arrays, Gx1 or Gx2
   In the first column, the groups are given, in either way:
      - vector of experiment indices
      - cell array of references to experiments: names (ExperimentName) or group names or 
        generic names
   In the second, optional column the group names can be given.
   Generic names:
      experiments: 'e(1)', 'e(2)', ...
      groups: 's(1)', 's(2)', ..., 'd(1)', 'd(2)',  ..., 'm(1)', 'm(2)',..., 'p(1)', 'p(2)', ...
      The constructs 's(2:4)' and 'e(3:end)' are also valid.
   The generic names are forbidden to be used as explicit names, to avoid confusion.
   See help(obj,'groups') for more detail
.Groups  (read-only) list all groups in a model
-------------
.PeriodLength  If positive number, period length. If Inf, the related
     properties (below) are neglected in get, set etc. If NaN, then possibly
     periodic data, the frequency vector contains the information.
.InputFrequencies  Vector of frequencies in periodic signal; cell array of 
     vectors if different for different channels
.OutputFrequencies  Vector of frequencies in periodic signal; cell array of 
     vectors if different for different channels
.State  string, 'steady-state' or 'transient'
.Synchronization  string, 'on', 'delayed' (can be synchronized), 'samepower' (same power, that is,
     same amplitudes, but different phases), 'mimo' (parts of full mimo experiment), or 'off'
     Setting of this propery affects the groups (see above), and vice versa.
--------------
.Info  read-only: textual description of channels
.OutputChNumber  read-only: number of output channels (used for MIMO)
.InputChNumber  read-only: number of input channels (used for MIMO)
.ChNumber  only output: total number of channels
.ExpNumber  only output: number of experiments
.SampleNumber (tiddata)  only output: number of samples
.FreqNumber (fiddata)  only output: number of frequency points
.Data  only output: all channel data
.ChTypes  (hidden) types of channels ('i'+0 or 'o'+0), change using function setchio
.Characters  (hidden) characters of all channels

If new data are defined, put the definition of the data before the definition
of other properties, to avoid possible inconsistencies.

If a property is e.g. a cell array of strings for several strings, for
simplicity a simple string is returned when it is only one string.
This allows easier use, but needs extra care in the use. 
In general, nonexistent (empty) data return as empty scalar or string.

Consistency is checked after each command, in order to assure that illegal
data are not generated. Therefore, those settings that require the change of
several properties, should be done in one 'set' command.
However, several settings (like the setting of a channel name) generate
empty strings for the names of the other channels, and thus cause no error
message.

If setting changes the number of channels or experiments, first set Input
or Output, then the other properties.
