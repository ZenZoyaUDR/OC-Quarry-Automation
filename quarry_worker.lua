local component = require("component");
local robot = require("robot")
local event = require("event")
local os = require("os")
local tunnel = component.tunnel
local invController = component.inventory_controller

local maxTries = 16
local QUARRY = "BuildCraft|Builders:machineBlock"
local ENDER_CHEST = "EnderStorage:enderChest"
local HYPER_CUBE = "EnderIO:blockTransceiver"
local allowedItems = {
    QUARRY,
    ENDER_CHEST,
    HYPER_CUBE,
}

local function moveForwardBreak()
    if robot.detect() then
        robot.swing()
    end

    local tries = 0
    while not robot.forward() do
        if tries > maxTries then
            print("Max tries exceeded (", maxTries, ")")
            tunnel.send("error", "Max tries exceeded", robot.name())
            os.exit()
        end
        
        robot.swing()
        tries = tries+1
    end
end

local function moveUpBreak()
    if robot.detectUp() then
        robot.swingUp()
    end

    local tries = 0
    while not robot.up() do
        if tries > maxTries then
            print("Max tries exceeded (", maxTries, ")")
            tunnel.send("error", "Max tries exceeded", robot.name())
            os.exit()
        end
        
        robot.swingUp()
        tries = tries+1
    end
end

local function moveDownBreak()
    if robot.detectDown() then
        robot.swingDown()
    end

    local tries = 0
    while not robot.down() do
        if tries > maxTries then
            print("Max tries exceeded (", maxTries, ")")
            tunnel.send("error", "Max tries exceeded", robot.name())
            os.exit()
        end
        
        robot.swingDown()
        tries = tries+1
    end
end

-- Placing functions
local function placeForwardBreak()
    if robot.detect() then
        robot.swing()
    end

    local tries = 0
    while not robot.place() do
        if tries > maxTries then
            print("Max tries exceeded (", maxTries, ")")
            tunnel.send("error", "Max tries exceeded", robot.name())
            os.exit()
        end
        
        robot.swing()
        tries = tries+1
    end
end

local function placeUpBreak()
    if robot.detectUp() then
        robot.swingUp()
    end

    local tries = 0
    while not robot.placeUp() do
        if tries > maxTries then
            print("Max tries exceeded (", maxTries, ")")
            tunnel.send("error", "Max tries exceeded", robot.name())
            os.exit()
        end
        
        robot.swingUp()
        tries = tries+1
    end
end

local function placeDownBreak()
    if robot.detectDown() then
        robot.swingDown()
    end

    local tries = 0
    while not robot.placeDown() do
        if tries > maxTries then
            print("Max tries exceeded (", maxTries, ")")
            tunnel.send("error", "Max tries exceeded", robot.name())
            os.exit()
        end
        
        robot.swingDown()
        tries = tries+1
    end
end

-- Breaking functions
local function breakForward()
    local tries = 0
    while not robot.detect() do
        robot.swing()
        tries = tries+1

        if tries > maxTries then
            print("Max tries exceeded (", maxTries, ")")
            tunnel.send("error", "Max tries exceeded", robot.name())
            os.exit()
        end
    end
end

local function breakUp()
    local tries = 0
    while not robot.detectUp() do
        robot.swingUp()
        tries = tries+1

        if tries > maxTries then
            print("Max tries exceeded (", maxTries, ")")
            tunnel.send("error", "Max tries exceeded", robot.name())
            os.exit()
        end
    end
end

local function breakDown()
    local tries = 0
    while not robot.detectDown() do
        robot.swingDown()
        tries = tries+1
        
        if tries > maxTries then
            print("Max tries exceeded (", maxTries, ")")
            tunnel.send("error", "Max tries exceeded", robot.name())
            os.exit()
        end
    end
end

-- Other stuff
local function trashItems()
    local slots = robot.inventorySize()

    for i = 1, slots do
        local item = invController.getStackInInternalSlot(i)
        if item and not item.empty then
            local trash = true
            for _, allowed in ipairs(allowedItems) do
                if item.name == allowed then
                    trash = false
                    break
                end
            end
            if trash then
                robot.select(i)
                robot.drop()
            end
        end
    end
end

local function holdItem(name)
    local slots = robot.inventorySize()

    for i = 1, slots do
        local item = invController.getStackInInternalSlot(i)
        if item and not item.empty and item.name == name then
            robot.select(i)
            return
        end
    end
    print("Can't not find item: ".. name)
    tunnel.send("error", "cant find item " .. name, robot.name())
    return false
end

local function move()
    moveUpBreak()
    trashItems()
    breakForward() --ENDER CHEST
    moveDownBreak()
    breakForward() -- QUARRY
    moveDownBreak()
    breakForward() -- HYPER CUBE
    moveUpBreak()
    trashItems()

    robot.turnRight()
    for _ = 1, 9 do
        moveForwardBreak()
    end

    robot.turnLeft()
    moveUpBreak()
    holdItem(ENDER_CHEST)
    placeForwardBreak()
    trashItems()
    moveDownBreak()
    holdItem(QUARRY)
    placeForwardBreak()
    moveDownBreak()
    holdItem(HYPER_CUBE)
    placeForwardBreak()
    trashItems()
    moveUpBreak()
end

while true do
    local id, _, _, _, _, message = event.pullMultiple("modem_message", "interrupted")
    if id == "interrupted" then
        print("Exiting...")
        break
    end

    if message == "ping" then
        tunnel.send("pong")
    elseif message == "move_quarry" then
        move()
        tunnel.send("move_success", robot.name())
    end
end
