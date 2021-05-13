clear
fileLocation = 'F:\Sleep_data\public_data\sleep-edfx_data\hypnogram\';
fileLoc = 'F:\Sleep_data\public_data\sleep-edfx_data\signal\';
X = dir(fileLocation);
for sub = 3:20 % :63
    ['-----------------------' sub '----------------------------']
    fileName_EEG = [X(sub).name(1:end-4) '-PSG.ascii'];
    fileName_hyp = X(sub).name;
    
    hyp=[]; hypno =[];
    y = fopen([fileLocation fileName_hyp]);
    T_ex = fgetl(y);
    T_ex = fgetl(y);
    T_ex = fgetl(y);
    n=0;cnt=0;Txl =0;start=-1;
    while(1)
        T_ex = fgetl(y);
        
                if T_ex == -1
            hypno = [hypno;hyp];
            hyp(end) = [];
            fclose(y);
            break;
        end

        
        for i=length(T_ex):-1:1 % duration ¹Þ±â
            x0 =T_ex(i);
            if T_ex(i) == '_'
                Txl = T_ex(i+1);
                break;
            elseif T_ex(i)==':'
                duration = str2double(T_ex(i+2:end));
            end
        end
        
        if start <0  % start & last setting
            if duration > 5000
                for i=1:length(T_ex) % sample number
                    x0 =T_ex(i);
                    if T_ex(i) == ']'
                        xs = i+1;
                    elseif T_ex(i)=='"'
                        xl = i-1;
                    end
                end
                start =str2double(T_ex(xs:xl))+ duration*100;
                continue;
            else
                start =str2double(T_ex(xs:xl));
            end
        else
            if duration > 5000
                for i=1:length(T_ex) % sample number
                    x0 =T_ex(i);
                    if T_ex(i) == ']'
                        xs = i+1;
                    elseif T_ex(i)=='"'
                        xl = i-1;
                    end
                end
                last = str2double(T_ex(xs:xl));
            else
                last = str2double(T_ex(xs:xl))+duration*100;
            end
        end
        
        
        if Txl ==0;
            continue;
        end
        for d = 1:duration/30
            if Txl =='W'; Txl = 1;
            elseif Txl =='R'; Txl = 2;
            elseif Txl=='1'||Txl=='2'; Txl=3;
            elseif Txl=='3'||Txl=='4'; Txl=4;
            elseif Txl==1; Txl=1;
            elseif Txl==2; Txl=2;
            elseif Txl==3; Txl=3;
            elseif Txl==4; Txl=4;
            else; Txl = 9;
            end
            hyp = [hyp; Txl];
        end
        n=n+1;
    end
    %% EEG data
    cnt = 0;
    x= [];
    xx=[];
    z = fopen([fileLoc fileName_EEG]);
    T_ex2 = fgetl(z); fir = -1;
    while(1)
        if fir < 0
        for s = 1:start
            T_ex2 = fgetl(z);
            if mod(s,1000)==0;
                s
            end
        end
        fir = fir+1;
        end
        for i=length(T_ex2):-1:1
            x0 =T_ex2(i);
            if T_ex2(i) == ';'
                x = [x; str2double(T_ex2(i+1:end))];
                break;
            end
        end
        if length(xx)==(length(hypno)*30*100)
            break
        end
        if isempty(x)
            fclose(z);
            break;
        elseif isnan(x(end))
            x(end) = [];
            xx = [xx;x];
            fclose(z);
            break;
        end
        
        cnt = cnt+1;
        if cnt==1000
            length(xx)
            xx = [xx; x];
            x=[];
            cnt=0;
        end
        if length(xx)==last
            break
        end
    end
    
    save([fileName_EEG '_hyp.mat'], 'hypno','xx');
end