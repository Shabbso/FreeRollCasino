-------------------------------------------------------------------------------
-- FreeRollCasino.lua
-- Main "hub" file that ties multiple games together (FreeRoll, TrollDice, Blackjack).
-- Also defines a global table CasinoRecords to log outcomes for the UI.
-------------------------------------------------------------------------------

-- We'll store persistent config in FreeRollCasinoDB (defined in .toc).
-- For ephemeral bet history, we use CasinoRecords (not saved across sessions).
CasinoRecords = CasinoRecords or {}

local currentGameMode = "FreeRoll"  -- default mode

-- Create a frame to handle events
local CasinoFrame = CreateFrame("Frame")

-- Register events
CasinoFrame:RegisterEvent("TRADE_ACCEPT_UPDATE")
CasinoFrame:RegisterEvent("CHAT_MSG_SYSTEM")

-- References to other game modules (you must load them before this file in .toc)
local FreeRollGame  = _G["FreeRollGame"]
local TrollDiceGame = _G["TrollDiceGame"]
local BlackjackGame = _G["BlackjackGame"]       -- new
local BlackjackUI   = _G["BlackjackUI"]         -- new UI with Deal/Hit/Stand

local function OnEvent(self, event, ...)
    if event == "TRADE_ACCEPT_UPDATE" then
        local playerName, goldAmount = ...

        if currentGameMode == "FreeRoll" then
            FreeRollGame:OnTrade(playerName, goldAmount)
        elseif currentGameMode == "TrollDice" then
            TrollDiceGame:OnTrade(playerName, goldAmount)
        elseif currentGameMode == "Blackjack" then
            -- Add Blackjack integration here
            BlackjackGame:OnTrade(playerName, goldAmount)
        end

    elseif event == "CHAT_MSG_SYSTEM" then
        local msg = ...

        -- 1) Check for a typical 1–100 roll: "<player> rolls <X> (1-100)"
        local frPlayer, frRoll = string.match(msg, "^(%S+) rolls (%d+) %(1%-100%)")
        if frPlayer and frRoll then
            frRoll = tonumber(frRoll)
            if currentGameMode == "FreeRoll" then
                FreeRollGame:OnSystemRoll(frPlayer, frRoll)
            else
                print("|cffcccccc[Casino] Ignoring 1–100 roll from " 
                      .. frPlayer .. " (not in FreeRoll mode).|r")
            end
            return
        end

        -- 2) Check for a 1–6 roll: "<player> rolls <X> (1-6)"
        local tdPlayer, tdRoll = string.match(msg, "^(%S+) rolls (%d+) %(1%-6%)")
        if tdPlayer and tdRoll then
            tdRoll = tonumber(tdRoll)
            if currentGameMode == "TrollDice" then
                TrollDiceGame:OnSystemRoll(tdPlayer, tdRoll)
            else
                print("|cffcccccc[Casino] Ignoring 1–6 roll from " 
                      .. tdPlayer .. " (not in TrollDice mode).|r")
            end
            return
        end
    end
end

CasinoFrame:SetScript("OnEvent", OnEvent)

-------------------------------------------------------------------------------
-- Slash command to switch game modes
-------------------------------------------------------------------------------
SLASH_CASINOMODE1 = "/casinomode"
SlashCmdList["CASINOMODE"] = function(mode)
    mode = string.lower(mode or "")
    if mode == "freeroll" then
        currentGameMode = "FreeRoll"
        print("|cffffff00[Casino] Game mode set to Free Roll.|r")

    elseif mode == "troll" then
        currentGameMode = "TrollDice"
        print("|cffffff00[Casino] Game mode set to Worn Troll Dice.|r")

    elseif mode == "blackjack" then
        currentGameMode = "Blackjack"
        print("|cffffff00[Casino] Game mode set to Blackjack.|r")

        -- OPTIONAL: auto-open the Blackjack UI
        if BlackjackUI then
            BlackjackUI:Show()
            BlackjackUI:RefreshUI()
        end

    else
        print("|cffffff00Usage: /casinomode freeroll | troll | blackjack|r")
        print("|cffffff00Currently: " .. currentGameMode .. "|r")
    end
end