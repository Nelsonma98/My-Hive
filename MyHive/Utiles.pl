contenida([],_):- fail,!.
contenida([X],X):-!.
contenida([X|_],X):-!.
contenida([_|Y],X):- contenida(Y,X).

anhadir_fin(X,[],[X]):-!.
anhadir_fin(X,[Y|YS],[Y|Z]):- anhadir_fin(X,YS,Z).

add_ady([],X,_,X):- !.
add_ady([X|XS],Y,Vis,Z):- contenida(Vis,X), add_ady(XS,Y,Vis,Z),!.
add_ady([X|XS],Y,Vis,Z):- contenida(Y,X), add_ady(XS,Y,Vis,Z),!.
add_ady([X|XS],Y,Vis,Z):-anhadir_fin(X,Y,R), add_ady(XS,R,Vis,Z).

add_adyA([],X,_,_,X):- !.
add_adyA([X|XS],Y,Vis,Bord,Z):- contenida(Vis,X), add_adyA(XS,Y,Vis,Bord,Z),!.
add_adyA([X|XS],Y,Vis,Bord,Z):- contenida(Y,X), add_adyA(XS,Y,Vis,Bord,Z),!.
add_adyA([X|XS],Y,Vis,Bord,Z):- not(contenida(Bord,X)), add_adyA(XS,Y,Vis,Bord,Z),!.
add_adyA([X|XS],Y,Vis,Bord,Z):-anhadir_fin(X,Y,R), add_adyA(XS,R,Vis,Bord,Z).

union([],R,R):-!.
union([X|XS],Y,R):-contenida(Y,X),union(XS,Y,R),!.
union([X|XS],Y,R):-union(XS,[X|Y],R).

adyacentes([X,Y], Ady):- X1 is X+2, X2 is X+1, Y2 is Y+1, X3 is X-1, Y3 is Y+1, X4 is X-2, X5 is X-1, Y5 is Y-1, X6 is X+1, Y6 is Y-1, Ady = [[X1, Y], [X2, Y2], [X3, Y3], [X4, Y], [X5, Y5], [X6, Y6]].