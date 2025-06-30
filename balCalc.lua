
function pythagoras(x, y)
    return math.sqrt(math.pow(x, 2)+ math.pow(y, 2))
end



function calculatePitch(vel, distance, deltaHeight, tolorance)
    local gravity = 0.05
    local formDrag = 0.01

    local correctionCoefficient = 0.01
    local angle = 90

    local maxChecks = 100
    local maxTicks = 4000
      
    local velocity = vel


    

    function calculateLoss(simulationAngle)


        --position = {0, -deltaHeight}
        position = {cannonBarrelLength*math.cos(simulationAngle*math.pi/180), cannonBarrelLength*math.sin(simulationAngle*math.pi/180)-deltaHeight}
        shellVectors = {velocity*math.cos(simulationAngle*math.pi/180), velocity*math.sin(simulationAngle*math.pi/180)}
        shellForce = {0, 0}

        distanceFromTarget = pythagoras(position[1]-distance, position[2]-deltaHeight)
        

        closestDistance = distanceFromTarget
        time = 0

        for ticks = 1,maxTicks do
            
            shellForce[1] = shellVectors[1]/pythagoras(shellVectors[1], shellVectors[2])
            shellForce[2] = shellVectors[2]/pythagoras(shellVectors[1], shellVectors[2])


            drag = formDrag * pythagoras(shellVectors[1], shellVectors[2])

            shellForce[1] = -shellForce[1]*drag
            shellForce[2] = -shellForce[2]*drag
            shellForce[2] = shellForce[2]-gravity

            

            position[1] = position[1] + shellVectors[1] + shellForce[1]*0.5
            position[2] = position[2] + shellVectors[2] + shellForce[2]*0.5

            shellVectors[1] = shellVectors[1] + shellForce[1]
            shellVectors[2] = shellVectors[1] + shellForce[2]

            distanceFromTarget = pythagoras(position[1]-distance, position[2])

            if distanceFromTarget < closestDistance then
                closestDistance = distanceFromTarget
                time = ticks
            end

        end


        return closestDistance, time
    end


    local lossesAndAngles = {}
    loss, time =  calculateLoss(angle)
    table.insert(lossesAndAngles, 1, {angle, loss, time})

    angle = angle -10
    loss, time =  calculateLoss(angle)
    table.insert(lossesAndAngles, 1, {angle, loss, time})




    for i=1,maxChecks do
        if lossesAndAngles[2][2]>lossesAndAngles[1][2] then
            angle = angle-math.max(lossesAndAngles[1][2]*correctionCoefficient, 0.01)
        else
            angle = angle+math.max(lossesAndAngles[1][2]*correctionCoefficient, 0.01)
        end
        
        loss, time =  calculateLoss(angle)
        table.insert(lossesAndAngles, 1, {angle, loss, time})

        
    end    
        
     
    return angle, lossesAndAngles[1][2], lossesAndAngles[1][3]

end

function calculateYaw(deltaX, deltaZ)


    local angle = -math.atan2(deltaX, deltaZ)*180/math.pi

    if angle>360 then
        angle=angle-360
    elseif angle<0 then
        angle=angle+360
    end

    return angle
end


function main()

    posX, posY, posZ = gps.locate()

    term.clear()
    term.setCursorPos(1, 1)
    print("current position")
    print("x: "..posX)
    print("y: "..posY)
    print("z: "..posZ)
    print("")
    print("-------------")
    print("give coords:")
    coords = {}
    answer = io.read()
    print("-------------")
    for coord in string.gmatch(answer, "[^%s]+") do
        table.insert(coords, coord)
    end

    xDest = tonumber(coords[1])
    yDest = tonumber(coords[2])
    zDest = tonumber(coords[3])

    velocity = 5
    cannonBarrelLength = 1

    deltaX = xDest-posX
    deltaY = yDest-posY
    deltaZ = zDest-posZ

    

    pitch, loss, time = calculatePitch(velocity, pythagoras(deltaX, deltaZ), deltaY, 3)
    yaw = calculateYaw(deltaX, deltaZ)

    if loss>20 then
        print("out of range")
    else

        print("aprox time: "..math.floor(time/140+0.5).."s")
        print("")
        print("pitch: "..math.floor(pitch+0.5).." degrees")
        print("yaw: "..math.floor(yaw+0.5).." degrees")
    end

end


main()
