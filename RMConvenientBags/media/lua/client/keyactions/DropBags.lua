require'TimedActions/ISTimedActionQueue';

function getBagToDrop(player)
    local item = player:getPrimaryHandItem();
    if item and item:getCategory() == 'Container' then
        return item;
    end
    item = player:getSecondaryHandItem();
    if item and item:getCategory() == 'Container' then
        return item;
    end
    item = player:getClothingItem_Back();
    if item and item:getCategory() == 'Container' then
        return item;
    end
end

local function onKeyPressed(key)
    if key == getCore():getKey('RMDropBags') then
        local player = getPlayer();
        local itemToDrop = getBagToDrop(player);
        if itemToDrop then
            ISTimedActionQueue.add(TADropBags:new(player, itemToDrop));
        end
    end
end

Events.OnKeyPressed.Add(onKeyPressed);
