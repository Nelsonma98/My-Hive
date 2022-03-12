:-[
    './Logica.pl',
    './Utiles.pl'
].

:- dynamic [fichas_ia/5,punt_inicial/1, best/1, posI/6, posF/6].

mov_ia(Xi,Yi,Xf,Yf,Ef,Idf):-
    revision(),
    posI(Xi,Yi,_,_,_,_),
    fichas_ia(Xi,Yi,E,M,K),
    posF(Xf,Yf,Ef,_,_,Idf),
    retractall(fichas_ia(Xi,Yi,E,M,K)),
    asserta(fichas_ia(Xf,Yf,E,0,K)).


revision():-
    limpia(),
    calcula_punt(PuntI),
    asserta(punt_inicial(PuntI)),
    revisa_fichas(1).


revisa_fichas(12):-!.
revisa_fichas(K):-
    fichas_ia(X,Y,E,M,K),
    M =:= 1,
    insertar(n,Pos),
    rev_ins(Pos,X,Y,E).
revisa_fichas(K):-
    fichas_ia(X,Y,E,_,K),
    revisa(X,Y,E),
    NewK is (K+1),
    revisa_fichas(NewK).


revisa(X,Y,E):-
    puede_mov(X,Y,E,R),
    R =:= 1,!.
revisa(X,Y,E):-
    clasif_mov_ia(X,Y,E,Pos),
    rev_pos(Pos,X,Y,E).

rev_pos([],_,_,_):-!.
rev_pos([[X,Y]|Pos],Xf,Yf,E):-
    tablero(Xf,Yf,E,n,N,Id),
    retractall(tablero(Xf,Yf,E,n,N,Id)),
    calcula_nivel(X,Y,Niv),
    NewN is (Niv+1),
    asserta(tablero(X,Y,E,n,NewN,Id)),
    tablero(Xb,Yb,r,b,_,_),
    cant_ady(Xb,Yb,CntB),
    retractall(tablero(X,Y,E,n,NewN,Id)),
    retractall(tablero(Xf,Yf,E,n,N,Id)),
    asserta(tablero(Xf,Yf,E,n,N,Id)),
    CntB =:= 6,
    actualiza_best([Xf,Yf,E,N,Id],[X,Y,E,NewN,Id],100),
    retractall(punt_inicial(_)),
    asserta(punt_inicial(100)),
    rev_pos(Pos,Xf,Yf,E),!.
rev_pos([[X,Y]|Pos],Xf,Yf,E):-
    tablero(Xf,Yf,E,n,N,Id),
    retractall(tablero(Xf,Yf,E,n,N,Id)),
    calcula_nivel(X,Y,Niv),
    NewN is (Niv+1),
    asserta(tablero(X,Y,E,n,NewN,Id)),
    calcula_punt(Punt),
    retractall(tablero(X,Y,E,n,NewN,Id)),
    retractall(tablero(Xf,Yf,E,n,N,Id)),
    asserta(tablero(Xf,Yf,E,n,N,Id)),
    punt_inicial(PuntI),
    Punt > PuntI,
    actualiza_best([Xf,Yf,E,N,Id],[X,Y,E,NewN,Id],Punt),
    retractall(punt_inicial(_)),
    asserta(punt_inicial(Punt)),
    rev_pos(Pos,Xf,Yf,E),!.
rev_pos([_|Pos],Xf,Yf,E):-
    rev_pos(Pos,Xf,Yf,E).

rev_ins([],_,_,_):-!.
rev_ins([[X,Y]|Pos],Xf,Yf,E):-
    ultimo_id(UId),
    Id is (UId+1),
    asserta(tablero(X,Y,E,n,1,Id)),
    calcula_punt(Punt),
    retractall(tablero(X,Y,E,n,1,Id)),
    best(PuntI),
    Punt > PuntI,
    actualiza_best([Xf,Yf,E,0,0],[X,Y,E,1,Id],Punt),
    rev_ins(Pos,Xf,Yf,E),!.
rev_ins([_|Pos],Xf,Yf,E):-
    rev_ins(Pos,Xf,Yf,E).

puede_mov(X,Y,E,1):-
    tablero(X,Y,_,_,_,Id),
    tablero(X,Y,E,n,_,Id2),
    not(Id =:= Id2),!.
puede_mov(X,Y,E,1):-
    tablero(X,Y,E,n,N,Id),
    not(valido_quit(X,Y,E,n,N,Id)),!.
puede_mov(_,_,_,0).

% REVIAS LA CANTIDAD DE ADYACENTES DE (X,Y)===
cant_ady(X,Y,C):-
    adyacentes([X,Y],Ady),
    cuenta_ady(Ady,0,C),!.

cuenta_ady([],R,R):-!.
cuenta_ady([[X,Y]|A],C,R):-
    tablero(X,Y,_,_,_,_),
    NewC is (C+1),
    cuenta_ady(A,NewC,R),!.
cuenta_ady([_|A],C,R):-
    cuenta_ady(A,C,R).

calcula_punt(PuntI):-
    tablero(Xb,Yb,r,b,_,_),
    cant_ady(Xb,Yb,Cb),
    tablero(Xn,Yn,r,n,_,_),
    cant_ady(Xn,Yn,Cn),
    PuntI is (Cb-Cn).
calcula_punt(PuntI):-
    tablero(Xn,Yn,r,n,_,_),
    cant_ady(Xn,Yn,Cn),
    PuntI is (0-Cn),!.
calcula_punt(0).

%=============================================

limpia():-
    retractall(best(_)),
    retractall(posI(_,_,_,_,_,_)),
    retractall(posF(_,_,_,_,_,_)),
    retractall(punt_inicial(_)),
    asserta(best(-7)).

actualiza_best([Xi,Yi,Ei,Ni,Idi|_],[Xf,Yf,Ef,Nf,Idf|_],Punt):-
    retractall(best(_)),
    asserta(best(Punt)),
    retractall(posI(_,_,_,_,_,_)),
    asserta(posI(Xi,Yi,Ei,n,Ni,Idi)),
    retractall(posF(_,_,_,_,_,_)),
    asserta(posF(Xf,Yf,Ef,n,Nf,Idf)).

clasif_mov_ia(Cx,Cy,r,Pos):-
    mov_reina(Cx,Cy,Pos),!.
clasif_mov_ia(Cx,Cy,h,Pos):-
    mov_hormiga(Cx,Cy,Pos),!.
clasif_mov_ia(Cx,Cy,e,Pos):-
    mov_escar(Cx,Cy,Pos),!.
clasif_mov_ia(Cx,Cy,s,Pos):-
    mov_saltam(Cx,Cy,[1,2,3,4,5,6],[],Pos),!.
clasif_mov_ia(Cx,Cy,a,Pos):-
    mov_aranna(Cx,Cy,Pos).

calcula_nivel(X,Y,R):-
    tablero(X,Y,_,_,N,_),
    R is N,!.
calcula_nivel(_,_,0).