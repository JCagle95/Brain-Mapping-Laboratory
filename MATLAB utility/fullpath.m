function [ Path, FileName ]= fullpath(folder, pattern)
%fullpath function will return the full address to the file matches the
%pattern described.
%
%   [ Path, FileName ]= fullPath(folder, pattern);
%
%   This utility function is to extract files in certain directory and
%   return its fullpath as opposite to only filename returned.
%
% J. Cagle, University of Florida 2016

if iscell(folder)==1
    folder = cell2mat(folder);
end
pattern = [folder pattern];

files = dir(pattern);

for fid = 1:length(files)
    Path{fid} = [folder files(fid).name];
    FileName{fid} = data(fid).name;
end

Path(ismember(FileName,{'.','..'})) = [];

if isempty(files)
    Path = 0;
end

end