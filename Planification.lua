require("Coordinates")


write("How many blocks height?> ")
BLOCKS_HEIGHT = tonumber(read())
write("This is X=0, whats X start?> ")
X_START = tonumber(read())
write("This is X=0, whats X end?> ")
X_END = tonumber(read())
write("This is Z=0, whats Z start?> ")
Z_START = tonumber(read())
write("This is Z=0, whats Z end?> ")
Z_END = tonumber(read())


--now it will break a squre based on x-start, x-end, z-start and z-end with blocks-height Y so it will be a cube with the based height

function Planification()
    --first break until are in X-START and Z-START
    COORDS.MoveToCords(X_START, COORDS.Y, Z_START)
end

Planification()