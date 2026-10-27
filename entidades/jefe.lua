Jefe = Class{__includes = Enemigo}

function Jefe:init(x, y, mundo)
    
    Enemigo.init(self, x, y, "img/Jefe.png", 4, 35, mundo)

    self.esJefe = true
    self.vidas = 3
    self.vidasMaximas = 3

    -- Duplicamos el tamaño para la colisión en Bump
    self.ancho = 32
    self.alto = 32
    self.origen_x = self.ancho / 2
    self.origen_y = self.alto / 2

    if self.mundo and self.mundo:hasItem(self) then
        self.mundo:update(self, self.x - self.origen_x, self.y - self.origen_y, self.ancho, self.alto)
    end
end

function Jefe:Dibujar()
   
    if self.congelado then
        love.graphics.setColor(0, 0.6, 1, 0.8)
    elseif self.vidas < self.vidasMaximas then
        love.graphics.setColor(1, 0.4, 0.4, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.scale(2, 2)
    Animacion.dibujar(self.animacionActual, 0, 0, 8, 8)
    love.graphics.pop()

    -- Barra de daño
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", self.x - 16, self.y - 24, 32, 4)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", self.x - 16, self.y - 24, (self.vidas / self.vidasMaximas) * 32, 4)
    love.graphics.setColor(1, 1, 1, 1)
end