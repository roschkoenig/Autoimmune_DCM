% gab_run

% Housekeeping
%==========================================================================
Fbase   = '/Users/roschkoenig/Dropbox/Research/1902 GABA-Ab';

fs          = filesep;
Fscripts    = [Fbase fs 'Scripts'];
Fdata       = [Fbase fs 'Data']; 
Fanalysis   = [Fbase fs 'Analysis'];
Fmeeg       = [Fanalysis fs 'MEEG']; 
Fdcm        = [Fanalysis fs 'DCM'];
spm('defaults', 'eeg');
addpath(genpath(Fscripts)); 

% Load data
%==========================================================================
M = gab_edf_load(Fdata);
m = M(strcmp({M.name}, 'GABA'));
I(1).st = 95;       I(1).dr = 26;
I(2).st = 548;      I(2).dr = 11;
I(3).st = 3473;     I(3).dr = 13;
I(4).st = 3509;     I(4).dr = 12; 

% Show spectral changes
%==========================================================================
gab_raw_plot(m, I); 

% Sliding window segmentation
%==========================================================================
D       = gab_win_slide(m, I, 5, 10, 30, Fmeeg); 

%% Invert individual DCMs
%==========================================================================
DCM = gab_dcm(Fmeeg, Fdcm); 

% Run PEB
%==========================================================================