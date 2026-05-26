%Help on Export/Import Data: Saving models
% 
%    The end results can be saved either by selecting the File/Save menu of any 
%    of the last three blocks, or by double-clicking on an arrow containing a 
%    model or a set of models. Remark: model saving is not accessible in trial 
%    versions, but otherwise the toolbox is fully functional for trial.
% 
%    The saved variable is a fidmodel object. Its properties contain all 
%    important information about the model. If the name of the variable is 
%    "modobj", for a list of the properties, issue "get(modobj)" or 
%    "help(fidmodel)", and get the value of a property as e.g. numv=modobj.num. 
%    Another possibility is to use the command "exppar(object,filename)" in the 
%    command window to generate an ASCII file with the most important model 
%    data.
% 
%    Study the structure of the object and the exact meaning of each property 
%    carefully, because the meaning of properties may slightly change in 
%    certain cases. For example, for orthogonal representation, the 
%    coefficients of the transfer function numerator and denominator are not 
%    accessible, only the coefficients of the orthogonal polynomials. However, 
%    functions like "info(modobj)", "pole(modobj)", "plot(modobj)", 
%    "plotpz(modobj)", "tfcalc(modobj,freqv)" etc. take care of these 
%    differences automatically, so use the objects primarily in the toolbox 
%    functions, or transform them to the Control System Toolbox by 
%    "tf(modobj)", ss(modobj)", etc.
% 
%    A model set is an array of fidmodel objects. If necessary, models or model 
%    arrays can be united into a model array as in the command lines:
% 
%    arr1 = [model1,model2]; %create model array
%    arr2 = [arr1,model3];
%    model_array = [arr1,arr2]; %concatenation of arrays
% 
%    In the above examples, model<i> denotes a fidmodel object.
% 
%    Other topics are also available, use the Topics menu.