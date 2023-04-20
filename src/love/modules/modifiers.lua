return {
	enter = function(self, previous)


		mods = {
			1,   -- rate          1
			false, -- no fail     2
			false, -- no miss     3
			false, -- PLACEHOLDER 4
			false, -- autoplay    5
			false, -- cinema mode 6
			false, -- mirror      7
			false,
			false  -- no long notes 9
		}

		cursorTable = {           -- this shit looks like something yanderedev would do 😭😭
			">",
			">",
			">",
			">",
			">",
			">",
			">",
			">",
			">"
		}


		modsDescriptions = {
			"Change the playback speed of the song. (will disable video backgrounds automatically)",
			"Impossible to lose",
			"If you miss a note, you die",
			"PLACEHOLDER",
			"Watch a perfect playthrough of the song",
			"View the background without any HUD or UI elements",
			"Mirrors the note lanes",
			"Randomizes what lane each note will be in",
			"Removes all long notes from the song"
		}




		modSelection = 1

	end,

	update = function(self, dt)

		if modsMenuOpened then
			if input:pressed("up") then
				if modSelection == 1 then
					modSelection = 9 
				else
					modSelection = modSelection - 1
				end
			elseif input:pressed("down") then
				if modSelection == 9 then
					modSelection = 1
				else
					modSelection = modSelection + 1
				end
			elseif input:pressed("confirm") then
				if modSelection ~= 1 then
					if mods[modSelection] then
						mods[modSelection] = false
					elseif not mods[modSelection] then
						mods[modSelection] = true
					end
				end
			elseif input:pressed("right") then
				if modSelection == 1 then
					if mods[1] >= 2 then
						mods[1] = 0.5
					else
						mods[1] = mods[1] + 0.1
					end
				end
			elseif input:pressed("left") then
				if modSelection == 1 then
					if mods[1] <= 0.5 then
						mods[1] = 2
					else
						mods[1] = mods[1] - 0.1
					end
				end
			elseif input:pressed("rateReset") then
				if modSelection == 1 then
					mods[1] = 1
				end
			end
		end



		for i = 1,9 do
			if i == modSelection then
				cursorTable[i] = ">"
			else
				cursorTable[i] = ""
			end
		end
	

	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			if modsMenuOpened then
				love.graphics.setFont(quaverFontSmall)
				love.graphics.setColor(0,0,0,0.8)
				love.graphics.rectangle("fill", -1000, -1000, 10000, 10000)
				love.graphics.setColor(1,1,1,1)

				love.graphics.printf("Song Rate: " .. tostring(mods[1]) .. "\n" ..
									"No Fail: " .. tostring(mods[2]) .. "\n" ..
									"No Miss: " .. tostring(mods[3]) .. "\n" ..
									"PLACEHOLDER: " .. tostring(mods[4]) .. "\n" ..
									"Autoplay: " .. tostring(mods[5]) .. "\n" ..
									"Cinema: " .. tostring(mods[6]) .. "\n" ..
									"Mirror: " .. tostring(mods[7]) .. "\n" ..
									"Randomize: " .. tostring(mods[8]) .. "\n" ..
									"No Long Notes: " .. tostring(mods[9]),
									-graphics.getWidth()/2+160, -150, graphics.getWidth(), "center", nil, 0.75, 0.75)

				love.graphics.printf(cursorTable[1] .. "\n" .. cursorTable[2] .. "\n" .. cursorTable[3] .. "\n" .. cursorTable[4] .. "\n" .. cursorTable[5] .. "\n" .. cursorTable[6] .. "\n" .. cursorTable[7]  .. "\n" .. cursorTable[8] .. "\n" .. cursorTable[9], -graphics.getWidth()/2+50, -150, graphics.getWidth(), "center", nil, 0.75, 0.75)

				love.graphics.printf(modsDescriptions[modSelection], -graphics.getWidth()/2+160, 250, graphics.getWidth(), "center", nil, 0.75, 0.75)


									
			end

		love.graphics.pop()
	end,
}
