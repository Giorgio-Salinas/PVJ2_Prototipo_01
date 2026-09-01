require "jugador"

ventana = {
    ancho  = 160,
    alto   = 144,
    escala = 4
}

function redondear(n)
    return math.floor(n + 0.5)
end

function love.load()
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)

    -- Instanciar jugador
    pj = Jugador:Nuevo(ventana.ancho / 2, ventana.alto / 2, 60)
end

function love.update(dt)
    pj:Actualizar(dt, ventana)
end

function love.draw()
    love.graphics.setCanvas(lienzo)
        love.graphics.clear(0.12, 0.12, 0.18)
        pj:Dibujar()
    love.graphics.setCanvas()

    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)
end