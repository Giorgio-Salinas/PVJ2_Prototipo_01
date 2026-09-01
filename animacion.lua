-- ================= MODULO DE ANIMACION =================
local Animacion = {}

-- offset define qué columna (X) o fila (Y) recortar
function Animacion.crear(rutaImg, limiteFrames, anchoQuad, altoQuad, velocidad, esVertical, offset)
    local anim = {}
    anim.spriteSheet = love.graphics.newImage(rutaImg)
    anim.limiteFrames = limiteFrames
    anim.ancho = anchoQuad
    anim.alto = altoQuad
    anim.velocidad = velocidad or 8
    anim.esVertical = esVertical or false
    anim.indice = 1
    anim.activado = true

    local despX = (anim.esVertical and (offset or 0) * anim.ancho) or 0
    local despY = (not anim.esVertical and (offset or 0) * anim.alto) or 0

    anim.quads = {}
    for i = 0, limiteFrames do
        local x = anim.esVertical and despX or (i * anim.ancho)
        local y = anim.esVertical and (i * anim.alto) or despY

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
            anim.indice = 1
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