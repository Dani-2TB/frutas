function make_player(x,y,sp)
    -- Al player lo creamos como un tabla (La estructura de datos principal de lua), 
    -- declarada con nombre_variable = {}.
    -- esto nos permite definir los atributos y métodos que van a controlar al player.
    -- Estos nos permitiran controlar todos los aspectos de como
    -- se comporta el jugador.
    player = {
        x = x, -- Su posición x e y en pantalla
        y = y, -- Posición y del player en pantalla
        dx = 0, -- la diferencia en movimiento se usará para agregar velocidad al player
        sp = 1, -- El sprite del player (recordar que se dibuja desde su esquina superior izquierda a la derecha y hacia abajo)
        canasta = 2, -- El sprite de la canasta
        speed = 1, -- La acelaración.
        friction = 0.8, -- Fricción, un número que se utilizará para desacelerar al player
                        -- Prueba modificar este valor para ver cómo afectan al player valores distintos
                        -- sin ser igual a 1. EJ: 0.2, 0.95, etc...

        update = function(self)
                -- Aquí programamos la lógica que controla al player.

            -- Partimos con la sección de "eventos", los eventos son todo lo que "escucha"
            -- el programa. Botones presionados, colisiones, etc.

            -- Movimiento horizontal
            -- Dependiendo de la dirección que se aprete, se agregará cada fotograma la velocidad
            -- a la variable dx del player, esto dará un efecto de aceleración.
            if (btn(0)) then
                self.dx -= self.speed -- Si vamos a la izquierda restamos
            end                      
            if (btn(1)) then
                self.dx += self.speed -- Si vamos a la derecha subimos
            end

            -- Aplicar la velocidad
            self.x += self.dx -- Se le aplica la "diferencia de velocidad" (por eso dx)
                              -- A la posición x del player para moverlo.

            self.dx *= self.friction -- Se utiliza la fricción para ir disminuyendo de a poco la 
                                     -- velocidad del player cada fotograma hasta llegar a 0

            -- Para asegurarnos que la velocidad llegue a 0 la volveremos 0 cuando dx llegue a 0.2
            -- es decir, cuando la velocidad sea muy baja.
            if (abs(self.dx) < 0.05) then
                self.dx = 0
            end

            -- Colisiones

            --Colisionar contra  el borde de la pantalla
            if (self.x <= 0) then 
                self.x = 0         -- Limitando el movimiento a los bordes de la pantalla
            end
            if (self.x >= 120) then
                self.x = 120       -- Ajustamos al ancho del sprite.
            end

        end,
        draw = function (self)
            -- Dibujamos el sprite del player y la canasta ajustada en 8 pixeles hacia arriba
            spr(self.sp, self.x, self.y)
            spr(self.canasta, self.x, self.y-8)
        end
    }
    return player
end