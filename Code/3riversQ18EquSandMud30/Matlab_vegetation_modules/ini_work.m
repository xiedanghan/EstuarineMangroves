%% The initial start of model without vegetation
% Offer the first simulation results
% A script to initialize the first set up of the work folder and necessary files:
% Create the work-folder and copy all the files in initial folder into work folder.
% Start first D3D run for ETS=0.
%% Copy + adjust + model
if Restart==0
    % ******* Copy all files from initial folder into work-folder ***
    copyfile(strcat(directory, 'initial_files'),strcat(directory, 'work'));
    ets       = 0; % initialize the very begining run
    fid_mdf1  = fopen(strcat(directory,'work/',ID1,'.mdf'),'r');
    mdf1      = textscan(fid_mdf1,'%s','delimiter','\n');
    fclose(fid_mdf1);
    mdf1      = mdf1{1,1};
    
    for i=1:length(mdf1)
        %1
        a5 = strmatch('Tstart', mdf1{i,1});
        if a5==1
            Time_start = mdf1{[i,1]};
            Time_start = Time_start(9:length(Time_start));
            Time_start = str2double(Time_start);
            Time_stop  = Time_start+eco_timestep/morfac;
            mdf1{i+1,1}= strcat('Tstop  = ',sprintf('% 2.8g',Time_stop));
        end
        %2
        a6 = strmatch('Flmap', mdf1{i,1});
        if a6 == 1
            mdf1{i,1}= strcat('Flmap  = ',sprintf('%2.8g  %2.8g  %2.8g',Time_start,tstep,Time_stop));
        end
    end % change Tstart Tstop Flmap
    clear i a5 a6
    
    %     write new mdf-file
    fid_mdf1 = fopen(strcat(directory,'work/',ID1,'.mdf'),'w');
    for k=1:numel(mdf1)
        fprintf(fid_mdf1,'%s\r\n',mdf1{k,1});
    end
    fclose(fid_mdf1);
    clear k
    % Run model
    run_line =  strcat(directory, 'work/', bat_file);
    cd(strcat(directory, 'work'));
    system(strcat('chmod 755',32,bat_file))
    system(run_line);
    clear mdf MDF1
    % Simulate from the first year
    year_ini = 1;
else
    % Look for the last results file and read the year no. when ets == 12
    filefolder  = fullfile(directory);
    diroutput   = dir(fullfile(filefolder,'*'));
    year_temp   = zeros(length(diroutput),1);
    for i = 1 : length(diroutput)
        filename = diroutput(i,1).name;
        if ismember('results',filename)
            year_loc     = strfind(filename,'results'); % SSC location
            year_temp(i) = str2double(filename(year_loc+8:end)); % The value of SSC
        end
    end
    % Check the folder validity
    File_check       = fullfile(strcat(directory,'results_',num2str(max(year_temp)),'/'));
    if Storage == 1
        diroutput_check  = dir(fullfile(File_check,strcat('*',num2str(t_eco_year),'.mat'))); % if finish, should contain maximum ets
    else
        diroutput_check  = dir(fullfile(File_check,strcat('*',num2str(t_eco_year),'.dat'))); % if finish, should contain maximum ets
    end
    filename_check   = {diroutput_check.name};
    if isempty(filename_check)
        error('Error .\Original simulation should complete');
    else
        year_ini    = max(year_temp)+1; % Start a new year
        % Map file: Update the dat and def file into the work folder
        %>Delete the old dat and def files from work folder
        delete(strcat(directory, 'work/trim-', ID1, '.def'));
        delete(strcat(directory, 'work/trim-', ID1, '.dat'));
        %>Delete old veg files TRV and TRD
        delete(strcat(directory, 'work/veg.trd'));
        delete(strcat(directory, 'work/veg.trv'));
        %>Delete old mdf files from work folder
        delete(strcat(directory, 'work/', ID1, '.mdf'));
        %>Delete old tri-diag files
        delete(strcat(directory,'work/tri-diag.',ID1));
        %>Delete old bch files
        delete(strcat(directory,'work/',ID1,'.bch'));

        %>Copy the dat and def from the very last simulation
        copyfile(strcat(directory, 'results_', num2str(max(year_temp)), '/trim-', ID1, '_', num2str(t_eco_year),'.def'),...
            strcat(directory, 'work/trim-', ID1, '.def'));
        copyfile(strcat(directory, 'results_', num2str(max(year_temp)), '/trim-', ID1, '_', num2str(t_eco_year),'.dat'),...
            strcat(directory, 'work/trim-', ID1, '.dat'));
        %>Copy the mdf file from the very last simulation
        copyfile(strcat(directory, 'results_', num2str(max(year_temp)), '/', ID1, '_', num2str(t_eco_year),'.mdf'),...
            strcat(directory, 'work/', ID1, '.mdf'));
        %>Copy the bch file from the very last simulation
        copyfile(strcat(directory, 'initial_files/', name_model_original1,'.bch'),strcat(directory, 'work'));
        % Copy a new BCC file from initial to work folder
        copyfile(strcat(directory, 'initial_files/', name_model_original1,'.bcc'),strcat(directory, 'work'));
        
        % Refreh vegetation information
        if VegPres ~= 0
            try
                % Load d3dparameters
                load(strcat(directory, 'results_', num2str(max(year_temp)), '/d3dparameters.mat'));
                %>Add vegetation files
                %>Copy the TRV and TRD file from the very last simulation
                copyfile(strcat(directory,'results_', num2str(max(year_temp)), '/veg', num2str(t_eco_year), '.trd'),...
                    strcat(directory, 'work/veg.trd'));
                copyfile(strcat(directory,'results_', num2str(max(year_temp)), '/veg', num2str(t_eco_year), '.trv'),...
                    strcat(directory, 'work/veg.trv'));
            catch
                % If results files don't have veg files, turn to initial files for help
                copyfile(strcat(directory,'/initial_files/veg.trd'), strcat(directory, 'work/veg.trd'));
                copyfile(strcat(directory,'/initial_files/veg.trv'), strcat(directory, 'work/veg.trv'));
            end
            % Load trv_trd
            for ets = 1 : t_eco_year
                try % if trv_trd exists
                    load(strcat(directory,'results_',num2str(max(year_temp)),'/','trv_trd',num2str(ets),'.mat')); % load trv_trd
                    trv_trd(trv_trd(:,11)==900,:) = []; % delete all the information about root
                catch % Create an empty trv_trd if no trv_trd exists
                    trv_trd = [];
                end
                trv_trd_dh(year_ini-1,ets) = {trv_trd}; % for mortality, roots are not included
            end
            %>Read vegetation parameters
            % Extra parameters
            % Initial area fraction by pre-allocation
            rough_eq            = zeros(num_veg_types,1);
            height              = zeros(num_veg_types,1);
            drag_coeff          = zeros(num_veg_types,1);
            chezy_coeff         = zeros(num_veg_types,1);
            vegtype             = zeros(num_veg_types,1);
            % Veg file
            for nv=1:num_veg_types
                % TRD
                rough_eq(nv,1)     = general_veg_char(1, 5, nv);
                height(nv,1)       = Shoot_height0(nv); % shoot height, (m)
                % 13/08/2018 consider roots
                drag_coeff(nv,1)   = 1.5;
                chezy_coeff(nv,1)  = chezy;
                vegtype(nv,1)      = nv;
            end % end loop over plant coordinates
            % if vegetation exists
            Trtrou_val = ' #Y#';
        else % if vegetation doexn't exist, delete vegetation information from mdf
            Trtrou_val = ' #N#';
        end
        % Update mdf Tstart/Tstop/Trtrou
        fid_mdf1 = fopen(strcat(directory,'work/',ID1,'.mdf'),'r');
        mdf1     = textscan(fid_mdf1,'%s','delimiter','\n');
        fclose(fid_mdf1);
        mdf1     = mdf1{1,1};
        addVeg   = 0;
        for i = 1:length(mdf1)
            a8 = strmatch('Trtrou', mdf1{i,1});
            if a8 == 1
                mdf1{i,1} = strcat('Trtrou = ',sprintf('%s',Trtrou_val));
                addVeg    = 1;
            end
            if addVeg ~= 1 && i == length(mdf1) % if no Trtrou is found, add manually
                mdf1{i+1,1} = strcat('Trtrou = ',sprintf('%s',Trtrou_val));
                mdf1{i+2,1} = strcat('Trtdef = ',sprintf('%s',' #veg.trd#'));
                mdf1{i+3,1} = strcat('Trtu   =',sprintf('%s',' #veg.trv#'));
                mdf1{i+4,1} = strcat('Trtv   =',sprintf('%s',' #veg.trv#'));
                mdf1{i+5,1} = strcat('Commnt =',sprintf('%s',''));
            end
        end
        %     write new mdf-file
        fid_mdf1 = fopen(strcat(directory,'work/',ID1,'.mdf'),'w');
        for k=1:numel(mdf1)
            fprintf(fid_mdf1,'%s\r\n',mdf1{k,1});
        end
        fclose(fid_mdf1);
        clear k
    end
    clear filefolder diroutput year_temp i filename year_loc File
    clear File_check diroutput_check filename_check ets
    clear Time_stop_new Time_start_new Time_stop a6 a7 a8 i mdf1 Trtrou_val
end