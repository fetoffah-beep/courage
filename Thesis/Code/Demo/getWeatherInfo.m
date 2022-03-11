function [structArray] = getWeatherInfo(latitude, longitude, startTime, endTime)
     baseUrl = 'https://darksky.net/details/';
     
     structArray = struct([]);
     
     dayNum = 0;
     
     if isempty(endTime)
         endTime = startTime;
     end
     
     startTime = datetime(startTime);

     endTime = datetime(endTime);

     for i = startTime:endTime 
         dayNum = dayNum+1;
    
         time = datestr(i);   
     
         httpsUrl = strcat(baseUrl,latitude,',',longitude,'/',time, '/si12/en/');

         webHTML = webread(httpsUrl);

         neededInfo = extractAfter(extractBefore(webHTML,'startHour'), 'var hours = ');

         out = extractBetween(neededInfo, '{', '}');

         outActual = replace(out, ':', ',');

         outActual = replace(outActual, '"', '');

         outActual = replace(outActual, '{azimuth', 'azimuth');

         outActual = replace(outActual, 'solar,', '');
     
         for i = 1:length(outActual)
             tmp = strsplit(outActual{i}, ',');

             fieldValue = tmp(2:2:end);

             fields = tmp(1:2:end);

             structArray{dayNum, i} = cell2struct(fieldValue, fields, 2);
         end
     end     
 end
