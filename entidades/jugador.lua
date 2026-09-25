-- ================= CLASE JUGADOR =================

Jugador = Class{}

function Jugador:init(x, y, vel)
    local o = setmetatable({}, Jugador)

    self.x = x
    self.y = y
    self.inicioX = x
    self.inicioY = y
    self.velocidad = vel or 60
    self.vidas = 3

    self.ancho = 16
    self.alto = 16
    self.origen_x = self.ancho / 2
    self.origen_y = self.alto / 2
    self.radio_colision = 5

    self.direccion_actual = "abajo"

    -- Animaciones verticales por cada columna del spritesheet Walk.png
    self.animaciones = {
        abajo     = Animacion.crear("img/Walk.png", 3, self.ancho, self.alto, 8, true, 0),
        arriba = Animacion.crear("img/Walk.png", 3, self.ancho, self.alto, 8, true, 1),
        izquierda    = Animacion.crear("img/Walk.png", 3, self.ancho, self.alto, 8, true, 2),
        derecha   = Animacion.crear("img/Walk.png", 3, self.ancho, self.alto, 8, true, 3)
    }

    self.animacionActual = self.animaciones.abajo

    
end

function Jugador:Actualizar(dt, limites)
    local seMueve = false

    -- Movimiento y selección de animación
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.x = self.x + (self.velocidad * dt)
        self.animacionActual = self.animaciones.derecha
        self.direccion_actual = "derecha"
        seMueve = true
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.x = self.x - (self.velocidad * dt)
        self.animacionActual = self.animaciones.izquierda
        self.direccion_actual = "izquierda"
        seMueve = true
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        self.y = self.y + (self.velocidad * dt)
        self.animacionActual = self.animaciones.abajo
        self.direccion_actual = "abajo"
        seMueve = true
    elseif love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        self.y = self.y - (self.velocidad * dt)
        self.animacionActual = self.animaciones.arriba
        self.direccion_actual = "arriba"
        seMueve = true
    end

    -- Límites dentro de la ventana
    if limites then
        self.x = math.max(self.origen_x, math.min(limites.ancho - self.origen_x, self.x))
        self.y = math.max(self.origen_y, math.min(limites.alto - self.origen_y, self.y))
    end

    -- Actualización de la animación activa
    self.animacionActual.activado = seMueve
    if seMueve then
        Animacion.actualizar(self.animacionActual, dt)
    else
        self.animacionActual.indice = 1
    end
end

function Jugador:RecibirDanio()
    self.vidas = self.vidas - 1
end

function Jugador:Reiniciar()
    self.x = self.inicioX
    self.y = self.inicioY
    self.direccion_actual = "abajo"
    self.animacionActual = self.animaciones.abajo
    self.animacionActual.activado = false
    self.animacionActual.indice = 1
end

function Jugador:Dibujar()
    Animacion.dibujar(self.animacionActual, self.x, self.y, self.origen_x, self.origen_y)
end
