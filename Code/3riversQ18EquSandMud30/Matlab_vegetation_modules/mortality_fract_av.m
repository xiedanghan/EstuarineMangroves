%% Initialisation - loading matrices from extract_par
%---------------------------Man, I am Grove--------------------------------------%
%-----If I die, then I*C should consecutively smaller than 0.5 for 5 years-------%
%----------------After I die, no new life forms at my place----------------------%
%----------------Remember, a yearly death, so I should be the yearly I-----------%

%% Cache clean - remove all the roots
%>> Max. root number is fixed for each species, mark as number 900
%>> Root marks are recorded in column 11th of trv_trd, similar to all vegetation species
% 09/10/2018 exclude null trv_trd
if ~(year == 1 && ets ==1) && ~isempty(trv_trd)
    trv_trd(trv_trd(:,11)==900,:) = []; % delete all the information about root
end
clear Root_mark
%% Mortality starts
% If mortality occurs, change this value to 1, colonization will negelect the mort cells
Mortality = 0; % No mortality occurs

% Acquire relative flood hydroperiod of last ets for growth only
% Acquire bed shear stress of last ets for colonization only 2019-12-04
if year==1 && ets==1 && Restart==0
    disp(['Vegetation will be assigned to the corresponding cells at the Year ' num2str(year)]);
    Relative_flood     = Relative_flood0;
    Tau                = Tau0; % only for colonization
    clear Relative_flood0 Tau0
elseif ets == 1
    Relative_flood     = cell2mat(d3dparameters.Flood(year-1).PerYear(t_eco_year,1));
    Tau                = cell2mat(d3dparameters.Tau(year-1).PerYear(t_eco_year,1)); % only for colonization
else
    Relative_flood     = cell2mat(d3dparameters.Flood(year).PerYear(ets-1,1));
end
P                      = Relative_flood; % relative hydro-period
% Update inundation stress and competition stress
if ~(year == 1 && ets ==1) && ~isempty(trv_trd)  % 09/10/2018 exclude null trv_trd
    %>>based on Trim file of last ets, I will be updated here
    trv_trd_addIC      = trv_trd;
    f_add_I_C % Update inundation stress and competition stress
    trv_trd            = trv_trd_addIC;
end
clear Relative_flood trv_trd_addIC

%% < Mortality Process >
if year==1 && Restart==0 
    disp(['Vegetation starts to colonize in Year ' num2str(year) ', NO vegetation dies at the very beginning!']);
elseif ets==1 && ~isempty(trv_trd) % 09/10/2018 exclude null trv_trd
    % Average the 3rd dimension of trv_trd over the last year to obtain average I and C and I*C
    trv_trd_temp              = mean(cat(3, trv_trd_dh{year-1,:}),3);
    trv_trd_temp(trv_trd_temp(:,11)==900,:) = []; % delete roots
    Ave_Inundation_temp       = trv_trd_temp(:,14); % temperary average inundation stress
    trv_trd_temp              = trv_trd; % assign the value of t_eco_year of last year
    trv_trd_temp(:,6)         = trv_trd_temp(:,14); % temporarily store I_last ets in Rough equation term
    trv_trd_temp(:,14)        = Ave_Inundation_temp; % inundation stress convert to annual average value
    trv_trd_temp(:,18)        = Ave_Inundation_temp.*trv_trd_temp(:,17); % Ave_I * last_C
    %****% !!!Ave(I*C) ~= Ave(I)*Ave(C), so 18col is calculated again.!!!
    % Mark the I*C which <= 0.5
    Mort_mark                 = zeros(size(trv_trd_temp,1),1);
    Mort_mark(trv_trd_temp(:,18)<=0.5) = 1; % may die if <=0.5
    trv_trd_temp(:,19)        = trv_trd_temp(:,19).*Mort_mark(:,1)+ Mort_mark(:,1); % update the mortality among the whole domain
    trv_trd_temp(:,20)        = 1:1:size(trv_trd_temp,1);
    % Remove the consecutively low growth plants one by one and test after every deforestation
    % Every time removement, the C will be recalculated subsequently
    if ismember(5,trv_trd_temp(:,19))
        fprintf(['Vegetation starts to die in Year ' num2str(year) ', ETS ' num2str(ets) '!']);
        f_mortality % mortality: kill mangroves based on vegetation species and diameters
        Mortality = 1; % Mortality occurs
    end
    trv_trd_temp(:,14)  = trv_trd_temp(:,6); % restore I as last_ets
    trv_trd_temp(:,6)   = rough_eq(1); % restore rough equation as default
    trv_trd             = trv_trd_temp; % return vegetation parameters to trv_trd matrix
end
clear Mort_mark Mort_Loc Mort_temp Mort_rc_temp Mort_cell
clear Death_mark j Bio_total_cell trv_trd_temp Ave_Inundation_temp