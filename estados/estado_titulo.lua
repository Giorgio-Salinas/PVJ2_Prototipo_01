EstadoTitulo = Class{__includes = Estado}

function EstadoTitulo:init()
end

function EstadoTitulo:actualizar(dt)
    if love.keyboard.isDown("return") then
        maquinaEstados:cambiar("jugar")
    end
end

function EstadoTitulo:dibujar()
    love.graphics.setFont(fuentes.grande)
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("ARENA 2D", 0, ventana.alto / 4, ventana.ancho, "center")
   love.graphics.setFont(fuentes.mediana)
   love.graphics.setColor(1, 1, 0)
    love.graphics.printf("Presiona ENTER para jugar\nPresiona Esc para salir", 0, ventana.alto / 2, ventana.ancho, "center")
    love.graphics.setFont(fuentes.pequena)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Presiona F1 para on / off el modo debug", 0, ventana.alto - 40, ventana.ancho, "center")
    love.graphics.printf("Presiona X para activar la habilidad especial", 0, ventana.alto - 20, ventana.ancho, "center")
end