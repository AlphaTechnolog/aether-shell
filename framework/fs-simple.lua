local oop = require("framework.oop")

local _fs = {}

-- checks if a given dirpath is a folder and exists or not
function _fs:folder_exists(dirpath)
  local ok, err, code = os.rename(dirpath, dirpath)
  if not ok then
    if code == 13 then
      -- permission denied but it exists
      return true
    end
  end
  return ok, err
end

-- just a wrapper for `folder_exists` which adds a leading `/`
function _fs:isdir(path)
  return self:folder_exists(path .. "/")
end

-- a wrapper for shell `mkdir` command
function _fs:mkdir(path)
  os.execute("mkdir " .. path)
end

-- creates a folder if it doesn't exists
function _fs:xmkdir(path)
  if not self:isdir(path) then
    self:mkdir(path)
  end
end

-- checks if a file exists or not
function _fs:isfile(path)
  local file = io.open(path, "r")

  if file ~= nil then
    file:close()
    return true
  end

  return false
end

-- creates a new file by using the shell `touch` command
function _fs:touch(path)
  os.execute("touch " .. path)
end

-- creates a file if it doesn't exists
function _fs:xtouch(path)
  if not self:isfile(path) then
    self:touch(path)
  end
end

-- reads a file and returns the content in a string
function _fs:read(path)
  if not self:isfile(path) then
    return nil
  end

  local file = io.open(path, "r")

  if not file then
    error("cannot open " .. path)
  end

  local content = file:read("*a")

  file:close()

  return content
end

return oop(_fs)
