EstadoJugar = Class{__includes = Estado}

function EstadoJugar:init()
    -- Mapa
    self.mapa = STI("mapa/arena1.lua")
    self.mundo = Bump.newWorld(16)
     
    
    -- Variables de control de la partida
    self.huboColision = false
    self.tiempoPausa = 0
    self.derrotados = 0
    self.objetivo = 5

    -- Spawner
    self.timerSpawn = 0
    self.tiempoEntreSpawns = 3.5
    self.maxEnemigos = 4

    -- Entidades de la partida
    self.pj = Jugador(ventana.ancho / 2, ventana.alto / 2, 60, self.mundo)
    --Camara
    self.camara_principal = Camara(self.pj.x, self.pj.y)
    
    self.enemigos = {
        Robot(20, 20, self.mundo),
        Bestia(20, 20, self.mundo)
    }

    for _, enemigo in ipairs(self.enemigos) do
        enemigo:PosicionarAleatorio(ventana)
    end

    while self.enemigos[1].x == self.enemigos[2].x and self.enemigos[1].y == self.enemigos[2].y do
        self.enemigos[2]:PosicionarAleatorio(ventana)
    end

    -- Animaciones de ataque
    self.ataques = {
        abajo     = Animacion.crear("img/Hammer.png", 3, 64, 64, 12, true, 0, false),
        arriba    = Animacion.crear("img/Hammer.png", 3, 64, 64, 12, true, 1, false),
        izquierda = Animacion.crear("img/Hammer.png", 3, 64, 64, 12, true, 2, false),
        derecha   = Animacion.crear("img/Hammer.png", 3, 64, 64, 12, true, 3, false)
    }

    self.ataque = self.ataques.abajo
    self.ataque.activado = false

    -- Música
    if sonidos.ToroYPampa then
        sonidos.ToroYPampa:stop()
        sonidos.ToroYPampa:play()
    end

    -- Limites de la camara
    ventana.camara_centro_x = ventana.ancho / 2
    ventana.camara_centro_y = ventana.alto / 2
    ventana.mapa_ancho = self.mapa.width * self.mapa.tilewidth
    ventana.mapa_alto = self.mapa.height * self.mapa.tileheight
end

function EstadoJugar:invocarEnemigo()
    if #self.enemigos >= self.maxEnemigos then
        return
    end

    local nuevo = nil
    if math.random() < 0.5 then
        nuevo = Robot(20, 20, self.mundo)
    else
        nuevo = Bestia(20, 20, self.mundo)
    end

    nuevo:PosicionarAleatorio(ventana)
    table.insert(self.enemigos, nuevo)
end

function EstadoJugar:actualizar(dt)
    if self.ataque and self.ataque.activado then
        Animacion.actualizar(self.ataque, dt)
    end

    if not self.huboColision then
        self.timerSpawn = self.timerSpawn + dt
        if self.timerSpawn >= self.tiempoEntreSpawns then
            self.timerSpawn = 0
            self:invocarEnemigo()
        end

        self.pj:Actualizar(dt)
        self.camara_principal:lookAt(self.pj.x, self.pj.y)

        if self.camara_principal.x < ventana.camara_centro_x then
            self.camara_principal.x = ventana.camara_centro_x
        elseif self.camara_principal.x > ventana.mapa_ancho - ventana.camara_centro_x then
            self.camara_principal.x = ventana.mapa_ancho - ventana.camara_centro_x
        end

        if self.camara_principal.y < ventana.camara_centro_y then
            self.camara_principal.y = ventana.camara_centro_y
        elseif self.camara_principal.y > ventana.mapa_alto - ventana.camara_centro_y then
            self.camara_principal.y = ventana.mapa_alto - ventana.camara_centro_y
        end

        local colisionCon = nil
        for _, enemigo in ipairs(self.enemigos) do
            enemigo:Actualizar(dt, self.pj)
            if verificarColision(self.pj, enemigo) then
                colisionCon = enemigo
            end
        end

        if colisionCon then
            if self.ataque and self.ataque.activado then
                self.derrotados = self.derrotados + 1
                colisionCon:Reiniciar(ventana)
                self.ataque.activado = false
                self.ataque.indice = 1

                if self.derrotados >= self.objetivo then
                    if sonidos.ToroYPampa then sonidos.ToroYPampa:stop() end
                    if sonidos.Ganar then sonidos.Ganar:play() end
                    maquinaEstados:cambiar("victoria")
                end
            else
                self.huboColision = true
                self.tiempoPausa = 0.5
                self.pj:RecibirDanio()
                if sonidos.Danio then sonidos.Danio:clone():play() end

                if self.pj.vidas <= 0 then
                    if sonidos.ToroYPampa then sonidos.ToroYPampa:stop() end
                    if sonidos.GameOver then sonidos.GameOver:play() end
                    maquinaEstados:cambiar("derrota")
                end
            end
        end
    else
        self.tiempoPausa = self.tiempoPausa - dt
        if self.tiempoPausa <= 0 then
            self.huboColision = false
            self.pj:Reiniciar()
            for _, enemigo in ipairs(self.enemigos) do
                enemigo:Reiniciar(ventana)
            end
        end
    end
end

function EstadoJugar:dibujar()

    self.camara_principal:attach(0, 0, ventana.ancho, ventana.alto)

    if self.mapa.layers["Piso"] then
    self.mapa:drawLayer(self.mapa.layers["Piso"])
    end

    self.pj:Dibujar()

    if self.mapa.layers["Deco"] then
    self.mapa:drawLayer(self.mapa.layers["Deco"])
    end

    if self.huboColision then
        love.graphics.setColor(1, 0.3, 0.3)
    else
        love.graphics.setColor(1, 1, 1)
    end
        
    
    

    for _, enemigo in ipairs(self.enemigos) do
        enemigo:Dibujar()
    end

    if self.ataque and self.ataque.activado then
        love.graphics.setColor(1, 1, 1)
        Animacion.dibujar(self.ataque, self.pj.x, self.pj.y, 32, 32)
    end
    
    -- Dibujar hitboxes de Bump
    love.graphics.setColor(0, 1, 0)
    local items = self.mundo:getItems()
    for _, item in ipairs(items) do
        local x, y, ancho, alto = self.mundo:getRect(item)
        love.graphics.rectangle("line", x, y, ancho, alto)
    end
    love.graphics.setColor(1, 1, 1)

    self.camara_principal:detach()

    love.graphics.setFont(fuentes.pequena)
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("Vidas: " .. self.pj.vidas, 4, 4)
    local textoObjetivo = "Objetivo: " .. self.derrotados .. "/" .. self.objetivo
    love.graphics.printf(textoObjetivo, 0, 4, ventana.ancho - 4, "right")
end

function EstadoJugar:keypressed(key)
    if key == "space" and not self.ataque.activado and not self.huboColision then
        local dir = self.pj.direccion_actual or "abajo"
        self.ataque = self.ataques[dir] or self.ataques.abajo
        self.ataque.activado = true
        self.ataque.indice = 1
        if sonidos.Golpe then
            sonidos.Golpe:clone():play()
        end
    end
end