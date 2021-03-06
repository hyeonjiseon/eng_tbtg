function [structureChanged,varargin] = addNewParam(structureToChange,field,defaultValue,paramDescription,paramType,fileCfg,varargin)
% Function to create a new parameter

% ==============
% Copyright (C) Alessandro Bazzi, University of Bologna, and Alberto Zanella, CNR
% 
% All rights reserved.
% 
% Permission to use, copy, modify, and distribute this software for any 
% purpose without fee is hereby granted, provided that this entire notice 
% is included in all copies of any software which is or includes a copy or 
% modification of this software and in all copies of the supporting 
% documentation for such software.
% 
% THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED 
% WARRANTY. IN PARTICULAR, NEITHER OF THE AUTHORS MAKES ANY REPRESENTATION 
% OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY OF THIS SOFTWARE 
% OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
% 
% Project: LTEV2Vsim
% ==============

sourceForValue = 0; % 0: default
value = defaultValue;
valueInCfg = searchParamInCfgFile(fileCfg,field,paramType);
if valueInCfg ~= -1
    value = valueInCfg;
    sourceForValue = 1; % 1: file config
end
for i=1:(length(varargin{1}))/2
    if strcmpi(char(varargin{1,1}(2*i-1)),field)
        value = cell2mat(varargin{1,1}(2*i));
        sourceForValue = 2; % 2: command line
        % I remove this parameter and value from varargin
        % This allows to check that all parameters are correctly given in
        % input
        varargin{1}(2*i-1) = [];
        varargin{1}(2*i-1) = [];
        break;
    end
end

% Print to command window
fprintf('%s:\t',paramDescription);
fprintf('[%s] = ',field);
if strcmpi(paramType,'integer')
    if ~isnumeric(value) || mod(value,1)~=0
        error('Error: parameter %s must be an integer.',field);
    end
    fprintf('%.0f ',value);
elseif strcmpi(paramType,'double')
    if ~isnumeric(value)
        error('Error: parameter %s must be a number.',field);
    end
    fprintf('%f ',value);
elseif strcmpi(paramType,'string')
    if ~ischar(value)
        error('Error: parameter %s must be a string.',field);
    end
    fprintf('%s ',value);
elseif strcmpi(paramType,'bool')    
    if ~islogical(value)
        error('Error: parameter %s must be a boolean.',field);
    end
    if value == true
        fprintf('true ');
    else
        fprintf('false ');
    end
elseif strcmpi(paramType,'integerOrArrayString') 
    if ischar(value)
        value = str2num(value);
    end    
    for iValue=1:length(value)
        if ~isnumeric(value(iValue)) || mod(value(iValue),1)~=0
            error('Error: parameter %s must be an integer or a string with integers.',field);
        end
        if iValue>1
            fprintf(',');
        end
        fprintf('%.0f',value(iValue));
    end
    fprintf(' ');
else
    error('Error in addNewParam: paramType can be only integer, double, string, or bool.');
end
if sourceForValue==0
    fprintf('(default)\n');
elseif sourceForValue==1
    fprintf('(file %s)\n',fileCfg);
else
    fprintf('(command line)\n');
end
structureChanged = setfield(structureToChange,field,value);
    

