utf8 = require("utf8")

Timer = require("lib.hump.timer")
Gamestate = require("lib.hump.gamestate")
vector = require("lib.hump.vector")
Class = require("lib.hump.class")
Signal = require("lib.hump.signal")
Camera = require("lib.hump.camera")

gui = require("gui")

highscore = require("lib.sick")

require("lib.TEsound")

require("menu")
require("game")
require("scoreboard")



pause = false

camera = nil

function love.load()

    Gamestate.registerEvents()
    text = ""
    camera = Camera()

    font = love.graphics.newFont("font/courbd.ttf", 24);
    smallFont = love.graphics.newFont("font/courbd.ttf", 18);
    love.graphics.setFont(font)

    highscore.set("hs", 10, "", -1)

    loadSounds()

    love.keyboard.setKeyRepeat(true)

    texTile = love.graphics.newImage("textures/tile2.png")
    texTileBg = love.graphics.newImage("textures/tile2bg.png")
    texTextBox = love.graphics.newImage("textures/tileTextBox.png")
    texButton = love.graphics.newImage("textures/tile2Bt.png")

	GUI = gui()
    GUI:newPanelType("button", texButton, 8, 48)
    GUI:newPanelType("textBox", texTextBox, 4, 56)
    Gamestate.switch(menu)
end

function love.update(dt)
    if (not pause) then
        Timer.update(dt)
    end
    TEsound.cleanup()
end

function love.draw()
	love.graphics.setColor(255,255,255)
	--love.graphics.print(tostring(love.timer.getFPS( )), 10, love.graphics.getHeight()-50)
end

function love.keypressed(k)
    if (k == "p") then
        pause = not pause
    end
end

function love.quit()
    highscore.save()
end

function loadSounds()
    sndLayerComplete = love.sound.newSoundData("sounds/SFX_SpecialLineClearSingle.ogg")
    sndPieceTouchDown = love.sound.newSoundData("sounds/SFX_PieceTouchDown.ogg")
    sndPieceMove = love.sound.newSoundData("sounds/SFX_PieceMoveLR.ogg")
    sndPieceRotate = love.sound.newSoundData("sounds/SFX_PieceRotateLR.ogg")
    sndPieceRotateFail = love.sound.newSoundData("sounds/SFX_PieceRotateFail.ogg")
    sndPieceDrop = love.sound.newSoundData("sounds/SFX_PieceFall.ogg")
end