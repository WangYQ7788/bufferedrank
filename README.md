# Buffered rankings for economic efficiency analysis
Best buffered ranking: The best buffered-ranking for a DMU is the highest upper buffered-ranking over all feasible settings of input/output multipliers. Here, the upper buffered-ranking for a DMU is the maximum *k* that the average of the top *k* efficient scores is higher than or equal to this DMU.

## Requirements:
[Gurobi](http://www.gurobi.com "Gurobi")

## Usage
function BestEcoBuffRankFun
function WorstEcoBuffRankFun
function BestEcoRankOpt
function WorstEcoRankOpt
function BestTechRankOpt
function WorstTechRankOpt
### %Aim 
- %Estimate the best buffered ranking of the economic efficiency of iDMUo among DMUs (mInput,mOutput)

## Files
-  BestEcoBuffRankFun.m: Estimate the best buffered ranking in terms of economic efficiency
-  WorstEcoBuffRankFun.m: Estimate the worst buffered ranking in terms of economic efficiency
-  BestEcoRankOpt.m: Estimate the best ranking in terms of economic efficiency
-  WorstEcoRankOpt.m: Estimate the worst ranking in terms of economic efficiency
-  BestTechRankOpt.m: Estimate the best ranking in terms of technical efficiency
-  WorstTechRankOpt.m: Estimate the worst ranking in terms of technical efficiency
-  exp1.m: illustrates the first concern with artificial data 1
-  exp2.m: illustrates the second concern with artificial data 2
-  exp3.m: illustrates the third concern with Pig data
-  pigdata.xlsx: Data file

## Citation
Yongqiao Wang, Stan Uryasev, Buffered-Rankings for Economic Efficiency Analysis, Working paper, Zhejiang Gongshang University.
