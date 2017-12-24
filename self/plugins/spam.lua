local function run(msg)
if msg.text:match("([Ss][Pp][Aa][Mm])(.*)") and is_sudo(msg) then
for i=1,msg.text:match("(%d+)") do
tdcli_function({
						ID = "ForwardMessages",
						chat_id_ = msg.chat_id_,
						from_chat_id_ = msg.chat_id_,
						message_ids_ = {[0] = msg.id_},
						disable_notification_ = 0,
						from_background_ = 1
					}, dl_cb, nil)
end
end
end
 
return {
  patterns = {
   "^[>#<$](.*)$"
  },
  run = run
}

-- Coded by @MahDiRoO
-- Channel @MaTaDoRTeaM
