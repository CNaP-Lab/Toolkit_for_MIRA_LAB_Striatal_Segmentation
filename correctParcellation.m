function correctParcellation(filename_n, caudateMaskFile, putamenMaskFile)
% Author: Yash Patel, MS
% CNAP-LAB, PI: Jared Van Snellenberg, PhD
% Stony Brook University
    [V_ROIs, Y_ROIs] = tippVol(filename_n);
    [~, Y_caudateMask] = tippVol(caudateMaskFile);
    [~, Y_putamenMask] = tippVol(putamenMaskFile);
    Y_preCA = Y_ROIs;
    Y_preCA(Y_ROIs~=2) = 0;
    Y_postCA = Y_ROIs;
    Y_postCA(Y_ROIs~=3) = 0;
    Y_prePU = Y_ROIs;
    Y_prePU(Y_ROIs~=1) = 0;
    Y_postPU = Y_ROIs;
    Y_postPU(Y_ROIs~=4) = 0;
    Y_VST = Y_ROIs;
    Y_VST(Y_ROIs~=5) = 0;
    Y_VST = logical(Y_VST);
    logicalMask_CA = logical(Y_caudateMask);
    logicalMask_PU = logical(Y_putamenMask);

    [parcellationFilePath,~,~] = fileparts(filename_n);
    
    %correct the ROIs based on the mask
    fixedSegments = fixStriatalSegments_v2(logicalMask_CA, logicalMask_PU, Y_preCA, Y_postCA, Y_prePU, Y_postPU);
    fixed_preCA_undilated = fixedSegments.fixed_preCA;
    fixed_postCA_undilated = fixedSegments.fixed_postCA;
    fixed_prePU_undilated = fixedSegments.fixed_prePU;
    fixed_postPU_undilated = fixedSegments.fixed_postPU;

    % Assign and combine the fixed ROIs based on the mask
    Y_ROIs(:) = 0;
    Y_ROIs(fixed_preCA_undilated) = 2;
    Y_ROIs(fixed_postCA_undilated) = 3;
    Y_ROIs(fixed_prePU_undilated) = 1;
    Y_ROIs(fixed_postPU_undilated) = 4;
    Y_ROIs(Y_VST) = 5;

    %temp write out for the next command
    intermediateParcellationPath = fullfile(parcellationFilePath, 'intermediateparcellation.nii');
    tippWriteVol(V_ROIs, Y_ROIs, intermediateParcellationPath);

    %remove islands and fill holes
    fixed_preCA_undilated = removeIslandsandFillHoles(intermediateParcellationPath, 'preCA');
    fixed_prePU_undilated = removeIslandsandFillHoles(intermediateParcellationPath, 'prePU');
    Y_VST = removeIslandsandFillHoles(intermediateParcellationPath, 'VST');
    fixed_postCA_undilated = removeIslandsandFillHoles(intermediateParcellationPath, 'postCA');
    fixed_postPU_undilated = removeIslandsandFillHoles(intermediateParcellationPath, 'postPU');


    %feed the corrected ROIs to dilate and fill
    [Y_preCA, Y_postCA, Y_VST_CA] = dilate2fillrois(fixed_preCA_undilated, fixed_postCA_undilated, Y_VST, logicalMask_CA, 'CA');
    [Y_prePU, Y_postPU, Y_VST_PU] = dilate2fillrois(fixed_prePU_undilated, fixed_postPU_undilated, Y_VST, logicalMask_PU, 'PU');
    Y_VST = Y_VST_CA | Y_VST_PU | Y_VST;

    Y_ROIs(:) = 0;
    Y_ROIs(Y_preCA) = 2;
    Y_ROIs(Y_postCA) = 3;
    Y_ROIs(Y_prePU) = 1;
    Y_ROIs(Y_postPU) = 4;
    Y_ROIs(Y_VST) = 5;


    tippWriteVol(V_ROIs, Y_ROIs, filename_n);

end
