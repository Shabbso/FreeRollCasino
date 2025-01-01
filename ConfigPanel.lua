-------------------------------------------------------------------------------
-- ConfigPanel.lua
-- A hybrid config panel that appears in "AddOns" list under Interface Options
-- or the new Settings panel if on Retail 10.x+ (Dragonflight).
-------------------------------------------------------------------------------

-- 1) Initialize saved variables (declared in .toc as "SavedVariables: FreeRollCasinoDB")
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
-- 3) Min Bet Slider
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
end)

-----------------------------------------------------------------
-- 4) Max Bet Slider
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
end)

-----------------------------------------------------------------
-- 5) Hybrid registration: Retail (Dragonflight) or older expansions
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

-- Wait for the addon to load fully
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "FreeRollCasino" then
        RegisterPanel()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)