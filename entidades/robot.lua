Robot = Class{__includes = Enemigo}

function Robot:init(x, y, mundo)
    -- Llama al constructor de Enemigo pasándole sus propios datos
    Enemigo.init(self, x, y, "img/Robot_Walk.png", 4, 15, mundo)
end