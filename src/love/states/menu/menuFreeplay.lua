local leftFunc, rightFunc, confirmFunc, backFunc, drawFunc

local menuState

local menuNum = 1
local songNum, weekNum

local songNum, songAppend
local songDifficulty = 2

local difficultyStrs
local selectSound, confirmSound
local ratingText

return {
    enter = function(self)
        selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
        confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")


        graphics:fadeInWipe(0.6)


        modsMenuOpened = false

        function modsMenuToggle()
            if modsMenuOpened then
                modsMenuOpened = false
            else 
                modsMenuOpened = true
            end
        end


        songsTable = love.filesystem.getDirectoryItems("songs/quaver")




        function getSongName()
            songNameFunc1 = json.decode(love.filesystem.read("songs/quaver/" .. selectedSong .. "/chart.json"))
            displaySongName = songNameFunc1["song"]["song"]
        end

        selectedSong = 1

        getSongName()
    end,
    
    update = function(self, dt)
        if input:pressed("down") and not modsMenuOpened then
            if selectedSong == #songsTable then
                selectedSong = 1
            else
                selectedSong = selectedSong + 1
            end

            getSongName()
        elseif input:pressed("up") and not modsMenuOpened then
            if selectedSong == 1 then
                selectedSong = #songsTable
            else
                selectedSong = selectedSong - 1
            end

            getSongName()


        elseif input:pressed("confirm") and not modsMenuOpened then
            if menuNum == 1 then songNum = 1 end
            if menuNum == 2 then
                status.setLoading(true)
    
                graphics:fadeOutWipe(
                    0.7,
                    function()
    
                        storyMode = false
    
                        music:stop()

                        Gamestate.switch(weekData[2], 1, "")
     
                        status.setLoading(false)
                    end
                )
            end
            if menuNum ~= 2 then
                menuNum = menuNum + 1
            end

            audio.playSound(confirmSound)
        elseif input:pressed("back") and not modsMenuOpened then
            if menuNum ~= 1 then
                menuNum = menuNum - 1
            else
                graphics:fadeOutWipe(0.7, function()
                    Gamestate.switch(menuSelect)
                end)
            end
            audio.playSound(selectSound)
        elseif input:pressed("modsMenu") then
            modsMenuToggle()
        end





    end,

    draw = function(self, dt)
        love.graphics.push()
            love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

                love.graphics.printf(tostring(displaySongName), 60, -72, 600, "center")
            

        love.graphics.pop()
    end
}