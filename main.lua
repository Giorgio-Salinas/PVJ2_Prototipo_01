require("dependencias")

ventana = {
    ancho  = 160,
    alto   = 144,
    escala = 4,
    camara_centro_x = 0,
    camara_centro_y = 0,
    mapa_ancho = 0,
    mapa_alto = 0

}
depurar = false


function redondear(n)
    return math.floor(n + 0.5)
end


function love.load()
    
    math.randomseed(os.time())
    love.window.setMode(ventana.ancho * ventana.escala, ventana.alto * ventana.escala)
    love.graphics.setDefaultFilter("nearest", "nearest")
    lienzo = love.graphics.newCanvas(ventana.ancho, ventana.alto)
    

    --Inicializa el gestor de audio desacoplado
    gestorAudio = GestorAudio()

    -- Inicialización de la Máquina de Estados
    maquinaEstados = MaquinaEstados({
        ["titulo"] = function() return EstadoTitulo() end,
        ["jugar"]  = function() return EstadoJugar() end,
        ["derrota"] = function() return EstadoDerrota() end,
        ["victoria"] = function() return EstadoVictoria() end
    })

    maquinaEstados:cambiar("titulo")
    
end



function love.keypressed(key)

    if key == "f1" then
        love.event.push("modoDebug") --Push al handler para cambiar el modo debug
    end

    if key == "escape" then
        love.event.quit()
        return
    end

    maquinaEstados:keypressed(key)
end

function love.update(dt)
    Timer.update(dt)
    maquinaEstados:actualizar(dt)
end

function love.draw()

    
    
    love.graphics.setCanvas(lienzo)
    love.graphics.clear(0.12, 0.12, 0.18)
   

    -- Dibuja el estado activo
    maquinaEstados:dibujar()

    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()

    love.graphics.draw(lienzo, 0, 0, 0, ventana.escala, ventana.escala)
end