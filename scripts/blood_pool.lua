--[[
    Script to add blood pools/splatter under tokens on actor death.					
]]--

function addBloodPool(tokenCT)
    -- Debug.chat('blood pool called', tokenCT)

    local randomImage = math.random(10); -- return 1-10    
    local bloodPoolName = 'blood_pool_' .. randomImage;

    -- as token
    local tokenWidth, tokenHeight = tokenCT.getImageSize();
    local tokenImageScale = tokenCT.getScale();

    -- get image window container and add token underneath actor token
    ctrlImage, windowInstance, bWindowOpened = ImageManager.getImageControl(tokenCT, false);
    -- Debug.chat('window container', ctrlImage, windowInstance, bWindowOpened)

    local tokenContainer = tokenCT.getContainerNode();
    local tokenX, tokenY = tokenCT.getPosition();
    -- local imageControl = tokenContainer;
    if (ctrlImage == nil) then
        return;
    end

    local bloodToken = ctrlImage.addToken(bloodPoolName, tokenX + 200, tokenY + 200);
    -- Debug.chat('bloodToken', bloodToken, bloodPoolName, ctrlImage, tokenX, tokenY)

    if bloodToken then
        -- randomize token size
        local sizeMultiplier = math.random() * 2 + 0.1;  -- math.random() returns number between 0 and 1
        local baseTokenSize = tokenWidth * tokenImageScale;
        -- bloodToken.setSize(baseTokenSize * sizeMultiplier, baseTokenSize * sizeMultiplier);

        local size = resizeForOriginalTokenSize(tokenCT);
        bloodToken.setSize(tokenWidth * tokenImageScale, tokenHeight * tokenImageScale);

        -- randomize token orientation
        local rotation = math.random(360); -- math.random(360) returns a number between 1 and 360    
        bloodToken.setOrientation(rotation);
    end

    -- as widget
    local bloodPool = tokenCT.addBitmapWidget(bloodPoolName);
    bloodPool.setName("blood_pool");	
    bloodPool.setPosition("center");
    bloodPool.sendToBack();
    local randomScaling = math.random() + 1;  -- math.random() returns number between 0 and 1
    Helper.resizeForTokenSize(tokenCT, bloodPool, randomScaling);
    local rotation = math.random(360); -- math.random(360) returns a number between 1 and 360   
    --image.rotate(rotation);
    bloodPool.setVisible(true);
end