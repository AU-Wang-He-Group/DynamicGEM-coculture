# DynamicGEM-coculture
What you need to have/do in order to run the codes:
- MATLAB 2018 or newer version
- Install the COBRA Toolbox on MATLAB
- 'glpk' solver for linear equations
- Try/follow the tutorial of the COBRA Toolbox at the following pathway, to make sure Genome scale metabolic (GEM) model run without any error: 
 . . . \cobratoolbox\tutorials\analysis\microbeMicrobeInteractions


# 1. Folder structure:
- __Codes:__ Including Matlab cods named as dynamicGEM __first__ and __second__ which are identification for two scripts
- __Model:__ Including curated/modified reconstruction for photoautotroph (_A. platensis_) and methanotroph (_M. buryatense_)
- __Data:__ Including Matlab data (Microsoft Access Table Shortcut) from first script as a prerequisite for running the second script

# 2. Workflow

- The main workflow is composed by two scripts that need to be run in sequence:

   1) __DynamicGEMfirst__ - this is available for 4 different conditions: 1-DynamicGEMfirstGasComposition, 2-DynamicGEMfirstInoculumRatio, 3-DynamicGEMfirstLightIntensity, 4-DynamicGEMfirstCocultureVsSingle, that are kinetic modeling of the coculture system at different conditions and will generate the predicited individual biomass, consumption production rates and also the time points that we want to see the behaviour of the system in molecular level as a dynamic model;
   - More information and details about first script can be found here: 
`https://github.com/AU-Wang-He-Group/Semi-structured-KineticModel.git`;
   
   2) __DynamicGEMsecondMicrobeMicrobe__ - this script will gather model projections 
   from DynamicGEMfirst (from step 1) including: dataforGEM 1 & 2, calculate the constraints for the coculture GEM model and predict the total growth rate and metabolic interactions.
   
   # Runing the model step by step:
