classdef BasePlot < dynamicprops

    %*******************************************************************************************************************************
    %*******************************************************************************************************************************

    properties (Access = public)

        rows
        gca_kws
        gcf_kws
        legend_kws
        currentFig
        outputFile

    end

    properties (Access = protected, Hidden)
        dfref = [];
        isdryrun = [];
    end

    %*******************************************************************************************************************************
    %*******************************************************************************************************************************

    methods (Access = public)

        %***************************************************************************************************************************
        %***************************************************************************************************************************

        function self = BasePlot(varargin)

            try
                self.dfref = varargin{1};
            catch
                self.dfref = [];
            end
            %self.reset();

        end

        %***************************************************************************************************************************
        %***************************************************************************************************************************

        function exportFig(self,varargin)

            set(0, "CurrentFigure", self.currentFig.gcf);
            if any(contains(string(varargin),"-transparent"))
                transparencyRequested = true;
                set(self.currentFig.gcf,"color","none");
                set(gca,"color","none");
            else
                transparencyRequested = false;
            end
            %for i = 1:length(varargin)
            %    if contains(varargin{i},"-transparent")
            %        transparencyRequested = true;
            %        set(self.currentFig.gcf,"color","none");
            %        set(gca,"color","none");
            %    end
            %    if isa(varargin{i},"string")
            %        varargin{i} = convertStringsToChars(varargin{i});
            %    end
            %end
            export_fig(varargin{:});
            if transparencyRequested
                set(self.currentFig.gcf,"color","default");
                set(gca,"color","default");
            end

        end

        %***********************************************************************************************************************
        %***********************************************************************************************************************

    end % methods

    %*******************************************************************************************************************************
    %*******************************************************************************************************************************

    methods (Access=public,Hidden)

        function reset(self)

            self.rows = {};
            self.gca_kws = struct();
            self.gcf_kws = struct();
            self.legend_kws = struct();
            self.currentFig = struct();
            self.outputFile = [];

            self.legend_kws.labels = {};
            self.legend_kws.enabled = true;
            self.legend_kws.fontsize = [];
            self.legend_kws.singleOptions = {};

            self.gcf_kws.enabled = true;

            self.gca_kws.xscale = "linear";
            self.gca_kws.yscale = "linear";

        end

    end

    %*******************************************************************************************************************************
    %*******************************************************************************************************************************

    methods (Hidden)

        %***************************************************************************************************************************
        %***************************************************************************************************************************

        function parseArgs(self,varargin)

            vararginLen = length(varargin);
            for i = 1:2:vararginLen
                propertyDoesNotExist = true;
                selfProperties = properties(self);
                selfPropertiesLen = length(selfProperties);
                for ip = 1:selfPropertiesLen
                    if strcmp(string(varargin{i}),string(selfProperties{ip}))
                        propertyDoesNotExist = false;
                        if i < vararginLen
                            self.(selfProperties{ip}) = varargin{i+1};
                        else
                            error("The corresponding value for the property """ + string(selfProperties{ip}) + """ is missing as input argument.");
                        end
                        break;
                    end
                end
                if propertyDoesNotExist
                    error("The requested the property """ + string(varargin{i}) + """ does not exist.");
                end
            end

        end % function parseArgs

        %***************************************************************************************************************************
        %***************************************************************************************************************************

        function doBasePlotStuff(self, lgEnabled, lglabels)

            % add legend

            if lgEnabled
                if isa(self.legend_kws.labels,"cell")
                    if isempty(self.legend_kws.labels)
                        self.legend_kws.labels = {lglabels{:}};
                    end
                    if isempty(self.legend_kws.fontsize)
                        self.legend_kws.fontsize = self.currentFig.xlabel.FontSize;
                    end
                    legend_kws_cell = convertStruct2Cell(self.legend_kws,{"enabled","singleOptions","labels"});
                    self.currentFig.legend = legend(self.legend_kws.labels{:},legend_kws_cell{:},self.legend_kws.singleOptions{:});
                else
                    error   ( newline ...
                            + "The input ""legend_kws.labels"" must be a cell array of string values." ...
                            + newline ...
                            );
                end
            else
                legend(self.currentFig.gca,"off");
            end

            if ~isempty(self.gca_kws)
                gca_kws_cell = convertStruct2Cell(self.gca_kws,{"enabled","singleOptions","labels"});
                if isfield(self.gca_kws,"singleOptions"); gca_kws_cell = { gca_kws_cell{:}, self.gca_kws.singleOptions{:} }; end
                set(gca, gca_kws_cell{:})
            end

            if isa(self.outputFile,"string") || isa(self.outputFile,"char")
                self.exportFig(self.outputFile,"-m2 -transparent");
            end

        end

        %***************************************************************************************************************************
        %***************************************************************************************************************************

    end % methods (Access = private)

    %***************************************************************************************************************************
    %***************************************************************************************************************************

end % classdef BasePlot < dynamicprops