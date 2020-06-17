function [I_f_meas_path, Vf_meas_path, f_path,If_0_path] = NonLinear_JTWPA_Analyser(t_meas_start,t_meas_end,N,Vt_wait_path_out,It_wait_path_out,time_path,plotpath,I_initial_path_out,Phit_full_path_out,param,paramstr_1,paramstr_2,loopVarFile_1,loopVarFile_2)

time = dlmread(time_path);
dt = time(2) - time(1);

time_meas_min = t_meas_start*10^-9+dt;
time_meas_max = t_meas_end*10^-9;
i_time_meas_min = round((time_meas_min+dt)/dt);
i_time_meas_max = round((time_meas_max+dt)/dt);
fft_time = time(i_time_meas_min:i_time_meas_max);

dim=1;
fft_n=length(fft_time);
meas_folder = dir(Vt_wait_path_out);
f = (1/dt).*(0:(fft_n/2))/fft_n;
f_path = [meas_folder.folder,'/f.txt'];
dlmwrite(f_path,f);


Vtdata = dlmread(Vt_wait_path_out);
mag_Vfft_double_sided = abs(fft(Vtdata,fft_n,dim)/fft_n);
mag_Vfft_han_double_sided = abs(fft(Vtdata.*hanning(length(Vtdata)),fft_n,dim)).*(1/sum(hanning(length(Vtdata))));
clear Vtdata
mag_Vfft_single_sided = 2*mag_Vfft_double_sided(1:fft_n/2+1,:);
mag_Vfft_han_single_sided = 2*mag_Vfft_han_double_sided(1:fft_n/2+1,:);
Vf_meas_path = [meas_folder.folder,'/V_f.txt'];
dlmwrite(Vf_meas_path,mag_Vfft_han_single_sided(:,:),'delimiter','\t');

clear mag_Vfft_double_sided mag_Vfft_han_double_sided

Itdata = dlmread(It_wait_path_out);
mag_Ifft_double_sided = abs(fft(Itdata,fft_n,dim)/fft_n);
mag_Ifft_han_double_sided = abs(fft(Itdata.*hanning(length(Itdata)),fft_n,dim)).*(1/sum(hanning(length(Itdata))));
clear Itdata
mag_Ifft_single_sided = 2*mag_Ifft_double_sided(1:fft_n/2+1,:);
mag_Ifft_han_single_sided = 2*mag_Ifft_han_double_sided(1:fft_n/2+1,:);
I_f_meas_path = [meas_folder.folder,'/I_f.txt'];
dlmwrite(I_f_meas_path,mag_Ifft_han_single_sided(:,:),'delimiter','\t');

dlmwrite([meas_folder.folder,'/I_f_50GHz_500N.txt'],mag_Ifft_han_single_sided(1:500,1:500),'delimiter','\t');

figure(1)
set(gcf,'renderer','zbuffer');
[sx,sy] = meshgrid(f(1:1001)*1e-9,1:N);
s=surf(sx,sy,mag_Ifft_han_single_sided(1:1001,1:N)'*10^6);
s.LineStyle = 'none';
s.FaceColor = 'interp';
view(10,20);
ylim([0 500]);
ax=gca;
ax.FontSize=22;
xlabel('Frequency (GHz)');
ylabel('Node (N)');
zlabel('Current (uA)');
title(['STS of JTWPA: IDC = ',num2str(param(1)),'uA, RFfreq = ',num2str(param(5)),'GHz, C0 = ',num2str(param(2)),'fF, Cj = ',num2str(param(6)),'fF, Lg = ',num2str(param(3)),'pH']);
set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf, [plotpath,paramstr_1,'=',loopVarFile_1,paramstr_2,'=',loopVarFile_2,'.png'])

clear mag_Ifft_double_sided mag_Ifft_han_double_sided




It_source_data = dlmread(I_initial_path_out);
mag_It_source_double_sided = abs(fft(It_source_data,fft_n,dim)/fft_n);
mag_It_source_han_double_sided = abs(fft(It_source_data.*hanning(length(It_source_data)),fft_n,dim)).*(1/sum(hanning(length(It_source_data))));
clear It_source_data
mag_It_source_single_sided = 2*mag_It_source_double_sided(1:fft_n/2+1,:);
mag_It_source_han_single_sided = 2*mag_It_source_han_double_sided(1:fft_n/2+1,:);
clear It_source_double_sided
If_0_path = [meas_folder.folder,'/If_input_data.txt'];
dlmwrite(If_0_path,mag_It_source_han_single_sided,'delimiter','\t');


clear mag_Ifft_single_sided mag_It_source_single_sided mag_Vfft_single_sided mag_Ifft_han_single_sided mag_It_source_han_single_sided mag_Vfft_han_single_sided






