clc; clear; close all; 
%% User Defined Values
%import data
filename = '250403 Control Data for Peak Alignment.xlsx';
rawdata = readmatrix(filename, 'Sheet', 4);
sheet_name = '1.8';
columns = size(rawdata,2);
rows = size(rawdata,1);
t = rawdata(:, 1); %minutes

%start and end times in minutes for peak calcs
starttime = 10;
endtime = 40;

%distance between peaks and height each peak must be for islets
peakdist = 20;
peakprom = 0.2;
peakwidth = 10;

%distance between peaks and height each peak must be for cells
cpeakdist = 50;
cpeakprom = 0.06;

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

%this makes islets and cells separate data
idata = rawdata(:, 2);
cdata = rawdata(:,3);

%reformat data to just times wanting to plot
idata = idata(starttime_idx:endtime_idx);
cdata = cdata(starttime_idx:endtime_idx);
t = t(starttime_idx:endtime_idx);

%gently smooth data
idata = smooth(idata, 5);
cdata = smooth(cdata, 5);

%% Finding Peaks and Valleys for Calcium Oscillations of Islet
[maxpks, maxlocs, widths, proms] = findpeaks(idata, 'MinPeakDistance', peakdist, 'MinPeakProminence', peakprom, 'MinPeakWidth', peakwidth);
[minpks, minlocs] = findpeaks(-idata, 'MinPeakDistance', peakdist, 'MinPeakProminence', peakprom, 'MinPeakWidth', peakwidth);

% Finding Peaks and Valleys for Calcium Oscillations of Cells
[cmaxpks, cmaxlocs, cwidths, cproms] = findpeaks(cdata, 'MinPeakDistance', cpeakdist, 'MinPeakProminence', cpeakprom);
[cminpks, cminlocs] = findpeaks(-cdata, 'MinPeakDistance', cpeakdist, 'MinPeakProminence', cpeakprom);

%Find starting min point of 1st phase calcium
min1 = min(idata(50:400));
idx = find(idata == min1);
minlocs = [idx; minlocs];
minpks = [min1; minpks];

%display the peak data graph
figure();
findpeaks(idata, 'MinPeakDistance', peakdist, 'MinPeakProminence', peakprom,'MinPeakWidth', peakwidth, 'Annotate','extents')
hold on;
findpeaks(cdata, 'MinPeakDistance', cpeakdist, 'MinPeakProminence', cpeakprom,'Annotate','extents')

%remove unfinished peaks
if length(maxlocs) ~= length(minlocs) && minlocs(1) < maxlocs(1)
    
end

if length(maxlocs) ~= length(minlocs) && minlocs(1) > maxlocs(1)
    %remove 1st and last max
    maxlocs = maxlocs(2:length(maxlocs)-1);
end

if length(maxlocs) == length(minlocs) && minlocs(1) < maxlocs(1)
    %remove last max
    maxlocs = maxlocs(1:length(maxlocs)-1);
end

if length(maxlocs) == length(minlocs) && minlocs(1) > maxlocs(1)
    %remove first max
    maxlocs = maxlocs(2:length(maxlocs));
end

shift_array = [];
bsmax = [];
imax = [];
imin = [];
for i = 1:length(cmaxlocs)
    for j = 1:length(minlocs)-1
        if cmaxlocs(i) < minlocs(j+1) && cmaxlocs(i) > minlocs(j)
            if cmaxlocs(i) < maxlocs(j)
                shift = (maxlocs(j) - cmaxlocs(i))/(minlocs(j) - maxlocs(j))*100;
                shift_array = [shift_array, shift];
                bsmax = [bsmax, cmaxlocs(i)];
                imax = [imax, maxlocs(j)];
                imin = [imin, minlocs(j)];
            else
                shift = (maxlocs(j) - cmaxlocs(i))/(maxlocs(j) - minlocs(j+1))*100;
                shift_array = [shift_array, shift];
                bsmax = [bsmax, cmaxlocs(i)];
                imax = [imax, maxlocs(j)];
                imin = [imin, minlocs(j+1)];
            end
            break
        end
    end
end

titles = ["Biosensor Max", "Islet Max", "Islet Min", "Phase Shift (%)"];
outputs = table(bsmax', imax', imin', shift_array', VariableNames=titles);
%% Outputs
%write to spreadsheet
filename = ['250403_Control', '_Phase_Alignment', '.xlsx'];
writetable(outputs,filename,'Sheet',sheet_name);