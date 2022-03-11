function [outActual] = getTimeZone(latitude, longitude, time)
     baseUrl = 'https://darksky.net/details/';
     
     httpsUrl = strcat(baseUrl,latitude,',',longitude,'/',time, '/si12/en/');
     
     webHTML = webread(httpsUrl);
  
     neededInfo = extractAfter(extractBefore(webHTML, 'units = '), 'tz_offset = ');
     
     outActual = replace(neededInfo, ',', '');
     
     outActual = str2double(outActual);
     
 end
