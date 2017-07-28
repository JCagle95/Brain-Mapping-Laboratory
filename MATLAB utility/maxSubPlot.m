function ax = maxSubPlot( h, dime )
%Create a series of subplot in the specified Figure with maximum space
%utilized
%   ax = maxSubPlot( h, dime );

clf(h);
if length(dime) ~= 2
    error('The dimension must be 2D');
end

row = dime(1);
column = dime(2);

rowLength = 0.96/(row);
columnLength = 0.96/(column);
leftEdge = 0.04;
if (columnLength*0.1) > leftEdge
    columnLength = 1/column;
end

for i = 1:row
    for j = 1:column
        ax((i-1)*column+j) = subplot('position',[leftEdge+(j-1)*columnLength 1-i*rowLength+0.05*rowLength columnLength*0.9 rowLength*0.9]);
        box(ax((i-1)*column+j),'on');
    end
end

end

