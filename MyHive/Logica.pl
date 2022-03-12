:-[
    './Utiles.pl'
].

:- dynamic [tablero/6,turno/1,ultimo_id/1].
/* tablero(posX,posY,especie,color,nivel,ID)
*/
ultimo_id(0).
turno(0).

direcciones(1, 1, -1).
direcciones(2, 2, 0).
direcciones(3, 1, 1).
direcciones(4, -1, 1).
direcciones(5, -2, 0).
direcciones(6, -1, -1).

dfs([],R,_,R):- !.
dfs([[X,Y|_]|XS],Cv,Vis,R):- 
    not(tablero(X,Y,_,_,_,_)), 
    dfs(XS,Cv,Vis,R), !.
dfs([[X,Y|_]|XS],Cv,Vis,R):-
    tablero(X,Y,_,_,Nv,_), 
    adyacentes([X,Y],Ady), 
    add_ady(Ady,XS,Vis,Ra),NC is Cv+Nv, 
    dfs(Ra,NC,[[X,Y]|Vis],R).

% VALIDO COLOCAR
tiene_vecino([]):- 
    fail,!.
tiene_vecino([[X,Y|_]|_]):- 
    tablero(X,Y,_,_,_,_),!.
tiene_vecino([_|XS]):- 
    tiene_vecino(XS).

% REVISION DE POSICIONES
revision_pos([],X,X):-!.
revision_pos([X|XS],R,Rf):- 
    adyacentes(X,Ady), 
    tiene_vecino(Ady), 
    revision_pos(XS,[X|R],Rf),!.
revision_pos([_|XS],R,Rf):- 
    revision_pos(XS,R,Rf).

%===================================INSERTAR FICHAS===================

insertar(_,[[0,0]]):-
    ultimo_id(N),
    N =:= 0,!.
insertar(_,R):-
    ultimo_id(N),
    N =:= 1,
    contorno(N,[],R),!.
insertar(b,R):-
    insertarB(R),!.
insertar(n,R):-
    insertarN(R).

insertarB(R):-
    ultimo_id(N),
    contorno(N,[],Cont),
    revisionB(Cont,[],R).

insertarN(R):-
    ultimo_id(N),
    contorno(N,[],Cont),
    revisionN(Cont,[],R).

revisionB([],X,X):-!.
revisionB([X|Bord],R,S):- 
    adyacentes(X,Ady),
    tiene_vecino_N(Ady,V),
    V =:= 0,
    revisionB(Bord,[X|R],S),!.
revisionB([_|Bord],R,S):-
    revisionB(Bord,R,S).

revisionN([],X,X):-!.
revisionN([X|Bord],R,S):-
    adyacentes(X,Ady),
    tiene_vecino_B(Ady,V),
    V =:= 0,
    revisionN(Bord,[X|R],S),!.
revisionN([_|Bord],R,S):-
    revisionN(Bord,R,S).

tiene_vecino_N([],X):- X is 0,!.
tiene_vecino_N([[X,Y|_]|_],R):-
    tablero(X,Y,_,n,_,_),
    R is 1,!.
tiene_vecino_N([_|XS],R):-
    tiene_vecino_N(XS,R).

tiene_vecino_B([],X):-X is 0,!.
tiene_vecino_B([[X,Y|_]|_],R):-
    tablero(X,Y,_,b,_,_),
    R is 1,!.
tiene_vecino_B([_|XS],R):-
    tiene_vecino_B(XS,R).

%===================================MOVIMIENTOS=======================

mov_fichas(X,Y,_,_,_,NewX,NewY):-
    tablero(X,Y,E,C,N,Id),
    tablero(NewX,NewY,_,_,Nn,_),
    retract(tablero(X,Y,E,C,N,Id)),
    NewN is Nn+1,
    asserta(tablero(NewX,NewY,E,C,NewN,Id)),
    turno(K),
    retract(turno(K)),
    asserta(turno(K+1)),!.
mov_fichas(X,Y,_,_,_,NewX,NewY):-
    tablero(X,Y,E,C,N,Id),
    retract(tablero(X,Y,E,C,N,Id)),
    asserta(tablero(NewX,NewY,E,C,N,Id)),
    turno(K),
    retract(turno(K)),
    asserta(turno(K+1)),!.
mov_fichas(_,_,E,C,Id,NewX,NewY):-
    asserta(tablero(NewX,NewY,E,C,1,Id)),
    retractall(ultimo_id(_)),
    asserta(ultimo_id(Id)),
    turno(K),
    retract(turno(K)),
    asserta(turno(K+1)).

% MOVIMIENTO DE LA REINA
mov_reina(X,Y,[]):- 
    tablero(X,Y,r,C,N,Id), 
    not(valido_quit(X,Y,r,C,N,Id)),!.
mov_reina(X,Y,RPos):- 
    adyacentes([X,Y],Ady), 
    pos_reina(Ady,[],Pos), 
    retract(tablero(X,Y,r,C,N,Id)),
    revision_pos(Pos,[],RPos),
    asserta(tablero(X,Y,r,C,N,Id)).

pos_reina([],X,X):- !.
pos_reina([[X,Y|_]|XS],R,Rf):- 
    tablero(X,Y,_,_,_,_), 
    pos_reina(XS,R,Rf), !.
pos_reina([[X,Y|_]|XS],R,Rf):- 
    pos_reina(XS,[[X,Y]|R],Rf).

% MOVIMIENTO DEL SALTAMONTES
% el 3er parametro es [1,2,3,4,5,6]
mov_saltam(X,Y,_,_,[]):- 
    tablero(X,Y,s,C,N,Id), 
    not(valido_quit(X,Y,s,C,N,Id)),!.
mov_saltam(_,_,[],R,R):- !.
mov_saltam(X,Y,[D|DS],R,Rf):- 
    pos_saltam(X,Y,D,0,R,Pos), 
    mov_saltam(X,Y,DS,Pos,Rf).

pos_saltam(X,Y,D,B,Pos,Pos):- 
    B =:= 0, 
    direcciones(D,DX,DY), 
    Nx is X+DX,
    Ny is Y+DY,
    not(tablero(Nx,Ny,_,_,_,_)),!.
pos_saltam(X,Y,D,B,Pos,R):- 
    B =:= 0, 
    direcciones(D,DX,DY),
    Nx is X+DX,
    Ny is Y+DY, 
    pos_saltam(Nx,Ny,D,1,Pos,R),!.
pos_saltam(X,Y,D,B,Pos,R):- 
    B =:= 1, 
    direcciones(D,DX,DY), 
    Nx is X+DX,
    Ny is Y+DY,
    not(tablero(Nx,Ny,_,_,_,_)), 
    pos_saltam(Nx,Ny,D,2,Pos,R),!.
pos_saltam(X,Y,D,B,Pos,R):- 
    B =:= 1, 
    direcciones(D,DX,DY), 
    Nx is X+DX,
    Ny is Y+DY,
    pos_saltam(Nx,Ny,D,1,Pos,R),!.
pos_saltam(X,Y,_,B,Pos,R):- 
    B =:= 2, 
    R = [[X,Y]|Pos].

% MOVIMIENTO DEL ESCARABAJO
mov_escar(X,Y,[]):- 
    tablero(X,Y,e,C,N,Id), 
    not(valido_quit(X,Y,e,C,N,Id)),!.
mov_escar(X,Y,RPos):- 
    adyacentes([X,Y],Pos), 
    tablero(X,Y,e,C,N,Id),
    retract(tablero(X,Y,e,C,N,Id)),
    revision_pos(Pos,[],RPos),
    asserta(tablero(X,Y,e,C,N,Id)).

% MOVIMIENTO DE LA HORMIGA
mov_hormiga(X,Y,[]):- 
    tablero(X,Y,h,C,N,Id), 
    not(valido_quit(X,Y,h,C,N,Id)),!.
mov_hormiga(X,Y,RPos):- 
    ultimo_id(K), 
    tablero(X,Y,h,C,N,Id),
    contorno(K,[],Bord),
    adyacentes([X,Y],Ady),
    dfsHormiga(Ady,Bord,[],Pos),
    retract(tablero(X,Y,h,C,N,Id)),
    revision_pos(Pos,[],RPos),
    asserta(tablero(X,Y,h,C,N,Id)).

dfsHormiga([],_,X,X):-!.
dfsHormiga([[X,Y|_]|XS],Bord,Vis,R):- 
    not(contenida(Bord,[X,Y])), 
    dfsHormiga(XS,Bord,Vis,R), !.
dfsHormiga([[X,Y|_]|XS],Bord,Vis,Rp):- 
    adyacentes([X,Y],Ady), 
    add_ady(Ady,XS,Vis,R), 
    dfsHormiga(R,Bord,[[X,Y]|Vis],Rp).

% MOVIMIENTO DE LA ARAÑA  
mov_aranna(X,Y,[]):- 
    tablero(X,Y,a,C,N,Id), 
    not(valido_quit(X,Y,a,C,N,Id)),!.
mov_aranna(X,Y,Pos):-
    ultimo_id(K),
    tablero(X,Y,a,C,N,Id),
    contorno(K,[],Bord),
    adyacentes([X,Y],Ady),
    dfsAranna(Ady,[],Bord,Ady,0,R),
    retract(tablero(X,Y,a,C,N,Id)),
    revision_pos(R,[],Pos),
    asserta(tablero(X,Y,a,C,N,Id)).

%El contador comienza en 0
dfsAranna(R,_,_,_,2,R):-!.
dfsAranna([],Pos,Bord,Vis,Cnt,Res):- 
    Cnt=:=0, 
    dfsAranna([],Pos,Bord,Vis,1,Res),!.
dfsAranna(Pos,[],Bord,Vis,Cnt,Res):- 
    Cnt=:=1, 
    dfsAranna(Pos,[],Bord,Vis,2,Res),!.
dfsAranna([A|PosA],PosB,Bord,Vis,Cnt,Res):- 
    Cnt=:=0,
    not(contenida(Bord,A)), 
    dfsAranna(PosA,PosB,Bord,Vis,Cnt,Res),!.
dfsAranna([A|PosA],PosB,Bord,Vis,Cnt,Res):- 
    Cnt=:=0, 
    adyacentes(A,Ady), 
    add_adyA(Ady,PosB,Vis,Bord,R), 
    union(R,Vis,NewV),
    dfsAranna(PosA,R,Bord,NewV,Cnt,Res),!.
dfsAranna(PosA,[B|PosB],Bord,Vis,Cnt,Res):- 
    Cnt=:=1, 
    not(contenida(Bord,B)), 
    dfsAranna(PosA,PosB,Bord,Vis,Cnt,Res),!.
dfsAranna(PosA,[B|PosB],Bord,Vis,Cnt,Res):- 
    Cnt=:=1, 
    adyacentes(B,Ady), 
    add_adyA(Ady,PosA,Vis,Bord,R),
    union(R,Vis,NewV),
    dfsAranna(R,PosB,Bord,NewV,Cnt,Res).

% CONTORNO DEL TABLERO   "el contador comienza en ultimo_id(N)"
contorno(Cnt,X,X):- 
    Cnt =:= 0,!.
contorno(Cnt,R,Nr):-
    tablero(X,Y,_,_,_,Cnt),
    adyacentes([X,Y],Ady), 
    add_bor(Ady,R,NewR),
    Ncont is Cnt-1,
    contorno(Ncont,NewR,Nr).

add_bor([],X,X):- !.
add_bor([[X,Y|_]|XS],A,R):- 
    tablero(X,Y,_,_,_,_), 
    add_bor(XS,A,R),!.
add_bor([X|XS],A,R):- 
    contenida(A,X), 
    add_bor(XS,A,R),!.
add_bor([[X,Y|_]|XS],A,R):- 
    add_bor(XS,[[X,Y]|A],R).

% ES VALIDO MOVER ESTA FICHA?
valido_quit(X,Y,E,C,N,Id):- retractall(tablero(X,Y,E,C,N,Id)),
                      tablero(Px,Py,_,_,_,_), 
                      dfs([[Px,Py]],1,[],Cv),
                      retractall(tablero(X,Y,E,C,N,Id)),
                      asserta(tablero(X,Y,E,C,N,Id)),
                      ultimo_id(Ct),
                      Cv =:= Ct.

% Verifica si algun jugador perdio.
pierdeN(1):- 
    tablero(X,Y,r,n,_,_), 
    adyacentes([X,Y],Ady),
    pos_reina(Ady,[],Pos), 
    length(Pos, Int), 
    Int =:= 0,!.
pierdeN(0).
pierdeB(1):- 
    tablero(X,Y,r,b,_,_), 
    adyacentes([X,Y],Ady),
    pos_reina(Ady,[],Pos), 
    length(Pos, Int), 
    Int =:= 0,!.
pierdeB(0).