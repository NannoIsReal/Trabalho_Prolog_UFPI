% 2) Regras

sintoma_equivalente(S1, S2) :-
    (subconjunto_sintomas(S1, S2);
    subconjunto_sintomas(S2, S1)).

% --- Calculo da probabilidade
calcular_score(P, Class, Int, Freq, Score):-
    peso_classificacao(Class, PClass),
    multiplicador_intensidade(Int, PInt),
    multiplicador_frequencia(Freq, PFreq),
    Valor is (P * PClass * PInt * PFreq),
    Score is round(Valor*100)/100.

% --- Calcular score sintoma
calcular_score_sintoma(Doenca, Sintoma, Score) :-
    (
        sintoma(Doenca, Sintoma, intensidade(Int), prob(P), _, frequencia(Freq), Class);   
        (
            sintoma_equivalente(Sintoma, Equiv),
            sintoma(Doenca, Equiv, intensidade(Int), prob(P), _, frequencia(Freq), Class)
        )
    ),
    calcular_score(P, Class, Int, Freq, Score).


% --- Diagnostico
% sintoma(pneumonia, hemoptise, intensidade(moderada), prob(0.3), duracao(dias), frequencia(raro), comum).
diagnosticar_doenca([],_).
diagnosticar_doenca([Sintoma|_], _) :-
    (
        sintoma(Doenca,Sintoma,_,_,_,_,_);
        (
            sintoma_equivalente(Sintoma, Equiv),
            sintoma(Doenca,Equiv,_,_,_,_,_)
        )
    ),
    calcular_score_sintoma(Doenca, Sintoma, Score),
    write('Doenca: '), write(Doenca),
    write(' - Probabilidade: '), write(Score), nl,
    fail.

%explicar

explicar(_,[],[]).

% caso em que lista final vazia diz nenhum sintoma compativel
explicar(Doenca, Sintomas, []) :-
    Sintomas \= [],
    \+ (explicar(Doenca, Sintomas, [_|_])),
    writeln('Nenhum sintoma compativel encontrado.').
explicar(Doenca,[Sintomas|Resto],[Exp|RestoExp]):-
    calcular_score_sintoma(Doenca,Sintomas,Score),
    (
        sintoma(Doenca, Sintomas, intensidade(Int), prob(P), _, frequencia(Freq), Class);
        (
            subconjunto_sintomas(Sintomas, SintomaEquivalente),
            sintoma(Doenca, SintomaEquivalente, intensidade(Int), prob(P), _, frequencia(Freq), Class)
        )
    ),

    Exp = (Sintomas, prob=P, class=Class, int=Int, freq=Freq, score=Score),
    explicar(Doenca,Resto,RestoExp).
explicar(Doenca, [_ | Resto], RestoExplicacao) :-
    % SintomaIrrelevante é ignorado e a recursão continua
    explicar(Doenca, Resto, RestoExplicacao).
% Caso especial: lista final vazia
explicar_sem_resultado(Doenca, Sintomas) :-
    explicar(Doenca, Sintomas, []),
    writeln('Nenhum sintoma compatível encontrado.').


%quais doenças possuem

quais_doencas_possuem(_,[],[]).
quais_doencas_possuem(Sintoma,[Doenca|Resto],[Doenca|Resto2]):-
    (
        sintoma(Doenca,Sintoma,_,_,_,_,_);
        (
            sintoma_equivalente(Sintoma,SintomaEquivalente),
            sintoma(Doenca,SintomaEquivalente,_,_,_,_,_)
        )
    ),
    quais_doencas_possuem(Sintoma,Resto,Resto2).
%caso o sintoma nao esteja presente, ignore
quais_doencas_possuem(Sintoma, [_|Resto], Lista) :-
    quais_doencas_possuem(Sintoma, Resto, Lista).

% imprimir sintomas de uma doenca
listar_sintomas(Doenca, Sintoma) :-
    sintoma(Doenca, Sintoma, _, _, _, _, _),
    write('Sintoma: '), writeln(Sintoma),
    fail.


%score total
scoreTotal(_, [], 0).
scoreTotal(Doenca,[Sintomas|Resto],ScoreTotal):-
    calcular_score_sintoma(Doenca,Sintomas,Score1),
    scoreTotal(Doenca,Resto,Score2),
    ScoreTotal is Score1 + Score2.

%gerar Scores
gerarScores(_, [], []).
gerarScores(Sintomas, [Doenca|DoencasResto], [ScoreIncio|ScoresResto]) :-
    scoreTotal(Doenca, Sintomas, Score),
    ScoreIncio = (Doenca,Score),
    gerarScores(Sintomas, DoencasResto, ScoresResto).

%maior elemento
maiorElemento([X], X, []).
maiorElemento([(Do1,Score1)|Resto], Maior, [(Do1,Score1)|RestoSemMaior]) :-
    maiorElemento(Resto, MaiorResto, RestoSemMaior),
    MaiorResto = (_, ScoreResto),
    ScoreResto > Score1,
    Maior = MaiorResto.
maiorElemento([(Do1,Score1)|Resto], (Do1,Score1), [(DoMaior,ScoreMaior)|RestoSemMaior]) :-
    maiorElemento(Resto, (DoMaior,ScoreMaior), RestoSemMaior),
    Score1 >= ScoreMaior.

%ordenação
ordenar([],[]).
ordenar([Lista|Resto],[ListaOrdenada|RestoOrdenado]):-
    maiorElemento([Lista|Resto],Maior,RestoSemMaior),
    ListaOrdenada = Maior,
    ordenar(RestoSemMaior,RestoOrdenado).

%ranking
ranking(_, []).
ranking([Sintomas|SintomasResto], [Ranking|RankingResto]):-
    sintoma(Sintomas,D)


% listar todas as doenças
% gerar lista de scores
% ordenar
% retornar
