-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local widget = require( "widget" )
local composer = require( "composer" )
local webcrawler = require( "webcrawler" )
 
-- Listen for segmented control events      
local function onSegmentPress( event )
    local target = event.target
    if target.segmentNumber == 1 then composer.gotoScene( "search" ) end
    if target.segmentNumber == 2 then composer.gotoScene( "crawl" ) end
    if target.segmentNumber == 3 then composer.gotoScene( "statistics" ) end
    print( "Segment Label is:", target.segmentLabel )
    print( "Segment Number is:", target.segmentNumber )
end
 
-- Create a default segmented control
local segmentedControl = widget.newSegmentedControl(
    {
        left = 0,
        top = display.viewableContentHeight,
        segmentWidth = display.viewableContentWidth / 3,
        segments = { "Search", "Crawl", "Statistics" },
        defaultSegment = 1,
        onPress = onSegmentPress
    }
)

composer.gotoScene( "search" )

webcrawler:crawlNextFromQueue()
