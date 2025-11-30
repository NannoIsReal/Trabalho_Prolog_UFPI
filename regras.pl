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

% imprimir doencas e probabilidades
imprimir_resultado_diagnostico([]).
imprimir_resultado_diagnostico([(Doenca, Score) | Resto]) :-
    write('Doenca: '), write(Doenca),
    write(' - Probabilidade: '), write(Score), nl,
    imprimir_resultado_diagnostico(Resto).

%diagnosticar doenca
diagnosticar_doenca(Sintomas) :-
    todas_doencas(ListaDoencas),
    diagnosticar_lista(Sintomas, ListaDoencas, ListaScoresBruta),
    filtrar_scores_zerados(ListaScoresBruta, ListaScores),
    ordenar_por_score(ListaScores, ResultadoOrdenado),
    imprimir_resultado_diagnostico(ResultadoOrdenado).


% Verifica se um elemento ja esta na lista
ja_existe(_, []) :- fail.
ja_existe(X, [X|_]) :- !.
ja_existe(X, [_|Resto]) :- ja_existe(X, Resto).

% Inverter lista
inverter([], Acc, Acc).
inverter([H|T], Acc, Res) :- inverter(T, [H|Acc], Res).
inverter(L, R) :- inverter(L, [], R).

% Pegar lista de doencas
todas_doencas(Lista) :-
    coletar_doencas([], Acumulada),
    inverter(Acumulada, Lista).

% Acumulador de doencas
coletar_doencas(Ac, ListaFinal) :-
    (   sintoma(Doenca, _, _, _, _, _, _),
        \+ ja_existe(Doenca, Ac),
        !,
        coletar_doencas([Doenca|Ac], ListaFinal)
    ;   ListaFinal = Ac
    ).

% Diagnosticar lista de doencas
diagnosticar_lista(_, [], []).
diagnosticar_lista(Sintomas, [Doenca|Resto], [(Doenca,Score)|RestoScores]) :-
    calcular_score_doenca(Doenca, Sintomas, Score),
    diagnosticar_lista(Sintomas, Resto, RestoScores).

% Calcular score acumulado de uma doenca
calcular_score_doenca(_, [], 0).
calcular_score_doenca(Doenca, [S|Resto], TotalArredondado) :-
    (calcular_score_sintoma(Doenca, S, Score) -> true ; Score = 0),
    calcular_score_doenca(Doenca, Resto, Parcial),
    Soma is Score + Parcial,
    TotalArredondado is round(Soma*100)/100.

% Filtrar doencas com score 0
filtrar_scores_zerados([], []).
filtrar_scores_zerados([(D,S)|Resto], ListaFiltrada) :-
    (   S =:= 0
    ->  filtrar_scores_zerados(Resto, ListaFiltrada)
    ;   ListaFiltrada = [(D,S)|Resto2],
        filtrar_scores_zerados(Resto, Resto2)
    ).

% Ordenar por score
ordenar_por_score([], []).
ordenar_por_score([X|Xs], ListaOrdenada) :-
    ordenar_por_score(Xs, ListaParcial),
    inserir_ordenado(X, ListaParcial, ListaOrdenada).

inserir_ordenado((D,S), [], [(D,S)]).
inserir_ordenado((D,S), [(D1,S1)|Resto], [(D,S),(D1,S1)|Resto]) :-
    S >= S1,
    !.
inserir_ordenado((D,S), [(D1,S1)|Resto], [(D1,S1)|NovoResto]) :-
    inserir_ordenado((D,S), Resto, NovoResto).