% Xiuyun Wu, 11/27/2018, Torsion Exp1
% getting the raw processed eye data... will be much more convenient for
% later analysis; from stimulus onset to stimulus offset
% need to correctly mark the time points! also whether the trial is
% valid
% excluding saccades, and replace them with extrapolation for velocity
% traces?...
clear all; close all; clc

global trial

names = {'JL' 'RD' 'MP' 'CB' 'KT' 'MS' 'IC' 'SZ' 'NY' 'SD' 'JZ' 'BK' 'RR' 'TM' 'LK'};
conditions = [25 50 100 200 400];
cd ..
analysisF = pwd;
dataFolder = {'C:\Users\CaptainS5\Documents\PhD@UBC\Lab\1st year\TorsionPerception\data\Exp1'};
trialPerCon = 60; % for each rotation speed, all directions together though...
totalBlocks = 5; % how many blocks in total
% eye data processing parameters
tSacThreshold = 8*ones(size(names)); % threshold for torsional saccades
% tSacRemoveFrames = 3*ones(size(names)); 
% threshold for reverse saccade, exceeding how many frames before? and
% after?... check the code
eyeName = {'L' 'R'};

% count = 1;
for subN = 1:length(names)
    cd(analysisF)
    % Subject details
    subject = names{subN};
    trialN = 1; % label the trial number so it would be easier to correspond perceptual, left eye, and right eye data
    
    for blockN = 1:totalBlocks
%         errorsL = load(['Errorfiles\Exp' num2str(blockN) '_Subject' num2str(subN,'%.2i') '_Block' num2str(blockN,'%.2i') '_L_errorFile.mat']);
        errorsR = load(['Errorfiles\Exp' num2str(blockN) '_Subject' num2str(subN,'%.2i') '_Block' num2str(blockN,'%.2i') '_R_errorFile.mat']);
        % load response data for trial information
        dataFile = dir([dataFolder{:} '\' subject '\response' num2str(blockN) '_*.mat']);
        load([dataFolder{:} '\' subject '\' dataFile.name]) % resp is the response data for the current block
        
        for t = 1:size(resp, 1) % trial number
            eyeTrialData.sub(subN, trialN) = subN;
            eyeTrialData.trial(subN, trialN) = trialN;
            eyeTrialData.rotationSpeed(subN, trialN) = resp.rotationSpeed(t);
            eyeTrialData.afterReversalD(subN, trialN) = -resp.initialDirection(t); % 1=clockwise, -1=counterclockwise
%             eyeTrialData.errorStatusL(subN, trialN) = errorsL.errorStatus(t);
            eyeTrialData.errorStatusR(subN, trialN) = errorsR.errorStatus(t);

            %% right eye
            eye = 2;
            % read in data and socscalexy
            filename = ['session_' num2str(blockN,'%.2i') '_' eyeName{eye} '.dat'];
            if subN==5 && blockN==5 % for KT, 5
                data = readDataFile_KTb5(filename, [dataFolder{:} '\' subject '\chronos']);
            elseif subN==6 && blockN==3 % for MS, b3-lost frames...
                data = readDataFile_MSb3(filename, [dataFolder{:} '\' subject '\chronos']);
            elseif subN==7 && blockN==1 % for IC, b1-lost frames
                data = readDataFile_ICb1(filename, [dataFolder{:} '\' subject '\chronos']);
            elseif subN==9 && blockN==5 % for NY, b5-lost frames...
                data = readDataFile_NYb5(filename, [dataFolder{:} '\' subject '\chronos']);
            elseif subN==13 && blockN==4 % for RR, b4-lost frames...
                data = readDataFile_RRb4(filename, [dataFolder{:} '\' subject '\chronos']);
            else
                data = readDataFile(filename, [dataFolder{:} '\' subject '\chronos']);
            end
            data = socscalexy(data);
            [header, logData] = readLogFile(blockN, ['response' num2str(blockN,'%.2i') '_' subject] , [dataFolder{:} '\' subject]);
            sampleRate = 200;
            
            % setup trial, remove saccades
            trial = setupTrial(data, header, logData, t);
            
            find saccades;
            [saccades.X.onsets, saccades.X.offsets, saccades.X.isMax] = findSaccades(trial.stim_onset, trial.stim_offset, trial.frames.DX_filt, trial.frames.DDX_filt, 20, 0);
            [saccades.Y.onsets, saccades.Y.offsets, saccades.Y.isMax] = findSaccades(trial.stim_onset, trial.stim_offset, trial.frames.DY_filt, trial.frames.DDY_filt, 20, 0);
            [saccades.T.onsets, saccades.T.offsets, saccades.T.isMax] = findSaccades(trial.stim_onset, trial.stim_offset, trial.frames.DT_filt, trial.frames.DDT_filt, tSacThreshold(subN), 0);
            
            % analyze saccades
            [trial] = analyzeSaccades(trial, saccades);
            clear saccades;
            
            % remove saccades
            trial = removeSaccades(trial);
            % end of setting up trial
            
            eyeTrialData.stim.onset(subN, trialN) = trial.stim_onset;
            eyeTrialData.stim.reversalOnset(subN, trialN) = trial.stim_reversalOnset;
            eyeTrialData.stim.reversalOffset(subN, trialN) = trial.stim_reversalOffset;
            eyeTrialData.stim.offset(subN, trialN) = trial.stim_offset;
            eyeTrialData.stim.beforeFrames(subN, trialN) = trial.stim_reversalOnset-trial.stim_onset; % for later alignment of velocity traces
            eyeTrialData.stim.afterFrames(subN, trialN) = trial.stim_offset-trial.stim_reversalOffset+1; % for later alignment of velocity traces
            eyeTrialData.frameLog.startFrame(subN, trialN) = trial.startFrame;
            eyeTrialData.frameLog.endFrame(subN, trialN) = trial.endFrame;
            eyeTrialData.frameLog.length(subN, trialN) = trial.length;
            eyeTrialData.frameLog.lostXframes{subN, trialN} = trial.lostXframes;
            eyeTrialData.frameLog.lostYframes{subN, trialN} = trial.lostYframes;
            eyeTrialData.frameLog.lostTframes{subN, trialN} = trial.lostTframes;
            eyeTrialData.frameLog.quickphaseFrames{subN, trialN} = trial.quickphaseFrames;
            eyeTrialData.saccades{subN, trialN} = trial.saccades;
            eyeTrialData.frames{subN, trialN} = trial.frames;
            
%             %% retinal torsion angle
%             dataTemp.LtorsionPosition(trialN, 1) = nanmean(torsion.slowPhases.onsetPosition);
%             
%             %% torsion velocity
%             dataTemp.LtorsionVelT(trialN, 1) = torsion.slowPhases.meanSpeed;
%             
%             %% torsion magnitude
%             dataTemp.LtorsionAngleTotal(trialN, 1) = torsion.slowPhases.totalAngle;
%             dataTemp.LtorsionAngleCW(trialN, 1) = torsion.slowPhases.totalAngleCW;
%             dataTemp.LtorsionAngleCCW(trialN, 1) = -torsion.slowPhases.totalAngleCCW;
%             
%             %% saccade numbers
%             dataTemp.LsacNumT(trialN, 1) = trial.saccades.T.number;
%             dataTemp.LsacNumTCW(trialN, 1) = trial.saccades.T_CW.number;
%             dataTemp.LsacNumTCCW(trialN, 1) = trial.saccades.T_CCW.number;
%             
%             %% saccade sum amplitudes
%             dataTemp.LsacAmpSumT(trialN, 1) = trial.saccades.T.sum;
%             dataTemp.LsacAmpSumTCW(trialN, 1) = trial.saccades.T_CW.sum;
%             dataTemp.LsacAmpSumTCCW(trialN, 1) = trial.saccades.T_CCW.sum;
%             
%             %% saccade mean amplitudes
%             dataTemp.LsacAmpMeanT(trialN, 1) = trial.saccades.T.meanAmplitude;
%             dataTemp.LsacAmpMeanTCW(trialN, 1) = trial.saccades.T_CW.meanAmplitude;
%             dataTemp.LsacAmpMeanTCCW(trialN, 1) = trial.saccades.T_CCW.meanAmplitude;
                        
            trialN = trialN+1;
%             count = count + 1;
        end
    end
end
cd([analysisF '\analysis functions'])
save(['eyeDataAll.mat'], 'eyeTrialData');
% rows are participants, columns are trials--all trial included