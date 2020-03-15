local log = libnjw.log

local VALUE_POS_X = 8

local COLOR_UNFILLED_BG = colors.gray
local COLOR_UNFILLED_FG = colors.white
local COLOR_FILLED_BG = colors.lime
local COLOR_FILLED_FG = colors.white

local Item = {
  name = "item",
  callback_keys = [],
  callback = nil,
  value = "",
  place = 1,
}

function Item:new(name, callback_keys, callback)
  assert(#name < 6, "Can't name an item longer than 6 chars")
  local o = {
    place = nil,
    name = name,
    callback_keys = callback_keys,
    callback = callback,
    value = "",
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Item:redraw(win)
  win.setCursorPos(1, self.place)
  pen_label(win)
  win.write(item.name)

  win.setCursorPos(VALUE_POS_X, self.place)
  if self.value == "" then
    pen_unfilled(win)
    win.write("      ")
  else
    pen_filled(win)
    win.write(self.value)
  end
end

function Item:has_callback(key)
  return self.callback_keys[key] ~= nil
end

function Item:do_callback(key)
  local callback_result = self.callback(self.name, key)
  self.value = callback_result.string
end

function Item:backspace()
  self.value = self.value:sub(1, -1)
end

function Item:append_string(s)
  self.value = self.value .. s
end

Form = {
  items = {},
  win = nil,
  selected = 1,
  original_bg = colors.black,
  original_fg = colors.white,
}

function Form:new()
  local o = {
    items = {},
    original_bg = term.getBackgroundColor(),
    original_fg = term.getTextColor(),
  }
  local w, h = term.getSize()
  o.win = window.create(term.current(), 1, 1, w, h, false)
  o.win.setBackgroundColor(COLOR_UNFILLED_BG)
  o.win.setTextColor(COLOR_UNFILLED_FG)
  o.win.clear()

  setmetatable(o, self)
  self.__index = self
  return o
end

function Form:pen_filled()
  pen_filled(self.win)
end

function Form:pen_unfilled()
  pen_unfilled(self.win)
end

function Form:pen_label()
  pen_label(self.win)
end

local function pen_filled(win)
  win.setBackgroundColor(COLOR_SELECT_BG)
  win.setTextColor(COLOR_SELECT_FG)
end

local function pen_unfilled(win)
  win.setBackgroundColor(COLOR_UNSELECT_BG)
  win.setTextColor(COLOR_UNSELECT_FG)
end

local function pen_label(win)
  win.setBackgroundColor(COLOR_LABEL_BG)
  win.setTextColor(COLOR_LABEL_FG)
end

function Form:current_field()
  return self.items[self.selected]
end

-- callback takes (name of current field, key pressed)
-- callback returns {string = string to enter in the current field}
function Form:add(form_item)
  form_item.place = #self.items + 1
  table.insert(self.items, form_item)
end

-- TODO: remove this
function Form:redraw_item(i)
  local item = self.items[i]
  self.win.setCursorPos(1, i)
  self:pen_label()
  self.win.write(item.name)

  self.win.setCursorPos(VALUE_POS_X, i)
  if item.value == "" then
    self:pen_unfilled()
    self.win.write("      ")
  else
    self:pen_filled()
    self.win.write(item.value)
  end
end

function Form:redraw()
  for i=1,#self.items do
    self.items[i]:redraw(self.win)
  end
  self.win.setCursorPos(VALUE_POS_X, self.selected)
  self.win.setCursorBlink(true)
end

function Form:display()
  local chose = nil
  while chose == nil do
    self:redraw()
    self.win.setVisible(true)
    local current_field = self:current_field()
    local _, k = os.pullEvent("key")
    if k == keys.up then self:up()
    elseif k == keys.down then self:down()
    elseif k == keys.tab then self:down()
    elseif k == keys.enter then chose = true
    elseif k == keys.delete then chose = false
    elseif k == keys.backspace then current_field:backspace()
    elseif current_field:has_callback(k) then current_field:do_callback(k)
    else current_field:append_string(keys.getName(k))
    end
  end
  -- reset display
  self.win.setVisible(false)
  term.setBackgroundColor(self.original_bg)
  term.setTextColor(self.original_fg)
  term.clear()
  term.setCursorPos(1, 1)
end

