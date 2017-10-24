function runExperiment(inputParameter)

global trigger;

%Get parameter from GUI (user interface)
parameter.horizontalSpeed = inputParameter{1};
parameter.rotationalSpeed = inputParameter{2};
parameter.circleDiameter = inputParameter{3};
parameter.dotsDiameter = inputParameter{4};
parameter.dotsNumber = inputParameter{5};
display.screenWidth = inputParameter{6};
display.screenDistance = inputParameter{7};
parameter.trialsPerCondition = inputParameter{8};
parameter.block = inputParameter{9};
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

parameter.singleDir = inputParameter{30};
parameter.moveRight = inputParameter{31};
parameter.moveLeft = inputParameter{32};
parameter.cue = inputParameter{33};

if parameter.cue
    % load cue images
    ccwimgdir = './cues/ccw.jpg';
    noneimgdir = './cues/none.png';
    dotdir = './cues/dot.jpg';

    ccw = imread(ccwimgdir);
    cw = fliplr(ccw);
    none = imcomplement(imread(noneimgdir));
    dot = imread(dotdir);
    
    cw = imrotate(cw, -90);
    ccw = imrotate(ccw, 90);

    
    cw(cw>25) = 150;
    ccw(ccw>25) = 150;
    none(none>63) = 150;
    none(none<=63) = 0;
    dot(dot>25) = 150;
    
    
    parameter.cw = cw;
    parameter.ccw = ccw;
    parameter.none = none;
    parameter.dot = dot;
end

% HideCursor;

%Open screen
[display.windowPointer, display.size] = Screen('OpenWindow', display.screen);
display.windowPointer = display.windowPointer;
display.size = display.size;
load('lut527.mat')
% Make a backup copy of original LUT into origLUT.
originalLUT=Screen('ReadNormalizedGammaTable', display.screen);
save('originalLUT.mat', 'originalLUT');
Screen('LoadNormalizedGammaTable', display.windowPointer, lut527);

numberOfSpeedLevels = length(parameter.speedLevels);
if(parameter.singleDir == 1)
    possibleConditions = [numberOfSpeedLevels 1 1];
else
    possibleConditions = [numberOfSpeedLevels 2 2];
end




if parameter.cue && parameter.block == 2
    cueConditions = createCueConditions(numberOfSpeedLevels);
    save('conditiontable.mat', 'cueConditions')
end

% get cue condition table
if parameter.cue
    switch parameter.block
        case 2
            load('conditiontable.mat')
            cueConditions = cueConditions(1:100,:);
        case 4
            load('conditiontable.mat')
            cueConditions = cueConditions(101:200,:);
        case 6
            load('conditiontable.mat')
            cueConditions = cueConditions(201:300,:);
        case 8
            load('conditiontable.mat')
            cueConditions = cueConditions(301:400,:);
        case 10
            load('conditiontable.mat')
            cueConditions = cueConditions(401:500,:);
        case 12
            load('conditiontable.mat')
            cueConditions = cueConditions(501:600,:);
    end
end
pause(1);
if(parameter.demo)
    
    if ~parameter.cue
        %table with all possible combinations
        conditionTable = createConditionTable(possibleConditions);

        %set with index numbers for the condition table
        conditionSampler = createConditionSampler(possibleConditions, parameter.trialsPerCondition);
        %     conditionSampler = cutOutBaselineTrials(conditionSampler, possibleConditions);
    end
    

    
    numberOfDemoTrials = 20;
    
    for trial = 1:numberOfDemoTrials
        
        if parameter.cue
            trialConditions = [cueConditions(trial,:) 1];
        else
            trialConditions = conditionTable(conditionSampler(trial),2:length(possibleConditions)+1);
        end
        
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



% for block = parameter.startBlock:parameter.numberOfBlocks

fileID = setupFile(parameter);

if(parameter.block == 2)
    printHeader(fileID, parameter)
end

%% show Calibration (this is outdated by now)
% try
%
%     startCalibration(display.screenWidth, display.screenHeight,...
%        display.screenDistance, display.windowPointer, display.size, parameter);
%
% catch ME
%     msgString = getReport(ME)
%     disp(msgString);
%     disp('Calibration interrupted.');
%     disp(ME.message);
% end

%% show Listings Calibration (in any case)

if(~showSaccades)
    try
        
        startCalibration(display.screenWidth, display.screenHeight,...
            display.screenDistance, display.windowPointer, display.size);
        
    catch ME
        msgString = getReport(ME);
        disp(msgString);
        disp('Calibration interrupted.');
    end
end


%% Saccades block
if(showSaccades)
    
    %Break before each block. Continue with F12
    showBreakModule(display)
    
    
    try
        sampledOrder = startListingsPlaneBlock(display.screenWidth, display.screenHeight,...
            display.screenDistance, display.windowPointer, display.size, parameter);
        
    catch ME
        disp('Listings Calibration interrupted.');
        disp(ME.message);
    end
end



%


%% Torsion and Baseline block
if(showTorsion || showBaseline)
    
    %Break before each block. Continue with F12
    showBreakModule(display)
    
    
    %     %Fixation to achieve straight gaze
    showCenterFixation(display.windowPointer, display.size, display.screenWidth, display.screenHeight, display.screenDistance);
    

    %table with all possible combinations
    conditionTable = createConditionTable(possibleConditions);

    %set with index numbers for the condition table
    conditionSampler = createConditionSampler(possibleConditions, parameter.trialsPerCondition);
    % conditionSampler = cutOutBaselineTrials(conditionSampler, possibleConditions);
   
    
    for trial = 1:length(conditionSampler)
        disp(['Current trial: ' num2str(trial)]);
        
        
        if parameter.cue
            trialConditions = [cueConditions(trial,:) 1];
        else
            %pick trial conditions from conditionTable
            %chose the line that is picked by the conditionSampler
            trialConditions = conditionTable(conditionSampler(trial),2:length(possibleConditions)+1);
        end
        
        try
            if(parameter.horizontal)
                [randomSpeed, translationalDirection, rotationalDirection] = rotationStimulusDrawDots(display, parameter, trialConditions);
                trigger.stopRecording();
            else
                [randomSpeed, translationalDirection, rotationalDirection] = rotationStimulusDrawDots(display, parameter, trialConditions);
                trigger.stopRecording();
            end
        catch ME
            Screen('LoadNormalizedGammaTable', display.windowPointer, originalLUT);
            disp(ME.message);
            disp('Error in StimulusModule');
            return;
        end
        
        
        
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

%% Clean up
Screen('LoadNormalizedGammaTable', display.windowPointer, originalLUT);
Screen('CloseAll');
ShowCursor;
fclose(fileID);


end

function [fileID] = setupFile(parameter)
fileName = [parameter.experimentID '_' parameter.initials datestr(now, '_yyyy_mmmm_dd') '.txt'];
filePath = fullfile(pwd,'..','LogFiles',fileName);
fileID = fopen(filePath,'a');
end

function printHeader(fileID, parameter)
fprintf(fileID, ['ExperimentID: ' parameter.experimentID '\n']);
fprintf(fileID, ['SubjectID: ' parameter.subjectID '\n']);
fprintf(fileID, ['Experiment: ' parameter.experiment '\n']);
fprintf(fileID, datestr(now, 'yyyy_mmmm_dd_HH:MM:SS.FFF\n'));
fprintf(fileID, '%s %s %s %s %s %s %s %s %s %s %s %s %s \n',...
    'block', 'trial', 'translationalDirection', 'rotationalDirection',...
    'randomSpeed', 'decision',...
    'circleDiameter', 'horizontalSpeed',...
    'rotationalSpeed', 'duration',...
    'multiplier', 'dotsDiameter', 'dotsNumber' );
end

function printTrialData(fileID, block, trial, translationalDirection,...
    rotationalDirection, randomSpeed, decision, parameter)
fprintf(fileID, '%d %d %d %d %0.0f %d %0.1f %0.1f %d %d %0.2f %0.2f %d \n',...
    block, trial, translationalDirection, rotationalDirection,...
    randomSpeed, decision,...
    parameter.circleDiameter, parameter.horizontalSpeed,...
    parameter.rotationalSpeed, parameter.duration,...
    parameter.multiplier, parameter.dotsDiameter,...
    parameter.dotsNumber);
disp('Trial data printed.');
end

% function  [conditionSampler] = cutOutBaselineTrials(conditionSampler, possibleConditions)
% indices = conditionSampler > prod(possibleConditions)-2;
% conditionSampler(indices) = [];
% end





