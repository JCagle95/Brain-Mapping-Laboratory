function [ XML ] = xmlParser( filename )
%xmlParser will parse the input XML file and output structured data
%   [ XML ] = xmlParser( filename )
%
%   This program is generically written for XML file. The main use is
%   Medtronic Sensing Programmer's Configuration XML file.
%
% J. Cagle, University of Florida 2016

% Read File
fid = fopen(filename);
if fid <= 0
    error('Failed to open file, please verify file name');
end

inputString = cell(0,1);
C = fgets(fid);
while ischar(C)
    inputString{end+1,1} = C;
    C = fgets(fid);
end
fclose(fid);

% Define XML
Count = 1;
Layer = 1;
maxDepth = 1;
subField = struct();
start_indices = cell(size(inputString));
end_indices = cell(size(inputString));

% Find all subfields and their layers
for x = 1:length(inputString)
    start_indices{x} = strfind(inputString{x},'<');
    end_indices{x} = strfind(inputString{x},'>');
    
    if ~isempty(start_indices{x}) && ~isempty(end_indices{x})
        Fields = cell(length(start_indices{x}),1);
        for i = 1:length(Fields)
            Fields{i} = inputString{x}(start_indices{x}(i)+1:end_indices{x}(i)-1);
            if Fields{i}(1) ~= '?'
                subField(Count).name = Fields{i};
                subField(Count).layer = Layer;
                if Fields{i}(1) == '/'
                    Layer = Layer - 1;
                    subField(Count).layer = Layer;
                else 
                    if Layer > maxDepth
                        maxDepth = Layer;
                    end
                    Layer = Layer + 1;
                end
                subField(Count).index = x;
                Count = Count + 1;
            end
        end
    end
end

% Construct XML
XML = struct();
LayerName = cell(maxDepth,1);
currentLayer = 0;
for x = 1:length(subField)
    if subField(x).layer >= currentLayer
        currentLayer = subField(x).layer;
        LayerName{currentLayer} = subField(x).name;
        if strcmp(subField(x+1).name,['/',subField(x).name])
            outputStruct = 'XML';
            for i = 1:currentLayer
                outputStruct = [outputStruct,'.',LayerName{i}];
            end
            
            if subField(x).index == subField(x+1).index
                inputValue = inputString{subField(x).index}(end_indices{subField(x).index}(1)+1:start_indices{subField(x).index}(2)-1);
            end
            
            if all(isstrprop(inputValue,'digit'))
                eval(sprintf('%s = %s;',outputStruct,inputValue));
            else
                eval(sprintf('%s = ''%s'';',outputStruct,inputValue));
            end
        end
    else
        currentLayer = subField(x).layer;
        LayerName{currentLayer} = [];
    end
end

end

