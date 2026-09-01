local Animacion = require "animacion"

-- Clase Enemigo
Enemigo = {}
Enemigo.__index = Enemigo

function Enemigo:Nuevo(x, y, vel)
    local o = setmetatable({}, Enemigo)

    o.x = x
    o.y = y
    o.velocidad = vel or 35

    o.ancho = 16
    o.alto = 16
    o.origen_x = o.ancho / 2
    o.origen_y = o.alto / 2

    -- Animaciones verticales por columna
    o.animaciones = {
        abajo     = Animacion.crear("img/Robot_Walk.png", 3, o.ancho, o.alto, 6, true, 0),
        arriba    = Animacion.crear("img/Robot_Walk.png", 3, o.ancho, o.alto, 6, true, 1),
        izquierda = Animacion.crear("img/Robot_Walk.png", 3, o.ancho, o.alto, 6, true, 2),
        derecha   = Animacion.crear("img/Robot_Walk.png", 3, o.ancho, o.alto, 6, true, 3)
    }

    o.animacionActual = o.animaciones.abajo

    return o
end

function Enemigo:Actualizar(dt, target)
    local seMueve = false

    if target then
        local dx = target.x - self.x
        local dy = target.y - self.y
        local distancia = math.sqrt(dx * dx + dy * dy)

        if distancia > 1 then
            local dirX = dx / distancia
            local dirY = dy / distancia

            self.x = self.x + (dirX * self.velocidad * dt)
            self.y = self.y + (dirY * self.velocidad * dt)
            seMueve = true

            
            if math.abs(dx) > math.abs(dy) then
                if dx > 0 then
                    self.animacionActual = self.animaciones.derecha
                else
                    self.animacionActual = self.animaciones.izquierda
                end
            else
                if dy > 0 then
                    self.animacionActual = self.animaciones.abajo
                else
                    self.animacionActual = self.animaciones.arriba
                end
            end
        end
    end

    self.animacionActual.activado = seMueve
    if seMueve then
        Animacion.actualizar(self.animacionActual, dt)
    else
        self.animacionActual.indice = 1
    end
end

function Enemigo:Dibujar()
    Animacion.dibujar(self.animacionActual, self.x, self.y, self.origen_x, self.origen_y)
end

return Enemigo