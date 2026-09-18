-- Clase Enemigo

Enemigo = Class{}

function Enemigo:init(x, y, ruta_img, total_frames, vel)
    

    self.x = x
    self.y = y
    self.inicioX = x
    self.inicioY = y
    self.velocidad = vel or 35

    local ruta = ruta_img or "img/Robot_Walk.png"
    local frames = total_frames or 4

    self.ancho = 16
    self.alto = 16
    self.origen_x = self.ancho / 2
    self.origen_y = self.alto / 2
    self.radio_colision = 5

    -- Animaciones verticales por columna
    self.animaciones = {
        abajo     = Animacion.crear(ruta, frames, self.ancho, self.alto, 6, true, 0),
        arriba    = Animacion.crear(ruta, frames, self.ancho, self.alto, 6, true, 1),
        izquierda = Animacion.crear(ruta, frames, self.ancho, self.alto, 6, true, 2),
        derecha   = Animacion.crear(ruta, frames, self.ancho, self.alto, 6, true, 3)
    }

    self.animacionActual = self.animaciones.abajo

end

function Enemigo:PosicionarAleatorio(limites)
    local esquina = math.random(1, 4)

    if esquina == 1 then
        -- Esquina superior izquierda
        self.x = self.origen_x
        self.y = self.origen_y
    elseif esquina == 2 then
        -- Esquina superior derecha
        self.x = limites.ancho - self.origen_x
        self.y = self.origen_y
    elseif esquina == 3 then
        -- Esquina inferior izquierda
        self.x = self.origen_x
        self.y = limites.alto - self.origen_y
    elseif esquina == 4 then
        -- Esquina inferior derecha
        self.x = limites.ancho - self.origen_x
        self.y = limites.alto - self.origen_y
    end
end

function Enemigo:Reiniciar(limites)
    if limites then
        self:PosicionarAleatorio(limites)
    else
        self.x = self.inicioX
        self.y = self.inicioY
    end
    self.animacionActual = self.animaciones.abajo
    self.animacionActual.activado = false
    self.animacionActual.indice = 1
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
