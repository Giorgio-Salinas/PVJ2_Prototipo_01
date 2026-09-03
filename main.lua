require "jugador"
require "enemigo"

local huboColision = false
local tiempoPausa = 0
local derrota = false

local Animacion = require "animacion"

local ataque = nil
local victoria = false
local derrotados = 0
local objetivo = 5

-- contenedor de audios
local sonidos = {}


ventana = {
    ancho  = 160,
    alto   = 144,
    escala = 4
}

function redondear(n)
    return math.floor(n + 0.5)
end

-- Deteccion de colision por cajas (AABB)

function verificarColision(a, b)
    local ra = a.radio_colision or a.origen_x
    local rb = b.radio_colision or b.origen_x

    local a_izq = a.x - ra
    local a_der = a.x + ra
    local a_arr = a.y - ra
    local a_aba = a.y + ra

    local b_izq = b.x - rb
    local b_der = b.x + rb
    local b_arr = b.y - rb
    local b_aba = b.y + rb

    return a_der > b_izq and
           a_izq < b_der and
           a_aba > b_arr and
           a_arr < b_aba
end


function love.load()
    math.randomseed(os.time())
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)

    -- Carga de audio (stream para musica larga, static para SFX cortos)
    sonidos.ToroYPampa = love.audio.newSource("SFX/ToroYPampa.mp3","stream")
    sonidos.ToroYPampa:setLooping(true)
    sonidos.ToroYPampa:setVolume(0.4)
    sonidos.ToroYPampa:play()

    sonidos.Golpe = love.audio.newSource("SFX/SFX_Golpe.mp3", "static")
    sonidos.Danio = love.audio.newSource("SFX/SFX_Danio.mp3", "static")
    sonidos.Ganar = love.audio.newSource("SFX/SFX_Ganar.mp3", "static")
    sonidos.GameOver = love.audio.newSource("SFX/SFX_GameOver.mp3", "static")

    pj = Jugador:Nuevo(ventana.ancho / 2, ventana.alto / 2, 60)
    malo = Enemigo:Nuevo(20, 20, 25)
    malo:PosicionarAleatorio(ventana)

   -- Animaciones de ataque direccionales (columnas 0 a 3 en vertical)
    ataques = {
        abajo     = Animacion.crear("img/Hammer.png", 3, 64, 64, 12, true, 0, false),
        arriba    = Animacion.crear("img/Hammer.png", 3, 64, 64, 12, true, 1, false),
        izquierda = Animacion.crear("img/Hammer.png", 3, 64, 64, 12, true, 2, false),
        derecha   = Animacion.crear("img/Hammer.png", 3, 64, 64, 12, true, 3, false)
    }

    ataque = ataques.abajo
    ataque.activado = false
end

function love.keypressed(key)
    if key == "space" and not ataque.activado and not derrota and not victoria and not huboColision then
        
        -- Seleccionar la animación según hacia dónde mira el jugador
        ataque = ataques[pj.direccion_actual] or ataques.abajo
        ataque.activado = true
        ataque.indice = 1
        
        -- Reproducir sonido de ataque (clonado para permitir spam sin cortarse)
        sonidos.Golpe:clone():play()
    end
end

function love.update(dt)
    if derrota or victoria then
        return
    end

    -- Actualizar animación de ataque
    if ataque and ataque.activado then
        Animacion.actualizar(ataque, dt)
    end

    if not huboColision then
        pj:Actualizar(dt, ventana)
        malo:Actualizar(dt, pj)

        

        if verificarColision(pj, malo) then
            if ataque and ataque.activado then
                -- ATAQUE EXITOSO: Derrotamos al enemigo
                derrotados = derrotados + 1
                malo:Reiniciar(ventana)

                if derrotados >= objetivo then
                    victoria = true
                    sonidos.ToroYPampa:stop()
                    sonidos.Ganar:play()
                end
            else
                -- DAÑO AL JUGADOR: Se pausa, se tiñe de rojo y resta vida
                huboColision = true
                tiempoPausa = 0.5
                pj:RecibirDanio()
                sonidos.Danio:clone():play()

                if pj.vidas <= 0 then
                    derrota = true
                    sonidos.ToroYPampa:stop()
                    sonidos.GameOver:play()
                end
            end
        end
    
    else
        -- Cuenta regresiva mientras dura el impacto
        tiempoPausa = tiempoPausa - dt
        if tiempoPausa <= 0 then
            huboColision = false
            pj:Reiniciar()
            malo:Reiniciar(ventana)
        end
    end
end



function love.draw()
    love.graphics.setCanvas(lienzo)
        love.graphics.clear(0.12, 0.12, 0.18)

        -- Tinte de impacto en los personajes
        if huboColision then
            love.graphics.setColor(1, 0.3, 0.3)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        pj:Dibujar()
        malo:Dibujar()

        -- DIBUJAR EL ATAQUE
        if ataque and ataque.activado then
            love.graphics.setColor(1, 1, 1)
            Animacion.dibujar(ataque, pj.x, pj.y, 32, 32)
        end

    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()

    
    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)

    
    -- Interfaz de vida y derrota y objetivo
   if derrota then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.print("GAME OVER / DERROTA", 10, 10)
    elseif victoria then
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.print("VICTORIA!", 10, 10)
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Vidas: " .. pj.vidas, 10, 10)
        love.graphics.print("Objetivo: " .. derrotados .. "/" .. objetivo, (ventana.ancho * ventana.escala) - 150, 10)
    end
end
