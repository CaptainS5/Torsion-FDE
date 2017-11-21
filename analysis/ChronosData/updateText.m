function [] = updateText(trial, torsion, logData, fig)

screenSize = get(0,'ScreenSize');

xPosition = screenSize(3)*2/3;
yPosition = screenSize(4)*2/5;
verticalDistance = 20;
width = 500;
height = 20;
textblock = 0;

fileNameText = uicontrol(fig,'Style','text',...
    'String', ['File: ' logData.fileName],...
    'Position',[xPosition yPosition width height],...
    'HorizontalAlignment','left'); %#ok<*NASGU>

textblock = textblock+1;
blockText = uicontrol(fig,'Style','text',...
    'String', ['Block: ' num2str(trial.log.block)],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

textblock = textblock+1;
trialText = uicontrol(fig,'Style','text',...
    'String', ['Trial: ' num2str(trial.number)],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

textblock = textblock+1;
pursuitGain = uicontrol(fig,'Style','text',...
    'String', ['Pursuit gain: ' num2str(pursuit.gain)],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

textblock = textblock+1;
torsionGain = uicontrol(fig,'Style','text',...
    'String', ['Torsion mean speed: ' num2str(torsion.slowPhases.meanSpeed )],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

textblock = textblock+1;
direction = uicontrol(fig,'Style','text',...
    'String', ['Torsion quality: ' sprintf('%0.2f', torsion.slowPhases.quality)],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

textblock = textblock+1;
rotationDirection = uicontrol(fig,'Style','text',...
    'String', ['Rotational direction: ' num2str(trial.log.rotationalDirection)],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');

textblock = textblock+1;
errorStatusTextField = uicontrol(fig,'Style','text',...
    'String', ['SlowPhase angles (CW/CCW): ' sprintf('%0.2f', torsion.slowPhases.totalAngleCW)  ' / '  sprintf('%0.2f', torsion.slowPhases.totalAngleCCW)],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');
% 
% 
if logData.natural(trial.number)
    natural_temp = 'natural';
else
    natural_temp = 'unnatural';
end
textblock = textblock+1;
naturalTextField = uicontrol(fig,'Style','text',...
    'String', ['Natural?: ' natural_temp],...
    'Position',[xPosition yPosition-textblock*verticalDistance width height],...
    'HorizontalAlignment','left');
% 
% textblock = textblock+1;
% rotationSpeed = uicontrol(fig,'Style','text',...
%     'String', ['Rotational Speed (�/s): ' num2str(rotationSpeed)],...
%     'Position',[xPosition yPosition-textblock*verticalDistance width height],...
%     'HorizontalAlignment','left');
% 
% textblock = textblock+1;
% decision = uicontrol(fig,'Style','text',...
%     'String', ['Decision: ' logData.decision{currentTrial}],...
%     'Position',[xPosition yPosition-textblock*verticalDistance width height],...
%     'HorizontalAlignment','left');
% 
% 
% slowPhasesString = [];
% slowPhaseOnsetsString = [];
% slowPhaseOffsetsString = [];
% 
% for i = 1:length(torsion.slowPhaseAllAngles)
%     
%     if ~isnan(torsion.slowPhaseAllAngles(i))  
%         slowPhasesString = [slowPhasesString num2str(torsion.slowPhaseAllAngles(i)) '  '];
%         slowPhaseOnsetsString = [slowPhaseOnsetsString num2str((slowPhaseOnsets(i)-trial.stim_onset)*5) '  '];
%         slowPhaseOffsetsString = [slowPhaseOffsetsString num2str((slowPhaseOffsets(i)-trial.stim_onset)*5) '  '];
%     end
% end
% 
% textblock = textblock+1;
% slowPhasesTextField = uicontrol(fig,'Style','text',...
%     'String', ['SlowPhases: ' slowPhasesString],...
%     'Position',[xPosition yPosition-textblock*verticalDistance width height],...
%     'HorizontalAlignment','left');
% 
% textblock = textblock+1;
% onsetsTextField = uicontrol(fig,'Style','text',...
%     'String', ['SlowPhasesOnsets (in ms): ' slowPhaseOnsetsString],...
%     'Position',[xPosition yPosition-textblock*verticalDistance width height],...
%     'HorizontalAlignment','left');
% 
% textblock = textblock+1;
% offsetsTextField = uicontrol(fig,'Style','text',...
%     'String', ['SlowPhasesOffsets (in ms): ' slowPhaseOffsetsString],...
%     'Position',[xPosition yPosition-textblock*verticalDistance width height],...
%     'HorizontalAlignment','left');

end

