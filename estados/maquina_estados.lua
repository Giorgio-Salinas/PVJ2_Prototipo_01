MaquinaEstados = Class{}

function MaquinaEstados:init(estados)
    self.estados = estados or {}
    self.estadoActual = nil
    
end

function MaquinaEstados:cambiar(nombreEstado, params)
    assert(self.estados[nombreEstado], "El estado " .. tostring(nombreEstado) .. " no existe.")
    
    if self.estadoActual and self.estadoActual.salir then
        self.estadoActual:salir()
    end

    self.estadoActual = self.estados[nombreEstado]()
    self.estadoActual:ingresar(params)
end

function MaquinaEstados:actualizar(dt)
    if self.estadoActual then
        self.estadoActual:actualizar(dt)
    end
end

function MaquinaEstados:dibujar()
    if self.estadoActual then
        self.estadoActual:dibujar()
    end
end

function MaquinaEstados:keypressed(key)
    if self.estadoActual and self.estadoActual.keypressed then
        self.estadoActual:keypressed(key)
    end
end