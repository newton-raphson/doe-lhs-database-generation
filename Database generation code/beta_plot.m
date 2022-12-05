function beta_plot(loop_index, beta_array)
%s=[0,33.3333333333333,66.6666666666667,100,0,33.3333333333333,66.6666666666667,100,0,33.3333333333333,66.6666666666667,100,0,33.3333333333333,66.6666666666667,100,0,33.3333333333333,66.6666666666667,100;...
 % 50,34.8253306559452,29,12.5993686702660,51.6750693749525,40.5637552459187,29.4491073892734,18.3377932602395,55.7164595183821,44.6051453893482,33.4904975327029,22.3791834036691,59.0488199032925,47.9375057742586,36.8228579176133,25.7115437885795,62.6601552177085,51.5488410886747,40.4341932320293,29.3228791029955];
%rang = ['red';'green';'blue';'cyan';'magenta'];
s=beta_array;
for i=1:5
n=4;
n1=n-1;
if i==1;
    m=1;
end
if i==2;
    m=5;
end
if i==3;
    m=9;
end
if i==4;
    m=13;
end
if i==5;
    m=17;
end
[p]=s(:,m:m+3)';
for j=0:1:n1
    coeff(j+1)=factorial(n1)/(factorial(j)*factorial(n1-j));
end
J=[];
D=[];
for t=0:0.002:1
for d=1:n
    J(d)=coeff(d)*((t^(d-1))*((1-t)^(n-d)));
end
    D=cat(1,D,J);
end
B1=D*p;
hold on;
figure(loop_index)
if i==1
line(B1(:,1),B1(:,2),'color','r');
end
if i==2
line(B1(:,1),B1(:,2),'color','b');
end
if i==3
line(B1(:,1),B1(:,2),'color','g');
end
if i==4
line(B1(:,1),B1(:,2),'color','m');
end
if i==5
line(B1(:,1),B1(:,2),'color','c');
end

%line(B2(:,1),B2(:,2),'color','r');
%line(p(:,1),p(:,2))
%line(q(:,1),q(:,2))

end
xlabel('%M-PRIME');
ylabel('BETA ANGLE');
title(sprintf('Sample %d', loop_index));
legend ('layer 1','layer 2','layer 3','layer 4','layer 5');


baseFileName = sprintf('beta_compare%d.jpg', loop_index);
folder = 'D:\Kalpana101\betacomparision';
fullFileName = fullfile(folder, baseFileName);
saveas(figure(loop_index),fullFileName); %put varible for 1 if you want create different name 
hold off
close all;
end
