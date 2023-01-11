%% Initialize and extract parameters from Delft3D for initial state
% Read important temporal data from the .mdf-file
% It is better to keep the reference date starting from day 1 and month 1

%% Read MDF and extract run-id fine grid
ini_mdf  = mdf('read',strcat(name_model_original1, '.mdf'));   % read initial MDF file
ID1      = strcat(name_model_original1); % for this test, '0river'

%% Extract static parameters from Delft3D
dimensions  = str2num(cell2mat(ini_mdf.mdf.Data{1,2}(strmatch('MNKmax', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'),2)));
% determine M/N dimensions of grid str2double converts str, while str2num converts an array or a vector
Mdim        = dimensions(1,1); % grid dimensions
Ndim        = dimensions(1,2); % grid dimensions
clear dimensions
% calculate cell area of grid
G_temp      = cell2mat(ini_mdf.mdf.Data{1,2}(strmatch('Filcco', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'),2)); %#ok<MATCH3>
G           = wlgrid('read',G_temp(2:end-1));
GX1         = G.X';
GY1         = G.Y';
D_temp      = cell2mat(ini_mdf.mdf.Data{1,2}(strmatch('Fildep', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'),2));
D           = wldep('read',D_temp(2:end-1),G); % dimensions:Mnode+1 Nnode+1
Dv          = D'; % transform to visualize shape
S_cell      = zeros(Ndim,Mdim); %cell area; Row:Ndim COl:Mdim, match the grid shape we visualize
for N = 1:Ndim % loop over cell numbers
   for M = 1:Mdim
       if N == 1 || N == Ndim || M == 1 || M == Mdim % virtual cells 
           S_cell(N,M) = nan;
       elseif N > 1 && M > 1 && N < Ndim && M < Mdim &&...
               ismember(-999,[Dv(N,M) Dv(N,M-1) Dv(N-1,M-1) Dv(N-1,M)])   % real cells, set nan if at least 1 of 4 surrounding index = -999 
           S_cell(N,M) = nan;
       else % surface area
           S_cell(N,M) = (GX1(N,M)-GX1(N-1,M-1))*(GY1(N,M)-GY1(N-1,M-1));
       end
   end
end
clear G_temp G GX1 GY1 D_temp D Dv N M
% morfac
if mor ==0 % if there is no morphology, no morfac is required
    morfac = morf;
else
    morfac   = strmatch('MorFac', char(ini_mdf.mor.Data{2,2}(:,1)), 'exact'); % find location of morfac
    morfac   = ini_mdf.mor.Data{2,2}(morfac,2); % extract morfac data
    C        = strsplit(morfac{1}); % split string
    morfac   = str2double(C{1}); % convert to number
    clear C a morf
end
% extract time-scales and chezy from mdf
Lchezy                  = strmatch('Ccofu', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'); % location of chezy
chezy                   = str2double(ini_mdf.mdf.Data{1,2}(Lchezy,2)); % value of chezy
Ltstep                  = strmatch('Flmap', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'); % Location of time step
tstep                   = str2num(cell2mat(ini_mdf.mdf.Data{1,2}(Ltstep,2))); % value of output timestep
tstep                   = tstep(2);
loc_start               = strmatch('Tstart', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'); % location of Tstart
Tstart                  = str2double(ini_mdf.mdf.Data{1,2}(loc_start,2))*morfac; % value of Tstart
loc_stop                = strmatch('Tstop', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact');  % location of Tstop
Tstop                   = str2double(ini_mdf.mdf.Data{1,2}(loc_stop,2))*morfac; % value of Tstop
Total_sim_time          = Tstop - Tstart; % total simulation time in minutes
years                   = ceil(Total_sim_time/(365.25*24*60)); % number of morph. years in the simulation, ceil function returns a bigger integer ceil(e.g., -1.9)=-1
% dh: when days/year <366, replace ceil with fix/floor/round(x) to get an integer which is smaller/the most close to x
IT_date                 = ini_mdf.mdf.Data{1,2}(strmatch('Itdate', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'),2); % extract IT date
IT_date                 = cell2mat(IT_date); % put in right format
month                   = str2double(IT_date(7:8)); % extract month
day                     = str2double(IT_date(10:11)); % extract day
clear Lchezy Tstart Tstop loc_start loc_stop Total_sim_time Ltstep
% start date of simulations in year
if month>1
    days_in_months  = [30 30 30 30 30 30 30 30 30 30 30 30]; % matrix for days in each month (total 360 days)
    IT_date_minutes = (sum(days_in_months(1,1:month-1))+(day-1)*24*60)*morfac; % minutes of IT date within a year
else
    IT_date_minutes = ((day-1)*24*60)*morfac; % minutes of IT date where simulations starts (1.1.), if years starts in another month the seed dispersal time needs to be adapted
end
clear day month ini_mdf