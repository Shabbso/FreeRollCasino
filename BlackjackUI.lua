-- BlackjackUI.lua
-------------------------------------------------------------------------------
-- A simple UI panel for WoW Blackjack with Deal/Hit/Stand buttons
-------------------------------------------------------------------------------

local BlackjackGame = _G["BlackjackGame"]

local BlackjackUI = CreateFrame("Frame", "BlackjackUIFrame", UIParent, "BasicFrameTemplateWithInset")
BlackjackUI:SetSize(400, 250)
BlackjackUI:SetPoint("CENTER")
BlackjackUI:EnableMouse(true)
BlackjackUI:SetMovable(true)
BlackjackUI:RegisterForDrag("LeftButton")
BlackjackUI:SetScript("OnDragStart", function(self) self:StartMoving() end)
BlackjackUI:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
BlackjackUI:Hide()

-- Title
BlackjackUI.title = BlackjackUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
BlackjackUI.title:SetPoint("TOP", 0, -10)
BlackjackUI.title:SetText("WoW Blackjack")

-- Local player name
local localPlayer = UnitName("player")

-- Player hand text
local playerHandText = BlackjackUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
playerHandText:SetPoint("TOPLEFT", 20, -50)
playerHandText:SetText("Player Hand: ???")

-- Dealer text
local dealerHandText = BlackjackUI:CreateFontString(nil, "OVERLAY", "GameFontNormal")
dealerHandText:SetPoint("TOPLEFT", 20, -80)
dealerHandText:SetText("Dealer: ???")

------------------------------------------------------------------------------
-- Deal button
------------------------------------------------------------------------------

local dealButton = CreateFrame("Button", nil, BlackjackUI, "UIPanelButtonTemplate")
dealButton:SetPoint("BOTTOMLEFT", 20, 20)
dealButton:SetSize(80, 24)
dealButton:SetText("Deal")

dealButton:SetScript("OnClick", function()
    if not BlackjackGame.playerBets[localPlayer] then
        print("|cffff0000[Blackjack] You haven't traded any gold yet.|r")
        return
    end
    BlackjackGame:StartGame(localPlayer)
    BlackjackUI:RefreshUI()
end)

------------------------------------------------------------------------------
-- Hit button
------------------------------------------------------------------------------

local hitButton = CreateFrame("Button", nil, BlackjackUI, "UIPanelButtonTemplate")
hitButton:SetPoint("LEFT", dealButton, "RIGHT", 10, 0)
hitButton:SetSize(80, 24)
hitButton:SetText("Hit")

hitButton:SetScript("OnClick", function()
    BlackjackGame:PlayerHit(localPlayer)
    BlackjackUI:RefreshUI()
end)

------------------------------------------------------------------------------
-- Stand button
------------------------------------------------------------------------------

local standButton = CreateFrame("Button", nil, BlackjackUI, "UIPanelButtonTemplate")
standButton:SetPoint("LEFT", hitButton, "RIGHT", 10, 0)
standButton:SetSize(80, 24)
standButton:SetText("Stand")

standButton:SetScript("OnClick", function()
    BlackjackGame:PlayerStand(localPlayer)
    BlackjackUI:RefreshUI()
end)

------------------------------------------------------------------------------
-- RefreshUI: Updates text for player's and dealer's hands
------------------------------------------------------------------------------

function BlackjackUI:RefreshUI()
    local pState = BlackjackGame.playerHands[localPlayer]
    local dState = BlackjackGame.dealerState[localPlayer]

    -- Player
    if not pState then
        playerHandText:SetText("Player Hand: ???")
    else
        local handStr = BlackjackGame:FormatHand(pState.hand)
        playerHandText:SetText("Player Hand: " .. handStr 
            .. " (Total: " .. pState.total .. ") [State: " .. (pState.state or "?") .. "]")
    end

    -- Dealer
    if not dState then
        dealerHandText:SetText("Dealer: ???")
    else
        if pState and pState.state == "active" then
            -- Show only the first dealer card
            dealerHandText:SetText("Dealer shows: " .. dState.hand[1] .. " + [Hidden]")
        else
            -- Reveal full dealer hand
            local dh = BlackjackGame:FormatHand(dState.hand)
            dealerHandText:SetText("Dealer: " .. dh 
                .. " (Total: " .. dState.total .. ") [State: " .. (dState.state or "?") .. "]")
        end
    end
end

------------------------------------------------------------------------------
-- Optional slash command to toggle UI
------------------------------------------------------------------------------

SLASH_BLACKJACKUI1 = "/bjui"
SlashCmdList["BLACKJACKUI"] = function()
    if BlackjackUI:IsShown() then
        BlackjackUI:Hide()
    else
        BlackjackUI:Show()
        BlackjackUI:RefreshUI()
    end
end

_G["BlackjackUI"] = BlackjackUI