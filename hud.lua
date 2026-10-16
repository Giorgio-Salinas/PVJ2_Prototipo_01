HUD = Class{}

function HUD:init(mundo)
    self.mundo = mundo
    self.texto_vidas = ""
    self.texto_objetivo = ""

    love.handlers.actualizar_vidas = function(vidas) self.texto_vidas = "Vidas: " .. vidas end
    love.handlers.actualizar_objetivos = function(derrotados, objetivo) self.texto_objetivo = "Objetivo: " .. derrotados .. " / " .. objetivo end
    love.handlers.modoDebug = function() self:modoDebug() end


end

function HUD:modoDebug()
    depurar = not depurar
end

function HUD:dibujarHitboxes()
    if not depurar then return end

    love.graphics.setColor(0, 1, 0)
    local items = self.mundo:getItems()
    for _, item in ipairs(items) do
        local x, y, ancho, alto = self.mundo:getRect(item)
        love.graphics.rectangle("line", x, y, ancho, alto)
    end
    love.graphics.setColor(1, 1, 1)
end

function HUD:dibujar()

    love.graphics.setFont(fuentes.pequena)
    
    -- Textos de la parte superior (en negro)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.texto_vidas, 4, 4)
    love.graphics.printf(self.texto_objetivo, 0, 4, ventana.ancho - 4, "right")

    -- Texto del Debug en la esquina inferior izquierda (magenta)
    local estadoDebug = depurar and "ON" or "OFF"
    love.graphics.setColor(1, 0, 1)
    love.graphics.print(" Hitbox Debug: " .. estadoDebug, 4, ventana.alto - 10)

    -- Restauramos el color original
    love.graphics.setColor(1, 1, 1)

end