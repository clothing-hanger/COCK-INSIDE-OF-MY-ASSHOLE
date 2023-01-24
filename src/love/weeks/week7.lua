return {
    enter = function(self, from, songNum, songAppend)
		pauseColor = {50, 50, 50}
		weeks:enter() 

		week = 7

        sky = graphics.newImage(graphics.imagePath("week7/tankSky"))
        ground = graphics.newImage(graphics.imagePath("week7/tankGround"))
        watchTower = love.filesystem.load("sprites/week7/tankWatchtower.lua")()
        smokeLeft = love.filesystem.load("sprites/week7/smokeLeft.lua")()
        smokeRight = love.filesystem.load("sprites/week7/smokeRight.lua")()

        tank0 = love.filesystem.load("sprites/week7/tank0.lua")()
        tank1 = love.filesystem.load("sprites/week7/tank1.lua")()
        tank2 = love.filesystem.load("sprites/week7/tank2.lua")()
        tank3 = love.filesystem.load("sprites/week7/tank3.lua")()
        tank4 = love.filesystem.load("sprites/week7/tank4.lua")()
        tank5 = love.filesystem.load("sprites/week7/tank5.lua")()

        girlfriend = love.filesystem.load("sprites/week7/gfTankmen.lua")()
        enemy = love.filesystem.load("sprites/week7/tankmanCaptain.lua")()

		cutsceneTime, cutsceneTimeThres, oldcutsceneTimeThres = 0, 0, 0

		if storyMode and not died then
			musicPos = 0
			camera.sizeX, camera.sizeY = 1.1, 1.1
			camera.scaleX, camera.scaleY = 1.1, 1.1
		end

        tank0.x, tank0.y = -1000, 603
        tank1.x, tank1.y = -675, 739
        tank2.x, tank2.y = -250, 614
        tank3.x, tank3.y = 250, 703
        tank4.x, tank4.y = 675, 606
        tank5.x, tank5.y = 1000, 618

        sky.sizeX, sky.sizeY = 1.3, 1.3
        ground.sizeX, ground.sizeY = 1.3, 1.3
        ground.y = 100

		song = songNum
		difficulty = songAppend

		enemyIcon:animate("tankman")

        girlfriend.x, girlfriend.y = 15, 190
        enemy.x, enemy.y = -560, 340
        boyfriend.x, boyfriend.y = 460, 423

        watchTower.x, watchTower.y = -670, 250
        smokeLeft.x, smokeLeft.y = -1000, 250
        smokeRight.x, smokeRight.y = 1000, 250
        
        enemy.sizeX = -1

		self:load()
	end,

	load = function(self)
		weeks:load()

		if song == 3 then
			picoSpeaker = love.filesystem.load("sprites/week7/picoSpeaker.lua")()
			picoSpeaker.x, picoSpeaker.y = 105, 110
			boyfriend = love.filesystem.load("sprites/week7/bfAndGF.lua")()
			boyfriend.x, boyfriend.y = 460, 423
			fakeBoyfriend = love.filesystem.load("sprites/week7/gfdead.lua")()
			fakeBoyfriend.x, fakeBoyfriend.y = 460, 423
			if not died and storyMode then
				video = cutscene.video("videos/stressCutscene.ogv")
				video:play()
			end

			inst = love.audio.newSource("songs/week7/stress/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week7/stress/Voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/week7/guns/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week7/guns/Voices.ogg", "stream")
			if storyMode and not died then
				video = cutscene.video("videos/gunsCutscene.ogv")
				video:play()
			end
		else
			inst = love.audio.newSource("songs/week7/ugh/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week7/ugh/Voices.ogg", "stream")
			if storyMode and not died then
				video = cutscene.video("videos/ughCutscene.ogv")
				video:play()
			end
		end

		self:initUI()

		if not inCutscene then
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/week7/stress/stress" .. difficulty .. ".json")
            --weeks:generatePicoNotes("data/week7/stress/picospeaker.json")
		elseif song == 2 then
			weeks:generateNotes("data/week7/guns/guns" .. difficulty .. ".json")
		else
			weeks:generateNotes("data/week7/ugh/ugh" .. difficulty .. ".json")
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
        watchTower:update(dt)
        smokeLeft:update(dt)
        smokeRight:update(dt)
        tank0:update(dt)
        tank1:update(dt)
        tank2:update(dt)
        tank3:update(dt)
        tank4:update(dt)
        tank5:update(dt)

        if beatHandler.onBeat() and beatHandler.getBeat() % 2 == 0 then
            tank0:animate("anim", false)
            tank1:animate("anim", false)
            tank2:animate("anim", false)
            tank3:animate("anim", false)
            tank4:animate("anim", false)
            tank5:animate("anim", false)
        end

		if inCutscene then
			if not video:isPlaying() then 
				inCutscene = false
				video:destroy()
				weeks:setupCountdown()
			end
		end

		if song == 1 then
			if musicTime >= 5620 then
				if musicTime <= 5720 then
					if enemy:getAnimName() == "up" then
						enemy:animate("ugh", false)
					end
				end
			end
			if musicTime >= 14620 then
				if musicTime <= 14720 then
					if enemy:getAnimName() == "up" then
						enemy:animate("ugh", false)
					end
				end
			end
			if musicTime >= 49120 then
				if musicTime <= 49220 then
					if enemy:getAnimName() == "up" then
						enemy:animate("ugh", false)
					end
				end
			end
			if musicTime >= 77620 then
				if musicTime <= 77720 then
					if enemy:getAnimName() == "up" then
						enemy:animate("ugh", false)
					end
				end
			end
		end

        if song == 3 then
			if musicTime >= 62083 then
				if musicTime <= 62083 + 50 then
					enemy:animate("good", false)
				end
			end
		end

		if health >= 80 then
            if enemyIcon:getAnimName() == "tankman" then
                enemyIcon:animate("tankman losing", false)
            end
        else
            if enemyIcon:getAnimName() == "tankman losing" then
                enemyIcon:animate("tankman", false)
            end
        end

		if not (countingDown or graphics.isFading()) and not (inst:isPlaying() and voices:isPlaying()) and not inCutscene then
			if storyMode and song < 3 then
				song = song + 1
				died = false

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

	draw = function()
        if inCutscene then 
            video:draw()
            return
        end
        love.graphics.push()
            love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
            love.graphics.scale(camera.sizeX, camera.sizeY)
            love.graphics.push()
                love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

                sky:draw()
                watchTower:draw()
                smokeLeft:draw()
                smokeRight:draw()
                ground:draw()
                if song ~= 3 then
                    girlfriend:draw()
                else
                    picoSpeaker:draw()
                end
            love.graphics.pop()
            love.graphics.push()
                love.graphics.translate(camera.x, camera.y)

                if not inCutscene then
                    enemy:draw()
                end
                boyfriend:draw()
                
                tank0:draw()
                tank1:draw()
                tank2:draw()
                tank3:draw()
                tank4:draw()
                tank5:draw()
            love.graphics.pop()
        love.graphics.pop()

        weeks:drawUI()
    end,

	leave = function(self)
		song = 1
        died = false
        inCutscene = false
        sky = nil
        ground = nil
        girlfriend = nil
        boyfriend = nil
        enemy = nil
        watchTower = nil
        smokeLeft = nil
        smokeRight = nil
        tank0 = nil
        tank1 = nil
        tank2 = nil
        tank3 = nil
        tank4 = nil
        tank5 = nil
		weeks:leave()
	end
}