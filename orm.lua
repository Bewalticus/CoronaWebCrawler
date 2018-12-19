local DB = {}
local sqlite3 = require( "sqlite3" )

function DB:initialize()
   self.connection:exec([[CREATE TABLE IF NOT EXISTS page (id INTEGER PRIMARY KEY, url, title);]]) 
   self.connection:exec([[CREATE TABLE IF NOT EXISTS queue (id INTEGER PRIMARY KEY, url);]]) 
   self.connection:exec([[CREATE TABLE IF NOT EXISTS keyword (id INTEGER PRIMARY KEY, keyword);]]) 
   self.connection:exec([[CREATE TABLE IF NOT EXISTS association (id INTEGER PRIMARY KEY, pageid INTEGER, keywordid INTEGER);]]) 
end

function DB:addUrlToQueue(url)
    for row in self.connection:nrows([[SELECT count(*) as nummer FROM page WHERE url=']] .. url .. [[';]]) do
        if ( row.nummer ~= 0 ) then
            return
        end
    end
    for row in self.connection:nrows([[SELECT count(*) as nummer FROM queue WHERE url=']] .. url .. [[';]]) do
        if ( row.nummer ~= 0 ) then
            return
        end
    end
    self.connection:exec([[INSERT INTO queue VALUES (NULL, ']] .. url .. [[');]])
    print(self.connection:last_insert_rowid())
end

function DB:getStatistics()
    local pagecount = 0
    local queuedcount = 0
    for row in self.connection:nrows([[SELECT count(*) as pagecount FROM page]]) do
        pagecount = row.pagecount
    end
    for row in self.connection:nrows([[SELECT count(*) as queuedcount FROM queue]]) do
        queuedcount = row.queuedcount
    end
    return pagecount, queuedcount
end

function DB:moveUrlFromQueueToPage()
    local firstEntry = 0
    local url
    for row in self.connection:nrows([[SELECT MIN(id) as minimum FROM queue;]]) do
        firstEntry = row.minimum
    end
    for row in self.connection:nrows([[SELECT * FROM queue WHERE id=]]..firstEntry..[[;]]) do
        url = row.url
    end
    self.connection:exec([[DELETE FROM queue WHERE id=]]..firstEntry..[[;]])

    local id
    for row in self.connection:nrows([[SELECT * FROM page WHERE url=']]..url..[[';]]) do
        id = row.id
    end
    if (not id) then
        self.connection:exec([[INSERT INTO page VALUES (NULL, ']]..url..[[', NULL);]])
        id = self.connection:last_insert_rowid()
    end
    return url, id
end

function DB:getKeywordId(keyword)
    local id
    for row in self.connection:nrows([[SELECT * FROM keyword WHERE keyword=']]..keyword..[[';]]) do
        id = row.id
    end
    if (not id) then
        self.connection:exec([[INSERT INTO keyword VALUES (NULL, ']]..keyword..[[');]])
        id = self.connection.last_insert_rowid()
    end
    return id
end

function DB:deleteAssociationsForUrl(id)
    self.connection:exec([[DELETE FROM association WHERE pageid=]]..id..[[;]])
end

function DB:addAssociation(pageid, keywordid)
    self.connection:exec([[INSERT INTO association VALUES (NULL, ]]..pageid..[[, ]]..keywordid..[[);]])
end

local function onSystemEvent( event )
    if ( event.type == "applicationExit" and DB.connection and DB.connection:isopen()) then             
        DB.connection:close()
    end
end

local path = system.pathForFile( "crwaler.db", system.DocumentsDirectory )

DB.connection = sqlite3.open( path )
DB:initialize()

Runtime:addEventListener( "system", onSystemEvent )

return DB