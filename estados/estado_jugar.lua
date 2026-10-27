-- Función auxiliar para que la corrutina espere una cantidad de segundos antes de continuar
local function wait(segundos)
    local tiempo_transcurrido = 0
    while tiempo_transcurrido < segundos do
        local dt = coroutine.yield()
        tiempo_transcurrido = tiempo_transcurrido + (dt or 0)
    end
end


EstadoJugar = Class{__includes = Estado}

-- INIT
function EstadoJugar:init()
    -- Mapa
    self.mapa = STI("mapa/arena1.lua")
    self.mundo = Bump.newWorld(16)
    self.hud = HUD(self.mundo)
    
     
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
    self.maxEnemigos = 4
    love.event.push("actualizar_objetivos", self.derrotados, self.objetivo)

    -- Spawner
    -- Variables para avisos de la secuencia en pantalla
    self.textoAlerta = ""
    self.mostrarAlerta = false

    -- ==========================================================
    -- CORRUTINA: Secuencia de Oleadas y Jefe Final
    -- ==========================================================
    self.rutinaPartida = coroutine.create(function()
        -- 1. Cartel inicial
        self.textoAlerta = "¡SOBREVIVE A LA OLEADA!"
        self.mostrarAlerta = true
        wait(2.0)
        self.mostrarAlerta = false

        -- Spawnea enemigos hasta llegar a los 5 derrotados
        while self.derrotados < self.objetivo do
            self:invocarEnemigo()
            wait(2.5) -- Espera gestionada por la corrutina
        end

        -- Alerta del Jefe
        self.textoAlerta = "¡ALERTA: EL JEFE!"
        self.mostrarAlerta = true
        wait(3.0)
        self.mostrarAlerta = false

        -- Invocamos al Jefe
        local nuevoJefe = Jefe(ventana.ancho / 2, 40, self.mundo)
        table.insert(self.enemigos, nuevoJefe)

        -- 5. La corrutina espera a que el Jefe se quede sin vidas
        while nuevoJefe.vidas > 0 do
            wait(0.2)
        end

        -- Victoria al derrotar al Jefe
        self.textoAlerta = "¡JEFE DERROTADO!"
        self.mostrarAlerta = true
        love.event.push("sonido_ganar")
        wait(2.0)
        maquinaEstados:cambiar("victoria")
    end)
   
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

    -- dispara Música por evento
   love.event.push("reproducir_musica")

    -- Limites de la camara
    ventana.camara_centro_x = ventana.ancho / 2
    ventana.camara_centro_y = ventana.alto / 2
    ventana.mapa_ancho = self.mapa.width * self.mapa.tilewidth
    ventana.mapa_alto = self.mapa.height * self.mapa.tileheight
end

-- iNVOCAR ENEMIGO
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

-- ACTUALIZAR
function EstadoJugar:actualizar(dt)
   

        -- Reanudar la corrutina pasándole dt
    if self.rutinaPartida and coroutine.status(self.rutinaPartida) ~= "dead" then
        local exito, err = coroutine.resume(self.rutinaPartida, dt)
        if not exito then
            print("Error en corrutina de partida: " .. tostring(err))
        end
    end

    --pausa la actualización si se está mostrando el cartel de alerta
    if self.mostrarAlerta then
        return
    end
    -- animacion del ataque si está activada
     if self.ataque and self.ataque.activado then
        Animacion.actualizar(self.ataque, dt)
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
            self.ataque.activado = false
            self.ataque.indice = 1

            if colisionCon.esJefe then
                -- Golpe al Jefe: le descontamos 1 vida
                colisionCon.vidas = colisionCon.vidas - 1
                love.event.push("sonido_golpe")

                if colisionCon.vidas <= 0 then
                    -- Al morir, lo quitamos de Bump y de la lista de enemigos
                    if self.mundo:hasItem(colisionCon) then
                        self.mundo:remove(colisionCon)
                    end
                    for i, e in ipairs(self.enemigos) do
                        if e == colisionCon then
                            table.remove(self.enemigos, i)
                            break
                        end
                    end
                end
            else
                -- Golpe a enemigo común: suma punto y reaparece
                self.derrotados = self.derrotados + 1
                love.event.push("actualizar_objetivos", self.derrotados, self.objetivo)
                colisionCon:Reiniciar(ventana)
            end
        else
                
                self.pj:RecibirDanio()
              

                if self.pj.vidas <= 0 then
                    love.event.push("sonido_perder") -- dispara evento para reproducir el sonido de derrota
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

    self.hud:dibujarHitboxes()

    self.camara_principal:detach()

    self.hud:dibujar()

    -- Cartel de alerta gestionado por la corrutina
    if self.mostrarAlerta then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, ventana.alto / 2 - 20, ventana.ancho, 35)
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.printf(self.textoAlerta, 0, ventana.alto / 2 - 10, ventana.ancho, "center")
        love.graphics.setColor(1, 1, 1, 1)
    end
end



function EstadoJugar:keypressed(key)
    if self.mostrarAlerta then
        return
    end
    
    if key == "space" and not self.ataque.activado then
        local dir = self.pj.direccion_actual or "abajo"
        self.ataque = self.ataques[dir] or self.ataques.abajo
        self.ataque.activado = true
        self.ataque.indice = 1
        love.event.push("sonido_golpe") -- evento para reproducir el sonido de golpe
    end
    if key == "x" then
        
        Signal.emit("onda_expansiva")-- Emisión de evento 1 a N: notifica el inicio de la habilidad a todos los suscriptores
        love.event.push("sonido_ondaExpansiva") -- evento para reproducir el sonido de onda expansiva
        Timer.after(5, function() Signal.emit("fin_onda_expansiva") end)
    end

end