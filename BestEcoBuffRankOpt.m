function [BuffRank,RunTime,ApproxRank,vOptNu,vOptMu]=BestEcoBuffRankOpt(mInput,mOutput,iDMUo,params,x0)
%Aim
%Estimate the best buffered ranking of the economic efficiency of iDMUo among DMUs (mInput,mOutput)

%inputs
%mInput: matrix of inputs, x_jm, row: DMU, column: input
%mOutput:matrix of outputs, x_jn, row: DMU, column: output
%jDMUo: a number, the DMU to be evaluated
%params: the gurobi parameters
%x0: (J+NumInput+NumOutput) vector, the initial point of [beta,nu,mu]

%output
%Rank: number, the best rank for DMUo
%RunTime: time in seconds, running time for computing DMUo's best ranking
%ApproxRank: the upper rank of DMUo in J measures E_j(nu*,mu*)
%vOptNu: the optimal Nu
%vOptMu: the optimal Mu

[J,nInput]=size(mInput);
[J1,nOutput]=size(mOutput);
BigC=0;
for m=1:nOutput
    if mOutput(iDMUo,m)~=0
        BigC=max(BigC,max(mOutput(:,m)/mOutput(iDMUo,m)));
    end
end

model.obj=[ones(J,1);zeros(nInput+nOutput,1)];
model.lb=zeros(J+nInput+nOutput,1);
model.ub=Inf*ones(J+nInput+nOutput,1);
model.A=sparse([-eye(J),-mInput+ones(J,1)*mInput(iDMUo,:),mOutput-ones(J,1)*mOutput(iDMUo,:)]);
model.rhs=-ones(J,1);
model.sense=repmat('<',J,1);
model.modelsense ='min';
model.objcon=0;
model.vtype=repmat('C',J+nInput+nOutput,1); 
if nargin==5
    model.Start=x0;
end

results = gurobi(model,params);
RunTime=results.runtime;
BuffRank=results.objval;
vOptNu=results.x((J+1):(J+nInput));
vOptMu=results.x((J+1+nInput):end);
vEffScore=mOutput*vOptMu-mInput*vOptNu;
ApproxRank=1+sum(vEffScore>vEffScore(iDMUo));





