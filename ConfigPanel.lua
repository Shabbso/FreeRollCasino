-------------------------------------------------------------------------------
-- ConfigPanel.lua
-- Adds edit boxes for directly entering minBet/maxBet
-------------------------------------------------------------------------------

-- 1) Initialize saved variables (if not already in your code)
FreeRollCasinoDB = FreeRollCasinoDB or {}
if not FreeRollCasinoDB.minBet then
    FreeRollCasinoDB.minBet = 5
end
if not FreeRollCasinoDB.maxBet then
    FreeRollCasinoDB.maxBet = 5000
end

-- 2) Create the main panel
local panel = CreateFrame("Frame", "FreeRollCasinoConfigPanel", UIParent)
panel.name = "Free Roll Casino"  -- name in the AddOns list

-- Title
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Free Roll Casino Settings")

-----------------------------------------------------------------
-- Min Bet SLIDER (unchanged from before)
-----------------------------------------------------------------
local minBetSlider = CreateFrame("Slider", "FRCMinBetSlider", panel, "OptionsSliderTemplate")
minBetSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -40)
minBetSlider:SetMinMaxValues(1, 10000)
minBetSlider:SetValueStep(1)
minBetSlider:SetObeyStepOnDrag(true)
minBetSlider:SetWidth(200)

minBetSlider:SetValue(FreeRollCasinoDB.minBet)
_G[minBetSlider:GetName().."Low"]:SetText("1g")
_G[minBetSlider:GetName().."High"]:SetText("10000g")
_G[minBetSlider:GetName().."Text"]:SetText("Min Bet: "..FreeRollCasinoDB.minBet.."g")

minBetSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    FreeRollCasinoDB.minBet = value
    _G[self:GetName().."Text"]:SetText("Min Bet: "..value.."g")
    
    -- Sync the edit box if it exists
    if panel.minBetEditBox then
        panel.minBetEditBox:SetText(tostring(value))
    end
end)

-----------------------------------------------------------------
-- Min Bet EDIT BOX for direct input
-----------------------------------------------------------------
-- We'll place it next to or below the slider
local minBetEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
minBetEditBox:SetSize(60, 25)
minBetEditBox:SetPoint("LEFT", minBetSlider, "RIGHT", 10, 0)  -- adjust as needed
minBetEditBox:SetAutoFocus(false)
minBetEditBox:SetNumeric(true)  -- only digits

-- Initialize with current minBet
minBetEditBox:SetText(tostring(FreeRollCasinoDB.minBet))

-- OnEnterPressed => parse the input, update DB, refresh slider
minBetEditBox:SetScript("OnEnterPressed", function(self)
    local text = self:GetText()
    local numVal = tonumber(text)
    if numVal then
        -- clamp to slider range
        if numVal < 1 then numVal = 1 end
        if numVal > 10000 then numVal = 10000 end
        
        FreeRollCasinoDB.minBet = numVal
        minBetSlider:SetValue(numVal)  -- this triggers the slider's OnValueChanged
    end
    self:ClearFocus()
end)

panel.minBetEditBox = minBetEditBox  -- store a reference if we want it elsewhere

-----------------------------------------------------------------
-- Max Bet SLIDER
-----------------------------------------------------------------
local maxBetSlider = CreateFrame("Slider", "FRCMaxBetSlider", panel, "OptionsSliderTemplate")
maxBetSlider:SetPoint("TOPLEFT", minBetSlider, "BOTTOMLEFT", 0, -60)
maxBetSlider:SetMinMaxValues(5, 200000)
maxBetSlider:SetValueStep(5)
maxBetSlider:SetObeyStepOnDrag(true)
maxBetSlider:SetWidth(200)

maxBetSlider:SetValue(FreeRollCasinoDB.maxBet)
_G[maxBetSlider:GetName().."Low"]:SetText("5g")
_G[maxBetSlider:GetName().."High"]:SetText("200k g")
_G[maxBetSlider:GetName().."Text"]:SetText("Max Bet: "..FreeRollCasinoDB.maxBet.."g")

maxBetSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value + 0.5)
    FreeRollCasinoDB.maxBet = value
    _G[self:GetName().."Text"]:SetText("Max Bet: "..value.."g")
    
    if panel.maxBetEditBox then
        panel.maxBetEditBox:SetText(tostring(value))
    end
end)

-----------------------------------------------------------------
-- Max Bet EDIT BOX for direct input
-----------------------------------------------------------------
local maxBetEditBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
maxBetEditBox:SetSize(60, 25)
maxBetEditBox:SetPoint("LEFT", maxBetSlider, "RIGHT", 10, 0)
maxBetEditBox:SetAutoFocus(false)
maxBetEditBox:SetNumeric(true)

maxBetEditBox:SetText(tostring(FreeRollCasinoDB.maxBet))

maxBetEditBox:SetScript("OnEnterPressed", function(self)
    local text = self:GetText()
    local numVal = tonumber(text)
    if numVal then
        if numVal < 5 then numVal = 5 end
        if numVal > 200000 then numVal = 200000 end
        
        FreeRollCasinoDB.maxBet = numVal
        maxBetSlider:SetValue(numVal)
    end
    self:ClearFocus()
end)

panel.maxBetEditBox = maxBetEditBox

-----------------------------------------------------------------
-- Hybrid registration: Retail (Dragonflight) or older expansions
-----------------------------------------------------------------
local function RegisterPanel()
    if Settings and Settings.RegisterAddOnCategory then
        -- Dragonflight
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        print("FreeRollCasino: Registered panel via Settings API (Retail).")
    else
        -- Classic/older fallback
        if InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(panel)
            print("FreeRollCasino: Registered panel via InterfaceOptions_AddCategory (Classic).")
        else
            print("FreeRollCasino: No recognized interface options function found. Panel not added.")
        end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "FreeRollCasino" then
        RegisterPanel()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)