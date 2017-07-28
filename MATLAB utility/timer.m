classdef timer
    properties
        startTime = 0;
        count = 0;
        str = '';
        formatedString = '';
    end
    methods
        function obj = timer(text)
            obj.formatedString = text;
            obj.startTime = tic;
        end
        function obj = currentTime(obj)
            obj.count = toc(obj.startTime);
        end
        function obj = printLine(obj,input)
            obj.count = toc(obj.startTime);
            eraseText([obj.str]);
            obj.str = sprintf(obj.formatedString,[input obj.count]);
            fprintf(obj.str);
        end
    end
end