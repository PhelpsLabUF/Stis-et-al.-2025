clc; clear; close all; 
%% User Defined Values
%import data
filename = '250430 Islets and Cells';
rawdata = readmatrix(filename, 'Sheet', 2);
sheet_name = 'Cells';
columns = size(rawdata,2);
rows = size(rawdata,1);
t = rawdata(:, 1); %minutes

%start and end times in minutes for peak calcs
starttime = 21;
endtime = 30;

%distance between peaks and height each peak must be
peakdist = 20;
peakprom = 0.05;
minwid = 5;

%islet number in sheet
i = 2;
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

%reformat data to just times wanting to plot 
t = t(starttime_idx:endtime_idx);

%this analyzes one islet at a time 
data = rawdata(:, i+1);
data = data(starttime_idx:endtime_idx);

%gently smooth data
data = smooth(data, 5);

% Finding Peaks and Valleys for Calcium Oscillations
[maxpks, maxlocs, widths, proms] = findpeaks(data, 'MinPeakDistance', peakdist, 'MinPeakProminence', peakprom, 'MinPeakWidth', minwid);
[minpks, minlocs] = findpeaks(-data, 'MinPeakDistance', peakdist, 'MinPeakProminence', peakprom, 'MinPeakWidth', minwid);
    
%display the peak data graph
figure();
findpeaks(data, 'MinPeakDistance', peakdist, 'MinPeakProminence', peakprom, 'MinPeakWidth', minwid, 'Annotate','extents')

if isempty(maxpks) == 0
    numpeaks = length(maxpks);
    ppm = numpeaks/(endtime - starttime);
else
    numpeaks = 0;
    ppm = numpeaks/(endtime - starttime);
end

%outputs
titles = ["NumPeaks", "Peaks per min"];
outputs = table(numpeaks, ppm, VariableNames=titles);
%% Outputs

%write to spreadsheet
filename = [filename(1:length(filename)-5), '_HighG_Peaks_2nd', '.xlsx'];
writetable(outputs,filename,'Sheet',sheet_name, 'WriteMode', 'append');