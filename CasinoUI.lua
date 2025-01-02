-------------------------------------------------------------------------------
-- CasinoUI.lua
-- A more user-friendly version:
--   1) Opens automatically on addon load.
--   2) Provides a welcome message.
--   3) Shows min/max bet info.
--   4) Slightly more "styled" layout.
-------------------------------------------------------------------------------

-- We'll assume FreeRollCasinoDB is already loaded with minBet and maxBet.
-- We also assume CasinoRecords is globally available.

local CasinoUI = CreateFrame("Frame", "FreeRollCasinoUIFrame", UIParent, "BackdropTemplate")

-- Increase the size for more space
CasinoUI:SetSize(500, 400)
CasinoUI:SetPoint("CENTER")
CasinoUI:EnableMouse(true)
CasinoUI:SetMovable(true)
CasinoUI:RegisterForDrag("LeftButton")
CasinoUI:SetScript("OnDragStart", function(self) self:StartMoving() end)
CasinoUI:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
-- Instead of :Hide(), we'll keep it open by default:
-- If you prefer to show/hide on load, set it to Hide() and manually call :Show().
CasinoUI:Show()

-- Slightly "prettier" backdrop
CasinoUI:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
CasinoUI:SetBackdropColor(0,0,0,0.8)

-- Title
local title = CasinoUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -12)
title:SetText("|cff00ff00Free Roll Casino|r")

-- Introduction text
local introText = CasinoUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
introText:SetPoint("TOPLEFT", 15, -50)
introText:SetJustifyH("LEFT")
introText:SetWidth(470) -- so text wraps nicely
introText:SetText(
    "Welcome to the Free Roll Casino!\n\n" ..
    "How to use:\n" ..
    "1) Trade your gold bet to the host.\n" ..
    "2) The host will switch to the desired game mode.\n" ..
    "3) Follow the instructions for rolling, using the Troll Dice toy, or playing Blackjack!\n\n" ..
    "Check out the logs below to see recent outcomes."
)

-- Show min/max bet info
local betInfoText = CasinoUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
betInfoText:SetPoint("TOPLEFT", introText, "BOTTOMLEFT", 0, -20)
betInfoText:SetJustifyH("LEFT")
betInfoText:SetTextColor(1, 0.8, 0)  -- slightly golden color

local function UpdateBetInfo()
    local minB = FreeRollCasinoDB and FreeRollCasinoDB.minBet or 5
    local maxB = FreeRollCasinoDB and FreeRollCasinoDB.maxBet or 5000
    betInfoText:SetText(string.format("Current Bet Range: %dg – %dg", minB, maxB))
end

UpdateBetInfo()  -- call once on load

-- We'll add a simple refresh button to re-check min/max if changed
local refreshBetButton = CreateFrame("Button", nil, CasinoUI, "UIPanelButtonTemplate")
refreshBetButton:SetSize(80, 22)
refreshBetButton:SetPoint("LEFT", betInfoText, "LEFT", 0, -30)
refreshBetButton:SetText("Refresh Bet")
refreshBetButton:SetScript("OnClick", function()
    UpdateBetInfo()
end)

-------------------------------------------------------------------------------
-- Scrollable Logs
-------------------------------------------------------------------------------
local logsFrame = CreateFrame("Frame", nil, CasinoUI, "BackdropTemplate")
logsFrame:SetSize(470, 120)
logsFrame:SetPoint("TOPLEFT", betInfoText, "BOTTOMLEFT", 0, -70)

logsFrame:SetBackdrop({
    bgFile   = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false, tileSize = 0, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
logsFrame:SetBackdropColor(0.1,0.1,0.1,0.8)

local scrollFrame = CreateFrame("ScrollFrame", "FreeRollCasinoScrollFrame", logsFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 5, -5)
scrollFrame:SetPoint("BOTTOMRIGHT", -26, 5)

local scrollChild = CreateFrame("Frame")
scrollChild:SetSize(1, 1)
scrollFrame:SetScrollChild(scrollChild)

local dataText = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
dataText:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
dataText:SetWidth(435)  -- about the width of logsFrame minus scrollbar
dataText:SetJustifyH("LEFT")
dataText:SetJustifyV("TOP")
dataText:SetText("No records yet.")

local function RefreshUI()
    if not CasinoRecords or #CasinoRecords == 0 then
        dataText:SetText("No records yet.")
    else
        local lines = {}
        for i, record in ipairs(CasinoRecords) do
            table.insert(lines, string.format(
                "[%s] %s (bet=%d) roll=%d => %s (net=%+d)",
                record.time or "?",
                record.player or "?",
                record.bet or 0,
                record.roll or 0,
                record.outcome or "??",
                record.netGain or 0
            ))
        end
        dataText:SetText(table.concat(lines, "\n"))
    end

    -- Adjust height so scrollbar is correct
    local textHeight = dataText:GetStringHeight()
    scrollChild:SetHeight(textHeight)
end

CasinoUI.Refresh = RefreshUI

-------------------------------------------------------------------------------
-- Buttons to Switch Game Modes (Optional)
-------------------------------------------------------------------------------
local modeFrame = CreateFrame("Frame", nil, CasinoUI, "BackdropTemplate")
modeFrame:SetSize(470, 40)
modeFrame:SetPoint("TOPLEFT", logsFrame, "BOTTOMLEFT", 0, -10)

modeFrame:SetBackdrop({
    bgFile   = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false, tileSize = 0, edgeSize = 14,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
modeFrame:SetBackdropColor(0.2,0.2,0.2,0.7)

local freeRollButton = CreateFrame("Button", nil, modeFrame, "UIPanelButtonTemplate")
freeRollButton:SetSize(90, 22)
freeRollButton:SetPoint("LEFT", modeFrame, "LEFT", 5, 0)
freeRollButton:SetText("Free Roll")
freeRollButton:SetScript("OnClick", function()
    SlashCmdList["CASINOMODE"]("freeroll")
end)

local trollDiceButton = CreateFrame("Button", nil, modeFrame, "UIPanelButtonTemplate")
trollDiceButton:SetSize(90, 22)
trollDiceButton:SetPoint("LEFT", freeRollButton, "RIGHT", 10, 0)
trollDiceButton:SetText("Troll Dice")
trollDiceButton:SetScript("OnClick", function()
    SlashCmdList["CASINOMODE"]("troll")
end)

local blackjackButton = CreateFrame("Button", nil, modeFrame, "UIPanelButtonTemplate")
blackjackButton:SetSize(90, 22)
blackjackButton:SetPoint("LEFT", trollDiceButton, "RIGHT", 10, 0)
blackjackButton:SetText("Blackjack")
blackjackButton:SetScript("OnClick", function()
    SlashCmdList["CASINOMODE"]("blackjack")
end)

local closeButton = CreateFrame("Button", nil, modeFrame, "UIPanelButtonTemplate")
closeButton:SetSize(60, 22)
closeButton:SetPoint("RIGHT", modeFrame, "RIGHT", -5, 0)
closeButton:SetText("Close")
closeButton:SetScript("OnClick", function()
    CasinoUI:Hide()
end)

-------------------------------------------------------------------------------
-- Auto-Open on Load
-------------------------------------------------------------------------------
-- We'll do this by hooking ADDON_LOADED or a small timer if needed.
local openFrame = CreateFrame("Frame")
openFrame:RegisterEvent("PLAYER_LOGIN")
openFrame:SetScript("OnEvent", function(self, event)
    -- Show the UI and refresh
    CasinoUI:Show()
    CasinoUI.Refresh()
    UpdateBetInfo()
end)

-- Optionally, if you also want a slash command for toggling
SLASH_CASINOUI1 = "/casinoui"
SlashCmdList["CASINOUI"] = function()
    if CasinoUI:IsShown() then
        CasinoUI:Hide()
    else
        CasinoUI:Show()
        CasinoUI.Refresh()
        UpdateBetInfo()
    end
end