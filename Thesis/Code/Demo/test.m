clc;
clear all;
close all;

format long;

longit = 'Enter Longitude: ';
valLong = input(longit,'s');

lat = 'Enter Latitude: ';
valLat = input(lat,'s');

time_1 = 'Enter starting time: ';
startTime = input(time_1,'s');


time_2 = 'Enter ending time: ';
endTime = input(time_2,'s');

% Call out the function to get the weather data
out = getWeatherInfo(valLong, valLat, startTime, endTime);

% Get the time zone offset and adjust the unix times
tzOffset = getTimeZone(valLong, valLat, startTime);

% Get the size of the data retrieved from the web
[numDays, numHoursInADay] = size(out);

% Read the file containing the ZTD for plotting
ztd = readmatrix('ALSN2020206_0000_86418.csv', ...
                'OutputType', 'double', ...
                'Range', 2);
            
addMeteoInfo (valLong, valLat, startTime, endTime, ztd);
            

% Initialise the needed variables. The type name has been specified to account for 
% a user who has change his default settings
unixTime = zeros(numDays, numHoursInADay);
temperature = zeros(numDays, numHoursInADay);
pressure = zeros(numDays, numHoursInADay);
humidity = zeros(numDays, numHoursInADay);
allHours = zeros(numDays, numHoursInADay);
icons = cell(numDays, numHoursInADay);

% Fill the variables with the actual values obtained from the web
for i=1:numDays
    for j = 1:numHoursInADay       
        unixTime(i, j) = str2double(out{i,j}.time);
        temperature(i, j) = str2double(out{i,j}.temperature);
        pressure(i, j) = str2double(out{i,j}.pressure);
        humidity(i, j) = str2double(out{i,j}.humidity);
        icons{i,j} = out{i,j}.icon;
        allHours(i, j) = str2double(out{i,j}.time);
    end
end

% The time values are 23 hours (0:00am to 23:00pm). The ztd values from csv
% are in the interval of 30s for 24 hours with 1 minute less. Therefore, 
% add 3600-60 to the range of time values in the plot

x = unixTime(1,1) : 30 : (unixTime(end, end)+ 3540);

% Convert the unix time to matlab time
t = GPS_Time(uint32(x), 0, 1, 1);

% Add the time zone offset to the times
t = t.addIntSeconds(tzOffset * 3600);
mt = t.getMatlabTime;

% Plot of time variation of ZTD
% Create a figure
fig = figure( 'Name', 'Time Variation of ZTD', ...
            'DockControls', 'off', ...
            'NumberTitle', 'off', ...
            'WindowState', 'maximized');

% Create axes
ax = axes('Parent',fig);
hold(ax,'on');
grid on;
            
% Make the plot of ZTD with time
plot(ax, mt, ztd(:,2), 'color', 'k');

% Label the graph
if isempty(endTime) || isequal(startTime, endTime)
    title(append('Time Variation of ZTD for ', startTime));
else
    title(append('Time Variation of ZTD from ', startTime, ' to ', endTime));
    xtickangle(ax,30)
end

xlabel('Date - time', 'FontWeight', 'bold'); 
ylabel('ZTD', 'FontWeight', 'bold');


% Get the hours in the Unix time array
hourCheck = [];
for i=1:length(x)
    if rem(x(i), 3600) == 0
        hourCheck(end+1) = x(i);
    end
end

% Convert hourcheck to matlab time
t = GPS_Time(uint32(hourCheck), 0, 1, 1);
t = t.addIntSeconds(tzOffset * 3600);
hourCheck = t.getMatlabTime;

% Modify the ticks on the x-axis
tickTime = [];
for h = 1:6:length(hourCheck)
    for j=1:length(mt)
        if eq(hourCheck(h), mt(j))
            tickTime(end+1) = mt(j);
        end
    end
end

set(ax,'Xtick',tickTime);

datetick(ax, 'x', 0, 'keepticks', 'keeplimits');

% Get the maximum value of the graphic objects that have YData property 
% and set an offset on it to determine the position of the weather icon
obj = findobj(ax,'-property','YData');

ydataMax = max(obj.YData);

% Offset around the x-axis data points
xOffset = 0.010416666627862;

tempText = text(ax, mt(1)-xOffset, ydataMax+0.017, 'Temp. (\circC)', ...
                'Clipping', 'on', ...
                'HorizontalAlignment', 'right', ...
                'FontWeight', 'bold');
            
humiText = text(ax, mt(1)-xOffset, ydataMax+0.01, 'Humidity (%)', ...
                'Clipping', 'on', ...
                'HorizontalAlignment', 'right', ...
                'FontWeight', 'bold');

% Convert the all the hours in the days to matlab time
allHours = GPS_Time(uint32(allHours), 0, 1, 1);

allHours = allHours.addIntSeconds(tzOffset * 3600);

allHours = allHours.getMatlabTime;

% Set the position to be updated for the patches
posX = [allHours(1, 1) allHours(1, 1) allHours(1, 1) allHours(1, 1)];

posY = [ydataMax+0.02 ydataMax+0.02 ydataMax+0.025 ydataMax+0.025];

% % List of unique icons in the data. I intend using this to do a colormap
% % that will be used for the facecolor of the patches
uniqueIcons = unique(icons);

numUniqueIcons = length(uniqueIcons);

% Generate parula color maps according to the number of unique icons
iconColors = parula(numUniqueIcons);


patchObj = zeros(numUniqueIcons,1);

patchColors = zeros(size(iconColors));

for i=1:numDays
    for j = 1:numHoursInADay       
        if lt(j, numHoursInADay) && not(isequal((out{i, j}.icon),(out{i, j+1}.icon)))
            % If there is a change in the icon type, then, update the 2nd
            % and 3rd coordinates of posX, apply the patch and set the 1st
            % and 4th coordinates of posX to the 2nd and 3rd.
            for cm = 1:numUniqueIcons
                if isequal(uniqueIcons{cm}, out{i, j}.icon)
                    col = iconColors(cm);
                    
                    ind = cm;
                end
            end
            
            posX(2) = allHours(i,j+1);
            
            posX(3) = allHours(i,j+1);
            
            pObj = patch(ax, posX, posY, col);
            
            
            if not(ismember(col, patchColors))
                patchColors(ind)=col;
                patchObj(ind) = pObj;
            end
                   
            tx=text(ax, (max(posX)+min(posX))/2, ...
                        (max(posY)+min(posY))/2, ...
                        cellstr(out{i, j}.summary), ...
                        'HorizontalAlignment','center', ...
                        'VerticalAlignment','middle', ...
                        'Color', 'Blue', ...
                        'Clipping', 'on', ...
                        'Visible', 'off');
                
            posX(1) = posX(2);
            posX(4) = posX(3);
             
        elseif isequal(i, numDays) && isequal(j, numHoursInADay)
            
            posX(2) = mt(end);
            posX(3) = mt(end);
            
            for cm = 1:numUniqueIcons
                if isequal(uniqueIcons{cm}, out{i, j}.icon)
                    col = iconColors(cm);
                    ind = cm;
                end
            end
            
            pObj = patch(ax, posX, posY, col);
            
            if not(ismember(col, patchColors))
                patchColors(ind)=col;
                patchObj(ind) = pObj;
            end
            
            
        end
        
        imSource = append('images/', out{i, j}.icon, '.png');
        
        [im, colorMap, alpha] = imread( imSource );
        
        % Create a surface with the images of the weather conditions
        s = surface([allHours(i, j)-xOffset, allHours(i, j)+xOffset; allHours(i, j)-xOffset, allHours(i, j)+xOffset],...
                    [ydataMax+0.025, ydataMax+0.025; ydataMax+0.02, ydataMax+0.02], ...
                    zeros(2), ...
                    'FaceColor', 'texturemap', ...
                    'EdgeColor','none',...
                    'CData', im, ...
                    'CDataMapping', 'direct', ...
                    'AlphaData', alpha, ...
                    'FaceAlpha', 'texturemap', ...
                    'Visible', 'off'); 
         
                
         if isempty(endTime) || isequal(startTime, endTime)
             pObj.Visible = 'off';
             s.Visible = 'on';
         end

         % Temperature and humidity strings to be inserted in the axes
         tempValues = append(num2str(round(temperature(j),1)));
         
         humValues = append(num2str(humidity(j)*100));
         
         tempTxt = text(ax, allHours(i, j)-xOffset, ...
                            ydataMax+0.017, tempValues, ...
                            'Clipping', 'on');
                        
         humidTxt = text(ax, allHours(i, j)-xOffset, ...
                             ydataMax+0.01, humValues, ...
                             'Clipping', 'on');

    end
end
                 
            
lgd = legend(ax, patchObj, uniqueIcons, 'Location', 'southwest'); 

title(lgd,'Weather conditions');
          

if isempty(endTime) || isequal(startTime, endTime)
	lgd.Visible = 'off';
end

%%           
% % Set the path of the images           
% imSource = {};
% for i=1:numDays
%     for h = 1:(length(hourCheck)/numDays)
%         for j=1:(length(mt)/numDays)
%             if eq(hourCheck(h), mt(j)) 
%                 
%                 
%                 % Index to use to query the data structure
%                 ind = (j-1)/120 + 1;
%                 
%                 % Path to the sources of images to be used
%                 
%                 imSource{end+1} = append('images/', out{i, ind}.icon, '.png');
%             end
%         end
%     end
% end



      



% % Attach the images and the temp and humidity values to the axes
% for i=1:numDays
%     for h = 1:length(hourCheck)
%         for j=1:length(mt)
%             if eq(hourCheck(h), mt(j))
%                 
%                 ind = (j-1)/120 + 1;
%   
%                 
%                 
%                 
%                 
%                 
% 
% %                 
% 
%                 
%                 
%                 if lt(ind, (length(hourCheck))/numDays) && not(isequal((out{i, ind}.icon),(out{i, ind+1}.icon)))
%                    % The change in icon type is now detected so implement
%                    % for the update of the positions for the patches and
%                    % set the corresponding text from the summaries of the
%                    % data.
%                    for j=j:length(mt)
%                        if eq(hourCheck(h+1), mt(j))
%                            posX(2) = mt(j);
%                            posX(3) = mt(j);
%                        end
%                    end
%                    
%                    patch(posX, posY, 'red')
%                    
%                    tx=text((max(posX)+min(posX))/2, (max(posY)+min(posY))/2, cellstr(out{i, ind}.summary),'HorizontalAlignment','center','VerticalAlignment','middle', 'Color', 'Blue');
%                 
%                    posX(1) = posX(2);
%                    posX(4) = posX(3);
%                    
%                 elseif isequal(ind, (length(hourCheck)/numDays))
%                    
%                    posX(2) = mt(j);
%                    posX(3) = mt(j);
%                    patch(posX, posY, 'red')
%                    tx=text((max(posX)+min(posX))/2, (max(posY)+min(posY))/2, cellstr(out{i, ind}.summary),'HorizontalAlignment','center','VerticalAlignment','middle', 'Color', 'Blue');
%                 
%                    
%                    
%                 end
%                 
%                 
%                 
%                 
%             end
%         end
%     end
%     
% %     posX(1) = posX(2);
% %     posX(4) = posX(3);
% %     posX;
%     
% end
% 
% % x = [2 3 3 2];
% % y = [5 5 10 10];
% % patch(x,y,'red')
% % tx=text((max(x)+min(x))/2, (max(y)+min(y))/2, cellstr(out{1, 1}.summary),'HorizontalAlignment','center','VerticalAlignment','middle', 'Color', 'Blue')
% 
