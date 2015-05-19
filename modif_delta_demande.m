function [fval1,fvals  ] = modif_delta_demande(donnees,show)
%R�pond � la question 5
%Renvoie les valeurs des couts de la fonction objectif selon un certain
%delta_demande * epsilon de deux mani�res diff�rentes: via le dual et en
%r�solvant compl�tement le probl�me
%
%@pre: -donnees: la strucutre des donnees
%      -show: si diff�rent de 0 affiche les valeurs des fonctions objectifs
%      et un grpahique des diff�rences normalis�es
%
%@post: -fval1:le vecteur des fonctions objectifs en utilisant le dual
%       -fvals:le vecteur des fonctions objectifs en reformulant le
%       probl�me

if nargin <2
    show=0;
end

%On effectue le primal puis le dual. On obtiens x* et y*. Puis on modifie
%la valeur de la fonction objectif en fonction de epsilon
[fval,xOriginal,f,Aeq,beq] = demandeq5(donnees,0,0);
options=optimoptions(@linprog,'Algorithm','dual-simplex');
y =linprog(-transpose(beq),transpose(Aeq),f,[],[],[],[],[],options);


fval1=zeros(11,1);
i=1;
for epsilon=0:.1:1
    b_deltab=transpose([donnees.delta_demande ,zeros(1,5*donnees.T+2-15)]) * epsilon;
    fval1(i)=fval + y.' * b_deltab;
    i=i+1;
end

%On refait le calcul depuis le debut avec un epsilon
fvals=zeros(11,1);
i=1;
for epsilon=0:.1:1
    fvals(i)=demandeq5(donnees, epsilon,0);
    i=i+1;
end

if show ~= 0
    for j=1:11
        fprintf('Le r�sultat pour un epsilon de %1.1f ' , j/10-0.1);
        fprintf('est avec le dual %d ' ,fval1(j));
        fprintf('et en refaisant tout on a %d. ',fvals(j));
        fprintf('Cela fait une diff�nce de %d.\n', fval1(j)-fvals(j));
    end
    diff=fval1-fvals;
    figure();
    plot([0:.1:1],diff./fvals *100);
    title('Diff�rence normalis�e en poucentage entre la m�thode du dual et le probl�me auxilaire en fonction de epsilon');
    xlabel('Epsilon');
    ylabel('Diff�rence normalis�e en pourcentage par rapport � fvals');
end

end

