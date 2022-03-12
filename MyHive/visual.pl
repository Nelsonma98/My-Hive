:- use_module(library(pce)).
:- pce_image_directory('./Fotos').

:-[
    './Logica.pl',
    './Utiles.pl',
    './IA.pl'
].

resource(rN, image, image('reinaN.jpg')).
resource(rB, image, image('reinaB.jpg')).
resource(aB, image, image('arannaB.jpg')).
resource(aN, image, image('arannaN.jpg')).
resource(empate, image, image('empate.jpg')).
resource(eB, image, image('escarabajoB.jpg')).
resource(eN, image, image('escarabajoN.jpg')).
resource(gana1, image, image('gana1.jpg')).
resource(gana2, image, image('gana2.jpg')).
resource(hB, image, image('hormigaB.jpg')).
resource(hN, image, image('hormigaN.jpg')).
resource(sB, image, image('saltamontesB.jpg')).
resource(sN, image, image('saltamontesN.jpg')).
resource(turno1, image, image('turno1.jpg')).
resource(turno2, image, image('turno2.jpg')).
resource(vacia, image, image('vacia.jpg')).
resource(valido, image, image('valido.jpg')).

size_ficha(55).
punto_inicial(point(495, 330)).
resultado_juego(point(400, 330)).
turno_pos(400,0).
ia(0).

:- dynamic [alto/1,ancho/1,window/1,ia/1,colocar/1,ficha_selec/6,tablero_aux/4,manoB/2,manoN/2].
/*
alto : altura del tablero
ancho : ancho del tablero
window : El Window donde se trabaja
ia : si se escogio el modo User vs IA
tablero_aux : las fichas que estan en la mano (nobreFoto, Color, FilaPix, ColumnaPix)
colocar : dende se puede colocar la ficha seleccionada
ficha_selec : la ficha que se selecciono (X,Y,Especie, color, Nivel, Id)
tablero_aux : las fichas que estan en la mano (nobreFoto, Color, FilaPix, ColumnaPix)
manoB : las posiciones de las fichas blancas q estan en la mano
manoN : las posiciones de las fichas negras q estan en la mano
*/

fichasB([rB, hB, hB, hB, sB, sB, sB, eB, eB, aB, aB]).
fichasN([rN, hN, hN, hN, sN, sN, sN, eN, eN, aN, aN]).

tipo_fm(1,r):- !.
tipo_fm(2,h):- !.
tipo_fm(3,h):- !.
tipo_fm(4,h):- !.
tipo_fm(5,s):- !.
tipo_fm(6,s):- !.
tipo_fm(7,s):- !.
tipo_fm(8,e):- !.
tipo_fm(9,e):- !.
tipo_fm(10,a):- !.
tipo_fm(11,a):- !.

foto(r,b,rB):-!.    
foto(r,n,rN):-!.
foto(h,b,hB):-!.    
foto(h,n,hN):-!.
foto(s,b,sB):-!.    
foto(s,n,sN):-!.
foto(e,b,eB):-!.    
foto(e,n,eN):-!.
foto(a,b,aB):-!.    
foto(a,n,aN):-!.

start :-
    new(D, dialog('My Hive')),
    send_list(D, append, [
        button('User vs User', and(
                        message(@prolog,simple),
                        message(D, destroy))
                ),
            button('User vs IA', and(
                message(@prolog, iamode),
                message(D, destroy))
            )
        ]),
    send(D, open).

simple():-
    fichasB(FB),
    fichasN(FN),
    asserta(alto(1045)),
    asserta(ancho(660)),
    asserta(colocar([])),
    main(FB,FN).

main(FB,FN):-
    ancho(Ancho),
    alto(Alto),
    new(W, window('My Hive', size(Ancho,Alto))),
    asserta(window(W)),
    send(W, open),
    pinta_tablero(W, FB, FN),
    pinta_turno(W),
    send(W, recogniser, click_gesture(left,
                                            '',
                                            single,
                                            message(@prolog, click, W, @event?position))).

pinta_tablero(Window, FB, FN):-
    size_ficha(SF),
    pinta_fichas_blancas(Window,SF, FB, 1, 0, 55),
    pinta_fichas_negras(Window, SF, FN, 1, 990, 55).
    
pinta_fichas_blancas(_,_,[],_,_,_):- !.
pinta_fichas_blancas(Window, SF, [X|XS],1, FS, CS):-
    nueva_imagen(Window, _,X,point(FS+27.5,CS)),
    NFS is FS+27.5,
    asserta(manoB(NFS, CS)),
    NewCS is CS + SF,
    pinta_fichas_blancas(Window,SF,XS,0,FS,NewCS).
pinta_fichas_blancas(Window, SF, [X|XS],0, FS, CS):-
    nueva_imagen(Window, _,X,point(FS,CS)),
    asserta(manoB(FS, CS)),
    NewCS is CS + SF,
    pinta_fichas_blancas(Window,SF,XS,1,FS,NewCS).

pinta_fichas_negras(_,_,[],_,_,_):- !.
pinta_fichas_negras(Window, SF, [X|XS],1, FS, CS):-
    nueva_imagen(Window, _,X,point(FS-27.5,CS)),
    NFS is FS-27.5,
    asserta(manoN(NFS, CS)),
    NewCS is CS + SF,
    pinta_fichas_negras(Window,SF,XS,0,FS,NewCS).
pinta_fichas_negras(Window, SF, [X|XS],0, FS, CS):-
    nueva_imagen(Window, _,X,point(FS,CS)),
    asserta(manoN(FS, CS)),
    NewCS is CS + SF,
    pinta_fichas_negras(Window,SF,XS,1,FS,NewCS).

nueva_imagen(Win, Fig, Imagen, Pos) :-
    new(Fig, figure),
    new(Bitmap, bitmap(resource(Imagen),@on)),
    send(Bitmap, name, 1),
    send(Fig, display, Bitmap),
    send(Fig, status, 1),
    send(Win, display, Fig, Pos).

pinta_turno(Window):-
    ia(IA),
    IA =:= 0,
    turno(N),
    T is N mod 2,
    T =:= 0,
    turno_pos(X,Y),
    nueva_imagen(Window, _, turno1 ,point(X,Y)),!.
pinta_turno(Window):-
    ia(IA),
    IA =:= 0,
    turno_pos(X,Y),
    nueva_imagen(Window,_,turno2,point(X,Y)),!.
pinta_turno(_).

% ESTOS METODOS CONVIERTEN DE CORDENADA A PIXEL Y DE PIXEL A CORDENADA RESPECTIVAMENTE.
conver_pixel(XCor,YCor,X,Y):-
    punto_inicial(PI),
    get(PI, x, X1),
    get(PI, y, Y1),
    X is (XCor / 2)* 55 + X1,
    Y is YCor * 55 + Y1.
conver_cordenada(XPix,YPix,X,Y):-
    convY(YPix,Y),
    N is (Y mod 2),
    convX(XPix,X,N).

convY(Py,Y):-
    punto_inicial(Pi),
    get(Pi,y,Yi),
    (Py-Yi)>=0,
    Y is integer(Py-Yi) div 55,!.
convY(Py,Y):-
    punto_inicial(Pi),
    get(Pi,y,Yi),
    Y is (integer(Py-Yi) div 55).

convX(Px,X,N):-
    N =:= 0,
    punto_inicial(Pi),
    get(Pi,x,Xi),
    (Px-Xi)>=0,
    X is (integer(Px-Xi) div 55)*2,!.
convX(Px,X,N):-
    N =:= 0,
    punto_inicial(Pi),
    get(Pi,x,Xi),
    X is ((integer(Px-Xi) div 55))*2,!.
convX(Px,X,_):-
    punto_inicial(Pi),
    get(Pi,x,Xi),
    (Px-Xi)>=0,
    X is (integer(Px - (Xi + (55/2))) div 55)*2 + 1,!.
convX(Px,X,_):-
    punto_inicial(Pi),
    get(Pi,x,Xi),
    X is ((integer(Px-(Xi+(55/2))) div 55)+1)*2 -1.

click(Window, Pos):-
    ficha_click(Window,Pos).

%si va a mover la ficha selecionada del tablero
ficha_click(Window,Pos):- 
    get(Pos,x,XPix),
    get(Pos,y,YPix),
    conver_cordenada(XPix,YPix,X,Y),
    colocar(Colo),
    contenida(Colo, [X,Y]),
    ficha_selec(Xv,Yv,E,C,_,Id),
    tablero(Xv,Yv,_,_,_,_),
    mov_fichas(Xv,Yv,E,C,Id,X,Y),
    quita_ficha(Window,Xv,Yv),
    limpia_pos(Window,Colo),
    retractall(ficha_selec(_,_,_,_,_,_)),
    pinta_turno(Window),
    pierdeN(N),
    pierdeB(B),
    pinta_resul(Window,B,N),!.
%si va a mover la ficha seleccionada de la mano
ficha_click(Window,Pos):- 
    get(Pos,x,XPix),
    get(Pos,y,YPix),
    conver_cordenada(XPix,YPix,X,Y),
    colocar(Colo),
    contenida(Colo, [X,Y]),
    ficha_selec(Xv,Yv,E,C,_,Id),
    conver_pixel(Xv,Yv,Px,Py),
    quit_mano(Px,Py,C),
    mov_fichas(Xv,Yv,E,C,Id,X,Y),
    quita_ficha(Window,Xv,Yv),
    limpia_pos(Window,Colo),
    retractall(ficha_selec(_,_,_,_,_,_)),
    pinta_turno(Window),
    pierdeN(N),
    pierdeB(B),
    pinta_resul(Window,B,N),!.
% si se toma una ficha de la mano blanca
ficha_click(Window,Pos):-
    get(Pos,x,X),
    get(Pos,y,Y),
    turno(T),
    (T mod 2) =:= 0, 
    conver_cordenada(X,Y,Cx,Cy),
    conver_pixel(Cx,Cy,Xp,Yp),
    manoB(Xp,Yp),
    colocar(Cv),
    limpia_pos(Window,Cv),
    Pf is (Y div 55),
    tipo_fm(Pf,E),
    ultimo_id(UId),
    Id is UId+1,
    retractall(ficha_selec(_,_,_,_,_,_)),
    asserta(ficha_selec(Cx,Cy,E,b,1,Id)),
    limite_reina(),
    insertar(b,Colo),
    retractall(colocar(_)),
    asserta(colocar(Colo)),
    pinta_posi(Window,Colo),!.
% si se toma una ficha de la mano negra
ficha_click(Window,Pos):-
    get(Pos,x,X),
    get(Pos,y,Y),
    turno(T),
    (T mod 2) =:= 1,
    conver_cordenada(X,Y,Cx,Cy),
    conver_pixel(Cx,Cy,Px,Py), 
    manoN(Px,Py),
    colocar(Cv),
    limpia_pos(Window,Cv),
    Pf is (Y div 55),
    tipo_fm(Pf,E),
    ultimo_id(UId),
    Id is UId+1,
    retractall(ficha_selec(_,_,_,_,_,_)),
    asserta(ficha_selec(Cx,Cy,E,n,1,Id)),
    limite_reina(),
    insertar(n,Colo),
    retractall(colocar(_)),
    asserta(colocar(Colo)),
    pinta_posi(Window,Colo),!.
%si se toma una ficha del tablero blanca
ficha_click(Window,Pos):-
    get(Pos,x,X),
    get(Pos,y,Y),
    conver_cordenada(X,Y,Cx,Cy),
    tablero(Cx,Cy,E,C,N,Id),
    turno(T),
    (T mod 2) =:= 0,
    C == b,
    colocar(Cv),
    limpia_pos(Window,Cv),
    retractall(ficha_selec(_,_,_,_,_,_)),
    asserta(ficha_selec(Cx,Cy,E,C,N,Id)), 
    clasif_mov(Cx,Cy,E,Colo), 
    retractall(colocar(_)),
    asserta(colocar(Colo)),
    limite_reina(),
    colocar(NewColo),
    pinta_posi(Window,NewColo),!.
%si se toma una ficha del tablero negra
ficha_click(Window,Pos):-
    get(Pos,x,X),
    get(Pos,y,Y),
    conver_cordenada(X,Y,Cx,Cy),
    tablero(Cx,Cy,E,C,N,Id),
    turno(T),
    (T mod 2) =:= 1,
    C == n,
    colocar(Cv),
    limpia_pos(Window,Cv),
    retractall(ficha_selec(_,_,_,_,_,_)),
    asserta(ficha_selec(Cx,Cy,E,C,N,Id)),
    clasif_mov(Cx,Cy,E,Colo),
    retractall(colocar(_)),
    asserta(colocar(Colo)),
    limite_reina(),
    colocar(NewColo),
    pinta_posi(Window,NewColo),!.

quit_mano(Px,Py,b):- retract(manoB(Px,Py)),!.
quit_mano(Px,Py,n):- retract(manoN(Px,Py)).

limite_reina():-
    turno(T),
    T =:= 6,
    manoB(27.5,55),
    ultimo_id(Id),
    NId is Id+1,
    retractall(ficha_selec(_,_,_,_,_,_)),
    conver_cordenada(27.5,55,X,Y),
    asserta(ficha_selec(X,Y,r,b,1,NId)),
    insertar(b,Colo),
    retractall(colocar(_)),
    asserta(colocar(Colo)),!.
limite_reina():-
    turno(T),
    T =:= 7,
    manoN(962.5,55),
    ultimo_id(Id),
    NId is Id+1,
    retractall(ficha_selec(_,_,_,_,_,_)),
    conver_cordenada(962.5,55,X,Y),
    asserta(ficha_selec(X,Y,r,n,1,NId)),
    insertar(n,Colo),
    retractall(colocar(_)),
    asserta(colocar(Colo)),!.
limite_reina().

% quita las opciones a las q se puede mover una ficha
limpia_pos(_,[]):-
    retractall(colocar(_)),
    asserta(colocar([])),!.
limpia_pos(Window,[[X,Y|_]|XS]):-
    tablero(X,Y,E,C,_,_),
    foto(E,C,R),
    conver_pixel(X,Y,Px,Py),
    nueva_imagen(Window,_,R,point(Px,Py)),
    limpia_pos(Window,XS),!.
limpia_pos(Window,[[X,Y|_]|XS]):-
    conver_pixel(X,Y,Px,Py),
    nueva_imagen(Window,_,vacia,point(Px,Py)),
    limpia_pos(Window,XS).

%quita la ficha del tablero (ESTE METODO DEBE EJECUTARSE DESPUES DEL METODO mov_fichas)
quita_ficha(Window,X,Y):-
    tablero(X,Y,E,C,_,_),
    foto(E,C,R),
    conver_pixel(X,Y,Px,Py),
    nueva_imagen(Window,_,R,point(Px,Py)),!.
quita_ficha(Window,X,Y):-
    conver_pixel(X,Y,Px,Py),
    nueva_imagen(Window,_,vacia,point(Px,Py)),!.

pinta_posi(_,[]):-!.
pinta_posi(Window,[[X,Y|_]|XS]):-
    conver_pixel(X,Y,Px,Py),
    nueva_imagen(Window,_,valido,point(Px,Py)),
    pinta_posi(Window,XS).

pinta_resul(_,0,0):-!.
pinta_resul(Window,0,1):-
    resultado_juego(P),
    nueva_imagen(Window,_,gana1,P),!.
pinta_resul(Window,1,0):-
    resultado_juego(P),
    nueva_imagen(Window,_,gana2,P),!.
pinta_resul(Window,1,1):-
    resultado_juego(P),
    nueva_imagen(Window,_,empate,P),!.


clasif_mov(Cx,Cy,r,Pos):-
    mov_reina(Cx,Cy,Pos),!.
clasif_mov(Cx,Cy,h,Pos):-
    mov_hormiga(Cx,Cy,Pos),!.
clasif_mov(Cx,Cy,e,Pos):-
    mov_escar(Cx,Cy,Pos),!.
clasif_mov(Cx,Cy,s,Pos):-
    mov_saltam(Cx,Cy,[1,2,3,4,5,6],[],Pos),!.
clasif_mov(Cx,Cy,a,Pos):-
    mov_aranna(Cx,Cy,Pos).


%================================= PARA LA IA =================================================

iamode():-
    fichasB(FB),
    fichasN(FN),
    asserta(alto(1045)),
    asserta(ancho(660)),
    asserta(colocar([])),
    mainIA(FB,FN).

mainIA(FB,FN):-
    ancho(Ancho),
    alto(Alto),
    new(W, window('My Hive', size(Ancho,Alto))),
    asserta(window(W)),
    send(W, open),
    pinta_tableroIA(W, FB, FN),
    send(W, recogniser, click_gesture(left,
                                            '',
                                            single,
                                            message(@prolog, clickIA, W, @event?position))).

pinta_tableroIA(Window, FB, FN):-
    size_ficha(SF),
    pinta_fichas_blancas(Window,SF, FB, 1, 0, 55),
    pinta_fichas_negrasIA(Window, SF, FN, 1, 990, 55).

pinta_fichas_negrasIA(_,_,[],_,_,_):- !.
pinta_fichas_negrasIA(Window, SF, [X|XS],1, FS, CS):-
    nueva_imagen(Window, _,X,point(FS-27.5,CS)),
    NFS is FS-27.5,
    asserta(manoN(NFS, CS)),

    conver_cordenada(NFS,CS,Cx,Cy),
    foto(E,_,X),
    IdK is (CS div 55),
    tipo_fm(IdK,E),
    asserta(fichas_ia(Cx,Cy,E,1,IdK)),

    NewCS is CS + SF,
    pinta_fichas_negrasIA(Window,SF,XS,0,FS,NewCS).
pinta_fichas_negrasIA(Window, SF, [X|XS],0, FS, CS):-
    nueva_imagen(Window, _,X,point(FS,CS)),
    asserta(manoN(FS, CS)),

    conver_cordenada(FS,CS,Cx,Cy),
    foto(E,_,X),
    IdK is (CS div 55),
    tipo_fm(IdK,E),
    asserta(fichas_ia(Cx,Cy,E,1,IdK)),

    NewCS is CS + SF,
    pinta_fichas_negrasIA(Window,SF,XS,1,FS,NewCS).

clickIA(Window, Pos):-
    ficha_clickIA(Window,Pos).

%si va a mover la ficha selecionada del tablero
ficha_clickIA(Window,Pos):- 
    get(Pos,x,XPix),
    get(Pos,y,YPix),
    conver_cordenada(XPix,YPix,X,Y),
    colocar(Colo),
    contenida(Colo, [X,Y]),
    ficha_selec(Xv,Yv,E,C,_,Id),
    tablero(Xv,Yv,_,_,_,_),
    mov_fichas(Xv,Yv,E,C,Id,X,Y),
    quita_ficha(Window,Xv,Yv),
    limpia_pos(Window,Colo),
    retractall(ficha_selec(_,_,_,_,_,_)),
    pierdeN(N),
    pierdeB(B),
    pinta_resul(Window,B,N),

    mov_ia(XiIA,YiIA,XfIA,YfIA,EIA,IdIA),
    mov_fichas(XiIA,YiIA,EIA,n,IdIA,XfIA,YfIA),
    quita_ficha(Window,XiIA,YiIA),
    limpia_pos(Window,[[XfIA,YfIA]]),
    pierdeN(N2),
    pierdeB(B2),
    pinta_resul(Window,B2,N2),

    !.
%si va a mover la ficha seleccionada de la mano
ficha_clickIA(Window,Pos):-
    get(Pos,x,XPix),
    get(Pos,y,YPix),
    conver_cordenada(XPix,YPix,X,Y),
    colocar(Colo),
    contenida(Colo, [X,Y]),
    ficha_selec(Xv,Yv,E,C,_,Id),
    conver_pixel(Xv,Yv,Px,Py),
    quit_mano(Px,Py,C),
    mov_fichas(Xv,Yv,E,C,Id,X,Y),
    quita_ficha(Window,Xv,Yv),
    limpia_pos(Window,Colo),
    retractall(ficha_selec(_,_,_,_,_,_)),
    pierdeN(N),
    pierdeB(B),
    pinta_resul(Window,B,N),
    
    mov_ia(XiIA,YiIA,XfIA,YfIA,EIA,IdIA),
    mov_fichas(XiIA,YiIA,EIA,n,IdIA,XfIA,YfIA),
    quita_ficha(Window,XiIA,YiIA),
    limpia_pos(Window,[[XfIA,YfIA]]),
    pierdeN(N2),
    pierdeB(B2),
    pinta_resul(Window,B2,N2),

    !.
% si se toma una ficha de la mano blanca
ficha_clickIA(Window,Pos):-
    get(Pos,x,X),
    get(Pos,y,Y),
    turno(T),
    (T mod 2) =:= 0, 
    conver_cordenada(X,Y,Cx,Cy),
    conver_pixel(Cx,Cy,Xp,Yp),
    manoB(Xp,Yp),
    colocar(Cv),
    limpia_pos(Window,Cv),
    Pf is (Y div 55),
    tipo_fm(Pf,E),
    ultimo_id(UId),
    Id is UId+1,
    retractall(ficha_selec(_,_,_,_,_,_)),
    asserta(ficha_selec(Cx,Cy,E,b,1,Id)),
    limite_reina(),
    insertar(b,Colo),
    retractall(colocar(_)),
    asserta(colocar(Colo)),
    pinta_posi(Window,Colo),!.
%si se toma una ficha del tablero blanca
ficha_clickIA(Window,Pos):-
    get(Pos,x,X),
    get(Pos,y,Y),
    conver_cordenada(X,Y,Cx,Cy),
    tablero(Cx,Cy,E,C,N,Id),
    turno(T),
    (T mod 2) =:= 0,
    C == b,
    colocar(Cv),
    limpia_pos(Window,Cv),
    retractall(ficha_selec(_,_,_,_,_,_)),
    asserta(ficha_selec(Cx,Cy,E,C,N,Id)), 
    clasif_mov(Cx,Cy,E,Colo), 
    retractall(colocar(_)),
    asserta(colocar(Colo)),
    limite_reina(),
    colocar(NewColo),
    pinta_posi(Window,NewColo),!.