function info = getInfo
% using GUI to gather sub information/manipulate parameters

global info

info.dateTime = clock;

% questions and defaults
n = 1;
q{n} = 'subID'; defaults{n} = 'NI'; n = n+1;
q{n} = 'Eyetracker(1) or not(0)'; defaults{n} = '0'; n = n+1;
q{n} = 'ReportStyle(lower: -1; higher: 1)'; defaults{n} = '1'; n = n+1; %L-lower; H-higher
q{n} = 'From block'; defaults{n} = '6'; n = n+1;
q{n} = 'To block'; defaults{n} = '10'; n = n+1;
q{n} = 'Experiment type(0=base, 1=exp)'; defaults{n} = '1'; n = n+1;

answer = inputdlg(q, 'Experiment basic information', 1, defaults);

% return value
n = 1;
info.subID = answer(n); n = n+1;
info.eyeTracker = str2num(answer{n}); n = n+1;
info.reportStyle = str2num(answer{n}); n = n+1;
info.fromBlock = str2num(answer{n}); n = n+1;
info.toBlock = str2num(answer{n}); n = n+1;
info.expType = str2num(answer{n}); n = n+1;

info.fileNameTime = [info.subID{1}, '_', sprintf('%d-%d-%d_%d%d', info.dateTime(1:5))];

% save(['Info_', info.fileNameTime], 'info')

end
