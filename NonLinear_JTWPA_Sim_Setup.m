function [plotpath,time_path,Vt_full_path_out,It_full_path_out,Phit_full_path_out,Vt_wait_path_out,It_wait_path_out,I_initial_path_out,Rterm] = NonLinear_JTWPA_Sim_Setup(t_meas_start,t_meas_end,dt,t_end,Cg,circuittype,critcurrent,Idc,Lg,N,rfamp,param,rffreq,shuntres,rtype,sigphase,timestamp,username,variance,wrspice,loopVar_1,loopVarFile_1,loopVar_2,loopVarFile_2,paramstr_1,paramstr_2)

mkdir(['/home/',username,'/Documents/WRspice/Outputs/',timestamp,'/Simulation_sweep/']);

i=1;
jj=1;
vdata = (N-10)/10;

bad_coding = 1;

circuitpath=strcat('/home/',username,'/Documents/WRspice/Outputs/',timestamp,'/Simulation_sweep/',paramstr_1,'_',paramstr_2,'_sweep/',paramstr_1,'=',loopVarFile_1,'/',paramstr_2,'=',loopVarFile_2,'/Circuit/');
rawdatapath=strcat('/home/',username,'/Documents/WRspice/Outputs/',timestamp,'/Simulation_sweep/',paramstr_1,'_',paramstr_2,'_sweep/',paramstr_1,'=',loopVarFile_1,'/',paramstr_2,'=',loopVarFile_2,'/RawData/');
processeddatapath=strcat('/home/',username,'/Documents/WRspice/Outputs/',timestamp,'/Simulation_sweep/',paramstr_1,'_',paramstr_2,'_sweep/',paramstr_1,'=',loopVarFile_1,'/',paramstr_2,'=',loopVarFile_2,'/ProcessedData/');
plotpath=strcat('/home/',username,'/Documents/WRspice/Outputs/',timestamp,'/Simulation_sweep/',paramstr_1,'_',paramstr_2,'_sweep/',paramstr_1,'=',loopVarFile_1,'/',paramstr_2,'=',loopVarFile_2,'/Plots/');
mkdir(circuitpath);
mkdir(rawdatapath);
mkdir(plotpath);
mkdir(processeddatapath);

Rterm = sqrt((param(3)*10^-12)/(param(2)*10^-15));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOU MAY WANT TO CHANGE YOUR KEY BINDINGS TO WINDOWS
% HOME >> PREFERENCES >> KEYBOARD >> CHANGE(EMACS --> WINDOWS)
%
% WRITING THE SINGLE JUNCTION FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'JTWPA_single_tone_spectroscopy.cir';
circuitfile = fopen(filename,'w');
fprintf(circuitfile,'*** %s \r\n\r\n',circuittype);

fprintf(circuitfile,'.model jj0 jj(rtype=%i, icrit=%0.4fuA, cap=%0.4ffF) \r\n',param(7),critcurrent,param(6));
fprintf(circuitfile,'*SQUID embedded transmission line \r\nIrf 0 1 sin(0 %0.4fuA %0.4fGHz 9ns 0 0) \r\n\r\nVmeas0 1 2 0V\r\nRtermfront 2 0 %0.4fOhm\r\nVmeas1 2 3 0V\r\n\r\n',param(4),param(5),Rterm);

for j = 2:1:N+1;
    delta=(rand-0.5)*2*variance;
    fprintf(circuitfile,'*Flux Biasing \r\nIdc%i 0 %i pwl(0 0uA 5ns %0.4fuA) \r\nLflux%i %i 0 %0.4fpH \r\nK%i Lg%i Lflux%i 1\r\n\r\n',j,N*100+j, param(1),j,N*100+j, param(3),j,j,j);
    fprintf(circuitfile,'Cg%i %i 0 %0.4ffF \r\nLg%i %i %i %0.4fpH\r\nB%i %i %i %i jj0 \r\nCgg%i %i 0 %0.4ffF\r\nVmeas%i %i %i 0V\r\n\r\n',j,2*j-1,(Cg+Cg*delta)*0.5,j,2*j-1,2*j,Lg,j,2*j-1,2*j,(20*N)+j-1,j,2*j,(Cg+Cg*delta)*0.5,j,2*j,2*j+1);
    
end

fprintf(circuitfile,'\r\n');
fprintf(circuitfile,'*Termination Resistor \r\nRtermend %i 0 %0.4fOhm \r\n\r\n',2*N+3,Rterm);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AC INPUTS: Iinput N1 N12 sin(offset, amplitude, frequency, timedealy, damping, phase delay)
%% ALSO WE CAN EITHER MEASURE THE FULL SIMULATION INCLUDING RAMP OR MAKE TRANSIENT ANALYSIS AFTER RAMP 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(circuitfile,'.tran 1p %0.4fn %0.4fn uic\r\n.control \r\nset maxdata = 8e8 \r\nrun \r\n\r\n',t_meas_end,0);
%fprintf(circuitfile,'.tran 1p 10n \r\n.control \r\nset maxdata = 8e8 \r\nrun \r\n\r\n');
fprintf(circuitfile,'print /printnoheaders time > %stime.txt\r\nprint /printnoheaders Vmeas0#branch Vmeas1#branch > %sI_initial.txt \r\n\r\n',rawdatapath,rawdatapath);

% DATA OUT PRINTED TO .TXT FILES

% DATA OUT PRINTED TO .TXT FILES

%VOLTAGE AT EVRY NODE
for j = 0:1:vdata;
Vdataout = sprintf('V(%i-%i).txt',10*j+1,10*j+10);
fprintf(circuitfile,'print /printnoheaders ');
for k = 1:1:10
fprintf(circuitfile,'v(%i) ',20*j+2*k+2);
end
fprintf(circuitfile,'> %s%s \r\n\r\n',rawdatapath,Vdataout);
end

%PHASE AT EVERY NODE
%PHASE AT EVERY NODE
for j = 0:1:vdata
Phidataout = sprintf('Phi(%i-%i)-t.txt',10*j+20*N+1,10*j+20*N+10);
fprintf(circuitfile,'print /printnoheaders ');
for k = 1:1:10
fprintf(circuitfile,'v(%i) ',20*N+10*j+k);
end
fprintf(circuitfile,'> %s%s \r\n\r\n',rawdatapath,Phidataout);
end


%CURRENT THROUGH ARRAY NODES
for j = 0:1:vdata;
Vdataout = sprintf('I(%i-%i).txt',10*j+1,10*j+10);
fprintf(circuitfile,'print /printnoheaders ');
for k = 1:1:10
fprintf(circuitfile,'Vmeas%i#branch ',10*j+k+1);
end
fprintf(circuitfile,'> %s%s \r\n\r\n',rawdatapath,Vdataout);
end



fprintf(circuitfile,'.endc\r\n');
fclose(circuitfile);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MOVE THIS FILE TO THE OUTPUTS CIRCUIT FOLDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
movefile(filename, circuitpath);
circuit = strcat(circuitpath,filename);
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SYSTEM(yakety_yak) WILL LITERALLY OPEN A TERMINAL
%% AND TYPE yakety_yak THEN PRESS ENTER, THUS IF
%% YOU KNOW A TERMINAL COMMAND WE CAN RUN IT FROM
%% MATLAB THIS IS HOW WE RUN WRspice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

command = strcat(wrspice,'<',circuit);
system(command);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% THESE FILEID'S HAVE CAUSED ME A HEADACHE
%% THIS SECTION IS A BIT WOOLY AND NEEDS WORK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j = 0:1:vdata;
Vdataout = sprintf('V(%i-%i).txt',10*j+1,10*j+10);
read_data = dlmread(sprintf('%s%s',rawdatapath,Vdataout));
for k = 1:1:10;
Vtdata(:,10*j+k) = read_data(:,k);
end
end

bad_coding = 0;
for j = 0:1:vdata;
Idataout = sprintf('I(%i-%i).txt',10*j+1,10*j+10);
read_data = dlmread(sprintf('%s%s',rawdatapath,Idataout));
for k = 1:1:10;
Itdata(:,10*j+k) = read_data(:,k);
end
end

bad_coding = 0;
for j = 0:1:vdata;
Phit_dataout = sprintf('I(%i-%i).txt',10*j+1,10*j+10);
read_data = dlmread(sprintf('%s%s',rawdatapath,Phit_dataout));
for k = 1:1:10;
Phitdata(:,10*j+k) = read_data(:,k);
end
end

time_path = [rawdatapath,'time.txt'];
time = dlmread(time_path);
I_initial = dlmread([rawdatapath,'I_initial.txt']);
dt = time(2,1) - time(1,1);
T = time(length(time),1) - time(1,1);
n=length(time);
meas_start_n = t_meas_start*10^-9/dt+1;
meas_end_n = t_meas_end*10^-9/dt+1;


full_processed_datapath=strcat('/home/',username,'/Documents/WRspice/Outputs/',timestamp,'/Simulation_sweep/',paramstr_1,'_',paramstr_2,'_sweep/',paramstr_1,'=',loopVarFile_1,'/',paramstr_2,'=',loopVarFile_2,'/ProcessedData/AllTimeData/');
mkdir(full_processed_datapath);

dlmwrite([full_processed_datapath,'V_t_data.txt'],Vtdata,'delimiter','\t');
dlmwrite([full_processed_datapath,'I_t_data.txt'],Itdata,'delimiter','\t');
dlmwrite([full_processed_datapath,'Phi_t_data.txt'],Phitdata,'delimiter','\t');
Phit_full_path_out = [full_processed_datapath,'Phi_t_data.txt'];
Vt_full_path_out = [full_processed_datapath,'V_t_data.txt'];
It_full_path_out = [full_processed_datapath,'I_t_data.txt'];



wait_processed_datapath=strcat('/home/',username,'/Documents/WRspice/Outputs/',timestamp,'/Simulation_sweep/',paramstr_1,'_',paramstr_2,'_sweep/',paramstr_1,'=',loopVarFile_1,'/',paramstr_2,'=',loopVarFile_2,'/ProcessedData/MeasurementTimeData/');
mkdir(wait_processed_datapath);

Vtdata_wait = Vtdata(meas_start_n:meas_end_n,:);
Itdata_wait = Itdata(meas_start_n:meas_end_n,:);



clear Vtdata Itdata

dlmwrite([wait_processed_datapath,'V_t_data.txt'],Vtdata_wait,'delimiter','\t');
dlmwrite([wait_processed_datapath,'I_t_data.txt'],Itdata_wait,'delimiter','\t');
Vt_wait_path_out = [wait_processed_datapath,'V_t_data.txt'];
It_wait_path_out = [wait_processed_datapath,'I_t_data.txt'];

clear Vtdata_wait Itdata_wait

I_initial_wait = I_initial(meas_start_n:meas_end_n,:);

initial_processed_datapath=strcat('/home/',username,'/Documents/WRspice/Outputs/',timestamp,'/Simulation_sweep/',paramstr_1,'_',paramstr_2,'_sweep/',paramstr_1,'=',loopVarFile_1,'/',paramstr_2,'=',loopVarFile_2,'/ProcessedData/rfSourceData/');
mkdir(initial_processed_datapath);

dlmwrite([initial_processed_datapath,'I_source_t_data.txt'],I_initial_wait,'delimiter','\t');
I_initial_path_out = [initial_processed_datapath,'I_source_t_data.txt'];

clear I_initial_wait
