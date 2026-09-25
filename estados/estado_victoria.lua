EstadoVictoria = Class{__includes = Estado}

function EstadoVictoria:init()
end

function EstadoVictoria:keypressed(key)
    -- Con R vuelve a jugar una partidar
    if key == "r" then
        maquinaEstados:cambiar("jugar")
    end
end

function EstadoVictoria:actualizar(dt)
end

function EstadoVictoria:dibujar()
    love.graphics.setFont(fuentes.grande)
    love.graphics.setColor(0.2, 1, 0.2)
    love.graphics.printf("VICTORIA!", 0, ventana.alto / 3, ventana.ancho, "center")
     love.graphics.setFont(fuentes.mediana)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Presiona R para reiniciar\no ESCAPE para salir", 0, ventana.alto / 2, ventana.ancho, "center")
end