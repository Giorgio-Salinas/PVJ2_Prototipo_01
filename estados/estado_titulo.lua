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
    love.graphics.printf("ARENA 2D", 0, ventana.alto / 3, ventana.ancho, "center")
   love.graphics.setFont(fuentes.mediana)
   love.graphics.setColor(1, 1, 0)
    love.graphics.printf("Presiona ENTER para jugar\nPresiona Esc para salir", 0, ventana.alto / 2, ventana.ancho, "center")
end