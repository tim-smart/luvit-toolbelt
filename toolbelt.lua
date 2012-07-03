local toolbelt  = {}

local table     = require('table')
local tremove   = table.remove

--------

local Object    = {}
toolbelt.Object = Object

function Object:new (...)
  local ret = setmetatable({}, { __index = self })

  if ret.__init then
    ret:__init(...)
  end

  return ret
end

function Object:extend ()
  return setmetatable({}, { __index = self })
end

--------

local Emitter     = Object:extend()
toolbelt.Emitter  = Emitter

function Emitter:__init ()
  self._handlers = {}
end

function Emitter:onMissing (name, ...)
  if 'error' == name then
    if process ~= self then
      local handlers = process.handlers
      if handlers and handlers['error'] then
        process:emit('error', ..., self)
      else
        error('Unhandled error emitted by an event emitter')
      end
    else
      error('Unhandled error emitted by an event emitter')
    end
  end
end

function Emitter:once (name, callback)
  local function wrap (self, ...)
    self:off(name, wrap)
    callback(self, ...)
  end
  self:on(name, wrap)
  return self
end

function Emitter:on (name, callback)
  local handlers  = self._handlers
  local fortype   = handlers[name]

  if not fortype then
    handlers[name] = callback
  else
    local kind = type(fortype)
    if 'function' == kind then
      handlers[name] = { fortype, callback }
    else
      fortype[#fortype + 1] = callback
    end
  end

  return self
end

function Emitter:emit (name, ...)
  local handlers = self._handlers[name]

  if handlers then
    local kind = type(handlers)

    if 'function' == kind then
      handlers(self, ...)
    else
      for i = 1, #handlers do
        handlers[i](self, ...)
      end
    end
  else
    self:onMissing(name, ...)
    return false
  end

  return true
end

function Emitter:off (name, callback)
  local handlers  = self._handlers
  local fortype   = handlers[name]

  if fortype then
    local kind = type(fortype)

    if 'function' == kind then
      handlers[name] = nil
    else
      for i = 1, #fortype do
        if fortype[i] == callback then
          tremove(fortype, i)
        end
      end
    end
  end

  return self
end

return toolbelt
