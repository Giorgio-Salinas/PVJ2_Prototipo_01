Robot = Class{__includes = Enemigo}

function Robot:init(x, y)
    -- Llama al constructor de Enemigo pasándole sus propios datos
    Enemigo.init(self, x, y, "img/Robot_Walk.png", 4, 15)
end