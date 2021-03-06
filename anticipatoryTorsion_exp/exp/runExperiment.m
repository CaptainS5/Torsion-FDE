function runExperiment(inputParameter)

try
    global trigger;
    
    % New parameter for the slope, just set them manually here...
    % "do not want to mess with the GUI"--XW
    % --the cross point of the slope depends on the fixation point, should
    % be below the fixation point with the distance of the RDP radius
    % --the length of the slope above the cross point depends on the
    % diameter of RDP, equals the RDP diameter
    parameter.slopeLength = 24; % in degs, the whole length
    % the travel distance of the RDP should be (slope.length-diameter of
    % RDP)
    parameter.slopeAngle = 10; % in degs
    parameter.fixationYDisToCenter = -2.5; % in degs; distance to screen center, up is minus
    parameter.slopeWidth = 3;
    
    %Get parameter from GUI (user interface)
    parameter.translationalSpeed = inputParameter{1};
    parameter.rotationalSpeed = inputParameter{2};
    parameter.circleDiameter = inputParameter{3};
    parameter.dotsDiameter = inputParameter{4};
    parameter.dotsNumber = inputParameter{5};
    display.screenWidth = inputParameter{6};
    display.screenDistance = inputParameter{7};
    parameter.trialsPerCondition = inputParameter{8};
    parameter.block = inputParameter{9}; % the current block
    parameter.numberOfBlocks = 2; % total number of blocks
    if(inputParameter{10} == 1)
        parameter.showDecisionText = true;
    else
        parameter.showDecisionText = false;
    end
    
    
    parameter.initials = inputParameter{11};
    if(inputParameter{12} == 1)
        parameter.lifetimeLimited = true;
    else
        parameter.lifetimeLimited = false;
    end
    if(inputParameter{13} == 1)
        parameter.showOutline = true;
    else
        parameter.showOutline = false;
    end
    parameter.lifetime = inputParameter{14};
    if(inputParameter{15} == 1)
        parameter.horizontal = true;
    else
        parameter.horizontal = false;
    end
    if(inputParameter{16} == 1)
        display.screen = max(max(Screen('Screens')-1),0);
    else
        display.screen = max(Screen('Screens'));
    end
    parameter.duration = inputParameter{17};
    parameter.multiplier = inputParameter{18};
    display.screenHeight = inputParameter{19};
    if(inputParameter{20} == 1)
        parameter.demo = true;
    else
        parameter.demo = false;
    end
    parameter.speedLevels = inputParameter{21};
    if(inputParameter{22} == 1)
        showSaccades = true;
    else
        showSaccades = false;
    end
    parameter.subjectID = inputParameter{23};
    parameter.experimentID = inputParameter{24};
    parameter.experiment = inputParameter{25};
    if(inputParameter{26} == 1)
        showBaseline = true;
        parameter.baseline = true;
    else
        showBaseline = false;
        parameter.baseline = false;
    end
    if(inputParameter{27} == 1)
        parameter.torsion = true;
        showTorsion = true;
    else
        parameter.torsion = false;
        showTorsion = false;
    end
    if(inputParameter{28} == 1)
        parameter.baselineCircle = true;
    else
        parameter.baselineCircle = false;
    end
    if(inputParameter{29} == 1)
        parameter.baselineDot = true;
    else
        parameter.baselineDot = false;
    end
    
    
    
    HideCursor;
    
    %Open screen
    [display.windowPointer, display.size] = Screen('OpenWindow',display.screen);
    % % for debug
    % [display.windowPointer, display.size] = Screen('OpenWindow',display.screen, [], [0 0 640 512]);
    display.windowPointer = display.windowPointer;
    display.size = display.size;
    load('lut527.mat')
    % Make a backup copy of original LUT into origLUT.
    originalLUT=Screen('ReadNormalizedGammaTable', display.screen);
    save('originalLUT.mat', 'originalLUT');
    Screen('LoadNormalizedGammaTable', display.windowPointer, lut527);
    
    numberOfSpeedLevels = length(parameter.speedLevels);
    possibleConditions = [numberOfSpeedLevels 1 2];
    % the second is either with rotation (block 2) or without rotation (block 1)
    % the third is translation direction
    % we always want natural rotation in the slope exp, so rotation
    % direction depends on translation direction--always "natural"
    
    
    if(parameter.demo)
        %table with all possible combinations
        conditionTable = createConditionTable(possibleConditions);
        
        %set with index numbers for the condition table
        conditionSampler = createConditionSampler(possibleConditions, parameter.trialsPerCondition);
        %     conditionSampler = cutOutBaselineTrials(conditionSampler, possibleConditions);
        
        numberOfDemoTrials = 20;
        
        for trial = 1:numberOfDemoTrials
            
            trialConditions = conditionTable(conditionSampler(trial),2:length(possibleConditions)+1);
            
            rotationStimulusDrawDots(display, parameter, trialConditions);
            
            showResponseModule(display, parameter);
            
            %         while(true)
            %             [keyIsDown, ~, keyCode, ~] = KbCheck();
            %             if(keyIsDown == 1)
            %
            %                 %Faster
            %
            %                 pause(0.5)
            %
            %                 break;
            %
            %             end
            %         end
            
        end
        
        
        Screen('LoadNormalizedGammaTable', display.windowPointer, originalLUT);
        Screen('CloseAll');
        startScript();
        return;
    end
    
    
    
    %     for block = parameter.block:parameter.numberOfBlocks
    
    %         if(parameter.block == 1) || isempty(fileID)
    fileID = setupFile(parameter);
    printHeader(fileID, parameter)
    %         end
    
    %% show Calibration (this is outdated by now)
%     try
%         
%         startCalibration(display.screenWidth, display.screenHeight,...
%             display.screenDistance, display.windowPointer, display.size); %, parameter);
%         HideCursor;
%     catch ME
%         msgString = getReport(ME)
%         disp(msgString);
%         disp('Calibration interrupted.');
%         disp(ME.message);
%     end
    
    %% show Listings Calibration (in any case)
    %
    if(~showSaccades)
        try
    
            startListingsPlaneCalibration(display.screenWidth, display.screenHeight,...
                display.screenDistance, display.windowPointer, display.size, parameter);
            HideCursor;
    
        catch ME
            msgString = getReport(ME);
            disp(msgString);
            disp('Calibration interrupted.');
        end
    end
    
    
    %% Saccades block
%     if(showSaccades)
%         
%         %Break before each block. Continue with F12
%         showBreakModule(display)
%         
%         
%         try
%             sampledOrder = startListingsPlaneBlock(display.screenWidth, display.screenHeight,...
%                 display.screenDistance, display.windowPointer, display.size, parameter);
%             
%         catch ME
%             disp('Listings Calibration interrupted.');
%             disp(ME.message);
%         end
%     end
    
    
    
    %
    
    
    %% Torsion and Baseline block
    if(showTorsion || showBaseline)
        
        %Break before each block. Continue with F12
        showBreakModule(display)
        
        
        %     %Fixation to achieve straight gaze
        showCenterFixation(display.windowPointer, display.size, display.screenWidth, display.screenHeight, display.screenDistance, parameter);
        
        %table with all possible combinations
        conditionTable = createConditionTable(possibleConditions);
        
        %set with index numbers for the condition table
        conditionSampler = createConditionSampler(possibleConditions, parameter.trialsPerCondition);
        % conditionSampler = cutOutBaselineTrials(conditionSampler, possibleConditions);
        
        
        
        for trial = 1:length(conditionSampler)
            disp(['Current trial: ' num2str(trial)]);
            
            %pick trial conditions from conditionTable
            %chose the line that is picked by the conditionSampler
            trialConditions = conditionTable(conditionSampler(trial),2:length(possibleConditions)+1);
            
            try
                %             if(parameter.horizontal)
                %                 [randomSpeed translationalDirection rotationalDirection] = rotationStimulusDrawDots(display, parameter, trialConditions);
                %             else
                [randomSpeed translationalDirection rotationalDirection] = rotationStimulusDrawDots(display, parameter, trialConditions);
                %             end
            catch ME
                Screen('LoadNormalizedGammaTable', display.windowPointer, originalLUT);
                disp(ME.message);
                disp('Error in StimulusModule');
                return;
            end
            
            trigger.stopRecording();
            
            
            %show response module
            try
                decision = showResponseModule(display, parameter);
            catch ME %#ok<NASGU>
                Screen('LoadNormalizedGammaTable', display.windowPointer, originalLUT);
                disp('Error in ResponseModule');
                return;
            end
            
            printTrialData(fileID, parameter.block, trial, translationalDirection,...
                rotationalDirection, randomSpeed, decision, parameter);
            
        end
        
    end
    %         Screen('LoadNormalizedGammaTable', display.windowPointer, originalLUT);
    %         Screen('CloseAll');
    %         ShowCursor;
    %         startScript();
    %         return;
    %     end
    
    %% Clean up
    Screen('LoadNormalizedGammaTable', display.windowPointer, originalLUT);
    Screen('CloseAll');
    ShowCursor;
    fclose(fileID);
    
    % end
    
catch ME
    trigger.stopRecording();
    disp('Error in runExperiment');
    disp(ME.message);
    clear all;
    return;
end

end

function [fileID] = setupFile(parameter)
fileName = [parameter.experimentID '_' parameter.initials '_b' num2str(parameter.block) datestr(now, '_yyyy_mmmm_dd_HH_MM_SS') '.txt'];
filePath = fullfile(pwd, 'LogFiles',fileName);
fileID = fopen(filePath,'a');
end

function printHeader(fileID, parameter)
fprintf(fileID, ['ExperimentID: ' parameter.experimentID '\n']);
fprintf(fileID, ['SubjectID: ' parameter.subjectID '\n']);
fprintf(fileID, ['Experiment: ' parameter.experiment '\n']);
fprintf(fileID, datestr(now, 'yyyy_mmmm_dd_HH:MM:SS.FFF\n'));
fprintf(fileID, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s \n',...
    'block', 'trial', 'translationalDirection', 'rotationalDirection',...
    'randomSpeed', 'decision',...
    'circleDiameter', 'translationalSpeed',...
    'rotationalSpeed', 'duration',...
    'multiplier', 'dotsDiameter', 'dotsNumber', 'slopeAngle' );
end

function printTrialData(fileID, block, trial, translationalDirection,...
    rotationalDirection, randomSpeed, decision, parameter)
fprintf(fileID, '%d %d %d %d %0.0f %d %0.1f %0.1f %d %d %0.2f %0.2f %d %0.1f \n',...
    block, trial, translationalDirection, rotationalDirection,...
    randomSpeed, decision,...
    parameter.circleDiameter, parameter.translationalSpeed,...
    parameter.rotationalSpeed, parameter.duration,...
    parameter.multiplier, parameter.dotsDiameter,...
    parameter.dotsNumber, parameter.slopeAngle);
disp('Trial data printed.');
end

% function  [conditionSampler] = cutOutBaselineTrials(conditionSampler, possibleConditions)
% indices = conditionSampler > prod(possibleConditions)-2;
% conditionSampler(indices) = [];
% end