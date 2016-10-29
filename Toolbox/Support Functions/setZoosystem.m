function zoosystem = setZoosystem(fl)

% zoosystem = SETZOOSYSTEM(fl) creates 'zoosystem' branch for data
% being imported to biomechZoo
%
% ARGUMENTS
%  data      ... Zoo data
%  r         ... Parameters (struct)
%
% RETURNS
%  data      ... Zoo data with appropriate parameters loaded


% Set defaults
%
ver = '1.3';                                                                
zch = {'Analog','Anthro','AVR','CompInfo','SourceFile','Units','Version','Video'};


% Set up struc
%
zoosystem = struct;
for i = 1:length(zch)
    zoosystem.(zch{i}) = struct;
end

section = {'Video','Analog'};

for i = 1:length(section)
    zoosystem.(section{i}).Channels = {};
    zoosystem.(section{i}).Freq = [];
    zoosystem.(section{i}).Indx = [];
    zoosystem.(section{i}).ORIGINAL_START_FRAME = [];
    zoosystem.(section{i}).ORIGINAL_END_FRAME   = [];
    zoosystem.(section{i}).CURRENT_START_FRAME  = [];
    zoosystem.(section{i}).CURRENT_END_FRAME    = []; 
end

zoosystem.Version = ver;
zoosystem.SourceFile = char(fl);
 

% 
