// Converted everything related to vampires from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

/* 	/		/		/		/		/		/		Setup		/		/		/		/		/		/		/		/		*/
/mob/proc/make_vampiric_thrall()
	if (ishuman(src))
		var/datum/abilityHolder/vampire/thrall/A = src.get_ability_holder(/datum/abilityHolder/vampire/thrall)
		if (A && istype(A))
			return

		A = src.add_ability_holder(/datum/abilityHolder/vampire/thrall)

		A.addAbility(/datum/targetable/vampire/speak_thrall/thrall)
		A.addAbility(/datum/targetable/vampire/vampire_bite/thrall)


		A.transferOwnership(src)

		if (src.mind && src.mind.special_role != ROLE_OMNITRAITOR)
			SHOW_VAMPTHRALL_TIPS(src)

	else return


/* 	/		/		/		/		/		/		Ability Holder	/		/		/		/		/		/		/		/		*/

/datum/abilityHolder/vampire/thrall
	tabName = "Thrall"
	notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"

	var/datum/abilityHolder/vampire/master = 0

	onLife(var/mult = 1) //failsafe for UI not doing its update correctly elsewhere
		.= 0
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (istype(H.mutantrace, /datum/mutantrace/vampiric_thrall))

				if (points_last != points)
					points_last = points
					src.updateText(0, src.x_occupied, src.y_occupied)


	onAbilityStat() // In the 'Thrall' tab.
		.= list()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (istype(H.mutantrace, /datum/mutantrace/vampiric_thrall))
				var/datum/mutantrace/vampiric_thrall/V = H.mutantrace
				.["Blood:"] = V.blood_points
				.["Max HP:"] = H.max_health

	check_for_unlocks()
		return
