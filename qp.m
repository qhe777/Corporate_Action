load existedfiles.mat
path = 'W:\mypath';
target_formate = sprintf('%s\\qp_*.xlsx',path);
fileinfo = dir(target_formate);
currentfiles = {fileinfo.name};
newfile_list = setdiff(currentfiles,existedfiles);
if isempty(newfile_list)
    disp('No new file')
else
    date_list=cellfun(@(x) [x(10:13),x(4:5),x(7:8)], newfile_list,'UniformOutput',false);
    uniquedates=unique(date_list);
    for i=1:length(uniquedates)
        date_i=uniquedates(i);
        files_i=newfile_list(strcmp(date_list,date_i));
        s = struct;
        for filecell = files_i
            filename = fullfile(path,filecell{:});
            [~,sheets] = xlsfinfo(filename);
            idx = cellfun(@(x) any(strfind(x,'Sheet')),sheets,'UniformOutput',1);
            sheets(idx)=[];
            for sheetcell = sheets
                sheetname = sheetcell{:};
                [~,~,raw] = xlsread(filename,sheetname);
                if size(raw,2)==8
                    mydata = raw(2:end,[1,2,4,8]);
                    index=cellfun(@isnan,mydata,'UniformOutput',0);
                    index=all(cellfun(@all,index),2);
                    mydata(index,:)=[];
                    mydata(:,1)=cellfun(@num2str,mydata(:,1),'UniformOutput',0');
                    mydata(:,2)=cellfun(@num2str,mydata(:,2),'UniformOutput',0');
                    fieldname = strrep(sheetname,'-','_');
                    s.(fieldname) = mydata;
                end

            end
        end

        dataname = sprintf('C:\\mypath\\qp_%s.mat',date_i{:});
        save(dataname,'s')
    end
    existedfiles = currentfiles;
    save('existedfiles.mat','existedfiles')
end
