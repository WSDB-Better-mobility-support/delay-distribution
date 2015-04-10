function [response,delay,error]=database_connect_ofcom(request_type,latitude,longitude,orientation,...
            semiMajorAxis,SemiMinorAxis,start_freq,stop_freq,height,heightType,my_path)

% data_connect_ofcom queries the Ofcom white space database
%   Last update: 10 January 2015

% Reference:
%   P. Pawelczak et al. (2014), "Will Dynamic Spectrum Access Drain my
%   Battery?," submitted for publication.

%   Code development: Amjed Yousef Majid (amjadyousefmajid@student.tudelft.nl),
%                     Przemyslaw Pawelczak (p.pawelczak@tudelft.nl)

% Copyright (c) 2014, Embedded Software Group, Delft University of
% Technology, The Netherlands. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
% HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
% TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

error=false; %Default error value
delay=[]; %Default delay value

server_name='https://tvwsdb.broadbandappstestbed.com/json.rpc';
text_coding='"Content-Type: application/json "';

ofcom_query(request_type,latitude,longitude,orientation,...
            semiMajorAxis,SemiMinorAxis,start_freq,stop_freq,height,heightType);

my_path=regexprep(my_path,' ','\\ ');

cmnd=['/usr/bin/curl -X POST ',server_name,' -H ',text_coding,' --data-binary @',my_path,'/ofcom.json -w %{time_total}'];
[status,response]=system(cmnd);

%check for error
err = findstr('error' , response);
 if ~isempty(err)
     error = true;
end

 start_res = findstr(response , '{"jsonrpc"');
 if isempty(start_res)
     disp('Empty response ')
     error=true;
 else
     response = response(start_res:end);
 end

pos_end_query_str=findstr(response,'}');
if ~isempty(pos_end_query_str)
    delay=str2num(response((pos_end_query_str(end)+1):end));
end 
system('rm ofcom.json');

function ofcom_query(request_type,latitude,longitude,orientation,...
            semiMajorAxis,SemiMinorAxis,start_freq,stop_freq,height,heightType)

request=['{"jsonrpc": "2.0",',...
    '"method": "spectrum.paws.getSpectrum",',...
    '"params": {',...
    '"type": ',request_type,', ',...
    '"version": "0.6", ',...
    '"deviceDesc": ',...
    '{ "manufacturerId": "TuDelft", ',...
    '"modelId": "Test", ',...
    '"serialNumber": "0001", ',...
    '"etsiEnDeviceType": "A", ',...
    '"etsiEnDeviceEmissionsClass": "3", ',...
    '"etsiEnDeviceCategory": "master", ',...
    '"etsiEnTechnologyId": "466", '...
    '"rulesetIds": [ "OfcomWhiteSpacePilotV1-2013",],}, ',...
    '"location": ',...
    '{ "point": ',...
    '{ "center": ',...
    '{"latitude": ',num2str(latitude),', '...
    '"longitude": ',num2str(longitude),',}, ',...
    '"orientation": ',num2str(orientation),', ' ,...
    '"semiMajorAxis": ',num2str(semiMajorAxis),', ' ,...
    '"semiMinorAxis": ',num2str(SemiMinorAxis),', ' ,...
    '},}, ',...
    '"capabilities": { ',...
    '"frequencyRanges": [ {' ,...
    '"startHz": ',num2str(start_freq),', ',...
    '"stopHz": ',num2str(stop_freq),', ',...
    '},],},',...
    '"antenna": { ',...
    '"height":',num2str(height),', ',...
    '"heightType":',heightType,'}, ',...
    '},"id": "123456789"}'];

dlmwrite('ofcom.json',request,'');