% Initial module 'general_input' calls veg module and defines run paths.
% Here different keywords need to be set to start a simulation with/without vegetation, with morphology, or from restart files.
% If restart, the trim-files are necessary (trim-*model name*.dat and trim-*model name*.def) as well as 
% matrice 'fraction_area_all_veg.m' and the 'veg.trv' with the locations of already settled vegetation. Moreover, random establishment can be chosen.

%% Initialisation
clear
close all
clc
% Define run directory
directory_head          = '...Xie_Application_2023 Syvitski Student Modeler Award/Code/'; % Link to the folders with modules and initial files
name_model              = '3riversQ18EquSandMud30'; % folder of scenario run
name_model_original1    = '3rivers'; % original name of mdf file
bat_file                = 'run_flow2d3d_parallel_eejit.sh'; % Linux exe file
directory = strcat(directory_head, name_model,'/'); % main directory
cd(strcat(directory, 'initial_files/')); % directory initial files
% add paths with functions and scripts of modules
addpath(strcat(directory,'Matlab_vegetation_modules'));
addpath(strcat(directory,'Matlab_functions'));
% turn this on in case of older matlab version (f.e. in GIS-lab)
addpath('/scratch/depfg/dangh001/Delft3d_tag7545_20210512/lnx64/delft3d_matlab');

%% User defined parameters for Vegetation model
%>> Veg
VegPres             = 1;   % 1 = vegetation present, 0 = no vegetation present
Root                = 1;   % 1 = Mangrove root included, 0 = mangrove root excluded
f                   = 0.5; % Constant of roots number increase% Barend: 0.3(40cm stem); Danghan: 0.1(~1m stem) and 0.5(18cm stem)
%>> Bnd
Wave                = 0;   % 1 = Roller wave, 0 = no wave
TauThres            = 0.2; % Bed shear stress Threshold for mangrove colonization
Restart             = 0;   % 1 = hot start from work file, 0 = run from pristine conditions
Storage             = 1;   % 1 = save the user-defined output file, 0 = save the delft3D output file 
SedThres            = 0.01;% sedimentation threshold for ColonisationStrategy 2B (in m) - defined in veg.txt-file
mor                 = 1;   % 1= include morphology, 0 = exclude morphology
morf                = 30; % give manual morfac in case without morphological development
fl_dr               = 0.1; % Boundary for water flooding/drying (m)
t_eco_year          = 4;   % number of ecological time-steps (ets) per year, 4 = quartely, 12=monthly
t_days_year         = 360; % number days per year to guarantee no integers in time-scales
denseed             = 3000;% initial seedlings density 3000 individuals per ha (van Maanen 2015) 
Mort_plant          = 10;  % Number of plants need to be removed at one time
Grow_plant          = 10;  % Number of plants need to be grown at one time
%% run vegetation model
Vegetation_model

