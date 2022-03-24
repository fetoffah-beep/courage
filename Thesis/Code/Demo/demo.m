% Prepare spaces and get user inputs
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

% Create a figure
fig = figure( 'Name', 'Variation of temperature', ...
    'DockControls', 'off', ...
    'NumberTitle', 'off', ...
    'WindowState', 'maximized');

fig.WindowState = 'maximized';
fig.UserData = struct('coordinate', [str2double(valLat) str2double(valLong)]);

% Create axes
ax = axes('Parent',fig);
ax.Title.String = 'Time variation of Temperature';
hold(ax,'on');
grid on;


% Call out the function to get the weather data
out = getWeatherInfo(valLong, valLat, startTime, endTime);

% Get the time zone offset and adjust the unix times
tzOffset = getTimeZone(valLong, valLat, startTime);

% Get the size of the data retrieved from the web
[numDays, numHoursInADay] = size(out);

% Initialise the needed variables. The type name has been specified to account for
% a user who has change his default settings
allHours = zeros(numDays, numHoursInADay);
y1 = [];

% Fill the variables with the actual values obtained from the web
for i=1:numDays
    for j = 1:numHoursInADay
        
        allHours(i, j) = str2double(out{i,j}.time);
        y1(end+1) = str2double(out{i,j}.temperature);
    end
end


% Convert the all the hours in the days to matlab time
allHours = GPS_Time(uint32(allHours), 0, 1, 1);

allHours = allHours.addIntSeconds(tzOffset * 3600);

allHours = allHours.getMatlabTime;


x = [];

for i=1:numDays
    for j = 1:numHoursInADay
        x(end+1) =  allHours(i, j);
    end
end

plot(x, y1)

% Label the graph
if isempty(endTime) || isequal(startTime, endTime)
    title(append('Temperature for ', datestr(startTime)));
else
    title(append('Temperature from ', datestr(startTime), ' to ', datestr(endTime)));
    xtickangle(ax,30)
end

xlabel('Date - time', 'FontWeight', 'bold');
ylabel('Temperature (\circC)', 'FontWeight', 'bold');


% Modify the ticks on the x-axis
tickTime = [];
for h = 1:6:length(x)
    tickTime(end+1) = x(h);
end

set(ax,'Xtick',tickTime);

datetick(ax, 'x', 0, 'keepticks', 'keeplimits');


% Function to add the Meteo menu
addMeteoMenu(fig, out, tzOffset);


function addMeteoMenu(fig_handle, out, tzOffset)
% Add a menu Meteo to figure with a submenu for adding the
% meteorological info to the figure
%
% SYNTAX
%   Core_Utils.addMeteoMenu(fig_handle)

if nargin == 0 || isempty(fig_handle)
    fig_handle = gcf;
end

m = findall(fig_handle.Children, 'Type', 'uimenu', 'Label', '&Meteo');
if ~isempty(m)
    m = m(1);
else
    % If the Meteo menu item is not available, create it
    m = uimenu(fig_handle, 'Label', '&Meteo');
    m.Accelerator = 'M';
end

mitemWeather = findall(m.Children, 'Type', 'uimenu', 'Label', '&Weather Info');
if ~isempty(mitemWeather)
    % Item already present
    %    mitemWeather = mitemWeather(1);
else
    mitemWeather = uimenu(m,'Label','&Weather Info', 'Checked', 'off');
    mitemWeather.Accelerator = 'W';
    mitemWeather.MenuSelectedFcn = {@addWeatherInfo, mitemWeather.Label, mitemWeather, out, tzOffset};
    
end


mitemTemp = findall(m.Children, 'Type', 'uimenu', 'Label', '&Temperature');
if ~isempty(mitemTemp)
    % Item already present
    %    mitemTemp = mitemTemp(1);
else
    mitemTemp = uimenu(m,'Label','&Temperature', 'Checked', 'off');
    mitemTemp.Accelerator = 'T';
    mitemTemp.MenuSelectedFcn = {@addWeatherInfo, mitemTemp.Label, mitemTemp, out, tzOffset};
    
end

mitemPressure = findall(m.Children, 'Type', 'uimenu', 'Label', '&Pressure');
if ~isempty(mitemPressure)
    % Item already present
    %    mitemPressure = mitemPressure(1);
else
    mitemPressure = uimenu(m,'Label','&Pressure', 'Checked', 'off');
    mitemPressure.Accelerator = 'P';
    mitemPressure.MenuSelectedFcn = {@addWeatherInfo, mitemPressure.Label, mitemPressure, out, tzOffset};
    
end

mitemHum = findall(m.Children, 'Type', 'uimenu', 'Label', '&Humidity');
if ~isempty(mitemHum)
    % Item already present
    %    mitemHum = mitemHum(1);
else
    mitemHum = uimenu(m,'Label','&Humidity', 'Checked', 'off');
    mitemHum.Accelerator = 'H';
    mitemHum.MenuSelectedFcn = {@addWeatherInfo, mitemHum.Label, mitemHum, out, tzOffset};
    
end


mitemSpeed = findall(m.Children, 'Type', 'uimenu', 'Label', 'Wind Speed');
if ~isempty(mitemSpeed)
    % Item already present
    %    mitemSpeed = mitemSpeed(1);
else
    mitemSpeed = uimenu(m,'Label','Wind Speed', 'Checked', 'off');
    mitemSpeed.MenuSelectedFcn = {@addWeatherInfo, mitemSpeed.Label, mitemSpeed, out, tzOffset};
    
end


mitemGust = findall(m.Children, 'Type', 'uimenu', 'Label', 'Wind Gust');
if ~isempty(mitemGust)
    % Item already present
    %    mitemGust = mitemGust(1);
else
    mitemGust = uimenu(m,'Label','Wind Gust', 'Checked', 'off');
    mitemGust.MenuSelectedFcn = {@addWeatherInfo, mitemGust.Label, mitemGust, out, tzOffset};
    
end

mitemBearing = findall(m.Children, 'Type', 'uimenu', 'Label', 'Wind Bearing');
if ~isempty(mitemBearing)
    % Item already present
    %    mitemBearing = mitemBearing(1);
else
    mitemBearing = uimenu(m,'Label','Wind Bearing', 'Checked', 'off');
    mitemBearing.MenuSelectedFcn = {@addWeatherInfo, mitemBearing.Label, mitemBearing, out, tzOffset};
    
end

mitemAllParam = findall(m.Children, 'Type', 'uimenu', 'Label', 'Show ALL');
if ~isempty(mitemAllParam)
    % Item already present
    %    mitemAllParam = mitemAllParam(1);
else
    mitemAllParam = uimenu(m,'Label','Show ALL', 'Checked', 'off', 'Separator', 'on');
    mitemAllParam.MenuSelectedFcn = {@addWeatherInfo, mitemAllParam.Label, mitemAllParam, out, tzOffset};
    
end



    function addWeatherInfo(src, event, label, itemName, out, tzOffset)
        
        if strcmp(itemName.Checked,'off')
            weatherInfo(src.Parent.Parent, label, out, tzOffset);
            
            if strcmp(label,'Show ALL')
                set(itemName.Parent.Children, 'Checked', 'on')
                set(itemName, 'Label', 'Hide ALL')
            else
                itemName.Checked= 'on';
            end
            
        else
            
            if strcmp(itemName.Label,'Hide ALL')
                set(itemName.Parent.Children, 'Checked', 'off')
            else
                itemName.Checked= 'off';
            end
            
            
            % Find and delete info when menu item is unchecked
            
            switch label
                % Delete objects according to which menu item has
                % been selected
                case '&Temperature'
                    textObjects = findobj(fig_handle, 'Tag', 'temperature');
                    delete(textObjects);
                    
                case '&Pressure'
                    textObjects = findobj(fig_handle, 'Tag', 'pressure');
                    delete(textObjects);
                    
                case '&Humidity'
                    textObjects = findobj(fig_handle, 'Tag', 'humidity');
                    delete(textObjects);
                    
                case 'Wind Speed'
                    textObjects = findobj(fig_handle, 'Tag', 'windspeed');
                    delete(textObjects);
                    
                case 'Wind Gust'
                    textObjects = findobj(fig_handle, 'Tag', 'windgust');
                    delete(textObjects);
                    
                case 'Wind Bearing'
                    textObjects = findobj(fig_handle, 'Tag', 'windbearing');
                    delete(textObjects);
                    
                case '&Weather Info'
                    objects = findobj(fig_handle, 'Tag', 'weatherInfo');
                    delete(objects);
                    lgdobjects = findobj(fig_handle, 'Tag', 'patchlgd');
                    delete(lgdobjects);
                    
                case 'Show ALL'
                    
                    allObj = {'temperature', 'pressure', 'humidity', 'windspeed', 'windgust', 'windbearing', 'weatherInfo', 'patchlgd'};
                    for i=1:length(allObj)
                        delete(findobj(fig_handle, 'Tag', allObj{i}));
                    end
                    set(itemName, 'Label', 'Show ALL')
                    
            end
            
        end
        
        
    end
    function weatherInfo (figHandle, label)
        
        %%%%%%%%% TWO AXES OBJECTS ARE BEING USED HERE TO %%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%% PRESERVE THE LEGEND FOR THE FIRST GRAPH %%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%  CREATE THE ELEMENTS IN THE FIRST AXES %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Call out the function to get the weather data
        % Check that the figure has the coordinate property.
        % Otherwise return and don't do anything
        if isfield(figHandle.UserData, 'coordinate')
            pos = figHandle.UserData.coordinate;
            
        else
            msgbox('Not supported in the current figure', 'Support Error', 'error', 'modal');
            return
        end
        
        
        valLat = pos(1);
        valLong = pos(2);
        
        % Find all the axes and create the children object in the
        % current axes that has a title
        axm = findall(figHandle.Children, 'Type', 'Axes');
        
        
        for i = 1:length(axm)
            if ~isempty(axm(i).Title.String)
                ax = axm(i);
            end
        end
        
        findLine = findall(ax.Children, 'Type', 'line');
        xMatlabTime = [];
        
        xMatlabTime(1) = min([findLine.XData]);
        xMatlabTime(2) = max([findLine.XData]);
        
        
        xTime = datestr(xMatlabTime, 'yyyy-mm-dd');
        startTime = convertCharsToStrings(xTime(1, :));
        endTime = convertCharsToStrings(xTime(2, :));
        
        % To show all parameters, if it has already been created,
        % then delete it and create a new one
        allObj = {'temperature', 'pressure', 'humidity', 'windspeed', 'windgust', 'windbearing', 'weatherInfo', 'patchlgd'};
        if strcmp(label, 'Show ALL')
            for ii=1:length(allObj)
                delete(findobj(fig_handle, 'Tag', allObj{ii}));
            end
        end
        
        % Get the weather data
        out = getWeatherInfo(valLat, valLong, startTime, endTime);
        
        
        % Check that the weather data is not empty
        if isempty(out)
            msgbox('No data available for the specified date', 'Error', 'error', 'modal');
            return
        end
        
        % Get the time zone offset and adjust the unix times
        tzOffset = getTimeZone(valLat, valLong, startTime);
        
        % Get the elevation of the station
        stat_elev = getGeodHeight(valLat, valLong);
       
        % Generate the meteorological rinex file
        marker_name = strcat(figHandle.UserData.marker_name, '_');
        getMeteoData(valLat, valLong, startTime, endTime, marker_name)
         
        % Get the size of the data retrieved from the web
        [numDays, numHoursInADay] = size(out);
        
        % Initialise the needed variables. The type name has been specified to account for
        % a user who has change his default settings
        unixTime = zeros(numDays *  numHoursInADay, 1);
        temperature = zeros(numDays * numHoursInADay, 1);
        pressure = zeros(numDays * numHoursInADay, 1);
        humidity = zeros(numDays * numHoursInADay, 1);
        windSpeed = zeros(numDays * numHoursInADay, 1);
        windGust = zeros(numDays * numHoursInADay, 1);
        windBearing = zeros(numDays * numHoursInADay, 1);
        allHours = zeros(numDays * numHoursInADay, 1);
        icons = cell(numDays * numHoursInADay, 1);
        
        
        
        % Fill the variables with the actual values obtained from the web
        for i=1:numDays
            for j = 1:numHoursInADay
                unixTime(24*(i-1)+j) = str2double(out{i,j}.time);
                temperature(24*(i-1)+j) = str2double(out{i,j}.temperature);
                pressure(24*(i-1)+j) = str2double(out{i,j}.pressure);
                humidity(24*(i-1)+j) = str2double(out{i,j}.humidity);
                windSpeed(24*(i-1)+j) = str2double(out{i,j}.windSpeed);
                windGust(24*(i-1)+j) = str2double(out{i,j}.windGust);
                windBearing(24*(i-1)+j) = str2double(out{i,j}.windBearing);
                allHours(24*(i-1)+j) = str2double(out{i,j}.time);
                icons{24*(i-1)+j} = out{i,j}.icon;
            end
        end
        
        % Convert the all the hours in the days to matlab time
        allHours = GPS_Time(uint32(allHours), 0, 1, 1);
        allHours = allHours.addIntSeconds(tzOffset * 3600);
        allHours = allHours.getMatlabTime;
        
        
        % Offset around the x-axis data points +/- 15 minutes
        xOffset = 15/60 * (allHours(2, 1) - allHours(1, 1));
        
        
        hourToLength = allHours(2, 1) - allHours(1, 1);
        
        
        % The current unit of the axes and change to pixels if it's
        % not in pixel units
        if ~strcmp(ax.Units, 'pixels')
            old_state = ax.Units;
            ax.Units = 'pixels';
        else
            old_state = 'pixels';
        end
        
        
        width_px = ax.Position(3);
        width_coor = diff(ax.XLim);
        
        scale_x = width_px/width_coor;
        
        % The icons will be at +/-15 minutes around an hour point,
        % so 30 miuntes interval. Convert 30 minute in matlab time
        % to pixels
        
        yPixel = (hourToLength / 2) * scale_x;
        
        % Determine an equivalent unit of Pixel on the Y Axis
        height_px = ax.Position(4);
        height_coor = diff(ax.YLim);
        
        scale_y = height_coor/height_px;
        
        yOffset = yPixel * scale_y;
        
        % Set the text offset as a percentage of the axes height
        textOffset = 0.03*height_px;
        textOffset = textOffset * scale_y;
        
        ax.Units = old_state;
        
        
        % Get the maximum value of the line graphic objects that have YData property
        % and set an offset on it to determine the position of the weather icon
        
        findSurface = findall(ax.Children, 'Type', 'Surface');
        findPatches = findall(ax.Children, 'Type', 'Patch');
        findText = findall(ax.Children, 'Type', 'Text');
        
        % If the objects have been created, then get their maximum
        % YData values and find the overall YData max
        surfMax = [];
        patchMax = [];
        textMax = [];
        textMin = [];
        if ~isempty(findSurface)
            for i = 1:length(findSurface)
                surfMax(end+1) = max(findSurface(i).YData, [], 'all');
            end
        end
        
        if ~isempty(findPatches)
            for i = 1:length(findPatches)
                patchMax(end+1) = max(findPatches(i).YData, [], 'all');
            end
        end
        
        if ~isempty(findText)
            for i = 1:length(findText)
                textMax(end+1) = max( (findText(i).Extent(4)+findText(i).Extent(2)), [], 'all');
                textMin(end+1) = min( findText(i).Extent(1), [], 'all');
            end
        end
        
        lineMax = max([findLine.YData], [], 'all') + yOffset*5;
        
        ydataMax = max([lineMax surfMax patchMax textMax], [], 'all');
        
        
        xlim([(xMatlabTime(1)-hourToLength*3) xMatlabTime(2)+hourToLength])
        
        initLim = ylim(ax);
        
        
        if gt(ydataMax, (ylim(ax)-yOffset*2))
            ylim(ax, [initLim(1) ydataMax+yOffset*3])
        end
        
        % Define the labels for the parameters
        
        posTX = xMatlabTime(1)-xOffset;
        posTY = double(ydataMax+textOffset);
        
        
        
        switch label
            
            case '&Temperature'
                itemtext = text(ax, posTX, posTY, 'Temp. (\circC)  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'temperature' );
                
            case '&Pressure'
                itemtext = text(ax, posTX, posTY, 'Pressure (hPa)  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'pressure');
                
            case '&Humidity'
                itemtext = text(ax, posTX, posTY, 'Humidity (%)  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'humidity');
                
            case 'Wind Speed'
                itemtext = text(ax, posTX, posTY, 'Wind Speed (m/s)  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'windspeed');
                
            case 'Wind Gust'
                itemtext = text(ax, posTX, posTY, 'Wind Gust (m/s)  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'windgust');
                
            case 'Wind Bearing'
                itemtext = text(ax, posTX, posTY, 'Wind Bearing  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'windbearing');
                
            case '&Weather Info'
                itemtext = text(ax, posTX, posTY, 'Weather Info  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'weatherInfo');
                
                
            case 'Show ALL'
                
                itemtext1 = text(ax, posTX, double(ydataMax), 'Wind Bearing  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'windbearing');
                
                
                itemtext2 = text(ax, posTX, double(ydataMax+textOffset*2), 'Wind Gust (m/s)  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'windgust');
                
                itemtext3 = text(ax, posTX, double(ydataMax+textOffset*4), 'Wind Speed (m/s)  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'windspeed');
                itemtext4 = text(ax, posTX, double(ydataMax+textOffset*6), 'Humidity (%)  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'humidity');
                
                
                itemtext5 = text(ax, posTX, double(ydataMax+textOffset*8), 'Pressure (hPa)  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'pressure');
                
                
                itemtext6 = text(ax, posTX, double(ydataMax+textOffset*10), 'Temp. (\circC)  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'temperature');
                
                itemtext7 = text(ax, posTX, double(ydataMax+textOffset*12), 'Weather Info  ', ...
                    'Clipping', 'on', ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', 'bold', ...
                    'FontSize', 8, 'Color', 'white', ...
                    'Clipping', 'on', 'Tag', 'weatherInfo');
                
        end
        
        
        % Set the position to be updated for the patches
        posX = [xMatlabTime(1) xMatlabTime(1) xMatlabTime(1) xMatlabTime(1)];
        
        if strcmp(label, 'Show ALL')
            posY = [ydataMax+textOffset*11.5 ydataMax+textOffset*11.5 ydataMax+yOffset+textOffset*11.5 ydataMax+yOffset+textOffset*11.5];
            
        else
            posY = [ydataMax+0.05 ydataMax+0.05 ydataMax+yOffset+0.05 ydataMax+yOffset+0.05];
            
        end
        
        
        % % List of unique icons in the data. I intend using this to do a colormap
        % % that will be used for the facecolor of the patches
        uniqueIcons = unique(icons);
        
        numUniqueIcons = length(uniqueIcons);
        
        % Generate parula color maps according to the number of unique icons
        
        iconColors = zeros(numUniqueIcons, 3);
        
        %                 colo = {'#b1fb32' '#466e02' '#a1b57e' '#3ba19b' '#fdfae8' '#816f03' '#a9a16e' '#d6d2b7' '#67634c' '#4c6762' '#5a8e85' '#10574a' '#9ba1a1' '#ec9558' '#f4752a' '#70edab' '#707271' '#dce6e1' '#adb1d2' '#535355' '#b0a0b5' '#87728e' '#40184d' '#a445e1' '#1f9c9b' '#156f6e' '#66b960' '#018788' '#8384c4' '#30328d' '#f3bddd' '#acf7f3' '#587270' '#d9bfda' '#958895' '#515051' '#0290fd' '#88c9fa' '#01335a' '#d1dee7' '#829cb0' '#da6c93' '#afa2a7' '#665e61' '#c1bb8f' '#2e3790' '#232748' '#fbec02' '#975051' '#57dd96'};
        %                 colorCode = zeros(length(colo), 3);
        %                 for i = 1:length(colo)
        %                     colorCode(i,:) = hex2rgb(colo{1, i});
        %                 end
        colorCode = [0.694117647058824,0.984313725490196,0.196078431372549;0.274509803921569,0.431372549019608,0.00784313725490196;0.631372549019608,0.709803921568628,0.494117647058824;0.231372549019608,0.631372549019608,0.607843137254902;0.992156862745098,0.980392156862745,0.909803921568627;0.505882352941176,0.435294117647059,0.0117647058823529;0.662745098039216,0.631372549019608,0.431372549019608;0.839215686274510,0.823529411764706,0.717647058823529;0.403921568627451,0.388235294117647,0.298039215686275;0.298039215686275,0.403921568627451,0.384313725490196;0.352941176470588,0.556862745098039,0.521568627450980;0.0627450980392157,0.341176470588235,0.290196078431373;0.607843137254902,0.631372549019608,0.631372549019608;0.925490196078431,0.584313725490196,0.345098039215686;0.956862745098039,0.458823529411765,0.164705882352941;0.439215686274510,0.929411764705882,0.670588235294118;0.439215686274510,0.447058823529412,0.443137254901961;0.862745098039216,0.901960784313726,0.882352941176471;0.678431372549020,0.694117647058824,0.823529411764706;0.325490196078431,0.325490196078431,0.333333333333333;0.690196078431373,0.627450980392157,0.709803921568628;0.529411764705882,0.447058823529412,0.556862745098039;0.250980392156863,0.0941176470588235,0.301960784313725;0.643137254901961,0.270588235294118,0.882352941176471;0.121568627450980,0.611764705882353,0.607843137254902;0.0823529411764706,0.435294117647059,0.431372549019608;0.400000000000000,0.725490196078431,0.376470588235294;0.00392156862745098,0.529411764705882,0.533333333333333;0.513725490196078,0.517647058823530,0.768627450980392;0.188235294117647,0.196078431372549,0.552941176470588;0.952941176470588,0.741176470588235,0.866666666666667;0.674509803921569,0.968627450980392,0.952941176470588;0.345098039215686,0.447058823529412,0.439215686274510;0.850980392156863,0.749019607843137,0.854901960784314;0.584313725490196,0.533333333333333,0.584313725490196;0.317647058823529,0.313725490196078,0.317647058823529;0.00784313725490196,0.564705882352941,0.992156862745098;0.533333333333333,0.788235294117647,0.980392156862745;0.00392156862745098,0.200000000000000,0.352941176470588;0.819607843137255,0.870588235294118,0.905882352941177;0.509803921568627,0.611764705882353,0.690196078431373;0.854901960784314,0.423529411764706,0.576470588235294;0.686274509803922,0.635294117647059,0.654901960784314;0.400000000000000,0.368627450980392,0.380392156862745;0.756862745098039,0.733333333333333,0.560784313725490;0.180392156862745,0.215686274509804,0.564705882352941;0.137254901960784,0.152941176470588,0.282352941176471;0.984313725490196,0.925490196078431,0.00784313725490196;0.592156862745098,0.313725490196078,0.317647058823529;0.341176470588235,0.866666666666667,0.588235294117647];
        %
        % Select the color of the icons according to the names
        iconNames = {'blizzard' 'blizzard-night' 'breezy' 'breezy-snow' 'clear-day' 'clear-night' 'cloudy' 'cloudy-day' 'cloudy-night' 'drizzle' 'drizzle-day' 'drizzle-night' 'dust' 'earthquake' 'fire' 'flood' 'flurries' 'fog' 'fog-day' 'fog-night' 'hail' 'hail-day' 'hail-night' 'haze' 'heavy-rain' 'heavy-rain-night' 'heavy-sleet' 'heavy-snow' 'light-rain' 'light-rain-night' 'light-sleet' 'light-snow' 'overcast' 'partly-cloudy' 'partly-cloudy-day' 'partly-cloudy-night' 'rain' 'rain-day' 'rain-night' 'showers' 'showers-day' 'sleet' 'sleet-day' 'sleet-night' 'smoke' 'snow' 'snow-night' 'sunny' 'tornado' 'wind'};
        for i=1:length(uniqueIcons)
            for j = 1:length(iconNames)
                if strcmp(uniqueIcons{i}, iconNames{j})
                    iconColors(i,:) = colorCode(j,:);
                end
            end
        end
        
        
        patchObj = zeros;
        
        patchColors = zeros(size(iconColors));
        
        legendIcons = {};
        
        numHoursInFigure = 0;
        
        
        for i=1:numDays
            for j = 1:numHoursInADay
                if le(allHours(24*(i-1)+j), (xMatlabTime(2))) && ge(allHours(24*(i-1)+j), (xMatlabTime(1)))
                    numHoursInFigure = numHoursInFigure + 1;
                    imSource = append('images/', out{i, j}.icon, '.png');
                    
                    [im, colorMap, alpha] = imread( imSource );
                    
                    presValues = append(num2str(pressure(24*(i-1)+j)));
                    tempValues = append(num2str(round(temperature(24*(i-1)+j),1)));
                    humValues = append(num2str(humidity(24*(i-1)+j)*100));
                    speedValues = append(num2str(round(windSpeed(24*(i-1)+j), 1)));
                    gustValues = append(num2str(round(windGust(24*(i-1)+j), 1)));
                    bearingValues = append(num2str(windBearing(24*(i-1)+j)));
                    
                    
                    switch label
                        
                        case '&Pressure'
                            presTxt = text(ax, allHours(24*(i-1)+j)-xOffset, ...
                                double(ydataMax+textOffset), presValues, ...
                                'Clipping', 'on', 'Tag', 'pressure', 'FontSize', 8, 'Color', 'white');
                            
                            if lt(24*(i-1)+j, 30)
                                if le(numDays,2)
                                    if isequal(rem(j,2), 0)
                                        set(presTxt, 'Visible', 'off');
                                    end
                                else
                                    if ~isequal(rem(24*(i-1)+j,2*numDays),0)
                                        set(presTxt, 'Visible', 'off')
                                    end
                                end
                            else
                                if ~isequal(rem(24*(i-1)+j,2*numDays),0)
                                    set(presTxt, 'Visible', 'off')
                                end
                            end
                            
                        case '&Temperature'
                            % Temperature  strings to be inserted in the axes
                            tempTxt = text(ax, allHours(24*(i-1)+j)-xOffset, ...
                                double(ydataMax+textOffset), tempValues, ...
                                'Clipping', 'on', 'Tag', 'temperature', 'FontSize', 8, 'Color', 'white');
                            if ~isequal(rem(24*(numDays-1)+j,numDays),0)
                                set(tempTxt, 'Visible', 'off');
                            end
                            
                        case '&Humidity'
                            humidTxt = text(ax, allHours(24*(i-1)+j)-xOffset, ...
                                double(ydataMax+textOffset), humValues, ...
                                'Clipping', 'on', 'Tag', 'humidity', 'FontSize', 8, 'Color', 'white');
                            if ~isequal(rem(24*(numDays-1)+j,numDays),0)
                                set(humidTxt, 'Visible', 'off');
                            end
                            
                        case 'Wind Speed'
                            speedTxt = text(ax, allHours(24*(i-1)+j)-xOffset, ...
                                double(ydataMax+textOffset), speedValues, ...
                                'Clipping', 'on', 'Tag', 'windspeed', 'FontSize', 8, 'Color', 'white');
                            if ~isequal(rem(24*(numDays-1)+j,numDays),0)
                                set(speedTxt, 'Visible', 'off');
                            end
                            
                        case 'Wind Gust'
                            gustTxt = text(ax, allHours(24*(i-1)+j)-xOffset, ...
                                double(ydataMax+textOffset), gustValues, ...
                                'Clipping', 'on', 'Tag', 'windgust', 'FontSize', 8, 'Color', 'white');
                            if ~isequal(rem(24*(numDays-1)+j,numDays),0)
                                set(gustTxt, 'Visible', 'off');
                            end
                            
                        case 'Wind Bearing'
                            modulus = str2double(bearingValues);
                            max_size = yOffset;
                            marker_scale = max_size / max(modulus);
                            if isequal(rem(24*(numDays-1)+j,numDays),0)
                                triPlot((allHours(24*(i-1)+j)-xOffset), (double(ydataMax+textOffset)), str2num(bearingValues), str2num(bearingValues), yOffset*4, marker_scale);
                            end
                            
                        case '&Weather Info'
                            
                            % Create a surface with the images of the weather conditions
                            s = surface(ax, [allHours(24*(i-1)+j)-xOffset, allHours(24*(i-1)+j)+xOffset;
                                allHours(24*(i-1)+j)-xOffset, allHours(24*(i-1)+j)+xOffset],...
                                [ydataMax+0.02+yOffset, ydataMax+0.02+yOffset; ...
                                ydataMax+0.02, ydataMax+0.02], ...
                                zeros(2), ...
                                'FaceColor', 'texturemap', ...
                                'EdgeColor','none',...
                                'CData', im, ...
                                'CDataMapping', 'direct', ...
                                'AlphaData', alpha, ...
                                'FaceAlpha', 'texturemap', ...
                                'Visible', 'off', 'Tag', 'weatherInfo');
                            
                            
                            if lt(j, numHoursInADay) && not(isequal((out{i, j}.icon),(out{i, j+1}.icon)))
                                % If there is a change in the icon type, then, update the 2nd
                                % and 3rd coordinates of posX, apply the patch and set the 1st
                                % and 4th coordinates of posX to the 2nd and 3rd.
                                
                                
                                for cm = 1:numUniqueIcons
                                    if isequal(uniqueIcons{cm}, out{i, j}.icon)
                                        col = iconColors(cm,:);
                                        
                                        ind = cm;
                                        
                                        iconForLegend = uniqueIcons{cm};
                                    end
                                end
                                
                                posX(2) = allHours(24*(i-1)+j+1);
                                
                                posX(3) = allHours(24*(i-1)+j+1);
                                
                                
                                pObj = patch(ax, posX, posY, col, 'Visible', 'off', 'Tag', 'weatherInfo');
                                
                                
                                if not(ismember(col, patchColors))
                                    patchColors(ind,:)=col;
                                    patchObj(ind) = pObj;
                                    legendIcons{ind} = iconForLegend;
                                end
                                
                                posX(1) = posX(2);
                                posX(4) = posX(3);
                                
                            elseif lt(allHours(24*(i-1)+j), xMatlabTime(2)) && lt( xMatlabTime(2) - allHours(24*(i-1)+j), (allHours(2,1) - allHours(1,1)) )
                                posX(2) = xMatlabTime(2);
                                posX(3) = xMatlabTime(2);
                                
                                for cm = 1:numUniqueIcons
                                    if isequal(uniqueIcons{cm}, out{i, j}.icon)
                                        col = iconColors(cm,:);
                                        ind = cm;
                                        iconForLegend = uniqueIcons{cm};
                                    end
                                end
                                
                                pObj = patch(ax, posX, posY, col, 'Visible', 'off', 'Tag', 'weatherInfo');
                                
                                
                                if not(ismember(col, patchColors))
                                    patchColors(ind)=col;
                                    patchObj(ind) = pObj;
                                    legendIcons{ind} = iconForLegend;
                                end
                                
                            elseif isequal(i, numDays) && isequal(j, numHoursInADay)
                                
                                posX(2) = allHours(end);
                                posX(3) = allHours(end);
                                
                                for cm = 1:numUniqueIcons
                                    if isequal(uniqueIcons{cm}, out{i, j}.icon)
                                        col = iconColors(cm,:);
                                        ind = cm;
                                        iconForLegend = uniqueIcons{cm};
                                    end
                                end
                                
                                pObj = patch(ax, posX, posY, col, 'Visible', 'off', 'Tag', 'weatherInfo');
                                
                                
                                if not(ismember(col, patchColors))
                                    patchColors(ind)=col;
                                    patchObj(ind) = pObj;
                                    legendIcons{ind} = iconForLegend;
                                end
                                
                            end
                            
                            
                        case 'Show ALL'
                            modulus = str2double(bearingValues);
                            max_size = yOffset;
                            marker_scale = max_size / max(modulus);
                            gca;
                            if isequal(rem(24*(numDays-1)+j,numDays),0)
                                triPlot((allHours(24*(i-1)+j)-xOffset), (double(ydataMax)), str2num(bearingValues), str2num(bearingValues), yOffset*4, marker_scale);
                            end
                            
                            % 'Wind Gust'
                            gustTxt = text(ax, allHours(24*(i-1)+j)-xOffset, ...
                                double(ydataMax+textOffset*2), gustValues, ...
                                'Clipping', 'on', 'FontSize', 8, ...
                                'Color', 'white', 'Tag', 'windgust');
                            if ~isequal(rem(24*(numDays-1)+j,numDays),0)
                                set(gustTxt, 'Visible', 'off');
                            end
                            
                            
                            % 'Wind Speed'
                            speedTxt = text(ax, allHours(24*(i-1)+j)-xOffset, ...
                                double(ydataMax+textOffset*4), speedValues, ...
                                'Clipping', 'on', 'FontSize', 8, ...
                                'Color', 'white', 'Tag', 'windspeed');
                            if ~isequal(rem(24*(numDays-1)+j,numDays),0)
                                set(speedTxt, 'Visible', 'off');
                            end
                            
                            
                            % Humidity
                            humidTxt = text(ax, allHours(24*(i-1)+j)-xOffset, ...
                                double(ydataMax+textOffset*6), humValues, ...
                                'Clipping', 'on', 'FontSize', 8, ...
                                'Color', 'white', 'Tag', 'humidity');
                            if ~isequal(rem(24*(numDays-1)+j,numDays),0)
                                set(humidTxt, 'Visible', 'off');
                            end
                            
                            % Pressure
                            presTxt = text(ax, allHours(24*(i-1)+j)-xOffset, ...
                                double(ydataMax+textOffset*8), presValues, ...
                                'Clipping', 'on', 'FontSize', 8, ...
                                'Color', 'white', 'Tag', 'pressure');
                            if lt(24*(i-1)+j, 30)
                                if le(numDays,2)
                                    if isequal(rem(j,2), 0)
                                        set(presTxt, 'Visible', 'off');
                                    end
                                else
                                    if ~isequal(rem(24*(i-1)+j,2*numDays),0)
                                        set(presTxt, 'Visible', 'off')
                                    end
                                end
                            else
                                if ~isequal(rem(24*(i-1)+j,2*numDays),0)
                                    set(presTxt, 'Visible', 'off')
                                end
                            end
                            
                            % Temperature and humidity strings to be inserted in the axes
                            tempTxt = text(ax, allHours(24*(i-1)+j)-xOffset, ...
                                double(ydataMax+textOffset*10), tempValues, ...
                                'Clipping', 'on', 'FontSize', 8, ...
                                'Color', 'white', 'Tag', 'temperature');
                            if ~isequal(rem(24*(numDays-1)+j,numDays),0)
                                set(tempTxt, 'Visible', 'off');
                            end
                            
                            imSource = append('images/', out{i, j}.icon, '.png');
                            
                            [im, colorMap, alpha] = imread( imSource );
                            
                            % 'Weather Info'
                            
                            % Create a surface with the images of the weather conditions
                            s = surface(ax, [allHours(24*(i-1)+j)-xOffset, allHours(24*(i-1)+j)+xOffset;
                                allHours(24*(i-1)+j)-xOffset, allHours(24*(i-1)+j)+xOffset],...
                                [ydataMax+textOffset*11.5+yOffset, ydataMax+textOffset*11.5+yOffset; ...
                                ydataMax+textOffset*11.5, ydataMax+textOffset*11.5], ...
                                zeros(2), ...
                                'FaceColor', 'texturemap', ...
                                'EdgeColor','none',...
                                'CData', im, ...
                                'CDataMapping', 'direct', ...
                                'AlphaData', alpha, ...
                                'FaceAlpha', 'texturemap', ...
                                'Visible', 'off', 'Tag', 'weatherInfo');
                            
                            
                            if lt(j, numHoursInADay) && not(isequal((out{i, j}.icon),(out{i, j+1}.icon)))
                                
                                for cm = 1:numUniqueIcons
                                    if isequal(uniqueIcons{cm}, out{i, j}.icon)
                                        col = iconColors(cm,:);
                                        
                                        ind = cm;
                                        
                                        iconForLegend = uniqueIcons{cm};
                                    end
                                end
                                
                                posX(2) = allHours(24*(i-1)+j+1);
                                
                                posX(3) = allHours(24*(i-1)+j+1);
                                
                                
                                pObj = patch(ax, posX, posY, col, 'Visible', 'off', 'Tag', 'weatherInfo');
                                
                                
                                if not(ismember(col, patchColors))
                                    patchColors(ind,:)=col;
                                    patchObj(ind) = pObj;
                                    legendIcons{ind} = iconForLegend;
                                end
                                
                                posX(1) = posX(2);
                                posX(4) = posX(3);
                                
                            elseif lt(allHours(24*(i-1)+j), xMatlabTime(2)) && lt( xMatlabTime(2) - allHours(24*(i-1)+j), (allHours(2, 1) - allHours(1,1)) )
                                posX(2) = xMatlabTime(2);
                                posX(3) = xMatlabTime(2);
                                
                                for cm = 1:numUniqueIcons
                                    if isequal(uniqueIcons{cm}, out{i, j}.icon)
                                        col = iconColors(cm,:);
                                        ind = cm;
                                        iconForLegend = uniqueIcons{cm};
                                    end
                                end
                                
                                pObj = patch(ax, posX, posY, col, 'Visible', 'off', 'Tag', 'weatherInfo');
                                
                                
                                if not(ismember(col, patchColors))
                                    patchColors(ind,:)=col;
                                    patchObj(ind) = pObj;
                                    legendIcons{ind} = iconForLegend;
                                end
                                
                            elseif isequal(i, numDays) && isequal(j, numHoursInADay)
                                
                                posX(2) = allHours(end);
                                posX(3) = allHours(end);
                                
                                for cm = 1:numUniqueIcons
                                    if isequal(uniqueIcons{cm}, out{i, j}.icon)
                                        col = iconColors(cm,:);
                                        ind = cm;
                                        iconForLegend = uniqueIcons{cm};
                                    end
                                end
                                
                                pObj = patch(ax, posX, posY, col, 'Visible', 'off', 'Tag', 'weatherInfo');
                                
                                
                                if not(ismember(col, patchColors))
                                    patchColors(ind,:)=col;
                                    patchObj(ind) = pObj;
                                    legendIcons{ind} = iconForLegend;
                                end
                                
                            end
                            
                            xlim([(xMatlabTime(1)-hourToLength*3) xMatlabTime(2)+hourToLength])
                            
                            initLim = ylim(ax);
                            
                            if gt(ydataMax + textOffset*11.5, (ylim(ax)))
                                ylim(ax, [initLim(1) ydataMax+yOffset*10])
                            end
                    end
                    
                end
                
            end
            
        end
        
        % If the number of hours is more than 30, use patch instead
        % of icons
        if lt(numHoursInFigure,30)
            set(findall(ax, 'Type', 'Patch', 'Tag', 'weatherInfo'), 'Visible', 'off');
            set(findall(ax, 'Type', 'Surface', 'Tag', 'weatherInfo'), 'Visible', 'on');
            
        elseif gt(numHoursInFigure,30)
            set(findall(ax, 'Type', 'Patch', 'Tag', 'weatherInfo'), 'Visible', 'on');
            set(findall(ax, 'Type', 'Surface', 'Tag', 'weatherInfo'), 'Visible', 'off');
        end
        
        
        
        % Change the text color according to the aspect mode
        aspect = get(figHandle, 'Color');
        
        if isequal(aspect, [1 1 1])
            set(findall(ax, 'Type', 'Text'), 'Color', 'k');
        else
            set(findall(ax, 'Type', 'Text'), 'Color', 'w');
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%% CREATE THE SECOND GRAPH BUT MAKE ALL OBJECTS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%% INVISIBLE
        getWeatherObj = findobj(figHandle, 'Tag', 'weatherInfo');
        
        if ~isempty(getWeatherObj)
            ax2 = copyobj(ax, figHandle);
            
            set(ax2, 'Box', 'off', 'Visible', 'off');
            set( get(ax2, 'Children'), 'Visible', 'off');
            
            legItems = findall(figHandle.Children, 'Type', 'Legend');
            legendTitles = get(legItems, 'Title');
            
            legendExist = 0;
            for i = 1:length(legendTitles)
                if strcmp('Weather conditions', legendTitles{i,1}.String)
                    % Legend has already been created
                    legendExist = 1;
                end
                
            end
            
            if isequal(legendExist,0)
                
                lgd = legend(ax2, patchObj, legendIcons, 'Location', 'best', 'Tag', 'patchlgd', 'TextColor', 'White');
                
                lgd.Title.String = 'Weather conditions';
                
                if isempty(endTime) || isequal(startTime, endTime) ||le(numHoursInFigure,30)
                    lgd.Visible = 'off';
                end
                
                % Set the text color
                if isequal(aspect, [1 1 1])
                    set(lgd, 'TextColor', 'k');
                else
                    set(lgd, 'TextColor', 'w');
                end
                
            end
            %                     set(findall(gcf, 'Type', 'Surface'), 'Visible', 'off');
            
            
        end
        
        
    end

end