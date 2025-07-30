/obj/item/artifact_staff
	name = "strange staff"
	desc = "A peculiar staff."
	icon = 'icons/obj/wizard.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "staff"
	item_state = "staff"
	force = 6
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | NOSHIELD
	object_flags = NO_ARM_ATTACH
	var/list/datum/artifact_staff_toll/tolls = list()
	var/list/datum/artifact_staff_effect/effects = list()

	New()
		. = ..()
		var/toll_type = pick(artifact_controls.artifact_staff_toll_types)
		var/effect_type = pick(artifact_controls.artifact_staff_effect_types)
		src.tolls.Add(new toll_type(src))
		src.effects.Add(new effect_type(src))
		RegisterSignal(src, COMSIG_ITEM_ATTACK_POST, PROC_REF(melee_effects))

	proc/add_toll()
		var/toll_type = pick(artifact_controls.artifact_staff_toll_types)
		src.tolls.Add(new toll_type(src))

	proc/add_effect()
		var/effect_type = pick(artifact_controls.artifact_staff_effect_types)
		src.effects.Add(new effect_type(src))

	proc/melee_effects(var/obj/item/staff_hopefully, var/mob/target, var/mob/user, var/force)
		if(!GET_COOLDOWN(src, "artifact_staff_delay"))
			for(var/datum/artifact_staff_toll/toll in src.tolls)
				toll.melee_toll(user, target, src)
			var/highest_delay = 0
			for(var/datum/artifact_staff_effect/effect in src.effects)
				effect.melee_effect(user, target, src)
				highest_delay = max(highest_delay, effect.melee_delay)
			if(highest_delay)
				ON_COOLDOWN(src, "artifact_staff_delay", highest_delay)
				SPAWN_DBG(highest_delay)
					if(iswizard(src.loc))
						var/mob/M = src.loc
						boutput(M, "\The [src] recharges!")

	on_spin_emote(mob/living/carbon/human/user)
		. = ..()
		if(!GET_COOLDOWN(src, "artifact_staff_delay"))
			for(var/datum/artifact_staff_toll/toll in src.tolls)
				toll.twirl_toll(user, src)
			var/highest_delay = 0
			for(var/datum/artifact_staff_effect/effect in src.effects)
				effect.twirl_effect(user, src)
				highest_delay = max(highest_delay, effect.twirl_delay)
			if(highest_delay)
				ON_COOLDOWN(src, "artifact_staff_delay", highest_delay)
				if(iswizard(src.loc))
					var/mob/M = src.loc
					boutput(M, "\The [src] recharges!")

	pixelaction(atom/target, params, mob/user, reach)
		if (reach)
			return 0
		if (!isturf(user.loc))
			return 0

		var/pox = text2num(params["icon-x"]) - 16
		var/poy = text2num(params["icon-y"]) - 16
		var/turf/user_turf = get_turf(user)
		var/turf/target_turf = get_turf(target)

		if(!GET_COOLDOWN(src, "artifact_staff_delay"))
			user.visible_message(SPAN_COMBAT("[user] points \the [src] at [target]!"), SPAN_COMBAT("You point \the [src] at [target]!"))
			for(var/datum/artifact_staff_toll/toll in src.tolls)
				toll.ranged_toll(user, target, src)
			var/highest_delay = 0
			for(var/datum/artifact_staff_effect/effect in src.effects)
				effect.ranged_effect(target_turf, user_turf, user, pox, poy, target, src)
				highest_delay = max(highest_delay, effect.ranged_delay)
			if(highest_delay)
				ON_COOLDOWN(src, "artifact_staff_delay", highest_delay)
				if(iswizard(src.loc))
					var/mob/M = src.loc
					boutput(M, "\The [src] recharges!")
		return 1

ABSTRACT_TYPE(/datum/artifact_staff_toll/)
/datum/artifact_staff_toll
	/// the staff that owns it
	var/obj/staff
	/// name this so its easier to keep track of
	var/name = "abstract staff toll"
	/// how severe this toll is
	var/scale = 1
	/// how much worse does it get with each use (multiplicative, dont set below one pls)
	var/progression = 1.01

	New(var/obj/staff)
		. = ..()
		src.staff = staff

	proc/twirl_toll(var/mob/user, var/atom/staff)
		src.scale = src.scale * src.progression
		return 1

	proc/melee_toll(var/mob/user, var/atom/target, var/atom/staff)
		src.scale = src.scale * src.progression
		return 1

	proc/ranged_toll(var/mob/user, var/atom/target, var/atom/staff)
		src.scale = src.scale * src.progression
		return 1

/datum/artifact_staff_toll/vampiric
	name = "vampiric"

	twirl_toll(mob/user, atom/staff)
		if(isliving(user))
			var/mob/living/L = user
			if(L.can_bleed)
				var/bleed_amount = (src.scale ** 2) * L.blood_volume * 0.005 // 2.5 units * 16 = 40 bleed
				for(var/dir in cardinal)
					blood_slash(user, bleed_amount, direction = dir)
				return ..()
		random_brute_damage(user, src.scale * 15)
		return ..()

	melee_toll(mob/user, atom/target, atom/staff)
		if(isliving(user))
			var/mob/living/L = user
			if(L.can_bleed)
				take_bleeding_damage(L, L, src.scale * L.blood_volume * 0.01 + rand(0, 3)) // 5 to 8 bleed for a healthy human
				transfer_blood(L, target, src.scale * L.blood_volume * 0.04 + rand(0, 5)) // and 20 to 25 blood transfer
		return ..()

	ranged_toll(mob/user, atom/target, atom/staff)
		if(isliving(user))
			var/mob/living/L = user
			if(L.can_bleed)
				take_bleeding_damage(L, L, (src.scale ** 2) * L.blood_volume * 0.07) // 35 bleed for a full health human
				return ..()
		random_brute_damage(user, src.scale * 10)
		return ..()

ABSTRACT_TYPE(/datum/artifact_staff_effect/)
/datum/artifact_staff_effect
	/// the staff that owns it
	var/obj/staff
	/// name this so its easier to keep track of
	var/name = "abstract staff effect"
	/// how powerful this effect is
	var/power = 1
	/// how long before its usable again after a twirl
	var/twirl_delay = 10 SECONDS
	/// how long before its usable again after a melee use
	var/melee_delay= 10 SECONDS
	/// how long before its usable again after a ranged use
	var/ranged_delay = 10 SECONDS

	New(var/obj/staff)
		. = ..()
		src.staff = staff

	proc/twirl_effect(var/mob/user, var/atom/staff)
		return 1

	proc/melee_effect(var/mob/user, var/atom/target, var/atom/staff)
		return 1

	proc/ranged_effect(var/turf/target_turf, var/turf/user_turf, var/mob/user, var/pox, var/poy, var/atom/target, var/atom/staff)
		return 1

/datum/artifact_staff_effect/smoke
	name = "smoke"
	twirl_delay = 15 SECONDS
	ranged_delay = 20 SECONDS
	melee_delay = 3 SECONDS
	var/datum/effects/system/bad_smoke_spread/smoke

	New(var/obj/staff)
		. = ..()
		src.smoke = new /datum/effects/system/bad_smoke_spread
		src.smoke.attach(src.staff)
		src.smoke.set_up(5, 0, src.staff.loc)

	twirl_effect(mob/user, atom/target, atom/staff)
		. = ..()
		playsound(src.staff.loc, "sound/effects/smoke.ogg", 50, 1, -3)
		SPAWN_DBG(0)
			if (src.staff)
				src.smoke.start()
				sleep(0.2 SECONDS)
				src.smoke.start()
				sleep(0.4 SECONDS)
				src.smoke.start()

	melee_effect(mob/user, atom/target, atom/staff)
		. = ..()
		var/obj/effects/bad_smoke/target_smoke = new(get_turf(target))
		SPAWN_DBG(5 SECONDS)
			qdel(target_smoke)

	ranged_effect(turf/target_turf, turf/user_turf, mob/user, pox, poy, atom/target, atom/staff)
		. = ..()
		if (target_turf in view(8,user_turf))
			playsound(target_turf, "sound/effects/smoke.ogg", 50, 1, -3)
			var/datum/effects/system/bad_smoke_spread/target_smoke = new /datum/effects/system/bad_smoke_spread
			target_smoke.attach(target_turf)
			target_smoke.set_up(6, 0, target_turf)
			target_smoke.start()
			SPAWN_DBG(5 SECONDS)
				qdel(target_smoke)

ABSTRACT_TYPE(/datum/artifact_staff_effect/shoot)
/datum/artifact_staff_effect/shoot
	name = "shoot"
	var/datum/projectile/projectile
	var/spread = 0

	New()
		. = ..()

	twirl_effect(mob/user, atom/staff)
		. = ..()

	melee_effect(mob/user, atom/target, atom/staff)
		. = ..()

	ranged_effect(turf/target_turf, turf/user_turf, mob/user, pox, poy, atom/target, atom/staff)
		shoot_projectile_ST_pixel_spread(user, src.projectile, target_turf, pox, poy, src.spread)
		. = ..()

/datum/artifact_staff_effect/shoot/buckshot
	name = "buckshot"
	spread = 20

	New()
		. = ..()
		src.projectile = new/datum/projectile/special/spreader/buckshot_burst/artifact

	ranged_effect(turf/target_turf, turf/user_turf, mob/user, pox, poy, atom/target, atom/staff)
		if(istype(src.projectile, /datum/projectile/special/spreader/buckshot_burst/artifact))
			var/datum/projectile/special/spreader/buckshot_burst/artifact/art_proj = src.projectile
			art_proj.pellets_to_fire = ceil(8 + power * 5 + prob(power * 20))
			art_proj.spread_angle_variance = initial(art_proj.spread_angle_variance)
		. = ..()


/datum/projectile/special/spreader/buckshot_burst/artifact
	name = "mystical blast"
	sname = "mystical blast"
	cost = 1
	pellets_to_fire = 12
	power = 100
	spread_projectile_type = /datum/projectile/artifact_pellet
	shot_sound = 'sound/voice/wizard/FireballGrim.ogg'
	speed_max = 48
	speed_min = 18
	spread_angle_variance = 5
	dissipation_variance = 32

	split(var/obj/projectile/P)
		var/turf/PT = get_turf(P)
		var/pellets = pellets_to_fire
		while (pellets > 0)
			var/datum/projectile/F = new spread_projectile_type()
			F.shot_volume = pellet_shot_volume //optional anti-ear destruction
			pellets--
			new_pellet(P,PT,F)
		P.die()

/datum/projectile/artifact_pellet
	name = "magic pellet"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "u_laser"
	shot_volume = 60
	shot_number = 1
	damage_type = D_PIERCING
	hit_ground_chance = 90
	window_pass = 0

	New()
		..()
		src.randomise()

	proc/randomise()
		icon_state = pick("spark","laser","ibeam","u_laser","phaser_heavy","phaser_light","phaser_med","phaser_ultra","blue_spark","disrupt","disrupt_lethal","radbolt","crescent",
		"goo","40mmgatling","elecorb","purple_orb","triple")
		src.shot_sound = pick('sound/weapons/Taser.ogg','sound/weapons/flaregun.ogg','sound/weapons/Laser.ogg','sound/weapons/laserheavy.ogg','sound/weapons/laserlight.ogg','sound/weapons/lasermed.ogg','sound/weapons/laserultra.ogg','sound/weapons/grenade.ogg','sound/weapons/rocket.ogg','sound/weapons/snipershot.ogg','sound/weapons/TaserOLD.ogg','sound/weapons/ACgun1.ogg','sound/weapons/ACgun2.ogg')
		// Now randomise the damage type, power, and such

		src.damage_type = pick(D_KINETIC,D_PIERCING,D_SLASHING,D_ENERGY,D_BURNING,D_RADIOACTIVE,D_TOXIC)
		src.power = rand(20,30)
		src.dissipation_rate = power * 10 / rand(20, 50)
		src.dissipation_delay = rand(2,4)
		src.ks_ratio = rand(0, 500) / 1000 + 0.5
		src.hit_ground_chance = rand(40,60)

		if (prob(40))
			src.window_pass = 1

	on_pre_hit(atom/hit, angle, obj/projectile/O)
		if(ismob(hit))
			// if youve been hit by two in the past 0.8 seconds, you have an 90% chance to dodge it. softens point blanking
			if(ON_COOLDOWN(hit, "artifact_buckshot_immunity1", 0.8 SECONDS) && ON_COOLDOWN(hit, "artifact_buckshot_immunity2", 0.8 SECONDS) && prob(90))
				return TRUE
		return ..()

	on_hit(atom/hit, direction, obj/projectile/P)
		// for some reason, an object (like this projectile) that moves into a turf
		// in the same tick as it bumped a mob in a different/prior turf (like this one can)
		// will collide with the turf it moved into regardless of density in the BYOND native Move()
		// im. not happy about this. but. ill just check density here.
		if(!ismob(hit) && hit.density && prob(40))
			if (!shoot_reflected_bounce(P, hit, 2, PROJ_RAPID_HEADON_BOUNCE))
				on_max_range_die(P)
		..()


