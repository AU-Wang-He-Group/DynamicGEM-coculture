%% Dynamic GEM modeling
clearvars;

%Input data

load('dataforGEM1.mat');%timeGEM 
load('dataforGEM2.mat');%DataGEM
%DataGEM includes: [time, photautotroph biomass, methanotroph biomass,vMch4,vMco2,vMo2,vPco2,vPo2]
%timeGEM includes the time points for GEM modeling:(hours)

%Finding actual time steps in the semi-structured model based on timeGEM:
for i=1:length(timeGEM)
if timeGEM(i)<=DataGEM(end,1)
    GEM(i)= find (round(DataGEM(:,1),3)==timeGEM(i));
end
end

%Convert the fluxes to constraint for coculture GEM modeling:
vcoch4 = -(DataGEM(GEM,4).*(DataGEM(GEM,3)./(DataGEM(GEM,3)+DataGEM(GEM,2))));
vcoo2 = DataGEM(GEM,8).*(DataGEM(GEM,2)./(DataGEM(GEM,3)+DataGEM(GEM,2)));
vcoco2 = -(DataGEM(GEM,7).*(DataGEM(GEM,2)./(DataGEM(GEM,3)+DataGEM(GEM,2))));
vcoco2M = DataGEM(GEM,5).*(DataGEM(GEM,3)./(DataGEM(GEM,3)+DataGEM(GEM,2)));
ratioco = DataGEM(GEM,2)./DataGEM(GEM,3);

%Computation and analysis of microbe-microbe metabolic interactions
%% Prepare the models

changeCobraSolver('glpk', 'LP');
M1 = readCbModel(['C:\Users\kzb0054\Box\ENG_WANG_GROUP\Group Reports 2021\Weekly Reports\Kiumars\DynamicGEM\Codes-dyGEM\5GB1_modifiedv4new3.mat']); %methanotroph
F2 = readCbModel(['C:\Users\kzb0054\Box\ENG_WANG_GROUP\Group Reports 2021\Weekly Reports\Kiumars\DynamicGEM\Codes-dyGEM\Platensis_ReducednewV3.mat']); %cyanobacteria

% Import a file with information
[~,infoFile,~]=xlsread('C:\Users\kzb0054\Box\ENG_WANG_GROUP\Group Reports 2021\Weekly Reports\Kiumars\DynamicGEM\Codes-dyGEM\Coculture_infoFile.xlsx');
% Creation of pairwise models
modelList=infoFile(2:end,1); 
M1=createEmptyFields(M1, 'metKEGGID');
M1=createEmptyFields(M1, 'metChEBIID');
F2=createEmptyFields(F2, 'metKEGGID');
F2=createEmptyFields(F2, 'metChEBIID');

% Polish the model a little bit:

% Modification for methanotroph(5GB1)
GAM1=23; %Growth associate maintanence
M1.S(123,444)=-GAM1;% This changes ATP[c] main in biomass
M1.S(254,444)=-GAM1;% This changes H2O[c] main in biomass
M1.S(371,444)= GAM1;% This changes Pi[c] main in biomass
M1.S(88,444)= GAM1; %This changes ADP[c] main in biomass
M1.S(259,444)= GAM1;% This changes proton[c] main in biomass
M1.S(88,40)=-6; % This is ADP
M1.S(371,40)=-6; %This is Pi
M1.S(123,40)=6; %This is ATP 
M1=changeRxnBounds(M1,'EX_cob12(e)',-1000,'l');%cob-12
% M1=changeRxnBounds(M1,'Pabc',10.93,'b');%NGAM 15.53 and 10.93
 
% Modification for photoaourtotroph (platensis)

F2 = changeRxnBounds(F2,'AP275',0,'b');%knock out the reaction
F2 = changeRxnBounds(F2,'AP062',0,'l');%make the reaction irreversible
F2 = changeRxnBounds(F2,'AP282',-1000,'l');%make the reaction reversible
F2 = changeRxnBounds(F2,'AP556',0,'u');%make the reaction irreversible
F2 = changeRxnBounds(F2,'AP558',0,'l');%make the reaction irreversible
F2 = changeRxnBounds(F2,'AP089',0,'l');%make the reaction irreversible
% Modification from Toyoshima (2020)
F2 = changeRxnBounds(F2,{'AP289'},0,'b'); % plastidic PFKh inactivated by light (Plaxton 1996)
F2 = changeRxnBounds(F2,{'AP076'},0,'b'); % light inhibits G6PDHh of oxidative pentose phosphate pathway (Plaxton 1996)
F2 = changeRxnBounds(F2,{'AP086'},0,'b'); % light inactivates FBAh (Lemaire 2004; Matsumoto 2008)
% F2 = changeRxnBounds(F2,{'AP486'},0,'u'); % This reaction is irreversible reaction (KEGG)
% F2 = changeRxnBounds(F2,{'AP511'},0.50,'b');%ATPM 
F2 = changeRxnBounds(F2,{'AP549'},0,'b'); % This reaction is not present (KEGG)
F2 = changeRxnBounds(F2,{'AP546'},0,'b'); % This reaction is not present (KEGG)
F2 = changeRxnBounds(F2,{'AP550'},0,'b'); % This reaction is not present (KEGG)
F2 = changeRxnBounds(F2,{'AP547'},0,'b'); % This reaction is not present (KEGG)
F2 = changeRxnBounds(F2,{'AP343'},0,'b'); % This reaction is not present (KEGG)
% F2 = changeRxnBounds(F2,{'AP003'},0,'b'); % This reaction is not present (KEGG)
F2 = changeRxnBounds(F2,{'AP281'},0,'b'); % This reaction is not present (KEGG)
F2 = changeRxnBounds(F2,{'AP005'},0,'u'); % This reaction is irreversible reaction (Muro-Pastor 2005)
F2 = changeRxnBounds(F2,'EX_AP758',0,'b');%Glucose % photoautotrophic condition
% model = changeRxnBounds(model,'EX_AP770',-0.6,'b');%Nitrate
F2 = changeRxnBounds(F2,'EX_AP769',0,'b');%NH4 no ammonia in medium
F2 = changeRxnBounds(F2,'EX_AP771',0,'l');%Oxygen
F2 = changeRxnBounds(F2,'EX_AP763',0,'b');%Bicarbonate
F2.S(129,1)=-39.21;% This changes ATP[c] main in biomass
F2.S(393,1)= 39.21;% This changes Pi[c] main in biomass
F2.S(99,1)= 39.21; %This changes ADP[c] main in biomass
F2.S(258,1)= 39.21;% This changes h[c] main in biomass
F2.S(258,289)= 1;% Chnage the h[c] coeficient in photosysnthesis reaction AP422
F2.S(261,289)= 0;% Chnage the h[t] coeficient in photosysnthesis reaction AP422
% make all empty cells in cell arrays to be empty string
fieldToBeCellStr = {'metFormulas'; 'genes'; 'grRules'; 'metNames'; 'rxnNames'; 'subSystems'; 'metKEGGID'; 'metChEBIID'};
for j = 1:numel(fieldToBeCellStr)
    M1.(fieldToBeCellStr{j})(cellfun(@isempty, M1.(fieldToBeCellStr{j}))) = {''};
    F2.(fieldToBeCellStr{j})(cellfun(@isempty, F2.(fieldToBeCellStr{j}))) = {''};
end

inputModels{1,1}=M1;
inputModels{2,1}=F2;

% Let us define some parameters for joining the models.
% Set the coupling factor c, which defined how the flux through all reactions in a model is coupled 
% to the flux through its biomass reaction. Allowed flux span through each reaction= 
% -(c * flux(biomass)) to +(c * flux(biomass)).
c = 400;
% Set the threshold u, which defines the flux through each reaction that 
% is allowed if flux through the biomass reaction is zero.
u = 0;
% Define whether or not genes from the models are merged and kept in the 
% joined models. If set to true the joining is more time-consuming.
mergeGenes = false;
% Define the number workers for parallel pool to allow parallel computing.Recommended 
% if a large number of microbe models is computed. Set to zero if parallel computing 
% is not available.
numWorkers = 0;

% Join the models in all possible combinations (coculture: one possible combination)
[pairedModels,pairedModelInfo]=joinModelsPairwiseFromList(modelList,inputModels,'c',c,'u',u,'mergeGenesFlag',mergeGenes,'numWorkers',numWorkers);
%% Computation of pairwise interactions

% Name the condition that will be simulated. "it is just a name"
conditions = {'WesternDiet_NoOxygen'};

% DynamicGEM for each time points:

for b=1:length(timeGEM)
    % preparing constraints for modeling:
    sch4=num2str(vcoch4(b)); %methane consumption by methanotroph
    sco2=num2str(vcoco2(b)); %carbon dioxide consumption by photoautotroph
    so2=num2str(vcoo2(b)); %oxygen consumption by methanotroph
    sco2M=num2str(vcoco2M(b)); %carbon dioxide prodcution by methanotroph
    
    % Define the corresponding constraints.Constraints for all metabolites in the community and extera cellular compartments of the coculture:
    % exchange reaction abbreviations correspond to the lumen exchanges in the joint models ('EX_compound[u]').
    
    dietConstraints{1}={'EX_ac[u]','0','1000';'EX_agdpcbi[u]','-1000','1000';'EX_agmdadpudcp[u]','0','1000';'EX_ahcys[u]','0','1000';'EX_akg[u]','0','1000';'EX_ala-L[u]','0','1000';'EX_arab-D[u]','0','1000';'EX_arg-L[u]','0','1000';'EX_asn-L[u]','0','1000';'EX_asp-L[u]','0','1000';'EX_btn[u]','0','1000';'EX_ca2[u]','-1000','1000';'EX_cit[u]','0','1000';'EX_cob12[u]','-1000','1000';'EX_cu2[u]','-1000','1000';'EX_cys-L[u]','0','1000';'EX_datp[u]','0','1000';'EX_dgtp[u]','0','1000';'EX_dial[u]','0','1000';'EX_dttp[u]','0','1000';'EX_ectoine[u]','0','1000';'EX_etoh[u]','0','1000';'EX_fad[u]','0','1000';'EX_fe[u]','-1000','1000';'EX_for[u]','0','1000';'EX_fum[u]','0','1000';'EX_gal_bD[u]','0','1000';'EX_gam[u]','0','1000';'EX_glc-D[u]','0','1000';'EX_glc_a[u]','0','1000';'EX_gln-L[u]','0','1000';'EX_glu-L[u]','0','1000';'EX_glycogen[u]','0','1000';'EX_gthrd[u]','0','1000';'EX_h2o[u]','-1000','1000';'EX_h[u]','-1000','1000';'EX_hco3[u]','0','1000';'EX_his-L[u]','0','1000';'EX_ile-L[u]','0','1000';'EX_lac[u]','0','1000';'EX_lanost[u]','0','1000';'EX_leu-L[u]','0','1000';'EX_lipa[u]','0','1000';'EX_lys-L[u]','0','1000';'EX_mal-L[u]','0','1000';'EX_malt[u]','0','1000';'EX_malttri[u]','0','1000';'EX_met-L[u]','0','1000';'EX_mg2[u]','-1000','1000';'EX_n2[u]','-1000','1000';'EX_nh4[u]','0','1000';'EX_no3[u]','-1000','1000';'EX_o2[u]','0','0';'EX_oaa[u]','0','1000';'EX_ocdca[u]','0','1000';'EX_pe160[u]','0','1000';'EX_pg[u]','0','1000';'EX_phe-L[u]','0','1000';'EX_pheme[u]','0','1000';'EX_pi[u]','-1000','1000';'EX_pppi[u]','0','1000';'EX_pro-L[u]','0','1000';'EX_pyr[u]','0','1000';'EX_rib-D[u]','0','1000';'EX_ser-L[u]','0','1000';'EX_so4[u]','-1000','1000';'EX_succ[u]','0','1000';'EX_succoa[u]','0','1000';'EX_sucr[u]','0','1000';'EX_thr-L[u]','0','1000';'EX_trp-L[u]','0','1000';'EX_ttdca[u]','0','1000';'EX_tyr-L[u]','0','1000';'EX_urea[u]','0','1000';'EX_val-L[u]','0','1000';
        'EX_ch4[u]',sch4,'1000'; %constraint for methane consumption
        'EX_co2[u]','-0.270','1000';
        'F2_IEX_co2[u]tr',sco2,sco2; %constraint for carbon dioxide consumption
        %     'F2_IEX_o2[u]tr',so2,so2;
        'EX_photon[u]','-6.7','1000'; %constraint for photon consumption
        'M1_IEX_co2[u]tr','0','1000'; %methanotroph cannot consume CO2
        'M1_IEX_n2[u]tr','-1000','0'; %methanotroph can consume N2 if it needed
        'M1_IEX_akg[u]tr','0','0';    %blocked exchange of akg
        'M1_IEX_fum[u]tr','0','0';    %blocked exchange of fumarate
        'M1_IEX_oaa[u]tr','0','0';    %blocked exchange of oxaloacetate
        %     'M1_IEX_lac[u]tr','0','0';  %lactate
        %     'M1_IEX_asp-L[u]tr','0','0';  %aminoacids
        %     'M1_IEX_asn-L[u]tr','0','0';  %aminoacids
        
     %three major metabolites for exchange (scenarios): 1- just malate. 2-
     %malate+pyruvate. 3- pyruvate. 4- succinate+pyruvate. 
        %     'M1_IEX_succ[u]tr','0','0';   %
        %     'M1_IEX_pyr[u]tr','0','0';
        'M1_IEX_mal-L[u]tr','0','0';};
    
    % Simulate the pairwise interactions.
    % Define what counts as significant difference between single growth of the 
% microbes and growth when joined with another microbe-here we choose 10%.
    sigD = 0.1;
    i=1;
    
    % assign  constraints
    [pairwiseInteractions, pairwiseSolutions]=simulatePairwiseInteractions(pairedModels,pairedModelInfo,'inputDiet',dietConstraints{i},'sigD',sigD,'saveSolutionsFlag', true,'numWorkers', numWorkers);
    Interactions.(conditions{i})=pairwiseInteractions;
    InteractionsSolution.(conditions{i})=pairwiseSolutions;
    XXInteraction{b}=Interactions.(conditions{i})
    XXInteractionsSolution{b} = InteractionsSolution.(conditions{i})
    
end
% Final flux prediction  
Growth{1,1} = ('GEM growth rate');Growth{1,2} = ('GEM ratio');Growth{1,3} = ('Kinetic biomass ratio');Growth{1,4} = ('YXmCH4');Growth{1,5} = ('YXpCO2');
for i=1:length(timeGEM)
    VisioInput(:,i) = XXInteractionsSolution{1,i}{2,2}.full; % for Visio input
    Growth{i+1,1} = XXInteractionsSolution{1,i}{2,2}.obj; %coculture growth rate
    Growth{i+1,2} = XXInteraction{1,i}{2,5}/XXInteraction{1,i}{2,4}; %ratio of biomass (P:M) predicted by GEM
    Growth{i+1,3} = ratioco(i); %ratio of biomass (P:M) predicted by Kinetic model
    Growth{i+1,4} = (XXInteraction{1,i}{2,4}/XXInteractionsSolution{1,i}{2,2}.full(1));
    Growth{i+1,5} = -(XXInteraction{1,i}{2,5}/XXInteractionsSolution{1,i}{2,2}.full(1051));
end
