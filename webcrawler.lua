local orm = require( "orm" )
local network = require( "network" )
local json = require( "json" )
require("html")

local Crawler = {}

function Crawler:crawlNextFromQueue()
    local url, id = orm:moveUrlFromQueueToPage()

    if (url) then
        self.id = id
        self.url = url
        orm:deleteAssociationsForUrl(id)
    
        network.request(url, "GET", self)
    else
        self:scheduleNextRound()
    end
end

function Crawler:networkRequest(event)
    if (not event.isError) then
        if ( "ended" == event.phase ) then
            print("URL "..event.url.." responds with status "..event.status.." and Content-Type "..event.responseHeaders["Content-Type"])
            if ( event.status == 200 and string.find(event.responseHeaders["Content-Type"], "text/html")) then
                local response = event.response
                local parsed = html.parsestr(response)
                local text = self:getTextAndAddLinksFrom(parsed)
                text = string.gsub(string.gsub(string.gsub(text, "'+", " "), "%c+", " "), "%s+", " ")
                text = string.lower(text)
                local words = self:collectWords(text)
                self:createKeywordAssociations(words)
            end
        end
    else
        print("Error retrieving URL "..event.url.." : "..event.response)
    end
    self:scheduleNextRound()
end

function Crawler:createKeywordAssociations(words)
    for key, value in pairs(words) do
        if (string.len(key) > 1) then
            if (not self.ignorableWords[key]) then
                keyId = orm:getKeywordId(key)
                orm:addAssociation(self.id, keyId)
            end
        end
    end
end

function Crawler:getTextAndAddLinksFrom(table)
    local text = ""
    if (table["_tag"] == "a") then
        local link = table["_attr"]["href"]
        if (link and (not string.starts(link, "#"))) then
            if ( (not string.starts(link, "https://")) and (not string.starts(link, "http://"))) then
                if ( (not string.starts(link, "/")) and (not string.ends(self.url, "/")) ) then
                    link = "/" .. link
                end
                link = self.url .. link
            end
            orm:addUrlToQueue(link)
        end
    end
    for name, value in pairs(table) do
        if ( type(value) == "table" ) then
            text = text .. " " .. self:getTextAndAddLinksFrom(value)
        elseif ( type(name) == "number") then
            text = text .. " " .. value
        end
    end
    return text
end

function Crawler:collectWords(inputstring)
    local t={}
    for str in string.gmatch(inputstring, "([^%s]+)") do
            t[str] = true
    end
    return t
end

function Crawler:scheduleNextRound()
    timer.performWithDelay(500, self)
end

function Crawler:timer(event)
    self:crawlNextFromQueue()
end

local function Set (list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
  end
  
Crawler.traversableTags = Set {"#document", "html", "title", "body", "p", "b", "a", "#nil", "head"}

Crawler.ignorableWords = Set {"the", "an", "der", "das", "ein", "eine", "einen"}

return Crawler