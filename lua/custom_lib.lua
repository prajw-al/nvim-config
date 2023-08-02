local nvim = require 'nvim'

function string.startswith(str, prefix)
  return str:sub(1, #prefix) == prefix
end

function string.endswith(str, suffix)
  return str:sub(-#suffix) == suffix
end

-- the priorities are as follows:
-- 1. buffers in the same project directory
-- 2. other open buffers
-- 3. past files in the same project directory
-- 4. past files else where
-- 5. docs
local function GetBufferCandidates(project_directorys)
  local candidates = {}
  local candidate_keys = {}
  local function add_to_candidates(key, value)
    candidates[key] = value
    candidate_keys[#candidate_keys + 1] = key
  end

  -- go through all the buffers
  for _, buffer_id in ipairs(nvim.list_bufs()) do
    is_loaded = nvim.buf_is_loaded(buffer_id)
    is_listed = nvim.buf_get_option(buffer_id, 'buflisted')

    if is_loaded and is_listed then
      local buffer_name = nvim.buf_get_name(buffer_id)

      -- project local buffer
      if string.startswith(buffer_name, project_directory) then
        -- strip out the project directory name
        local short_name = 'b:' .. buffer_name:sub(#project_directory + 1)
        add_to_candidates(short_name, {category=0, kind='buffer', location=buffer_name})
      -- other open buffers
      else
        local short_name = 'b:' .. buffer_name
        add_to_candidates(short_name, {category=1, kind='buffer', location=buffer_name})
      end

    end
  end

  local docs_location = vim.loop.os_getenv("VIMRUNTIME") .. "/doc/"
  -- all the old files
  for _, old_file in ipairs(nvim.v.oldfiles) do

    if string.startswith(old_file, docs_location) then
      -- strip out the docs location and the .txt extension
      local short_name = 'd:' .. old_file:sub(#docs_location + 1, -5)
      add_to_candidates(short_name, {category=4, kind='doc', location=old_file})

    -- project local old files
    elseif string.startswith(old_file, project_directory) then
      -- strip out the project directory name
      local short_name = 'r:' .. old_file:sub(#project_directory + 1)
      add_to_candidates(short_name, {category=2, kind='oldfile', location=old_file})

    -- other oldfiles
    else
      local short_name = 'r:' .. old_file
      add_to_candidates(short_name, {category=3, kind='oldfile', location=old_file})
    end

  end

  table.sort(candidate_keys,
    function(a, b)
      local a_info = candidates[a]
      local b_info = candidates[b]
      if a_info.category == b_info.category then
        return a_info.location < b_info.location
      else
        return a_info.category < b_info.category
      end
    end
  )
  return candidate_keys
  -- print(vim.inspect(candidate_keys))
end
-- GetBufferCandidates("/home/mavish/.config/nvim/")

-- local function FzfCommand()
--   local callback = {
--     -- windowId = nvim.get_current_win(),
--     -- temporaryFileName = nvim.fn.tempname(),
--     -- on_exit = function(jobId, data, event)
--     --   print("hello from exit")
--     -- end
--     on_exit = "onExitFunction"
--   }
--   local onExitFunction = function(jobId, data, event)
--       print("hello from exit")
--     end
--   CenteredFloatingWindow()
--   terminalJobId = vim.api.nvim_call_function("termopen", {"ls -la | fzf --layout=reverse"})
--   nvim.ex.startinsert()
--   -- nvim.fn.jobwait({terminalJobId})
--   currentBuf = nvim.get_current_buf()
--   print(vim.inspect(nvim.buf_get_lines(currentBuf, 0, -1, false)))
-- end
-- FzfCommand()
-- require'nvim'.fn.termopen('ls -la')

local nvim = require 'nvim'
local function GetOrCreateBuffer(bufferName, creationCommand, bufferOptions)
  -- window number returned by bufwinnr cannot be used with the
  -- nvim's _win functions
  local win = nvim.fn.bufwinnr(bufferName)
  if win < 0 then
    nvim.command(creationCommand .. ' ' .. bufferName)
    for option, value in pairs(bufferOptions) do
      nvim.buf_set_option(0, option, value)
    end
  else
    -- change focus to the above returned window, see :h wincmd
    nvim.command(win .. 'wincmd w')
  end
  return nvim.win_get_buf(0)
end

local function RunCommandAsync(command, commandArgs, stdinData, stdoutCallback, stderrCallback)
  local loop = vim.loop

  local function updateBuffer(streamName, bufferContent)
    local function callback(err, data)
      if data then
        table.insert(bufferContent, data)
      end
    end
    return callback
  end

  local stdin = nil
  if stdinData then
    stdin = loop.new_pipe(false)
  end
  local stdout = loop.new_pipe(false)
  local stdoutContent = {}
  local stderr = loop.new_pipe(false)
  local stderrContent = {}

  handle, pid = loop.spawn(command, {
    args = commandArgs,
    stdio = {stdin, stdout, stderr}
  }, vim.schedule_wrap(function(code, signal)
    stdout:read_stop()
    stdout:close()
    stderr:read_stop()
    stderr:close()
    handle:close()
    stdoutCallback(table.concat(stdoutContent))
    if #stderrContent > 0 then
      stderrCallback(table.concat(stderrContent))
    end
  end))

  if stdin then
    loop.write(stdin, stdinData)
    loop.shutdown(stdin, function()
      stdin:close()
    end)
  end
  -- if the process is not created, looks like pid is returned as a string
  if type(pid) == "string" then
    stdout:close()
    stderr:close()
    stderrCallback('failed executing ' .. command .. ': ' .. pid)
  else
    loop.read_start(stdout, updateBuffer('stdout', stdoutContent))
    loop.read_start(stderr, updateBuffer('stderr', stderrContent))
  end
end

local function DisplayCommandOutput(
  command, commandArgs, commandStdinData,
  bufferName, bufferCreationCommand, bufferFileType)

  local currentWin = nvim.get_current_win()
  local bufferOptions = {
    buftype = 'nofile',
    swapfile = false,
    filetype = bufferFileType
  }
  local bufferId = GetOrCreateBuffer(bufferName, bufferCreationCommand, bufferOptions)
  nvim.set_current_win(currentWin)

  local function bufferCallback(buffer)
    bufferContentLines = vim.split(buffer, "\n")
    nvim.buf_set_lines(bufferId, 0, -1, true, bufferContentLines)
  end
  RunCommandAsync(command, commandArgs, commandStdinData, bufferCallback, bufferCallback)

end

-- local nvim = require 'nvim'
local function GetCurrentFilePath()
  return nvim.buf_get_name(0)
end
-- DisplayCommandOutput('exec_in_pyenv', {'/home/mavish/hasura/graphql-engine/server/ws/relay_workbench.yaml'}, 'execute_nvim', 'botright vsp', {})
-- DisplayCommandOutput( 'ls', {'-la'}, nil, 'execute_nvim', 'botright vsp', 'sql')

return {
  GetBufferCandidates = GetBufferCandidates,
  DisplayCommandOutput = DisplayCommandOutput,
  GetCurrentFilePath = GetCurrentFilePath
}

