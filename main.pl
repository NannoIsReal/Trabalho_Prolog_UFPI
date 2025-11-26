% Esta diretiva carrega os arquivos assim que o main.pl é lido
:- ['fatos.pl', 'regras.pl'].

% Teste 
:- initialization(iniciar, main).

iniciar :-
    writeln('Ola mundo').