% Imports standard files exported by Multi-shimmer Sync, force plate and motion capture system
% and creates workspace variables which conatin the relevant data.
% 
% 
% For synchronization the time of capture of the 2nd frame of the motion
% tracking is set to zero and the force plate and Shimmer capture times are modified
% to reflect the same.
%
%%

clear;
clc;

tic;
% Enter name of text file exported by Bioware
Filename_BW = 'DataFile_BW_5.txt';

% Enter name of text file exported by VZSoft
Filename_VZ = 'DataFile_VZ_5.txt';

% Enter name of text file exported by MSS
Filename_MSS = 'sample_set_2_cal007.dat';

% Get Force plate & Shimmer data
[Shimmer, FP] = forceplate_shimmer_sync(Filename_BW, Filename_VZ, Filename_MSS);

% Get Motion Capture data
[marker] = load_mocap_file(Filename_VZ);

toc;