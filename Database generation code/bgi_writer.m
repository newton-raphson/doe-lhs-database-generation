clear all
close all
clc

% This program opens batchinput file from preliminary design and extract
% necessary data. str contains the whole content of the bgi file in form of
% cell array. idx contains the coordinates available in given bgi file

filename = ['BG','.bgi'];
str=[];
fid=fopen(filename);
if fid == -1
    error('Cannot open file: %s', filename);
end

l=fgetl(fid);
while ischar(l)
  str{end+1,1}=l;
  l=fgetl(fid);
end
fclose(fid);
str;
idx=str(cellfun(@numel,regexp(str,'[\d\.]+'))==2);
idx = regexp(idx,'\d?\d?\d?\.?\d+','match');


% The value of n refers to the number of control points for meridional
% profile curves
n = 32;

for i = 1: n
    z{i} = (str2double(idx{i}{1}));
    r{i} = (str2double(idx{i}{2}));
end

% To change cell array into matrix
z_orig = cell2mat(z);
r_orig = cell2mat(r);

% The parameters for the beta angles are extracted from the BETA_PARA.xlsx
% into an array beta_parameters. The last one i.e. p_t(1,8) is a constant
% and is excluded in creation of lhs
beta_parameters = [-0.003586979	-1.052155552	-2.820303047	26.23465634	-16.08928896	21.9500396
];
bp_orig = [-0.003635542	-1.051897244	-2.820292665	26.23437524	-16.089271];

% the 5 beta parameters is appended with the original z coordinates and for
% creating an array of zr 5 NaN are added at the end of the z array
r = [r_orig bp_orig];
z = [z_orig NaN(1, 5)];

exp_s=150; %number of experiments

% Preallocating the memory for database 
d_base = zeros(150,18);
%last column presents whether simulation went correctly
% or not "-1" for correct
read_dbase=readtable('new_database.xlsx','ReadVariableNames',false);
d_array=table2array(read_dbase);
[pos n]=size(d_array);
simulation_pos=pos+1;
terminate = input(sprintf('\nGive the position of simulation you want to perform greater than %d\n',pos));
d_base = d_array;

rn_lhs = readtable('lhs.csv','ReadVariableNames',false);
ser_lhs = table2array(rn_lhs); 
r_new = ser_lhs.* (ones(151,1)* r);
zr = [z_orig; r_orig];
space = [4 5 14 15 26 27 30 31]; % mer control points thats needs to be changed
for i = simulation_pos:exp_s
     zr_new = [z; r_new(i,:)];

for j= 1:32
     if ~sum(j == space)
         zr_new(2,j) = r (j);
    end
end
temp1 = zr_new;
d_base(i,1:8) = zr_new(2,[4 5 14 15 26 27 30 31]);
d_base(i,9:13) = r_new(i,33:37);

beta_angles = [];
v = [0 0.25 0.5 0.75 1];

p = [0 0.3333 0.6667 1];
for m = 1 : length(v)
        
%         The beta angle at the m(Layer) anb n(span) is calculated using
%         the equation proposed in the paper (Teran 2016)
        beta_angle = (r_new(i,33) .* (1 - p) .^ 3 + (r_new(i,34) - r_new(i,35) * v(m) ^ 2) .* ...
            (1 - p) .^ 2 +...
            (1 - p) .* (r_new(i,36) -r_new(i,37) * v(m) ^ 3) + ...
            beta_parameters(6));
         
%%%%%%%%%%%% The above formula needs to be rechecked%%%%%%%%%%%%%%%%%%%%%%
        beta_angles = [beta_angle' ; beta_angles];
end
vv = [0:100/3:100];
vv = [vv';vv';vv';vv';vv'];

% The beta_array consists the 20 rows of (%M-Prime,Beta angle)
beta_array1 = [vv beta_angles];

% Fixing the bgi data in required positions 
% 1. fixing the beta angles at the leading edge and trailing edge
unchanged_beta_pos = [1 4 5 8 9 12 13 16 17 20];
unchanged_beta = [61.70010608	28.59002102	58.99975600	24.99998207	56.19999773	21.93001690	52.89999001	18.55999375	46.29997458	15.10001621];
 for q = 1:10
     beta_array1(unchanged_beta_pos(q),2) = unchanged_beta(q);
 end
% 2. fixing the necessaary coordinates e.g. intersection of hub and te
zr_new(:,[21 3 25 7 29 23 22 13 28 17 32 24])=temp1(:,[1 2 2 6 6 10 11 12 12 16 16 20]);
beta_array1 = beta_array1';
zr_mer = zr_new(:,1:end-5);

% The design_data array consists the data that is ready to be replaced into
% createing a new design
design_data = [zr_mer beta_array1];

% Two bgi files: krishna.bgi is opened in read mode and the BATCHINPUT.bgi is 
% opened in the write mode
f_id = fopen(filename,'r');
f2_id = fopen('BATCHINPUT.bgi','wt');

% The suffix 1 and 2 refers for meridional curves points while 11 and 22
% refers to the beta angles
checkstr1 = '			Begin Data';
checkstr11 ='				Begin Data';
checkstr2 = '			End Data';
checkstr22 ='				End Data';
k = 1;
if i ~= 1
    while ~feof(f_id)
        strings = fgetl(f_id);

        % This part replaces thte meridional curves control points and writes 
        % into new BGI file (BATCHINPUT.bgi)
        if strcmp(strings, checkstr1)
            fprintf(f2_id,'			Begin Data\n');
            while strcmp(fgetl(f_id), checkstr2) == 0
                    fprintf(f2_id, '				( %f,%f )\n',design_data(1,k), design_data(2,k));
                    k = k + 1;
            end 
            fprintf(f2_id,'			End Data\n');

            % This part replaces the beta angles and writes into a new BGI file
            % If thickness needs to be included, we can simply omit the 
            % later condtition
        elseif strcmp(strings, checkstr11) & k <= 52 
            fprintf(f2_id,'				Begin Data\n');
            while strcmp(fgetl(f_id), checkstr22) == 0
                    fprintf(f2_id, '					( %f,%f )\n',design_data(1,k), design_data(2,k));
                    k = k + 1;
            end 
            fprintf(f2_id,'				End Data\n');
        else

            % This part writes into the BGI file portion as it is without any change
            fprintf(f2_id, '%s\n', strings);
        end
    end
elseif i == 1
    copyfile('BG.bgi', 'BATCHINPUT.bgi')
end
fclose(f_id);
fclose(f2_id);
fprintf('\n Running %d sample simulation\n\n',i)
hold off
% To determine error is two consecutive simulation results are the same
% This needs to be changed for every start
% Last database column needs  to be placed in a b c and d
 a = 73.831;
 b = 5667850;
 c = 6037;
 d = 0.06646;
[H, P, Et, Cc, error]=code(i);
 
d_base(i,14:19)= [H P Et Cc error,i];

% Accessing the data of recent last column of d_base
    H_1 = d_base(i-1,14);
    P_1 = d_base(i-1,15);
    ET_1 = d_base(i-1,16);
    last_values = [H_1 P_1 ET_1];
    recent_values = [H P Et];
    if sum(last_values == recent_values) > 1
        error = 5;
    end
if (error == -1) || (i == 1)
    xlswrite('new_database.xlsx',d_base);
    mkdir('ANSYS FILES',sprintf('InitData-%d SIMFILES',i));
    folder1 = sprintf('F:\\PulchowkCampus\\4thyear\\FYP\\BATCHFILE FOR KL3r\\BATCH_files\\ANSYS FILES\\InitData-%d SIMFILES',i);
    if isfile('BATCH_SOLVERINPUT_002.out')
        copyfile('BATCH_SOLVERINPUT_002.out',folder1);
    end
    if isfile('BATCH_SOLVERINPUT_002.res')
        copyfile('BATCH_SOLVERINPUT_002.res',folder1);
    end
    copyfile('turbomesh.gtm',folder1);
    copyfile('HydraulicTurbineReport',folder1);
    copyfile('HydraulicTurbineReport.txt',folder1);
    copyfile('PerformanceTable.csv',folder1);
    copyfile('curves',folder1); bladeplot(i,zr_mer,zr)
    beta_plot(i,beta_array1);
end
fprintf('\nNext sample..\n\n');
end
close all;
 
