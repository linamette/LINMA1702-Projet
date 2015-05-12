function [x]= demande( semaine )

%variables
n_t=0;
nhs_t=0;
nst_t=0;
s_t=0;
r_t=0;
%parametre d'optimisation
d_t= 200;
c_m = 75;
c_s = 10;
d_a = 60;
n_o = 60;
c_h = 20;
n_h = 35;
c_r = 10;
c_hs= 40;
n_hs= 5;
c_st= 150;
s_i = 500;
n_max = 60 * n_h * n_o / d_a;
nhs_max = 60 * n_hs * n_o /d_a;
%création de f à optimiser
f=zeros(5*semaine+1,1);
for i=1:semaine
   f(i,1)=c_m; 
end

for i=semaine+1:2*semaine
   f(i,1)=c_m + d_a / 60 * c_hs;
end

for i=2*semaine+1: 3*semaine
    f(i,1)=c_st;
end

for i=3*semaine+2:4*semaine+1
   f(i,1)=c_s; 
end

for i=4*semaine+2:5*semaine+1
   f(i,1)=c_r; 
end
f
%Contraintes telles que Ax <= b
%création de la matrice A
A=zeros(10*semaine+7,5*semaine+1);
for i=1:semaine
   A(i ,i)=1;
   A(i, i+semaine)=1;
   A(i, i+2*semaine)=1;
   A(i, i+3*semaine)=1;
   A(i, i+3*semaine+1)=-1;
   A(i, i+4*semaine+1)=-1;
  % A(i, i+4*semaine+2)= 1;
end
count=1;
for i=semaine+1:2*semaine
   A(i ,count)=            -1;
   A(i, count+semaine)=    -1;
   A(i, count+2*semaine)=  -1;
   A(i, count+3*semaine)=  -1;
   A(i, count+3*semaine+1)= 1;
   A(i, count+4*semaine+1)= 1;
  % A(i, count+4*semaine+2)=-1;
   count = count + 1;
end
count=1;
for i=2*semaine+1: 3*semaine
   A(i ,count)=            -1;
   A(i, count+semaine)=    -1;
   A(i, count+2*semaine)=  -1;
   A(i, count+3*semaine)=  -1;
   A(i, count+3*semaine+1)= 1;
   A(i, count+4*semaine+1)= 1;
   count+1;
end
count=1;
for i=3*semaine+1 : 4*semaine
    A(i,count)=1;
    count = count + semaine ;
end

count=2;
for i=4*semaine+1 : 5*semaine
    A(i,count)=1;
    count = count + semaine ;
end

A(5*semaine+1,3*semaine+1)=1;
A(5*semaine+2,3*semaine+1)=-1;
A(5*semaine+3,4*semaine+1)=1;
A(5*semaine+4,4*semaine+1)=-1;
A(5*semaine+5,4*semaine+2)=1;
A(5*semaine+6,4*semaine+2)=-1;
count=1;
for i=5*semaine+7:10*semaine+7
   A(i,count)=-1;
   count = count +1;
end




%création de la matrice b
b=zeros(10*semaine+7,1);
pointeur=0;
for i=1:2*semaine
   b(i)=d_t;
   pointeur = pointeur +1;
end
for i=3*semaine+1:(4*semaine) 
    b(i)= n_max;
    pointeur = pointeur +1 ;
end

for i =4*semaine+1: 5*semaine
    b(i)= nhs_max; 
end
b(5*semaine+1) = s_i;
b(5*semaine+2) = s_i;
b(5*semaine+3) = s_i;
b(5*semaine+4) = s_i;
b;
x=linprog(f,A,b);

end




