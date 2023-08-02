local nvim = require 'nvim'
local window = require 'window'

function openInRightMostWindow(fileName, line, column)
  layout = nvim.fn.winlayout()
  if layout[1] == "leaf" or layout[1] == "col" then
    nvim.ex.vertical("botright vsp " .. fileName)
  elseif layout[1] == "row" then
    rowLayout = layout[2]
    rightMostNode = rowLayout[#rowLayout]
    if rightMostNode[1] == "leaf" then
      windowId = rightMostNode[2]
      nvim.fn.win_gotoid(windowId)
      nvim.ex.e(fileName)
    end
  end
  if line and column then
    vim.fn.cursor(line, column)
  end
end

function openInLeftMostWindow(fileName, line, column)
  layout = nvim.fn.winlayout()
  if layout[1] == "leaf" or layout[1] == "col" then
    nvim.ex.vertical("topleft vsp " .. fileName)
  elseif layout[1] == "row" then
    rowLayout = layout[2]
    leftMostNode = rowLayout[1]
    if leftMostNode[1] == "leaf" then
      windowId = leftMostNode[2]
      nvim.fn.win_gotoid(windowId)
      nvim.ex.e(fileName)
    end
  end
  if line and column then
    vim.fn.cursor(line, column)
  end
end

function trim(s)
   return string.match(s,'^()%s*$') and '' or string.match(s,'^%s*(.*%S)')
end

local function split(s, sep)
   local r, patt = {}
   if sep == '' then
      patt = '(.)'
      insert(r, '')
   else
      patt = '(.-)' ..(sep or '%s+')
   end
   local b, slen = 0, #s
   while b <= slen do
      local e, n, m = string.find(s, patt, b + 1)
      table.insert(r, m or string.sub(s, b + 1, slen))
      b = n or slen + 1
   end
   return r
end


local function getGitRoot()
  local currentFileDirectory = vim.fn.expand('%:p:h')
  local gitRoot = trim(vim.fn.system(table.concat({"git -C", currentFileDirectory, "rev-parse --show-toplevel 2> /dev/null"}, " ")))
  if gitRoot ~= "" then
    return gitRoot
  else
    return currentFileDirectory
  end
end
getGitRoot()

local function runCommand(terminalCommand, workingDirectory, exitCallback)
  local callingWindowId = nvim.fn.win_getid()
  local options = {}
  if workingDirectory then
    options.cwd = workingDirectory
  end
  options.on_exit = function(jobId, data, event)
    local bufferLines = nvim.buf_get_lines(0, 0, -1, false)
    nvim.command("bw!")
    nvim.fn.win_gotoid(callingWindowId)
    exitCallback(bufferLines)
  end
  window.CenteredFloatingWindow()
  nvim.fn.termopen(terminalCommand, options)
  nvim.ex.startinsert()
end

local function keys(t)
   local l = {}
   for k in pairs(t) do
      l[#l + 1] = k
   end
   return l
end

local function openFileWithExCommand(exCommand)
  return function (fileName, line, column)
    nvim.command(exCommand .. " " .. fileName)
    vim.fn.cursor(line, column)
  end
end

fileNameMappings = {
  ['']       = openFileWithExCommand('e'),
  ['ctrl-v'] = openFileWithExCommand('vsp'),
  ['ctrl-s'] = openFileWithExCommand('sp'),
  ['ctrl-l'] = openInRightMostWindow,
  ['ctrl-h'] = openInLeftMostWindow
}

local function searchInProjectInteractive()
  local mappings = {
    ['']       = openFileWithExCommand('e'),
    ['ctrl-v'] = openFileWithExCommand('vsp'),
    ['ctrl-s'] = openFileWithExCommand('sp'),
    ['ctrl-l'] = openInRightMostWindow,
    ['ctrl-h'] = openInLeftMostWindow
  }

  local command = "sk --ansi --reverse -i -c 'if [ $(echo -n \"{}\" | wc -m) -ge 3 ]; then rg --column --line-number --no-heading --color=always --smart-case \"{}\"; fi'" .. " --expect " .. table.concat(keys(mappings),",")

  local projectRoot = getGitRoot()

  local openRgLocation = function(output)
    -- output[1] is the key that's executed
    -- output[2] is the search result which is empty when there is no result
    if output[2] ~= '' then
      -- locations[1] is the filename and locations[2] and locations[3] are
      -- line and column respectively
      local locations = split(output[2], ':')
      local filePath = projectRoot .. '/' .. locations[1]
      mappings[output[1]](filePath, locations[2], locations[3])
    end
  end
  runCommand(command, projectRoot, openRgLocation)
end

local function searchInProject(query)
  local mappings = {
    ['']       = openFileWithExCommand('e'),
    ['ctrl-v'] = openFileWithExCommand('vsp'),
    ['ctrl-s'] = openFileWithExCommand('sp'),
    ['ctrl-l'] = openInRightMostWindow,
    ['ctrl-h'] = openInLeftMostWindow
  }

  local rgCommand = "rg --column --line-number --no-heading --color=always --smart-case -w " .. vim.fn.shellescape(query)
  local skCommand = "sk --ansi --reverse --expect " .. table.concat(keys(mappings),",") .. " --prompt " .. vim.fn.shellescape("> " .. query)

  local command = rgCommand .. ' | ' .. skCommand

  local projectRoot = getGitRoot()

  local openRgLocation = function(output)
    -- output[1] is the key that's executed
    -- output[2] is the search result which is empty when there is no result
    if output[2] ~= '' then
      -- locations[1] is the filename and locations[2] and locations[3] are
      -- line and column respectively
      local locations = split(output[2], ':')
      local filePath = projectRoot .. '/' .. locations[1]
      mappings[output[1]](filePath, locations[2], locations[3])
    end
  end
  runCommand(command, projectRoot, openRgLocation)
end

local function projectFiles()
  local mappings = {
    ['']       = openFileWithExCommand('e'),
    ['ctrl-v'] = openFileWithExCommand('vsp'),
    ['ctrl-s'] = openFileWithExCommand('sp'),
    ['ctrl-l'] = openInRightMostWindow,
    ['ctrl-h'] = openInLeftMostWindow
  }

  local command = "rg --files | sk --reverse --expect " .. table.concat(keys(mappings),",")

  local projectRoot = getGitRoot()
  local openFile = function(output)
    -- output[1] is the key that's executed
    -- output[2] is the search result which is empty when there is no result
    if output[2] ~= '' then
      local filePath = projectRoot .. '/' .. output[2]
      mappings[output[1]](filePath, nil, nil)
    end
  end
  runCommand(command, projectRoot, openFile)
end

return {
  searchInProjectInteractive = searchInProjectInteractive,
  searchInProject = searchInProject,
  getGitRoot = getGitRoot,
  projectFiles = projectFiles,
  recentBuffers = recentBuffers
}

