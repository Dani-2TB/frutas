-- La función _init es la función de inicialización de la consola
-- Esta se ejecuta una sola vez al iniciar el cartucho
function _init()
  player = make_player(60,120) -- Creamos el objeto player con nuestra función definida en player.lua
  frutas = {} -- Inicializamos una tabla de lua vacía que contendrá nuestras frutas
  
  -- Crearemos 3 variables que manejarán nuestro temporizador para hacer aparecer las frutas.
  -- Nuestro tiempo mínimo será de 1 segundo y el máximo será de 2 segundos.
  -- Finalmente creamos un timer con nuestra función random definida más abajo, para crear un
  -- tiempo inicial aleatorio entre 1 segundo y 2 segunds. Recordemos que cada segundo
  -- son 30 fotogramas, o 30 ciclos de update y draw, por ende un segundo son 30 ciclos.
  timer_min = 30
  timer_max = 60
  timer_frutas = rndb(timer_min, timer_max)

  vidas = 3 -- iniciaremos el juego con 3 vidas
  puntos = 0 -- iniciamos el juego con 0 puntos
  game_over = true -- Esta variable booleana nos ayudará a decidir qué dibujar y hacer si
                    -- el jugador perdió la partida. Inicia como "false".

end

-- La función _update es una función que ejecuta la consola 30 veces por segundo
-- Esta función se encarga de hacer los cálculos y manejar la lógica de nuestro juego y
-- se ejecuta antes que _draw.
function _update()
  -- Iniciamos con un checkeo, que servira para controlar el estado del juego
  if not game_over then
    player:update() -- Ejecutamos la función update del objeto player

    update_timer() -- llamamos a la función para actualizar el timer cada fotograma

    agregar_fruta(frutas) -- Agregamos una fruta cada vez que el timer llegue a 0

    actualizar_frutas(frutas, player) -- Actualizamos las frutas con nuesta función definida más abajo
    
    -- finalmente tenemos que saber si las vidas llegaron a 0 si es así activamos el game over
    if (vidas == 0) then
      game_over = true
    end
  else
    -- Sólo necesitamos lógica para reiniciar el juego, si el usuario apreta el boton correspondiente
    -- se resetean las variables y se vuelve a poner game over a false, para que la lógica del juego vuelva a operar
    if (btn(5)) then
      vidas = 3
      puntos = 0
      frutas = {}
      player.x = 60
      game_over = false
    end
  end
  

end

function _draw()
  cls(0) -- Limpiamos la pantalla con el color negro
  if not game_over then
    dibujar_frutas(frutas) -- Dibujamos las frutas con nuestra función definida más abajo
    player:draw() -- Dibujamos al player con su función draw, ejecutamos esto después de las frutas
                -- para que así las frutas se dibujen detrás de la canasta. Es siempre importante
                -- verificar el orden en el que dibujamos las cosas.
    dibujar_interfaz()
    
  else
    -- Dibujamos el texto que queramos mostrar en la pantalla de game over, al igual que con la interfaz
    -- este código puede ser pasado a una función, sin embargo acá se dejó en la función draw
    print("game over", 46, 30)
    print("presiona ❎ para continuar", 13, 60)
    if (puntos > 0) then -- Acá solo mostraremos el puntaje si es mayor que 0 puntos.
      print("tu puntaje fue: "..puntos, 28, 70)
    end
  end
end

-- Función personalizada usando la función rnd
-- Genera un número al azar entre el número más bajo y
-- el número más alto.
function rndb(min,max)
  return flr(rnd(max-min+1)+min)
end

-- Esta función actualiza el timer global de las frutas
-- en cada fotograma irá reduciendo en uno el valor del 
-- temporizador, hasta llegar a 0, donde será resetado
-- el temporizador a un valor al azar entre un mínimo
-- y un máximo definidos globalmente.
function update_timer()
  if timer_frutas > 0 then
    timer_frutas -= 1
  else
    timer_frutas = rndb(timer_min, timer_max)
  end
end

-- Esta función se encarga de agregar las frutas, utiliza el timer global
-- para que cuando este llegue a 0, agrege una fruta a la lista de frutas
function agregar_fruta(tabla_frutas)
  if (timer_frutas == 0) then
    add(tabla_frutas, make_fruta())
  end
end

-- Esta función se encarga de llamar la función update de cada fruta en la
-- lista de frutas. Utiliza un for loop para acceder a cada objeto en la lista.
-- además chequea la colisión de la fruta con el piso o el player para sumar puntos
-- o restar vidas.
function actualizar_frutas(tabla_frutas, player)
  for fruta in all(tabla_frutas) do -- Por cada fruta en la lista de frutas:
    fruta:update() -- ejecutamos su función update
    -- Colisión con el suelo
    if fruta.y > 127 then -- verificamos si la fruta llegó al suelo
      del(tabla_frutas, fruta)  -- y de ser así la borramos de la lista
      vidas -= 1 -- restamos vidas al player DESPUÉS de borrar la fruta
    end
    -- Colisión con la canasta si colisiona con la canasta, entonces
    -- borramos la fruta de la lista y actualizamos el puntaje
    if check_collision(fruta, player) then
      del(tabla_frutas, fruta)
      puntos += 10
    end
  end
end

-- Esta función se encarga de dibujar todas las frutas. 
-- Utiliza un for loop para acceder a cada objeto de la lista de frutas
-- y llamar su función draw.
function dibujar_frutas(tabla_frutas)
  for fruta in all(tabla_frutas) do
    fruta:draw()
  end
end

-- Esta función chequea si la fruta colisiona con la canasta del player.
-- Sabemos la posición del player, por ende sabemos la posición de la canasta.
-- se utilizan estos valores para saber si la fruta representada como un punto
-- colisiona con una caja, en este caso la canasta.
function check_collision(fruta, player)
  local fruta_x = fruta.x + 3 -- vamos a tres pixeles para estar al "centro" de la fruta
  local fruta_y = fruta.y + 3 -- lo mismo hacia abajo, para que (x,y) = centro de la fruta

  -- definimos cuatro variables que describen una caja, x1 e y1 es la esquina superior izquierda de la caja
  -- x2 e y2 son la esquina inferior derecha de la caja
  local canasta_x1 = player.x
  local canasta_y1 = player.y - 7

  local canasta_x2 = player.x + 7
  local canasta_y2 = player.y - 1

  -- Ahora, necesitamos saber si el punto x,y de la fruta está dentro de la caja, para eso necesitamos
  -- que varias cosas sean verdad al mismo tiempo. 
  -- el en eje X, la posición x de la fruta debe ser mayor al x1 de la caja y menor al x2 de la caja
  -- en el eje Y, la posición de y debe ser mayor a y1 y menor a y2
  -- si todas estas condiciones son verdaderas al mismo tiempo, entonces el punto está dentro de la caja
  if (
    fruta_x > canasta_x1 and -- utilizamos el operador lógico AND para que así el resultado
    fruta_x < canasta_x2 and -- de la expresión sea verdadero SOLO si todas las expresiones
    fruta_y > canasta_y1 and -- evaluan a verdadero.
    fruta_y < canasta_y2) then
    return true
  end
  -- El operador lógico AND entonces actua como un filtro, prueba en la consola ejecutar expresiones booleanas y vé que
  -- te sale. La LÓGICA BOOLEANA es fundamental el programación, y es la base de la lógica de computadores.
  -- se podría hacer una tabla booleana de la puerta AND de la siguiente manera
  -- false AND false = false
  -- false AND true = false
  -- true AND false = false
  -- true AND true = true
  -- Existen otros operadores lógicos como OR y NOT que cambian el valor de las expresiones.

  -- Finalmente si la expresión del if no evalua verdadero, el punto está fuera de la caja por ende retornamos false
  return false

end

-- Esta función dibuja la interfaz mostrando el puntaje y las vidas
-- será llamada después de dibujar el resto de objetos para que
-- siempre aparezca sobre ellos
function dibujar_interfaz()
  rectfill(0,0,127,8,8) -- dibujamos un rectangulo que contendrá la información
                        -- los parametros son x1, y1, x2, y2, y el numero del color
  print("puntaje "..puntos, 2,2, 7) -- Se imprimen las palabras puntajes y vidas y se le agraga
  print("vidas "..vidas, 90,2, 7)   -- con el .. la variable correspondiente, esto se llama "concatenación"
                                    -- después se posiciona el texto en pantalla con sus cordenadas x e y de la esquina
                                    -- superior izquierda, y finalmente se elige el color blanco para "pintar" el texto
end