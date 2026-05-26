Help on time domain identification data objects (tiddata)
Last Modified: 12-Aug-2002

TIDDATA Time Domain Identification Data Object
Overloaded functions: get, set, field references (obj.field), ==, ~=
  obj1 + obj2 (concatenate samples)
  diff(obj1,obj2) lists differences between objects
  check(obj) lists all properties
  plot(obj) make plot
  add objects by experiment: merge(), add by channel: addchannels()
     obsolete functionalities eliminated in this version:
     add: [obj1,obj2] (by experiment), [obj1;obj2] (by channel)
Special second argument in set/get: 'ch:<number>' or 'ch:<chname>'
   which refers to the object reduced to the selected channel
Indexing of object: select {channels, experiments}(sample places: time or freq),
   dat{:,3}(indv) works now for objects, it returns a complete but
   reduced object. The three indices: channels, experiments, samples.
   Examples: see get(iddat)
   Indexing compatible with the SYSID Toolbox:
     dat(indv,outputs,inputs,experiments)
Parent: iddat (see help(iddat) for details)
Basic generation: tiddata(y,u,Ts), or longer, see 'help tiddata'
Maximum length call: tiddata(y,u,Ts,oname,iname,ounit,iunit);

Properties:
.Version  version
.Ts  sampling interval, scalar or 1 x expno cell array
.TStart  start times of sampling, scalar or cell array
.InputTStart  start times of sampling, scalar or cell array
.OutputTStart  start times of sampling, scalar or cell array
.SampleInstants  vector (or cell array) of sampling instants
.InputSampleInstants  vector (or cell array) of sampling instants
.OutputSampleInstants  vector (or cell array) of sampling instants
.OutputVariance  scalar or cell: variance of white noise for each output channel
.InputVariance  scalar or cell: variance of white noise for each input channel
Further, parent properties are all inherited, see help(iddat)

In general, nonexistent (empty) properties return as empty scalar or string.

Consistency is checked after each command, in order to assure that illegal
data are not generated. Therefore, those settings that require the change of
several properties, should be done in one 'set' command.
However, several settings (like the setting of a channel name) generate
empty strings for the names of the other channels, and thus cause no error
message.

Available methods are listed by helpc(tiddata)
