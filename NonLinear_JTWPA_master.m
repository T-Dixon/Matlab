
clear
username = getenv('USER');
wrspice = '/usr/local/xictools/bin/wrspice';
timestamp = datestr(now, 'dd,mmmyyyy_HH:MM');
mkdir(['/home/',username,'/Documents/WRspice/']);
mkdir(['/home/',username,'/Documents/WRspice/Outputs/']);
mkdir(['/home/',username,'/Documents/WRspice/Outputs/',timestamp]);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % DEFINE PARAMETERS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

circuittype = 'Single Tone Spectroscopy of JTWPA';
critcurrent = 5;
juncap = 60;
shuntres = 2;
Lg = 57;
Cg = 100;
N = 1250;
Idc = 14.068;
rfamp = 1;
rffreq = 12;
rtype = 0;
sigphase = 0;
variance=0;
%measurment time step in picoseconds
dt = 1;
%Simulation end time in nanoseconds
t_end = 20;
%Measurement start time in nanoseconds
t_meas_start = 10;
%Measurmeent end time in nanoseconds
t_meas_end = 20;
param = [Idc, Cg, Lg, rfamp,rffreq,juncap,rtype];


S = input('First variable to sweep (Idc/Cg/Lg/rfamp/rffreq/juncap/rtype): ','s');
X = find(strcmp(S,{'Idc','Cg','Lg','rfamp','rffreq','juncap','rtype'}));
sweepmin_1 = str2double(input('please enter minimum sweep value (uA,fF,pH,uA,GHz,fF,0-4): ','s'));
sweepmax_1 = str2double(input('please enter maximum sweep value (uA,fF,pH,uA,GHz,fF,0-4): ','s')); 
sweepstep_1 = str2double(input('please enter sweep step value (uA,fF,pH,uA,GHz,fF,0-4): ','s'));
paramstr_1 = {'Idc','Cg','Lg','rfamp','rffreq','juncap','rtype'};
paramstr_units_1 = {'uA','fF','pH','uA','GHz','fF','0-4'};
sweeprange_1 = sweepmin_1:sweepstep_1:sweepmax_1;
%sweeprange_1 = [ 0.5, 1, 2, 6];
paramstr_1 = paramstr_1{X};


S = input('Second variable to sweep (Idc/Cg/Lg/rfamp/rffreq/juncap/rtype): ','s');
XX = find(strcmp(S,{'Idc','Cg','Lg','rfamp','rffreq','juncap','rtype'}));
sweepmin_2 = str2double(input('please enter minimum sweep value (uA,fF,pH,uA,GHz,fF,0-4): ','s'));
sweepmax_2 = str2double(input('please enter maximum sweep value (uA,fF,pH,uA,GHz,fF,0-4): ','s')); 
sweepstep_2 = str2double(input('please enter sweep step value (uA,fF,pH,uA,GHz,fF,0-4): ','s'));
paramstr_2 = {'Idc','Cg','Lg','rfamp','rffreq','juncap','rtype'};
paramstr_units_2 = {'uA','fF','pH','uA','GHz','fF','0-4'};
sweeprange_2 = sweepmin_2:sweepstep_2:sweepmax_2;
paramstr_2 =  paramstr_2{XX};

sweep_n=1;

profile_data(length(sweeprange_1)*length(sweeprange_2)).name = 'init' %initialise data structure
system('echo ********** | sudo -S -k whoami');

for loopVar_1 = sweeprange_1;
    param(X) = loopVar_1;
    loopVarFile_1 = strrep(num2str(loopVar_1),'.',',');


    for loopVar_2 = sweeprange_2;
        param(XX) = loopVar_2;
        loopVarFile_2 = strrep(num2str(loopVar_2),'.',',');

        %WRspice Simulation and raw data writer
        [plotpath,time_path,Vt_full_path_out,It_full_path_out,Phit_full_path_out,Vt_wait_path_out,It_wait_path_out,I_initial_path_out,Rterm] = NonLinear_JTWPA_Sim_Setup(t_meas_start,t_meas_end,dt,t_end,Cg,circuittype,critcurrent,Idc,Lg,N,rfamp,param,rffreq,shuntres,rtype,sigphase,timestamp,username,variance,wrspice,loopVar_1,loopVarFile_1,loopVar_2,loopVarFile_2,paramstr_1,paramstr_2);
        %Simulation data analyser
        [I_f_meas_path, Vf_meas_path, f_path,If_0_path] = NonLinear_JTWPA_Analyser(t_meas_start,t_meas_end,N,Vt_wait_path_out,It_wait_path_out,time_path,plotpath,I_initial_path_out,Phit_full_path_out,param,paramstr_1,paramstr_2,loopVarFile_1,loopVarFile_2)

        sweep_n=sweep_n+1;
        system('echo Archie2010 | sudo -S -k whoami');
        command = 'echo 3 | sudo tee /proc/sys/vm/drop_caches';
        system(command);    

    end

    
end


% save(['/home/',username,'/Documents/WRspice/Outputs/',timestamp,'/Workspace.mat'])
system('echo ********** | sudo -S -k whoami');
command = 'echo 3 | sudo tee /proc/sys/vm/drop_caches';
system(command);
