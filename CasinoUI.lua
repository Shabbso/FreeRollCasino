-------------------------------------------------------------------------------
-- CasinoUI.lua
-- Provides a scrollable frame to list recent bet outcomes (CasinoRecords),
-- plus three new buttons to switch game modes: Free Roll, Troll Dice, Blackjack.
-------------------------------------------------------------------------------

-- Create a main frame
local CasinoUI = CreateFrame("Frame", "FreeRollCasinoUIFrame", UIParent, "BasicFrameTemplateWithInset")
CasinoUI:SetSize(400, 340)  -- Increased height a bit to fit buttons
CasinoUI:SetPoint("CENTER")
CasinoUI:EnableMouse(true)
CasinoUI:SetMovable(true)
CasinoUI:RegisterForDrag("LeftButton")
CasinoUI:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
CasinoUI:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
CasinoUI:Hide()  -- Hidden by default

-- Title text
CasinoUI.title = CasinoUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
CasinoUI.title:SetPoint("TOP", 0, -10)
CasinoUI.title:SetText("Free Roll Casino Records")

-- ScrollFrame
local scrollFrame = CreateFrame("ScrollFrame", "FreeRollCasinoScrollFrame", CasinoUI, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 15, -40)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 55)  
-- Note: We leave some extra space at the bottom for the new buttons

local scrollChild = CreateFrame("Frame")
scrollChild:SetSize(1, 1)
scrollFrame:SetScrollChild(scrollChild)

-- FontString to show data
local dataText = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
dataText:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
dataText:SetJustifyH("LEFT")
dataText:SetJustifyV("TOP")
dataText:SetText("No records yet.")

-- Function to refresh text from CasinoRecords
local function RefreshUI()
    if not CasinoRecords or #CasinoRecords == 0 then
        dataText:SetText("No records yet.")
    else
        local lines = {}
        for i, record in ipairs(CasinoRecords) do
            -- Format example: [12:34:56] Player(bet=XX) roll=YY => outcome (net=ZZ)
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

    -- Adjust scrollChild height so the scrollbar works
    local textHeight = dataText:GetStringHeight()
    scrollChild:SetHeight(textHeight)
end

CasinoUI.Refresh = RefreshUI  -- Expose for outside calls

------------------------------------------------------------------------------
-- 3 New Buttons to Switch Game Modes
-- We'll call the same internal function that the slash command uses:
-- SlashCmdList["CASINOMODE"]("<mode>")
------------------------------------------------------------------------------

-- 1) Free Roll Button
local freeRollButton = CreateFrame("Button", nil, CasinoUI, "UIPanelButtonTemplate")
freeRollButton:SetSize(90, 22)
freeRollButton:SetPoint("BOTTOMLEFT", 15, 15)
freeRollButton:SetText("Free Roll")
freeRollButton:SetScript("OnClick", function()
    -- This calls the same logic as typing /casinomode freeroll
    SlashCmdList["CASINOMODE"]("freeroll")
end)

-- 2) Troll Dice Button
local trollDiceButton = CreateFrame("Button", nil, CasinoUI, "UIPanelButtonTemplate")
trollDiceButton:SetSize(90, 22)
trollDiceButton:SetPoint("LEFT", freeRollButton, "RIGHT", 10, 0)
trollDiceButton:SetText("Troll Dice")
trollDiceButton:SetScript("OnClick", function()
    SlashCmdList["CASINOMODE"]("troll")
end)

-- 3) Blackjack Button
local blackjackButton = CreateFrame("Button", nil, CasinoUI, "UIPanelButtonTemplate")
blackjackButton:SetSize(90, 22)
blackjackButton:SetPoint("LEFT", trollDiceButton, "RIGHT", 10, 0)
blackjackButton:SetText("Blackjack")
blackjackButton:SetScript("OnClick", function()
    SlashCmdList["CASINOMODE"]("blackjack")
end)

-- Slash Command to toggle the Casino UI
SLASH_CASINOUI1 = "/casinoui"
SlashCmdList["CASINOUI"] = function()
    if FreeRollCasinoUIFrame:IsShown() then
        FreeRollCasinoUIFrame:Hide()
    else
        FreeRollCasinoUIFrame:Show()
        FreeRollCasinoUIFrame.Refresh()
    end
end