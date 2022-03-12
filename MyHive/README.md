### Proyecto de Programación Declarativa. Prolog. 

#### Hive with IA.

- Nelson Robin Mendoza Alvarez C411

#### Forma de ejecución del proyecto:

1. Situarse en una terminal en la carpeta del proyecto.

2. swipl visual.pl

3. start.

#### Estructura del proyecto:

En el proyecto se presentan varios módulos o bloques de código fundamentales:

- Logica: contiene la lógica central del juego, incluye los movimientos de cada uno de los insectos y otras funciones, relativas todas a dichos movimientos.

- visual: incluye todo el modelado de la parte visual del juego y la interacción de los usuarios con el mismo.

- IA: implementación de la lógica relacionada con el jugador no humano.

#### Logica:

Este modulo contiene los predicados cuyo objetivo es la movilidad de las fichas. Maneja la posición de las fichas que han sido jugadas, si pueden ser jugadas (viendo los casos en los q un movimiento pueda desconectar la colmeno, cosa que no es válida), cuando un jugador pierde o empata, los posibles lugares a donde pueden moverse las fichas del tablero según su especie, los sitios en los que se puede colocar una ficha que está en la mano del jugador, etc.

- Para revisar si una ficha no descanecta la colmena al ser movida primeramente quitamos la ficha del tablero y luego con un DFS partiendo de una d las fichas que queda se puede llegar a todas las demás fichas del tablero.

- Para revisar el resultado del juego tras una jugada el proyecto revisa si las reinas (cuando estan en el tablero) tienen una casilla vecina vacía.

- Dependiendo de las especies de las fichas (reina, hormiga, saltamontes, escarabajo y araña) se implemento un predicado para cada una de ellas, que dado una posición en la que se encuentra nos da los posibles lugares a los que se puede mover (siempre revisando antes si se puede mover).

- Para colocar una ficha de la mano, primero se toma todo el contorno de la colmena y quitamos las posiciones que son adyacentes con fichas del color contrario a la ficha que se desea colocar.

#### Movimientos:

- Reina: Esta busca las casillas adyacentes a ellas que están vacías y que al moverse a estas se mantiene conectada con la colmena. 

- Hormiga: Con un DFS busca las casillas del contorno del tablero a las que puede llegar.

- Saltamontes: Revisa en las direcciones en las que tiene vecino el primer lugar que se encuentre vacío.

- Escarabajo: Es parecido a la reina lo que este ignora que alla una ficha al lugar donde desea moverse ya que se puede colocar sobre esta.

- Araña: Es parecida a la hormiga pero esta solo se queda con las posiciones a las que se llegó en el DFS en su tercer nivel de búsqueda.

#### IA:

La inteligencia artificial que podemos observar en este proyecto centra su funcionemiento en la cantidad de fichas que rodean a ambas reinas, tratando siempre de que cada jugada trate de mejorar la situación para su reina (la negra), es decir, ella siempre trata de que la cantidad de fichas alrededor de la reina blanca aumente y la de la negra disminuya. En caso de que no exista una jugada que mejore esto se coloca una ficha de la mano, tratando siempre de no colocarla junto a la reina negra.

#### Visual:

Para el desarrollo del ambiente visual de la aplicación se empleó [XPCE](https://www.swi-prolog.org/packages/xpce/) que no es más que un conjunto de herramientas para desarrollar aplicaciones gráficas en Prolog y otros lenguajes interactivos y de escritura dinámica.

El predicado _start_ es con el que se inicia el fujo de la aplicación mostrando una especie de menú que ofrece las opciones válidas para el inicio del juego:

- User vs User

- User vs IA

Una vez que el usuario selecciona la opción deseada se procede a mostrar la vista diseñada para tal motivo.

El módulo principal, por llamarlo de alguna forma, es _User vs User_ donde se permite la interacción de dos jugadores, las principales diferencias radican en que en _User vs IA_  se juega contra un usuario no humano.

En la parte superior se irá mostrando a que jugador le toca jugar en el moda User vs User y cuando un jugador gane o la partida termine en un empate esto se mostrará en el centro del tablero.

En el modo User vs IA el usuario siempre será el primero en jugar con las fichas blancas. La IA jugará automaticamente después de cada jugada del usuario.

Cada ficha del tablero es controlada con el predicado tablero(X,Y,E,C,N,Id) que la información que nos brinda es: _fila, columna, especie, color, nivel, Id_. El nivel se usa ya que hay fichas que pueden estar colocadas sobre otras y el Id es un identificador único que poseen todas las fichas del tablero y que se va asignando a medida que se van colocando.

Cuando un jugador selecciona una ficha se muestran los lugares a los que se puede mover, si se selecciona uno de estos lugares la ficha se movera a dicho lugar, si se seleciona otra ficha se mostraran las opciones de juego de esta.

Si en la cuarta jugada de un jugador, si este aun no ha jugado su reina, solo se mostrarán los lugares en los que puede colocar a la reina e independientemente de la ficha que seleccione solo podra colocar la reina ya que este es el limite de jugadas en el que se debe jugar la raina.

Lamentablemente no se pudo implementar las fichas de expansión del juego por lo que solo se podrá jugar con las fichas principales (1 reina, 3 hormigas, 3 saltamontes, 2 escarabajos y 2 arañas).

Para que se vea mejor el juego se deberá abrir completamente la ventana o no se podrán observar las fichas negras.

_Nota_: En caso de querer reiniciar el juego, para probar otra combinación de fichas o algo por el estilo, se debe invocar en la terminar el comando halt., para cerrarla y ejecutar de nuevo, lo descrito al inicio del informe.