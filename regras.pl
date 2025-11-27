% 2) Regras

sintoma_equivalente(S1, S2) :-
    subconjunto_sintomas(S1, S2).
sintoma_equivalente(S1, S2) :-
    subconjunto_sintomas(S2, S1).

% --- Peso por classificacao do sintoma
peso_classificacao(critico, 2.0).
peso_classificacao(comum, 1.0).
peso_classificacao(raro, 0.5).

% --- Multiplicador por intensidade
multiplicador_intensidade(leve, 0.8).
multiplicador_intensidade(moderada, 1.0).
multiplicador_intensidade(alta, 1.1).
multiplicador_intensidade(severa, 1.2).

% --- Multiplicador por frequencia
multiplicador_frequencia(continuo, 1.2).
multiplicador_frequencia(intermitente, 1.0).
multiplicador_frequencia(raro, 0.7).

% --- Calculo da probabilidade
 calcular_score(P, Class, Int, Freq, Score):-
    peso_classificacao(Class, PClass),
    multiplicador_intensidade(Int, PInt),
    multiplicador_frequencia(Freq, PFreq),
    Score is (P * PClass * PInt * PFreq).

% --- Calcular score sintoma
calcular_score_sintoma(Doenca, Sintoma, Score) :-
    (sintoma(Doenca, Sintoma, intensidade(Int), prob(P), _, frequencia(Freq), Class);   
    (sintoma_equivalente(Sintoma, Equiv),
    sintoma(Doenca, Equiv, intensidade(Int), prob(P), _, frequencia(Freq), Class))),
    calcular_score(P, Class, Int, Freq, Score).


% --- Diagnostico
% sintoma(pneumonia, hemoptise, intensidade(moderada), prob(0.3), duracao(dias), frequencia(raro), comum).
diagnosticar_doenca([],_).
diagnosticar_doenca([Sintoma|_], _) :-
    (sintoma(Doenca,Sintoma,_,_,_,_,_);
    (sintoma_equivalente(Sintoma, Equiv),
    sintoma(Doenca,Equiv,_,_,_,_,_))),
    calcular_score_sintoma(Doenca, Sintoma, Score),
    write('Doenca: '), write(Doenca),
    write(' - Probabilidade: '), write(Score), nl.