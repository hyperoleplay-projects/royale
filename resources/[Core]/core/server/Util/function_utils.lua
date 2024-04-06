local abyte = string.byte("A")
local zbyte = string.byte("0")
local usedCodes = {}  -- Tabela para armazenar os códigos utilizados
-----------------------------------------------------------------------------------------------------------------------------------------
-- DUMP
-----------------------------------------------------------------------------------------------------------------------------------------
function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TD
-----------------------------------------------------------------------------------------------------------------------------------------
function tD(n)
    n = math.ceil(n * 100) / 100
    return n
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- tablelength
-----------------------------------------------------------------------------------------------------------------------------------------
function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATESTRINGNUMBER
-----------------------------------------------------------------------------------------------------------------------------------------
function generateStringNumber(format)
    local number = ""

    repeat
        number = ""  -- Limpar o número gerado

        for i = 1, #format do
            local char = string.sub(format, i, i)

            if char == "D" then
                number = number .. string.char(zbyte + math.random(0, 9))
            elseif char == "L" then
                number = number .. string.char(abyte + math.random(0, 25))
            else
                number = number .. char
            end
        end
    until not usedCodes[number]  -- Repetir até que o código gerado não esteja na tabela

    usedCodes[number] = true  -- Adicionar o código à tabela de códigos utilizados
    return number
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GenerateCenterPoint
-----------------------------------------------------------------------------------------------------------------------------------------
function GenerateCenterPoint(distance, notDIVIDED)
	local vec = vector3(0.0, 0.0, 0.0)

	local radius = math.floor(distance / 6)
	while Vmag(vec) < distance do
		vec = vec + vector3(math.random(-radius, radius), math.random(-radius, radius), 0.0)
		Citizen.Wait(0)
	end

	return notDIVIDED and vec or vec - vec / 2
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VectorToTable
-----------------------------------------------------------------------------------------------------------------------------------------
function VectorToTable(vec)
	return { x = vec.x, y = vec.y, z = vec.z }
end