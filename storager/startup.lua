require("Coordinates")
X = -157
Y = 68
Z = -70
DIRECTION = 'east'

COORDS.LoadCoordinates()
if COORDS.X == 0 and COORDS.Y == 0 and COORDS.Z == 0 then
    COORDS.X = X
    COORDS.Y = Y
    COORDS.Z = Z
    COORDS.SaveCoordinates(X, Y, Z, COORDS.DIRECTIONS.EAST)
end

shell.run('Storager.lua' .. ' ' .. X .. ' ' .. Y .. ' ' .. Z .. ' ' .. DIRECTION)