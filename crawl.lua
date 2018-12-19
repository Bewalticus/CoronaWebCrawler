local composer = require( "composer" )
local widget = require( "widget" )
local orm = require( "orm" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function handleAddButtonEvent( event )
    if ( "ended" == event.phase ) then
        local text = scene.crawlField.text
        print("Adding " .. text .. " to the queue")
        if (text ~= "") then
            orm:addUrlToQueue(text)
        end
    end
end 
 
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local title = display.newText( "Add URL to Crawler", display.contentCenterX, 0, native.systemFont, 32 )
    self.crawlField = native.newTextField(display.contentCenterX - 30, 48, display.viewableContentWidth - 65, 24)
    self.crawlField.font = native.newFont( native.systemFontBold, 24 )
    self.crawlField:resizeHeightToFitFont()
    self.crawlField.inputType = "no-emoji"
    self.crawlField.isVisible = false
    local button = widget.newButton(
        {
            x = display.viewableContentWidth - 30,
            y = 48,
            id = "add",
            label = "Add",
            onEvent = handleAddButtonEvent
        }
    )

    sceneGroup:insert(title)
    sceneGroup:insert(self.crawlField)
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
        self.crawlField.isVisible = true
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        self.crawlField.isVisible = false
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