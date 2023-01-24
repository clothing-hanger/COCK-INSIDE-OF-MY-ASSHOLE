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

local walls, escalator, christmasTree, snow

local topBop, bottomBop, santa

local scaryIntro = false

return {
	enter = function(self, from, songNum, songAppend)
		weeks:enter()

		camera.sizeX, camera.sizeY = 0.7, 0.7
		camera.scaleX, camera.scaleY = 0.7, 0.7

		sounds.lightsOff = love.audio.newSource("sounds/week5/lights-off.ogg", "static")
		sounds.lightsOn = love.audio.newSource("sounds/week5/lights-on.ogg", "static")

		song = songNum
		difficulty = songAppend

		if song ~= 3 then
			walls = graphics.newImage(graphics.imagePath("week5/walls"))
			escalator = graphics.newImage(graphics.imagePath("week5/escalator"))
			christmasTree = graphics.newImage(graphics.imagePath("week5/christmas-tree"))
			snow = graphics.newImage(graphics.imagePath("week5/snow"))

			escalator.x = 125
			christmasTree.x = 75
			snow.y = 850
			snow.sizeX, snow.sizeY = 2, 2

			topBop = love.filesystem.load("sprites/week5/top-bop.lua")()
			bottomBop = love.filesystem.load("sprites/week5/bottom-bop.lua")()
			santa = love.filesystem.load("sprites/week5/santa.lua")()

			topBop.x, topBop.y = 60, -250
			bottomBop.x, bottomBop.y = -75, 375
			santa.x, santa.y = -1350, 410
		end

		girlfriend = love.filesystem.load("sprites/week5/girlfriend.lua")()
		enemy = love.filesystem.load("sprites/week5/dearest-duo.lua")()
		boyfriend = love.filesystem.load("sprites/week5/boyfriend.lua")()
		fakeBoyfriend = love.filesystem.load("sprites/boyfriend.lua")() -- Used for game over

		girlfriend.x, girlfriend.y = -50, 410
		enemy.x, enemy.y = -780, 410
		boyfriend.x, boyfriend.y = 300, 620
		fakeBoyfriend.x, fakeBoyfriend.y = 300, 620

		enemyIcon:animate("dearest duo", false)

		self:load()
	end,

	load = function(self)
		weeks:load()

		if song == 3 then
			camera.scaleX, camera.scaleY = 0.9, 0.9

			if scaryIntro then
				camera.x, camera.y = -150, 750
				camera.sizeX, camera.sizeY = 2.5, 2.5

				graphics.setFade(1)
			else
				camera.sizeX, camera.sizeY = 0.9, 0.9
			end

			walls = graphics.newImage(graphics.imagePath("week5/evil-bg"))
			christmasTree = graphics.newImage(graphics.imagePath("week5/evil-tree"))
			snow = graphics.newImage(graphics.imagePath("week5/evil-snow"))

			walls.y = -250
			christmasTree.x = 75
			christmasTree.sizeX, christmasTree.sizeY = 0.5, 0.5
			snow.x, snow.y = -50, 770

			enemy = love.filesystem.load("sprites/week5/monster.lua")()

			enemy.x, enemy.y = -780, 420

			enemyIcon:animate("monster", false)

			inst = love.audio.newSource("songs/week5/winter-horrorland/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week5/winter-horrorland/Voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/week5/eggnog/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week5/eggnog/Voices.ogg", "stream")
		else
			inst = love.audio.newSource("songs/week5/cocoa/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week5/cocoa/Voices.ogg", "stream")
		end

		self:initUI()

		if scaryIntro then
			Timer.after(
				5,
				function()
					scaryIntro = false

					camTimer = Timer.tween(2, camera, {x = -boyfriend.x + 100, y = -boyfriend.y + 75, sizeX = 0.9, sizeY = 0.9}, "out-quad")

					weeks:setupCountdown()
				end
			)

			audio.playSound(sounds.lightsOn)
		else
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/week5/winter-horrorland/winter-horrorland-" .. difficulty .. ".json")
		elseif song == 2 then
			weeks:generateNotes("data/week5/eggnog/eggnog-" .. difficulty .. ".json")
		else
			weeks:generateNotes("data/week5/cocoa/cocoa-" .. difficulty .. ".json")
		end
	end,

	update = function(self, dt)
		if not scaryIntro then
			weeks:update(dt)

			if song ~= 3 then
				topBop:update(dt)
				bottomBop:update(dt)
				santa:update(dt)

				if beatHandler.onBeat() then
					topBop:animate("anim", false)
					bottomBop:animate("anim", false)
					santa:animate("anim", false)
				end
			end

			if song == 3 then
				if health >= 80 then
					if enemyIcon:getAnimName() == "monster" then
						enemyIcon:animate("monster losing", false)
					end
				else
					if enemyIcon:getAnimName() == "monster losing" then
						enemyIcon:animate("monster", false)
					end
				end
			else
				if health >= 80 then
					if enemyIcon:getAnimName() == "dearest duo" then
						enemyIcon:animate("dearest duo losing", false)
					end
				else
					if enemyIcon:getAnimName() == "dearest duo losing" then
						enemyIcon:animate("dearest duo", false)
					end
				end
			end

			if not (scaryIntro or countingDown or graphics.isFading()) and not (inst:isPlaying() and voices:isPlaying()) then
				if storyMode and song < 3 then
					song = song + 1

					-- Winter Horrorland setup
					if song == 3 then
						scaryIntro = true

						audio.playSound(sounds.lightsOff)

						graphics.setFade(0)

						Timer.after(3, function() self:load() end)
					else
						self:load()
					end
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
		end
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.sizeX, camera.sizeY)

			love.graphics.push()
				love.graphics.translate(camera.x * 0.5, camera.y * 0.5)

				walls:draw()
				if song ~= 3 then
					topBop:draw()
					escalator:draw()
				end
				christmasTree:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

				if song ~= 3 then
					bottomBop:draw()
				end

				snow:draw()

				girlfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x, camera.y)

				if song ~= 3 then
					santa:draw()
				end
				enemy:draw()
				boyfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x * 1.1, camera.y * 1.1)
			love.graphics.pop()
			weeks:drawRating(0.9)
		love.graphics.pop()

		if not scaryIntro then
			weeks:drawUI()
		end
	end,

	leave = function()
		walls = nil
		escalator = nil

		santa = nil

		graphics.clearCache()

		weeks:leave()
	end
}
