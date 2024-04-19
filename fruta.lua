function make_fruta()
  local fruta = {
      x = rndb(0,120), -- La fruta usa una posición al azar entre 0 y 120 para aparecer
      y = -8,          -- La hacemos aparecer fuera de la pantalla en el eje Y
      sp = rndb(3,8),  -- además usa un sprite al azar entre los que tengamos dibujados
                       -- Recuerden utilizar un rango de sprites continuo y que tengan contenido 
      update = function(self) -- update mueve la fruta hacia abajo
        self.y += 1
      end,
      draw = function(self)
        spr(self.sp, self.x, self.y) -- draw dibuja el sprite de la fruta
      end
  }
  return fruta
end