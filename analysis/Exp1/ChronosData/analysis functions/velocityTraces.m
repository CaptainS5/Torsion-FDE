% plot velocity traces, generate csv file for plotting in R, Exp1
% also calculate torsional latency based on mean values in each speed
% condition (directions merged)
clear all; close all; clc

names = {'JL' 'RD' 'MP' 'CB' 'KT' 'MS' 'IC' 'SZ' 'NY' 'SD' 'JZ' 'BK' 'RR' 'TM' 'LK'};
conditions = [25 50 100 200 400];
sampleRate = 200; 
folder = pwd;

load('eyeDataAll.mat')
% load('eyeDataAllBase.mat')

%% directions merged, generate csv files for R plotting
% consistent reversal duration and duration after for all participants
reversalFrames = eyeTrialData.stim.reversalOffset(10, 1)-eyeTrialData.stim.reversalOnset(10, 1);
afterFrames = eyeTrialData.stim.afterFrames(10, 1);
for subN = 1:size(names, 2)
    maxBeforeFrames = max(eyeTrialData.stim.beforeFrames(subN, :));
    frameLength(subN) = maxBeforeFrames+reversalFrames+afterFrames;
    for speedI = 1:size(conditions, 2)
        validI = find(eyeTrialData.errorStatusR(subN, :)==0 & eyeTrialData.rotationSpeed(subN, :)==conditions(speedI)); 
        frames{subN, speedI} = NaN(length(validI), frameLength(subN)); % align the reversal; filled with NaN
        % rows are trials, columns are frames
        framesInitial{subN, speedI} = NaN(length(validI), frameLength(subN)); % align the motion onset; filled with NaN
        % rows are trials, columns are frames
        
        % fill in the velocity trace of each frame
        % interpolate NaN points for a better velocity trace
        for validTrialN = 1:length(validI)
            startI = eyeTrialData.stim.onset(subN, validI(validTrialN));
            endI = eyeTrialData.stim.offset(subN, validI(validTrialN));
            startIF = maxBeforeFrames-eyeTrialData.stim.beforeFrames(subN, validI(validTrialN))+1;
            endIF = maxBeforeFrames+reversalFrames+eyeTrialData.stim.afterFrames(subN, validI(validTrialN));
            frames{subN, speedI}(validTrialN, startIF:endIF) = eyeTrialData.frames{subN, validI(validTrialN)}.DT_noSac(startI:endI)*eyeTrialData.afterReversalD(subN, validI(validTrialN)); % flip directions
            framesInitial{subN, speedI}(validTrialN, 1:(endI-startI+1)) = eyeTrialData.frames{subN, validI(validTrialN)}.DT_noSac(startI:endI)*eyeTrialData.afterReversalD(subN, validI(validTrialN)); % flip directions
        end
    end
end
maxFrameLength = max(frameLength);

% for each rotational speed, draw the mean filtered and unfiltered
% velocity trace
for speedI = 1:size(conditions, 2)
    velTAverage{speedI} = NaN(length(names), maxFrameLength);
    velTStd{speedI} = NaN(length(names), maxFrameLength);
    velTInitialAverage{speedI} = NaN(length(names), maxFrameLength);
    velTInitialStd{speedI} = NaN(length(names), maxFrameLength);
    
    for subN = 1:size(names, 2)
        tempStartI = maxFrameLength-frameLength(subN)+1;
        velTAverage{speedI}(subN, tempStartI:end) = nanmean(frames{subN, speedI});
        velTStd{speedI}(subN, tempStartI:end) = nanstd(frames{subN, speedI});
        velTInitialAverage{speedI}(subN, tempStartI:end) = nanmean(framesInitial{subN, speedI});
        velTInitialStd{speedI}(subN, tempStartI:end) = nanstd(framesInitial{subN, speedI});
    end
    
    % plotting parameters
    minFrameLength = min(frameLength);
    beforeFrames = minFrameLength-reversalFrames-afterFrames;
    framePerSec = 1/sampleRate;
    timePReversal = [0:(reversalFrames-1)]*framePerSec*1000;
    timePBeforeReversal = timePReversal(1)-(beforeFrames+1-[1:beforeFrames])*framePerSec*1000;
    timePAfterReversal = timePReversal(end)+[1:afterFrames]*framePerSec*1000;
    timePoints = [timePBeforeReversal timePReversal timePAfterReversal]; % align at the reversal and after...
    % reversal onset is 0
    velTmean{speedI} = nanmean(velTAverage{speedI}(:, (maxFrameLength-minFrameLength+1):end));
    % need to plot ste? confidence interval...?
    
%     figure
%     % filtered mean velocity trace
%     subplot(2, 1, 1)
%     plot(timePoints, velTmean{speedI})
%     % hold on
%     % patch(timePoints, )
%     title(['rotational speed ', num2str(conditions(speedI))])
%     xlabel('Time (ms)')
%     ylabel('Torsional velocity (deg/s)')
%     % ylim([-0.5 0.5])
%     
% %     % mean velocity trace, aligned at motion onset
% %     subplot(2, 1, 2)
% %     plot(timePoints, nanmean(velTInitialAverage{speedI}(:, 1:(maxFrameLength-minFrameLength+1))))
% %     title(['rotational speed ', num2str(conditions(speedI))])
% %     xlabel('Time (ms)')
% %     ylabel('Torsional velocity_unfiltered (deg/s)')
% %     ylim([-2 2])
% %     
%     % saveas(gca, ['velocityTraces_', num2str(conditions(speedI)), '.pdf'])
end

% generate csv files, each file for one speed condition
% each row is the mean velocity trace of one participant
% use the min frame length--the lengeth where all participants have
% valid data points
for speedI = 1:size(conditions, 2)
    idxN = [];
    % find the min frame length in each condition
    for subN = 1:size(names, 2)
        tempI = find(~isnan(velTAverage{speedI}(subN, :)));
        idxN(subN) = tempI(1);
    end
    startIdx(speedI) = max(idxN);
end

startI = max(startIdx);
velTAverageSubBase = [];
velTInitialAverageSubBase = [];
latency = [];
% cd('C:\Users\CaptainS5\Documents\PhD@UBC\Lab\1stYear\TorsionPerception\analysis')
% for each participant in each rotational speed, draw the mean
% calculate latency in seconds and save
for speedI = 1:size(conditions, 2)
    for subN = 1:size(names, 2)
        velTAverageSubBase(subN, :) = velTAverage{speedI}(subN, startI:end);
        velTInitialAverageSubBase(subN, :) = velTInitialAverage{speedI}(subN, :);
        % calculate latency in seconds, the point when velocity
        % exceeds 0.1 deg/s
        reversalOnsetFrame = length(velTAverageSubBase(subN, :))-afterFrames-reversalFrames+1;
        minOnsetFrame = reversalOnsetFrame+80/1000*sampleRate; % 80 ms after reversal
        onsetFrame = find(velTAverageSubBase(subN, :)>0.1);
        onsetFrame = onsetFrame(onsetFrame>minOnsetFrame);
        onsetFrame = onsetFrame(1);
        latency(subN, speedI) = (onsetFrame-reversalOnsetFrame)/sampleRate; % this is the latency after reversal
        % latency before reversal, latencyB
        minOnsetFrame = 80/1000*sampleRate; % 80 ms after reversal
        onsetFrame = find(velTInitialAverageSubBase(subN, :)<-0.1);
        onsetFrame = onsetFrame(onsetFrame>minOnsetFrame);
        onsetFrame = onsetFrame(1);
        latencyB(subN, speedI) = onsetFrame/sampleRate; % this is the latency after reversal
    end
%     csvwrite(['velocityTraceExp1_', num2str(conditions(speedI)), '.csv'], velTAverageSubBase)
end
% save('torsionLatencyExp1', 'latency', 'latencyB')

%% baseline
% reversalFrames = eyeTrialDataBase.stim.reversalOffset(1, 1)-eyeTrialDataBase.stim.reversalOnset(1, 1);
% afterFrames = eyeTrialDataBase.stim.afterFrames(1, 1);
% for subN = 1:7
%     maxBeforeFrames = max(eyeTrialDataBase.stim.beforeFrames(subN, :));
%     frameLength(subN) = maxBeforeFrames+reversalFrames+afterFrames;
%     for speedI = 1:size(conditions, 2)
%         validI = find(eyeTrialDataBase.errorStatusR(subN, :)==0 & eyeTrialDataBase.rotationSpeed(subN, :)==conditions(speedI)); 
%         frames{subN, speedI} = NaN(length(validI), frameLength(subN)); % align the reversal; filled with NaN
%         % rows are trials, columns are frames
%         framesInitial{subN, speedI} = NaN(length(validI), frameLength(subN)); % align the reversal; filled with NaN
%         % rows are trials, columns are frames
%         
%         % fill in the velocity trace of each frame
%         % interpolate NaN points for a better velocity trace
%         for validTrialN = 1:length(validI)
%             startI = eyeTrialDataBase.stim.onset(subN, validI(validTrialN));
%             endI = eyeTrialDataBase.stim.offset(subN, validI(validTrialN));
%             startIF = maxBeforeFrames-eyeTrialDataBase.stim.beforeFrames(subN, validI(validTrialN))+1;
%             endIF = maxBeforeFrames+reversalFrames+eyeTrialDataBase.stim.afterFrames(subN, validI(validTrialN));
%             frames{subN, speedI}(validTrialN, startIF:endIF) = eyeTrialDataBase.frames{subN, validI(validTrialN)}.DT_noSac(startI:endI)*eyeTrialDataBase.afterReversalD(subN, validI(validTrialN)); % flip directions
% %             framesUnfilt{subN, speedI}(validTrialN, startIF:endIF) = eyeTrialDataBase.frames{subN, validI(validTrialN)}.DTUnfilt_noSac(startI:endI)*eyeTrialDataBase.afterReversalD(subN, validI(validTrialN)); % flip directions
%         end
%     end
% end
% maxFrameLength = max(frameLength);
% 
% % for each rotational speed, draw the mean filtered and unfiltered
% % velocity trace
% for speedI = 1:size(conditions, 2)
%     velTAverage{speedI} = NaN(length(names), maxFrameLength);
%     velTStd{speedI} = NaN(length(names), maxFrameLength);
%     velTInitialAverage{speedI} = NaN(length(names), maxFrameLength);
%     velTInitialStd{speedI} = NaN(length(names), maxFrameLength);
%     
%     for subN = 1:7
%         tempStartI = maxFrameLength-frameLength(subN)+1;
%         velTAverage{speedI}(subN, tempStartI:end) = nanmean(frames{subN, speedI});
%         velTStd{speedI}(subN, tempStartI:end) = nanstd(frames{subN, speedI});
%         velTInitialAverage{speedI}(subN, tempStartI:end) = nanmean(framesInitial{subN, speedI});
%         velTInitialStd{speedI}(subN, tempStartI:end) = nanstd(framesInitial{subN, speedI});
%     end
%     
%     % plotting parameters
%     minFrameLength = min(frameLength);
%     beforeFrames = minFrameLength-reversalFrames-afterFrames;
%     framePerSec = 1/sampleRate;
%     timePReversal = [0:(reversalFrames-1)]*framePerSec*1000;
%     timePBeforeReversal = timePReversal(1)-(beforeFrames+1-[1:beforeFrames])*framePerSec*1000;
%     timePAfterReversal = timePReversal(end)+[1:afterFrames]*framePerSec*1000;
%     timePoints = [timePBeforeReversal timePReversal timePAfterReversal]; % align at the reversal and after...
%     % reversal onset is 0
%     velTmean{speedI} = nanmean(velTAverage{speedI}(:, (maxFrameLength-minFrameLength+1):end));
%     % need to plot ste? confidence interval...?
%     
%     figure
%     % filtered mean velocity trace
% %     subplot(2, 1, 1)
%     plot(timePoints, velTmean{speedI})
%     % hold on
%     % patch(timePoints, )
%     title(['base rotational speed ', num2str(conditions(speedI))])
%     xlabel('Time (ms)')
%     ylabel('Torsional velocity (deg/s)')
%     % ylim([-0.5 0.5])
%     
% %     % unfiltered mean velocity trace
% %     subplot(2, 1, 2)
% %     plot(timePoints, nanmean(velTUnfiltAverage{speedI}(:, (maxFrameLength-minFrameLength+1):end)))
% %     title(['base rotational speed ', num2str(conditions(speedI))])
% %     xlabel('Time (ms)')
% %     ylabel('Torsional velocity_unfiltered (deg/s)')
% %     ylim([-2 2])
% %     
% %     % saveas(gca, ['velocityTraces_', num2str(conditions(speedI)), '.pdf'])
% end
% 
% % generate csv files, each file for one speed condition
% % each row is the mean velocity trace of one participant
% % use the min frame length--the lengeth where all participants have
% % valid data points
% for speedI = 1:size(conditions, 2)
%     idxN = [];
%     % find the min frame length in each condition
%     for subN = 1:7
%         tempI = find(~isnan(velTAverage{speedI}(subN, :)));
%         idxN(subN) = tempI(1);
%     end
%     startIdx(speedI) = max(idxN);
% end
% 
% startI = max(startIdx);
% velTAverageSubBase = [];
% cd('C:\Users\CaptainS5\Documents\PhD@UBC\Lab\1st year\TorsionPerception\analysis')
% % for each participant in each rotational speed, draw the mean
% % calculate latency in seconds and save
% for speedI = 1:size(conditions, 2)
%     for subN = 1:7
%         velTAverageSubBase(subN, :) = velTAverage{speedI}(subN, startI:end);
%         % calculate latency in seconds, the point when velocity
%         % exceeds 0.1 deg/s
%         reversalOnsetFrame = length(velTAverageSubBase(subN, :))-afterFrames-reversalFrames+1;
%         minOnsetFrame = reversalOnsetFrame+80/1000*sampleRate; % 80 ms after reversal
%         onsetFrame = find(velTAverageSubBase(subN, :)>0.1);
%         onsetFrame = onsetFrame(onsetFrame>minOnsetFrame);
%         onsetFrame = onsetFrame(1);
%         latency(subN, speedI) = (onsetFrame-reversalOnsetFrame)/sampleRate;
%     end
%     csvwrite(['velocityTraceExp1_base_', num2str(conditions(speedI)), '.csv'], velTAverageSubBase)
% end