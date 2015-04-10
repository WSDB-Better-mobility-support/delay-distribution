function [ response,delay,error ] = database_connect_csir(lat,long ,my_path)
%DATABASE_CONNECT_NOMINET Summary of this function goes here
%   Detailed explanation goes here

error=false; %Default error value
delay=[]; %Default delay value

server_name='http://whitespaces.meraka.csir.co.za/PawsService';
text_coding='"Content-Type: application/json; charset=utf-8"';


height='3.0';
fccId='FCC114';
model_num='MN510';
serial_num='SN510';
%lat=-24.286049;
%long=24.3749782;
id='01';

%%
cd(my_path)
csir_query(lat,long,height,fccId,model_num,serial_num,id);

cmnd=['/usr/bin/curl -X POST ',server_name,' -H ',text_coding,' --data-binary @',my_path,'/csir.json -w %{time_total}'];
[status,response]=system(cmnd);

start_res = findstr('{' , response);
if ~isempty(start_res)
response = response(start_res(1):end);
end
     end_query_str=',"jsonrpc":"2.0"}';
     pos_end_query_str=findstr(response,end_query_str);
     length_end_query_str=length(end_query_str); 
     delay=str2num(response(pos_end_query_str+length_end_query_str:end));
     %response(pos_end_query_str+length_end_query_str:end)=[];

 error_str = findstr('font-family' , response);    

 if ~isempty(error_str)
     error = true;
 end
    
system('rm csir.json');
end
function csir_query(lat,long,height,fccId,model_num,serial_num,id)

request=['{"jsonrpc": "2.0",'...
'"method": "spectrum.paws.getSpectrum",'...
'"params": {'...
'"type": "AVAIL_SPECTRUM_REQ",'...
'"version": "1.0",'...
'"deviceDesc": {'...
'"serialNumber": "',serial_num,'",'...
'"fccId": "',fccId,'",'...
'"modelId":"',model_num,'"},'...
'"location": {"point": {"center": {'...
'"latitude": ' , num2str(lat) , ' , '...
'"longitude": ' , num2str(long) , ' }}},'...
'"antenna": {'...
'"height": ',height,','...
'"heightType": "AGL"}},'...
'"id":"spetrum-id-',id,'"'...
'}'];
dlmwrite('csir.json',request,'');
end

