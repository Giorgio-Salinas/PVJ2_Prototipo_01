-- ================= CLASE JUGADOR =================

Jugador = Class{}

function Jugador:init(x, y, vel, mundo)
    

    self.x = x
    self.y = y
    self.velocidad = vel or 60
    self.vidas = 3
    self.invulnerable = false
    self.color = {1, 1, 1, 1}
    love.event.push("actualizar_vidas", self.vidas) --Push al handler para actualizar el texto de vidas
    self.mundo = mundo
    

    self.ancho = 16
    self.alto = 16
    self.origen_x = self.ancho / 2
    self.origen_y = self.alto / 2

    -- Hitbox reducida para no recibir daño injusto (10x10)
    self.anchoColision = 8
    self.altoColision = 8
    self.origen_colision_x = self.anchoColision / 2
    self.origen_colision_y = self.altoColision / 2

    -- Registra la caja de 10x10 bien centrada en Bump
    self.mundo:add(
        self, 
        self.x - self.origen_colision_x, 
        self.y - self.origen_colision_y, 
        self.anchoColision, 
        self.altoColision
    ) 
    -- Agrega al mundo de colisiones
    self.direccion_actual = "abajo"

    -- Animaciones verticales por cada columna del spritesheet Walk.png
    self.animaciones = {
        abajo  = Animacion.crear("img/Walk.png", 3, self.ancho, self.alto, 8, true, 0),
        arriba = Animacion.crear("img/Walk.png", 3, self.ancho, self.alto, 8, true, 1),
        izquierda = Animacion.crear("img/Walk.png", 3, self.ancho, self.alto, 8, true, 2),
        derecha = Animacion.crear("img/Walk.png", 3, self.ancho, self.alto, 8, true, 3)

    }

    self.animacionActual = self.animaciones.abajo


    self.animacion_poder =  Animacion.crear("img/Poder.png", 8, 53, 35, 12, false, 0)
    self.poder_activo = false

    -- Suscripción a señales de habilidad
    Signal.register("onda_expansiva", function()
        self.poder_activo = true
        self.animacion_poder.activado = true
        self.animacion_poder.indice = 1
        end)

        Signal.register("fin_onda_expansiva", function()
        self.poder_activo = false
        self.animacion_poder.activado = false
        end)

end



function Jugador:Actualizar(dt)
    local seMueve = false
    local anterior_x = self.x
    local anterior_y = self.y

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
    -- Sincronizar posición con Bump
    if seMueve and self.mundo then
        self.mundo:update(self, self.x - self.origen_colision_x, self.y - self.origen_colision_y)
    

    --consulta si toca una pared
        local x, y, w, h = self.mundo:getRect(self)
        local elementos, cantidad = self.mundo:queryRect(x, y, w, h)
        for i = 1, cantidad do
            local item = elementos[i]
            if item ~= self and item.esPared then
                -- Si colisiona con una pared, revertir al estado anterior
                self.x = anterior_x
                self.y = anterior_y
            
                self.mundo:update(self, self.x - self.origen_colision_x, self.y - self.origen_colision_y)
                break
            end
        end
    end

    -- Actualización de la animación activa
    self.animacionActual.activado = seMueve
    if seMueve then
        Animacion.actualizar(self.animacionActual, dt)
    else
        self.animacionActual.indice = 1
    end

    -- Actualizar el efecto de poder si está activo
    if self.poder_activo then
        Animacion.actualizar(self.animacion_poder, dt)
    end

end

function Jugador:RecibirDanio()
    if not self.invulnerable then
        love.event.push("sonido_danio") -- dispara el evcento daño
    
    self.invulnerable = true
    self.color = {1, 0.4, 0.4, 0.7}

    Timer.after(4, function() self.invulnerable = false self.color = {1, 1, 1, 1} end) -- Temporizador para invulnerabilidad de 4 segundos
    self.vidas = self.vidas - 1
    love.event.push("actualizar_vidas", self.vidas) --Push al handler para actualizar el texto de vidas
    end
end

function Jugador:Dibujar()
    love.graphics.setColor(self.color)
    Animacion.dibujar(self.animacionActual, self.x, self.y, self.origen_x, self.origen_y)
    love.graphics.setColor(1, 1, 1)

    if self.poder_activo then
        Animacion.dibujar(self.animacion_poder, self.x, self.y, 26.5, 17.5)

    end
end


function Jugador:colision()
    --Le pide a Bump las coordenadas exactas de la caja de este jugador
    local x, y, w, h = self.mundo:getRect(self)

    --SE fija en esa área exacta para ver qué estamos tocando
    local items, cantidad = self.mundo:queryRect(x, y, w, h)

    --Revisa la lista de objetos encontrados
    for i = 1, cantidad do
        local item = items[i]

        -- Si el objeto no soy yo mismo y ademas tiene la etiqueta de enemigo
        if item ~= self and item.esEnemigo then
            return item  -- Le devolvemos el enemigo encontrado a quien llamo a la funcion
        end
    end

    -- 4. Si termino el bucle y no toco a ningún enemigo, devuelve nil (nada)
    return nil
end