clear
pATh                  = "/Users/lshjr3/Documents/RaMMPS/under-five mortality/";
lISt                  = {'RaMMPSdst','DHSmalawidst','RaMMPScalls'};
for i = 1:numel(lISt)
    options    = detectImportOptions(char(pATh + string(lISt{i}) + ".csv"));
    for j = 1:numel(options.VariableTypes)
        if isequal(options.VariableTypes{j},'char')
            options.VariableTypes{j} = 'categorical';
        end
        if isequal(options.VariableTypes{j},'datetime') & ~isequal(lISt{i},'RaMMPScalls')
            options.VariableOptions(1,j).InputFormat = 'dd/MM/yyyy';
        end
    end
    sET        = readtable(char(pATh + string(lISt{i}) + ".csv"),options);
    assignin('base',lISt{i},sET);
    clear options j sET
end
clear lISt i
save(char(pATh + "Results/RaMMPSf.mat"),'RaMMPS');
RaMMPSdst             = RaMMPSdst(isundefined(RaMMPSdst.missing),:);
save(char(pATh + "Results/RaMMPS.mat"));

clear
pATh                  = "/Users/lshjr3/Documents/RaMMPS/under-five mortality/";
load(char(pATh + "Results/RaMMPS.mat"),'RaMMPSdst');
list         = {'$\textrm{RaMMPS, all 18-64}$'};
models       = {'$\textit{unweighted}$','$\textit{weighted}$'};

for i = 1:numel(list)
    for j = 1:numel(models)
        I          = numel(models)*(i - 1) + j;
        date       = max(RaMMPSdst.interview);
        ts{I,1}    = datetime([2014 year(date)]',[1 month(date)]',[1 day(date)]');
        date       = eXAcTTime(ts{I,1});
        date       = string(list{i}) + ", " + string(sprintf('%0.1f',date(1))) + "-" + string(sprintf('%0.1f',date(2)));
        pOPsD{I,1} = {char("RaMMPS " + date);models{j}};
        pOPsS{I,1} = list{i};
        clear data I
    end
end

sET                   = [ones(size(RaMMPSdst.WT)),RaMMPSdst.WT];
R                     = 1000;
bLOKs                 = {1,2,3,4};
data                  = RaMMPSdst;
for i = 1:numel(models)
    rng(0);
    S          = [ones(size(data,1),1),rand(size(data,1),R)];
    for j = 1:numel(bLOKs)
        sEL             = find(data.group == bLOKs{j});
        W               = sET(sEL,i);
        W               = [0;cumsum(W(1:end - 1))]/sum(W);
        for r = 2:R + 1
            temp     = tabulate([sum(W < S(sEL,r)',1)';numel(sEL) + 1]);
            S(sEL,r) = temp(1:end - 1,2);
            clear temp
            clc;
            r/(R + 1)
        end
    clear W sEL    
    end
    dATadst{i} = {data.group  > 0,S};
    clear S
end

load(char(pATh + "Results/RaMMPS.mat"),'DHSmalawidst');
listDHS               = {'$\textrm{DHS VII, all 18-64}$'};
modelsDHS             = {'$\textit{all}$','$\textit{m.\,owner}$','$\textit{re-weighted}$'};
dATaDHSdst{1}         = {DHSmalawidst.age >= 18 & DHSmalawidst.age < 65 & DHSmalawidst.jure == 1,DHSmalawidst.Wh};
dATaDHSdst{2}         = {DHSmalawidst.age >= 18 & DHSmalawidst.age < 65 & DHSmalawidst.mobile == 1 & DHSmalawidst.jure == 1,DHSmalawidst.Wh};
dATaDHSdst{3}         = {dATaDHSdst{2}{1},DHSmalawidst.WT};

rng(0);
s                     = DHSmalawidst(DHSmalawidst.k == 1, {'cluster','k','K','h','H','iNDeX'});
w                     = rand(size(s,1),R);
w                     = [(1:size(s,1))',ceil(s.H.*w) + s.iNDeX];
Wdhs                  = NaN(size(DHSmalawidst,1),R + 1);
for r = 1:R + 1
    S                  = tabulate([w(:,1);w(:,r)]);
    Wdhs(:,r)          = repelem(S(:,2) - 1,s.K);
    clc;
    r/(R + 1)
end
clear r s S w

for i = 1:numel(dATaDHSdst)
    dATaDHSdst{i}{1,2} = Wdhs.*dATaDHSdst{i}{1,2};
end

for i = 1:numel(modelsDHS)
    mIn              = min(DHSmalawidst.interview);
    mAx              = max(DHSmalawidst.interview);
    mAx              = mean([mIn mAx]);
    mIn              = datetime([year(mAx) - 5,month(mAx),day(mAx)],'Format','dd/MM/yyyy');
    date             = [mIn mAx]';
    ts{end + 1,1}    = date;
    date             = eXAcTTime(date);    
    date             = ", " + string(sprintf('%0.1f',date(1))) + "-" + string(sprintf('%0.1f',date(2)));
    date             = char("DHS VII" + date);
    pOPsD{end + 1,1} = {date;modelsDHS{i}};
    pOPsS{end + 1,1} = listDHS{1};
    clear deta mIn mAx
end


pACk         = {{RaMMPSdst,dATadst},{DHSmalawidst,dATaDHSdst}};
lABelS       = {'Place of residence','Region','Sex','Age','Education','Household size','Electricity','Drinking water','Roofing'};
lABelSd      = {{'urban' 'rural'} {'North' 'Central' 'South'} {'Female' 'Male'} {'18-29' '30-39' '40-49' '50-64'} {'less than complete primary' 'incomplete secondary' 'complete secondary or more'} {'1-4' '5-8' '9+'} {'access' 'no access'} {'safe source' 'other source'} {'durable material' 'other material'}}; 
outcomes     = {[1 2],[1 2 3],[2 1],[1 2 3 4],[1 2 3],[1 2 3],[2 1],[2 1],[2 1]};

H            = 0;
for h = 1:numel(pACk)
    d    = pACk{h}{1};
    data = [d.UR,d.Region,d.sex,d.GO,d.Education,d.household,d.Electricity,d.Water,d.Roofing];
    for i = 1:numel(pACk{h}{2})
        H  = H + 1;
        s  = pACk{h}{2}{i}{1};
        sW = pACk{h}{2}{i}{2}(s,:);
        I  = 0;
        for j = 1:numel(outcomes)
            for k = 1:numel(outcomes{j})
                I        = I + 1;
                BST      = ((data(s,j) == outcomes{j}(k))'*sW)./sum(sW,1);
                bOx{I,H} = prctile(100*BST(2:end),[50 2.5 97.5]);
                
                if isequal(h,1) & isequal(i,1)
                    if k == 1
                        pOPsd{I,1} = {char(string(lABelS{j}) + ": " + string(lABelSd{j}{k}))};
                    else
                        pOPsd{I,1} = {lABelSd{j}{k}};
                    end
                end
            end
        end
        
        if isequal(h,1) & isequal(i,1)
            bOx{end + 1,H}   = [sum(s) NaN NaN];
            pOPsd{end + 1,1} = {'Observations'};            
        else
            bOx{end,H}       = [sum(s) NaN NaN];
        end
    end
end

selection    = 1 + [0 cumsum([numel(models)])];
for i = 1:numel(selection)
    sEt{i} = {pOPsS{selection(i)}};
end

lABs       = {{1} {3 4 5} {6} {8 9 10 11} {12 13 14} {15 16 17} {18} {24}};
vARs       = {models modelsDHS};
foRMaT     = {'%0.2f','%0.2f','%0.2f'};

nOTe       = {'$\textrm{Attributes}$/$\textit{method}$',''};
tABleBAyEs(sEt,vARs,foRMaT,lABs,nOTe,pOPsd,cell2mat(bOx(:,[1 2 3 4 5])),0.190,0.065,[]);
saveas(gcf,char(pATh + "Results/RaMMPS-Data Table 3.png"));
s            = [1 3 4 5 6 8 9 10 11 12 13 14 15 16 17 18 24];
bOx          = bOx(s,[1 2 3 4 5]);
pOPsd        = pOPsd(s);
sets         = sEt([1 2 3 4 5]);
vars         = vARs;
save(char(pATh + "Results/Tables/data_Table_3.mat"),'bOx','pOPsd','vars','sets');
clear bOx  pOPsd vars sets s

clear
pATh                  = "/Users/lshjr3/Documents/RaMMPS/under-five mortality/";
load(char(pATh + "Results/RaMMPS.mat"),'RaMMPScalls');
R                     = 0;
bLOKs                 = {1,2,3,4};
data                  = RaMMPScalls(RaMMPScalls.k == RaMMPScalls.K,{'group','caseid','K','catioutcome','catiOUTcome'});

rng(0);
WS                    = [ones(size(data,1),1),rand(size(data,1),R)];
for j = 1:numel(bLOKs)
    sEL             = find(data.group == bLOKs{j});
    W               = ones(size(sEL));
    W               = [0;cumsum(W(1:end - 1))]/sum(W);
    for r = 2:R + 1
        temp      = tabulate([sum(W < WS(sEL,r)',1)';numel(sEL) + 1]);
        WS(sEL,r) = temp(1:end - 1,2);
        clear temp
        clc;
        r/(R + 1)
    end
clear W sEL    
end
W                     = WS(repelem((1:size(data,1))',data.K),:);

data.complete         = (data.catiOUTcome ==  1);
data.refusal          = (data.catiOUTcome ==  3);
data.eligible         = (data.catiOUTcome ==  1 | data.catiOUTcome ==  2 | data.catiOUTcome ==  3 | data.catiOUTcome == 4 | data.catiOUTcome == 7);

CATI                  = data.complete'*WS;
cases                 = size(data,1);
calls                 = size(RaMMPScalls,1);
response              = (data.complete'*WS)./(data.eligible'*WS)*100;
refusal               = (data.refusal'*WS)./(data.eligible'*WS)*100;
callperCATI           = calls./CATI;
numbersCATI           = cases./CATI;

nAMeS{1,1}            = {'$\textrm{Complete CATI}$';'$\textrm{}$'};
nAMeS{2,1}            = {'$\textrm{Cases}$';'$\textrm{}$'};
nAMeS{3,1}            = {'$\textrm{Calls placed}$';'$\textrm{}$'};
nAMeS{4,1}            = {'$\textrm{Response rate (\%)}$';'$\textit{excludes ineligible and numbers not in use}$'};
nAMeS{5,1}            = {'$\textrm{Refusal rate (\%)}$';'$\textit{excludes ineligible and numbers not in use}$'};
nAMeS{6,1}            = {'$\textrm{Calls per complete CATI}$';'$\textrm{}$'};
nAMeS{7,1}            = {'$\textrm{Cases per complete CATI}$';'$\textrm{}$'};

bOx{1,1}              = prctile(CATI,[50 2.5 97.5]);
bOx{2,1}              = [cases,NaN(1,2)];
bOx{3,1}              = [calls,NaN(1,2)];
bOx{4,1}              = prctile(response,[50 2.5 97.5]);
bOx{5,1}              = prctile(refusal,[50 2.5 97.5]);
bOx{6,1}              = prctile(callperCATI,[50 2.5 97.5]);
bOx{7,1}              = prctile(numbersCATI,[50 2.5 97.5]);

sEt                   = {'$\textrm{}$'};
lABs                  = {{1 2 3} {4 5} {6 7}};
models                = {'$\textit{}$'};
vARs                  = {models};
foRMaT                = {'%0.2f'};
nOTe                  = {'$\textrm{Summary}$',''};
tABleBAyEs(sEt,vARs,foRMaT,lABs,nOTe,nAMeS,cell2mat(bOx),0.250,0.070,[]);
saveas(gcf,char(pATh + "Results/RaMMPS-Data Table 1.png"));
s                     = [1 2 3 4 5 6 7];
bOx                   = bOx(s,:);
pOPsd                 = nAMeS(s);
sets                  = sEt;
vars                  = vARs;
save(char(pATh + "Results/Tables/data_Table_1.mat"),'bOx','pOPsd','vars','sets');
clear nAMeS bOx pOPsd vars sets s


TAB                   = tabulate(data.catiOUTcome);
TAB                   = TAB(:,1);
for i = 1:numel(TAB)
    sEL        = (data.catiOUTcome == TAB(i));    
    bOx{i,1}   = [sum(sEL),NaN(1,2)];
    bOx{i,2}   = prctile((sEL'*WS)./(sum(WS,1))*100,[50 2.5 97.5]);
    temp       = data.catioutcome(sEL);
    temp       = char(temp(1));
    j          = find(temp == '(');
    if numel(j) > 0
        nAMeS{i,1} = {char("$\textrm{" + temp(1:j - 2) + "}$");char("$\textit{" + temp(j:end) + "}$")};
    else
        nAMeS{i,1} = {char("$\textrm{" + temp + "}$");'$\textit{}$'};
    end
    clear sEL temp j
end

bOx{i + 1,1}        = [size(data,1),NaN(1,2)];
bOx{i + 1,2}        = [100,NaN(1,2)];
nAMeS{i + 1,1}      = {'$\textrm{Total cases}$';'$\textrm{}$'};

lABs                  = {{1 2 3 4},{5 6},{7},{8}};
models                = {'$\textit{Number}$','$\textit{\%}$'};
vARs                  = {models};
foRMaT                = {'%0.0f','%0.2f'};
nOTe                  = {'$\textrm{Call Outcome}\textit{ (final dispositions)}$',''};
tABleBAyEs(sEt,vARs,foRMaT,lABs,nOTe,nAMeS,cell2mat(bOx),0.250,0.070,[]);
saveas(gcf,char(pATh + "Results/RaMMPS-Data Table 2.png"));
s                     = [1 2 3 4 5 6 7 8];
bOx                   = bOx(s,:);
pOPsd                 = nAMeS(s);
sets                  = sEt;
vars                  = vARs;
save(char(pATh + "Results/Tables/data_Table_2.mat"),'bOx','pOPsd','vars','sets');
clear nAMeS bOx pOPsd vars sets s