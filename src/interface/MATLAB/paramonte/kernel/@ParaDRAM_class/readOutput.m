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
function varargout = readOutput(self,varargin) % callerName,file,delimiter

    if isempty(self.objectName); self.objectName = inputname(1); end

    self.Err.marginTop = 0;

    file = [];
    delimiter = [];
    errorOccurred = false;
    markovChainRequested = false;
    if nargin==1; errorOccurred = true; end
    if nargin>1
        callerName = varargin{1};
        if strcmp(callerName,"readChain")
            fileType = "chain";
        elseif strcmp(callerName,"readSample")
            fileType = "sample";
        elseif strcmp(callerName,"readMarkovChain")
            fileType = "chain";
            markovChainRequested = true;
        end
    end
    if nargin>2; file = convertStringsToChars(varargin{2}); end
    if nargin>3; delimiter = varargin{3}; end
    if nargin>4 || errorOccurred
        self.Err.msg    = callerName + "takes only two input arguments (file, delimiter). Correct usage:" + newline + newline ...
                        + "    " + callerName + "(file,delimiter)" + newline + newline ...
                        + "where ""file"" is the name of the file to be read, delimiter is the delimiter used in the file,";
        self.Err.abort();
    end

    if isempty(file)
        if isempty(self.spec.outputFileName)
            self.Err.msg    = "The " + self.methodName + " input simulation specification " + self.objectName + ".spec.outputFileName is not set. " ...
                            + "This information is essential, otherwise how could the output files be found? " ...
                            + "All that is needed is the common section of the paths to the output simulation files (including the simulation name) " ...
                            + "or simply, the path to the " + fileType + " file.";
            if ~isempty(self.inputFile)
                self.Err.msg    = self.Err.msg + newline ...
                                + "Apparently, you have specified an input file for the simulation via the attribute """ + self.objectName + ".inputFile""." + newline ...
                                + "Extract the value of outputFileName from this file, and assign it to the simulation specification """ + self.objectName + ".spec.outputFileName"".";
            end
            self.Err.abort();
        else
            file = string(self.spec.outputFileName);
        end
    else
        file = string(file);
    end

    if isempty(delimiter)
        if isempty(self.spec.outputDelimiter)
            delimiter = ',';
            if ~self.mpiEnabled
                self.Err.msg    = "The " + self.methodName + " input simulation specification " + self.objectName + ".spec.outputDelimiter is not set." + newline ...
                                + "This information is essential for successful reading of the requested " + fileType + " file(s)." + newline ...
                                + "Proceeding with the default assumption of comma-delimited " + fileType + " file contents...";
                self.Err.warn();
            end
        else
            delimiter = string(self.spec.outputDelimiter);
        end
    else
        delimiter = string(delimiter);
    end

    fileList = self.getFileList(file,fileType);
    fileListLen = length(fileList);

    outputList = cell(fileListLen,1);
    for ifile = fileListLen:-1:1
        filePathModified = string( strrep(fileList(ifile),'\','\\') );
        if ~self.mpiEnabled
            self.Err.msg = "processing file: " + filePathModified;
            self.Err.marginTop = 1;
            self.Err.marginBot = 0;
            self.Err.note();
        end
        outputList{ifile} = OutputFileContents  ( filePathModified ...
                                                , fileType ...
                                                , delimiter ...
                                                , self.methodName ...
                                                , self.mpiEnabled ...
                                                , markovChainRequested ...
                                                , self.Err ...
                                                );
    end

    if nargout==0
        dummy = fileType; if contains(lower(callerName),"markov"); dummy = "markovChain"; end
        outputListName = dummy + "List"; 
        outputListFullName = self.objectName + "." + outputListName;
        prop=outputListName; if ~any(strcmp(properties(self),prop)); self.addprop(prop); end
        self.(outputListName) = outputList;
        self.Err.msg    = "The processed " + fileType + " file(s) are now stored in the newly-created component """ + outputListFullName + """ of the " + self.methodName + " object as a cell array. " ...
                        + "For example, to access the contents of the first (or the only) " + fileType + " file, try:";
    elseif nargout==1
        varargout{1} = outputList;
        outputListFullName = "OUTPUT_CELL_ARRAY";
        self.Err.msg    = "The processed " + fileType + " file(s) are now stored in the output variable as a cell array. " ...
                        + "For example, to access the contents of the first (or the only) " + fileType + " file stored in an output variable named " ...
                        + outputListFullName + ", try:";
    end

    if ~self.mpiEnabled
        self.Err.marginTop = 1;
        self.Err.marginBot = 1;
        self.Err.msg    = self.Err.msg ...
                        + newline + newline ...
                        + "    " + outputListFullName + "{1}.df" + newline + newline ...
                        + "To access the plotting tools, try:" + newline + newline ...
                        + "    " + outputListFullName + "{1}.plot.<PRESS TAB TO SEE THE LIST OF PLOTS>" + newline + newline ...
                        + "For example," + newline + newline ...
                        + "    " + outputListFullName + "{1}.plot.line.plot()           %% to make bivariate line plots." + newline ...
                        + "    " + outputListFullName + "{1}.plot.scatter.plot()        %% to make bivariate scatter plots." + newline ...
                        + "    " + outputListFullName + "{1}.plot.lineScatter.plot()    %% to make bivariate line-scatter plots." + newline ...
                        + "    " + outputListFullName + "{1}.plot.line3.plot()          %% to make trivariate line plots." + newline ...
                        + "    " + outputListFullName + "{1}.plot.scatter3.plot()       %% to make trivariate scatter plots." + newline ...
                        + "    " + outputListFullName + "{1}.plot.lineScatter3.plot()   %% to make trivariate line-scatter plots." + newline ...
                        + "    " + outputListFullName + "{1}.plot.contour3.plot()       %% to make 3D kernel-density contour plots." + newline ...
                        + "    " + outputListFullName + "{1}.plot.contourf.plot()       %% to make 2D kernel-density filled-contour plots." + newline ...
                        + "    " + outputListFullName + "{1}.plot.contour.plot()        %% to make 2D kernel-density plots." + newline ...
                        + "    " + outputListFullName + "{1}.plot.histogram2.plot()     %% to make bivariate histograms." + newline ...
                        + "    " + outputListFullName + "{1}.plot.histogram.plot()      %% to make univariate histograms." + newline ...
                        + "    " + outputListFullName + "{1}.plot.grid.plot()           %% to make GridPlot" + newline + newline ...
                        + "To plot or inspect the variable autocorrelations or the correlation/covariance matrices, try:" + newline + newline ...
                        + "    " + outputListFullName + "{1}.stats.<PRESS TAB TO SEE THE LIST OF COMPONENTS>" + newline + newline ...
                        + "For more information and examples on the usage, visit:" + newline + newline ...
                        + "    " + self.website.home.url;
        self.Err.note();
    end

end
