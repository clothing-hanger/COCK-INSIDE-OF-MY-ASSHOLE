local upFunc, downFunc, confirmFunc, drawFunc, musicStop

local menuState

local menuNum = 1

local songNum, songAppend
local songDifficulty = 2

local selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
local confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")
local transparency
local bpm, time

return {
	enter = function(self, previous)

        ratingX, ratingY = 330,20
        ratingSizeX, ratingSizeY = 2.5,2.5

        judgeSize = 0.2





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

        ratings.X.x, ratings.X.y = ratingX, ratingY
		ratings.F.x, ratings.F.y = ratingX, ratingY
		ratings.D.x, ratings.D.y = ratingX, ratingY
		ratings.C.x, ratings.C.y = ratingX, ratingY
		ratings.B.x, ratings.B.y = ratingX, ratingY
		ratings.A.x, ratings.A.y = ratingX, ratingY
		ratings.S.x, ratings.S.y = ratingX, ratingY
		ratings.SS.x, ratings.SS.y = ratingX, ratingY

        quaverMarv = graphics.newImage(graphics.imagePath("quaver/judge/judge-marv"))
		quaverPerf = graphics.newImage(graphics.imagePath("quaver/judge/judge-perf"))
		quaverGreat = graphics.newImage(graphics.imagePath("quaver/judge/judge-great"))
		quaverGood = graphics.newImage(graphics.imagePath("quaver/judge/judge-good"))
		quaverOkay = graphics.newImage(graphics.imagePath("quaver/judge/judge-okay"))
		quaverMiss = graphics.newImage(graphics.imagePath("quaver/judge/judge-miss"))


        quaverMarv.x, quaverMarv.y = -500-40, -110
        quaverPerf.x, quaverPerf.y = -420-40, 0-110

        
        quaverGreat.x, quaverGreat.y = -340-40, 0-110
        quaverGood.x, quaverGood.y = -260-40, 0-110
        quaverOkay.x, quaverOkay.y = -180-40, 0-110
        quaverMiss.x, quaverMiss.y = -100-40, 0-110


        displayJudgments = {0,0,0,0,0,0}


        Timer.tween(2, displayJudgments, {[1] = marvs, [2] = perfs, [3] = greats, [4] = goods, [5] = okays, [6] = misses})
        

		bg = graphics.newImage(graphics.imagePath("menu/results"))


		
		changingMenu = false


        displayAccuracy = {0}

        ratingPercentPenis = {0}

        Timer.tween(2, displayAccuracy, {[1] = ratingPercent}, "out-quad")

        Timer.tween(2, ratingPercentPenis, {[1] = ratingPercent}, "out-quad")

        percentMeterX, percentMeterY = -220, 175



        songDisplayName = string.sub(curSong, 1, 15)


	end,

	update = function(self, dt)

		if not graphics.isFading() then
			if input:pressed("confirm") then
                graphics:fadeInWipe(0.6, function() Gamestate.switch(menuFreeplay) end)
                
            end
		end

	end,
    

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

			love.graphics.push()
				love.graphics.push()

                bg:draw()

                local rating = ((math.floor(ratingPercentPenis[1] * 10000) / 100))

                if not hasLost then
                    if rating >= 100 then
                        ratings.X:udraw(ratingSizeX, ratingSizeY)
                    elseif rating >= 95 then
                        ratings.SS:udraw(ratingSizeX, ratingSizeY)
                    elseif rating >= 90 then
                        ratings.S:udraw(ratingSizeX, ratingSizeY)
                    elseif rating >= 80 then
                        ratings.A:udraw(ratingSizeX, ratingSizeY)
                    elseif rating >= 70 then
                        ratings.B:udraw(ratingSizeX, ratingSizeY)
                    elseif rating >= 60 then
                        ratings.C:udraw(ratingSizeX, ratingSizeY)
                    elseif rating >= 50 then
                        ratings.D:udraw(ratingSizeX, ratingSizeY)
                    elseif rating < 50 then
                        ratings.F:udraw(ratingSizeX, ratingSizeY)
                    end
                else
                    ratings.F:udraw(ratingSizeX, ratingSizeY)
                end
                print(resultsDifficulty)
                print(curSong) 

                quaverMarv:udraw(judgeSize,judgeSize)
                quaverPerf:udraw(judgeSize,judgeSize)
                quaverGreat:udraw(judgeSize,judgeSize)
                quaverGood:udraw(judgeSize,judgeSize)
                quaverOkay:udraw(judgeSize,judgeSize)
                quaverMiss:udraw(judgeSize,judgeSize)

                love.graphics.setFont(quaverFontLarge)
                love.graphics.setColor(0,0,0)

                love.graphics.printf(songDisplayName, -580, -300, 500, "left")
                

                love.graphics.printf(string.format("%.2f",displayAccuracy[1]*100) .. "%", percentMeterX-370, percentMeterY-45, 500, "left", nil, 1, 1)

            love.graphics.setFont(quaverFontSmall)

                


                love.graphics.printf(string.format("%.0f",displayJudgments[1]), quaverMarv.x-33, quaverMarv.y+10, 100, "left")
                love.graphics.printf(string.format("%.0f",displayJudgments[2]), quaverPerf.x-33, quaverPerf.y+10, 100, "left")
                love.graphics.printf(string.format("%.0f",displayJudgments[3]), quaverGreat.x-33, quaverGreat.y+10, 100, "left")
                love.graphics.printf(string.format("%.0f",displayJudgments[4]), quaverGood.x-33, quaverGood.y+10, 100, "left")
                love.graphics.printf(string.format("%.0f",displayJudgments[5]), quaverOkay.x-33, quaverOkay.y+10, 100, "left")
                love.graphics.printf(string.format("%.0f",displayJudgments[6]), quaverMiss.x-33, quaverMiss.y+10, 100, "left")

                

                love.graphics.printf("Difficulty Rating: " .. songDifficulty, -580, -240, 500, "left")
                love.graphics.printf("Performance Rating: " .. finalPR, -580, -210, 500, "left")



                

                love.graphics.arc("fill", percentMeterX, percentMeterY, 105, 0, 2*math.pi*(displayAccuracy[1]))

                love.graphics.setColor(1,1,1)
                love.graphics.circle("fill", percentMeterX, percentMeterY, 100)





                love.graphics.pop()
			love.graphics.pop()

		love.graphics.pop()
	end,

	leave = function(self)

	end
}
