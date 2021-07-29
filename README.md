# DynamicGEM-coculture

![image](https://user-images.githubusercontent.com/67964457/127546060-4ec09198-05ea-4814-8199-1ef48e3204c7.png)


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

![image](https://user-images.githubusercontent.com/67964457/127546356-b6794520-b37c-44d7-8237-88afad6d02e8.png)


- The main workflow is composed by two scripts that need to be run in sequence:

   1) __DynamicGEMfirst__ - this is available for 4 different conditions: 1-DynamicGEMfirstGasComposition, 2-DynamicGEMfirstInoculumRatio, 3-DynamicGEMfirstLightIntensity, 4-DynamicGEMfirstCocultureVsSingle, that are __kinetic modeling__ of the coculture system at different conditions and will generate the predicited individual biomass, consumption production rates and also the time points that we want to see the behaviour of the system in molecular level as a dynamic model;
   - More information and details about first script can be found here: 
`https://github.com/AU-Wang-He-Group/Semi-structured-KineticModel.git`;
   
   2) __DynamicGEMsecondMicrobeMicrobe__ - this script will gather model projections 
   from DynamicGEMfirst (from step 1) including: dataforGEM 1 & 2, calculate the constraints for the coculture GEM model and predict the total growth rate and metabolic interactions.
   
   # Runing the model step by step:
- The full description for running the first script (DynamicGEMfirst=kinetic model) is avalaible at `https://github.com/AU-Wang-He-Group/Semi-structured-KineticModel.git`. The only difference is "Dynamic GEM preparation" section in the code, that user needs to enter the desired 'time points' for the GEM modeling.

![info-icon](https://img.icons8.com/flat_round/48/000000/info.png)
__NOTE__: There is a default time points in the code and a plot will be generated to show you dynamic of the system at the time points. If you wish to change or use different time points, simply change __'timeGEM'__ parameter.
