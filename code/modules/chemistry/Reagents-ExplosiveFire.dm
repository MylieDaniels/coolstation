//Contains Fire / Explosion / Implosion related reagents.

ABSTRACT_TYPE(/datum/reagent/combustible)

datum
	reagent
		combustible/
			name = "fire stuff"

		combustible/phlogiston //This is used for the smoke/phlogiston reaction.
			name = "phlogiston"
			id = "phlogiston"
			description = "It appears to be liquid fire."
			reagent_state = LIQUID
			fluid_r = 250
			fluid_b = 0
			fluid_g = 175
			volatility = 2
			transparency = 175
			hygiene_value = 1 // with purging fire
			viscosity = 0.7
			flammable_influence = TRUE
			combusts_on_fire_contact = TRUE
			burn_speed = 2
			burn_energy = 1100000
			burn_temperature = 2500
			burn_volatility = 10
			minimum_reaction_temperature = T0C - 50
			var/mob_burning = 33

			reaction_turf(var/turf/T, var/volume)
				. = ..()
				if (holder && holder.total_temperature >= minimum_reaction_temperature)
					holder.start_combusting()

			reaction_temperature(exposed_temperature, exposed_volume)
				. = ..()
				if(holder && !holder.is_combusting && istype(holder,/datum/reagents/fluid_group))
					holder.start_combusting()

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				. = ..()
				if (!holder) //Wire: Fix for Cannot read null.total_temperature
					return
				if(holder.total_temperature <= T0C - 50) return
				var/MB = mob_burning
				var/mob/living/L = M
				if(istype(L))
					L.update_burning(MB)
				if (method == INGEST)
					M.TakeDamage("All", 0, min(max(10, volume_passed * 2), 45), 0, DAMAGE_BURN)
					boutput(M, "<span class='alert'>It burns!</span>")
					M.emote("scream")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!holder) //Wire: Fix for Cannot read null.total_temperature
					return
				if(holder.total_temperature <= T0C - 50) return
				holder.start_combusting()
				if(!M) M = holder.my_atom
				var/mob/living/L = M
				if(istype(L))
					L.update_burning(2 * mult)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("fire",8)
				P.growth -= 12

		combustible/phlogiston/firedust
			name = "phlogiston dust"
			id = "firedust"
			description = "And this is solid fire. However that works."
			dispersal = 4
			transparency = 255
			mob_burning = 15
			burn_speed = 1.5
			burn_energy = 900000
			burn_temperature = 1500
			burn_volatility = 6
			minimum_reaction_temperature = T0C

		combustible/napalm_goo  // adapated from weldfuel
			name = "napalm goo"
			id = "napalm_goo"
			description = "A highly flammable jellied fuel."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_b = 50
			fluid_g = 100
			transparency = 150
			viscosity = 0.8
			flammable_influence = TRUE
			combusts_on_fire_contact = TRUE
			burn_speed = 0.35
			burn_energy = 600000
			burn_temperature = 1200
			burn_volatility = 2
			minimum_reaction_temperature = T0C + 100
			var/temp_reacted = 0
			penetrates_skin = 1

			reaction_temperature(exposed_temperature, exposed_volume)
				. = ..()
				if(holder && !holder.is_combusting)
					holder.start_combusting()

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == TOUCH)
					var/mob/living/L = M
					var/datum/statusEffect/simpledot/burning/burn = L.hasStatus("burning")
					if(istype(L) && burn)
						if(!M.stat && !ON_COOLDOWN(M, "napalm_damage", 1 SECOND))
							L.TakeDamage("All", 0, (1 - L.get_heat_protection()/100) * clamp(2 * volume * (burn.getStage()-1.25), 0, 25), 0, DAMAGE_BURN)
					return 0
				return 1

			on_mob_life(var/mob/M, var/mult = 1)
				var/mob/living/L = M
				var/datum/statusEffect/simpledot/burning/burn = L.hasStatus("burning")
				if(istype(L))
					if(!burn && src.holder.is_combusting)
						burn = L.changeStatus("burning", 2 SECONDS)
					if(burn)
						L.changeStatus("burning", src.volume / 2 SECONDS)
						burn.counter += src.volume / 2
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("poison",1)

			syndicate
				name = "syndicate napalm"
				id = "syndicate_napalm"
				description = "Extra sticky, extra burny"
				burn_speed = 0.25
				burn_energy = 690000
				burn_temperature = 1800
				burn_volatility = 3

				reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
					. = ..()
					if(method == TOUCH)
						var/mob/living/L = M
						var/datum/statusEffect/simpledot/burning/burn = L.hasStatus("burning")
						L.changeStatus("slowed", 2 SECONDS, optional = 4)
						if(istype(L) && burn) //double up on the extra burny, not blockable by biosuits/etc either
							L.changeStatus("burning", src.volume SECONDS)
							burn.counter += 5 * src.volume

		combustible/kerosene
			name = "kerosene"
			id = "kerosene"
			description = "A substance widely applied as fuel for aviation vehicles and solvent for metal alloys (when heated)."
			reagent_state = LIQUID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 255
			viscosity = 0.4
			volatility = 2
			flammable_influence = TRUE
			combusts_on_fire_contact = TRUE
			burn_speed = 0.5
			burn_energy = 875000
			burn_temperature = 5000
			burn_volatility = 14
			minimum_reaction_temperature = T0C+600

			reaction_temperature(exposed_temperature, exposed_volume)
				. = ..()
				if(holder && !holder.is_combusting)
					holder.start_combusting()

			reaction_obj(var/obj/O, var/volume)
				if (!holder)
					return
				if (volume >= 5 && holder.total_temperature >= T0C + 400 && (istype(O, /obj/steel_beams) || (O.material && O.material.mat_id == "steel")))
					O.visible_message("<span class='alert'>[O] melts!</span>")
					qdel(O)

			reaction_turf(var/turf/T, var/volume)
				if (!holder)
					return
				if (!istype(T) || volume < 5 || holder.total_temperature < T0C + 400)
					return
				for (var/obj/steel_beams/O in T)
					O.visible_message(SPAN_ALERT("[O] melts!"))
					qdel(O)
				if (T.material && T.material.mat_id == "steel")
					//T.visible_message("<span class='alert'>[T] melts!</span>")
					T.ex_act(OLD_EX_HEAVY)
				. = ..()
				holder.start_combusting()

		combustible/thermite
			name = "thermite"
			id = "thermite"
			description = "Thermite burns at an incredibly high temperature. Can be used to melt walls."
			reagent_state = SOLID
			fluid_r = 85
			fluid_g = 0
			fluid_b = 0
			transparency = 255
			volatility = 1.5
			minimum_reaction_temperature = T0C+100

			reaction_temperature(exposed_temperature, exposed_volume)
				var/turf/A = holder.my_atom
				if(!istype(A)) return

				if(holder.get_reagent_amount(id) >= 15) //no more thermiting walls with 1u tyvm
					var/id = src.id
					var/datum/reagents/holder = src.holder
					var/volume
					holder.del_reagent(id)
					fireflash_sm(A, 0, rand(20000, 25000) + volume * 2500, 0, 0, 1) // Bypasses the RNG roll to melt walls (Convair880).

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == TOUCH)
					var/mob/living/L = M
					if(istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", 10 SECONDS)
				return

			reaction_turf(var/turf/T, var/volume)
				if(issimulatedturf(T))
					var/list/covered = holder.covered_turf()
					if(length(covered) > 9)
						volume = volume/length(covered)
					if (volume < 3)
						return
					if(!T.reagents)
						T.create_reagents(volume)
					else
						T.reagents.maximum_volume = T.reagents.maximum_volume + volume

					if(!T.reagents.has_reagent("thermite"))
						T.UpdateOverlays(image('icons/effects/effects.dmi',icon_state = "thermite"), "thermite")

					T.reagents.add_reagent("thermite", volume, null)
					if (T.active_hotspot)
						T.reagents.temperature_reagents(T.active_hotspot.temperature, T.active_hotspot.volume, 350, 300, 1)
				return


		combustible/smokepowder
			name = "smoke powder"
			id = "smokepowder"
			description = "Produces smoke when heated."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 230
			minimum_reaction_temperature = T0C+25
			evaporates_cleanly = TRUE
			var/ignited = 0
/*
			pooled()
				..()
				ignited = 0
*/
			reaction_temperature(exposed_temperature, exposed_volume)
				var/datum/reagents/myholder = holder
				if(!istype(holder,/datum/reagents/fluid_group) && !holder?.my_atom?.is_open_container())
					if(holder.my_atom)
						for(var/mob/M in AIviewers(5, get_turf(holder.my_atom)))
							boutput(M, "<span class='notice'>With nowhere to go, the smoke settles.</span>")
				else if(!ignited)
					ignited = 1
					var/vol = volume
					SPAWN_DBG(1 DECI SECOND)
						myholder.smoke_start(vol) //moved to a proc in Chemistry-Holder.dm so that the instant reaction and powder can use the same proc
				myholder.del_reagent(id)

		combustible/propellant
			name = "aerosol propellant"
			id = "propellant"
			description = "Produces a aerosol spray when heated."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 255
			transparency = 230
			minimum_reaction_temperature = T0C + 100
			evaporates_cleanly = TRUE
			var/ignited = FALSE
/*
			pooled()
				..()
				ignited = FALSE
*/
			reaction_temperature(exposed_temperature, exposed_volume)
				var/datum/reagents/myholder = holder
				if(!holder?.my_atom?.is_open_container())
					if(holder.my_atom)
						for(var/mob/M in AIviewers(5, get_turf(holder.my_atom)))
							boutput(M, "<span class='notice'>With nowhere to go, the smoke settles.</span>")
				else if(!ignited)
					ignited = TRUE
					var/vol = volume
					SPAWN_DBG(1 DECI SECOND)
						myholder.smoke_start(vol,classic = 1) //moved to a proc in Chemistry-Holder.dm so that the instant reaction and powder can use the same proc
				myholder.del_reagent(id)

		combustible/sonicpowder
			name = "hootingium"
			id = "sonicpowder"
			description = "Produces a loud bang when heated."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 230
			penetrates_skin = 1 // coat them with it?
			minimum_reaction_temperature = T0C+100
			var/no_fluff = 0

			reaction_temperature(exposed_temperature, exposed_volume)
				if(!reacting)
					reacting = 1
					var/list/covered = holder.covered_turf()
					var/location = covered.len ? covered[1] : 0
					var/hootmode = prob(5)

					if (src.no_fluff == 0)
						if (hootmode)
							playsound(location, "sound/voice/animal/hoot.ogg", 100, 1)
						else
							playsound(location, "sound/weapons/flashbang.ogg", 25, 1)

					for (var/mob/living/M in all_hearers(world.view, location))
						if (issilicon(M) || isintangible(M))
							continue

						if (src.no_fluff == 0)
							if (!M.ears_protected_from_sound())
								boutput(M, "<span class='alert'><b>[hootmode ? "HOOT" : "BANG"]</b></span>")
							else
								continue

						var/checkdist = get_dist(M, location)
						var/weak = max(0, holder.get_reagent_amount(id) * 0.2 * (3 - checkdist))
						var/misstep = clamp(1 + 6 * (5 - checkdist), 0, 40)
						var/ear_damage = max(0, holder.get_reagent_amount(id) * 0.2 * (3 - checkdist))
						var/ear_tempdeaf = max(0, holder.get_reagent_amount(id) * 0.2 * (5 - checkdist)) //annoying and unfun so reduced dramatically
						var/stamina = clamp(holder.get_reagent_amount(id) * (5 + 1 * (7 - checkdist)), 0, 120)

						M.apply_sonic_stun(weak, 0, misstep, 0, 0, ear_damage, ear_tempdeaf, stamina)

					for (var/mob/living/silicon/S in all_hearers(world.view, location))
						if (src.no_fluff == 0)
							if (!S.ears_protected_from_sound())
								boutput(S, "<span class='alert'><b>[hootmode ? "HOOT" : "BANG"]</b></span>")
							else
								continue

						var/checkdist = get_dist(S, location)
						var/C_weak = max(0, holder.get_reagent_amount(id) * 0.2 * (3 - checkdist))

						S.apply_sonic_stun(C_weak, 0)

				holder?.del_reagent(id)

			on_mob_life(var/mob/M, var/mult = 1) // fuck you jerk chemists (todo: a thing to self-harm borgs too, maybe ex_act(OLD_EX_LIGHT) to the holder? I D K
				if(!M) M = holder.my_atom
				if(prob(70))
					M.take_brain_damage(1 * mult)
				..()
				return

		combustible/sonicpowder/nofluff
			name = "hootingium"
			id = "sonicpowder_nofluff"
			no_fluff = 1

// Don't forget to update Reagents-Recipes.dm too, we have duplicate code for sonic and flash powder there (Convair880).

		combustible/flashpowder
			name = "flash powder"
			id = "flashpowder"
			description = "Produces a bright flash of light when heated."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 230
			penetrates_skin = 1 // coat them with it?
			viscosity = 0.5
			minimum_reaction_temperature = T0C+100

			reaction_temperature(exposed_temperature, exposed_volume)
				if(!reacting)
					reacting = 1
					var/list/covered = holder.covered_turf()
					var/location = covered.len ? covered[1] : 0
					flashpowder_reaction(location, holder.get_reagent_amount(id))
				holder?.del_reagent(id)

		combustible/infernite // COGWERKS CHEM REVISION PROJECT. this could be Chlorine Triflouride, a really mean thing
			name = "chlorine triflouride"
			id = "infernite"
			description = "An extremely volatile substance, handle with the utmost care."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 200
			fluid_b = 200
			volatility = 2
			transparency = 175
			depletion_rate = 4
			dispersal = 2
			hygiene_value = 2 // with purging fire
			viscosity = 0.5
			flammable_influence = TRUE
			burn_speed = 3
			burn_energy = 0 // not a fuel, its an oxidizer
			burn_temperature = 3500
			burn_volatility = 14

			reaction_turf(var/turf/T, var/volume)
				var/datum/reagents/old_holder = src.holder //mbc pls, ZeWaka fix: null.holder
				//if(!T.reagents) T.create_reagents(50)
				//T.reagents.add_reagent("infernite", 5, null)
				var/list/covered = old_holder.covered_turf()
				if(length(covered) > 9)
					volume = volume/length(covered)
				if (volume < 3)
					return

				var/fail = 0
				if (length(covered)>4)
					fail = 1
					if (prob(volume+6))
						fail = 0

				if (!fail)
					var/radius = min((volume - 3) * 0.15, 2)
					fireflash_sm(T, radius, src.burn_temperature + volume * 500, 350)

			reaction_obj(var/obj/O, var/volume)
				var/datum/reagents/old_holder = src.holder //mbc pls, ZeWaka fix: null.holder
				var/id = src.id
				if (isnull(O)) return
				if(isitem(O))
					var/obj/item/I = O
					if(!I.burn_possible)
						I.burn_possible = TRUE
					if(!I.health)
						I.health = 10
					if(!I.burn_output)
						I.burn_output = 1200
					if(!I.burning)
						if(!isnull(I)) // just in case
							I.combust()

					var/list/covered = old_holder.covered_turf()
					if (covered.len>4)
						old_holder.remove_reagent(id, I.health * 0.25)
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == TOUCH || method == INGEST)
					var/mob/living/L = M
					if(istype(L))
						if (volume <= 1)
							L.update_burning(10)
						else
							L.update_burning(50)
				if (method == INGEST)
					M.TakeDamage("All", 0, min(max(15, volume * 2.5), 90), 0, DAMAGE_BURN)
					boutput(M, "<span class='alert'>It burns!</span>")
					M.emote("scream")
				return

			on_mob_life(var/mob/M, var/mult = 1)

				var/mob/living/L = M
				if(istype(L) && (L.getStatusDuration("burning") || src.holder.is_combusting))
					L.changeStatus("burning", 10 SECONDS * mult)
				..()

		combustible/foof
			name = "FOOF"
			id = "foof"
			description = "Dioxygen Diflouride, a ludicrously powerful oxidizer. Run away."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 200
			fluid_b = 200
			transparency = 175
			depletion_rate = 1.2
			viscosity = 0.6
			volatility = 4
			flammable_influence = TRUE
			combusts_on_fire_contact = TRUE
			burn_speed = 2.5
			burn_energy = 1500000
			burn_temperature = 9000
			burn_volatility = 20
			minimum_reaction_temperature = -INFINITY
			evaporates_cleanly = TRUE

			reaction_turf(var/turf/T, var/volume)
				. = ..()
				if (holder && holder.total_temperature)
					holder.start_combusting()

			reaction_temperature(exposed_temperature, exposed_volume)
				. = ..()
				if(holder && !holder.is_combusting && !istype(holder.my_atom,/obj/item/reagent_containers/glass/wateringcan/artifact))
					holder.start_combusting()

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == TOUCH || method == INGEST)
					var/mob/living/L = M
					if(istype(L))
						L.update_burning(90)
				if (method == INGEST)
					M.TakeDamage("All", 0, min(max(30, volume * 6), 90), 0, DAMAGE_BURN)
					boutput(M, "<span class='alert'>It burns!</span>")
					M.emote("scream")
				return

			on_mob_life(var/mob/M, var/mult = 1)

				var/mob/living/L = M
				if(istype(L))
					L.update_burning(50 * mult)
				..()

		combustible/thalmerite // COGWERKS CHEM REVISION PROJECT. pretty much a magic chem, can leave alone
			name = "pyrosium"
			id = "thalmerite"
			description = "This strange compound seems to slowly heat up all by itself. Very sticky."
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 200
			fluid_b = 150
			transparency = 150
			viscosity = 0.7
			minimum_reaction_temperature = 1000

			reaction_temperature(exposed_temperature, exposed_volume)
				holder.del_reagent(id)

			reaction_obj(var/obj/O, var/volume)
				if (O)
					if(!O.reagents)
						O.create_reagents(50)
					O.reagents.add_reagent("thalmerite", 5, null)
				return

			reaction_turf(var/turf/T, var/volume)
				if (T)
					if(!T.reagents)
						T.create_reagents(50)
					T.reagents.add_reagent("thalmerite", 5, null)
				return

		combustible/argine
			name = "argine"
			id = "argine"
			description = "This strange material seems to ignite & explode on low temperatures."
			reagent_state = LIQUID
			fluid_r = 50
			fluid_g = 200
			fluid_b = 200
			transparency = 200
			viscosity = 0.6
			volatility = 3
			minimum_reaction_temperature = -INFINITY

			reaction_temperature(exposed_temperature, exposed_volume)
				if(exposed_temperature < T0C)
					if(holder)
						var/list/covered = holder.covered_turf()
						for(var/turf/t in covered)
							explosion(t, t, 2, 3, 4, 1)
						holder.del_reagent(id)

			reaction_obj(var/obj/O, var/volume)
				return
			reaction_turf(var/turf/T, var/volume)
				return

		combustible/sorium
			name = "sorium"
			id = "sorium"
			description = "Flammable material that causes a powerful shockwave on detonation."
			reagent_state = LIQUID
			fluid_r = 90
			fluid_g = 100
			fluid_b = 200
			transparency = 200
			viscosity = 0.6
			volatility = 1.25
			minimum_reaction_temperature = T0C + 200
			evaporates_cleanly = TRUE

			reaction_temperature(exposed_temperature, exposed_volume)
				if(!src.reacting)
					src.reacting = sorium_reaction(holder, volume, id)


			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				return

		combustible/liquiddarkmatter
			name = "liquid dark matter"
			id = "ldmatter"
			description = "What has science done ... It's concentrated dark matter in liquid form. And i thought you needed plutonic quarks for that."
			reagent_state = LIQUID
			fluid_r = 33
			fluid_g = 0
			fluid_b = 33
			value = 6 // 3 1 1 1
			viscosity = 0.9
			volatility = 1.5 // lol no
			minimum_reaction_temperature = T0C+200
			evaporates_cleanly = TRUE

			reaction_temperature(exposed_temperature, exposed_volume)
				if(!src.reacting)
					var/list/covered = holder.covered_turf()
					if (length(covered) > 1 && ((exposed_volume / length(covered)) > 0.5))
						return

					src.reacting = ldmatter_reaction(holder, volume, id)


			//Comment this out if you notice a lot of crashes. (It's probably a really bad idea to have this in)
			/* i agree. also fuck snapcakes
			reaction_turf(var/turf/T, var/volume)
				if(prob(75)) return

				var/datum/reagent/us = src
				if(!T.reagents) T.create_reagents(50)
				T.reagents.add_reagent(us.id, 5, null)
				return
			*/

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				return

		combustible/something
			name = "something"
			id = "something"
			description = "What is this thing?  None of the normal tests have been able to determine what exactly this is, just that it is benign."
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 100
			fluid_b = 100
			transparency = 250
			viscosity = 0.2

		combustible/fuel // COGWERKS CHEM REVISION PROJECT. treat like acetylene or similar basic hydrocarbons for other reactions
			name = "fuel"
			id = "fuel"
			description = "A highly flammable blend of basic hydrocarbons, mostly Acetylene. Useful for both welding and organic chemistry, and can be fortified into a heavier oil."
			reagent_state = LIQUID
			volatility = 1
			fluid_r = 175
			fluid_g = 130
			fluid_b = 20
			transparency = 230
			viscosity = 0.2
			minimum_reaction_temperature = T0C + 200
			depletion_rate = 0.6
			heat_capacity = 5
			flammable_influence = TRUE
			combusts_on_fire_contact = TRUE
			burn_speed = 1
			burn_energy = 840000 // gases use molar specific heat, this is in joules. assumes a 400 unit fuel tank is a 10 liter jerrycan
			burn_temperature = 1300
			burn_volatility = 5
			var/smoke_counter = 0

			reaction_temperature(exposed_temperature, exposed_volume)
				. = ..()
				if(holder && !holder.is_combusting)
					holder.start_combusting()

			do_burn(reacting_volume)
				if (istype(holder,/datum/reagents/fluid_group))
					var/list/covered = holder.covered_turf()
					if (length(covered) && prob(5 + smoke_counter))
						var/turf/location = pick(covered)
						if(prob(40))
							var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
							smoke.set_up(max(round(length(covered)/3), 1), 0, location)
							smoke.start()
						else
							var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
							smoke.set_up(max(round(length(covered)/3), 1), 0, location)
							smoke.start()
						smoke_counter = 0
					else
						smoke_counter += reacting_volume
				if (holder.my_atom && holder.my_atom.is_open_container())
					if (prob(5 + smoke_counter) && src.volume >= 20)
						if(prob(40))
							var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
							smoke.set_up(1, 0, holder.my_atom.loc)
							smoke.start()
						else
							var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
							smoke.set_up(1, 0, holder.my_atom.loc)
							smoke.start()
						smoke_counter = 0
					else
						smoke_counter += reacting_volume * 2

			reaction_obj(var/obj/O, var/volume)
				return 1

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == TOUCH)
					var/mob/living/L = M
					if(istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", 30 SECONDS)
				return 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if(istype(M, /mob/living/) && M.getStatusDuration("burning"))
					M.changeStatus("burning", 2 SECONDS * mult)
				if((M.health > 20) && (prob(33)))
					M.take_toxin_damage(1 * mult)
				if(probmult(1))
					var/vomit_message = SPAN_ALERT("[M] pukes all over [himself_or_herself(M)].")
					M.vomit(0, null, vomit_message)
				..()

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("poison", 1)

		// cogwerks - gunpowder test. IS THIS A TERRIBLE GODDAMN IDEA? PROBABLY

		combustible/blackpowder
			name = "black powder"
			id = "blackpowder"
			description = "A dangerous explosive material."
			reagent_state = SOLID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			volatility = 2.5
			transparency = 255
			depletion_rate = 0.05
			penetrates_skin = 1 // think of it as just being all over them i guess
			minimum_reaction_temperature = T0C+200

			reaction_temperature(exposed_temperature, exposed_volume)
				if(src.reacting)
					return

				src.reacting = 1
				var/list/covered = holder.covered_turf()

				for(var/turf/location in covered)
					var/our_amt = holder.get_reagent_amount(src.id) / length(covered)

					if (our_amt < 10 && covered.len > 5)
						if (prob(min(covered.len/3,85)))
							continue

					elecflash(location)
					SPAWN_DBG(rand(5,15))
						if(!holder || !holder.my_atom) return // runtime error fix
						switch(our_amt)
							if(0 to 20)
								holder.my_atom.visible_message("<b>The black powder ignites!</b>")
								if (covered.len < 5 || prob(5))
									var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
									smoke.set_up(1, 0, location)
									smoke.start()
								explosion(holder.my_atom, location, -1, -1, pick(0,1), 1)
								if (covered.len > 1)
									holder.remove_reagent(id, our_amt)
								else
									holder.del_reagent(id)
							if(21 to 80)
								holder.my_atom.visible_message("<b>[holder.my_atom] flares up!</b>")
								fireflash(location,0)
								explosion(holder.my_atom, location, -1, -1, 1, 2)
								if (covered.len > 1)
									holder.remove_reagent(id, our_amt)
								else
									holder.del_reagent(id)
							if(81 to 160)
								holder.my_atom.visible_message("<span class='alert'><b>[holder.my_atom] explodes!</b></span>")
								explosion(holder.my_atom, location, -1, 1, 2, 3)
								if (covered.len > 1)
									holder.remove_reagent(id, our_amt)
								else
									holder.del_reagent(id)
							if(161 to 300)
								holder.my_atom.visible_message("<span class='alert'><b>[holder.my_atom] violently explodes!</b></span>")
								explosion(holder.my_atom, location, 1, 3, 6, 8)
								if (covered.len > 1)
									holder.remove_reagent(id, our_amt)
								else
									holder.del_reagent(id)
							if(301 to INFINITY)
								holder.my_atom.visible_message("<span class='alert'><b>[holder.my_atom] detonates in a huge blast!</b></span>")
								explosion(holder.my_atom, location, 3, 6, 12, 15)
								if (covered.len > 1)
									holder.remove_reagent(id, our_amt)
								else
									holder.del_reagent(id)

			reaction_obj(var/obj/O, var/volume)
				return

			reaction_turf(var/turf/T, var/volume)
				if(!istype(T, /turf/space))
					//if(volume >= 5)
					if(!locate(/obj/decal/cleanable/dirt) in T)
						var/obj/decal/cleanable/dirt/D = make_cleanable(/obj/decal/cleanable/dirt,T)
						D.name = "black powder"
						D.desc = "Uh oh. Someone better clean this up!"
						if(!D.reagents) D.create_reagents(10)
						D.reagents.add_reagent("blackpowder", 5, null)
				return
			reaction_mob(var/mob/living/carbon/human/M, var/method=TOUCH, var/volume)
				. = ..()
				if (ishuman(M) && volume >= 10)
					M.gunshot_residue = 1
				return

		combustible/nitrogentriiodide
			//This is the parent and should not be spawned
			name = "Nitrogen Triiodide"
			id = "nitrotri_parent"
			description = "A chemical that is stable when in liquid form, but becomes extremely volatile when dry."
			random_chem_blacklisted = 1
			reagent_state = LIQUID
			penetrates_skin = 1
			volatility = 2
			fluid_r = 48
			fluid_g = 22
			fluid_b = 64
			minimum_reaction_temperature = T0C+100
			var/is_dry = 0
/*
			pooled()
				..()
				is_dry = 0
*/
			proc/bang()
				if(holder?.my_atom)
					holder.my_atom.visible_message("<b>The powder detonates!</b>")

					var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
					smoke.set_up(1, 0, holder.my_atom.loc)
					smoke.start()

					elecflash(holder.my_atom.loc)

					var/max_dev = min(round(1 * (volume/300)), 1)
					var/max_heavy = min(round(3 * (volume/300)), 3)
					var/max_light = min(round(6 * (volume/300)), 6)
					var/max_flash = min(round(9 * (volume/300)), 9)

					explosion(holder.my_atom, holder.my_atom.loc, max_dev, max_heavy, max_light, max_flash)

					var/datum/reagents/H = holder
					SPAWN_DBG(0)
						H.del_reagent("nitrotri_wet")
						H.del_reagent("nitrotri_dry")
						H.del_reagent("nitrotri_parent")

			proc/dry()
				if(is_dry) return
				is_dry = 1
				var/datum/reagents/H = holder
				var/vol = volume
				if(!H)
					return
				H.del_reagent(reagent="nitrotri_wet")
				H.add_reagent(reagent="nitrotri_dry", amount=vol, donotreact=1)


			reaction_turf(var/turf/T, var/volume)
				if(!istype(T, /turf/space) && volume >= 5 && !locate(/obj/decal/cleanable/nitrotriiodide) in T)
					return make_cleanable(/obj/decal/cleanable/nitrotriiodide,T)

			reaction_temperature(exposed_temperature, exposed_volume)
				dry()

		combustible/nitrogentriiodide/wet
			id = "nitrotri_wet"
			random_chem_blacklisted = 1
			volatility = 2
			viscosity = 0.3

			New()
				..()
				SPAWN_DBG(200 + rand(10, 600) * rand(1, 4)) //Random time until it becomes HIGHLY VOLATILE
					dry()
/*

			unpooled()
				SPAWN_DBG(200 + rand(10, 600) * rand(1, 4)) //Random time until it becomes HIGHLY VOLATILE
					dry()
				..()

*/

		combustible/nitrogentriiodide/dry
			id = "nitrotri_dry"
			random_chem_blacklisted = 1
			volatility = 2.5
			description = "A chemical that is stable when in liquid form, but becomes extremely volatile when dry. This is dry. Uh oh."
			is_dry = 1
			reagent_state = SOLID
			minimum_reaction_temperature = -INFINITY

			New()
				..()
				SPAWN_DBG(10 * rand(11,600)) //At least 11 seconds, at most 10 minutes
					bang()
/*
			unpooled()
				is_dry = 1
				SPAWN_DBG(10 * rand(11,600)) //At least 11 seconds, at most 10 minutes
					bang()
				..()*/

			reaction_turf(var/turf/T, var/volume)
				var/obj/decal/cleanable/nitrotriiodide/NT = ..()
				if(NT)
					NT.Dry() 	//Welp
					NT.bang()	//What did you expect would happen when splashing THE HIGHLY VOLATILE POWDER on the floor

			reaction_temperature(exposed_temperature, exposed_volume)
				bang()
