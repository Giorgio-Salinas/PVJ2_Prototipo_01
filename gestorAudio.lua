GestorAudio = Class{}

function GestorAudio:init()

    self.sonidos = {}

    -- Carga de audios globales
    self.sonidos.ToroYPampa = love.audio.newSource("SFX/ToroYPampa.mp3", "stream")
    self.sonidos.ToroYPampa:setLooping(true)
    self.sonidos.ToroYPampa:setVolume(0.4)

    self.sonidos.Golpe = love.audio.newSource("SFX/SFX_Golpe.mp3", "static")
    self.sonidos.Danio = love.audio.newSource("SFX/SFX_Danio.mp3", "static")
    self.sonidos.Ganar = love.audio.newSource("SFX/SFX_Ganar.mp3", "static")
    self.sonidos.GameOver = love.audio.newSource("SFX/SFX_GameOver.mp3", "static")

    love.handlers.reproducir_musica = function() self:reproducirMusica() end
    love.handlers.sonido_golpe = function() self:reproducirGolpe() end
    love.handlers.sonido_danio = function() self:reproducirDanio() end
    love.handlers.sonido_ganar = function() self:reproducirGanar() end
    love.handlers.sonido_perder = function() self:reproducirPerder() end

end

function GestorAudio:reproducirMusica()
    if self.sonidos.ToroYPampa then
        self.sonidos.ToroYPampa:stop()
        self.sonidos.ToroYPampa:play()
    end
end

function GestorAudio:reproducirGolpe()
    if self.sonidos.Golpe then
        self.sonidos.Golpe:clone():play()
    end
end

function GestorAudio:reproducirDanio()
    if self.sonidos.Danio then
        self.sonidos.Danio:stop()
        self.sonidos.Danio:play()
    end
end

function GestorAudio:reproducirGanar()
    if self.sonidos.ToroYPampa then self.sonidos.ToroYPampa:stop() end
    if self.sonidos.Ganar then self.sonidos.Ganar:play() end
end

function GestorAudio:reproducirPerder()
    if self.sonidos.ToroYPampa then self.sonidos.ToroYPampa:stop() end
    if self.sonidos.GameOver then self.sonidos.GameOver:play() end
end