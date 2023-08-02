local nvim = require 'nvim'

local function BorderedFloatingWindow(
  positionColumn, positionRow, windowWidth, windowHeight
  )
  local function makeWindowOptions(options)
    return {
      -- the window will be positioned relative to the main editor
      -- see: :h nvim_open_win
      relative = 'editor',
      row = options.row,
      col = options.column,
      width = options.width,
      height = options.height,
      style = 'minimal',
      -- -- we do not want wincommands to enter this window
      -- focusable = false
    }
  end

  local borderBufferPositionRow = positionRow - 1
  local borderBufferPositionColumn = positionColumn - 2

  -- create an unlisted, scratch buffer
  local borderBuffer = nvim.create_buf(false, true)

  local borderBufferContent = {}
  borderBufferContent[1] = "╭" .. string.rep("─", windowWidth + 2) .. "╮"
  for lineNumber = 2, windowHeight + 2 do
    borderBufferContent[lineNumber] = "│" .. string.rep(" ", windowWidth + 2) .. "│"
  end
  borderBufferContent[windowHeight + 2] =
    "╰" .. string.rep("─", windowWidth + 2) .. "╯"

  -- so the :w is disabled, see :h buftype
  nvim.buf_set_option(borderBuffer, 'buftype', 'nofile')
  nvim.buf_set_lines(borderBuffer, 0, -1, true, borderBufferContent)

  local borderWindowOptions = makeWindowOptions{
    style = "minimal",
    row = positionRow - 1,
    column = positionColumn - 2,
    height = windowHeight + 2,
    width = windowWidth + 4
  }
  -- open and focus on the opened window
  local borderWindow = nvim.open_win(borderBuffer, true, borderWindowOptions)
  nvim.win_set_option(borderWindow, 'winhighlight', 'Normal:Float')

  local windowOptions = makeWindowOptions {
    style = "minimal",
    row = positionRow,
    column = positionColumn,
    height = windowHeight,
    width = windowWidth
  }
  local window = nvim.open_win(nvim.create_buf(false, true), true, windowOptions)
  -- nvim.win_set_option(window, 'winhighlight', 'Normal:Float')
  -- delete the border buffer (which further closes the window)
  -- if the actual buffer is deleted
  nvim.ex.autocmd("BufWipeout <buffer> exe 'bw " .. borderBuffer .. "'")
end

local function CenteredFloatingWindow()
  -- get the editor's max width
  local columns = nvim.get_option("columns")
  -- maximum of 100 columns or 60% of available width
  local windowWidth = math.min(math.ceil(columns * 0.7), 140)

  local lines = nvim.get_option("lines")
  -- 40% of the available height
  local windowHeight = math.ceil(lines * 0.5)

  -- where should the window be positioned?
  local positionRow = math.ceil((lines -windowHeight) / 2)
  local positionColumn = math.ceil((columns - windowWidth) / 2)
  return BorderedFloatingWindow(
    positionColumn, positionRow, windowWidth, windowHeight
  )
end

local function SetWindowsN(number)
  nvim.command('only')
  for i = 1, number-1 do
    nvim.command('vsp')
  end
end

return {
  BorderedFloatingWindow = BorderedFloatingWindow,
  CenteredFloatingWindow = CenteredFloatingWindow,
  SetWindowsN = SetWindowsN
}

