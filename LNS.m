
function W=Label_Propagation(feature_matrix,tag,neighbor_num,regulation) %% Using the method of label propagation to predict the interaction
    distance_matrix=calculate_instances(feature_matrix);
    nearst_neighbor_matrix=calculate_neighbors(distance_matrix,neighbor_num);
    W=optimization_similairty_matrix(feature_matrix,nearst_neighbor_matrix,tag,regulation);
end

%%'regulation1':LN similarity, 'regulation2': RLN similarity
function W=optimization_similairty_matrix(feature_matrix,nearst_neighbor_matrix,tag,regulation) %%quadratic programming二次规划
   row_num=size(feature_matrix,1);
   W=zeros(1,row_num); %权重
   if tag==1    
       row_num=1;
   end
   for i=1:row_num      
       nearst_neighbors=feature_matrix(logical(nearst_neighbor_matrix(i,:)'),:);   
       neighbors_num=size(nearst_neighbors,1);
       G1=repmat(feature_matrix(i,:),neighbors_num,1)-nearst_neighbors; %相当于公式里的G
       G2=repmat(feature_matrix(i,:),neighbors_num,1)'-nearst_neighbors';
       if regulation=='regulation2'
         G_i=G1*G2+eye(neighbors_num);
       end
       if regulation=='regulation1'
         G_i=G1*G2;
       end
       H=2*G_i;
       f=[];
       A=[];
       if isempty(H)
           A;
       end
       
       b=[];
       Aeq=ones(neighbors_num,1)';
       beq=1;
       lb=zeros(neighbors_num,1);
       ub=[];
       options=optimset('Display','off');
       [w,fval]= quadprog(H,f,A,b,Aeq,beq,lb,ub,[],options);
       w=w';
       W(i,logical(nearst_neighbor_matrix(i,:)))=w;     
   end
end

function distance_matrix=calculate_instances(feature_matrix) %%calculate the distance between each feature vector of lncRNAs or disease.
    [row_num,col_num]=size(feature_matrix);  
    distance_matrix=zeros(row_num,row_num);  %这里可区分此时求的是Lnc还是disease的距离
    for i=1:row_num
        for j=i+1:row_num
            distance_matrix(i,j)=sqrt(sum((feature_matrix(i,:)-feature_matrix(j,:)).^2)); %欧氏距离，假如是Lnc刚好算每一个lnc与另外的距离
            distance_matrix(j,i)=distance_matrix(i,j);  
        end
        distance_matrix(i,i)=col_num;
    end
end

function nearst_neighbor_matrix=calculate_neighbors(distance_matrix,neighbor_num)%% calculate the nearest K neighbors
  [sv,si]=sort(distance_matrix,2,'ascend'); %升序，sv为排序出来的结果，si为序号index，dim=2时为横向排列，即把distance矩阵的每行按升序排列
  [row_num,col_num]=size(distance_matrix);
  nearst_neighbor_matrix=zeros(row_num,col_num);
  index=si(:,1:neighbor_num);
  for i=1:row_num
       nearst_neighbor_matrix(i,index(i,:))=1; %令所选取的邻居序号等于1
  end
end
