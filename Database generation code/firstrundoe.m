%First Run this code to design LHS
%in this code the DOE is performed
 exp_s= 600; % total number of experiments
 n=10; %total parameters
 experiments_sample = zeros(exp_s,n);
 beta_angle=[61.70010608	50.66341106	39.62671604	28.59002102	58.999756...
     47.66649802	36.33324005	24.99998207	56.19999773	44.77667079	33.35334384	21.9300169...
     52.89999001	41.45332459	30.00665917	18.55999375	46.29997458	35.89998846	25.50000233	15.10001621];

experiments_sample(:,1:8) = (0.9 + 0.2*lhsdesign(exp_s,8)); % 10% im both dirn is allowed
experiments_sample(:,9:end) = (1.1+0.9*lhsdesign(exp_s,2));
% for i=1:exp_s
%     for j=1:5
%         if rand()<=0.5
%             chng =1;
%         else
%             chng =-1;
%         end
%         experiments_sample(i,32+j)= chng + experiments_sample(i,32+j);
%     end
% end
 csvwrite('lhs.csv',experiments_sample,0);