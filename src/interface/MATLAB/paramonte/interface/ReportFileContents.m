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
%   This is the ReportFileContents class for generating instances 
%   of ParaMonte output report file contents. The ParaMonte readReport method
%   returns an object or a list of objects of class ReportFileContents.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
classdef ReportFileContents < OutputFileContents

    properties(Access = public)
        contents = [];
        setup = struct();
        stats = struct();
        spec = struct();
    end

    properties(Hidden)
        lineList = [];
        lineListLen = [];
        dsym = '****'; % decoration symbol
        lineCounter;
        prefix;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods (Access = public)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function self = ReportFileContents  ( file ...
                                            , methodName ...
                                            , mpiEnabled ...
                                            , Err ...
                                            )

            self = self@OutputFileContents(file,methodName,mpiEnabled,Err);
            self.timer.tic();

            self.prefix = convertStringsToChars(self.methodName + " - NOTE:");

            if ispc
                self.contents = fileread(file);
            else
                self.contents = strrep(fileread(file),char(13),'');
            end
            self.lineList = strsplit(self.contents,newline); % strtrim()
            self.lineListLen = length(self.lineList);

            self.updateUser("parsing the report file contents...");

            self.lineCounter  = 0;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% read the banner
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            lineStartFound = false;
            while true
                self.lineCounter = self.lineCounter + 1; if self.lineCounter==self.lineListLen; break; end
                record = self.lineList{self.lineCounter};
                if lineStartFound
                    if ~contains(record,self.dsym)
                        self.lineCounter = self.lineCounter - 1;
                        break
                    end
                else
                    if contains(record,self.dsym)
                        lineStartFound = true;
                        lineStart = self.lineCounter;
                    end
                end
            end
            if lineStartFound
                self.setup.library.banner = self.concat(lineStart,self.lineCounter);
            else
                self.reportParseFailure("ParaMonte banner");
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% read the ParaMonte library interface specifications
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            self.setup.library.interface = self.parseSection("ParaMonte library interface specifications");

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% read the Runtime platform specifications
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            self.setup.platform = self.parseSection("Runtime platform specifications");

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% read the simulation environment
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            self.setup.io = self.parseSection("simulation environment");

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% read the simulation environment
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            self.spec = self.parseSection("simulation specifications");

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% statistics: this must be always the last item to parse
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            self.parseStats();

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            self.updateUser([]);

        end % constructor

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function helpme(self,varargin)
            %
            %   Open the documentation for the input object's name in string format, otherwise, 
            %   open the documentation page for the class of the object owning the helpme() method.
            %
            %   Parameters
            %   ----------
            %
            %       This function takes at most one string argument, 
            %       which is the name of the object for which help is needed.
            %
            %   Returns
            %   -------
            %
            %       None. 
            %
            %   Example
            %   -------
            %
            %       helpme("plot")
            %
            methodNotFound = true;
            if nargin==2
                if strcmpi(varargin{1},"reset")
                    cmd = "doc self.resetPlot";
                    methodNotFound = false;
                else
                    methodList = ["plot","helpme"];
                    for method = methodList
                        if strcmpi(varargin{1},method)
                            methodNotFound = false;
                            cmd = "doc self." + method;
                        end
                    end
                end
            elseif nargin~=1
                error("The helpme() method takes at most one argument that must be string.");
            end
            if methodNotFound
                cmd = "doc self";
            end
            eval(cmd);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end % methods (Access = public)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods(Hidden)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function reportParseFailure(self,topic)
            self.Err.msg = "failed to parse the " + topic + ". This is highly unusual. Skipping... "; 
            self.Err.warn();
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function section = parseSection(self,topic)
            section = [];
            lineStartFound = false;
            while true
                self.lineCounter = self.lineCounter + 1; if self.lineCounter==self.lineListLen; break; end
                record = self.lineList{self.lineCounter};
                if lineStartFound
                    if contains(record,self.dsym)
                        self.lineCounter = self.lineCounter - 1;
                        break
                    end
                else
                    if contains(record,topic)
                        lineStartFound = true;
                        self.lineCounter = self.lineCounter + 3;
                        lineStart = self.lineCounter;
                    end
                end
            end
            if lineStartFound
                section = self.concat(lineStart,self.lineCounter);
            else
                self.reportParseFailure(topic);
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function concatatedString = concat(self,lineStart,lineCounter)
            concatatedString = self.lineList(lineStart:lineCounter);
            %concatatedString = concatatedString(~cellfun('isempty',concatatedString));
            concatatedString = string(join(concatatedString,newline));
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function stats = parseStats(self)
            if strcmp(self.methodName,"ParaDRAM")
                while true
                    self.lineCounter = self.lineCounter + 1; if self.lineCounter>self.lineListLen; break; end
                    record = self.lineList{self.lineCounter};
                    if length(record)>5 && strcmp(record(1:6),'stats.')
                        self.lineCounter = self.lineCounter + 2; % assumes the value starts two rows after item
                        valueIsNumeric = true;
                        valueStart = self.lineCounter;
                        value = '';
                        while true
                            if length(self.lineList{self.lineCounter})>8
                                dummy = strrep(self.lineList{self.lineCounter},newline,' ');
                                dummy = strrep(self.lineList{self.lineCounter},char(13),' ');
                                value = [value, dummy];
                                if isempty(str2num(dummy))
                                    valueIsNumeric = false;
                                end
                                self.lineCounter = self.lineCounter + 1; if self.lineCounter>self.lineListLen; break; end
                            else
                                valueEnd = self.lineCounter - 1;
                                break;
                            end
                        end
                        desc = '';
                        while true
                            self.lineCounter = self.lineCounter + 1; if self.lineCounter>self.lineListLen; break; end
                            if length(self.lineList{self.lineCounter})>8 && contains(self.lineList{self.lineCounter},self.prefix)
                                dummy = strrep(self.lineList{self.lineCounter},newline,' ');
                                dummy = strrep(self.lineList{self.lineCounter},char(13),' ');
                                dummy = strrep(self.lineList{self.lineCounter},self.prefix,' ');
                                desc = [desc, ' ', strtrim(dummy)];
                            else
                                break;
                            end
                        end
                        if valueIsNumeric
                            value = ['[',value,']'];
                            %value = strsplit(join(strtrim(self.lineList(valueStart:valueEnd)),' '));
                            %value = value(~cellfun('isempty',value));
                            eval(['self.',strtrim(record),'.value=',value,';']);
                            eval(['self.',strtrim(record),'.description="',strtrim(desc),'";']);
                            %valueStart = self.lineCounter;
                        %else
                        %    value = [];
                        %    for i = valueStart:valueEnd
                        %        value = [value, self.lineList{i}, newline];
                        %    end
                        %    value = ['''', value, ''''];
                        %    disp(['self.',strtrim(record),'.value=''',value,''';']);
                        %    eval(['self.',strtrim(record),'.value=''',value,''';']);
                        end
                    end
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end % methods (Access = public)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end % classdef ReportFileContents < handle