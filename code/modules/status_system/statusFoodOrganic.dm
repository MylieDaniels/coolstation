/datum/statusEffect/foodOrganic
	id = "organic_base"
	name = "Base Organic Buff (YOU SHOULD NOT SEE ME)"
	desc = "Organic food buff. Tell a coder if you see this!"
	icon_state = "foodbuff"
	exclusiveGroup = "Organic"
	maxDuration = 10 MINUTES
	unique = 1

/datum/statusEffect/foodOrganic/ability
	id = "organic_ability_base"
	name = "Base Organic Ability Buff (YOU SHOULD NOT SEE ME)"
	var/ability_type = /datum/targetable/organic
	var/datum/targetable/associated_ability

	onAdd()
		if (ismob(owner))
			var/mob/M = owner
			var/datum/abilityHolder/organic/A = M.get_ability_holder(/datum/abilityHolder/organic)
			if (A && istype(A))
				return
			A = M.add_ability_holder(/datum/abilityHolder/organic)
			src.associated_ability = A.addAbility(src.ability_type)
		..()

	onRemove()
		if (src.associated_ability)
			var/datum/abilityHolder/holder = src.associated_ability.holder
			holder.removeAbilityInstance(src.associated_ability)
		..()

/datum/statusEffect/foodOrganic/ability/watermelon
	id = "organic_watermelon"
	name = "Seed Reserves"
	desc = "Use the Spit Seed ability to fire a watermelon seed, reducing this buff's duration by 50 seconds!"
	ability_type = /datum/targetable/organic/watermelon

// THE ABILITIES, FOR NOW

/datum/abilityHolder/organic
	usesPoints = 0
	regenRate = 0
	tabName = "Organic Ability"

/datum/targetable/organic
	preferred_holder_type = /datum/abilityHolder/organic

/datum/targetable/organic/watermelon
	name = "Spit Seed"
	desc = "Spit a high velocity watermelon seed, a potentially possibly slightly hazardous projectile."
	cooldown = 5
	targeted = 1
	target_anything = 1
	max_range = 50
	var/datum/projectile/proj = new /datum/projectile/special/watermelon_seed
	var/duration_change = -50 SECONDS

	tryCast(atom/target, params)
		var/turf/T = get_turf(src.holder.owner)
		if (!T || T == get_turf(target))
			return 998
		..()

	cast(atom/target, params)
		if(ismob(src.holder.owner))
			var/mob/M = src.holder.owner
			var/pixel_offset_x = 0
			var/pixel_offset_y = 0
			if (islist(params))
				if(params["icon-x"])
					pixel_offset_x = text2num(params["icon-x"])
				if(params["icon-y"])
					pixel_offset_x = text2num(params["icon-y"])

			var/obj/projectile/P = shoot_projectile_ST_pixel(M, src.proj, target, pixel_offset_x, pixel_offset_y)
			if (!P)
				return
			M.visible_message("<span class='alert'>[M] spits a [P.name] at [target]!</span>","<span class='alert'>You spit a [P.name] at [target]!</span>", group = "spit_seed_\ref[M]")
			if(duration_change)
				M.changeStatus("organic_watermelon", src.duration_change)
			return
