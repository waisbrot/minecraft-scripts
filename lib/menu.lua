Menu = {
  items = {},
  selected = 1,
}

function Menu:new()
  local w, h = term.getSize()
  local win = window.create(term.current(), 0, 0, w, h, false)
  win.setBackgroundColor(colors.gray)
  win.setTextColor(colors.white)
  win.clear()
  local o = {
    items = {},
    win = win,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Menu:pen_selected()
  self.win.setBackgroundColor(colors.lime)
  self.win.setTextColor(colors.black)
end

function Menu:pen_unselected()
  self.win.setBackgroundColor(colors.gray)
  self.win.setTextColor(colors.white)
end

function Menu:current_selection()
  return self.items[self.selected]
end

-- print the currently-selected item
function Menu:print_current_selection()
  print(self:current_selection())
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
  print(item)
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
  while true do
    local _, k = os.pullEvent("key")
    if k == keys.up then self:up()
    elseif k == keys.down then self:down()
    elseif k == keys.enter then return self:current_selection()
    elseif k == keys.backspace then return nil
    end
  end
end
