function checkZoo

% CHECKZOO should be used before pushing new updates to the repositories



% 1 - check machine learning module
ml_processing_template_IMU_simple
ml_processing_template_IMU
ml_processing_template_mocap

% 2 - run all examples test
all_examples_test

% 3 - run sample study
samplestudy_process







