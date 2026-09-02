require "jugador"
require "enemigo"

local huboColision = false
local tiempoPausa = 0

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
    local a_izq = a.x - a.origen_x
    local a_der = a.x + a.origen_x
    local a_arr = a.y - a.origen_y
    local a_aba = a.y + a.origen_y

    local b_izq = b.x - b.origen_x
    local b_der = b.x + b.origen_x
    local b_arr = b.y - b.origen_y
    local b_aba = b.y + b.origen_y

    return a_der > b_izq and
           a_izq < b_der and
           a_aba > b_arr and
           a_arr < b_aba
end

local huboColision = false

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)

    
    pj = Jugador:Nuevo(ventana.ancho / 2, ventana.alto / 2, 60)
    malo = Enemigo:Nuevo(20, 20, 35)
end

function love.update(dt)
    if not huboColision then
        pj:Actualizar(dt, ventana)
        malo:Actualizar(dt, pj)

        -- Al colisionar: activa pausa, descuenta vida y arranca temporizador
        if verificarColision(pj, malo) then
            huboColision = true
            tiempoPausa = 0.5
            pj:RecibirDanio()
        end
    else
        -- Cuenta regresiva mientras dura el impacto
        tiempoPausa = tiempoPausa - dt
        if tiempoPausa <= 0 then
            huboColision = false
            pj:Reiniciar()
            malo:Reiniciar()
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

        love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()

    
    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)

    
    love.graphics.print("Vidas: " .. pj.vidas, 10, 10)
end
