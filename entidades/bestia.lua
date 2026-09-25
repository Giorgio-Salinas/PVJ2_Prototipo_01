Bestia = Class{__includes = Enemigo}

function Bestia:init(x, y)
    -- Llama al constructor de Enemigo con la imagen de la bestia y mayor velocidad
    Enemigo.init(self, x, y, "img/Beast2.png", 4, 25)
end