clc; clear; close all; 
%% User Defined Values
%import data
filename = '241022 GADKO and INSCRE Traces Only.xlsx';
rawdata = readmatrix(filename, 'Sheet', 1);
name = 'GADKO';
columns = size(rawdata,2);
rows = size(rawdata,1);
t = rawdata(:, 1); %minutes

%start and end times in minutes for AUC calcs
starttime = 59;
endtime = 74;

%% Code Running - No Need for Change
% Reformtatting data for just time of calcium oscillations

%linear index vector
ind = 1:length(t);

%find indices of start and end time
startdiff = abs(t - starttime);
enddiff = abs(t-endtime);

minstart = min(startdiff);
starttime_idx = ind(startdiff == minstart);

minend = min(enddiff);
endtime_idx = ind(enddiff == minend);

%find # of indices of 30s
thirty_ind = abs(t-0.5);
min_30 = min(thirty_ind);
thirtysec = ind(thirty_ind == min_30);

%reformat data to just times wanting to plot 
t = t(starttime_idx:endtime_idx);

AUC = [];
avg1st = [];
avglast = [];
avg2nd30 = [];
waste_area = [];
correct_AUC = [];
theo_end = [];
for i=2:columns
    %this analyzes one islet at a time 
    data = rawdata(:, i);
    data = data(starttime_idx:endtime_idx);

    % AUC
    AUC(i-1) = trapz(t,data);

    %Average of 1st and last 30s
    avg1st(i-1) = mean(data(1:thirtysec));
    avg2nd30(i-1) = mean(data(thirtysec:thirtysec*2));
    if avg2nd30(i-1) + 0.05 < avg1st(i-1)
        avg1st(i-1) = avg2nd30(i-1);
    end
    avglast(i-1) = mean(data(length(data)-thirtysec:length(data)));
    
    %moving average of min area
    movavg = [];
    for j=1:length(t)-thirtysec
        movavg(j) = mean(data(j:j+thirtysec));
    end
    
    %calculate theoretical "end" value for changing baseline
    idx_movavg = ind(min(movavg) == movavg);
    delta = (avg1st(i-1)-min(movavg))/(idx_movavg);
    theoretical_end = avg1st(i-1) - delta*(length(movavg));
    theo_end(i-1) = theoretical_end;

    if avglast(i-1) < avg1st(i-1)
        %area over baseline
        waste_area(i-1) = 0.5*(avg1st(i-1)+theoretical_end)*(endtime-starttime);
        
        %correct the AUC
        correct_AUC(i-1) = AUC(i-1) - waste_area(i-1);
    else
        %area over baseline (add avg1st(i-1) instead of min(movavg) for
        %varying baseline)
        waste_area(i-1) = avg1st(i-1)*(endtime-starttime);
        
        %correct the AUC
        correct_AUC(i-1) = AUC(i-1) - waste_area(i-1);
    end
    plot(t,data);
    hold on;
end

%outputs
titles = ["AUC", "1st 30s AVG", "Last 30s AVG", "Waste Area", "Corrected AUC", "TheoEnd"];
outputs = table(AUC', avg1st', avglast', waste_area', correct_AUC', theo_end', VariableNames=titles);
%% Outputs

%write to spreadsheet
filename = [filename(1:length(filename)-4), '_AUC', '.xlsx'];
writetable(outputs,filename,'Sheet',name);