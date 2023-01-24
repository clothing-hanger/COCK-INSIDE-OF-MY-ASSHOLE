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

local hauntedHouse

return {
	enter = function(self, from, songNum, songAppend)
		weeks:enter()

		song = songNum
		difficulty = songAppend

		camera.sizeX, camera.sizeY = 1.1, 1.1
		camera.scaleX, camera.scaleY = 1.1, 1.1

		sounds["thunder"] = {
			love.audio.newSource("sounds/week2/thunder1.ogg", "static"),
			love.audio.newSource("sounds/week2/thunder2.ogg", "static")
		}

		hauntedHouse = love.filesystem.load("sprites/week2/haunted-house.lua")()
		enemy = love.filesystem.load("sprites/week2/skid-and-pump.lua")()

		girlfriend.x, girlfriend.y = -200, 50
		enemy.x, enemy.y = -610, 140
		boyfriend.x, boyfriend.y = 30, 240

		enemyIcon:animate("skid and pump", false)

		self:load()
	end,

	load = function(self)
		weeks:load()

		if song == 3 then
			enemy = love.filesystem.load("sprites/week2/monster.lua")()

			enemy.x, enemy.y = -610, 120

			enemyIcon:animate("monster", false)

			inst = love.audio.newSource("songs/week2/monster/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week2/monster/Voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/week2/south/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week2/south/Voices.ogg", "stream")
		else
			inst = love.audio.newSource("songs/week2/spookeez/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week2/spookeez/Voices.ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes(love.filesystem.load("data/week2/monster/monster" .. difficulty .. ".json")())
		elseif song == 2 then
			weeks:generateNotes(love.filesystem.load("charts/week2/south/south" .. difficulty .. ".json")())
		else
			weeks:generateNotes(love.filesystem.load("charts/week2/spookeez/spookeez" .. difficulty .. ".json")())
		end
	end,

	update = function(self, dt)
		weeks:update(dt)

		hauntedHouse:update(dt)

		if not hauntedHouse:isAnimated() then
			hauntedHouse:animate("normal", false)
		end
		if song == 1 and musicThres ~= oldMusicThres and math.fmod(absMusicTime, 60000 * (love.math.random(17) + 7) / bpm) < 100 then
			audio.playSound(sounds["thunder"][love.math.random(2)])

			hauntedHouse:animate("lightning", false)
			weeks:safeAnimate(girlfriend, "fear", true, 1)
			weeks:safeAnimate(boyfriend, "shaking", true, 3)
		end

		if song ~= 3 and musicThres ~= oldMusicThres and math.fmod(absMusicTime, 60000 / bpm) < 100 then
			if enemy:getAnimName() == "idle" then
				enemy:setAnimSpeed(14.4 / (120 / bpm))
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
				if enemyIcon:getAnimName() == "skid and pump" then
					enemyIcon:animate("skid and pump losing", false)
				end
			else
				if enemyIcon:getAnimName() == "skid and pump losing" then
					enemyIcon:animate("skid and pump", false)
				end
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
				love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

				hauntedHouse:draw()
				girlfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x, camera.y)

				enemy:draw()
				boyfriend:draw()
			love.graphics.pop()
			weeks:drawRating(0.9)
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		hauntedHouse = nil

		graphics.clearCache()

		weeks:leave()
	end
}
