function [structArray] = getWeatherConditions(latitude, longitude, time)
     baseUrl = 'https://darksky.net/details/';
     
     httpsUrl = strcat(baseUrl,latitude,',',longitude,'/',time, '/si12/en/');
     
     webHTML = webread(httpsUrl);
     
     neededInfo = extractAfter(extractBefore(webHTML,'cityName'), 'conditions = ');
     
     out = extractBetween(neededInfo, '{', '}');
     
     outActual = replace(out, ':', ',');
     
     outActual = replace(outActual, '"', '');
     
     outActual = replace(outActual, '-', '_');
     
     structArray = struct([]);
     
     for i = 1:length(outActual)
         tmp = strsplit(outActual{i}, ',');
         
         fieldValue = tmp(2:2:end);
         
         fields = tmp(1:2:end);
         
         structArray{i} = cell2struct(fieldValue, fields, 2);
     end
    
 end
