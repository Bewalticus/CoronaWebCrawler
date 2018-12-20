local composer = require( "composer" )
local widget = require( "widget" )
local orm = require( "orm" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function handleClearButtonEvent( event )
 
    if ( "ended" == event.phase ) then
        orm:clearAll()
        scene:updateInfo()
    end
end
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local title = display.newText( "Statistics", display.contentCenterX, 0, native.systemFont, 32 )
    self.pageText = display.newText( "Indexed Pages: ", display.contentCenterX, 50, native.systemFont, 24)
    self.queueText = display.newText( "Queued Pages: ", display.contentCenterX, 75, native.systemFont, 24)
    self.keyText = display.newText( "Keywords: ", display.contentCenterX, 100, native.systemFont, 24)
    self.assocText = display.newText( "Associations: ", display.contentCenterX, 125, native.systemFont, 24)
    local button = widget.newButton(
        {
            x = display.contentCenterX,
            y = display.viewableContentHeight - 50,
            id = "clear",
            label = "Clear All",
            onEvent = handleClearButtonEvent
        }
    )


    sceneGroup:insert(title)
    sceneGroup:insert(self.pageText)
    sceneGroup:insert(self.queueText)
    sceneGroup:insert(self.keyText)
    sceneGroup:insert(self.assocText)
    sceneGroup:insert(button)
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        self:updateInfo()
    end
end

function scene:updateInfo()
    local pagecount, queuedcount, keycount, assoccount = orm:getStatistics()
    self.pageText.text = "Indexed Pages: " .. pagecount
    self.queueText.text = "Queued Pages: " .. queuedcount
    self.keyText.text = "Keys: " .. keycount
    self.assocText.text = "Associations: " .. assoccount
end
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene