local mp = require 'mp'

local function has_en_sub()
  for _, t in ipairs(mp.get_property_native('track-list', {})) do
    if t.type == 'sub' and t.lang and t.lang:match('^en') then return true end
  end
  return false
end

mp.register_event('file-loaded', function()
  local path = mp.get_property('path')
  if not path or path:find('://') then return end           -- local files only
  if mp.get_property_number('duration', 0) < 300 then return end
  if has_en_sub() then return end                           -- embedded or already fetched

  mp.osd_message('Fetching English subs…', 3)
  mp.command_native_async({
    name = 'subprocess', args = { 'fetchsub', path },
    capture_stdout = true, playback_only = false,
  }, function(ok, res)
    if ok and res.status == 0 then
      local sub = res.stdout:gsub('%s+$', '')
      mp.commandv('sub-add', sub, 'select', 'en (synced)', 'en')
      mp.osd_message('Subs loaded', 2)
    else
      mp.osd_message('No English subs found', 2)
    end
  end)
end)
