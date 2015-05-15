function [ fvals ] = modif_delta_demande(donnees)
%Execute demande.m avec different epsilon et enregistre les couts dans un
%vecteur



%On refait le calcul depuis le debut avec un epsilon
fvals=zeros(10,1);
i=1;
for epsilon=0:.1:1
    fvals(i)=demande(donnees, epsilon);
    i=i+1;
end

%faire un plot ici

end

