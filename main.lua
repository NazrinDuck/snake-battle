------------------------------------
--Author: NazrinDuck
--Time: 2024/4/19
------------------------------------
Game = require("game")
Button = require("ui.button")
Camera = require("ui.camera")

local function init()
	love.audio.setVolume(0.6)
	Basic.info.load_bgm:play()
	local height = Basic.info.WINDOWS.HEIGHT
	local width = Basic.info.WINDOWS.WIDTH
	Button:set_button("Snake Battle", {
		_x = width / 2,
		_y = 150,
		sx = 5,
		sy = 5,
	}, false)
	Button:set_button(
		"Play",
		{
			_x = width / 2,
			_y = 500,
			sx = 3,
			sy = 3,
		},
		true,
		function()
			GAME_START = false
			START_TIME = love.timer.getTime()
			Button:clear()
			love.audio.stop()
			love.audio.setVolume(0.6)
			Basic.info.bgm:play()
		end
	)
	---- wait for next version
	--[[
  Button:set_button(
    "Config",
    {
      _x = width / 2,
      _y = 750,
      sx = 3,
      sy = 3,
    },
    true,
    function()
      CONFIG = true
    end
  )
]]
end

function love.load()
	local font = love.graphics.newFont(FONT)
	love.graphics.setFont(font)
	love.graphics.setBackgroundColor(0, 0, 0)
	math.randomseed(love.timer.getTime())
	init()

	----- init -----
	Basic:init()

	Game:init()
end

local function add_snake_after_two_minutes()
	if ADD_SNAKE then
		if love.timer.getTime() - START_TIME >= 120 then
			ADD_SNAKE = false
			Game:add_enemy_snake()
		end
	end
end

local function game_start()
	local height = Basic.info.WINDOWS.HEIGHT
	local width = Basic.info.WINDOWS.WIDTH
	Camera:set()
	Basic:draw_background()
	Camera:unset()
	love.graphics.setColor(0.4, 0.4, 0.4, 0.6)
	love.graphics.rectangle("fill", 0, 0, width, height)
	Button:draw()
end

local function game_over()
	local height = Basic.info.WINDOWS.HEIGHT
	local width = Basic.info.WINDOWS.WIDTH
	local font_height = love.graphics.getFont():getHeight()
	local font_width = love.graphics.getFont():getWidth("Game over!")
	love.graphics.setColor(0.4, 0.4, 0.4, 0.6)
	love.graphics.rectangle("fill", 0, 0, width, height)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Game over!", width / 2, height / 2, 0, 5, 5, font_width / 2, font_height / 2)
end

local function win()
	local height = Basic.info.WINDOWS.HEIGHT
	local width = Basic.info.WINDOWS.WIDTH
	local font_height = love.graphics.getFont():getHeight()
	local font_width = love.graphics.getFont():getWidth("Congratulations!")
	love.graphics.setColor(0.4, 0.4, 0.4, 0.6)
	love.graphics.rectangle("fill", 0, 0, width, height)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("Congratulations!", width / 2, height / 2 - 200, 0, 5, 5, font_width / 2, font_height / 2)
	font_width = love.graphics.getFont():getWidth("score: " .. tostring(math.floor(Game.sum_score * 10)))
	love.graphics.print("score: " .. tostring(Game.sum_score), width / 2, 600, 0, 3, 3, font_width / 2, font_height / 2)
end

function love.update(dt)
	if GAME_START then
		Button:check_press()
		Camera:set_offset(Basic:get_map_border().width / 2, Basic:get_map_border().height / 2)
		return
	end
	if GAME_OVER then
		return
	end
	if WIN then
		return
	end

	Game:game_start(dt)

	Camera:set_offset(
		Snake.snake.head.info._x - Basic.info.WINDOWS.WIDTH / 2,
		Snake.snake.head.info._y - Basic.info.WINDOWS.HEIGHT / 2
	)
	add_snake_after_two_minutes()
end

function love.draw()
	if GAME_START then
		game_start()
		return
	end
	Camera:set()
	Game:draw_game()
	Camera:unset()

	Game:draw_ui()
	Basic:draw_fps()

	if GAME_OVER then
		game_over()
	end
	if WIN then
		win()
	end

	---------- debug ----------
	if DEBUG then
		love.graphics.print("speed: " .. tostring(Snake.snake.head.speed), Basic.info.FPS.x, Basic.info.FPS.y + 50)
		love.graphics.print("x: " .. tostring(Snake.snake.head.info._x), Basic.info.FPS.x, Basic.info.FPS.y + 75)
		love.graphics.print("y: " .. tostring(Snake.snake.head.info._y), Basic.info.FPS.x, Basic.info.FPS.y + 100)

		love.graphics.print(
			"head health: " .. tostring(Snake.snake.head.health),
			Basic.info.FPS.x,
			Basic.info.FPS.y + 175
		)
		--[[
    ]]
	end
end
