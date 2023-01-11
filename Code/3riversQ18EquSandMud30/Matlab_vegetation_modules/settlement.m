%% Settlement module. Vegetation is assigned to grid cells with certain area fraction.
% Find the cells with space for colonization and the fraction that can be colonized. Fills up the space with
% the new fraction from current ETS==1. Adds the trachytope ID to new fractions for each vegetation type and saves it in matrix output.
% Opens existing trv-file and adds the new fractions, sorted after the cell numbers.
%----------------Man, say sth--------------------**--------
%>>dh: I am a referee, so allocate area fraction when coexist
%>>dh: I am a donkey, area fraction always represents no. of plants by timing total no.
  
% Add the roots and Output the results on the basis of trv_trd
f_output

% format
%>> diameter, height and I, C ... are the real parameters of this ets
%::Save trv_trd after every run or before every new run
trv_trd_dh(year, ets)          = {trv_trd};

% save file trv_trd
savefile = strcat('trv_trd',num2str(ets));
savefile = strcat(directory, 'results_', num2str(year),'/', savefile);
save(savefile, 'trv_trd');
clear savefile