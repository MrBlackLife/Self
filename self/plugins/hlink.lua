local function run(msg, matches)
local chat = msg.chat_id_
local data = load_data(_config.moderation.data)
local hash = data[tostring(chat)]['settings']['linkgp']
local tex = "[link]("..hash..")"

	local hlink = function(arg, data)
	 tdcli_function({ID = "SendInlineQueryResultMessage",chat_id_ = msg.chat_id_,reply_to_message_id_ = msg.id_,disable_notification_ = 0,from_background_ = 1,query_id_ = data.inline_query_id_,result_id_ = data.results_[0].id_}, dl_cb, nil)
	end
	 tdcli_function({ID = "GetInlineQueryResults",bot_user_id_ = 107705060,chat_id_ = msg.chat_id_,user_location_ = {ID = "Location",latitude_ = 0,longitude_ = 0},query_ = tex,offset_ = 0}, hlink, nil)
end
return {
  patterns = {
    "^[#!/](hlink)$"
  },
patterns_fa = {
"^(هایپر لینک)$"
},
  run = run
}



--   #copyright special team 2016
-- #plugin by amirspecial 
