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

local canvas, font

local song, difficulty

local sky, school, street, treesBack

local petals, trees, freaks

return {
	enter = function(self, from, songNum, songAppend)
		love.graphics.setDefaultFilter("nearest")

		font = love.graphics.newFont("fonts/pixel_small.fnt")

		weeks:enter("pixel")

		song = songNum
		difficulty = songAppend

		cam.sizeX, cam.sizeY = 0.85, 0.85
		camScale.x, camScale.y = 0.85, 0.85

		if song ~= 3 then
			sky = graphics.newImage(graphics.imagePath("week6/sky"))
			school = graphics.newImage(graphics.imagePath("week6/school"))
			street = graphics.newImage(graphics.imagePath("week6/street"))
			treesBack = graphics.newImage(graphics.imagePath("week6/trees-back"))

			trees = love.filesystem.load("sprites/week6/trees.lua")()
			petals = love.filesystem.load("sprites/week6/petals.lua")()
			freaks = love.filesystem.load("sprites/week6/freaks.lua")()

			sky.y = 1
			school.y = 1
		end

		fakeBoyfriend = love.filesystem.load("sprites/pixel/boyfriend-dead.lua")()

		boyfriend.x, boyfriend.y = 50, 30
		fakeBoyfriend.x, fakeBoyfriend.y = 50, 30

		boyfriendIcon:animate("boyfriend (pixel)", false)
		enemyIcon:animate("senpai", false)

		self:load()
	end,

	load = function(self)
		if song == 3 then
			school = love.filesystem.load("sprites/week6/evil-school.lua")()
			enemy = love.filesystem.load("sprites/week6/spirit.lua")()

			enemyIcon:animate("spirit", false)
		elseif song == 2 then
			enemy = love.filesystem.load("sprites/week6/senpai-angry.lua")()

			freaks:animate("dissuaded", true)
		else
			enemy = love.filesystem.load("sprites/week6/senpai.lua")()
		end

		weeks:load("pixel")

		if song == 3 then
			inst = love.audio.newSource("songs/week6/thorns/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week6/thorns/Voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/week6/roses/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week6/roses/Voices.ogg", "stream")
		else
			inst = love.audio.newSource("songs/week6/senpai/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week6/senpai/Voices.ogg", "stream")
		end
		enemy.x, enemy.y = -50, 0

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI("pixel")

		if song == 3 then
			weeks:generateNotes("data/week6/thorns/thorns" .. difficulty .. ".json")
		elseif song == 2 then
			weeks:generateNotes("data/week6/roses/roses" .. difficulty .. ".json")
		else
			weeks:generateNotes("data/week6/senpai/senpai" .. difficulty .. ".json")
		end
	end,

	update = function(self, dt)
		weeks:update(dt)

		if song == 3 then
			school:update(dt)
		else
			trees:update(dt)
			petals:update(dt)
			freaks:update(dt)
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
			love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			love.graphics.push()
				love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

				if song ~= 3 then
					sky:udraw()
				end

				school:udraw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)

				if song ~= 3 then
					street:udraw()
					treesBack:udraw()

					trees:udraw()
					petals:udraw()
					freaks:udraw()
				end

				girlfriend:udraw()
				enemy:udraw()
				boyfriend:udraw()
			love.graphics.pop()
			weeks:drawRating()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		sky = nil
		school = nil
		street = nil

		graphics.clearCache()

		weeks:leave()

		love.graphics.setDefaultFilter("linear")
	end
}
