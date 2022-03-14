# OCT
Out-of-sample Causal Tuning

This repository contains the code for the paper:\
K. Biza, I. Tsamardinos, S. Triantafillou, Out-of-sample Tuning for Causal Discovery,
Manuscript submitted for publication, 2021

It is based on our previous work:\
K. Biza, I. Tsamardinos, S. Triantafillou, Tuning Causal Discovery Algorithms,
Proceedings of the Tenth International Conference on Probabilistic Graphical Models, 2020


Contact: konbiza@gmail.com


## Experimental_setup.m 

Set the parameters for the experiment.

- Nnets : number of repetitions

### Causal hyper-parameters 
- cdParam.alpha : significance level
- cdParam.penaltyDiscount
- cdParam.structurePrior
- cdParam.algs : causal discovery algorithms {*'pc','cpc', 'pcstable', 'cpcstable', 'fges', 'lingam', 'fci', 'fcimax', 'rfci', 'gfci', 'mmhc','m3hc', 'full', 'empty'*}
- cdParam.indTests : independence tests {*'fisher', 'cci', 'cg_lrt', 'dg_lrt', 'chisquare', 'gsquare'*}
- cdParam.scores : {*'sembic', 'bdeu', 'discreteBic', 'cg_bic', 'dg_bic'*}


### Simulation 
Simulate data or apply the causal-based simulation
- causalbasedSim=false;

#### Causal-based Simulation

- simParam.nameData  : the name of the real dataset {*Iris, Wine, HeartDisease, WineQualityRed, BreastCancerWisconsin, Car, Abalone, ForestFire, StudentMat*}
- simParam.Nsamples  : the number of samples to resimulate


#### Data Simulation

- graphInfo

| dataType	| causalGraph	| graphType |	
| --------- | --------- | --------- |
| continuous | DAG | ConDag |		
| categorical| DAG | CatDag |
| mixed | DAG | MixDag |
| continuous | MAG | ConMag |
| categorical | MAG | CatMag |
| mixed | MAG | MixMag |


- simParam.Nnodes  : number of nodes 
- simParam.Nedges  : number of edges 
- simParam.Nsamples: number of samples 
- simParam.Nlatent : number of latent variables (if causalGraph=MAG)

In addition, for mixed data:
- simParam.method 	: {*'CondGaus', 'LeeHastie'*} 

and for continuous data: 
- simParam.func		: causal functional relations {*'sumX', 'sumX2', 'sumX-1', 'prodX', 'tanh', 'sumabsX', 'logX', 'exp05', 'exp15', 'logcosh', 'prode'*}     
- simParam.errorDist	: error distribution {*'gaussian', 'uniform'*} 


### SID

- computeSid=false

To compute SID you need first to modify StructInterventionalDist.m and sidR.R 

StructInterventionalDist.m\
line 11:  Change the path and the R version if needed. Example:\
	  rscript = '"C:\Program Files\R\R-3.6.3\bin\Rscript.exe" ';

sidR.R\
line 1:   Change the path. Example:\
	  setwd('C:/Users/konstantina/OCT/Functions/SidMetric')

We use the [SID](https://CRAN.R-project.org/package=SID) package


### TETRAD

We use the [tetrad project](https://github.com/cmu-phil/tetrad) for the simulation of mixed data, causal discovery algorithms (except MMHC, M3HC), BIC, AIC, CG, and DG scores.\
For more information read also : http://cmu-phil.github.io/tetrad/manual/ \
Please download the jar file "tetrad-gui-6.8.1-launch.jar" from https://cloud.ccd.pitt.edu/nexus/content/repositories/releases/edu/cmu/tetrad-gui/6.8.1/  and add it in the tetradJar folder.

SCORE=2L-penDiscount*ln(n)*k
- if penDiscount=1 : BIC
- if penDiscount=2/ln(n) : AIC
    
CG=2(L+structurePrior)-penDiscount*ln(n)*k

DG=2(L+structurePrior)-penDiscount*ln(n)*k

Higher is better for all scores (BIC, AIC, CG, DG)


### Notation

DAG\
(i, j)=1 and (j, i)=0  : i-->j


PDAG\
(i, j)=1 and (j, i)=0  : i-->j\
(i, j)=1 and (j, i)=1  : i---j


MAG\
(i, j)=2 and (j, i)=3  : i-->j\
(i, j)=2 and (j, i)=2  : i<->j


PAG\
(i, j)=2 and (j, i)=3  : i-->j\
(i, j)=2 and (j, i)=2  : i<->j\
(i, j)=2 and (j, i)=1  : io->j\
(i, j)=1 and (j, i)=1  : io-oj

## Tuning.m

Evaluate the performance of the tuning methods.
