SCC = LibStub("AceAddon-3.0"):NewAddon("SimpleChatCleaner", "AceConsole-3.0", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("SimpleChatCleaner")
local AceGUI = LibStub("AceGUI-3.0")

local options = {
  name = L["Simple Chat Cleaner"],
  handler = SCC,
  type = "group",
  args = {
    stat = {
      order = 0,
      name = "",
      guiInline = true,
      cmdHidden = true,
      type = "group",
      args = {
        counter = {
          type = "description",
          name = function() return L["SessionCount"](SCC.sessionCount) .. "\n\n" end,
        },
      },
    },
    config = {
      order = 1,
      name = L["Config Options"],
      type = "group",
      inline = true,
      args = {
        enabled = {
          order = 0,
          type = "toggle",
          name = L["Enabled"],
          desc = L["Enables the Chat Cleaner"],
          get = "GetEnabled",
          set = "SetEnabled",
        },
        debug = {
          order = 101,
          type = "toggle",
          name = L["Debug"],
          desc = L["Toggles debug mode"],
          get = "GetDebugMode",
          set = "SetDebugMode",
        },
        filterFriendly = {
          type = "toggle",
          name = L["Filter Friendly"],
          desc = L["Filter friends and guild members"],
          get = "GetFilterFriendly",
          set = "SetFilterFriendly",
        },
        filterSay = {
          type = "toggle",
          name = L["Filter Say"],
          desc = L["Filter /say"],
          get = "GetFilterSay",
          set = "SetFilterSay",
        },
        filterYell = {
          type = "toggle",
          name = L["Filter Yell"],
          desc = L["Filter /yell"],
          get = "GetFilterYell",
          set = "SetFilterYell",
        },
        wholeWords = {
          type = "toggle",
          name = L["Match Whole Words"],
          desc = L["Filter by the full word only instead of partial matches"],
          get = "GetWholeWords",
          set = "SetWholeWords",
        },
      },
    },
    filters = {
      order = 10,
      name = L["Filters"],
      type = "group",
      inline = true,
      args = {
        addOne = {
          order = 0,
          type = "input",
          name = L["Add Word to Filter One"],
          desc = L["Adds a word to the first Filter Group"],
          get = false,
          set = "AddOne",
          validate = "ValidateAdd",
        },
        showOne = {
          order = 5,
          type = "multiselect",
          name = "",
          values = function() return #SCC.db.profile.filterGroupOne > 0 and SCC.db.profile.filterGroupOne or  {L["Empty Filter"]} end,
          get = function(_, idx) return SCC.db.profile.filterGroupOne[idx] end,
          set = function(_, idx) return table.remove(SCC.db.profile.filterGroupOne, idx) end,
          cmdHidden = true,
        },
        addTwo = {
          order = 10,
          type = "input",
          name = L["Add Word to Filter Two"],
          desc = L["Adds a word to the second Filter Group"],
          get = false,
          set = "AddTwo",
          validate = "ValidateAdd",
        },
        showTwo = {
          order = 15,
          type = "multiselect",
          name = "",
          values = function() return #SCC.db.profile.filterGroupTwo > 0 and SCC.db.profile.filterGroupTwo or {L["Empty Filter"]} end,
          get = function(_, idx) return SCC.db.profile.filterGroupTwo[idx] end,
          set = function(_, idx) return table.remove(SCC.db.profile.filterGroupTwo, idx) end,
          cmdHidden = true,
        },
      }
    },
    exec = {
      order = 20,
      name = "",
      type = "group",
      inline = true,
      args = {
        list = {
          type = "execute",
          name = L["List Filters"],
          desc = L["List all word filters to the chat console"],
          func = "ListWords",
          guiHidden = true,
        },
        stats = {
          type = "execute",
          name = L["Stats"],
          desc = L["Show basic filtering stats"],
          func = "Stats",
          guiHidden = true,
        },
        clear = {
          type = "execute",
          name = L["Clear All Filters"],
          desc = L["Removes all words from all filters"],
          func = "ClearFilters",
        },
      }
    },
    channels = {
      order = 30,
      name = L["Channels"],
      type = "group",
      inline = true,
      args = {
        addChannel = {
          order = 0,
          type = "input",
          name = L["Add Channel"],
          desc = L["Adds a channel to filter on, an empty list means ALL channels"],
          get = false,
          set = "AddChannel",
          validate = "ValidateAdd",
        },
        showChannel = {
          order = 5,
          type = "multiselect",
          name = "",
          values = function() return #SCC.db.profile.channels > 0 and SCC.db.profile.channels or {L["All Channels"]} end,
          get = function(_, idx) return #SCC.db.profile.channels == 0 and L["All Channels"] or SCC.db.profile.channels[idx] end,
          set = function(_, idx) if #SCC.db.profile.channels > 0 then table.remove(SCC.db.profile.channels, idx) end end,
          cmdHidden = true,
        },
      }
    },
  },
}

local defaults = {
  profile = {
    debug = false,
    filterGroupOne = {},
    filterGroupTwo = {},
    enabled = true,
    wholeWords = false,
    filterFriendly = false,
    filterSay = false,
    filterYell = false,
    channels = {},
  }
}

function SCC:ClearFilters()
  self.db.profile.filterGroupOne = {}
  self.db.profile.filterGroupTwo = {}
end

function SCC:ListWords()
  self:Print("Filter One:")
  for i=1, #self.db.profile.filterGroupOne do
    self:Print(self.db.profile.filterGroupOne[i])
  end
  self:Print("Filter Two:")
  for i=1, #self.db.profile.filterGroupTwo do
    self:Print(self.db.profile.filterGroupTwo[i])
  end
end

function SCC:Stats()
  self:Print(L["SessionCount"](self.sessionCount))
end

function SCC:AddOne(_, value)
  self:Debug("Adding to Filter One: " .. value)
  table.insert(self.db.profile.filterGroupOne, value)
end

function SCC:AddTwo(_, value)
  self:Debug("Adding to Filter Two: " .. value)
  table.insert(self.db.profile.filterGroupTwo, value)
end

function SCC:AddChannel(_, value)
  self:Debug("Adding Channel: " .. value)
  table.insert(self.db.profile.channels, value)
end

function SCC:ValidateAdd()
  return true
end

function SCC:StringSearch(msg, kw)
	-- special: check for ecncapsulating symbols that exist around the word (like <GUILD NAMES>)...
	local encapsulated_word =
		(kw:sub(1, 1) == "<" or kw:sub(1, 1) == "{" or kw:sub(1, 1) == "[" or kw:sub(1, 1) == "(") and
		(kw:sub(-1)   == ">" or kw:sub(-1)   == "}" or kw:sub(-1)   == "]" or kw:sub(-1)   == ")")
	return
		( self.db.profile.wholeWords == true  and string.find(msg, "%f[%w_]" .. kw .. "%f[^%w_]")) or
		((self.db.profile.wholeWords == false or encapsulated_word) and msg:find(kw, nil, true))
end

function SCC:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("SimpleChatCleanerDB", defaults, true)
  self.prevLineId = 0
  self.result = nil
end

function SCC:OnEnable()
  self:Print(L["AddonEnabled"](GetAddOnMetadata("SimpleChatCleaner", "Version"), GetAddOnMetadata("SimpleChatCleaner", "Author")))
  self.firstOpen = true
  LibStub("AceConfig-3.0"):RegisterOptionsTable("SimpleChatCleaner", options)
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SimpleChatCleaner", L["Simple Chat Cleaner"])
  self:RegisterChatCommand(L["scc"], "ChatCommand")
  self:RegisterChatCommand(L["simplechatcleaner"], "ChatCommand")
  self:RegisterChatCommand(L["simplechat"], "ChatCommand")
  ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.CHAT_MSG_CHANNEL)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.CHAT_MSG_SAY)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.CHAT_MSG_YELL)
  self:Debug("Debug Enabled")
  self.sessionCount = 0
end

function SCC:ChatCommand(input)
  if input == nil then
    input = ""
  end
  input = input:trim()
  if input == "" or input == "config" or input == "settings" then
    -- Blizzard bug - doesn't open to correct frame the first time
    if self.firstOpen then
      self.firstOpen = false
      InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    end
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
  elseif input == "help" then
    LibStub("AceConfigCmd-3.0"):HandleCommand(L["scc"], "SimpleChatCleaner", "")
  else
    LibStub("AceConfigCmd-3.0"):HandleCommand(L["scc"], "SimpleChatCleaner", input)
  end
end

function SCC:GetFilterFriendly(info)
  return self.db.profile.filterFriendly
end

function SCC:SetFilterFriendly(info, value)
  self.db.profile.filterFriendly = value
  self:Debug(L["Filter Friendly"] .. " " .. L[value and "enabled" or "disabled"])
end

function SCC:GetFilterSay(info)
  return self.db.profile.filterSay
end

function SCC:SetFilterSay(info, value)
  self.db.profile.filterSay = value
  self:Debug(L["Filter Say"] .. " " .. L[value and "enabled" or "disabled"])
end

function SCC:GetFilterYell(info)
  return self.db.profile.filterYell
end

function SCC:SetFilterYell(info, value)
  self.db.profile.filterYell = value
  self:Debug(L["Filter Yell"] .. " " .. L[value and "enabled" or "disabled"])
end

function SCC:GetWholeWords(info)
  return self.db.profile.wholeWords
end

function SCC:SetWholeWords(info, value)
  self.db.profile.wholeWords = value
  self:Debug(L["Match Whole Words"] .. " " .. L[value and "enabled" or "disabled"])
end

function SCC:GetDebugMode(info)
  return self.db.profile.debug
end

function SCC:SetDebugMode(info, value)
  self.db.profile.debug = value
  self:Print(L["Debug"] .. " " .. L[value and "enabled" or "disabled"])
end

function SCC:GetEnabled(info)
  return self.db.profile.enabled
end

function SCC:SetEnabled(info, value)
  self.db.profile.enabled = value
  self:Print(L["Simple Chat Cleaner"] .. " " .. L[value and "enabled" or "disabled"])
end

function SCC:Debug(msg)
  if self.db.profile.debug then
    if msg == nil then
      msg = "nil"
    end
    self:Print("|cFFFFFF00" .. msg .. "|r")
  end
end

function SCC:IsFriendly(name, flag, _, guid)
  if not guid then return true end -- LocalDefense automated prints
  if not guid:find("^Player") then
    self:Debug("Unexpected GUID requested by an addon: " .. guid)
    return true
  end
  local _, characterName = BNGetGameAccountInfoByGUID(guid)
  if characterName or IsGuildMember(guid) or C_FriendList.IsFriend(guid) or UnitInRaid(name) or UnitInParty(name) or flag == "GM" or flag == "DEV" then
    return true
  end
end

function SCC:CHAT_MSG_SAY(event,msg,player,_,_,_,flag,chid,chnum,chname,_,lineId,guid)
  if not SCC.db.profile.enabled or not SCC.db.profile.filterSay then return end
  return SCC:Filter(msg,player,flags,lineId,guid)
end

function SCC:CHAT_MSG_YELL(event,msg,player,_,_,_,flag,chid,chnum,chname,_,lineId,guid)
  if not SCC.db.profile.enabled or not SCC.db.profile.filterYell then return end
  return SCC:Filter(msg,player,flags,lineId,guid)
end

function SCC:CHAT_MSG_CHANNEL(event,msg,player,_,_,_,flag,chid,chnum,chname,_,lineId,guid)
  if not SCC.db.profile.enabled then return end
  if event == "" and type(chid) ~= "number" then return end
  if #SCC.db.profile.channels == 0 then  return SCC:Filter(msg,player,flags,lineId,guid) end
  for i=1, #SCC.db.profile.channels do
    if chname and chname ~= '' and string.lower(SCC.db.profile.channels[i]) == string.lower(chname) then
      return SCC:Filter(msg,player,flags,lineId,guid)
    end
  end
end

function SCC:Filter(msg,player,flag,lineId,guid)
  local filterOneCount = #self.db.profile.filterGroupOne;
  local filterTwoCount = #self.db.profile.filterGroupTwo;
  if filterOneCount + filterTwoCount == 0 then return end

  if lineId == self.prevLineId then return self.result end

  self.prevLineId = lineId
  self.result = nil

  local trimmedPlayer = Ambiguate(player, "none")
  if trimmedPlayer == UnitName("player") then return end

  local lowMsg = msg:lower()

  if not self.db.profile.filterFriendly and self:IsFriendly(trimmedPlayer, flag, lineId, guid) then return end

  local matchString = ""
  local matchFilterOne = filterOneCount == 0
  for i=1, #self.db.profile.filterGroupOne do
    local m1 = self.db.profile.filterGroupOne[i]
    if self:StringSearch(lowMsg, m1) then
      matchString = m1
      matchFilterOne = true
      break
    end
  end

  local matchFilterTwo = filterTwoCount == 0
  for i=1, #self.db.profile.filterGroupTwo do
    local m2 = self.db.profile.filterGroupTwo[i]
    if self:StringSearch(lowMsg, m2) then
      matchString = matchString .. " & " .. m2
      matchFilterTwo = true
      break
    end
  end

  self.result = matchFilterOne and matchFilterTwo

  if self.result == true and self.db.profile.debug then
    self:Debug("Match: " .. matchString)
    self:Print("|cFFFC0000" .. msg .. "|r")
  end

  if self.result then self.sessionCount = self.sessionCount + 1 end

  return self.result
end
