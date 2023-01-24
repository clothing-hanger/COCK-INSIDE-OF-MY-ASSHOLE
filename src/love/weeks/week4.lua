--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local song, difficulty

local sunset

local bgLimo, limoDancer, limo

return {
	enter = function(self, from, songNum, songAppend)
		bpm = 100

		enemyFrameTimer = 0
		boyfriendFrameTimer = 0

		sounds = {
			countdown = {
				three = love.audio.newSource("sounds/countdown-3.ogg", "static"),
				two = love.audio.newSource("sounds/countdown-2.ogg", "static"),
				one = love.audio.newSource("sounds/countdown-1.ogg", "static"),
				go = love.audio.newSource("sounds/countdown-go.ogg", "static")
			},
			miss = {
				love.audio.newSource("sounds/miss1.ogg", "static"),
				love.audio.newSource("sounds/miss2.ogg", "static"),
				love.audio.newSource("sounds/miss3.ogg", "static")
			},
			death = love.audio.newSource("sounds/death.ogg", "static")
		}

		images = {
			icons = love.graphics.newImage(graphics.imagePath("icons")),
			notes = love.graphics.newImage(graphics.imagePath("notes")),
			numbers = love.graphics.newImage(graphics.imagePath("numbers"))
		}

		sprites = {
			icons = love.filesystem.load("sprites/icons.lua"),
			numbers = love.filesystem.load("sprites/numbers.lua")
		}

		song = songNum
		difficulty = songAppend

		sunset = graphics.newImage(graphics.imagePath("week4/sunset"))

		bgLimo = love.filesystem.load("sprites/week4/bg-limo.lua")()
		limoDancer = love.filesystem.load("sprites/week4/limo-dancer.lua")()
		girlfriend = love.filesystem.load("sprites/week4/girlfriend.lua")()
		limo = love.filesystem.load("sprites/week4/limo.lua")()
		enemy = love.filesystem.load("sprites/week4/mommy-mearest.lua")()
		boyfriend = love.filesystem.load("sprites/week4/boyfriend.lua")()
		rating = love.filesystem.load("sprites/rating.lua")()
		fakeBoyfriend = love.filesystem.load("sprites/boyfriend.lua")() -- Used for game over

		fakeBoyfriend.x, fakeBoyfriend.y = 350, -100
		bgLimo.y = 250
		limoDancer.y = -130
		girlfriend.x, girlfriend.y = 30, -50
		limo.y = 375
		enemy.x, enemy.y = -380, -10
		boyfriend.x, boyfriend.y = 340, -100

		rating = love.filesystem.load("sprites/rating.lua")()

		rating.sizeX, rating.sizeY = 0.75, 0.75
		numbers = {}
		for i = 1, 3 do
			numbers[i] = sprites.numbers()

			numbers[i].sizeX, numbers[i].sizeY = 0.5, 0.5
		end

		enemyIcon = sprites.icons()
		boyfriendIcon = sprites.icons()

		if settings.downscroll then
			downscrollOffset = -750
		else
			downscrollOffset = 0
		end

		enemyIcon.y = 350 + downscrollOffset
		boyfriendIcon.y = 350 + downscrollOffset

		enemyIcon.sizeX = 1.5
		boyfriendIcon.sizeX = -1.5
		enemyIcon.sizeY = 1.5
		boyfriendIcon.sizeY = 1.5

		countdownFade = {}
		countdown = love.filesystem.load("sprites/countdown.lua")()

		enemyIcon:animate("mommy mearest", false)

		self:load()
	end,

	load = function(self)
		weeks:load()

		if song == 3 then
			inst = love.audio.newSource("songs/week4/milf/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week4/milf/Voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/week4/high/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week4/high/Voices.ogg", "stream")
		else
			inst = love.audio.newSource("songs/week4/satin-panties/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week4/satin-panties/Voices.ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/week4/milf/milf" .. difficulty .. ".json")
		elseif song == 2 then
			weeks:generateNotes("data/week4/high/high" .. difficulty .. ".json")
		else
			weeks:generateNotes("data/week4/satin-panties/satin-panties" .. difficulty .. ".json")
		end
	end,

	update = function(self, dt)
		weeks:update(dt)

		-- Hardcoded M.I.L.F camera scaling
		if song == 3 and musicTime > 56000 and musicTime < 67000 and musicThres ~= oldMusicThres and math.fmod(absMusicTime, 60000 / bpm) < 100 then
			if camScaleTimer then Timer.cancel(camScaleTimer) end

			camScaleTimer = Timer.tween((60 / bpm) / 16, camera, {sizeX = camera.scaleX * 1.05, sizeY = camera.scaleY * 1.05}, "out-quad", function() camScaleTimer = Timer.tween((60 / bpm), camera, {sizeX = camera.scaleX, sizeY = camera.scaleY}, "out-quad") end)
		end

		bgLimo:update(dt)
		limoDancer:update(dt)
		limo:update(dt)

		if beatHandler.onBeat() and beatHandler.getBeat() % 2 == 0 then
			limoDancer:animate("anim", false)

			limoDancer:setAnimSpeed(14.4 / (60 / bpm))
		end

		if health >= 80 then
			if enemyIcon:getAnimName() == "mommy mearest" then
				enemyIcon:animate("mommy mearest losing", false)
			end
		else
			if enemyIcon:getAnimName() == "mommy mearest losing" then
				enemyIcon:animate("mommy mearest", false)
			end
		end

		if not (countingDown or graphics.isFading()) and not (inst:isPlaying() and voices:isPlaying()) then
			if storyMode and song < 3 then
				song = song + 1

				self:load()
			else
				status.setLoading(true)

				graphics.fadeOut(
					0.5,
					function()
						Gamestate.switch(menu)

						status.setLoading(false)
					end
				)
			end
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.sizeX, camera.sizeY)

			love.graphics.push()
				love.graphics.translate(camera.x * 0.5, camera.y * 0.5)

				sunset:draw()

				bgLimo:draw()
				for i = -475, 725, 400 do
					limoDancer.x = i

					limoDancer:draw()
				end
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x, camera.y)

				girlfriend:draw()
				limo:draw()
				enemy:draw()
				boyfriend:draw()
			love.graphics.pop()
			weeks:drawRating(1)
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function()
		sunset = nil

		bgLimo = nil
		limoDancer = nil
		limo = nil

		graphics.clearCache()

		weeks:leave()
	end
}
