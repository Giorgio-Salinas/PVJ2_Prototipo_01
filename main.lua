require("dependencias")

sonidos = {}

ventana = {
    ancho  = 160,
    alto   = 144,
    escala = 4
}

function redondear(n)
    return math.floor(n + 0.5)
end

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

    -- Carga de audios globales
    sonidos.ToroYPampa = love.audio.newSource("SFX/ToroYPampa.mp3", "stream")
    sonidos.ToroYPampa:setLooping(true)
    sonidos.ToroYPampa:setVolume(0.4)

    sonidos.Golpe = love.audio.newSource("SFX/SFX_Golpe.mp3", "static")
    sonidos.Danio = love.audio.newSource("SFX/SFX_Danio.mp3", "static")
    sonidos.Ganar = love.audio.newSource("SFX/SFX_Ganar.mp3", "static")
    sonidos.GameOver = love.audio.newSource("SFX/SFX_GameOver.mp3", "static")

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
    if key == "escape" then
        love.event.quit()
        return
    end

    maquinaEstados:keypressed(key)
end

function love.update(dt)
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