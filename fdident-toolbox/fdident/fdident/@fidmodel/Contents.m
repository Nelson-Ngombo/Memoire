% Identification toolboxes - fidmodel class directory
% Version 2.2, 2-Apr-2006
%
% Class directory functions
%   addhist     - Add history string to existing ones of object
%   best        - Return best model from set
%   bode        - Bode diagram of model
%   check       - List all properties of object for quick test
%   cloud       - Generate scattered object set from covariance
%   crossval    - Perform cross validation calculation
%   c2d         - Continuous to discrete time conversion
%   d2c         - Discrete to continuous time conversion
%   display     - Pretty-print fidmodel object
%   diff        - List different properties of two models
%   get         - Get property(ties) of fidmodel object
%   eq          - Overloaded method == to compare two models
%   export      - Make a structure for exchange of data with people not using fdident
%   fidmodel    - Creator function
%   fidmodelh   - Detailed text on class
%   get         - Obtain property value of object
%   help        - Detailed textual help to class fidmodel
%   helpc       - Type out Contents.m of class directory
%   horzcat     - Concatenate models to MIMO by input channels
%   idmodel     - Convert object to class idpoly (rather than idmodel) of the ident toolbox
%   idpoly      - Convert object to class idpoly of the ident toolbox
%   idpvpget    - Expand property names or return set of properties
%   idpvpstr    - Quickly expand property names or return set of properties
%   impulse     - Plot impulse response of object
%   info        - Textual information on fit of model to data
%   insertdata  - Add data and fitinfo to model
%   inv         - Implement 1/idmod
%   issiso      - True for SISO fidmodel objects
%   isstable    - Test stability of object
%   minus       - Overloaded method - to subtract model tf's (models in parallel)
%   mrdivide    - Evaluate expressions of type const/object and object/const
%   msotalerr   - Calculate mean square of errors
%   mtimes      - Overloaded method * to multiply object with scalar or with object
%   ne          - Overloaded method ~= to compare two models
%   nichols     - Plot Nichols diagram of object
%   nyquist     - Plot Nyquist diagram of object
%   order       - Order(s) of object
%   plot        - Plot model (maybe along with fiddata object)
%   plotdelays  - Plot cost functions and delays of models
%   plotpz      - Plot pole/zero pattern of model, with confidence ellipses
%   plus        - Overloaded method + to add model tf's (connect models in parallel)
%   pole        - Calculate poles of fidmodel object
%   pzcancel    - Cancel poles/zeros (if possible)
%   pzmap       - Plot poles/zeros of fidmodel object through @lti/pzmap
%   recalculate - Recalculate model with given errors or with residuals of model
%   rmpz        - Remove poles/zeros from model
%   set         - Set property(ties) of fidmodel object
%   shprops     - Display properties (used with get)
%   size        - Size and order of fidmodel objects
%   ss          - Convert object to class ss of control toolbox
%   stable      - Stabilize model object
%   stack       - Stack fidmodel objects into fidmodel array
%   step        - Plot step response of object
%   subsasgn    - Define overloaded subscripted assigning of subfields
%   subsref     - Define overloaded subscripting
%   tf          - Convert object to class tf of control toolbox
%   theta       - Convert object to theta format (System Identification Toolbox)
%   vertcat     - Concatenate models to MIMO by output channels
%   zero        - Calculate (transmission) zeros of fidmodel object
%   zpk         - Convert object to class zpk of control toolbox
%
% Other utilities:
%   help fdident

% Copyright (c) I. Kollar and Vrije Universiteit Brussel, ELEC, 1998-2002
% All rights reserved.
% $Revision: $
