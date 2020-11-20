sfinv.register_page("vk_quests:quests", {
	title = "Quests",
	get = function(self, player, context)
		if not context then context = {} end
		-- Active quest count
		local aquest_count = #vk_quests.get_unfinished_quests(player)
		local formspec = ([[
			real_coordinates[true]
			label[3.5,0.5;Current quests in progress: %d]
			button[4.2,0.8;2,0.6;refresh;Refresh]
		]]):format(
			aquest_count
		)

		if aquest_count > 0 then
			formspec = formspec .. "textlist[0,1.6;10.5,4.1;quests;"

			for qid, questprog in pairs(vk_quests.get_unfinished_quests(player)) do
				local quest = vk_quests.get_quest(qid)

				formspec = ("%s\\[%d/%d\\] %s - %s,"):format(
					formspec,
					questprog.kills or 0,
					quest.amount,
					minetest.formspec_escape(quest.description),
					minetest.formspec_escape(quest.rewards_description)
				)
			end

			formspec = formspec:sub(1, -2) -- Remove trailing comma
			formspec = formspec .. ";0;true]"
		end

		return sfinv.make_formspec(player, context, formspec, true)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if fields.refresh then
			sfinv.set_page(player, "vk_quests:quests")
		end
	end
})
