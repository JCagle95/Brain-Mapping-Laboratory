function [ varargout ] = xcorrMatrix( X, Label )
%Compute elementwise-correlation matrix and visualize it 
%   J. Cagle, University of Florida, 2017

% Setup
largeFigure(0,[1200 900]); clf; hold on; box off;
cmap = redblue(201);
colormap(cmap);
R = corr(X);
set(gca,'fontname','Trebuchet MS')

% Plot the Grid
for i = 1:length(R)-1
    plot([0 length(R)+1],[i i]+0.5,'linewidth',1.5,'color',[0.5 0.5 0.5]);
    plot([i i]+0.5,[0 length(R)+1],'linewidth',1.5,'color',[0.5 0.5 0.5]);
end
set(gca,'gridcolor',[0.5 0.5 0.5]);

% Plot ellipse
for i = 1:length(R)
    for j = 1:length(R)
        if true%length(R)-j+1 ~= i
            shadedEllipse(i,j,R(i,length(R)-j+1),cmap(round(R(i,length(R)-j+1)*100)+101,:));
        end
    end
end

% Setup axis
axis([0.5 length(R)+0.5 0.5 length(R)+0.5]);
set(gca,'XTick',1:length(R),'YTick',1:length(R),'XAxisLocation','top');
set(gca,'TickLength',[0 0],'XTickLabel',Label,'YTickLabel',flip(Label),'XTickLabelRotation',90);
set(gca,'Position',[0.2 0.1 0.7 0.7]);
set(gca, 'XColor', [1 0 0], 'YColor', [1 0 0]);
pbaspect([1 1 1])

% Generate Colormap
caxis([-1 1]);
addColorbar('Correlation Coefficients',18);
set(gca,'fontsize',15);

ax1_pos = get(gca,'Position'); % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','left',...
    'Color','none',...
    'XTickLabel',{},'YTickLabel',{},'TickLength',[0 0]);
box(ax2,'on');
pbaspect([1 1 1])

end

function shadedEllipse(X,Y,r,cScale)

radius = 0.35;
width = 1;
xRange = X-0.5:0.001:X+0.5;
underRoot = (-r*width*(xRange-X)).^2 - 4*((xRange-X).^2 - (radius^2));
xRange = xRange(underRoot > 0);
underRoot = underRoot(underRoot > 0);

lowerY = (-(-r*width*(xRange-X)) + sqrt(underRoot))/2 + Y;
upperY = (-(-r*width*(xRange-X)) - sqrt(underRoot))/2 + Y;

h = patch([xRange,flip(xRange)],[lowerY,flip(upperY)],cScale);
alpha(h,sqrt(abs(r)));
text(X,Y,sprintf('%.2f',r),'horizontalalignment','center','fontsize',15,'fontname','Arial black');

end