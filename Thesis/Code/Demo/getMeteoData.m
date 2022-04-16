function getMeteoData(latitude, longitude, startTime, endTime, file_name)

    % Get the weather data
    out = getWeatherInfo(latitude, longitude, startTime, endTime);
    
    % Get the elevation of the station
    stat_elev = getGeodHeight(latitude, longitude);
    
    % Get the size of the data retrieved from the web
    [numDays, numHoursInADay] = size(out);
    
    % Initialise the needed variables.
    temperature = zeros(numDays * numHoursInADay, 1);
    pressure = zeros(numDays * numHoursInADay, 1);
    humidity = zeros(numDays * numHoursInADay, 1);
    windSpeed = zeros(numDays * numHoursInADay, 1);
    windBearing = zeros(numDays * numHoursInADay, 1);
    rainIntensity = zeros(numDays * numHoursInADay, 1);
    allHours = zeros(numDays * numHoursInADay, 1);
    
    % Fill the variables with the actual values obtained from the web
    for i=1:numDays
        for j = 1:numHoursInADay
            temperature(24*(i-1)+j) = str2double(out{i,j}.temperature);
            pressure(24*(i-1)+j) = str2double(out{i,j}.pressure);
            humidity(24*(i-1)+j) = str2double(out{i,j}.humidity);
            windSpeed(24*(i-1)+j) = str2double(out{i,j}.windSpeed);
            windBearing(24*(i-1)+j) = str2double(out{i,j}.windBearing);
            rainIntensity(24*(i-1)+j) = str2double(out{i,j}.precipIntensity);
            allHours(24*(i-1)+j) = str2double(out{i,j}.time);
        end
    end
    
    % Convert the all the hours in the days to matlab time
    allHours = GPS_Time(uint32(allHours), 0, 1, 1);
    mds = Meteo_Data;
    mds.setName(file_name);
    mds.setRinType(3);
    mds.setData(allHours, [pressure temperature humidity windBearing windSpeed rainIntensity], [Meteo_Data.PR Meteo_Data.TD Meteo_Data.HR Meteo_Data.WD Meteo_Data.WS Meteo_Data.RR]);
    mds.setValid(true);
    [x, y, z] = geod2cart(latitude, longitude, stat_elev);
    mds.setCoordinates([x, y, z]  );
    mds.export(strcat(file_name, '${DOY}.${YY}m'));
    
end
