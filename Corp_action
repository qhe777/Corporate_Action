%% Initial parameters
%------------------------------------------------------------------
mydate=datestr(datetime('yesterday'),'YYYYmmdd');

%------------------------------------------------------------------
cd='C:\mypath';
sftp_bat=fullfile(cd,'sftp.txt');

%% Get data from S&P   (updated 4:30 pm daily)
%download files
sp_host='sftp.myhost.com';
sp_account='myaccount';
sp_pw='mypassword';
sp_format=sprintf('r/%s_BNYMELLON_*_MKT_CLASSIC_ADR.SDE',mydate);
sp_Cols=[5,7,9,11,13,15,23,29];
SP_Actions={'Drop','Merger/Acquisition','Rights Offering','Spin-Off'};

fid_1 = fopen(sftp_bat, 'wt' );
fprintf(fid_1, 'lcd "%s"\n', cd); %change path to current path
fprintf(fid_1, 'mget "%s"\n', sp_format);
fprintf(fid_1, '%s\n', 'quit');
fclose(fid_1);

system('cd C:\Program Files\PuTTy')
sftp_command=sprintf('psftp -b %s -pw %s %s@%s',sftp_bat,sp_pw, sp_account, sp_host);
system(sftp_command)
delete(sftp_bat)

%read data
file_info=dir(sprintf('%s_BNYMELLON_*_MKT_CLASSIC_ADR.SDE',mydate));
file_list={file_info.name};
n=length(file_list);
if n==0 %if there is no new files yesterday, exit
    exit
end
ADR_raw=[];
for i = 1:n
    filename=file_list{i};
    source=sprintf('S&P_%s',filename(20:21));
    
    fid_2=fopen(filename,'r','n','US-ASCII');
    format=repmat('%q',[1,91]);
    C=textscan(fid_2,format,'Delimiter','\t','HeaderLines',1,'Whitespace','\b');
    fclose(fid_2);
    C{1}(end)=[];
    C{2}(end)=[];
    mydata=[C{:}];
    mydata=mydata(:,sp_Cols);
    mydata(:,end+1)={mydate};
    mydata(:,end+1)={source};
    ADR_raw=[ADR_raw;mydata];
end
idx=cellfun(@(x) any(strcmp(x,SP_Actions)),ADR_raw(:,1));
ADR=ADR_raw(idx,:);
ADR=[ADR(:,9:10),ADR(:,1:8)];
ADR(:,11)={''};
delete(sprintf('%s_BNYMELLON_*_MKT_CLASSIC_ADR.SDE',mydate))

%% Get corporate actions data from Bloomberg
bb_host='sftp.myhost.com';
bb_account='myaccount';
bb_pw='mypassword';
%------------------------------------------------------------------
% bb_filename='equity_namr.cax';
bb_filename='equity_namr_0228.cax';
%------------------------------------------------------------------

rpath='Bloomberg Data Files';
bb_format=[rpath,'/',bb_filename];
bb_cols=[6,7,16,15,5,9,10,1,21];
bb_Actions={'ACQUIS','SPIN','DELIST','RIGHTS_OFFER','STOCK_SPLT',...
    'DVD_STOCK','CHG_TKR','CHG_ID','RECLASS'};

fid_1 = fopen(sftp_bat, 'wt' );
fprintf(fid_1, 'lcd "%s"\n', cd); %change path to current path
fprintf(fid_1, 'mget "%s"\n', bb_format);
fprintf(fid_1, '%s\n', 'quit');
fclose(fid_1);

system('cd C:\Program Files\PuTTy')
sftp_command=sprintf('psftp -b %s -pw %s %s@%s',sftp_bat,bb_pw, bb_account, bb_host);
system(sftp_command)
delete(sftp_bat)

fid_3=fopen(bb_filename,'r');
format=[repmat('%q',[1,20]),'%[^\n]'];
C=textscan(fid_3,format,'Delimiter','|');
fclose(fid_3);
start_index=find(strcmp(C{1},'START-OF-DATA'))+1;
end_index=find(strcmp(C{1},'END-OF-DATA'))-1;

dateinfo=C{1}{find(strcmp(C{1},'END-OF-FILE'))-1};
dateinfo=regexprep(dateinfo,'[^=]+=','');
dateinfo=regexprep(dateinfo,'EDT ','');
dateinfo=regexprep(dateinfo,'EST ','');
t = datetime(dateinfo,'InputFormat','eeee MMMM dd HH:mm:ss yyyy');
bbdate=datestr(t,'yyyymmdd');

index_1=cellfun(@(x) any(strcmp(x,bb_Actions)),C{6});
C=[C{:}];
namr=C(index_1,bb_cols);
index_2=cellfun(@(x) any(strfind(x,'US Equity')),namr(:,8),'UniformOutput',1);
namr=namr(index_2,:);
namr(~strcmp(namr(:,6),'CUSIP'),7)={''};
namr(:,6)={''};
namr(:,8)=regexprep(namr(:,8),'\s+.+','');
namr(:,8)=strrep(namr(:,8),'/','');
namr(:,end+1)={bbdate};
namr(:,end+1)={'Bloomberg'};
namr=[namr(:,10:11),namr(:,1:9)];
namr(strcmp(namr(:,6),'N.A.'),6)={''};
u_idx=[1];
for i=2:size(namr,1)
    if ~(strcmp(namr(i,7),namr(i-1,7)) && strcmp(namr(i,10),namr(i-1,10)))
        u_idx=[u_idx,i];
    end
end
namr=namr(u_idx,:);
delete('equity_namr.cax')

%% get stocks universe
% mydate
load 'Cusip.mat'
tickers=cusip_exchange(:,4);
tickers_nodot=strrep(tickers,'.','');
tickers_ADR=cusip_exchange_ADR(:,4);
tickers_ADR_nodot=strrep(tickers_ADR,'.','');

%% get current portfolio holdings
run C:\mypath\qp.m
qps=dir(sprintf('C:\\mypath\\qp_%s.mat',mydate));
portfolios=qps.name;
load(fullfile('C:\mypath', portfolios))

%% Find companies with Corp Actions that are in current holdings
models=fieldnames(s);
summary_h=[];
tickers_holdings=[];
for i=1:length(models)
    model_i=models{i};
    port_i=s.(model_i);
    tickers=port_i(:,1);
    tickers_holdings=[tickers_holdings;tickers];
    index_sp=cellfun(@(x) any(strcmp(tickers,x)),ADR(:,10));
    index_bb=cellfun(@(x) any(strcmp(tickers,x)),namr(:,10));
    if (any(index_sp) || any(index_bb))
        mydata=[ADR(index_sp,:);namr(index_bb,:)];
        mydata=sortrows(mydata,[2,7]);
        mydata(:,12)={model_i};
        summary_h=[summary_h; mydata];
    end
end
tickers_holdings=unique(tickers_holdings);
summary_h=sortrows(summary_h,[2,7,10]);
n=1;
u_idx=[1];
group_id=[n];
for i=2:size(summary_h,1)
    if ~(strcmp(summary_h(i-1,2),summary_h(i,2)) && strcmp(summary_h(i-1,7),summary_h(i,7)) && strcmp(summary_h(i-1,10),summary_h(i,10)))
        n=n+1;
        u_idx=[u_idx,i];
    end
    group_id=[group_id,n];
end

effected_model_tickers=repmat({''},[n,2]);
for i=1:n
    effected_models=group_id==i;
    num_effected=sum(effected_models);
    effected_models_cells=summary_h(effected_models,12)';
    effected_models_str=effected_models_cells{1};
    if num_effected>1
        for j=2:num_effected
            effected_models_str=[effected_models_str,'|',effected_models_cells(j)];
        end
        effected_models_str=cell2mat(effected_models_str);
    end
    effected_model_tickers(i,1:2) = [{num_effected},{effected_models_str}];
end
summary_h=[summary_h(u_idx,1:11),effected_model_tickers];
summary_h(:,11)=cellfun(@(x) strrep(x,'''','"'),summary_h(:,11),'UniformOutput',0);

%% Add Corp Actions in Stock Universe but not in current holdings
tickers_u_minus_h=setdiff([tickers_nodot;tickers_ADR_nodot],tickers_holdings);
tickers_ADR_u_minus_h=setdiff(tickers_ADR_nodot,tickers_holdings);

BB_donotinvest_idx=cellfun(@(x) any(strcmp(tickers_u_minus_h,x)),namr(:,10),'UniformOutput',1);

SP_donotinvest_idx=cellfun(@(x) any(strcmp(tickers_ADR_u_minus_h,x)),ADR(:,10),'UniformOutput',1);

summary_u=[namr(BB_donotinvest_idx,:); ADR(SP_donotinvest_idx,:)];
summary_u(:,[end+1,end+2])={''};
summary_all=[summary_h;summary_u];

summary_all(strcmp(summary_all(:,6),''),6)={'null'};



%% write corporate actions in both universe and current holdings to SQL
%Initialize the SQL data source
data_source='SQLdatabase';
username='';
password='';
tablename = '[ciqdata].[dbo].[Corp_Action]';

% % create the table (run only once)
% conn = database(data_source, username, password);
% conn.Message
% create_table_query1=sprintf(['CREATE TABLE %s( '...
%     '[Recording_Date] date not null, '...
%     '[Source] varchar (20), '...
%     '[Action_Type] varchar (20), '...
%     '[Status] varchar (15), '...
%     '[Last_Updated_Date] date, '...
%     '[Effective_Date] date, '...
%     '[Action_ID] varchar (20) not null, '...
%     '[Sequence_No.] int, '...
%     '[Current_Cusip] varchar (15), '...
%     '[Current_Ticker] varchar (15) not null, '...
%     '[Details] nvarchar (4000), '...
%     '[No._Model_effected] int, '...
%     '[Model_tickers] varchar (8000), '...
%     'PRIMARY KEY ([Recording_Date], [Action_ID], [Current_Ticker]) )'],...
%     tablename);
% curs=exec(conn,create_table_query1);
% curs.Message
% close(curs);
% close(conn);


% % Insert data
try
    conn = database(data_source, username, password);
    conn.Message
    colnames={'[Recording_Date]','[Source]','[Action_Type]','[Status]','[Last_Updated_Date]',...
        '[Effective_Date]','[Action_ID]','[Sequence_No.]','[Current_Cusip]',...
        '[Current_Ticker]','[Details]','[No._Model_effected]','[Model_tickers]'};
    insert(conn,tablename,colnames,summary_all);
    
    close(conn);
catch me
    me.identifier
end

