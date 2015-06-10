-- =============================================================================
-- Unpack Bags
-- by RoboMat
-- 
-- Created: 22.08.13 - 12:00
-- =============================================================================

require'Mods/UnpackBags/TimedActions/TAUnpackBag';
require'TimedActions/ISTimedActionQueue';

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Shows a modal window that informs the player about something and only has
-- an okay button to be closed.
--
-- @param _text - The text to display on the modal
-- @param _centered - If set to true the modal will be centered (optional)
-- @param _width - The width of the window (optional)
-- @param _height - The height of the window (optional)
--
-- @author RoboMat (updated by rmcode)
--
local function showOkModal(_text, _centered, _width, _height, _posX, _posY)
	local posX = _posX or 0;
	local posY = _posY or 0;
	local width = _width or 230;
	local height = _height or 120;
	local centered = _centered;
	local txt = _text;
	local core = getCore();

	-- center the modal if necessary
	if centered then
		posX = core:getScreenWidth() * 0.5 - width * 0.5;
		posY = core:getScreenHeight() * 0.5 - height * 0.5;
	end

	local modal = ISModalDialog:new(posX, posY, width, height, txt, false, nil, nil);
	modal:initialise();
	modal:addToUIManager();
end


---
-- Converts a java arrayList to a lua table. Remember
-- that lua tables start at index 1. Thanks to lemmy101.
--
-- @param _arrayList - The arrayList to convert
--
-- @author RoboMat (updated by rmcode)
--
local function convertArrayList(arrayList)
	local itemTable = {};

	for i = 0, arrayList:size() - 1 do
		itemTable[i] = arrayList:get(i);
	end

	return itemTable;
end

---
-- Creates the timed action which empties the bag.
-- @param _items - A table containing the clicked items / stack.
-- @param _player - The player who clicked the menu.
-- @param _itemsInContainer - The items contained in the bag.
-- @param _bag - The bag to unpack.
--
local function onUnpackBag(_items, _player, _itemsInContainer, _bag)
	local bag = _bag;
	local bagWeight = bag:getInventory():getCapacityWeight();
	local container = bag:getContainer();
	local conWeight = bag:getContainer():getCapacityWeight();

	-- We check if the target bag has enough free capacity to hold the items.
	if container:getCapacity() < (bagWeight + conWeight) then
		showOkModal("There is not enough space to unpack the bag here.", true);
		return;
	end

	ISTimedActionQueue.add(TAUnpackBag:new(_player, _itemsInContainer, bag, 50));
end

---
-- Creates a context menu entry when the player selects
-- an inventory container (e.g. hiking bag).
-- @param _player - The player who clicked the menu.
-- @param _context - The context menu to add a new option to.
-- @param _items - A table containing the clicked items / stack.
--
local function createMenu(_player, _context, _items)
	local itemTable = _items; -- The table containing the clicked items.
	local context = _context;
	local player = getSpecificPlayer(_player);

	-- We iterate through the table of clicked items. We have
	-- to seperate between single items, stacks and expanded
	-- stacks.
	for i1 = 1, #itemTable do

		local item = itemTable[i1];
		if instanceof(item, "InventoryItem") and instanceof(item, "InventoryContainer") then
			local bag = item; -- Store the clicked bag.
			local itemsInContainer = convertArrayList(bag:getInventory():getItems()); -- Get its contents.

			-- Only create a menu entry if the bag contains an item.
			if #itemsInContainer > 0 then
				context:addOption("Unpack (" .. #itemsInContainer .. " Items)", itemTable, onUnpackBag, player, itemsInContainer, bag);
			end

		elseif type(itemTable[i1]) == "table" then
			-- We start to iterate at the second index to jump over the dummy
			-- item that is contained in the item-table.
			for i2 = 2, #itemTable[i1].items do

				local item = itemTable[i1].items[i2];
				if instanceof(item, "InventoryItem") and instanceof(item, "InventoryContainer") then
					local bag = item;
					local itemsInContainer = convertArrayList(bag:getInventory():getItems());
					if #itemsInContainer > 0 then
						context:addOption("Unpack (" .. #itemsInContainer .. " Items)", itemTable, onUnpackBag, player, itemsInContainer, bag);
					end
				end
			end
		end
	end
end

-- ------------------------------------------------
-- Game Hooks
-- ------------------------------------------------

Events.OnPreFillInventoryObjectContextMenu.Add(createMenu);
