require'TimedActions/ISTimedActionQueue';

local function onKeyPressed(key)
    if key == getCore():getKey('RMDropBags') then
        local player = getPlayer();
        local item = player:getPrimaryHandItem()
            or player:getSecondaryHandItem()
            or player:getClothingItem_Back();

        if item and item:getCategory() == 'Container' then
            ISTimedActionQueue.add(TADropBags:new(getPlayer(), item));
        end
    end
end

Events.OnKeyPressed.Add(onKeyPressed);
