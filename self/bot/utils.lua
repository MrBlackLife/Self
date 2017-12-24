local clock = os.clock
function sleep(time)  -- seconds
  local t0 = clock()
  while clock() - t0 <= time do end
end

function serialize_to_file(data, file, uglify)
  file = io.open(file, 'w+')
  local serialized
  if not uglify then
    serialized = serpent.block(data, {
        comment = false,
        name = '_'
      })
  else
    serialized = serpent.dump(data)
  end
  file:write(serialized)
  file:close()
end
function string.random(length)
   local str = "";
   for i = 1, length do
      math.random(97, 122)
      str = str..string.char(math.random(97, 122));
   end
   return str;
end

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function string.trim(s)
  print("string.trim(s) is DEPRECATED use string:trim() instead")
  return s:gsub("^%s*(.-)%s*$", "%1")
end

function string:trim()
  return self:gsub("^%s*(.-)%s*$", "%1")
end

function get_http_file_name(url, headers)
  local file_name = url:match("[^%w]+([%.%w]+)$")
  file_name = file_name or url:match("[^%w]+(%w+)[^%w]+$")
  file_name = file_name or str:random(5)

  local content_type = headers["content-type"]

  local extension = nil
  if content_type then
    extension = mimetype.get_mime_extension(content_type)
  end
  if extension then
    file_name = file_name.."."..extension
  end

  local disposition = headers["content-disposition"]
  if disposition then
    file_name = disposition:match('filename=([^;]+)') or file_name
  end

  return file_name
end

function download_to_file(url, file_name)
  print("url to download: "..url)

  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }

  local response = nil

  if url:starts('https') then
    options.redirect = false
    response = {https.request(options)}
  else
    response = {http.request(options)}
  end

  local code = response[2]
  local headers = response[3]
  local status = response[4]

  if code ~= 200 then return nil end

  file_name = file_name or get_http_file_name(url, headers)

  local file_path = "data/"..file_name
  print("Saved to: "..file_path)

  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()

  return file_path
end
function run_command(str)
  local cmd = io.popen(str)
  local result = cmd:read('*all')
  cmd:close()
  return result
end
function string:isempty()
  return self == nil or self == ''
end

function string:isblank()
  self = self:trim()
  return self:isempty()
end

function string.starts(String, Start)
  print("string.starts(String, Start) is DEPRECATED use string:starts(text) instead")
  return Start == string.sub(String,1,string.len(Start))
end

function string:starts(text)
  return text == string.sub(self,1,string.len(text))
end
function unescape_html(str)
  local map = {
    ["lt"]  = "<",
    ["gt"]  = ">",
    ["amp"] = "&",
    ["quot"] = '"',
    ["apos"] = "'"
  }
  new = string.gsub(str, '(&(#?x?)([%d%a]+);)', function(orig, n, s)
    var = map[s] or n == "#" and string.char(s)
    var = var or n == "#x" and string.char(tonumber(s,16))
    var = var or orig
    return var
  end)
  return new
end
function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  for filename in popen('ls -a "'..directory..'"'):lines() do
    i = i + 1
    t[i] = filename
  end
  return t
end

function plugins_names( )
  local files = {}
  for k, v in pairs(scandir("plugins")) do
    -- Ends with .lua
    if (v:match(".lua$")) then
      table.insert(files, v)
    end
  end
  return files
end

function file_exists(name)
  local f = io.open(name,"r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function gp_type(chat_id)
  local gp_type = "pv"
  local id = tostring(chat_id)
    if id:match("^-100") then
      gp_type = "channel"
    elseif id:match("-") then
      gp_type = "chat"
  end
  return gp_type
end

function is_reply(msg)
  local var = false
    if msg.reply_to_message_id_ ~= 0 then
      var = true
    end
  return var
end

function is_supergroup(msg)
  chat_id = tostring(msg.to.id)
  if chat_id:match('^-100') then
    if not msg.is_post_ then
    return true
    end
  else
    return false
  end
end

function is_channel(msg)
  chat_id = tostring(msg.to.id)
  if chat_id:match('^-100') then 
  if msg.is_post_ then 
    return true
  else
    return false
  end
  end
end

function is_group(msg)
  chat_id = tostring(msg.to.id)
  if chat_id:match('^-100') then
    return false
  elseif chat_id:match('^-') then
    return true
  else
    return false
  end
end

function is_private(msg)
  chat_id = tostring(msg.to.id)
  if chat_id:match('^-') then
    return false
  else
    return true
  end
end

function check_markdown(text)
		str = text
		if str:match('_') then
			output = str:gsub('_','\\_')
		elseif str:match('*') then
			output = str:gsub('*','\\*')
		elseif str:match('`') then
			output = str:gsub('`','\\`')
		else
			output = str
		end
	return output
end

function is_sudo(msg)
  local var = false
  -- Check users id in config
  for v,user in pairs(_config.sudo_users) do
    if user == msg.from.id then
      var = true
    end
  end
  return var
end

function is_owner(msg)
  local var = false
  local data = load_data(_config.moderation.data)
  local user = msg.from.id
  if data[tostring(msg.to.id)] then
    if data[tostring(msg.to.id)]['owners'] then
      if data[tostring(msg.to.id)]['owners'][tostring(msg.from.id)] then
        var = true
      end
    end
  end

  for v,user in pairs(_config.admins) do
    if user[1] == msg.from.id then
      var = true
  end
end

  for v,user in pairs(_config.sudo_users) do
    if user == msg.from.id then
        var = true
    end
  end
  return var
end

function is_admin(msg)
  local var = false
  local user = msg.from.id
  for v,user in pairs(_config.admins) do
    if user[1] == msg.from.id then
      var = true
  end
end

  for v,user in pairs(_config.sudo_users) do
    if user == msg.from.id then
        var = true
    end
  end
  return var
end

--Check if user is the mod of that group or not
function is_mod(msg)
  local var = false
  local data = load_data(_config.moderation.data)
  local usert = msg.from.id
  if data[tostring(msg.to.id)] then
    if data[tostring(msg.to.id)]['mods'] then
      if data[tostring(msg.to.id)]['mods'][tostring(msg.from.id)] then
        var = true
      end
    end
  end

  if data[tostring(msg.to.id)] then
    if data[tostring(msg.to.id)]['owners'] then
      if data[tostring(msg.to.id)]['owners'][tostring(msg.from.id)] then
        var = true
      end
    end
  end

  for v,user in pairs(_config.admins) do
    if user[1] == msg.from.id then
      var = true
  end
end

  for v,user in pairs(_config.sudo_users) do
    if user == msg.from.id then
        var = true
    end
  end
  return var
end

function is_sudo1(user_id)
  local var = false
  -- Check users id in config
  for v,user in pairs(_config.sudo_users) do
    if user == user_id then
      var = true
    end
  end
  return var
end

function is_owner1(chat_id, user_id)
  local var = false
  local data = load_data(_config.moderation.data)
  local user = user_id
  if data[tostring(chat_id)] then
    if data[tostring(chat_id)]['owners'] then
      if data[tostring(chat_id)]['owners'][tostring(user)] then
        var = true
      end
    end
  end

  for v,user in pairs(_config.admins) do
    if user[1] == user_id then
      var = true
  end
end

  for v,user in pairs(_config.sudo_users) do
    if user == user_id then
        var = true
    end
  end
  return var
end

function is_admin1(user_id)
  local var = false
  local user = user_id
  for v,user in pairs(_config.admins) do
    if user[1] == user_id then
      var = true
  end
end

  for v,user in pairs(_config.sudo_users) do
    if user == user_id then
        var = true
    end
  end
  return var
end

--Check if user is the mod of that group or not
function is_mod1(chat_id, user_id)
  local var = false
  local data = load_data(_config.moderation.data)
  local usert = user_id
  if data[tostring(chat_id)] then
    if data[tostring(chat_id)]['mods'] then
      if data[tostring(chat_id)]['mods'][tostring(usert)] then
        var = true
      end
    end
  end

  if data[tostring(chat_id)] then
    if data[tostring(chat_id)]['owners'] then
      if data[tostring(chat_id)]['owners'][tostring(usert)] then
        var = true
      end
    end
  end

  for v,user in pairs(_config.admins) do
    if user[1] == user_id then
      var = true
  end
end

  for v,user in pairs(_config.sudo_users) do
    if user == user_id then
        var = true
    end
  end
  return var
end

function warns_user_not_allowed(plugin, msg)
  if not user_allowed(plugin, msg) then
    local text = '*This plugin requires privileged user*'
    local receiver = msg.chat_id_
             tdcli.sendMessage(msg.chat_id_, "", 0, result, 0, "md")
    return true
  else
    return false
  end
end

-- Check if user can use the plugin
function user_allowed(plugin, msg)
  if plugin.privileged and not is_sudo(msg) then
    return false
  end
  return true
end

function kick_user(user_id, chat_id)
if not tonumber(user_id) then
return false
end
  tdcli.changeChatMemberStatus(chat_id, user_id, 'Kicked', dl_cb, nil)
end

function del_msg(chat_id, message_ids)
local msgid = {[0] = message_ids}
  tdcli.deleteMessages(chat_id, msgid, dl_cb, nil)
end

function invite_user(user_id, chat_id)
if not tonumber(user_id) then
return false
end
  tdcli.addChatMember(chat_id, user_id, 100, dl_cb, nil)
end

function file_dl(file_id)
	tdcli.downloadFile(file_id, dl_cb, nil)
end

