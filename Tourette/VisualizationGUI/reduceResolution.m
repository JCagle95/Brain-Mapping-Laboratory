function reduceResolution( source, target, percentage )
%Simply reducing the video resolution by downsampling.
%   reduceResolution( source, target, percentage );
%
% J. Cagle, University of Florida, 2016

vidObj = VideoReader(source);
targetVidObj = VideoWriter(target);
targetVidObj.FrameRate = vidObj.FrameRate;
open(targetVidObj);
while hasFrame(vidObj)
    vidFrame = readFrame(vidObj);
    vidFrame = imresize(vidFrame, percentage);
    writeVideo(targetVidObj,vidFrame);
    disp(vidObj.CurrentTime);
end

end

