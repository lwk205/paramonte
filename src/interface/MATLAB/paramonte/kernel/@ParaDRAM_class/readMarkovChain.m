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
%   readMarkovChain(file,delimiter)
%
%   Return a list of the contents of a set of the simulation(s) output
%   chain files whose names begin the user-provided prefix, specified,
%   by the input simulation specification pmpd.spec.outputFileName.
%
%   This routine is idential to readChain() method, except that upon reading
%   the output chain files, it will also convert the chains from the default
%   efficient compact format stored in the file to the full verbose Markov
%   chain format.
%
%   WARNING: Avoid using this routine for very large compact chains.
%   Reading the full Markov chain of large-scale simulation problems
%   can be extremely memory-intensive wihtout any potential benefits.
%
%   WARNING: This method is to be only used for post-processing of the output
%   chain file(s) of an already finished simulation. It is NOT meant to be
%   called by all processes in parallel mode, although it is possible.
%
%   Parameters
%   ----------
%
%       file (optional)
%
%           A string representing the path to the chain file with the
%           default value of []. The path only needs to uniquely identify
%           the name of the simulation to which the chain file belongs.
%           For example, specifying "./mydir/mysim" as input will lead to
%           a search for a file that begins with "mysim" and ends with
%           "_chain.txt" inside the directory "./mydir/".
%           If there are multiple files with such name, then all of them
%           will be read and returned as a list.
%           If this input argument is not provided by the user, the
%           value of the object's `spec` attribute `outputFileName`
%           will be used instead.
%           ======================================================
%           WARNING: At least one of the two mentioned routes must
%           provide the path to the chain file. Otherwise,
%           this method will break by calling sys.exit().
%           ======================================================
%
%           Example usage:
%
%               pmpd.readMarkovChain("./out/test_run_");
%
%           or,
%
%               pmpd.spec.outputFileName = "./out/test_run_";
%               pmpd.readMarkovChain();
%
%           Both of the above examples are equivalent.
%           The latter is recommended as it is less confusing.
%
%       delimiter (optional)
%
%           Optional input string representing the delimiter used in the output
%           chain file. If it is not provided as input argument, the value of
%           the corresponding object's `spec` attribute `outputDelimiter`
%           will be used instead. If none of the two are available,
%           the default comma delimiter "," will be assumed and used.
%
%           Example usage:
%
%               pmpd.readMarkovChain("./out/test_run_", " ");
%
%           or,
%
%               pmpd.spec.outputDelimiter = " ";
%               pmpd.readMarkovChain("./out/test_run_");
%
%           or,
%
%               pmpd.spec.outputFileName = "./out/test_run_";
%               pmpd.spec.outputDelimiter = " ";
%               pmpd.readMarkovChain();
%
%           Both of the above examples are equivalent.
%           The latter is recommended as it is less confusing.
%
%   Returns
%   -------
%
%       chainList (optional)
%
%           a cell array of objects, each of which corresponds to the contents
%           of a unique chain file. Each object has the following components:
%
%               file
%                   full absolute path to the chain file.
%
%               delimiter
%                   the delimiter used in the chain file.
%
%               ndim
%                   number of dimensions of the domain of the objective function
%                   for which the chain was generated.
%
%               count
%                   the number of unique (weighted) points in the chain file.
%                   This is essentially the number of rows in the chain file
%                   minus one (representing the header line).
%
%               df
%                   the contents of the chain file in the form of
%                   a MATLAB table (df stands for DataFrame).
%
%           If no output argument is provided, a chainList property will be added
%           to the parent sampler-object to which the method readMarkovChain() belongs.
%           return value of the method. Otherwise, the list will be stored in a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [markovChainList] = readMarkovChain(self,varargin)

    if isempty(self.objectName); self.objectName = inputname(1); end
    callerName = string(mfilename());
    chainType = string(callerName{1}(5:end));
    chainType = string( [ lower(chainType{1}(1)) , chainType{1}(2:end) ] );
    output = chainType + "List";

    if nargout==0
        %if ~any(strcmp(properties(self),output)); self.addprop(output); end
        %self.(output) = self.readOutput(callerName,varargin{:});
        self.readOutput(callerName,varargin{:});
    elseif nargout==1
        %eval(output+" = self.readOutput(callerName,varargin{:})");
        varargout{1} = self.readOutput(callerName,varargin{:});
    else
        self.Err.msg    = "The method, " + self.objectName + "." + callerName + "(file,delimiter)" ...
                        + "optionally outputs one variable (" + output + ") or nothing. If the latter is chosen by the user " ...
                        + "(that is, no output is provivded to the method, " + self.objectName + "." + callerName + "), then the output " + output + ...
                        + " will be instead added as a component of the " + self.object + " object.";
        self.Err.abort();
    end

end