%% Initialization of vegetation
% Most importantly, this code calculates the number of ecological time-steps per year which is not automated, yet, and needs to be double-checked.
% The main aim of this code is to determine all vegetation types and their properties through calling different modules.
% The number of different vegetation types is limited to nn=20. Pre-allocation of mortality matrices (need to be checked!).
% Calculates the first fract_area_all_veg{} either as zeros or from restart-matrix.
% Calls read_vegetation.m.

eco_timestep = (t_days_year*24*60)/t_eco_year; %the amount of the ecological mins/ets
% t_days_year is a parameter preset in general_input code as 360
% t_eco_year, number of ets/eco. year

if VegPres > 0 % check if there is dynamic vegetation presentm (1 =  vegetation present, 0 = no vegetation present)
    % Check the amount of vegetation files in folder based on number of 'veg' text
    for nn = 1:20 % maximum 20 vegetation types
        matFilename = sprintf('Veg%d.txt', nn);
        Check = exist(matFilename,'file'); % if file exists, value =2, else zero
        if Check ==2
            num_veg_types = nn; % save number of veg types in seperate vector
        else
            continue;
        end
    end
    clear Check nn matFilename
    
    %% Read characteristics from vegetation input files     %%     read_vegetation
    % Initialisation - preparation of colonisation
    general_veg_char    = zeros(1, 13, num_veg_types); % matrix for recording general vegetation characteristics for each veg-type
    life_veg_char       = cell(num_veg_types,1); % matrix for recording specific vegetation characteristics per vegetation life stage
    LocEco              = zeros(1,12,num_veg_types); % matrix for capturing start and stop of colonisation per vegetation type in ecological timesteps
    % Inundation stress parameters preallocate matrix size
    a                   = zeros(num_veg_types,1); % Stress inundation constant 1, a (-)
    b                   = zeros(num_veg_types,1); % Stress inundation constant 2, b (-)
    c                   = zeros(num_veg_types,1); % Stress inundation constant 3, c (-)
    xL                  = zeros(num_veg_types,1); % Lower limit habitat relative inundation period
    xR                  = zeros(num_veg_types,1); % Upper limit habitat relative inundation period
    % Competition stress parameters preallocate matrix size
    d                   = zeros(num_veg_types,1); % Stress competition constant 1, d (-)
    B_half              = zeros(Ndim,Mdim,num_veg_types); % Stress competition constant 2, B0.5 (kg/ha)2021-01-12 xie
    ind_a               = zeros(num_veg_types,1); % Biomass above-ground index, ind_a(-)
    bio_a               = zeros(num_veg_types,1); % Biomass above-ground constant, bio_a(-)
    ind_b               = zeros(num_veg_types,1); % Biomass below-ground index, ind_b(-)
    bio_b               = zeros(num_veg_types,1); % Biomass below-ground constant, bio_b(-)
    % Initial vegetation parameters pre-allocate
    stem_d0             = zeros(num_veg_types,1);
    stem_diameter0      = zeros(num_veg_types,1);
    Shoot_height0       = zeros(num_veg_types,1);
    max_root            = zeros(num_veg_types,1);
    Cd_root             = zeros(num_veg_types,1);
    % Growth constants pre-allocate
    G                   = zeros(num_veg_types,1); % Growth constant 1, G (cm/year)
    b2                  = zeros(num_veg_types,1); % (-) Growth constant 2
    b3                  = zeros(num_veg_types,1); % (/cm)Growth constant 3
    Dmax                = zeros(num_veg_types,1); % Maximum stem diameter, Dmax (cm)
    Hmax                = zeros(num_veg_types,1); % Maximum shoot height, Hmax (cm)
    
    %% **** Create matrices with vegetation data ****
    for nv = 1:num_veg_types % start loop over vegetation types
        % ****** Load vegetation parameters from veg.txt files *******
        life_veg_temp   = []; % reset temporary characteristics per vegetation type
        
        % Read general data from vegetation-txt files
        FID                         = fopen(strcat(directory, '/initial_files/', 'Veg', num2str(nv), '.txt'));
        datacell                    = textscan(FID, '%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f/n%*f', 'HeaderLines', 36);
        fclose(FID);
        mat_veg                     = cell2mat(datacell); % put general vegetation characteristics in matrix
        general_veg_char(:, :, nv)  = mat_veg; % put data of vegetation type in total vegetation matrix
        num_ls                      = mat_veg(6); % count number of lifestages
        num_mon                     = mat_veg(2);% extract amount of months for seed dispersal
        clear FID datacell mat_veg
        
        % Construct matrix for seed dispersal months
        FID                         = fopen(strcat(directory, '/initial_files/', 'Veg', num2str(nv), '.txt'));
        m=repmat('%f',1,num_mon);
        ColEco                      = textscan(FID, strcat(m, '/n%*f'), 'HeaderLines', 37); % ets that seed dispersal occurs, headerline help to jumt to line 37 directly
        fclose(FID);
        LocEco(:,1:num_mon,nv)      = cell2mat(ColEco); % ets that seed dispersal occurs
        clear FID m ColEco num_mon
        
        % Extract life-stage data
        for nls = 1:num_ls % loop over life stages
            FID                  = fopen(strcat(directory, '/initial_files/', 'Veg', num2str(nv), '.txt'));
            data                 = textscan(FID,'%f%f%f%f%f%f%f%f%f%f%f%f%f/n%*f', 'HeaderLines', 37+nls);
            fclose(FID);
            mat_veg             = cell2mat(data); % put data in matrix
            life_veg_temp(nls, :) = mat_veg;
        end % end loop over life stages
        
        life_veg_char{nv,1}      = life_veg_temp; % fill matrix with data of current vegetation type from vegx.txt-file
        clear FID data mat_veg life_veg_temp nls num_ls
        
        % **** Creat veg matrices which will be frequently used afterwards *****
        %>> Inundation stress parameters/Fitness function parameters
        a(nv)               = life_veg_char{nv,1}(1,6);
        b(nv)               = life_veg_char{nv,1}(1,7);
        c(nv)               = life_veg_char{nv,1}(1,8);
        xL(nv)              = general_veg_char(1, 10, nv);
        xR(nv)              = general_veg_char(1, 11, nv);
        %>> Growth function: above-ground
        G(nv)               = life_veg_char{nv,1}(1,3); % Growth constant 1, G (cm/year)
        b2(nv)              = life_veg_char{nv,1}(1,4); % (-) Growth constant 2
        b3(nv)              = life_veg_char{nv,1}(1,5); % (/cm)Growth constant 3
        Dmax(nv)            = life_veg_char{nv,1}(1,1); % Maximum stem diameter, Dmax (cm)
        Hmax(nv)            = life_veg_char{nv,1}(1,2); % Maximum shoot height, Hmax (cm)
        %>> Vegetation characteristics
        stem_d0(nv)         = general_veg_char(1,7,nv);
        stem_diameter0(nv)  = stem_d0(nv)/100; % shoot diameter, (m)
        Shoot_height0(nv)   = (25+b2(nv)*stem_d0(nv)-b3(nv)*stem_d0(nv)^2)/100; % shoot height, (m).
        max_root(nv)        = general_veg_char(1,12,nv);
        Cd_root(nv)         = general_veg_char(1,13,nv);
        %>> Competition stress parameters/Biomass stress parameters
        d(nv)               = life_veg_char{nv,1}(1,9); % maybe change to d(nv)
        ind_a(nv)           = life_veg_char{nv,1}(1,10);
        bio_a(nv)           = life_veg_char{nv,1}(1,11);
        ind_b(nv)           = life_veg_char{nv,1}(1,12);
        bio_b(nv)           = life_veg_char{nv,1}(1,13);
        % B_half
        % = num of mature * biomass
        B_half(:,:,nv) = floor(S_cell/(2*10*sqrt(0.5*Dmax(nv)/100))^2)*(bio_a(nv)*Dmax(nv)^ind_a(nv)+bio_b(nv)*Dmax(nv)^ind_b(nv));
    end
    clear stem_d0 life_veg_char
    %% Calculate the initial and maximum thresholds
    num0  = round(denseed/10000*S_cell); % initial individuals of plants in one cell
    if Root == 0 || max(max_root) == 0 % Exclude roots 23/10/2018
        num_all = num0; % Use a smaller maximum objexts number
    else
        num_all = round(denseed*max(max_root)/10000*S_cell); % The max number of columns in one cell incl. plants and roots
    end
    clear denseed
    
end % end check if dynamic vegetation is present