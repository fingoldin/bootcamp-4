gui = {}

function love.load()
    gridX = 40
    gridY = 25
    max_snake_pos_x = 0;

    gridXCount = gridX;
    gridYCount = gridY;
    score = 0
    max_score = 0
    foodColors = {{1, 0, 0}, {0, 1, 0}, {0, 0, 1}}
    foodValues = {1, 2, 3}
    foodType = 1
    toadd = 0
    base_speed = 0.1
    speed = base_speed

    love.window.setMode(40 * 15, 30 * 15);
    love.window.setTitle("Better Snake");

    cellSize = 15;

        snakeSegments = {
            {x = 3, y = 4},
            {x = 2, y = 4},
            {x = 1, y = 4},
        }

        function moveFood()
    local possibleFoodPositions = {}

        for foodX = 1, gridXCount do
            for foodY = 1, gridYCount do
                local possible = true;

                for segmentIndex, segment in ipairs(snakeSegments) do
                    if foodX == segment.x and foodY == segment.y then
                        possible = false;
                    end

                    -- this just makes sure the food random change is on the board and to make sure it doesn't spawn in the snake.

                    if (foodY < 4 or foodY > (30 * 15) - 45) then
                      possible = false;
                      end
                end

                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})
                end
            end
        end

        foodPosition = possibleFoodPositions[love.math.random(1, #possibleFoodPositions)]
        foodType = love.math.random(1, #foodColors)
    end

    moveFood();

    function updateBest()
        if score > max_score then
          max_score = score
        end
    end

    function updateSpeed()
        speed = base_speed * math.pow(0.9, score)
    end

    function reset()

        gridXCount = gridX;
        gridYCount = gridY;

        snakeSegments = {
            {x = 3, y = 4},
            {x = 2, y = 4},
            {x = 1, y = 4},
        }

        directionQueue = {'right'} -- the starting movement is right.
        snakeAlive = true;
        timer = 0;
        gui.timer = 0;
        gameTimer = 0;
        updateBest();
        score = 0;

        moveFood();
    end

    reset();
end

function love.update(dt)
    timer = timer + dt;

    gameTimer = gameTimer + dt;

    if snakeAlive then
         if (gameTimer >= 1) then
           gui.timer = gui.timer + 1;
           gameTimer = 0;
           end

        local timerLimit = speed; -- snake speed
        if timer >= timerLimit then
            timer = timer - timerLimit;

            if #directionQueue > 1 then
                table.remove(directionQueue, 1);
            end

            local nextXPosition = snakeSegments[1].x;
            local nextYPosition = snakeSegments[1].y;

            if directionQueue[1] == 'right' then
                nextXPosition = nextXPosition + 1;
                if nextXPosition > gridXCount then
                    table.remove(snakeSegments);
                    snakeAlive = false;
                end

            elseif directionQueue[1] == 'left' then
                nextXPosition = nextXPosition - 1;
                if nextXPosition < 1 then
                    table.remove(snakeSegments);
                    snakeAlive = false;
                end

                -- all this stuff is collision

            elseif directionQueue[1] == 'down' then
                nextYPosition = nextYPosition + 1;
                if nextYPosition > (gridYCount + 3) then
                    table.remove(snakeSegments);
                    snakeAlive = false;
                end

            elseif directionQueue[1] == 'up' then
                nextYPosition = nextYPosition - 1;
                if nextYPosition < 4 then
                    table.remove(snakeSegments);
                    snakeAlive = false;
                end
            end

            local canMove = true;

            for segmentIndex, segment in ipairs(snakeSegments) do
                if segmentIndex ~= #snakeSegments
                and nextXPosition == segment.x
                and nextYPosition == segment.y then -- this stops the player going back on itself
                    canMove = false;
                end
            end

            if canMove then
                table.insert(snakeSegments, 1, {x = nextXPosition, y = nextYPosition})

                if snakeSegments[1].x == foodPosition.x
                and snakeSegments[1].y == foodPosition.y then
                    score = score + foodValues[foodType]
                    updateBest();
                    moveFood();
                    updateSpeed();
                    toadd = toadd + foodValues[foodType]
                end

                if toadd > 0 then
                    toadd = toadd - 1
                else
                    table.remove(snakeSegments);
                end
            else
                snakeAlive = false;
            end
        end
    elseif timer >= 1.5 then
        reset(); -- when the snake dies, the timer stops. if the timer has stopped for 1.5 seconds, restart the game.
    end
    if love.math.random() > 0.95 then
        max_snake_pos_x = 0;
        for segmentIndex, segment in ipairs(snakeSegments) do
            if max_snake_pos_x < segment.x then
                max_snake_pos_x = segment.x;
            end
        end
        if gridXCount > max_snake_pos_x + 3 and gridXCount > 10 then
            if love.math.random() >= 0.2 then
                gridXCount = gridXCount - 1;
            else
                gridXCount = gridXCount + 1;
            end
        elseif gridXCount < gridX and love.math.random() > 0.9 then
            gridXCount = gridXCount + 1;
        end
    end
end

function createGameWindow()
  love.graphics.setColor(28/255, 28/255, 28/255);
  love.graphics.rectangle('fill', 0, 45, gridXCount * cellSize , (gridYCount * cellSize)); -- The Game Window
  end

function love.draw()
    local cellSize = 15;

    createGameWindow();

    local function drawCell(x, y)
        love.graphics.rectangle('fill', (x - 1) * cellSize, (y - 1) * cellSize, cellSize - 1, cellSize - 1); -- draw entity function
    end

    for segmentIndex, segment in ipairs(snakeSegments) do
        if snakeAlive then
            love.graphics.setColor(173/255, 255/255, 47/255); -- snake colour
        else
            love.graphics.setColor(70/255, 70/255, 70/255); -- dead snake colour
        end
        drawCell(segment.x, segment.y); -- draw snake
    end

    love.graphics.setColor(foodColors[foodType][1], foodColors[foodType][2], foodColors[foodType][3]); -- food colour
    drawCell(foodPosition.x, foodPosition.y);

    drawGUI();
end

function love.keypressed(key)
    if (key == "right" or key == "d")
    and directionQueue[#directionQueue] ~= 'right'
    and directionQueue[#directionQueue] ~= 'left' then
        table.insert(directionQueue, 'right')

    elseif (key == "left" or key == "a")
    and directionQueue[#directionQueue] ~= 'left'
    and directionQueue[#directionQueue] ~= 'right' then
        table.insert(directionQueue, 'left')

   -- This is handling key presses.

    elseif (key == "up" or key == "w")
    and directionQueue[#directionQueue] ~= 'up'
    and directionQueue[#directionQueue] ~= 'down' then
        table.insert(directionQueue, 'up')

    elseif (key == "down" or key == "s")
    and directionQueue[#directionQueue] ~= 'down'
    and directionQueue[#directionQueue] ~= 'up' then
        table.insert(directionQueue, 'down')
    end
end

function drawGUI()

  love.graphics.setColor(1, 1, 1);
  font = love.graphics.newFont(28);
  love.graphics.setFont(font);
  love.graphics.print("- SNAKE -", 235, 5);

  font = love.graphics.newFont(15); -- font size+
  love.graphics.setFont(font);

  love.graphics.print("Score: " .. tostring(score), 50, 425);
  love.graphics.print("Timer: " .. tostring(0), 270, 425);
  love.graphics.print("Best Score: " .. tostring(max_score), 450, 425);

  end
