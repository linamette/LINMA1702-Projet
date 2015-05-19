function [fval,x,f,A,b,Aeq,beqvrai]= demandeq3( donnees ,epsilon)

if nargin <2
    epsilon = 0;
end
%parametre d'optimisation
semaine = 15;
d_t = donnees.demande;
c_m = donnees.cout_materiaux;
c_s = donnees.cout_stockage;
d_a = donnees.duree_assemblage/60;
n_o = donnees.nb_ouvriers;
c_h = donnees.cout_horaire;
n_h = 35;
c_r = donnees.cout_retard;
c_hs= donnees.cout_heure_sup;
n_hs= donnees.nb_max_heure_sup;
c_st= donnees.cout_sous_traitant;
s_i = donnees.stock_initial;
n_max_st = donnees.nb_max_sous_traitant;
c_e = donnees.cout_embauche;
c_l = donnees.cout_licenciement;
nb_o = donnees.nb_max_ouvriers;
delta = donnees.delta_demande;
d_t = d_t + epsilon * delta;
n_max =  n_h * n_o / d_a;
nhs_max = n_hs * n_o /d_a;


%Les variables sont dans l'ordre: n_t,nhs_t,ns_t,s_0,s_t,r_t
%cr�ation de f � optimiser
f=zeros(5*semaine+1,1);
for i=1:semaine
   f(i,1)=c_m; 
end

for i=semaine+1:2*semaine
   f(i,1)=c_m + d_a  * c_hs;
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


%Contraintes telles que Ax <= b

%cr�ation de la matrice A
A=zeros(9*semaine,5*semaine+1);
for i=1:semaine-1 %r^(t+1) <= d_t(i)

  A(i, i+4*semaine+2)= 1;
end 


count=1;
for i=semaine : 4*semaine-1 % contrainte n_t <= n_max + nhs_t <= nhs_max + nst <= n_max_st
    A(i,count)=1;
    count = count + 1; 
end 

count=1;
for i=4*semaine:9*semaine %toutes les variables sont positives
   A(i,count)=-1;
   count = count +1;
end


%cr�ation de la matrice b
b=zeros(9*semaine,1);
for i=1:semaine-1 %r^(t+1) <= d_t(i)
  b(i)=d_t(i);
end
for i=semaine:(2*semaine-1) %n_t <= n_max 
    b(i)= n_max;
   
end

for i =2*semaine: 3*semaine-1 %nst <= n_max_st
    b(i)= nhs_max; 
end

for i=3*semaine:4*semaine-1 %les variables doivent �tre positives
 b(i)=n_max_st;
end

%Contraintes telles Aeq *x =beq.'



Aeq=zeros(semaine+3,5*semaine+1);
for i=1:semaine-1  %n_t + nhs_t +ns_t + s_t-1 - s_t -r_t +r_t+1 = d_t(i)
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

Aeq(semaine+1,3*semaine+1)=1; %s_0 = s_i
Aeq(semaine+2,4*semaine+1)=1; %s_t = s_i
Aeq(semaine+3,4*semaine+2)=1; %r_1 = 0

beq = zeros(1,semaine+3); %n_t + nhs_t +ns_t + s_t-1 - s_t -r_t +r_t+1 = d_t(i)
for i=1:semaine
   beq(i)=d_t(i); 
end
for i=semaine+1:semaine+2 %s_0 = s_i + s_t = s_i
   beq(i)=s_i; 
end
for i=semaine+3:semaine+3 %r_1 = 0
   beq(i)=0; 
end

beqvrai=beq.'

options=optimoptions(@linprog,'Algorithm','dual-simplex');
[x,fval,exiflag, output, lambda]=linprog(transpose(f),A,b,Aeq,beq.',[],[],[],options);
fval=fval+c_h*n_o*semaine*35; %fval renvoie le cout r�el, on ajoute une constante
                              %qui repr�sente les salaires de tous les
                              %employes sur la dur�e d�sir�e



end




