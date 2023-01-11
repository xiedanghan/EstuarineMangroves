%% To store model results
%>> When timesteps is large or model results is rough,
% use the original Delft3D results
%>> When timestep is small or model results are required to be elaborated,
% use the results method storing specified parameters


% 28/12/2018 Store the results in 2 different ways
if Storage == 0 % Copy the original Delft3D results to results folder
    if ets == t_eco_year
%         try
            % Save results to result/folder for analysis
            copyfile(strcat(directory, 'work/trim-', ID1, '.def'), strcat(directory, 'results_', num2str(year), '/trim-', ID1, '_', num2str(ets),'.def'));
            copyfile(strcat(directory, 'work/trim-', ID1, '.dat'), strcat(directory, 'results_', num2str(year), '/trim-', ID1, '_', num2str(ets),'.dat'));
%         catch
%         end
        if mod(year,10)==0  % Save the last ets to results folder in order to the restart process
            save(strcat(directory, 'results_', num2str(year), '/d3dparameters.mat'),'d3dparameters');
        end
    end
else % Storage =1, convert the original results to my own results with specified parameters
    if mod(year,10)==0 && ets == t_eco_year % Save the last ets to results folder in order to the restart process
        try
            % Save results to result/folder for analysis
            copyfile(strcat(directory, 'work/trim-', ID1, '.def'), strcat(directory, 'results_', num2str(year), '/trim-', ID1, '_', num2str(ets),'.def'));
            copyfile(strcat(directory, 'work/trim-', ID1, '.dat'), strcat(directory, 'results_', num2str(year), '/trim-', ID1, '_', num2str(ets),'.dat'));
            save(strcat(directory, 'results_', num2str(year), '/d3dparameters.mat'),'d3dparameters');
        catch
        end
    end
    % Function to save the specified parameters
    %>>Read NFS
    NFS      = vs_use(strcat(directory, 'work/', 'trim-', ID1,'.dat'),'quiet'); % read last trim file from previous year fine domain
    %  bed level [m]
    DPS       = vs_get(NFS,'map-sed-series','DPS','quiet');
    % water level [m]
    S1        = vs_get(NFS,'map-series','S1','quiet'); % Water level data at zeta points for all time-steps
    % velocity [m/s]
    U1        = vs_get(NFS,'map-series','U1','quiet'); % U
    V1        = vs_get(NFS,'map-series','V1','quiet'); % V
    % sediment concentration
    R1        = vs_get(NFS,'map-series','R1','quiet'); % SSC
    % bed shear stress [N/m2]
    TAUKSI    = vs_get(NFS,'map-series','TAUKSI','quiet'); % bed shear stress in U
    TAUETA    = vs_get(NFS,'map-series','TAUETA','quiet'); % bed shear stress in V
    TAUMAX    = vs_get(NFS,'map-series','TAUMAX','quiet'); % max bed shear stress (scalar)
    % bed-load transport [m3/m/s]
    SBUU      = vs_get(NFS,'map-sed-series','SBUU','quiet'); % Bed-load transport u-direction (u point)
    SBVV      = vs_get(NFS,'map-sed-series','SBVV','quiet'); % Bed-load transport v-direction (v point)
    % Suspended-load transport [m3/m/s]
    SSUU      = vs_get(NFS,'map-sed-series','SSUU','quiet'); % Suspended-load transport u-direction (u point)
    SSVV      = vs_get(NFS,'map-sed-series','SSVV','quiet'); % Suspended-load transport v-direction (v point)
    % Near-bed reference concentration of sediment [kg/m^3]
    RCA       = vs_get(NFS,'map-sed-series','RCA','quiet'); %
    % sediment in layer
    LYRFRAC   = vs_get(NFS,'map-sed-series','LYRFRAC','quiet'); % [-] Volume fraction of sediment in layer
    DP_BEDLYR = vs_get(NFS,'map-sed-series','DP_BEDLYR','quiet'); % [m] Vertical position of sediment layer interface

    %>>Save data
    MyStorage.DPS    = DPS;
    MyStorage.S1     = S1;
    MyStorage.U1     = U1;
    MyStorage.V1     = V1;
    MyStorage.R1     = R1;
    MyStorage.TAUKSI = TAUKSI;
    MyStorage.TAUETA = TAUETA;
    MyStorage.TAUMAX = TAUMAX;
    MyStorage.SBUU = SBUU;
    MyStorage.SBVV = SBVV;
    MyStorage.SSUU = SSUU;
    MyStorage.SSVV = SSVV;
    MyStorage.RCA  = RCA;
    MyStorage.LYRFRAC = LYRFRAC;
    MyStorage.DP_BEDLYR = DP_BEDLYR;

    if Wave > 0
        % significant wave height
        Hs       = vs_get(NFS,'map-rol-series','HS','quiet');
        MyStorage.Hs = Hs;
    end
    
    save('MyStorage.mat','MyStorage');
    copyfile(strcat(directory, 'work/MyStorage.mat'), strcat(directory, 'results_', num2str(year), '/MyStorage_', num2str(ets),'.mat'));
    clear NFS S1 U1 V1 R1 TAUKSI TAUETA TAUMAX SBUU SBVV LYRFRAC DP_BEDLYR  MyStorage
end