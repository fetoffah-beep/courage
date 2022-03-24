function [stat_elev] = getTimeZone(latitude, longitude, time)
     latitude = string(latitude / pi * 180);
     
     longitude = string(longitude / pi * 180);
     
     baseUrl = 'https://api.opentopodata.org/v1/srtm30m?locations=';
     
     httpsUrl = strcat(baseUrl,latitude,',',longitude);
     
     webHTML = webread(httpsUrl);
  
     stat_elev = webHTML.results.elevation;
     
 end

