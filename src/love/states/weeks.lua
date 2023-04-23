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


ratingAnim = ""

marvAlpha = 0
perfAlpha = 0
greatAlpha = 0
goodAlpha = 0
okayAlpha = 0
missAlpha = 0



marvOverlayAlpha = 0
perfOverlayAlpha = 0
greatOverlayAlpha = 0
goodOverlayAlpha = 0
okayOverlayAlpha = 0
missOverlayAlpha = 0

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
		playMenuMusic = false
		beatHandler.reset()
		option = option or "normal"
	
			sounds = {

				breakfast = love.audio.newSource("music/breakfast.ogg", "stream"),
			}

			images = {
				qnotes = love.graphics.newImage(graphics.imagePath("qnotes")),

			}

			sprites = {

			}

			

		if settings.downscroll then
			downscrollOffset = -750
		else
			downscrollOffset = 0
		end

		function doNoteTimeMeter(noteHitTime, color)
			--table.insert(hitErrorTable, noteHitTime)
		--	table.insert(hitErrorColorTable, color)

			if hitErrorTween then
				Timer.cancel(hitErrorTween)
			end
		--	for i = 1,#hitErrorTable do
		--		if i > 10 then
		--			table.remove(hitErrorTable, i)
		--			table.remove(hitErrorColorTable, i)
		--		end
		--	end



			hitErrorNote = noteHitTime
			hitErrorColorTable[1] = color



			hitErrorTween = Timer.tween(0.3, hitErrorPointer, {x = noteHitTime}, "out-expo")
		end




		function gameOverFunc()
			hasLost = true

			gameoverSongSpeed = {mods[1]}
			if gameoverTimer then
				Timer.cancel(gameoverTimer)
			end
			gameoverTimer = Timer.tween(1.5, gameOverRed, {[1] = 1}, "out-quad")
			if gameoverSpeedTimer then
				Timer.cancel(gameoverSpeedTimer)
			end

			gameoverSpeedTimer = Timer.tween(0.5, gameoverSongSpeed, {0.01}, "out-expo")



		end

		function lerp(a, b, time)
			return a * (1.0 - time) + b * time
		  end

	
	end,

	load = function(self)
		hitErrorTable = {}
		hitErrorColorTable = {}

		botplayY = 0
		botplayAlpha = {1}
		judgeYPos = {-15}
		songSpeed = {1}
		gameOverRed = {0}
		paused = false
		combo = 0
		timer = 0
		clickCount = 0
		timeSinceLastClick = 0
		pauseMenuSelection = 1
		noteHitsArray = {}
		dyingAlpha = 0
		hasLost = false


		comboPopup = graphics.newImage(graphics.imagePath("quaver/combo"))
		hitErrorPointer = graphics.newImage(graphics.imagePath("hitErrorPointer"))
		dyingOverlay = graphics.newImage(graphics.imagePath("dyingOverlay"))
		topCover = graphics.newImage(graphics.imagePath("laneCover"))
		BottomCover = graphics.newImage(graphics.imagePath("laneCover"))


		dyingOverlay.sizeX = 1500

		topCover.sizeX = 1500
		BottomCover.sizeX = 1500

		BottomCover.sizeY = -1

		dyingOverlay.x, dyingOverlay.y = 0, 0

		hitErrorPointer.y = 0
		hitErrorPointer.x = 0


		topCover.y = lerp(-850, 100, (mods[10] / 100))





		--topCover.y = 100 lowest it can be (this would be fully on)

		--topCover.y = -850 highest it can be (this would be fully off)



		comboPopup.x = 1200

		comboPopup.sizeX, comboPopup.sizeY = 1.8, 1.8
		
		function boyPlayAlphaChange()
			Timer.tween(1.25, botplayAlpha, {0}, "in-out-cubic", function()
				Timer.tween(1.25, botplayAlpha, {1}, "in-out-cubic", boyPlayAlphaChange)
			end)
		end

		function comboTextPopupThisThingIsMadAnnoyingTBHButItsFunnySoImAddingIT()
			if theballs then
				Timer.cancel(theballs)
			end
			theballs = Timer.tween(1, comboPopup, {x = 550}, "out-expo", function()
				Timer.after(1, function()
					comboPopup.x = 1200
				end)
			end)
		end

		boyPlayAlphaChange()
		pauseBG = graphics.newImage(graphics.imagePath("pause/pause_box"))
		pauseShadow = graphics.newImage(graphics.imagePath("pause/pause_shadow"))

		quaverMarv = graphics.newImage(graphics.imagePath("quaver/judge/judge-marv"))
		quaverPerf = graphics.newImage(graphics.imagePath("quaver/judge/judge-perf"))
		quaverGreat = graphics.newImage(graphics.imagePath("quaver/judge/judge-great"))
		quaverGood = graphics.newImage(graphics.imagePath("quaver/judge/judge-good"))
		quaverOkay = graphics.newImage(graphics.imagePath("quaver/judge/judge-okay"))
		quaverMiss = graphics.newImage(graphics.imagePath("quaver/judge/judge-miss"))
		quaverOverlay = graphics.newImage(graphics.imagePath("quaver/judge/judgement-overlay"))
		quaverHealth = graphics.newImage(graphics.imagePath("quaver/health"))
		--overlays
		marvOverlay = graphics.newImage(graphics.imagePath("quaver/judge/judgement-overlay"))
		perfOverlay = graphics.newImage(graphics.imagePath("quaver/judge/judgement-overlay"))
		greatOverlay = graphics.newImage(graphics.imagePath("quaver/judge/judgement-overlay"))
		goodOverlay = graphics.newImage(graphics.imagePath("quaver/judge/judgement-overlay"))
		okayOverlay = graphics.newImage(graphics.imagePath("quaver/judge/judgement-overlay"))
		missOverlay = graphics.newImage(graphics.imagePath("quaver/judge/judgement-overlay"))

		ratings = {
			X = graphics.newImage(graphics.imagePath("quaver/ratings/grade-small-x")),
			SS = graphics.newImage(graphics.imagePath("quaver/ratings/grade-small-ss")),
			S = graphics.newImage(graphics.imagePath("quaver/ratings/grade-small-s")),
			A = graphics.newImage(graphics.imagePath("quaver/ratings/grade-small-a")),
			B = graphics.newImage(graphics.imagePath("quaver/ratings/grade-small-b")),
			C = graphics.newImage(graphics.imagePath("quaver/ratings/grade-small-c")),
			D = graphics.newImage(graphics.imagePath("quaver/ratings/grade-small-d")),
			F = graphics.newImage(graphics.imagePath("quaver/ratings/grade-small-f"))
		}

		ratings.X.x, ratings.X.y = 685, -486
		ratings.F.x, ratings.F.y = 685, -486
		ratings.D.x, ratings.D.y = 685, -486
		ratings.C.x, ratings.C.y = 685, -486
		ratings.B.x, ratings.B.y = 685, -486
		ratings.A.x, ratings.A.y = 685, -486
		ratings.S.x, ratings.S.y = 685, -486
		ratings.SS.x, ratings.SS.y = 685, -486


		quaverHealth.sizeX, quaverHealth.sizeY = 0.5, 0.5

		for i = 1, 4 do
			notMissed[i] = true
		end

		graphics:fadeInWipe(0.6)
	end,

	calculateRating = function(self)
		ratingPercent = score / ((noteCounter + misses) * 350)
		if ratingPercent == nil or ratingPercent < 0 then 
			ratingPercent = 0
		elseif ratingPercent > 1 then
			ratingPercent = 1
		end
	end,


	initUI = function(self, option)
		boyfriendNotes = {}
		health = 1
		score = 0
		misses = 0
		marvs = 0
		perfs = 0
		greats = 0
		goods = 0
		okays = 0
		ratingPercent = 0.0
		noteCounter = 0


			sprites.leftArrow = love.filesystem.load("sprites/left-arrow.lua")
			sprites.downArrow = love.filesystem.load("sprites/down-arrow.lua")
			sprites.upArrow = love.filesystem.load("sprites/up-arrow.lua")
			sprites.rightArrow = love.filesystem.load("sprites/right-arrow.lua")

			sprites.receptors = love.filesystem.load("sprites/receptor.lua")

		boyfriendArrows= {
			sprites.receptors(),
			sprites.receptors(),
			sprites.receptors(),
			sprites.receptors()
		}

		for i = 1, 4 do

			boyfriendArrows[i].x = -410 + 165 * i



			boyfriendArrows[i].y = -400

			boyfriendArrows[i]:animate(tostring(i))


			if settings.downscroll then 
				boyfriendArrows[i].sizeY = -1
			end

			boyfriendNotes[i] = {}
		end
	end,

	generateNotes = function(self, chart)
		local eventBpm

		chart = json.decode(love.filesystem.read(chart))
		chart = chart["song"]
		curSong = chart["song"]
		songDifficulty = chart["songDifficulty"]

		videoBackground = chart["videoBG"]

		print(videoBackground)

		resultsDifficulty = songDifficulty

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


		


		if settings.customScrollSpeed == 1 then
			speed = chart["speed"] or 1 / mods[1]
		else
			speed = settings.customScrollSpeed / mods[1]
		end

		

		for i = 1, #chart["notes"] do
			for j = 1, #chart["notes"][i]["sectionNotes"] do
				local sprite
				local sectionNotes = chart["notes"][i]["sectionNotes"]

				local mustHitSection = chart["notes"][i]["mustHitSection"]
				local noteType = sectionNotes[j][2]
				local noteTime = sectionNotes[j][1]

				if mods[7] then

					if noteType == 3 then
						noteType = 0
					elseif noteType == 2 then
						noteType = 1
					elseif noteType == 1 then
						noteType = 2
					elseif noteType == 0 then
						noteType = 3
					end

					if noteType == 7 then
						noteType = 4
					elseif noteType == 6 then
						noteType = 5
					elseif noteType == 5 then
						noteType = 6
					elseif noteType == 4 then
						noteType = 7
					end
				end

				if mods[8] then
					if noteType == 0 or noteType == 1 or noteType == 2 or noteType == 3 then
						noteType = love.math.random(0,3)
					elseif noteType == 4 or noteType == 5 or noteType == 6 or noteType == 7 then
						noteType = love.math.random(4, 7)
					end
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



					if noteType < 4 and noteType >= 0 then
					   	local id = noteType + 1
					   	local c = #boyfriendNotes[id] + 1
					   	local x = boyfriendArrows[id].x

						local beatRow = util.round(((noteTime / 1000) * (bpm / 60)) * 48)
				 
						if settings.colourByQuantization then
							if (beatRow % (192 / 4) == 0) then  -- 4th
								col = 1
								sprite = sprites.leftArrow
							elseif (beatRow % (192 / 8) == 0) then -- 8th
								col = 2
								sprite = sprites.downArrow
							elseif (beatRow % (192 / 12) ==  0) then  -- 12th
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 16) == 0) then -- 16th
								col = 4
								sprite = sprites.rightArrow
							elseif (beatRow % (192 / 24) == 0) then -- 24th
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 32) == 0) then -- 32nd
								col = 3
								sprite = sprites.upArrow
							else -- Unknown
								col = id
							end
						else
							col = id
						end

					   	table.insert(boyfriendNotes[id], sprite())
						boyfriendNotes[id][c].col = col
					   	boyfriendNotes[id][c].x = x
					   	boyfriendNotes[id][c].y = -400 + noteTime * 0.6 * speed
						boyfriendNotes[id][c].time = noteTime

						
						if settings.downscroll then
							boyfriendNotes[id][c].sizeY = -1
						end
				 
					   	boyfriendNotes[id][c]:animate("on", false)
						if not mods[9] then
				 
							if sectionNotes[j][3] > 0 then
								local c
					
								for k = 71 / speed, sectionNotes[j][3], 71 / speed do
									local c = #boyfriendNotes[id] + 1
					
									table.insert(boyfriendNotes[id], sprite())
									boyfriendNotes[id][c].x = x
									boyfriendNotes[id][c].y = -400 + (noteTime + k) * 0.6 * speed
									boyfriendNotes[id][c].time = noteTime + k
									boyfriendNotes[id][c].col = col
					
									boyfriendNotes[id][c]:animate("hold", false)
								end
					
								c = #boyfriendNotes[id]
					
								boyfriendNotes[id][c].offsetY = not pixel and 10 or 2
					
								boyfriendNotes[id][c]:animate("end", false)
							end
						end
					end
				
					if noteType >= 4 then
					   	local id = noteType - 3
					   	local c = #boyfriendNotes[id] + 1
					   	local x = boyfriendArrows[id].x

						local beatRow = util.round(((noteTime / 1000) * (bpm / 60)) * 48)
				 
						if settings.colourByQuantization then
							if (beatRow % (192 / 4) == 0) then 
								col = 1
								sprite = sprites.leftArrow
							elseif (beatRow % (192 / 8) == 0) then
								col = 2
								sprite = sprites.downArrow
							elseif (beatRow % (192 / 12) ==  0) then 
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 16) == 0) then
								col = 4
								sprite = sprites.rightArrow
							elseif (beatRow % (192 / 24) == 0) then
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 32) == 0) then
								col = 3
								sprite = sprites.upArrow
							end
						else
							col = id
						end
				 
					   	table.insert(boyfriendNotes[id], sprite())
						boyfriendNotes[id][c].col = col
					   	boyfriendNotes[id][c].x = x
					   	boyfriendNotes[id][c].y = -400 + noteTime * 0.6 * speed
						boyfriendNotes[id][c].time = noteTime

						
						if settings.downscroll then
							boyfriendNotes[id][c].sizeY = -1
						end
				 
					   	boyfriendNotes[id][c]:animate("on", false)
						if not mods[9] then
					
							if sectionNotes[j][3] > 0 then
								local c
					
								for k = 71 / speed, sectionNotes[j][3], 71 / speed do
									local c = #boyfriendNotes[id] + 1
					
									table.insert(boyfriendNotes[id], sprite())
									boyfriendNotes[id][c].x = x
									boyfriendNotes[id][c].y = -400 + (noteTime + k) * 0.6 * speed
									boyfriendNotes[id][c].time = noteTime + k
									boyfriendNotes[id][c].col = col
					
									boyfriendNotes[id][c]:animate("hold", false)
								end
					
								c = #boyfriendNotes[id]
					
								boyfriendNotes[id][c].offsetY = not pixel and 10 or 2
					
								boyfriendNotes[id][c]:animate("end", false)
							end
						end
					end
				
			end
		end

		for i = 1, 4 do
			table.sort(boyfriendNotes[i], function(a, b) return a.y < b.y end)
		end

		-- Workarounds for bad charts that have multiple notes around the same place
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

		NPS = 0
		NPSTimer = 0
	end,


	-- Gross countdown script
	setupCountdown = function(self)
		lastReportedPlaytime = 0
		musicTime = -3000

		musicThres = 0
		musicPos = 0



		countdownFade = {1}
		countingDown = true


		Timer.after(3, function()
			Timer.tween(0.5, countdownFade, {0}, "linear")
			countingDown = false

			previousFrameTime = love.timer.getTime() * 1000
			musicTime = 0
			beatHandler.reset(0)


			voices:setPitch(mods[1])

			voices:play()

			if videoBackground == 1 then
				videoBG:play()
			end
		end)



	end,

	update = function(self, dt)





		if health > 0.66 then
			dyingAlpha = dyingAlpha - 0.99 * dt
			if dyingAlpha < -0.1 then dyingAlpha = -0.1 end
		else
			dyingAlpha = dyingAlpha + 0.99 * dt
			if dyingAlpha > 1 then dyingAlpha = 1 end
		end

		if input:pressed("pause") and not countingDown and not inCutscene and not doingDialogue and not paused then
			if not graphics.isFading() then 
				paused = true
				pauseTime = musicTime
				if paused then
					if videoBackground == 1 then
						videoBG:pause()
					end
					voices:pause()
					love.audio.play(sounds.breakfast)
					sounds.breakfast:setLooping(true) 
				end
			end
			return
		end
		for i = 1, #noteHitsArray do
			if (noteHitsArray[i]) then
				if noteHitsArray[i] + 1000 < musicTime then
					table.remove(noteHitsArray, i)
				end
			end
		end
		nps = #noteHitsArray
		  -- increase timer by delta time
		  if timer then
		  	timer = timer + dt
		  end
  
		  -- increase time since last click by delta time
		  timeSinceLastClick = timeSinceLastClick + dt
		  
		  -- reset click count and time since last click if time since last click is greater than 1 second
		  if timeSinceLastClick > 1 then
			clickCount = 0
			timeSinceLastClick = 0
		  end
		if paused then 
			previousFrameTime = love.timer.getTime() * 1000
			musicTime = pauseTime
			if input:pressed("gameDown") then
				if pauseMenuSelection == 3 then
					pauseMenuSelection = 1
				else
					pauseMenuSelection = pauseMenuSelection + 1
				end
			end

			if input:pressed("gameUp") and paused then
				if pauseMenuSelection == 1 then
					pauseMenuSelection = 3
				else
					pauseMenuSelection = pauseMenuSelection - 1
				end
			end
			if input:pressed("confirm") then
				love.audio.stop(sounds.breakfast) -- since theres only 3 options, we can make the sound stop without an else statement
				if pauseMenuSelection == 1 then
					voices:play()
					if videoBackground == 1 then
						videoBG:play()
					end
					paused = false 
				elseif pauseMenuSelection == 2 then
					pauseRestart = true
					Gamestate.push(gameOver)
				elseif pauseMenuSelection == 3 then
					paused = false
					voices:stop()
					storyMode = false
					quitPressed = true
				end
			end
			return
		end

		if combo % 100 == 0 and combo ~= 0 then
			comboTextPopupThisThingIsMadAnnoyingTBHButItsFunnySoImAddingIT()
		end
		if inCutscene then return end
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

	end,

	updateUI = function(self, dt)
		if inCutscene then return end
		if paused then return end
		musicPos = musicTime * 0.6 * speed

		for i = 1, 4 do
			local boyfriendArrow = boyfriendArrows[i]
			local boyfriendNote = boyfriendNotes[i]
			local curInput = inputList[i]

			local noteNum = i

			boyfriendArrow:update(dt)

			if settings.botPlay or mods[5] or mods[6] then
				if not boyfriendArrow:isAnimated() then
					boyfriendArrow:animate(tostring(i), false)
				end
			end



			if #boyfriendNote > 0 then
				if (boyfriendNote[1].y - musicPos < -600) then

					notMissed[noteNum] = false




					if boyfriendNote[1]:getAnimName() ~= "hold" and boyfriendNote[1]:getAnimName() ~= "end" then 
						health = health - 0.095
						misses = misses + 1
						marvAlpha = 0
						perfAlpha = 0
						greatAlpha = 0
						goodAlpha = 0
						okayAlpha = 0
						missAlpha = 1

						missOverlayAlpha = 1
						ratingPercent = score / ((noteCounter + misses) * 350)
						if ratingPercent == nil or ratingPercent < 0 then 
							ratingPercent = 0
						elseif ratingPercent > 1 then
							ratingPercent = 1
						end
						combo = 0
					else
						health = health - 0.0125
					end


					
					table.remove(boyfriendNote, 1)
				end
			end

			if settings.botPlay or mods[5] or mods[6] then 
				if #boyfriendNote > 0 then
					if (boyfriendNote[1].y - musicPos <= -400) then

						boyfriendArrow:animate(tostring(boyfriendNote[1].col) .. " confirm", false)



						if boyfriendNote[1]:getAnimName() ~= "hold" and boyfriendNote[1]:getAnimName() ~= "end" then 
							noteCounter = noteCounter + 1
							combo = combo + 1
							health = health + 0.095
							score = score + 350

							ratingAnim = "marv"
							marvAlpha = 1
							perfAlpha = 0
							greatAlpha = 0
							goodAlpha = 0
							okayAlpha = 0
							missAlpha = 0

							marvs = marvs + 1



							self:calculateRating()
						else
							health = health + 0.0125
						end

						table.remove(boyfriendNote, 1)
					end
				end
			end

			if input:pressed("gameLeft") or input:pressed("gameRight") or input:pressed("gameUp") or input:pressed("gameDown") then
				clickCount = clickCount + 1
				timeSinceLastClick = 0
			end

			if input:pressed(curInput) and not hasLost then
				-- unshit noteHitsArray with current time
				util.unshift(noteHitsArray, musicTime)
				-- if settings.botPlay is true, break our the if statement
				if settings.botPlay or mods[5] or mods[6] then break end
				local success = false

				if settings.ghostTapping then
					success = true
				end

				boyfriendArrow:animate(tostring(i) .. " press", false)

				if #boyfriendNote > 0 then
					for j = 1, #boyfriendNote do
						if boyfriendNote[j] and boyfriendNote[j]:getAnimName() == "on" then
							if (boyfriendNote[j].time - musicTime <= 150) then
								local notePos
								local ratingAnim

								notMissed[noteNum] = true

								notePos = math.abs(boyfriendNote[j].time - musicTime)



								if notePos <= 25 then -- "Marv"
									ratingAnim = "marv"
									marvAlpha = 1
									perfAlpha = 0
									greatAlpha = 0
									goodAlpha = 0
									okayAlpha = 0
									missAlpha = 0
									health = health + (2 / 100)
									judgeYPos = {-15}
									score = score + 350
									marvs = marvs + 1

									marvOverlayAlpha = 1

									color = {251/255, 255/255, 182/255}



								elseif notePos <= 55 then -- "Perf"
									ratingAnim = "perf"
									marvAlpha = 0
									perfAlpha = 1
									greatAlpha = 0
									goodAlpha = 0
									okayAlpha = 0
									missAlpha = 0
									health = health + (1.5 / 100)
									judgeYPos = {-15}
									score = score + 200

									perfs = perfs + 1

									perfOverlayAlpha = 1

									color = {255/255, 231/255, 107/255}


								elseif notePos <= 80 then -- "Great"
									score = score + 100

									ratingAnim = "great"
									marvAlpha = 0
									perfAlpha = 0
									greatAlpha = 1
									goodAlpha = 0
									okayAlpha = 0
									missAlpha = 0
									judgeYPos = {-15}

									greats = greats + 1

									greatOverlayAlpha = 1

									color = {86/255, 254/255, 110/255}

								elseif notePos <= 106 then -- "Good"
									score = score + 50

									ratingAnim = "good"
									marvAlpha = 0
									perfAlpha = 0
									greatAlpha = 0
									goodAlpha = 1
									okayAlpha = 0
									missAlpha = 0
									health = health - (1.5 / 100)
									judgeYPos = {-15}

									goods = goods + 1

									goodOverlayAlpha = 1

									color = {0/255, 209/255, 255/255}


								else -- "Okay"
									ratingAnim = "okay"
									score = score + 10

									marvAlpha = 0
									perfAlpha = 0
									greatAlpha = 0
									goodAlpha = 0
									okayAlpha = 1
									missAlpha = 0
									health = health - (2 / 100)
									judgeYPos = {-15}

									okays = okays + 1

									okayOverlayAlpha = 1

									color = {217/255, 107/255, 206/255}

								end

								combo = combo + 1
								noteCounter = noteCounter + 1


								doNoteTimeMeter(boyfriendNote[j].time - musicTime, color)




								if not settings.ghostTapping or success then
									boyfriendArrow:animate(tostring(boyfriendNote[1].col) .. " confirm", false)

									success = true
								end

								table.remove(boyfriendNote, j)

								self:calculateRating()
							else
								break
							end
						end
					end
				end

				if not success then

					notMissed[noteNum] = false
					score = score - 10
					combo = 0
					health = health - 0.135
					misses = misses + 1
					ratingPercent = score / ((noteCounter + misses) * 350)
					if ratingPercent == nil or ratingPercent < 0 then 
						ratingPercent = 0
					elseif ratingPercent > 1 then
						ratingPercent = 1
					end
				end
			end



			if (#boyfriendNote > 0 and input:down(curInput) and ((boyfriendNote[1].y - musicPos <= -400)) and (boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end")) and not hasLost then

				boyfriendArrow:animate(tostring(boyfriendNote[1].col) .. " confirm", false)


				health = health + 0.0125


				table.remove(boyfriendNote, 1)
			end

			if input:released(curInput) then
				boyfriendArrow:animate(tostring(i), false)
			end
		end

		if health > 2 then
			health = 2

		elseif health <= 0 and settings.showDebug ~= "detailed" and not mods[2] then


			health = 0
			if not hasLost then
				gameOverFunc()
			end

			if gameOverRed[1] > 0.9 then
				Gamestate.switch(results)
			end

			if gameoverSongSpeed[1] < 0.1 then
				voices:stop()
			end

			voices:setPitch(gameoverSongSpeed[1])



		end



		if mods[3] then
			if misses > 0 then
				if gameoverTimer then
					Timer.cancel(gameoverTimer)
				end
				gameoverTimer = Timer.tween(3, songSpeed, {[1] = 0.1}, "out-quad")
				if gameoverTimer then
					Timer.cancel(gameoverTimer)
				end
				gameoverTimer = Timer.tween(3, gameOverRed, {[1] = 0.8}, "out-quad")
				health = 0
				if gameOverRed[1] > 0.5 then
					Gamestate.push(gameOver)
				end
			end
		end

	end,


	drawUI = function(self)
		self:drawHealthbar()
		if paused then 
			love.graphics.push()
				love.graphics.setFont(pauseFont)
				love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
				if paused then
					graphics.setColor(0, 0, 0, 0.8)
					love.graphics.rectangle("fill", -10000, -2000, 25000, 10000)
					graphics.setColor(1, 1, 1)
					pauseShadow:draw()
					pauseBG:draw()
					if pauseMenuSelection ~= 1 then
						uitextflarge("Resume", -305, -275, 600, "center", false)
					else
						uitextflarge("Resume", -305, -275, 600, "center", true)
					end
					if pauseMenuSelection ~= 2 then
						uitextflarge("Restart", -305, -75, 600, "center", false)
						--  -600, 400+downscrollOffset, 1200, "center"
					else
						uitextflarge("Restart", -305, -75, 600, "center", true)
					end
					if pauseMenuSelection ~= 3 then
						uitextflarge("Quit", -305, 125, 600, "center", false)
					else
						uitextflarge("Quit", -305, 125, 600, "center", true)
					end
				end
				love.graphics.setFont(font)
			love.graphics.pop()
			return 
		end
		
		love.graphics.push()
			love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
			love.graphics.setColor(1, 0, 0, 1)

			--for i = 1,#hitErrorTable do
			--	love.graphics.setColor(hitErrorColorTable[i][1], hitErrorColorTable[i][2], hitErrorColorTable[i][3])
		--		love.graphics.rectangle("fill", hitErrorTable[i], -5, 2, 10)
		--	end

		if hitErrorColorTable[1] then

			love.graphics.setColor(hitErrorColorTable[1][1], hitErrorColorTable[1][2], hitErrorColorTable[1][3])
			love.graphics.rectangle("fill", hitErrorNote, -5, 2, 10)
			love.graphics.setColor(0,0,1,1)
			love.graphics.rectangle("fill", 0, -5, 2, 15)

		end


			love.graphics.setColor(0, 1, 0)
			hitErrorPointer:draw()

			love.graphics.setColor(1, 1, 1)

			if not settings.downscroll then
				love.graphics.scale(0.7, 0.7)
			else
				love.graphics.scale(0.7, -0.7)
			end
			love.graphics.scale(uiScale.zoom, uiScale.zoom)

			for i = 1, 4 do


				graphics.setColor(1, 1, 1)
					boyfriendArrows[i]:draw()

				graphics.setColor(1, 1, 1)

				love.graphics.push()
					love.graphics.translate(0, -musicPos)

					love.graphics.push()
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
					love.graphics.pop()
				love.graphics.pop()
			end
			love.graphics.setColor(0,0,0,1)
			love.graphics.rectangle("fill", -1000, topCover.y-630, 10000, 720)
			topCover:draw()
			graphics.setColor(1, 1, 1)
		love.graphics.pop()

		love.graphics.push()
		love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2 - 50)
		love.graphics.scale(0.7, 0.7)

			myBalls = love.timer.getDelta( )

			love.graphics.setColor(1, 1, 1, marvAlpha)
			quaverMarv:udraw(0.5, 0.5)
			love.graphics.setColor(1, 1, 1, perfAlpha)
			quaverPerf:udraw(0.5, 0.5)
			love.graphics.setColor(1, 1, 1, greatAlpha)
			quaverGreat:udraw(0.5, 0.5)
			love.graphics.setColor(1, 1, 1, goodAlpha)
			quaverGood:udraw(0.5, 0.5)
			love.graphics.setColor(1, 1, 1, okayAlpha)
			quaverOkay:udraw(0.5, 0.5)
			love.graphics.setColor(1, 1, 1, missAlpha)
			quaverMiss:udraw(0.5, 0.5)
			love.graphics.setColor(1, 1, 1, 1)

			marvAlpha = marvAlpha - 0.9*myBalls
			perfAlpha = perfAlpha - 0.9*myBalls
			greatAlpha = greatAlpha - 0.9*myBalls
			goodAlpha = goodAlpha - 0.9*myBalls
			okayAlpha = okayAlpha - 0.9*myBalls
			missAlpha = missAlpha - 0.9*myBalls

			marvOverlayAlpha = marvOverlayAlpha - 0.9*myBalls
			perfOverlayAlpha = perfOverlayAlpha - 0.9*myBalls
			greatOverlayAlpha = greatOverlayAlpha - 0.9*myBalls
			goodOverlayAlpha = goodOverlayAlpha - 0.9*myBalls
			okayOverlayAlpha = okayOverlayAlpha - 0.9*myBalls
			missOverlayAlpha = missOverlayAlpha - 0.9*myBalls

			quaverMarv.y = judgeYPos[1]
			quaverPerf.y = judgeYPos[1]
			quaverGreat.y = judgeYPos[1]
			quaverGood.y = judgeYPos[1]
			quaverOkay.y = judgeYPos[1]
			quaverMiss.y = judgeYPos[1]

			if judgeTween then
				Timer.cancel(judgeTween)
			end
			judgeTween = Timer.tween(0.1, judgeYPos, {[1] = 0}, "out-expo")
		love.graphics.pop()


	end,


	drawHealthbar = function(self, visibility)
		local visibility = visibility or 1
		love.graphics.push()
			love.graphics.push()
			graphics.setColor(0,0,0,settings.scrollUnderlayTrans)

			love.graphics.rectangle("fill", 400, -100, 90 + 170 * 2.35, 1000)

			graphics.setColor(1,1,1,1)
			love.graphics.pop()
			love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
			love.graphics.scale(0.7, 0.7)
			love.graphics.scale(uiScale.zoom, uiScale.zoom)

			graphics.setColor(1, 1, 1, 1)

			quaverHealth.x, quaverHealth.y = 510, 65
			love.graphics.rectangle("fill", 500, 450, 20, -health * 408)       --------

			quaverHealth:draw()

			firstPR = ((math.floor(ratingPercent * 10000) / 100) / 100)*(songDifficulty * 1.15)

			finalPR = math.floor(firstPR * 100) / 100


			local rating = ((math.floor(ratingPercent * 10000) / 100))

			if rating >= 100 then
				ratings.X:udraw(0.3, 0.3)
			elseif rating >= 95 then
				ratings.SS:udraw(0.3, 0.3)
			elseif rating >= 90 then
				ratings.S:udraw(0.3, 0.3)
			elseif rating >= 80 then
				ratings.A:udraw(0.3, 0.3)
			elseif rating >= 70 then
				ratings.B:udraw(0.3, 0.3)
			elseif rating >= 60 then
				ratings.C:udraw(0.3, 0.3)
			elseif rating >= 50 then
				ratings.D:udraw(0.3, 0.3)
			elseif rating < 50 then
				ratings.F:udraw(0.3, 0.3)
			end

			marvOverlay.x, marvOverlay.y = 883, -150
			perfOverlay.x, perfOverlay.y = 883, -90
			greatOverlay.x, greatOverlay.y = 883, -30
			goodOverlay.x, goodOverlay.y = 883, 30
			okayOverlay.x, okayOverlay.y = 883, 90
			missOverlay.x, missOverlay.y = 883, 150

			love.graphics.setColor(1/2, 1/2, 1/2)

			marvOverlay:draw()
			love.graphics.setColor(255/255/2, 231/255/2, 107/255/2)

			perfOverlay:draw()
			love.graphics.setColor(86/255/2, 254/255/2, 110/255/2)

			greatOverlay:draw()
			love.graphics.setColor(0/255/2, 209/255/2, 255/255/2)

			goodOverlay:draw()
			love.graphics.setColor(217/255/2, 107/255/2, 206/255/2)

			okayOverlay:draw()
			love.graphics.setColor(249/255/2, 100/255/2, 93/255/2)

			missOverlay:draw()

			love.graphics.setColor(1, 1, 1, marvOverlayAlpha)

			marvOverlay:draw()
			love.graphics.setColor(255/255, 231/255, 107/255, perfOverlayAlpha)

			perfOverlay:draw()
			love.graphics.setColor(86/255, 254/255, 110/255, greatOverlayAlpha)

			greatOverlay:draw()
			love.graphics.setColor(0/255, 209/255, 255/255, goodOverlayAlpha)

			goodOverlay:draw()
			love.graphics.setColor(217/255, 107/255, 206/255, okayOverlayAlpha)

			okayOverlay:draw()
			love.graphics.setColor(249/255, 100/255, 93/255, missOverlayAlpha)

			missOverlay:draw()

			love.graphics.setColor(1, 1, 1)

			love.graphics.setFont(quaverFontLarge)
			--love.graphics.print(score, -850, -500)
			-- string.format for 7 digits
			love.graphics.print(string.format("%07d", score), -900, -520)
			love.graphics.printf(string.format("%.2f", finalPR), -900, -470, 1000)

			love.graphics.setColor(0,0,1)
			comboposx = -20
			if combo > 10 then
				comboposx = -40
			elseif combo > 100 then
				comboposx = -60
			elseif combo > 1000 then
				comboposx = -80
			elseif combo > 10000 then
				comboposx = -100
			end
			love.graphics.printf(combo, comboposx, judgeYPos[1]-200, 1000, "left", 0, 1.4, 1.4)
			love.graphics.setColor(1,1,1)

			love.graphics.printf(combo, comboposx, judgeYPos[1]-200, 1000, "left", 0, 1.3, 1.3)

			local averageClicks = clickCount / timer

			--love.graphics.printf((math.floor(ratingPercent * 10000) / 100) .. "%", 400, -525, 500, "right")
			-- string.format so theres always 2 decimal places
			love.graphics.printf(string.format("%.2f", (math.floor(ratingPercent * 10000) / 100)) .. "%", 405, -525, 500, "right")
			love.graphics.printf(nps, 802, -480, 100, "right")

			love.graphics.setFont(quaverFontSmall)

			love.graphics.print(marvs, 863, -170)
			love.graphics.print(perfs, 863, -110)
			love.graphics.print(greats, 863, -50)
			love.graphics.print(goods, 863, 10)
			love.graphics.print(okays, 863, 70)
			love.graphics.print(misses, 863, 130)
			love.graphics.setColor(1, 1, 1, 1)

			comboPopup:draw()

			love.graphics.setColor(1, 0, 0, gameOverRed[1])
			love.graphics.rectangle("fill", -1000, -1000, 10000, 10000)
			love.graphics.setColor(1, 1, 1, 1)

		love.graphics.pop()
		love.graphics.push()
			-- make a small yellow-ish time-bar at the bottom that grows as the song progresses (Use musicTime)
			love.graphics.setColor(0.4, 0.4, 0.4, 1)
			love.graphics.rectangle("fill", 0, 715, 1282, 10)
			love.graphics.setColor(0.8, 0.8, 0, 1)
			-- use the opposite of ((inst:getDuration("seconds") - musicTime/1000) / inst:getDuration("seconds")) to get the percentage of the song that has passed
			-- draw a rect to draw the precentage of the song that has passed
			love.graphics.rectangle("fill", 0, 715, 1282 * ((musicTime/1000) / voices:getDuration("seconds")), 10)
			-- on the left, print the time passed in minutes:seconds in a cyan-like color
			love.graphics.setColor(0, 0.8, 0.8, 1)
			love.graphics.setFont(quaverFontSmall)
			love.graphics.print(string.format("%02d:%02d", math.floor(musicTime/1000/60), math.floor(musicTime/1000%60)), 5, 680)
			-- on the right, print the time left in minutes:seconds in a cyan-like color
			love.graphics.print(string.format("%02d:%02d", math.floor((voices:getDuration("seconds") - musicTime/1000)/60), math.floor((voices:getDuration("seconds") - musicTime/1000)%60)), 1198, 680)
			love.graphics.setColor(1, 1, 1, 1)

		love.graphics.pop()
		love.graphics.push()
		love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)


			--testing the countdown
			love.graphics.setColor(1,1,1,countdownFade[1])
			love.graphics.setFont(quaverFontLarge)
			love.graphics.printf(curSong .. "\n" ..
								songDifficulty .. "\n",
								-graphics.getWidth()/2+160, 0, graphics.getWidth(), "center", nil, 0.75, 0.75)
			love.graphics.setFont(font)


			love.graphics.setColor(1,1,1,1)
		love.graphics.pop()
		love.graphics.push()
		love.graphics.translate(graphics.getWidth(), graphics.getHeight())
		love.graphics.setColor(1, 1, 1, dyingAlpha)
		dyingOverlay:draw()

		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.pop()
	end,

	leave = function(self)

		voices:stop()

		playMenuMusic = true


		Timer.clear()
	end
}
