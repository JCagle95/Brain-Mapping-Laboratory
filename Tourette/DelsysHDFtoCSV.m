function DelsysHDFtoCSV( folder, ID )
%Simplified DOS call to convert HDF file to CSV file
%   DelsysDHDFtoCSV(folder);
%
% J. Cagle, University of Florida 2016

if folder(end) ~= '/' || folder(end) ~= '\'
    folder(end+1) = '/';
end
rootPath = fullPath(folder,'*hpf');
for i = 1:length(rootPath)
    if i >= ID
        dos(['"C:\Program Files (x86)\Delsys, Inc\EMGworks 4.3.0\DelsysFileUtil.exe" -nogui -o CSV -i "' rootPath{i} '" -r "' folder 'CSV\']);
    end
end
end

