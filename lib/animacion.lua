-- ================= MODULO DE ANIMACION =================
local Animacion = {}

-- offset define qué columna (X) o fila (Y) recortar
-- enBucle define si se repite infinitamente (true) o se ejecuta una sola vez (false)
function Animacion.crear(rutaImg, limiteFrames, anchoQuad, altoQuad, velocidad, esVertical, offset, enBucle)
    local anim = {}
    anim.spriteSheet = love.graphics.newImage(rutaImg)
    anim.limiteFrames = limiteFrames
    anim.ancho = anchoQuad
    anim.alto = altoQuad
    anim.velocidad = velocidad or 8
    anim.esVertical = esVertical or false
    anim.indice = 1
    anim.activado = true
    
    if enBucle == nil then
        anim.enBucle = true
     else
        anim.enBucle = enBucle
    end

    local filaOColumna = offset or 0
    anim.quads = {}

    for i = 0, limiteFrames do
        local x, y
        if anim.esVertical then
            -- Se mueve verticalmente en una columna fija
            x = filaOColumna * anim.ancho
            y = i * anim.alto
        else
            -- Se mueve horizontalmente en una fila fija
            x = i * anim.ancho
            y = filaOColumna * anim.alto
        end

        local quad = love.graphics.newQuad(
            x, y,
            anim.ancho, anim.alto,
            anim.spriteSheet:getDimensions()
        )
        table.insert(anim.quads, quad)
    end

    return anim
end

function Animacion.actualizar(anim, dt)
    if anim.activado then
        anim.indice = anim.indice + (anim.velocidad * dt)
        
        if anim.indice > anim.limiteFrames + 1 then
            if anim.enBucle then
                anim.indice = 1
            else
                -- Si no tiene bucle, se apaga la animación y se resetea el índice
                anim.indice = 1
                anim.activado = false
            end
        end
    end
end

function Animacion.dibujar(anim, x, y, ox, oy)
    local frameActual = math.floor(anim.indice)
    if frameActual > #anim.quads then frameActual = #anim.quads end
    if frameActual < 1 then frameActual = 1 end

    love.graphics.draw(
        anim.spriteSheet,
        anim.quads[frameActual],
        redondear(x),
        redondear(y),
        0,
        1,
        1,
        ox or 0,
        oy or 0
    )
end

return Animacion