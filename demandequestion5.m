function []= demande( donnees,temps )


%parametre d'optimisation
semaine = temps;
d_t = donnees.demande;
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
%f
%Contraintes telles que Ax <= b
%création de la matrice A
A=zeros(8*semaine+1,5*semaine+1);
for i=1:semaine
   A(i ,i)=-1;
   A(i, i+semaine)=-1;
   A(i, i+2*semaine)=-1;
   A(i, i+3*semaine)=-1;
   A(i, i+3*semaine+1)=1;
   A(i, i+4*semaine+1)=1;
  % A(i, i+4*semaine+2)= 1;
end %premiere contrainte

%for i=semaine+1:2*semaine
 %  A(i ,count)=            -1;
  % A(i, count+semaine)=    -1;
  % A(i, count+2*semaine)=  -1;
  % A(i, count+3*semaine)=  -1;
  % A(i, count+3*semaine+1)= 1;
  % A(i, count+4*semaine+1)= 1;
  % A(i, count+4*semaine+2)=-1;
   %count = count + 1;
%end 

% for i=semaine: semaine %2eme
%    A(i ,count)=            -1;
%    A(i, count+semaine)=    -1;
%    A(i, count+2*semaine)=  -1;
%    A(i, count+3*semaine)=  -1;
%    A(i, count+3*semaine+1)= 1;
%    A(i, count+4*semaine+1)= 1;
%    count+1;
% end 

count=1;
for i=semaine+1 : 2*semaine %3eme contrainte n_t <= n_max
    A(i,count)=1;
    count = count + 1; 
end 

count=semaine+1;
for i=2*semaine+1 : 3*semaine %4eme
    A(i,count)=1;
    count = count + 1; ;
end 

count=1;
for i=3*semaine+1:8*semaine+1 %8eme condition
   A(i,count)=-1;
   count = count +1;
end
%A
%size(A)


%création de la matrice b
b=zeros(8*semaine+1,1);
%for i=1:2*semaine %premiere contrainte
 %  b(i)=d_t;
%end
for i=semaine+1:(2*semaine) %2eme
    b(i)= n_max;
   
end

for i =2*semaine+1: 3*semaine %3eme contrainte
    b(i)= nhs_max; 
end
%b(5*semaine+1) = s_i;
%b(5*semaine+2) = s_i;
%b(5*semaine+3) = s_i;
%b(5*semaine+4) = s_i;
%b
%size(A)
%size(f)
%size(transpose(f))
%size(b)


beq = zeros(1,semaine+3);
for i=1:semaine
   beq(i)=d_t(i); 
end
for i=semaine+1:semaine+2
   beq(i)=s_i; 
end
for i=semaine+3:semaine+3
   beq(i)=0; 
end

Aeq=zeros(semaine+3,5*semaine+1);
for i=1:semaine-1
   Aeq(i ,i)=1;
   Aeq(i, i+semaine)=1;
   Aeq(i, i+2*semaine)=1;
   Aeq(i, i+3*semaine)=1;
   Aeq(i, i+3*semaine+1)=-1;
   Aeq(i, i+4*semaine+1)=-1;
   Aeq(i, i+4*semaine+2)=1;
end %premiere contrainte pour les semaines sauf la derniere

for i=semaine:semaine
   Aeq(i ,i)=1;
   Aeq(i, i+semaine)=1;
   Aeq(i, i+2*semaine)=1;
   Aeq(i, i+3*semaine)=1;
   Aeq(i, i+3*semaine+1)=-1;
   Aeq(i, i+4*semaine+1)=-1;
  
end %premiere contrainte pour la derniere semaine

Aeq(semaine+1,3*semaine+1)=1;
Aeq(semaine+2,4*semaine+1)=1;
Aeq(semaine+3,4*semaine+2)=1;
options=optimoptions(@linprog,'Algorithm','dual-simplex');
[x,fval,exiflag, output, lambda]=linprog(transpose(f),A,b,Aeq,beq.',[],[],[],options);
% for i=1:semaine
%     
% fprintf('Le nombre de smartphone à produire en semaine %d est de %d, via heures supplémentaires %d, autre chose %d\n',i ,x(i), x(i+semaine),x(i+2*semaine));
% end
%fprintf('Le cout de la construction sur %d semaines est de %d \n',temps,f.'* x)

end




