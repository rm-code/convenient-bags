require('TimedActions/TAUnpackBag');
require('TimedActions/ISTimedActionQueue');
require('TimedActions/ISInventoryTransferAction');
require('UI/UITagModal');
require('luautils');

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MENU_ENTRY_TEXT_ONE = getText('UI_menu_entry_one');
local MENU_ENTRY_TEXT_MUL = getText('UI_menu_entry_multi');
local MENU_ENTRY_PACKING  = getText('UI_menu_entry_packing');
local MENU_ENTRY_TAGGING  = getText('UI_menu_entry_tagging');
local MODAL_WARNING_TEXT  = getText('UI_warning_modal');

-- The factors for calculating the timed action durations for both
-- the normal and the partial unpacking.
local DURATION_DEFAULT_FACTOR = 2.5;
local DURATION_PARTIAL_FACTOR = 3.5;

local TAG_DELETION_IDENTIFIER = '!';

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Converts a java arrayList to a lua table.
--
-- @param arrayList - The arrayList to convert.
--
local function convertArrayList(arrayList)
    local itemTable = {};

    for i = 1, arrayList:size() do
        itemTable[i] = arrayList:get(i - 1);
    end

    return itemTable;
end

---
-- Creates a list of all tags associated with a bag. If the bag doesn't have
-- any tags it will return "Tags: none".
-- @param bag - The bag to create the list for.
--
local function createTagList(bag)
    local tags = 'Tags: '
    local modData = bag:getModData();
    if modData.rmcbtags then
        local counter = 0;
        for i, v in pairs(modData.rmcbtags) do
            tags = tags .. i .. ', ';
            counter = counter + 1;
        end
        -- Cut off the last comma and whitespace.
        tags = tags:sub(1, tags:len() - 2);

        if counter == 0 then
            tags = 'Tags: none';
        end
    else
        tags = 'Tags: none';
    end
    return tags;
end

---
-- This function adds or deletes a tag of a bag.
-- @param bag - The bag which needs to be tagged.
-- @param button - The button of the TextBox.
-- @param player - The player who clicked the TextBox.
--
local function storeNewTag(bag, button, player)
    if button.internal == 'ADD' then
        local tag = button.parent.entry:getText();
        if tag and tag ~= '' then
            -- Initialise new tag table or load the saved one.
            local modData = bag:getModData();
            modData.rmcbtags = modData.rmcbtags or {};

            -- Add tag.
            modData.rmcbtags[tag] = true;
        end
    elseif button.internal == 'REMOVE' then
        local tag = button.parent.entry:getText();
        if tag and tag ~= '' then
            -- Initialise new tag table or load the saved one.
            local modData = bag:getModData();
            modData.rmcbtags = modData.rmcbtags or {};

            -- Cycle through all tag-entries and remove the tag if it can be found.
            -- The case will be ignored when trying to delete a tag.
            for i, _ in pairs(modData.rmcbtags) do
                if i:lower() == tag:lower() then
                    modData.rmcbtags[i] = nil;
                end
            end
        end
    end
end

---
-- Creates a TextBox which allows the player to enter a new tag.
-- The TextBox will display a list of already existing tags.
-- @param items - All items in the inventory.
-- @param player - The player who clicked the menu.
-- @param playerIndex - The player's index.
-- @param bag - The bag to tag.
--
local function onAddTag(items, player, playerIndex, bag)
    local modal = UITagModal:new(0, 0, 280, 180, createTagList(bag), bag, storeNewTag, playerIndex);
    modal.backgroundColor.r =   0;
    modal.backgroundColor.g =   0;
    modal.backgroundColor.b =   0;
    modal.backgroundColor.a = 0.9;
    modal:initialise();
    modal:addToUIManager();
end

---
-- Creates the timed action which empties the bag.
-- @param items - A table containing the clicked items / stack.
-- @param player - The player who clicked the menu.
-- @param itemsInBag - The items contained in the bag.
-- @param bag - The bag to unpack.
--
local function onUnpackBag(items, player, itemsInBag, bag)
    local container = bag:getContainer();

    -- Display a warning and abort the unpacking if the next item in the bag doesn't fit into the container.
    if container:getMaxWeight() < itemsInBag[1]:getActualWeight() + container:getCapacityWeight() then
        luautils.okModal(MODAL_WARNING_TEXT, true);
        return;
    end

    -- Partially unpacking a bag will have a longer timed action to represent how the player is emptying the bag
    -- more carefully. The duration of the TimedAction also depends on the amount of items in the bag.
    local traitModifier = 0;
    if player:HasTrait("Dextrous") then
        traitModifier = -0.8;
    elseif player:HasTrait("AllThumbs") then
        traitModifier = 0.8;
    end
    local duration;
    if container:getMaxWeight() < (bag:getInventory():getCapacityWeight() + container:getCapacityWeight()) then
        duration = #itemsInBag * (DURATION_PARTIAL_FACTOR + traitModifier);
    else
        duration = #itemsInBag * (DURATION_DEFAULT_FACTOR + traitModifier);
    end
    ISTimedActionQueue.add(TAUnpackBag:new(player, itemsInBag, bag, duration));
end

---
-- Creates the timed action which empties the bag.
-- @param items - A table containing the clicked items / stack.
-- @param player - The player who clicked the menu.
-- @param itemsInContainer - The items contained in the bag.
-- @param bag - The bag to unpack.
--
local function onPackBag(items, player, itemsInContainer, bag)
    for i = 1, #itemsInContainer do
        local item = itemsInContainer[i];
        if instanceof(item, 'InventoryItem') and not instanceof(item, 'InventoryContainer') and not player:isEquipped(item) then

            local modData = bag:getModData();
            local counter = 0;
            if modData.rmcbtags then
                for tag, _ in pairs(modData.rmcbtags) do
                    counter = counter + 1;

                    -- Check for custom (modded) categories or use the default categories.
                    local category = item:getDisplayCategory();
                    if not category then
                        category = item:getCategory(); -- Default.
                    end

                    if category:lower() == tag:lower() or item:getName():lower():find(tag:lower()) then
                        ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, bag:getContainer(), bag:getInventory()));
                    end
                end
            end
            if counter == 0 then
                ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, bag:getContainer(), bag:getInventory()));
            end
        end
    end
end

---
-- Creates the actual menu entry
-- @param item - The bag item.
-- @param itemTable - A table containing the clicked items / stack.
-- @param player - The player who clicked the menu.
-- @param playerIndex - The index of the player who clicked the menu.
-- @param context - The context menu to add a new option to.
-- @paran func - The function to execute when the menu is clicked.
--
local function createMenuEntry(item, itemTable, player, playerIndex, context)
    if instanceof(item, 'InventoryItem') and instanceof(item, 'InventoryContainer') then
        local itemsInBag = convertArrayList(item:getInventory():getItems());
        if #itemsInBag == 1 then
            context:addOption(MENU_ENTRY_TEXT_ONE, itemTable, onUnpackBag, player, itemsInBag, item);
        elseif #itemsInBag > 1 then
            context:addOption(string.format(MENU_ENTRY_TEXT_MUL, #itemsInBag), itemTable, onUnpackBag, player, itemsInBag, item);
        end

        local itemsInContainer = convertArrayList(item:getContainer():getItems());
        context:addOption(MENU_ENTRY_PACKING, itemTable, onPackBag, player, itemsInContainer, item);

        -- Add option to add tags to a bag for automatic item sorting.
        context:addOption(MENU_ENTRY_TAGGING, itemTable, onAddTag, player, playerIndex, item);
    end
end

---
-- Creates a context menu entry when the player selects
-- an inventory container (e.g. hiking bag).
-- @param player - The player who clicked the menu.
-- @param context - The context menu to add a new option to.
-- @param itemTable - A table containing the clicked items / stack.
--
local function createInventoryMenu(playerIndex, context, itemTable)
    local player = getSpecificPlayer(playerIndex);

    -- We iterate through the table of clicked items. We have
    -- to seperate between single items, stacks and expanded
    -- stacks.
    for i1 = 1, #itemTable do
        local item = itemTable[i1];
        if type(item) == 'table' then
            -- We start to iterate at the second index to jump over the dummy
            -- item that is contained in the item-table.
            for i2 = 2, #item.items do
                createMenuEntry(item.items[i2], itemTable, player, playerIndex, context);
            end
        else
            createMenuEntry(item, itemTable, player, playerIndex, context);
        end
    end
end

---
-- Creates a world context menu when the player selects and item on the floor.
-- @param player - The player who opened the menu.
-- @param context - The menu to add a new option to.
-- @param worldobjects - A table containing the world objects on the tile.
--
local function createWorldContextMenu(player, context, worldobjects)
    local player = getSpecificPlayer(player);

    for _, object in ipairs(worldobjects) do
        if instanceof(object, 'IsoWorldInventoryObject') then
            createUnpackingMenuEntry(object:getItem(), worldobjects, player, context, onUnpackBag);
        end
    end
end

-- ------------------------------------------------
-- Game Hooks
-- ------------------------------------------------

Events.OnPreFillInventoryObjectContextMenu.Add(createInventoryMenu);
Events.OnFillWorldObjectContextMenu.Add(createWorldContextMenu);
