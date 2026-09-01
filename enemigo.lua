-- Clase Enemigo
Enemigo = {}
Enemigo.__index = Enemigo

function Enemigo:Nuevo(x, y, vel)
    local o = setmetatable({}, Enemigo)

    o.x = x
    o.y = y
    o.velocidad = vel or 35
    o.sprite = love.graphics.newImage("img/Robot_Walk.png")

    o.ancho = 16
    o.alto = 16
    o.origen_x = o.ancho / 2
    o.origen_y = o.alto / 2

    -- Frame inicial del robot
    o.cuadro = love.graphics.newQuad(0, 0, o.ancho, o.alto, o.sprite:getDimensions())

    return o
end

function Enemigo:Actualizar(dt, target)
    if target then
        -- Vector hacia el objetivo
        local dx = target.x - self.x
        local dy = target.y - self.y
        local distancia = math.sqrt(dx * dx + dy * dy)

        -- Si no esta superpuesto, se mueve en direccion al jugador
        if distancia > 1 then
            local dirX = dx / distancia
            local dirY = dy / distancia

            self.x = self.x + (dirX * self.velocidad * dt)
            self.y = self.y + (dirY * self.velocidad * dt)
        end
    end
end

function Enemigo:Dibujar()
    love.graphics.draw(self.sprite, self.cuadro, redondear(self.x), redondear(self.y), 0, 1, 1, self.origen_x, self.origen_y)
end

return Enemigo