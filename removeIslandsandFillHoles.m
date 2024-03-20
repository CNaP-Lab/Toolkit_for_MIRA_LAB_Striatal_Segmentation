function Y = removeIslandsandFillHoles(filename_n, mode)
% Author: Yash Patel, MS
% CNAP-LAB, PI: Jared Van Snellenberg, PhD
% Stony Brook University

    [intermediateOutFilePath, ~,~] = fileparts(filename_n);
    % Define the directory path named Intermediates within intermediateOutFilePath
    intermediateDirPath = fullfile(intermediateOutFilePath, 'Intermediates');

    % Check if the 'Intermediates' directory exists, if not, create it
    if ~exist(intermediateDirPath, 'dir')
        mkdir(intermediateDirPath);
    end

    [V,Y,XYZ] = tippVol(filename_n);

    switch mode
        case 'VST'
            targetValue = 5;
            nameModifier = 'VST';
        case 'prePU'
            targetValue = 1;
            nameModifier = 'prePU';
        case 'preCA'
            targetValue = 2;
            nameModifier = 'preCA';
        case 'postCA'
            targetValue = 3;
            nameModifier = 'postCA';
        case 'postPU'
            targetValue = 4;
            nameModifier = 'postPU';
        otherwise
            disp('Error: ROI not recognized.');
            return;
    end

    Y_copy = Y;
    Y_copy(Y~=targetValue) = 0; 

    %right ROI
    Y_copy(XYZ(1,:)<0)=0;
    outputRight = fullfile(intermediateDirPath, ['intermediate_', nameModifier, '_right.nii']);
    tippWriteVol(V, Y_copy, outputRight);

    %left ROI
    Y_copy = Y;
    Y_copy(Y~=targetValue) = 0; 
    Y_copy(XYZ(1,:)>0)=0;
    outputLeft = fullfile(intermediateDirPath, ['intermediate_', nameModifier, '_left.nii']);
    tippWriteVol(V, Y_copy, outputLeft);

    outputRight_islanded = fullfile(intermediateDirPath, ['intermediate_', nameModifier, '_right_islanded.nii']);
    outputLeft_islanded = fullfile(intermediateDirPath, ['intermediate_', nameModifier, '_left_islanded.nii']);

    commandStrRight = sprintf('wb_command -volume-remove-islands %s %s', outputRight, outputRight_islanded);
    commandStrLeft = sprintf('wb_command -volume-remove-islands %s %s', outputLeft, outputLeft_islanded);

    [statusR, cmdoutR] = system(commandStrRight);
    if statusR == 0
        disp('wb_command executed successfully for removing islands.');
    else
        disp('Error executing wb_command for removing islands.');
        disp(cmdoutR);
    end

    [statusL, cmdoutL] = system(commandStrLeft);
    if statusL == 0
        disp('wb_command executed successfully for removing islands.');
    else
        disp('Error executing wb_command for removing islands.');
        disp(cmdoutL);
    end
    outputRight_islanded_nohole = fullfile(intermediateDirPath, ['intermediate_', nameModifier, '_right_islanded_noholes.nii']);
    outputLeft_islanded_nohole = fullfile(intermediateDirPath, ['intermediate_', nameModifier, '_left_islanded_noholes.nii']);

    commandStrRight = sprintf('wb_command -volume-fill-holes %s %s', outputRight_islanded, outputRight_islanded_nohole);
    commandStrLeft = sprintf('wb_command -volume-fill-holes %s %s', outputLeft_islanded, outputLeft_islanded_nohole);

    [statusR, cmdoutR] = system(commandStrRight);
    if statusR == 0
        disp('wb_command executed successfully for removing holes.');
    else
        disp('Error executing wb_command for removing holes.');
        disp(cmdoutR);
    end

    [statusL, cmdoutL] = system(commandStrLeft);
    if statusL == 0
        disp('wb_command executed successfully for removing holes.');
    else
        disp('Error executing wb_command for removing holes.');
        disp(cmdoutL);
    end

    [~, Y_rightIslanded] = tippVol(outputRight_islanded_nohole);
    [~, Y_leftIslanded] = tippVol(outputLeft_islanded_nohole);

    Y = Y_leftIslanded | Y_rightIslanded;
    
    Y = logical(Y);
    

    outfile = fullfile(intermediateDirPath, [nameModifier '.nii']);
    tippWriteVol(V, Y, outfile);

end
