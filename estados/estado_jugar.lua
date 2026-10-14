EstadoJugar = Class{__includes = Estado}

function EstadoJugar:init()
    -- Mapa
    self.mapa = STI("mapa/arena1.lua")
    self.mundo = Bump.newWorld(16)
    
     
    --Pregunta si en el mapa existe la capa llamada "Colisiones"
    if self.mapa.layers["Colisiones"] then
        
        --Recorre con un bucle todos los objetos rectangulares dibujados en esa capa
        for _, objeto in ipairs(self.mapa.layers["Colisiones"].objects) do
            
            --Le pega la etiqueta de que es una pared / obstáculo
            objeto.esPared = true
            
            
            --Lo registra en la libreta del árbitro Bump
            self.mundo:add(objeto, objeto.x, objeto.y, objeto.width, objeto.height)
        end
    end
    
    -- Variables de control de la partida
    self.derrotados = 0
    self.objetivo = 5
    self.texto_objetivo = ""
    love.handlers.actualizar_objetivos = function(derrotados, objetivo)
        self.texto_objetivo = "Objetivo: " .. derrotados .. "/" .. objetivo
    end
    love.event.push("actualizar_objetivos", self.derrotados, self.objetivo)

    -- Spawner
    self.timerSpawn = 0
    self.tiempoEntreSpawns = 3.5
    self.maxEnemigos = 4
    self.texto_vidas = ""
    love.handlers.actualizar_vidas = function(vidas) --Handlers para actualizar el texto de vidas
        self.texto_vidas = "Vidas: " .. vidas
    end
    -- Entidades de la partida
    self.pj = Jugador(ventana.ancho / 2, ventana.alto / 2, 60, self.mundo)
    --Camara
    self.camara_principal = Camara(self.pj.x, self.pj.y)
    
    -- Enemigos posicionados en Tiled
    self.enemigos = {}

    if self.mapa.layers["Generadores"] then
        for _, objeto in ipairs(self.mapa.layers["Generadores"].objects) do
            if objeto.name == "Robot" then
                table.insert(self.enemigos, Robot(objeto.x + objeto.width / 2, objeto.y + objeto.height / 2, self.mundo))
            elseif objeto.name == "Bestia" then
                table.insert(self.enemigos, Bestia(objeto.x + objeto.width / 2, objeto.y + objeto.height / 2, self.mundo))
            end
        end
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

        -- spawn de enemigos cada cierto tiempo
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

        --cada enemigo camina y actualice su posición
        for _, enemigo in ipairs(self.enemigos) do
            enemigo:Actualizar(dt, self.pj)
        end

        -- Le preguntamos al jugador si chocó contra algún enemigo
        local colisionCon = self.pj:colision()

        if colisionCon then
            if self.ataque and self.ataque.activado then
                self.derrotados = self.derrotados + 1
                love.event.push("actualizar_objetivos", self.derrotados, self.objetivo)
                colisionCon:Reiniciar(ventana)
                self.ataque.activado = false
                self.ataque.indice = 1

                if self.derrotados >= self.objetivo then
                    if sonidos.ToroYPampa then sonidos.ToroYPampa:stop() end
                    if sonidos.Ganar then sonidos.Ganar:play() end
                    maquinaEstados:cambiar("victoria")
                end
            else
                
                self.pj:RecibirDanio()
              

                if self.pj.vidas <= 0 then
                    if sonidos.ToroYPampa then sonidos.ToroYPampa:stop() end
                    if sonidos.GameOver then sonidos.GameOver:play() end
                    maquinaEstados:cambiar("derrota")
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

    love.graphics.setColor(1, 1, 1)
     

    for _, enemigo in ipairs(self.enemigos) do
        enemigo:Dibujar()
    end

    if self.ataque and self.ataque.activado then
        love.graphics.setColor(1, 1, 1)
        Animacion.dibujar(self.ataque, self.pj.x, self.pj.y, 32, 32)
    end
    
    -- Dibujar hitboxes de Bump
    if depurar then
        love.graphics.setColor(0, 1, 0)
        local items = self.mundo:getItems()
        for _, item in ipairs(items) do
            local x, y, ancho, alto = self.mundo:getRect(item)
            love.graphics.rectangle("line", x, y, ancho, alto)
        end
    end
    love.graphics.setColor(1, 1, 1)

    self.camara_principal:detach()

    love.graphics.setFont(fuentes.pequena)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.texto_vidas, 4, 4)
    love.graphics.printf(self.texto_objetivo, 0, 4, ventana.ancho - 4, "right")
end


function EstadoJugar:keypressed(key)
    
    if key == "space" and not self.ataque.activado then
        local dir = self.pj.direccion_actual or "abajo"
        self.ataque = self.ataques[dir] or self.ataques.abajo
        self.ataque.activado = true
        self.ataque.indice = 1
        if sonidos.Golpe then
            sonidos.Golpe:clone():play()
        end
    end
end