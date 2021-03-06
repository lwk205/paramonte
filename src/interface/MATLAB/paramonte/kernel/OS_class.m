%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   ParaMonte: plain powerful parallel Monte Carlo library.
%
%   Copyright (C) 2012-present, The Computational Data Science Lab
%
%   This file is part of the ParaMonte library.
%
%   ParaMonte is free software: you can redistribute it and/or modify it 
%   under the terms of the GNU Lesser General Public License as published 
%   by the Free Software Foundation, version 3 of the License.
%
%   ParaMonte is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%   GNU Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public License
%   along with the ParaMonte library. If not, see, 
%
%       https://github.com/cdslaborg/paramonte/blob/master/LICENSE
%
%   ACKNOWLEDGMENT
%
%   As per the ParaMonte library license agreement terms, 
%   if you use any parts of this library for any purposes, 
%   we ask you to acknowledge the use of the ParaMonte library
%   in your work (education/research/industry/development/...)
%   by citing the ParaMonte library as described on this page:
%
%       https://github.com/cdslaborg/paramonte/blob/master/ACKNOWLEDGMENT.md
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
classdef OS_class < handle

    properties (Constant)
        CLASS_NAME  = "@OS_class"
    end

    properties
        name        = []
        slash       = []
        isWindows   = false
        Err         = Err_class()
    end

%***********************************************************************************************************************************
%***********************************************************************************************************************************

    methods (Access = public)
    
    %*******************************************************************************************************************************
    %*******************************************************************************************************************************

        function queryOS(self)
            
            FUNCTION_NAME       = self.CLASS_NAME + "@queryOS()";
            
            self.Err.occurred   = false;
            self.Err.msg        = "";

            if ispc
                self.name           = "WINDOWS";
                self.isWindows      = true;
                self.slash          = '\';
            elseif ismac
                self.name           = "MAC";
                self.isWindows      = false;
                self.slash          = "/";
            elseif isunix 
                self.name           = "UNIX";
                self.isWindows      = false;
                self.slash          = "/";
            else
                self.name           = "";
                self.isWindows      = false;
                self.Err.occurred   = false;
                self.Err.msg        = FUNCTION_NAME + ": Unknown error occurred while attempting to read the Operating System's name";
            end



            
            % [self.name, self.Err]   = EnvVar_class.getEnvVar("OS");
            
            % if self.Err.occurred
                % self.Err.msg    = FUNCTION_NAME + ": Error occurred while querying OS type." + newline + self.Err.msg;
                % self.name       = "";
                % return
            % end
            
            % self.name       = strtrim(self.name);
            
            % if length(self.name) >= 7
                % if lower(self.name(1:7)) == "windows"
                    % self.isWindows  = true;
                    % self.slash      = "\";
                % end
            % else % it's either Linux- or Darwin- based OS
            
                % self.isWindows  = false;
                % self.slash      = "/";
                
                % RFN = RandomFileName_class([],"queryOS",[]);
                % if RFN.Err.occurred
                    % self.Err        = RFN.Err;
                    % self.Err.msg    = FUNCTION_NAME + ": Error occurred while inquiring OS type." + newline + self.Err.msg;
                    % self.name = "";
                    % return
                % end
                
                % [self.Err.occured, self.Err.msg] = system("uname > " + RFN.path);
                % if self.Err.occurred
                    % self.Err.msg    = FUNCTION_NAME + ": Error occurred while executing command 'uname > " + RFN.path + "'." + newline...
                                    % + self.Err.msg;
                    % self.name       = "";
                    % return
                % end
                
                % [fid, self.Err.msg] = fopen("RFN.path","r");
                % if fid > 2
                    % self.Err.occurred = true;
                    % self.Err.msg    = FUNCTION_NAME + ": Error occurred while opening file = '" + RFN.path + "'." + newline...
                                    % + self.Err.msg;
                    % OS.name = "";
                    % return
                % end
                
            % %%%%%%%%%%%     UNFINISHED CODE     %%%%%%%%%%%%
                
            % end
            
            % self.name = strtrim(self.name);
            
        end

    %*******************************************************************************************************************************
    %*******************************************************************************************************************************

    end

%***********************************************************************************************************************************
%***********************************************************************************************************************************

end