function fixedSegments = fixStriatalSegments_v2(mask_CA, mask_PU, pre_CA, post_CA, pre_PU, post_PU)
% Author: Yash Patel, MS
% CNAP-LAB, PI: Jared Van Snellenberg, PhD
% Stony Brook University
    
    pairs = {
        {'pre_CA_CA', pre_CA, mask_CA},
        {'post_CA_CA', post_CA, mask_CA},
        {'pre_PU_PU', pre_PU, mask_PU},
        {'post_PU_PU', post_PU, mask_PU},
        {'pre_CA_PU', pre_CA, mask_PU},
        {'post_CA_PU', post_CA, mask_PU},
        {'pre_PU_CA', pre_PU, mask_CA},
        {'post_PU_CA', post_PU, mask_CA}
    };
    
    results = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    for i = 1:length(pairs)
        pair = pairs{i};
        outputName = pair{1}; 
        Y1 = pair{2};
        Y2 = pair{3};
        
        resultMatrix = Y1 .* Y2;
        
        results(outputName) = resultMatrix;
    end
    
    combinations = {
        {'fixed_preCA', {'pre_CA_CA', 'pre_PU_CA'}},
        {'fixed_postCA', {'post_CA_CA', 'post_PU_CA'}},
        {'fixed_prePU', {'pre_PU_PU', 'pre_CA_PU'}},
        {'fixed_postPU', {'post_PU_PU', 'post_CA_PU'}}
    };
    
    fixedSegments = struct(); % Initialize the structure to store fixed segment matrices
    
    for i = 1:size(combinations, 1)
        comboName = combinations{i}{1};
        parts = combinations{i}{2};
        
        combinedResult = results(parts{1}) | results(parts{2});
        
        combinedResult = logical(combinedResult);
        
        fixedSegments.(comboName) = combinedResult;
    end
    
end
