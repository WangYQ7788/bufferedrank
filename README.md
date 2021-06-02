# Buffered rankings for economic efficiency analysis
Best buffered ranking: The best buffered-ranking for a DMU is the highest upper buffered-ranking over all feasible settings of input/output multipliers. Here, the upper buffered-ranking for a DMU is the maximum *k* that the average of the top *k* efficient scores is higher than or equal to this DMU.

## Requirements:
[Gurobi](http://www.gurobi.com "Gurobi")

## Usage
function [Rank,RunTime,ApproxRank]=BestEcoBuffRankFun(mInput,mOutput,iDMUo,params) 
function [Rank,RunTime,ApproxRank]=WorstEcoBuffRankFun(mInput,mOutput,iDMUo,params)
function [Rank,RunTime]=BestEcoRankOpt(mInput,mOutput,iDMUo,params)
function [Rank,RunTime]=WorstEcoRankOpt(mInput,mOutput,iDMUo,params)
function [Rank,RunTime]=BestTechRankOpt(mInput,mOutput,iDMUo,params)
function [Rank,RunTime]=WorstTechRankOpt(mInput,mOutput,iDMUo,params)
### %Aim 
- %Estimate the best buffered ranking of the economic efficiency of iDMUo among DMUs (mInput,mOutput)
### %inputs 
- %mInput: matrix of inputs, x_jm, row: DMU, column: input 
- %mOutput:matrix of outputs, x_jn, row: DMU, column: output 
- %jDMUo: a number, the DMU to be evaluated 
- %params: the gurobi parameters
### %output 
- %Rank: number, the best rank for DMUo 
- %RunTime: time in seconds, running time for computing DMUo's best ranking 
- %ApproxRank: the upper rank of DMUo in J measures E_j(nu*,mu*)

## Files
-  BestEcoBuffRankFun.m: Estimate the best buffered ranking in terms of economic efficiency
-  WorstEcoBuffRankFun.m: Estimate the worst buffered ranking in terms of economic efficiency
-  BestEcoRankOpt.m: Estimate the best ranking in terms of economic efficiency
-  WorstEcoRankOpt.m: Estimate the worst ranking in terms of economic efficiency
-  BestTechRankOpt.m: Estimate the best ranking in terms of technical efficiency
-  WorstTechRankOpt.m: Estimate the worst ranking in terms of technical efficiency
-  demo.m: The demo file that illustrates how to use six ranking functions
-  pigdata.xlsx: Data file

## Citation
Yongqiao Wang, Stan Uryasev, Buffered-Rankings for Economic Efficiency Analysis, Working paper, Zhejiang Gongshang University.
