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

local animList = {
	"singLEFT",
	"singDOWN",
	"singUP",
	"singRIGHT"
}
local inputList = {
	"gameLeft",
	"gameDown",
	"gameUp",
	"gameRight"
}

local ratingTimers = {}

local useAltAnims
local notMissed = {}
local option = "normal"

return {
	enter = function(self, option)
		option = option or "normal"
		if option ~= "pixel" then
			pixel = false
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
	
			-- put our rating images in a cache
			images.sickCache = graphics.newImage(graphics.imagePath("engine/sick"))
			images.goodCache = graphics.newImage(graphics.imagePath("engine/good"))
			images.badCache = graphics.newImage(graphics.imagePath("engine/bad"))
			images.shitCache = graphics.newImage(graphics.imagePath("engine/shit"))

			sprites = {
				icons = love.filesystem.load("sprites/icons.lua"),
				numbers = love.filesystem.load("sprites/numbers.lua")
			}

			rating = love.filesystem.load("sprites/rating.lua")()

			rating.sizeX, rating.sizeY = 0.75, 0.75

			girlfriend = love.filesystem.load("sprites/girlfriend.lua")()
			boyfriend = love.filesystem.load("sprites/boyfriend.lua")()
		else
			pixel = true
			love.graphics.setDefaultFilter("nearest", "nearest")
			sounds = {
				countdown = {
					three = love.audio.newSource("sounds/pixel/countdown-3.ogg", "static"),
					two = love.audio.newSource("sounds/pixel/countdown-2.ogg", "static"),
					one = love.audio.newSource("sounds/pixel/countdown-1.ogg", "static"),
					go = love.audio.newSource("sounds/pixel/countdown-date.ogg", "static")
				},
				miss = {
					love.audio.newSource("sounds/pixel/miss1.ogg", "static"),
					love.audio.newSource("sounds/pixel/miss2.ogg", "static"),
					love.audio.newSource("sounds/pixel/miss3.ogg", "static")
				},
				death = love.audio.newSource("sounds/pixel/death.ogg", "static")
			}

			images = {
				icons = love.graphics.newImage(graphics.imagePath("icons")),
				notes = love.graphics.newImage(graphics.imagePath("pixel/notes")),
				numbers = love.graphics.newImage(graphics.imagePath("pixel/numbers"))
			}

			-- put our rating images in a cache
			images.sickCache = graphics.newImage(graphics.imagePath("pixel/sick"))
			images.goodCache = graphics.newImage(graphics.imagePath("pixel/good"))
			images.badCache = graphics.newImage(graphics.imagePath("pixel/bad"))
			images.shitCache = graphics.newImage(graphics.imagePath("pixel/shit"))

			sprites = {
				icons = love.filesystem.load("sprites/icons.lua"),
				numbers = love.filesystem.load("sprites/pixel/numbers.lua")
			}

			rating = love.filesystem.load("sprites/pixel/rating.lua")()

			girlfriend = love.filesystem.load("sprites/pixel/girlfriend.lua")()
			boyfriend = love.filesystem.load("sprites/pixel/boyfriend.lua")()
		end

		numbers = {}
		for i = 1, 3 do
			numbers[i] = sprites.numbers()

			if option ~= "pixel" then
				numbers[i].sizeX, numbers[i].sizeY = 0.5, 0.5
			end
		end

		enemyIcon = sprites.icons()
		boyfriendIcon = sprites.icons()

		if settings.downscroll then
			downscrollOffset = -750
			enemyIcon.sizeY = -1.5
			boyfriendIcon.sizeY = -1.5
		else
			downscrollOffset = 0
			enemyIcon.sizeY = 1.5
			boyfriendIcon.sizeY = 1.5
		end

		enemyIcon.y = 350 
		boyfriendIcon.y = 350 
		enemyIcon.sizeX = 1.5
		boyfriendIcon.sizeX = -1.5

		countdownFade = {}
		countdown = love.filesystem.load("sprites/countdown.lua")()
	end,

	load = function(self)
		for i = 1, 4 do
			notMissed[i] = true
		end
		useAltAnims = false

		camera.x, camera.y = -boyfriend.x + 100, -boyfriend.y + 75

		rating.x = girlfriend.x
		if not pixel then
			for i = 1, 3 do
				numbers[i].x = girlfriend.x - 100 + 50 * i
			end
		else
			for i = 1, 3 do
				numbers[i].x = girlfriend.x - 100 + 58 * i
			end
		end

		ratingVisibility = {0}
		combo = 0

		enemy:animate("idle")
		boyfriend:animate("idle")

		graphics.fadeIn(0.5)
	end,

	initUI = function(self, option)
		events = {}
		enemyNotes = {}
		boyfriendNotes = {}
		health = 50
		score = 0

		if not pixel then
			sprites.leftArrow = love.filesystem.load("sprites/left-arrow.lua")
			sprites.downArrow = love.filesystem.load("sprites/down-arrow.lua")
			sprites.upArrow = love.filesystem.load("sprites/up-arrow.lua")
			sprites.rightArrow = love.filesystem.load("sprites/right-arrow.lua")
		else
			sprites.leftArrow = love.filesystem.load("sprites/pixel/left-arrow.lua")
			sprites.downArrow = love.filesystem.load("sprites/pixel/down-arrow.lua")
			sprites.upArrow = love.filesystem.load("sprites/pixel/up-arrow.lua")
			sprites.rightArrow = love.filesystem.load("sprites/pixel/right-arrow.lua")
		end

		enemyArrows = {
			sprites.leftArrow(),
			sprites.downArrow(),
			sprites.upArrow(),
			sprites.rightArrow()
		}
		boyfriendArrows= {
			sprites.leftArrow(),
			sprites.downArrow(),
			sprites.upArrow(),
			sprites.rightArrow()
		}

		for i = 1, 4 do
			enemyArrows[i].x = -925 + 165 * i
			boyfriendArrows[i].x = 100 + 165 * i
			enemyArrows[i].y = -400
			boyfriendArrows[i].y = -400

			if settings.downscroll then 
				enemyArrows[i].sizeY = -1
				boyfriendArrows[i].sizeY = -1
			end

			enemyNotes[i] = {}
			boyfriendNotes[i] = {}
		end
	end,

	generateNotes = function(self, chart)
		local eventBpm

		chart = json.decode(love.filesystem.read(chart))
		chart = chart["song"]
		curSong = chart["song"]

		for i = 1, #chart["notes"] do
			bpm = chart["notes"][i]["bpm"]

			if bpm then
				break
			end
		end
		if not bpm then
			bpm = chart["bpm"]
		end
		if not bpm then
			bpm = 100
		end
		beatHandler.setBPM(bpm)

		speed = chart["speed"] or 1

		for i = 1, #chart["notes"] do
			for j = 1, #chart["notes"][i]["sectionNotes"] do
				local sprite
				local sectionNotes = chart["notes"][i]["sectionNotes"]

				local mustHitSection = chart["notes"][i]["mustHitSection"]
				local altAnim = chart["notes"][i]["altAnim"] or false
				local noteType = sectionNotes[j][2]
				local noteTime = sectionNotes[j][1]

				if j == 1 then
					table.insert(events, {eventTime = sectionNotes[1][1], mustHitSection = mustHitSection, bpm = eventBpm, altAnim = altAnim})
				end

				if noteType == 0 or noteType == 4 then
					sprite = sprites.leftArrow
				elseif noteType == 1 or noteType == 5 then
					sprite = sprites.downArrow
				elseif noteType == 2 or noteType == 6 then
					sprite = sprites.upArrow
				elseif noteType == 3 or noteType == 7 then
					sprite = sprites.rightArrow
				end

				if mustHitSection then
					if noteType >= 4 then
					   	local id = noteType - 3
					   	local c = #enemyNotes[id] + 1
					   	local x = enemyArrows[id].x
				 
					   	table.insert(enemyNotes[id], sprite())
					   	enemyNotes[id][c].x = x
					   	enemyNotes[id][c].y = -400 + noteTime * 0.6 * speed
						if settings.downscroll then
							enemyNotes[id][c].sizeY = -1
						end
				 
					   	enemyNotes[id][c]:animate("on", false)
				 
					    if sectionNotes[j][3] > 0 then
						  	local c
				 
						  	for k = 71 / speed, sectionNotes[j][3], 71 / speed do
							 	local c = #enemyNotes[id] + 1
				 
							 	table.insert(enemyNotes[id], sprite())
							 	enemyNotes[id][c].x = x
							 	enemyNotes[id][c].y = -400 + (noteTime + k) * 0.6 * speed
				 
								enemyNotes[id][c]:animate("hold", false)
							end
				 
							c = #enemyNotes[id]
				 
							enemyNotes[id][c].offsetY = not pixel and 10 or 2
				 
						  	enemyNotes[id][c]:animate("end", false)
					    end
					else
					   	local id = noteType + 1
					   	local c = #boyfriendNotes[id] + 1
					   	local x = boyfriendArrows[id].x
				 
					   	table.insert(boyfriendNotes[id], sprite())
					   	boyfriendNotes[id][c].x = x
					   	boyfriendNotes[id][c].y = -400 + noteTime * 0.6 * speed
						boyfriendNotes[id][c].time = noteTime
						if settings.downscroll then
							boyfriendNotes[id][c].sizeY = -1
						end
				 
					   	boyfriendNotes[id][c]:animate("on", false)
				 
					   	if sectionNotes[j][3] > 0 then
						  	local c
				 
						  	for k = 71 / speed, sectionNotes[j][3], 71 / speed do
							 	local c = #boyfriendNotes[id] + 1
				 
							 	table.insert(boyfriendNotes[id], sprite())
							 	boyfriendNotes[id][c].x = x
							 	boyfriendNotes[id][c].y = -400 + (noteTime + k) * 0.6 * speed
				 
							 	boyfriendNotes[id][c]:animate("hold", false)
						  	end
				 
						  	c = #boyfriendNotes[id]
				 
						  	boyfriendNotes[id][c].offsetY = not pixel and 10 or 2
				 
						  	boyfriendNotes[id][c]:animate("end", false)
					   	end
					end
				 else
					if noteType >= 4 then
					   	local id = noteType - 3
					   	local c = #boyfriendNotes[id] + 1
					   	local x = boyfriendArrows[id].x
				 
					   	table.insert(boyfriendNotes[id], sprite())
					   	boyfriendNotes[id][c].x = x
					   	boyfriendNotes[id][c].y = -400 + noteTime * 0.6 * speed
						boyfriendNotes[id][c].time = noteTime
						if settings.downscroll then
							boyfriendNotes[id][c].sizeY = -1
						end
				 
					   	boyfriendNotes[id][c]:animate("on", false)
				 
					   	if sectionNotes[j][3] > 0 then
						  	local c
				 
						  	for k = 71 / speed, sectionNotes[j][3], 71 / speed do
							 	local c = #boyfriendNotes[id] + 1
				 
							 	table.insert(boyfriendNotes[id], sprite())
							 	boyfriendNotes[id][c].x = x
							 	boyfriendNotes[id][c].y = -400 + (noteTime + k) * 0.6 * speed
				 
							 	boyfriendNotes[id][c]:animate("hold", false)
						  	end
				 
						  	c = #boyfriendNotes[id]
				 
						  	boyfriendNotes[id][c].offsetY = not pixel and 10 or 2
				 
						  	boyfriendNotes[id][c]:animate("end", false)
					   	end
					else
					   	local id = noteType + 1
					   	local c = #enemyNotes[id] + 1
					   	local x = enemyArrows[id].x
				 
					   	table.insert(enemyNotes[id], sprite())
					   	enemyNotes[id][c].x = x
					   	enemyNotes[id][c].y = -400 + noteTime * 0.6 * speed
						if settings.downscroll then
							enemyNotes[id][c].sizeY = -1
						end
				 
					   	enemyNotes[id][c]:animate("on", false)
				 
					   	if sectionNotes[j][3] > 0 then
						  	local c
				 
						  	for k = 71 / speed, sectionNotes[j][3], 71 / speed do
							 	local c = #enemyNotes[id] + 1
				 
							 	table.insert(enemyNotes[id], sprite())
							 	enemyNotes[id][c].x = x
							 	enemyNotes[id][c].y = -400 + (noteTime + k) * 0.6 * speed
							 	if k > sectionNotes[j][3] - 71 / speed then
									enemyNotes[id][c].offsetY = not pixel and 10 or 2
				 
									enemyNotes[id][c]:animate("end", false)
							 	else
									enemyNotes[id][c]:animate("hold", false)
							 	end
						  	end
				 
						  	c = #enemyNotes[id]
				 
						  	enemyNotes[id][c].offsetY = not pixel and 10 or 2
				 
						  	enemyNotes[id][c]:animate("end", false)
					   	end
					end
				 end
			end
		end

		for i = 1, 4 do
			table.sort(enemyNotes[i], function(a, b) return a.y < b.y end)
			table.sort(boyfriendNotes[i], function(a, b) return a.y < b.y end)
		end

		-- Workarounds for bad charts that have multiple notes around the same place
		for i = 1, 4 do
			local offset = 0

			for j = 2, #enemyNotes[i] do
				local index = j - offset

				if enemyNotes[i][index]:getAnimName() == "on" and enemyNotes[i][index - 1]:getAnimName() == "on" and ((enemyNotes[i][index].y - enemyNotes[i][index - 1].y <= 10)) then
					table.remove(enemyNotes[i], index)

					offset = offset + 1
				end
			end
		end
		for i = 1, 4 do
			local offset = 0

			for j = 2, #boyfriendNotes[i] do
				local index = j - offset

				if boyfriendNotes[i][index]:getAnimName() == "on" and boyfriendNotes[i][index - 1]:getAnimName() == "on" and ((boyfriendNotes[i][index].y - boyfriendNotes[i][index - 1].y <= 10)) then
					table.remove(boyfriendNotes[i], index)

					offset = offset + 1
				end
			end
		end
	end,

	-- Gross countdown script
	setupCountdown = function(self)
		lastReportedPlaytime = 0
		musicTime = (240 / bpm) * -1000

		musicThres = 0
		musicPos = 0

		countingDown = true
		countdownFade[1] = 0
		audio.playSound(sounds.countdown.three)
		Timer.after(
			(60 / bpm),
			function()
				countdown:animate("ready")
				countdownFade[1] = 1
				audio.playSound(sounds.countdown.two)
				Timer.tween(
					(60 / bpm),
					countdownFade,
					{0},
					"linear",
					function()
						countdown:animate("set")
						countdownFade[1] = 1
						audio.playSound(sounds.countdown.one)
						Timer.tween(
							(60 / bpm),
							countdownFade,
							{0},
							"linear",
							function()
								countdown:animate("go")
								countdownFade[1] = 1
								audio.playSound(sounds.countdown.go)
								Timer.tween(
									(60 / bpm),
									countdownFade,
									{0},
									"linear",
									function()
										countingDown = false

										previousFrameTime = love.timer.getTime() * 1000
										musicTime = 0

										if inst then inst:play() end
										voices:play()
									end
								)
							end
						)
					end
				)
			end
		)
	end,

	safeAnimate = function(self, sprite, animName, loopAnim, timerID)
		sprite:animate(animName, loopAnim)

		spriteTimers[timerID] = 12
	end,

	update = function(self, dt)
		beatHandler.update(dt)

		oldMusicThres = musicThres
		if countingDown or love.system.getOS() == "Web" then -- Source:tell() can't be trusted on love.js!
			musicTime = musicTime + 1000 * dt
		else
			if not graphics.isFading() then
				local time = love.timer.getTime()
				local seconds = voices:tell("seconds")

				musicTime = musicTime + (time * 1000) - previousFrameTime
				previousFrameTime = time * 1000

				if lastReportedPlaytime ~= seconds * 1000 then
					lastReportedPlaytime = seconds * 1000
					musicTime = (musicTime + lastReportedPlaytime) / 2
				end
			end
		end
		absMusicTime = math.abs(musicTime)
		musicThres = math.floor(absMusicTime / 100) -- Since "musicTime" isn't precise, this is needed

		for i = 1, #events do
			if events[i].eventTime <= absMusicTime then
				local oldBpm = bpm

				if events[i].bpm then
					bpm = events[i].bpm
					if not bpm then bpm = oldBpm end
					print(bpm)
					beatHandler.setBPM(bpm)
				end

				if camTimer then
					Timer.cancel(camTimer)
				end
				if events[i].mustHitSection then
					camTimer = Timer.tween(1.25, camera, {x = -boyfriend.x + 100, y = -boyfriend.y + 75}, "out-quad")
				else
					camTimer = Timer.tween(1.25, camera, {x = -enemy.x - 100, y = -enemy.y + 75}, "out-quad")
				end

				if events[i].altAnim then
					useAltAnims = true
				else
					useAltAnims = false
				end

				table.remove(events, i)

				break
			end
		end

		if beatHandler.onBeat() and beatHandler.getBeat() % 4 == 0 then
			if camScaleTimer then Timer.cancel(camScaleTimer) end

			camScaleTimer = Timer.tween((60 / bpm) / 16, camera, {sizeX = camera.scaleX * 1.05, sizeY = camera.scaleY * 1.05}, "out-quad", function() camScaleTimer = Timer.tween((60 / bpm), camera, {sizeX = camera.scaleX, sizeY = camera.scaleY}, "out-quad") end)
		end
		--[[
		if beatHandler.onBeat() then 
			print("beat")
			if not util.startsWith(boyfriend:getAnimName(), "sing") then
				--boyfriend:animate("idle")
			end
		end
		--]]

		girlfriend:update(dt)
		enemy:update(dt)
		boyfriend:update(dt)

		if beatHandler.onBeat() and beatHandler.getBeat() % 2 == 0 then
			if spriteTimers[1] == 0 then
				self:safeAnimate(girlfriend, "idle", true, 1)
				girlfriend:setAnimSpeed(14.4 / (60 / bpm))
			end
		end
		boyfriend:beat(beatHandler.getBeat())
		enemy:beat(beatHandler.getBeat())

		for i = 1, 3 do
			local spriteTimer = spriteTimers[i]

			if spriteTimer > 0 then
				spriteTimers[i] = spriteTimer - 1
			end
		end
	end,

	updateUI = function(self, dt)
		musicPos = musicTime * 0.6 * speed

		for i = 1, 4 do
			local enemyArrow = enemyArrows[i]
			local boyfriendArrow = boyfriendArrows[i]
			local enemyNote = enemyNotes[i]
			local boyfriendNote = boyfriendNotes[i]
			local curAnim = animList[i]
			local curInput = inputList[i]

			local noteNum = i

			enemyArrow:update(dt)
			boyfriendArrow:update(dt)

			if not enemyArrow:isAnimated() then
				enemyArrow:animate("off", false)
			end

			if #enemyNote > 0 then
				if (enemyNote[1].y - musicPos <= -400) then
					voices:setVolume(1)

					enemyArrow:animate("confirm", false)

					if enemyNote[1]:getAnimName() == "hold" or enemyNote[1]:getAnimName() == "end" then
						if useAltAnims then
							if (not enemy:isAnimated()) or enemy:getAnimName() == "idle" then self:safeAnimate(enemy, curAnim .. " alt", false, 2) end
						else
							if (not enemy:isAnimated()) or enemy:getAnimName() == "idle" then self:safeAnimate(enemy, curAnim, false, 2) end
						end
					else
						if useAltAnims then
							self:safeAnimate(enemy, curAnim .. " alt", false, 2)
						else
							self:safeAnimate(enemy, curAnim, false, 2)
						end
					end

					enemy.lastHit = musicTime

					table.remove(enemyNote, 1)
				end
			end

			if #boyfriendNote > 0 then
				if (boyfriendNote[1].y - musicPos < -500) then
					if inst then voices:setVolume(0) end

					notMissed[noteNum] = false

					table.remove(boyfriendNote, 1)

					if combo >= 5 then self:safeAnimate(girlfriend, "sad", true, 1) end

					combo = 0
					health = health - 2
				end
			end

			if input:pressed(curInput) then
				local success = false

				if settings.ghostTapping then
					success = true
				end

				boyfriendArrow:animate("press", false)

				if #boyfriendNote > 0 then
					for i = 1, #boyfriendNote do
						if boyfriendNote[i] and boyfriendNote[i]:getAnimName() == "on" then
							if (boyfriendNote[i].time - musicTime <= 150) then
								local notePos
								local ratingAnim

								notMissed[noteNum] = true

								notePos = math.abs(boyfriendNote[i].time - musicTime)

								voices:setVolume(1)

								boyfriend.lastHit = musicTime

								if notePos <= 30 then -- "Sick"
									score = score + 350
									ratingAnim = "sick"
								elseif notePos <= 70 then -- "Good"
									score = score + 200
									ratingAnim = "good"
								elseif notePos <= 90 then -- "Bad"
									score = score + 100
									ratingAnim = "bad"
								else -- "Shit"
									if settings.ghostTapping then
										success = false
									else
										score = score + 50
									end
									ratingAnim = "shit"
								end
								combo = combo + 1

								rating:animate(ratingAnim, false)
								numbers[1]:animate(tostring(math.floor(combo / 100 % 10), false))
								numbers[2]:animate(tostring(math.floor(combo / 10 % 10), false))
								numbers[3]:animate(tostring(math.floor(combo % 10), false))

								for i = 1, 5 do
									if ratingTimers[i] then Timer.cancel(ratingTimers[i]) end
								end

								ratingVisibility[1] = 1
								rating.y = girlfriend.y - 50
								for i = 1, 3 do
									numbers[i].y = girlfriend.y + 50
								end

								ratingTimers[1] = Timer.tween(2, ratingVisibility, {0})
								ratingTimers[2] = Timer.tween(2, rating, {y = girlfriend.y - 100}, "out-elastic")
								ratingTimers[3] = Timer.tween(2, numbers[1], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[4] = Timer.tween(2, numbers[2], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[5] = Timer.tween(2, numbers[3], {y = girlfriend.y + love.math.random(-10, 10)}, "out-elastic")

								table.remove(boyfriendNote, i)

								if not settings.ghostTapping or success then
									boyfriendArrow:animate("confirm", false)

									self:safeAnimate(boyfriend, curAnim, false, 3)

									health = health + 1

									success = true
								end
							else
								break
							end
						end
					end
				end

				if not success then
					audio.playSound(sounds.miss[love.math.random(3)])

					notMissed[noteNum] = false

					if combo >= 5 then self:safeAnimate(girlfriend, "sad", true, 1) end

					self:safeAnimate(boyfriend, "miss " .. curAnim, false, 3)

					score = score - 10
					combo = 0
					health = health - 2
				end
			end

			if notMissed[noteNum] and #boyfriendNote > 0 and input:down(curInput) and ((boyfriendNote[1].y - musicPos <= -400)) and (boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end") then
				voices:setVolume(1)

				table.remove(boyfriendNote, 1)

				boyfriendArrow:animate("confirm", false)

				if (not boyfriend:isAnimated()) or boyfriend:getAnimName() == "idle" then self:safeAnimate(boyfriend, curAnim, false, 3) end

				health = health + 1
			end

			if input:released(curInput) then
				boyfriendArrow:animate("off", false)
			end
		end

		if health > 100 then
			health = 100
		elseif health > 20 and boyfriendIcon:getAnimName() == "boyfriend losing" then
			if not pixel then 
				boyfriendIcon:animate("boyfriend", false)
			else
				boyfriendIcon:animate("boyfriend (pixel)", false)
			end
		--elseif health <= 0 then -- Game over
			Gamestate.push(gameOver)
		elseif health <= 20 and boyfriendIcon:getAnimName() == "boyfriend" then
			if not pixel then 
				boyfriendIcon:animate("boyfriend losing", false)
			end
		end

		enemyIcon.x = 425 - health * 10
		boyfriendIcon.x = 585 - health * 10

		if beatHandler.onBeat() then
			if enemyIconTimer then Timer.cancel(enemyIconTimer) end
			if boyfriendIconTimer then Timer.cancel(boyfriendIconTimer) end

			if not settings.downscroll then
				enemyIconTimer = Timer.tween((60 / bpm) / 16, enemyIcon, {sizeX = 1.75, sizeY = 1.75}, "out-quad", function() enemyIconTimer = Timer.tween((60 / bpm), enemyIcon, {sizeX = 1.5, sizeY = 1.5}, "out-quad") end)
				boyfriendIconTimer = Timer.tween((60 / bpm) / 16, boyfriendIcon, {sizeX = -1.75, sizeY = 1.75}, "out-quad", function() boyfriendIconTimer = Timer.tween((60 / bpm), boyfriendIcon, {sizeX = -1.5, sizeY = 1.5}, "out-quad") end)
			else
				enemyIconTimer = Timer.tween((60 / bpm) / 16, enemyIcon, {sizeX = 1.75, sizeY = -1.75}, "out-quad", function() enemyIconTimer = Timer.tween((60 / bpm), enemyIcon, {sizeX = 1.5, sizeY = -1.5}, "out-quad") end)
				boyfriendIconTimer = Timer.tween((60 / bpm) / 16, boyfriendIcon, {sizeX = -1.75, sizeY = -1.75}, "out-quad", function() boyfriendIconTimer = Timer.tween((60 / bpm), boyfriendIcon, {sizeX = -1.5, sizeY = -1.5}, "out-quad") end)
			end
		end

		if not countingDown and input:pressed("gameBack") then
			if inst then inst:stop() end
			voices:stop()

			storyMode = false
		end
	end,

	drawRating = function(self, multiplier)
		love.graphics.push()
			if multiplier then
				love.graphics.translate(camera.x * multiplier, camera.y * multiplier)
			else
				love.graphics.translate(camera.x, camera.y)
			end

			graphics.setColor(1, 1, 1, ratingVisibility[1])
			if not pixel then
				rating:draw()
				for i = 1, 3 do
					numbers[i]:draw()
				end
			else
				rating:udraw(6.85, 6.85)
				for i = 1, 3 do
					numbers[i]:udraw(6.85, 6.85)
				end
			end
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
	end,

	drawUI = function(self)
		love.graphics.push()
			love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
			if not settings.downscroll then
				love.graphics.scale(0.7, 0.7)
			else
				love.graphics.scale(0.7, -0.7)
			end

			for i = 1, 4 do
				if enemyArrows[i]:getAnimName() == "off" then
					graphics.setColor(0.6, 0.6, 0.6)
				end
				if not pixel then
					enemyArrows[i]:draw()
				else
					if not settings.downscroll then
						enemyArrows[i]:udraw(8, 8)
					else
						enemyArrows[i]:udraw(8, -8)
					end
				end
				graphics.setColor(1, 1, 1)
				if not pixel then 
					boyfriendArrows[i]:draw()
				else
					if not settings.downscroll then
						boyfriendArrows[i]:udraw(8, 8)
					else
						boyfriendArrows[i]:udraw(8, -8)
					end
				end

				love.graphics.push()
					love.graphics.translate(0, -musicPos)

					for j = #enemyNotes[i], 1, -1 do
						if enemyNotes[i][j].y - musicPos <= 560 then
							local animName = enemyNotes[i][j]:getAnimName()

							if animName == "hold" or animName == "end" then
								graphics.setColor(1, 1, 1, 0.5)
							end
							if not pixel then
								enemyNotes[i][j]:draw()
							else
								if not settings.downscroll then
									enemyNotes[i][j]:udraw(8, 8)
								else
									if enemyNotes[i][j]:getAnimName() == "end" then
										enemyNotes[i][j]:udraw(8, 8)
									else
										enemyNotes[i][j]:udraw(8, -8)
									end
								end
							end
							graphics.setColor(1, 1, 1)
						end
					end
					for j = #boyfriendNotes[i], 1, -1 do
						if boyfriendNotes[i][j].y - musicPos <= 560 then
							local animName = boyfriendNotes[i][j]:getAnimName()

							if animName == "hold" or animName == "end" then
								graphics.setColor(1, 1, 1, math.min(0.5, (500 + (boyfriendNotes[i][j].y - musicPos)) / 150))
							else
								graphics.setColor(1, 1, 1, math.min(1, (500 + (boyfriendNotes[i][j].y - musicPos)) / 75))
							end
							if not pixel then 
								boyfriendNotes[i][j]:draw()
							else
								if not settings.downscroll then
									boyfriendNotes[i][j]:udraw(8, 8)
								else
									if boyfriendNotes[i][j]:getAnimName() == "end" then
										boyfriendNotes[i][j]:udraw(8, 8)
									else
										boyfriendNotes[i][j]:udraw(8, -8)
									end
								end
							end
						end
					end
					graphics.setColor(1, 1, 1)
				love.graphics.pop()
			end

			graphics.setColor(1, 0, 0)
			love.graphics.rectangle("fill", -500, 350, 1000, 25)
			graphics.setColor(0, 1, 0)
			love.graphics.rectangle("fill", 500, 350, -health * 10, 25)
			graphics.setColor(0, 0, 0)
			love.graphics.setLineWidth(10)
			love.graphics.rectangle("line", -500, 350, 1000, 25)
			love.graphics.setLineWidth(1)
			graphics.setColor(1, 1, 1)

			boyfriendIcon:draw()
			enemyIcon:draw()
			love.graphics.print("Score: " .. score, 300, 400)

			graphics.setColor(1, 1, 1, countdownFade[1])
			if not settings.downscroll then
				if not pixel or pixel then 
					countdown:draw()
				else
					countdown:udraw(6.75, 6.75)
				end
			else
				if not pixel or pixel then 
					countdown:udraw(1, -1)
				else
					countdown:udraw(6.75, -6.75)
				end
			end
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
	end,

	leave = function(self)
		if inst then inst:stop() end
		voices:stop()

		Timer.clear()

		fakeBoyfriend = nil
	end
}
