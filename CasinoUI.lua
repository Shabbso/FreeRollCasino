-------------------------------------------------------------------------------
-- CasinoUI.lua
-- Provides a scrollable frame to list recent bet outcomes (CasinoRecords).
-------------------------------------------------------------------------------

-- Create a main frame
local CasinoUI = CreateFrame("Frame", "FreeRollCasinoUIFrame", UIParent, "BasicFrameTemplateWithInset")
CasinoUI:SetSize(400, 300)
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
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 15)

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

-- Slash Command to toggle
SLASH_CASINOUI1 = "/casinoui"
SlashCmdList["CASINOUI"] = function()
    if FreeRollCasinoUIFrame:IsShown() then
        FreeRollCasinoUIFrame:Hide()
    else
        FreeRollCasinoUIFrame:Show()
        FreeRollCasinoUIFrame.Refresh()
    end
end