-- Archivo central de dependencias--

--libreria
Class = require ("lib.class")

--modulo auxiliar

Animacion = require("lib/animacion")

-- Entidades y clases

require("entidades.jugador")
require("entidades.enemigo")
require("entidades.robot")
require("entidades.bestia")

-- Maquina de estados y estados
require("estados/estado")
require("estados/maquina_estados")
require("estados/estado_titulo")
require("estados/estado_jugar")
require("estados/estado_derrota")
require("estados/estado_victoria")

-- fuente
fuentes = {
    pequena = love.graphics.newFont("fuente/PIXELSIX10.TTF", 8, "mono"),
    mediana = love.graphics.newFont("fuente/PIXELSIX10.TTF", 10, "mono"),
    grande  = love.graphics.newFont("fuente/ROBOT ROC.OTF", 16, "mono")
}
