function [response , delay, error ] = database_connect_fairspectrum(latitude,longitude,my_path)
%DATABASE_CONNECT_FAIRSPECTRUM Summary of this function goes here
%   Detailed explanation goes here
error=false;
delay=[];

server_name = 'https://fswsdb.com:443/wsd/index.php';
text_coding='"Content-Type: application/json; charset=utf-8"';

fairspectrum_db(latitude,longitude);

cmnd=['/usr/bin/curl -X POST ',server_name,' -k -H ',text_coding,' --data-binary @',my_path,'/fairspectrum.json -w %{time_total}'];
[status,response]=system(cmnd);

start_res = findstr('{' , response);
if ~isempty(start_res)
response = response(start_res(1):end);
end
%check for error
err = findstr('error' , response);
 if ~isempty(err)
     error = true;
end

pos_end_query_str=findstr(response,'}');
if ~isempty(pos_end_query_str)
delay=str2num(response((pos_end_query_str(end)+1):end));
end
system('rm fairspectrum.json')
end

function fairspectrum_db(latitude,longitude)

request=['{"method": "spectrum.paws.getSpectrum",',... 
    '"params": {',... 
        '"deviceDesc": { ',...
            '"serialNumber": "fb4ab169-f8bf-49d0-9852-e69e044d1111",',...
            '"fccId": "71",',...
            '"other": {',... 
                '"etsiEnDeviceEmissionsClass": 5 ',...
            '} ',...
        '}, ',...
        '"location": { ',...
            '"point": { ',...
                '"center": { ',...
                    '"latitude":',latitude,', ',...
                    '"longitude":',longitude,'}}}, ',...
        '"owner": { ',...
            '"owner": { ',...
                '"fn": "Arto Kivinen", ',...
                '"org": { ',...
                    '"text": "Fairspectrum" ',...
                '}, ',...
                '"adr": { ',...
                    '"pobox": "", ',...
                    '"street": "Haapaniemenkatu 7 9 B", ',...
                    '"locality": "Helsinki", ',...
                    '"region": "Uusimaa", ',...
                    '"code": "00530", ',...
                    '"country": "FI" ',...
                '}, ',...
                '"tel": {',... 
                    '"uri": "+ 45445454599 " ',...
                '}, ',...
                '"email": { ',...
                    '"text": "arto.kivinen@fairspectrum.com"',...
                '} ',...
            '}, ',...
            '"operator": { ',...
                '"fn": "Arto Kivinen", ',...
                '"org": { ',...
                    '"text": "Fairspectrum" ',...
                '}, ',...
                '"adr": { ',...
                    '"pobox": "", ',...
                    '"street": "Haapaniemenkatu 7 9 B", ',...
                    '"locality": "Helsinki", ',...
                    '"region": "Uusimaa", ',...
                    '"code": "00530", ',...
                    '"country": "FI" ',...
                '}, ',...
                '"tel": {',... 
                    '"uri": "+ 45445454599 " ',...
                '}, ',...
                '"email": { ',...
                    '"text": "arto.kivinen@fairspectrum.com"',...
               ' } ',...
            '} ',...
        '}, ',...
        '"antenna": { ',...
            '"height": 2.0, ',...
            '"heightType": "AGL" ',...
        '}, ',...
       ' "type": "AVAIL_SPECTRUM_REQ", ',...
        '"version": "1.0/draft 12" ',...
    '}, ',...
    '"jsonrpc": "2.0", ',...
    '"id": "2" ',...
'}'];
dlmwrite('fairspectrum.json',request,'');
end

