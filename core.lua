-- RiddleCompass - Optimized core.lua (no unknown riddle tracking, title-based)

local ADDON_NAME = ...
local RiddleCompass = {}
_G.RiddleCompass = RiddleCompass

-- SavedVariables
RiddleCompassDB = RiddleCompassDB or {}

--------------------------------------------------
-- Constants
--------------------------------------------------
local TARGET_QUEST_NAME = "Decor Treasure Hunt"

--------------------------------------------------
-- Default saved settings
--------------------------------------------------
local defaults = {
    enabled = true,
    autoWaypoint = true,
    debug = false,
}

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99RiddleCompass|r: " .. tostring(msg))
end

local function Debug(msg)
    if RiddleCompassDB.debug then
        Print("|cffffcc00DEBUG:|r " .. tostring(msg))
    end
end

local function MergeDefaults()
    for k, v in pairs(defaults) do
        if RiddleCompassDB[k] == nil then
            RiddleCompassDB[k] = v
        end
    end
end

--------------------------------------------------
-- Normalize text
--------------------------------------------------
local function NormalizeText(text)
    if not text or text == "" then return "" end
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text
end

--------------------------------------------------
-- Load correct riddle table
--------------------------------------------------
local function GetActiveRiddleTable()
    local faction = UnitFactionGroup("player")
    return (faction == "Alliance")
        and RiddleCompass_Riddles_Alliance
        or  RiddleCompass_Riddles_Horde
end

--------------------------------------------------
-- /way handler discovery
--------------------------------------------------
local WaySlashHandler

local function FindWayHandler()
    if WaySlashHandler ~= nil then
        return WaySlashHandler
    end

    for name, func in pairs(SlashCmdList) do
        local i = 1
        while true do
            local slash = _G["SLASH_" .. name .. i]
            if not slash then break end

            if slash:lower() == "/way" then
                WaySlashHandler = func
                Debug("Found /way handler: " .. name)
                return func
            end

            i = i + 1
        end
    end

    WaySlashHandler = false
    Debug("No /way handler found.")
    return false
end

--------------------------------------------------
-- Set waypoint
--------------------------------------------------
local function SetTreasureWaypoint(mapID, x, y)
    if not RiddleCompassDB.autoWaypoint then
        Debug("Auto waypoint disabled.")
        return
    end

    local handler = FindWayHandler()
    local msg = string.format("%.2f %.2f", x, y)

    if handler and type(handler) == "function" then
        Debug("Calling /way handler with: " .. msg)
        handler(msg)
        Print(string.format("Waypoint set at %.2f, %.2f", x, y))
    else
        Print("Could not find /way handler; opening chat input.")
        ChatFrame_OpenChat("/way " .. msg)
    end
end

--------------------------------------------------
-- Match riddle text
--------------------------------------------------
local function MatchRiddleText(text)
    local riddles = GetActiveRiddleTable()
    if not riddles then
        Debug("No riddle table found for faction.")
        return false
    end

    local normalized = NormalizeText(text)
    Debug("Normalized riddle: " .. normalized)

    -- Exact match
    local data = riddles[normalized]
    if data then
        Debug("Exact riddle match.")
        SetTreasureWaypoint(data.mapID, data.x, data.y)
        return true
    end

    -- Substring fallback
    for key, d in pairs(riddles) do
        if normalized:find(key, 1, true) then
            Debug("Substring riddle match found.")
            SetTreasureWaypoint(d.mapID, d.x, d.y)
            return true
        end
    end

    Debug("No matching riddle found (all known riddles should be in the table).")
    return false
end

--------------------------------------------------
-- Event handler
--------------------------------------------------
local frame = CreateFrame("Frame")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == ADDON_NAME then
            MergeDefaults()
            Debug("Addon Loaded.")
        end

    elseif event == "QUEST_DETAIL" then
        if not RiddleCompassDB.enabled then
            Debug("Addon disabled; ignoring QUEST_DETAIL.")
            return
        end

        -- On your client, questID from QUEST_DETAIL is 0, so we can't rely on it.
        -- Instead, filter by the quest title shown in the quest window.
        local title = QuestInfoTitleHeader and QuestInfoTitleHeader:GetText()
        Debug("QUEST_DETAIL fired. Title: " .. tostring(title or "nil"))

        if title ~= TARGET_QUEST_NAME then
            Debug("QUEST_DETAIL is for another quest; ignoring.")
            return
        end

        if QuestInfoDescriptionText then
            local text = QuestInfoDescriptionText:GetText()
            if text and text ~= "" then
                Debug("Captured riddle text.")
                MatchRiddleText(text)
            else
                Debug("QUEST_DETAIL had empty description text.")
            end
        end
    end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_DETAIL")

--------------------------------------------------
-- Slash commands
--------------------------------------------------
SLASH_RIDDLECOMPASS1 = "/riddlecompass"
SLASH_RIDDLECOMPASS2 = "/rc"

SlashCmdList["RIDDLECOMPASS"] = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")

    if msg == "toggle" then
        RiddleCompassDB.enabled = not RiddleCompassDB.enabled
        Print("Enabled: " .. tostring(RiddleCompassDB.enabled))

    elseif msg == "debug" then
        RiddleCompassDB.debug = not RiddleCompassDB.debug
        Print("Debug: " .. tostring(RiddleCompassDB.debug))

    else
        Print("Commands:")
        Print("/rc toggle  - enable/disable addon")
        Print("/rc debug   - toggle debug")
    end
end
