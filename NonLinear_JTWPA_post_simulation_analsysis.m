clear
close all

Z = sqrt((57*10^-12)/(100*10^-15));
phi0 = 2.067833848*10^-15;

location = uigetdir;
sim_location = [location,'/Simulation_sweep/'];


sweep_type = dir(sim_location);
sweep_type = sweep_type(~ismember({sweep_type.name}, {'.', '..'}));
sweep_type_string = strsplit(sweep_type.name,'_');
sweep1_string = string(sweep_type_string(1));
sweep2_string = string(sweep_type_string(2));

sweep1_folders = dir([sweep_type.folder,'/',sweep_type.name,'/']);
sweep1_folders = sweep1_folders(~ismember({sweep1_folders.name}, {'.', '..'}));

sweep2_folders = dir([sweep_type.folder,'/',sweep_type.name,'/',sweep1_folders.name,'/']);
sweep2_folders = sweep2_folders(~ismember({sweep2_folders.name}, {'.', '..'}));


for m=1:length(sweep1_folders)
    
    
    for n=1:length(sweep2_folders)
        
        time = dlmread([sweep1_folders(m).folder,'/',sweep1_folders(m).name,'/',sweep2_folders(n).name,'/RawData/time.txt']);
        data_struct{m,n}.I_t_meas = dlmread([sweep1_folders(m).folder,'/',sweep1_folders(m).name,'/',sweep2_folders(n).name,'/ProcessedData/MeasurementTimeData/I_t_data.txt'])
        data_struct{m,n}.f_meas = dlmread([sweep1_folders(m).folder,'/',sweep1_folders(m).name,'/',sweep2_folders(n).name,'/ProcessedData/MeasurementTimeData/f.txt'])
 
        data_struct{m,n}.V_f = dlmread([sweep1_folders(m).folder,'/',sweep1_folders(m).name,'/',sweep2_folders(n).name,'/ProcessedData/MeasurementTimeData/V_f.txt'])
 

        dim=1;
        fft_n=length(time);
        
        
        mag_Ifft_han_double_sided = abs(fft(data_struct{m,n}.I_t_meas.*hanning(length(data_struct{m,n}.I_t_meas)),fft_n,dim)).*(1/sum(hanning(length(data_struct{m,n}.I_t_meas))));
        
        
        mag_Ifft_han_single_sided = 2*mag_Ifft_han_double_sided(1:fft_n/2+1,:);
        clear mag_Ifft_han_double_sided
        data_struct{m,n}.I_f_meas = mag_Ifft_han_single_sided;
        clear mag_Ifft_han_single_sided
        
        
        
        N=length(data_struct{1}.I_f_meas(1,:))
      
        n=n+1;
    end
    
    m=m+1;
end

mean_200GHz = mean(data_struct{1}.I_f_meas(1:2000,:)');
cut_off_indices = find(mean_200GHz<mean_200GHz(1)/100);
cut_off_index = min(cut_off_indices);
cut_off_frequency = data_struct{1}.f_meas(cut_off_index)*10^-9;

[sx,sy] = meshgrid(data_struct{1}.f_meas(1:2000),1:N);
set(gcf,'renderer','zbuffer')
s=surf(sx*10^-9,sy,data_struct{1}.I_f_meas(1:2000,1:N)'.*10^6);
s.LineStyle = 'none';
s.FaceColor = 'interp';
view([10 -20 20]);
ax=gca;
ax.FontSize=22;
xlabel('Frequency (GHz)');
ylabel('Node (N)');
zlabel('Current (uA)');
title([' 1/sqrt(LC) = 66.7 GHz, Measured cut-off = ',num2str(cut_off_frequency),'GHz']);
