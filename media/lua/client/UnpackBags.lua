-- =============================================================================
-- Unpack Bags
-- by RoboMat
-- 
-- Created: 22.08.13 - 11:49
-- =============================================================================

local MOD_ID = "RMUnpackBags";
local MOD_NAME = "Unpack Bags";
local MOD_VERSION = "1.0.4";
local MOD_AUTHOR = "RoboMat";
local MOD_DESCRIPTION = "Allows the player to unpack a bag in his inventory.";
local MOD_URL = "http://theindiestone.com/forums/index.php/topic/1047-";

local isDebug = false;

-- ------------------------------------------------
-- Functions
-- ------------------------------------------------
---
-- Prints out the mod info on startup.
--
local function info()
	print("Mod Loaded: " .. MOD_NAME .. " by " .. MOD_AUTHOR .. " (v" .. MOD_VERSION .. ")");
end

---
-- Give player some containers for testing purposes.
--
local function debug(player)
	if isDebug then
		player:getInventory():AddItem("Base.Schoolbag");
		player:getInventory():AddItem("Base.Plasticbag");
	end
end

-- ------------------------------------------------
-- Game hooks
-- ------------------------------------------------
Events.OnGameBoot.Add(info);
Events.OnNewGame.Add(debug);