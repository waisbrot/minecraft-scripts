Menu = {
  items = {},
  win = nil,
  selected = 1,
  original_bg = colors.black,
  original_fg = colors.white,
}

local COLOR_UNSELECT_BG = colors.gray
local COLOR_UNSELECT_FG = colors.white
local COLOR_SELECT_BG = colors.lime
local COLOR_SELECT_FG = colors.white

function Menu:new()
  local o = {
    items = {},
    original_bg = term.getBackgroundColor(),
    original_fg = term.getTextColor(),
  }
  local w, h = term.getSize()
  o.win = window.create(term.current(), 1, 1, w, h, false)
  o.win.setBackgroundColor(COLOR_UNSELECT_BG)
  o.win.setTextColor(COLOR_UNSELECT_FG)
  o.win.clear()

  setmetatable(o, self)
  self.__index = self
  return o
end

function Menu:pen_selected()
  self.win.setBackgroundColor(COLOR_SELECT_BG)
  self.win.setTextColor(COLOR_SELECT_FG)
end

function Menu:pen_unselected()
  self.win.setBackgroundColor(COLOR_UNSELECT_BG)
  self.win.setTextColor(COLOR_UNSELECT_FG)
end

function Menu:current_selection()
  return self.items[self.selected]
end

-- print the currently-selected item
function Menu:print_current_selection()
  self.win.write(self:current_selection())
end

-- redraw as unselected the current selection
function Menu:redraw_unselected()
  self.win.setCursorPos(1, self.selected)
  self:pen_unselected()
  self:print_current_selection()
end

-- redraw as selected the current selection
function Menu:redraw_selected()
  self.win.setCursorPos(1, self.selected)
  self:pen_selected()
  self:print_current_selection()
end

function Menu:add(item)
  table.insert(self.items, item)
  self.win.setCursorPos(1, #self.items)
  if #self.items == 1 then
    self.selected = 1
    self:pen_selected()
  else
    self:pen_unselected()
  end
  self.win.write(item)
end

function Menu:up()
  self:redraw_unselected()
  if self.selected == 1 then
    self.selected = #self.items
  else
    self.selected = self.selected - 1
  end
  self:redraw_selected()
end

function Menu:down()
  self:redraw_unselected()
  if self.selected == #self.items then
    self.selected = 1
  else
    self.selected = self.selected + 1
  end
  self:redraw_selected()
end

function Menu:display()
  self.win.setVisible(true)
  local chose = nil
  while chose == nil do
    local _, k = os.pullEvent("key")
    if k == keys.up then self:up()
    elseif k == keys.down then self:down()
    elseif k == keys.enter then chose = true
    elseif k == keys.backspace then chose = false
    end
  end

  -- reset display
  self.win.setVisible(false)
  term.setBackgroundColor(self.original_bg)
  term.setTextColor(self.original_fg)
  term.clear()
  term.setCursorPos(1, 1)

  -- return either the choice or nil
  if chose then
    return self:current_selection()
  else
    return nil
  end
end
