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

local difficulty

local stageBack, stageFront, curtains

return {
	enter = function(self, from, songNum, songAppend)
		weeks:enter()




		BGIMAGEPATH = "songs/quaver/" .. selectedSong .. "/image.png"


		song = songNum
		difficulty = songAppend

        backGroundImage = graphics.newImage(BGIMAGEPATH)




		self:load()
	end,

	load = function(self)

		weeks:load()

		voices = love.audio.newSource("songs/quaver/" .. selectedSong .. "/song.ogg", "stream")




		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		weeks:generateNotes("songs/quaver/" .. selectedSong .. "/chart.json")

		if videoBackground == 1 then    -- goofy fake boolean (i promise its for a reason)
			videoBG = love.graphics.newVideo("songs/quaver/" .. selectedSong .. "/video.ogv")
		end


		print("initUI")
	end,

	update = function(self, dt)

		weeks:update(dt)





		if (not (countingDown or graphics.isFading()) and not voices:isPlaying() and not paused) or input:pressed("endSong") then

				status.setLoading(true)

				graphics:fadeOutWipe(
					0.7,
					function()
						Gamestate.switch(results)

						status.setLoading(false)
					end
				)
	
		end

		weeks:updateUI(dt)
	
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			if videoBackground == 1 and mods[1] == 1 then
				love.graphics.draw(videoBG, -650, -360, 0, 1, 1)
			else
				backGroundImage:draw()
			end


		love.graphics.pop()
		if not mods[6] then

			weeks:drawUI()
		end

	end,

	leave = function(self)

		BGIMAGEPATH = nil

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()

	end
}
