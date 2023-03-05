traces = load('traces.mat');
%%
ydata=traces.tracesList(1,:);
xdata=0:size(ydata,2)-1;
figure
plot(xdata,ydata,'r');
grid()
ylabel('Fuites')
xlabel('temps')
title('Consommation mesurée n°1')

hold on
xline(360, "--b", "1er round")
xline(3510, "--b", "dernier round")
hold off

%%
%calcul de la moyenne des traces

moyenne = ones(1,4000);
for j = 1:20000
    moyenne = moyenne + traces.tracesList(j,:)/20000;
end

%%
plot(xdata, moyenne, 'r')
hold on
xline(921, "--g", "Initialisation du code VHDL (à ignorer)")
xline(1123, "--k", "Round initial")
rounds_t_nb = [1327, 1526, 1728, 1927, 2128, 2326, 2527, 2729, 2925];
for i = 1:9
   xline(rounds_t_nb(i), "--b", "Round n°" + num2str(i)) 
end
xline(3131, "--k", "Round final")
hold off

%%
dernier_round = 2800:3500;
moyenne_sur_dernier_round = moyenne(dernier_round);

%%
chiffres=load('cto.mat');
chiffres = cell2mat(chiffres.ctoList);
chiffres=reshape(chiffres,36,20000);
chiffres=chiffres(1:32,:);
Xchiffre=zeros(20000,16);
for k=1:20000
    for i=1:16
        Xchiffre(k,i)=hex2dec(chiffres(2*i-1:2*i));
    end
end

Z    = uint8(zeros(20000,256,16));
Z_xor= uint8(zeros(20000,256,16));
Z_sr = uint8(zeros(20000,256,16));
Z_sb = uint8(zeros(20000,256,16));
    
%%
for trace = 1:20000
    for hypothese = 1:256
        for valeur = 1:16
            Z(trace, hypothese, valeur) = uint8(Xchiffre(trace, valeur));
        end 
    end 
end

%%
% xor 
for trace = 1:20000
   for valeur = 1:16
       for hypothese = 1:256
           Z_xor(trace, hypothese, valeur) = uint8(bitxor(Z(trace, hypothese, valeur), uint8(hypothese-1))); 
       end
   end
end

%%
%shiftrow
shiftRowInv = [1, 14, 11, 8, 5, 2, 15, 12, 9, 6, 3, 16, 13, 10, 7, 4];
shiftrow = [1,6,11,16,5,10,15,4,9,14,3,8,13,2,7,12];


for trace = 1:20000
    for valeur = 1:16
       for hypothese = 1:256
           Z_sr(trace, hypothese, valeur) = Z_xor(trace, hypothese, shiftRowInv(valeur)); 
       end
   end
end

%%
% on remonte encore pour arriver au point d'attaque 
SBox=[99,124,119,123,242,107,111,197,48,1,103,43,254,215,171,118,202,130,201,125,250,89,71,240,173,212,162,175,156,164,114,192,183,253,147,38,54,63,247,204,52,165,229,241,113,216,49,21,4,199,35,195,24,150,5,154,7,18,128,226,235,39,178,117,9,131,44,26,27,110,90,160,82,59,214,179,41,227,47,132,83,209,0,237,32,252,177,91,106,203,190,57,74,76,88,207,208,239,170,251,67,77,51,133,69,249,2,127,80,60,159,168,81,163,64,143,146,157,56,245,188,182,218,33,16,255,243,210,205,12,19,236,95,151,68,23,196,167,126,61,100,93,25,115,96,129,79,220,34,42,144,136,70,238,184,20,222,94,11,219,224,50,58,10,73,6,36,92,194,211,172,98,145,149,228,121,231,200,55,109,141,213,78,169,108,86,244,234,101,122,174,8,186,120,37,46,28,166,180,198,232,221,116,31,75,189,139,138,112,62,181,102,72,3,246,14,97,53,87,185,134,193,29,158,225,248,152,17,105,217,142,148,155,30,135,233,206,85,40,223,140,161,137,13,191,230,66,104,65,153,45,15,176,84,187,22];
invSBox(SBox(1:256)+1)=0:255;


% on passe de 0-255 --> 1-256
%Z_sb = invSBox(Z_sr + 1);
for trace = 1:20000
    for valeur = 1:16
       for hypothese = 1:256
           Z_sb(trace, hypothese, valeur) = uint8(invSBox(Z_sr(trace, hypothese, valeur)+1)); 
       end
   end
end

%%

%% attaque par HW

% matrice de binaires

Weight_Hamming_vect = [0 1 1 2 1 2 2 3 1 2 2 3 2 3 3 4 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 4 5 5 6 5 6 6 7 5 6 6 7 6 7 7 8];
DH = uint8(zeros(20000,256,16));
for i = 1:256
    for k =1:16 
        DH(:,i,k) = bitxor(Z_sb(:,i,k), uint8(Xchiffre(:,k)));
    end 
end
Phi = Weight_Hamming_vect(DH+1);

fuites=traces.tracesList;

disp("Calcul des corrélations pour les sous-clés")
best_candidate = zeros(16, 1);
figure
sgtitle("Corrélation par méthode du poids de Hamming")
for k = 1:16
    A=double(Phi(1:20000,:, shiftrow(k)));
    B=double(fuites(1:20000, dernier_round));
    X=[A B];
    cor = corrcoef(X);
    cor=cor(257:957,257:957); 

    [RK, IK] = sort(max(abs(cor(:, :)), [], 2), 'descend'); 
    fprintf('%s %d %s %d \n','sous cle n°', k, ' : meilleur candidat : k=', IK(1) - 1)
    best_candidate(k)=IK(1)-1;

    subplot(4,4,k)
    plot(dernier_round, cor(:, :))
    title("k=" + num2str(k))
    xlabel('echantillon')
    ylabel('correlation')
end 

%% 
disp("Affichage de la clé à obtenir")
key = '4c8cdf23b5c906f79057ec7184193a67';
key_dec = zeros(16, 1);
for i = 1:16
    key_dec(i) = hex2dec(key((2*i)-1 : 2*i));
end

w = uint8(zeros(11, 4, 4));
w(1, :, :) = reshape(key_dec, 4, 4);

for i = 1:10
    w(i+1, :, :) = key_schu(squeeze(w(i, :, :)), i);
end
key_to_find = squeeze(w(11, :, :));
disp(key_to_find)


disp('best_candidate = ')
disp(reshape(best_candidate, 4, 4))
disp("Nombre de correspondances: ")
disp(sum(key_to_find == reshape(best_candidate, 4, 4)))
