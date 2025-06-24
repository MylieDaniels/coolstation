/datum/targetable/vampire/speak_thrall/thrall
	name = "Speak"
	desc = "Telepathically speak to your master and your fellow ghouls."
	unlock_message = ""

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/thrall/H = holder

		if (!H.master)
			boutput(M, __red("Your link to your master has been severed!"))
			return 1

		return ..()

/datum/targetable/vampire/vampire_bite/thrall
	thrall = 1
