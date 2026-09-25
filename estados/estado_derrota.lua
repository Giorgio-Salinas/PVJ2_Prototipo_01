EstadoDerrota = Class{__includes = Estado}

function EstadoDerrota:init()
end

function EstadoDerrota:keypressed(key)
    if key == "r" then
        -- Con R vuelve a jugar una partida
        maquinaEstados:cambiar("jugar")
    end
end

function EstadoDerrota:actualizar(dt)
end

function EstadoDerrota:dibujar()
    love.graphics.setFont(fuentes.grande)
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("GAME OVER", 0, ventana.alto / 3, ventana.ancho, "center")
    love.graphics.setFont(fuentes.pequena)
    love.graphics.setColor(1, 1, 0)
    love.graphics.printf("Presiona R para reiniciar\no ESCAPE para salir", 0, ventana.alto / 2, ventana.ancho, "center")
end