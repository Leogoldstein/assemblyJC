function [IDXs,sCl,M,S] = kmeansopt(E,N,type)

%E p parameters (cells) by N Events
%N number of trials per cluster number
%p p-value for cluster validation

Ne = size(E,2);

%% Covariance matrix
if strcmp(type,'var')
    M = CovarM(E);
end

%% k-means loop
% rng("default")
parfor k = 1:N*18
    NCl = floor((k-1)/N) + 2;
    % IDX = kmeans(E',NCl)'; %Normal K-means on distance metric
    % IDX = kmeans(M,NCl,"MaxIter",300,'OnlinePhase','on');%,'distance','cityblock');    % Kmeans on distance of covariance metric
    IDX = kmeans(M,NCl,"MaxIter",300)%   % Kmeans on distance of covariance metric
    s = silh(M,IDX);
    IDX0(k,:) = IDX;
    S(k) = mean(s);
end

%Best clustering for each cluster number

% IDX1 = zeros(18,Ne);  %removed 2023-11-19
% for i = 1:18
%     tmp = IDX0((i-1)*N+(1:N),:);
%     [~,idx] = max(S((i-1)*N+(1:N))); % maybe 95% should be better
%     IDX1(i,:) = tmp(idx,:);
% end

%% keep best silhouette  %%%seem redundant...

[~,ClOK] = max(S); % maybe 95% should be better  
% test = prctile(S,95); 
NCl = floor((ClOK-1)/N) + 2;
IDX = IDX0(ClOK,:);
s = silh(M,IDX);
sCl = zeros(1,NCl);
for i = 1:NCl
    sCl(i) = median(s(IDX==i));
end

%sort RACE/silhouette of best cluster
[sCl,xCl] = sort(sCl,'descend');
IDXs = zeros(1,Ne);
for i = 1:NCl
    IDXs = IDXs + (IDX == xCl(i))*i;
end

