require('Mods/UnpackBags/TimedActions/TAUnpackBag');
require('TimedActions/ISTimedActionQueue');

-- ------------------------------------------------
-- Local variables
-- ------------------------------------------------

local menuEntryText = getText('UI_menu_entry');

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Shows a modal window that informs the player about something and only has
-- an okay button to be closed.
--
-- @param txt - The text to display on the modal.
-- @param centered - If set to true the modal will be centered (optional).
-- @param w - The width of the window (optional).
-- @param h - The height of the window (optional).
-- @param x - The x position of the modal (optional).
-- @param y - The y position of the modal (optional).
--
local function showOkModal(txt, centered, w, h, x, y)
    local x, y = x or 0, y or 0;
    local w, h = w or 230, h or 120;
    local core = getCore();

    -- center the modal if necessary
    if centered then
        x = core:getScreenWidth() * 0.5 - w * 0.5;
        y = core:getScreenHeight() * 0.5 - h * 0.5;
    end

    local modal = ISModalDialog:new(x, y, w, h, txt);
    modal:initialise();
    modal:addToUIManager();
end

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
-- Creates the timed action which empties the bag.
-- @param items - A table containing the clicked items / stack.
-- @param player - The player who clicked the menu.
-- @param itemsInContainer - The items contained in the bag.
-- @param bag - The bag to unpack.
--
local function onUnpackBag(items, player, itemsInContainer, bag)
    local bagWeight = bag:getInventory():getCapacityWeight();
    local container = bag:getContainer();
    local conWeight = bag:getContainer():getCapacityWeight();

    -- We check if the target container has enough free capacity to hold the items.
    if container:getCapacity() < (bagWeight + conWeight) then
        showOkModal("There is not enough space to unpack the bag here.", true);
        return;
    end

    ISTimedActionQueue.add(TAUnpackBag:new(player, itemsInContainer, bag, 50));
end

---
-- Creates the actual menu entry
-- @param item - The bag item.
-- @param itemsInContainer - A table containing all items in the bag.
-- @param itemTable - A table containing the clicked items / stack.
-- @param player - The player who clicked the menu.
-- @param context - The context menu to add a new option to.
--
local function createMenuEntry(item, itemsInContainer, itemTable, player, context)
    if instanceof(item, "InventoryItem") and instanceof(item, "InventoryContainer") then
        local itemsInContainer = convertArrayList(item:getInventory():getItems());
        if #itemsInContainer > 0 then
            context:addOption(string.format(menuEntryText, #itemsInContainer), itemTable, onUnpackBag, player, itemsInContainer, item);
        end
    end
end

---
-- Creates a context menu entry when the player selects
-- an inventory container (e.g. hiking bag).
-- @param player - The player who clicked the menu.
-- @param context - The context menu to add a new option to.
-- @param itemTable - A table containing the clicked items / stack.
--
local function createMenu(player, context, itemTable)
    local player = getSpecificPlayer(player);

    -- We iterate through the table of clicked items. We have
    -- to seperate between single items, stacks and expanded
    -- stacks.
    for i1 = 1, #itemTable do
        if type(itemTable[i1]) == "table" then
            -- We start to iterate at the second index to jump over the dummy
            -- item that is contained in the item-table.
            for i2 = 2, #itemTable[i1].items do

                local item = itemTable[i1].items[i2];
                createMenuEntry(item, itemsInContainer, itemTable, player, context);
            end
        else
            local item = itemTable[i1];
            createMenuEntry(item, itemsInContainer, itemTable, player, context);
        end
    end
end

-- ------------------------------------------------
-- Game Hooks
-- ------------------------------------------------

Events.OnPreFillInventoryObjectContextMenu.Add(createMenu);
