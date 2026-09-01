-- ================= CLASE JUGADOR =================
Jugador = {}
Jugador.__index = Jugador

function Jugador:Nuevo(x, y, rutaImg, vel)
    local o = setmetatable({}, Jugador)

    o.x = x
    o.y = y
    o.sprite = love.graphics.newImage(rutaImg)
    o.velocidad = vel or 60

    -- Dimensiones de frame (grilla 4x4)
    o.ancho = o.sprite:getWidth() / 4
    o.alto  = o.sprite:getHeight() / 4
    o.origen_x = o.ancho / 2
    o.origen_y = o.alto / 2

    -- Primer quad estático
    o.cuadro = love.graphics.newQuad(0, 0, o.ancho, o.alto, o.sprite:getDimensions())

    return o
end

function Jugador:Actualizar(dt, limites)
    -- Movimiento top-down
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.x = self.x + (self.velocidad * dt)
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.x = self.x - (self.velocidad * dt)
    end

    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        self.y = self.y + (self.velocidad * dt)
    elseif love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        self.y = self.y - (self.velocidad * dt)
    end

    -- Limitar dentro de la ventana
    if limites then
        self.x = math.max(self.origen_x, math.min(limites.ancho - self.origen_x, self.x))
        self.y = math.max(self.origen_y, math.min(limites.alto - self.origen_y, self.y))
    end
end

function Jugador:Dibujar()
    love.graphics.draw(self.sprite, self.cuadro, redondear(self.x), redondear(self.y), 0, 1, 1, self.origen_x, self.origen_y)
end

return Jugador