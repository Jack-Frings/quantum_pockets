Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'
socket = require("socket")

require 'src/constants'
require 'src/Background'
require 'src/Level'
require 'src/StateMachine'
require 'src/CueBall'
require 'src/CueStick'
require 'src/Slider'

require 'src/states/BaseState'
require 'src/states/PlayState'
require 'src/states/StartState'

require 'src/states/cue_stick/WaitingState'
require 'src/states/cue_stick/PoweringState'
require 'src/states/cue_stick/AnimationState'
require 'src/states/cue_stick/HittingState'

gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
    ['huge'] = love.graphics.newFont('fonts/font.ttf', 64)
}
