%% 1. Open Simulink file and create environment

open_system('Env_cpl_buck')
obsInfo = rlNumericSpec([6 1],...
    'LowerLimit',[-inf -inf  -inf -inf -inf  -inf]',...
    'UpperLimit',[ inf  inf inf inf inf inf ]');
obsInfo.Name = 'observations';
obsInfo.Description = 'integrated error, error, and measured Vo';
numObservations = obsInfo.Dimension(1);

actInfo = rlFiniteSetSpec([0.44:0.01:0.55]);
actInfo.Name = 'action';
numActions = 12;

env = rlSimulinkEnv('Env_cpl_buck','Env_cpl_buck/RL Agent',...
    obsInfo,actInfo);
env.ResetFcn = @(in)localResetFcn(in);

Ts = 0.00005;
Tf = 0.4;
rng(0)


%% 2. Build neural network
dnn = [
    imageInputLayer([obsInfo.Dimension(1) 1 1],...
    'Normalization', 'none', 'Name', 'State')
    fullyConnectedLayer(64, 'Name', 'CriticStateFC1')
    reluLayer('Name', 'CriticRelu1')
    fullyConnectedLayer(64, 'Name', 'CriticStateFC2')
    reluLayer('Name','CriticCommonRelu')
    fullyConnectedLayer(numActions, 'Name', 'output')];

criticOptions = rlRepresentationOptions('LearnRate',1e-3,'GradientThreshold',1);%,'UseDevice','gpu'

critic = rlQValueRepresentation(dnn,obsInfo,actInfo, ...
    'Observation',{'State'},'Action',{'output'},criticOptions);


%% 3. Set training parameters
agentOptions = rlDQNAgentOptions(...
    'SampleTime',Ts,...
    'UseDoubleDQN',true,...
    'TargetSmoothFactor',1e-3,...'TargetUpdateFrequency',500,...
    'ResetExperienceBufferBeforeTraining',true,...
    'DiscountFactor',0.9,...
    'ExperienceBufferLength',2e5,...
    'MiniBatchSize',256);
opt.EpsilonGreedyExploration.Epsilon = 1;
opt.EpsilonGreedyExploration.EpsilonDecay = 0.001;
opt.EpsilonGreedyExploration.EpsilonMin = 0.1;


agent = rlDQNAgent(critic,agentOptions);
maxepisodes = 200;
maxsteps = ceil(Tf/Ts);
trainOpts = rlTrainingOptions(...
    'MaxEpisodes',maxepisodes, ...
    'MaxStepsPerEpisode',maxsteps, ...
    'ScoreAveragingWindowLength',20, ...
    'Verbose', false, ...
    'Plots','training-progress',...
    'StopTrainingCriteria','EpisodeReward',...
    'StopTrainingValue',48000,...%34000
    'SaveAgentCriteria','EpisodeReward',...
    'SaveAgentValue',48000);

%% 5. Reset function, reset Vref
 %doTraining = true;
doTraining = false;
if doTraining
    % Train the agent.
    trainingStats = train(agent,env,trainOpts);
    save('test.mat','agent');
end

if doTraining==false
    % Load pretrained agent for the example.
    load('1mh1mf20k.mat','agent');
end
   

rlSimulationOptions('MaxSteps',maxsteps,'StopOnError','on');
experiences = sim(env,agent,rlSimulationOptions);

%% 5.reset部分,重置Vref
function in = localResetFcn(in)
blk = sprintf('Env_cpl_buck/Desired Voltage');
V = 100;
while V <= 60 || V >= 300
   V =  100;
end
in = setBlockParameter(in,blk,'Value',num2str(V));

end

