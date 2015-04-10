tic;
clear all;
close all;
clc;
%%

my_path='/home/amjed/Documents/Gproject/workspace/data/WSDB_DATA'; %Path to save files (select your own)
ftsz=14; %Plot parameters
%legend_string={'GGL','MSR','SBI','OFC','NOM','CSI','FAI'}; %Create legend for the figures
legend_string={'GGL','MSR','SBI','NOM','CSI','FAI'}; %Remove ofcom

%%

longitude_interval=50; % the number of intervals
no_queries=20; %Number of queries per individual location

%Global Google parameters (refer to https://developers.google.com/spectrum/v1/paws/getSpectrum)
type='"AVAIL_SPECTRUM_REQ"';
height_ggl='30.0'; %In meters; Note: 'height' needs decimal value
agl='"AMSL"';
ggl_cnt=0; % google key counter

%Global SpectrumBridge parameters (refer to WSDB_TVBD_Interface_v1.0.pdf [provided by Peter Stanforth])
AntennaHeight='30'; %In meters; Ignored for personal/portable devices
DeviceType='3'; %Examples: 8-Fixed, 3-40 mW Mode II personal/portable; 4-100 mW Mode II personal/portable

%Global Microsoft parameters (refer to http://whitespaces.msresearch.us/api.html)
PropagationModel='"Rice"';
CullingThreshold='-114'; %In dBm
IncludeNonLicensed='true';
IncludeMicrophones='true';
UseSRTM='false';
UseGLOBE='true';
UseLRBCast='true';

%Global parameters
request_type='"AVAIL_SPECTRUM_REQ"';
orientation= 45;
semiMajorAxis = 50;
SemiMinorAxis = 50;
start_freq = 470000000;
stop_freq = 790000000;
height=7.5;
heightType = '"AGL"';

%Delay collectors
delay_google=[];
delay_mrs=[];
delay_sbi=[];
delay_ofcom=[];
delay_nominet=[];
delay_csir=[];
delay_fair=[];
% error check
ggl_err=0;
sbi_err=0;
mrs_err=0;
sbo_err=0;
nom_err=0;
csi_err=0;
fai_err=0;

%%
%Location of start and finish query
%Query start location
WSDB_data{1}.name='LO'; %London
WSDB_data{1}.latitude='51.506753';
WSDB_data{1}.longitude='-0.127686';

%Query finish location
WSDB_data{2}.name='BR'; % Bristol
WSDB_data{2}.latitude='51.431471';
WSDB_data{2}.longitude='-2.577637';

longitude_start=str2num(WSDB_data{1}.longitude); %Start of the spectrum scanning trajectory
longitude_end=str2num(WSDB_data{2}.longitude); %End of spectrum scanning trajectory
longitude_step=(longitude_end-longitude_start)/longitude_interval;
%%
inx=0; %Initialize position counter
for xx=longitude_start:longitude_step:longitude_end
    inx=inx+1;
    iny=0; %Initialize query counter
    for yy=1:no_queries
        iny=iny+1;
        fprintf('[Query no., Location no.]: %d, %d\n',iny,inx);
        %Fetch location data
        latitude=WSDB_data{1}.latitude; % latitude is fixed
        longitude=num2str(xx);
        %google----------------->>>>>>>
        latitude_us =num2str(str2num(latitude)-11);  % location shift
        longitude_us= num2str(str2num(longitude)-100);
        ggl_cnt=ggl_cnt+1;
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/google']);
        [msg_google,delay_google_tmp,error_google_tmp]=database_connect_google(...
            type,latitude_us,longitude_us,height_ggl,agl,[my_path,'/google'],ggl_cnt);
        var_name=(['google_',longitude_us,'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('Google\n');
        if error_google_tmp==0
            dlmwrite([var_name,'.txt'],msg_google,'');
            delay_google=[delay_google,delay_google_tmp];
        else
            ggl_err = ggl_err+1; 
        end
        %microsoft----------------->>>>>>>
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/microsoft']);
        [msg_microsoft,delay_mrs_tmp,error_microsoft_tmp]=...
            database_connect_microsoft(longitude_us,latitude_us,PropagationModel,...
            CullingThreshold,IncludeNonLicensed,IncludeMicrophones,...
            UseSRTM,UseGLOBE,UseLRBCast,[my_path,'/microsoft']);
        var_name=(['microsoft_',num2str(longitude_us),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('Microsoft\n')
        if error_microsoft_tmp==0
            dlmwrite([var_name,'.txt'],msg_microsoft,'');
            delay_mrs=[delay_mrs,delay_mrs_tmp];
        else
            mrs_err = mrs_err+1;
        end
        %spectrumBridge----------------->>>>>>>>>>>>
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/spectrumbridge']);
        
        [msg_spectrumbridge,~]=database_connect_spectrumbridge_register(...
            AntennaHeight,DeviceType,latitude_us,longitude_us,[my_path,'/spectrumbridge']);
        
        [msg_spectrumbridge,delay_sbi_tmp,error_spectrumbridge_tmp]=database_connect_spectrumbridge(DeviceType,latitude_us,longitude_us);
        var_name=(['spectrumbridge_',longitude_us,'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('SpectrumBridge\n')
        fprintf('sbi delay %d', delay_sbi_tmp)
        if error_spectrumbridge_tmp==0
            dlmwrite([var_name,'.txt'],msg_spectrumbridge,'');
            delay_sbi=[delay_sbi,delay_sbi_tmp];
        else
            sbi_err = sbi_err+1;
        end
        %ofcom ----------------->>>>>>>
%         fprintf('ofcom\n')
%         instant_clock=clock; %Start clock again if scanning only one database
%         cd([my_path,'/ofcom']);
%         
%         [msg_ofcom,delay_ofcom_tmp,error_ofcom_tmp]=...
%             database_connect_ofcom(request_type,latitude,longitude,orientation,...
%             semiMajorAxis,SemiMinorAxis,start_freq,stop_freq,height,heightType,[my_path,'/ofcom']);
%         
%         var_name=(['ofcom_',longitude,'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
%         if error_ofcom_tmp==0;
%             dlmwrite([var_name,'.txt'],msg_ofcom,'');
%             delay_ofcom=[delay_ofcom,delay_ofcom_tmp];
%         end
        % nominet------------>>>>
        fprintf('nominet\n')
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/nominet']);
        
        [msg_nominet,delay_nominet_tmp,error_nominet_tmp]=...
            database_connect_nominet(latitude,longitude,[my_path,'/nominet']);
        
        var_name=(['nominet_',longitude,'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        if error_nominet_tmp==0
            dlmwrite([var_name,'.txt'],msg_nominet,'');
            delay_nominet=[delay_nominet,delay_nominet_tmp];
        else 
            nom_err = nom_err+1;
        end
        % CSIR south Africa --------->>>>>>
        fprintf('csir\n')
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/csir']);
        latitude_csir =num2str(str2num(latitude)-75);
        longitude_csir= num2str(str2num(longitude)+24);
        [msg_csir,delay_csir_tmp,error_csir_tmp]=...
            database_connect_csir( latitude_csir ,longitude_csir,[my_path,'/csir']);
        
        var_name=(['csir_',num2str(longitude_csir),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        if error_csir_tmp==0
            dlmwrite([var_name,'.txt'],msg_csir,'');
            delay_csir=[delay_csir,delay_csir_tmp];
        else
            csi_err = csi_err+1;
        end
        %fairspectrum------------------->>>>>>>>
        fprintf('fairspectrum\n')
        instant_clock=clock; %Start clock again if scanning only one database
        cd([my_path,'/fairspectrum']);
        [msg_fair,delay_fair_tmp,error_fair_tmp]=...
            database_connect_fairspectrum( latitude ,longitude,[my_path,'/fairspectrum']);
        
        var_name=(['fairspectrum_',longitude,'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        fprintf('fairspectrum\n')
        if error_fair_tmp==0
            dlmwrite([var_name,'.txt'],msg_fair,'');
            delay_fair=[delay_fair,delay_fair_tmp];
        else
            fai_err = fai_err+1;
        end
        
    end
    %Assign delay per location per WSDB to a new variable
    delay_google_loc{inx}=delay_google;
    delay_mrs_loc{inx}=delay_mrs;
    delay_sbi_loc{inx}=delay_sbi;
    delay_ofcom_loc{inx}=delay_ofcom;
    delay_nominet_loc{inx}=delay_nominet;
    delay_csir_loc{inx}=delay_csir;
    delay_fair_loc{inx}=delay_fair;
    delay_google=[];
    delay_mrs=[];
    delay_sbi=[];
    delay_ofcom=[];
    delay_nominet=[];
    delay_csir=[];
    delay_fair=[];
end
%%
% average delays collectors 
google_delay_per_loc=[];
mrs_delay_per_loc=[];
sbi_delay_per_loc=[];
ofcom_delay_per_loc=[];
nominet_delay_per_loc=[];
csir_delay_per_loc=[];
fair_delay_per_loc=[];
for xx=1:inx
    mtmp_google=delay_google_loc{xx};
    mtmp_mrs=delay_mrs_loc{xx};
    mtmp_sbi=delay_sbi_loc{xx};
    mtmp_ofcom=delay_ofcom_loc{xx};
    mtmp_nominet=delay_nominet_loc{xx};
    mtmp_csir=delay_csir_loc{xx};
    mtmp_fair=delay_fair_loc{xx};
    google_delay_per_loc=[google_delay_per_loc,mean(mtmp_google)];
    mrs_delay_per_loc=[mrs_delay_per_loc,mean(mtmp_mrs)];
    sbi_delay_per_loc=[sbi_delay_per_loc,mean(mtmp_sbi)];
    ofcom_delay_per_loc=[ofcom_delay_per_loc,mean(mtmp_ofcom)];
    nominet_delay_per_loc=[nominet_delay_per_loc,mean(mtmp_nominet)];
    csir_delay_per_loc=[csir_delay_per_loc,mean(mtmp_csir)];
    fair_delay_per_loc=[fair_delay_per_loc,mean(mtmp_fair)];
end
%%
%Plot distribution curves
%Plot figures
%------------google-------------->>>>
figure('Position',[440 378 560 620/3]);
[fg,xg]=ksdensity(google_delay_per_loc,'support','positive');
fg=fg./sum(fg);
plot(xg,fg , 'g-', 'LineWidth' , 2);
hold on
%------------mrs-------------->>>>
[fg,xg]=ksdensity(mrs_delay_per_loc,'support','positive');
fg=fg./sum(fg);
plot(xg,fg , 'b-.', 'LineWidth' , 2);
%------------sbi-------------->>>>
[fg,xg]=ksdensity(sbi_delay_per_loc,'support','positive');
fg=fg./sum(fg);
plot(xg,fg , 'k:', 'LineWidth' , 2);
%------------ofcom-------------->>>>
%[fg,xg]=ksdensity(ofcom_delay_per_loc,'support','positive');
%fg=fg./sum(fg);
%plot(xg,fg , 'r--', 'LineWidth' , 2);
%-----------------nominet----------->>>>>
[fg,xg]=ksdensity(nominet_delay_per_loc,'support','positive');
fg=fg./sum(fg);
plot(xg,fg , 'k-', 'LineWidth' , 2);
%-----------------csir------------->>>>
[fg,xg]=ksdensity(csir_delay_per_loc,'support','positive');
fg=fg./sum(fg);
plot(xg,fg , 'c-.', 'LineWidth' , 2);
%---------------fairspectrum--------->>>>>
[fg,xg]=ksdensity(fair_delay_per_loc,'support','positive');
fg=fg./sum(fg);
plot(xg,fg , 'm--.', 'LineWidth' , 2);
hold off
xlabel('Response time (sec)','FontSize',ftsz);
ylabel('Probability','FontSize',ftsz);
leg = legend(legend_string,'FontSize',ftsz);
set(gca,'FontSize',ftsz);
set(leg,'FontSize',12)
set(gca,'xTick',[0 0.5 [1:6]])
%% Save matlab data
fprintf('ggl_err=%d\nmrs_err=%d\nsbi_err=%d nom_err=%dcsi_err=%dfai_err=%d'...
    ,ggl_err , mrs_err , sbi_err , nom_err , csi_err , fai_err);   
cd(my_path);
save('delay-distribution');
%%
['Elapsed time: ',num2str(toc/60),' min']