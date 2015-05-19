function [fval,x,f,Aeq,beqvrai]= demandeq5( donnees ,epsilon,show)
%
%Ne répond pas à la question 5 : résoud le problème donné
%transformé sous forme standard via linprog. Le nombre d ouvriers est
%constant.
%La réponse à la question 5 est via la fonction modif_delta_demande.
%@pre : -donnees: la structure nécessaire au problème
%       -la variation désirée
%       -show: si différent de 1 affiche un graphique de la solution pour
%       chaque semaine
%
%@post: fval: -la fonction cout
%             -le vecteur x, valeur des variables
%             -Aeq et beqvrai: la matrice telle que : Aeq * x =beqvrai
%
%
if nargin <2
    epsilon = 0;
end
if nargin <3
    show = 0;
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
%création de f à optimiser
f=zeros(9*semaine,1);
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

%création de la matrice A
A=zeros(9*semaine,9*semaine);



for i=1:9*semaine %toutes les variables sont positives
    A(i,i)=-1;
    
end


%création de la matrice b
b=zeros(9*semaine,1);


%Contraintes telles Aeq *x =beq.'



Aeq=zeros(5*semaine+2,9*semaine);
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

count = 4*semaine+2; %on début a r^(1)
for i=semaine+4:2*semaine+2 %r^(t+1) <= d_t(i)
    Aeq(i,count+1) = 1;
    Aeq(i, count+semaine)= 1;
    count = count +1;
end


count=1;
for i=2*semaine+3 : 5*semaine+2 % contrainte n_t <= n_max + nhs_t <= nhs_max + nst <= n_max_st
    Aeq(i,count)=1;
    Aeq(i,count+6*semaine) = 1;
    count = count + 1;
end


beq = zeros(1,5*semaine+2); %n_t + nhs_t +ns_t + s_t-1 - s_t -r_t +r_t+1 = d_t(i)
for i=1:semaine
    beq(i)=d_t(i);
end
for i=semaine+1:semaine+2 %s_0 = s_i + s_t = s_i
    beq(i)=s_i;
end
for i=semaine+3:semaine+3 %r_1 = 0
    beq(i)=0;
end
counti =semaine+3;
for i=1+counti:semaine-1+counti %r^(t+1) <= d_t(i)
    beq(i)=d_t(i-counti);
end
for i=semaine+counti:(2*semaine-1)+counti %n_t <= n_max
    beq(i)= n_max;
    
end

for i =2*semaine+counti: 3*semaine-1+counti %nst <= n_max_st
    beq(i)= nhs_max;
end

for i=3*semaine+counti:4*semaine-1+counti %les variables doivent être positives
    beq(i)=n_max_st;
end

beqvrai=beq.';

options=optimoptions(@linprog,'Algorithm','dual-simplex');
[x,fval,exiflag, output, lambda]=linprog(transpose(f),A,b,Aeq,beq.',[],[],[],options);
fval=fval+c_h*n_o*semaine*35; %fval renvoie le cout réel, on ajoute une constante
                                %qui représente les salaires de tous les
                                %employes sur la durée désirée


%Montre l'évolution des valeurs en fonction des semaines
if show ~=0
    figure();
    hold on;
    plot((1:1:15),d_t,'g');
    plot((1:1:15),x(1:semaine),'b');
    plot((1:1:15),x(semaine+1:2*semaine),'r');
    plot((1:1:15),x(2*semaine+1:3*semaine),'m');
    plot((1:1:15),x(3*semaine+2:4*semaine+1),'c');
    plot((1:1:15),x(4*semaine+2:5*semaine+1),'k');
    xlabel('semaine');
    title('Nombres de smartphones produits en fonctions des semaines pour une certaine demande');
    ylabel('nombres d unités produites');
    legend('demande','normal','heures supp','sous-traités','stockés','retardés');
    
    xlim([1 15]);
    hold off;
    
end


end




