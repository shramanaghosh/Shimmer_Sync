function [Shimmer, FP] = load_fp_file(Filename_BW, Filename_VZ, Filename_MSS)

% This file will modify the  force plate and shimmer capture start times 
% to sync with motion capture.

% Current method of triggering sync capture in Shimmer relies on using a
% modified EOF signal to trigger the Shimmer Modules. MSS writes data to
% file as soon as EOF(1) from Motion Capture arrives at the Shimmer device.
% The following code (approximately) aligns the start times of motion
% capture, force plate and Shimmer captures. It is necessarily dependent on
% force plate FP #7 data in this version. A probable source of error in
% these calculations is any delay in the EOF(1) signal reaching the Shimmer
% module. The code should be appropriately modified to include this factor
% once more information is available.


%% Load data from data file of Multi-Shimmer Sync using the file
% loadmssdata.m

% Enter name of MSS file
% filePath = 'sample_set_2_cal007.dat';
filePath = Filename_MSS;

% Load numeric data

sensorDataArray = dlmread (filePath,'\t',3,0);	                           % Load tab seperated numeric data from a text file starting 
                                                                           % from 4th row 1st column of data(i=0,1,2...) (i.e. ignore header information)                                                                                                   

% Load header data

[nSamples, nSignals] = size(sensorDataArray);                              % Determine number of signals captured in the file (i.e. columns of data)     

fid = fopen(filePath);

sensorNamesCellTemp = textscan(fid, '%s', nSignals, 'delimiter' , '\t');   % Load tab seperated sensor name strings for each signal  
sensorNamesCellArray = sensorNamesCellTemp{1};
signalNamesCellTemp = textscan(fid, '%s', nSignals, 'delimiter' , '\t');   % Load tab seperated signal name strings for each signal  
signalNamesCellArray = signalNamesCellTemp{1};
signalUnitsCellTemp = textscan(fid, '%s', nSignals, 'delimiter' , '\t');   % Load tab seperated signal unit strings for each signal  
signalUnitsCellArray = signalUnitsCellTemp{1};

fclose(fid);

%clearvars -except sensorNamesCellArray signalNamesCellArray signalUnitsCellArray sensorDataArray;


%% Adjust time stamps 

% Get Force plate data
[FP, Sh_adj_fact] = load_fp_file(Filename_BW, Filename_VZ);

col_t = sensorDataArray(:,1);

for i = 1:length(sensorDataArray)
    
        col_tm(i,1) = col_t(i,1) - col_t(1,1);     
    
end

time = col_tm/1000;

for i = 1:length(time)
    
    time_mod(i,1) = time(i,1) - Sh_adj_fact;
    
end

Data_new = horzcat(sensorDataArray,time_mod);

%% Create structures

no_devices = 0;
for i = 1:length(sensorNamesCellArray)
    
   if strncmp(sensorNamesCellArray(i), 'Shimmer', 5) && strncmp(signalNamesCellArray(i), 'Timestamp', 7)
       no_devices = no_devices + 1;
       array_pos = i;
   end
    
end

for i = 1:length(no_devices)
    j = array_pos(i);
    names = char(sensorNamesCellArray(j));
    
end

for i = 1:length(no_devices)
    
   Shimmer_name{i} = sprintf('Shimmer_%s', names(i,8));
   
end

% Initialize fieldnames
for i = 1:length(Shimmer_name)
    Shimmer.(Shimmer_name{i}).time_orig = [];
    Shimmer.(Shimmer_name{i}).time_mod = time_mod;
    Shimmer.(Shimmer_name{i}).signals = [];
end

for i = 1:length(Shimmer_name)
    
    Shimmer.(Shimmer_name{i}).time_orig = sensorDataArray(:,array_pos(i));
    
    Shimmer.(Shimmer_name{i}).signals(:,1) = sensorDataArray(:,array_pos(i)+1); 
    Shimmer.(Shimmer_name{i}).signals(:,2) = sensorDataArray(:,array_pos(i)+2); 
    Shimmer.(Shimmer_name{i}).signals(:,3) = sensorDataArray(:,array_pos(i)+3); 
    
end
