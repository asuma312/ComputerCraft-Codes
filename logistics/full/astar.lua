require("Coordinates")

-- Sistema de pathfinding usando A*
nodesObj = {
    startNode = nil,
    endNode = nil,
    existingNodesHashmap = {},
    nodes = {},
    currentNode = nil,
}

node = {}

function node:new(o, x, y, z, parent)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- Corrigido: atribua ao objeto 'o', não a 'self'
    o.X = x or COORDS.X or 0
    o.Y = y or COORDS.Y or 0
    o.Z = z or COORDS.Z or 0
    o.G = 3
    o.H = 0
    o.F = 0
    o.CLOSED = false
    o.VISITED = false
    o.parent = parent or nil
    return o
end

function node:calculateH(endNode)
    local dx = math.abs(self.X - endNode.X)
    local dy = math.abs(self.Y - endNode.Y)
    local dz = math.abs(self.Z - endNode.Z)
    self.H = (dx + dy + dz) * 10
end

function node:calculateG(startNode)
    local dx = math.abs(self.X - startNode.X)
    local dy = math.abs(self.Y - startNode.Y)
    local dz = math.abs(self.Z - startNode.Z)
    self.G = (dx + dy + dz) * 10
end

function node:calculateF()
    self.F = self.G + self.H
    return self.F
end

function nodesObj:addNode(newNode)
    local key = newNode.X .. "," .. newNode.Y .. "," .. newNode.Z
    self.existingNodesHashmap[key] = newNode
    table.insert(self.nodes, newNode)
    return true
end

function nodesObj:calculateNodes()
    local sides = {
        COORDS.DIRECTIONS.NORTH,
        COORDS.DIRECTIONS.EAST,
        COORDS.DIRECTIONS.SOUTH,
        COORDS.DIRECTIONS.WEST,
    }
    
    -- Gerar nós adjacentes nas quatro direções horizontais
    for i=1, #sides do
        local newX, newY, newZ = COORDS.X, COORDS.Y, COORDS.Z
        
        if sides[i] == COORDS.DIRECTIONS.NORTH then
            newZ = newZ - 1
        elseif sides[i] == COORDS.DIRECTIONS.SOUTH then
            newZ = newZ + 1
        elseif sides[i] == COORDS.DIRECTIONS.EAST then
            newX = newX + 1
        elseif sides[i] == COORDS.DIRECTIONS.WEST then
            newX = newX - 1
        end
        
        local newNode = node:new(nil, newX, newY, newZ, self.currentNode)
        newNode:calculateG(self.startNode)
        newNode:calculateH(self.endNode)
        newNode:calculateF()
        local existingNode = self.existingNodesHashmap[newNode.X .. "," .. newNode.Y .. "," .. newNode.Z]
        if existingNode == nil then

            
            COORDS.turnToDirection(sides[i])
            local success, data = turtle.inspect()
            if success then
                -- Verificação corrigida para bloqueios
                local blockName = data.name
                if blockName == "minecraft:air" or 
                blockName == "minecraft:water" or 
                blockName == "minecraft:lava" or 
                blockName == "minecraft:flowing_water" or 
                blockName == "minecraft:flowing_lava" then
                    newNode.CLOSED = false
                else
                    newNode.CLOSED = true
                end
            else
                newNode.CLOSED = false
            end
            
            self:addNode(newNode)
        else
            existingNode.parent = newNode.parent
        end
        print("Nó: " .. newNode.X .. "," .. newNode.Y .. "," .. newNode.Z .. 
              " G: " .. newNode.G .. " H: " .. newNode.H .. " F: " .. newNode.F,
            "CLOSED: " .. tostring(newNode.CLOSED) .. " VISITED: " .. tostring(newNode.VISITED))
    end

    -- Verificar nó acima
    local upNode = node:new(nil, COORDS.X, COORDS.Y + 1, COORDS.Z, self.currentNode)
    upNode:calculateG(self.startNode)
    upNode:calculateH(self.endNode)
    upNode:calculateF()

    local existingNode = self.existingNodesHashmap[upNode.X .. "," .. upNode.Y .. "," .. upNode.Z]
    if existingNode == nil then
        local success, data = turtle.inspectUp()
        if success then
            local blockName = data.name
            if blockName == "minecraft:air" or 
            blockName == "minecraft:water" or 
            blockName == "minecraft:lava" or 
            blockName == "minecraft:flowing_water" or 
            blockName == "minecraft:flowing_lava" then
                upNode.CLOSED = false
            else
                upNode.CLOSED = true
            end
        else
            upNode.CLOSED = false
        end
        self:addNode(upNode)
    else
        existingNode.parent = upNode.parent
    end
    print("Nó: " .. upNode.X .. "," .. upNode.Y .. "," .. upNode.Z .. 
          " G: " .. upNode.G .. " H: " .. upNode.H .. " F: " .. upNode.F .. 
          "CLOSED: " .. tostring(upNode.CLOSED) .. " VISITED: " .. tostring(upNode.VISITED))

    -- Verificar nó abaixo
    local downNode = node:new(nil, COORDS.X, COORDS.Y - 1, COORDS.Z, self.currentNode)
    downNode:calculateG(self.startNode)
    downNode:calculateH(self.endNode)
    downNode:calculateF()

    local existingNode = self.existingNodesHashmap[downNode.X .. "," .. downNode.Y .. "," .. downNode.Z]
    if existingNode == nil then
        local success, data = turtle.inspectDown()
        if success then
            local blockName = data.name
            if blockName == "minecraft:air" or 
            blockName == "minecraft:water" or 
            blockName == "minecraft:lava" or 
            blockName == "minecraft:flowing_water" or 
            blockName == "minecraft:flowing_lava" then
                downNode.CLOSED = false
            else
                downNode.CLOSED = true
            end
        else
            downNode.CLOSED = false
        end
        print("Nó: " .. downNode.X .. "," .. downNode.Y .. "," .. downNode.Z .. 
            " G: " .. downNode.G .. " H: " .. downNode.H .. " F: " .. downNode.F ..
            "CLOSED: " .. tostring(downNode.CLOSED) .. " VISITED: " .. tostring(downNode.VISITED))
        self:addNode(downNode)
    else
        existingNode.parent = downNode.parent
    end

end

function nodesObj:findLowestFNode()
    local lowestFNode = nil
    local lowestF = math.huge
    
    for i=1, #self.nodes do
        if self.nodes[i].CLOSED == false and 
           self.nodes[i].VISITED == false and
           self.nodes[i].F < lowestF then
            lowestF = self.nodes[i].F
            lowestFNode = self.nodes[i]
        elseif 
        self.nodes[i].CLOSED == false and 
        self.nodes[i].VISITED == false and
        self.nodes[i].F == lowestF and
        self.nodes[i].Y > lowestFNode.Y then
            lowestF = self.nodes[i].F
            lowestFNode = self.nodes[i]       
        elseif 
            self.nodes[i].CLOSED == false and 
            self.nodes[i].VISITED == false and
            self.nodes[i].F == lowestF and
            self.nodes[i].H < lowestFNode.H then
            lowestF = self.nodes[i].F
            lowestFNode = self.nodes[i]
        end
    end
    
    self.currentNode = lowestFNode
    return lowestFNode
end

function nodesObj:doPathFinding(startNodeCoords, endNodeCoords)
    self.startNode = node:new(nil, startNodeCoords.X, startNodeCoords.Y, startNodeCoords.Z)
    self.startNode.VISITED = true
    self.endNode = node:new(nil, endNodeCoords.X, endNodeCoords.Y, endNodeCoords.Z)

    nodesObj:addNode(self.startNode)
    

    COORDS.init()
    self:calculateNodes()
    local nextNode = self:findLowestFNode()
    if nextNode then
        nextNode.VISITED = true
    end
    return nextNode
end

function nodesObj:clearNodes()
    self.nodes = {}
    self.existingNodesHashmap = {}
end

function nodesObj:getNextPath()
    COORDS.init()

    self:calculateNodes()
    
    local nextNode = self:findLowestFNode()
    if nextNode == nil then
        return nil
    end
    nextNode.VISITED = true
    return nextNode
end

return nodesObj