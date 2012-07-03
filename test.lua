local toolbelt = require('./')
local Emitter = toolbelt.Emitter


local Thing = Emitter:extend()

function Thing:__init ()
  Emitter.__init(self)

  self:on('connect', self.onConnect)
end

function Thing:onConnect (...)
  p(...)
end

local thing = Thing:new()

thing:emit('connect', 1, 2, 3, 4, 5)
thing:emit('notthere')
local function notthere (self)
  p('notthere emitted')
end
local function notthere2 (self)
  p('notthere emitted 2')
end
thing:on('notthere', notthere)
thing:emit('notthere')
thing:on('notthere', notthere2)
thing:emit('notthere')
thing:off('notthere', notthere2)
thing:emit('notthere')
thing:off('notthere', notthere)
thing:emit('notthere')
thing:emit('error', 'This error should throw')
