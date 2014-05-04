groupNaive = dlmread('naive.mat');
groupCB = dlmread('cb.mat');
groupGT = dlmread('gt.mat');
groupGE = dlmread('ge.mat');
groupHF = dlmread('hf.mat');

figure;
hold on;
[numtrials junk] = size(groupNaive)
errorbar(mean(groupNaive), std(groupNaive)/sqrt(numtrials), 'b-o');
errorbar(mean(groupCB), std(groupCB)/sqrt(numtrials), 'r-x');
errorbar(mean(groupHF), std(groupHF)/sqrt(numtrials), 'g-+');
errorbar(mean(groupGT), std(groupGT)/sqrt(numtrials), 'm-.');
errorbar(mean(groupGE), std(groupGE)/sqrt(numtrials), 'k-^');
%set(gca, 'Yscale', 'log');
ylim([0.2 0.75])
xlim([0 10])
xlabel('Number of Gibbs Iterations')
ylabel('Error rate')
title('Error rate v. Number of Gibbs Iterations')
legend('Naive', 'Checker Board', 'Hamze-Freitas Two Trees', 'Greedy Tree', 'Greedy Edge');


%figure;
%hold on;
%errorbar(mean(groupCB), std(groupCB)/sqrt(numtrials), 'r-x');
%errorbar(mean(groupHF), std(groupHF)/sqrt(numtrials), 'g-+');
%errorbar(mean(groupGT), std(groupGT)/sqrt(numtrials), 'm-.');
%errorbar(mean(groupGE), std(groupGE)/sqrt(numtrials), 'k-^');
%%set(gca, 'Yscale', 'log');
%ylim([0.2 0.45])
%xlim([0 10])
%legend('Checker Board', 'Hamze-Freitas Two Trees', 'Greedy Tree', 'Greedy Edge');
