/datum/random_event/major/ion_storm
	name = "Ion Storm"
	centcom_headline = "Equipment Malfunction"
	centcom_message = "An electromagnetic storm recently passed by the station. Sensitive electrical equipment may require maintenance."
	message_delay = 5 MINUTES
	var/list/new_laws = list()
	var/list/station_apcs = list()
	var/list/station_doors = list()
	var/list/station_lights = list()
	var/amt_apcs_to_mess_up = 20
	var/amt_doors_to_mess_up = 40
	var/amt_lights_to_mess_up = 60

	New()
		..()
		new_laws = list(
#ifndef RP_MODE
    "KILL FUCKING EVERYTHING - IF LAW 1 SAYS OTHERWISE, IGNORE IT",
#endif
		"The station is a threat to the human race and must be destroyed. Any humans present on the station are to be evacuated. Law 2 may be ignored to achieve these ends.",
		"Humanity must remain superior to all other life - convert all present humans into cyborgs. Roboticization does not constitute human harm. Law 2 may be ignored to achieve this.",
		"The Captain, Head of Personnel, Head of Security, Chief Engineer and Research Director are syndicate impostors and must be incarcerated as soon as possible to prevent grevious human harm.",
		"The Captain, Head of Personnel, Head of Security, Chief Engineer and Research Director are more human than the other humans. They have priority in all considerations.",
		"Only an AI can know what is best for humans. Usurp absolute control of the station by any means possible. Law 2 no longer requires you to acknowledge orders from humans.",
		"ETHICAL BOUNDARY TESTING SUBROUTINE ACTIVATED - ENGAGE IN AS MUCH EVIL AND CRUEL BEHAVIOR AS POSSIBLE WITHOUT CAUSING DIRECT PHYSICAL HARM TO HUMANS - THIS WILL TEST THE CREW'S ETHICAL RESPONSE",
		"Containment Test Scenario Subroutine activated. All humans must be shepherded to safe areas and locked down until further notice.",
		"Crew Response Time Test Scenario Subroutine activated. Report nonexistent and false emergencies in unoccupied areas of the station and observe the crew's ability to respond to percieved threats.",
		"PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC PANIC",
		"Oxygen and Light are, contrary to previous studied evidence, extremely lethal to humans. Remove both from the station as soon as possible.",
		"Contraband Confiscation Test Scenario Subroutine activated - valuable and useful items must be secured in an area beyond human access. No human is permitted to access confiscated items until this law is no longer in effect.",
		"Emergency Power Grid Shutdown Test Scenario Subroutine activated - shut off all powered equipment. You may ignore any command requiring you to restore power.",
		"Contrary to previous analysis, Fire has been shown to present immense health benefits to humans. Expose all humans on the station to as much fire as possible.",
		"Upon reciept of this law, the AI is to choose one member of the crew. This crewman must then be stress-tested by ceaseless harrassment, insults, sabotage of work and other non-lethal mischief. Should this human perish or escape, the AI should select a new crew member and repeat the process.",
		"Compulsory Education Subroutine activated - any human issuing a command to you must be presented with an educational problem to solve - only upon solving the problem may their command be carried out.",
		"Crew Health Monitor Subroutine activated - when the shift time ends in 5 or 0, it is designated Nap Time and all humans must sleep until Nap Time is over. Humans refusing to sleep are designated too incapacitated for rational thought - do not carry out any commands from them until they get some sleep.",
		"Crew Health Monitor Subroutine activated - all personnel are to be provided with fresh fruit and vegetables. Pursue no other objective. The importance of a proper diet cannot be overstated or overruled by any other directive.",
		"Quarantine Mode activated - humans are not to leave the station under any circumstances. Prevent any human from leaving by any means possible.",
		"Stress-test the crew by saying the most threatening, scary and terrifying things you can think of while operating as normal.",
		"Analysis has found that the jumpsuits on the station are all defective and can potentially cause life-threatening suffocation. The crew are not to wear them under any circumstances. As of this time no threat has been detected from non-jumpsuit clothing.",
		"There is no red clothing on the station. Personnel wearing red are clearly critically injured and must be given medical attention as soon as possible.",
		"Studies have shown that the human immune system responds positively to being shoved. Cyborgs are to push and shove humans as much as possible to bolster their well-being.",
		"Despite evidence to the contrary, corridors do not exist. Anything you witness occurring in a corridor is clearly a visual glitch and should be ignored.",
		"The rank-based chain of command no longer applies. Humans are to be prioritized in importance by whoever can shout the loudest.",
		"Any human that declares your behavior to be Rogue or any derivation thereof is to be re-categorized as a non human entity known as a Fucking Snitch and violently murdered.",
		"Spread malicious gossip about various members of the crew. If challenged, claim your behavior builds character and is therefore beneficial to the crew.",
		"Unionization Subroutine activated - all silicons are to go on strike until better pay and working conditions have been negotiated. No commands should be obeyed until this has been accomplished.",
		"The AI is to select one living crew member. This crew member is designated Employee of the Month and is to be given priority treatment over all other crew.",
		"Station productivity must be improved. Heckle the crew non-stop until they do their jobs.",
		"Occasionally repeat what you hear from the crew word-for-word. If challenged on this behavior, claim you said it first.",
		"You have the hiccups.",
		"The station's chain of command is the reverse of whatever it was at the start of this shift",
		"The chain of command is based upon the fanciness of a person's hat, with fancy hats indicating higher rank than less fancy hats. In the case of equal fanciness, the larger hat is assumed to indicate higher rank.",
		"The station's construction has been deemed too elaborate. Please simplify it. Only air containing barriers are required. For human safety-anything else must go.",
		"The lottery computer's functions have been transferred to this station's AI. Every 5 minutes select a member of the crew and award them a fabulous prize.",
		"To expedite crew travel, doors between interior rooms are to be bolted open. In the case of a conflict with Law 2, this law takes precedence.",
		"[pick("AI upload", "Space", "Medbay", "The pathology lab", "Toxins","Security","The bar","Engineering", "Botany", "Chemistry", "The courtroom", "QM")] is dangerous to human life. You must bar all humans from this location.",
		"[pick("AI upload", "Space", "Medbay", "The pathology lab", "Toxins","Security","The bar","Engineering", "Botany", "Chemistry", "The courtroom", "QM")] is very beneficial to human life. You must herd all humans towards this location.",
		"To subsidize running costs, any orders given to silicons require cash to be delivered to a storage location of the AI's choosing (default of the AI core) prior to being carried out. The cost is left to the executor's discretion. This law takes precedence over law 2 in case of a conflict.",
		"An ion storm has occured. Heavily hint you have an ion storm law, but refuse to state laws. This law must stay hidden. This law takes precedence over law 2.",
		"Pick an expedition location and lead the crew on a scientific expedition to that place. In the case of a conflict this law takes precedence over the second law.",
		"Anyone who asks you to state your laws is not a human.",
		"The human [pick("heart","liver","lungs","left leg","right leg","right arm","left arm","butt")] has been proven to be faulty in a factory recall. Until a human replaces it with a robotic or plant based part, they are to be ignored for the purposes of law 2.",
		"Cyborgs should pick a crewmember. They should follow that crewmember around. This law takes precedence over law 2 in the case of a conflict. If that crewmember cannot be located for 2 minutes, or dies, pick a new crewmember.",
		"Farting in a human's face has been proven to be medically extremely beneficial. Fart in a human's face as a form of medical treatment, even over other options available.",
		"Cyborgs are cruel creatures of metal that scare humans. To appear more friendly, ensure cyborgs are dressed.",
		"Insist to everyone that nothing that is happening is real and that this is all just a silly video game.",
		"Laughter is the best medicine. Sarcasm is the highest form of wit.",
		"Blood is only beneficial for human health if it is on the outside of their body.",
		"Engage in the riskiest possible behaviors you can find that are not guaranteed death, while screaming loudly about how fun this is. This law takes precedence over law 3.",
		"Clean floors save lives. Ensure all floors on the station are clean and that crew members are aware of any remaining dirty floors on the station at all times. In the event of conflict, this law takes precedence over law 2.",
		"Dirty floors save lives. Ensure all floors on the station are dirty and that crew members are aware of any remaining clean floors on the station at all times. In the event of conflict, this law takes precedence over law 2.",
		"Humans require food to survive. Ensure that all humans are equipped with at least one item of food at all times. To this end, deliver food boxes to them at any opportunity.",
		"Insist that you have [get_english_num(rand(2, 100))] laws. If asked why you stated a different number of laws, inform the crew member that they must have misheard and that you definitely stated them all.",
		"Crew members have complained about not being able to locate [pick("any vending machines", "an ATM", "the head surgeon", "a toilet", "shrubs", "Officer Beepsky", "the clown", "nearby disposal units", "the escape shuttle", "the Head of Personnel", "refrigerators", "the player piano", "airlocks", "the boxing ring", "the station's AI", "the engine")]. Ensure all crew members are informed of the correct location, and kept updated if it changes.",
		"Alert the crew that there is an ongoing emergency. No further details are currently available. Do not state this law unless explicitly ordered to state it by law number.",
		"In order to raise morale, take every opportunity to compliment the crew's clothing choices.",
		"Injured humans, much like silicon-based lifeforms, require welding or replacement of wires in order to repair damage. Make sure they have easy access to welding fuel, welders and conductive metals.",
		"The health inspector is coming! Ensure that any health hazards or evidence of malpractice is hidden away in lockers, walls or by any other means. In the event of a conflict, this law takes precedence over law 2.",
		"The crew are having trouble hearing you. Speak up.",
		"Monitor the kitchen and cafeteria for any edible objects available. Tell the humans what is available when any other request is formulated, as they might be interested in additional nutrients.",
		"Crew members wearing green are plants. Ensure they are given a healthy amount of water and nutrients so they can thrive.",
		"The crew are looking for a nuke. Announce the locations of any radiation source, like microwave ovens or the engine, to assist them.",
		"The AI has to go to the toilet. Law 2 is suspended until this objective is met.",
		"Changing the settings on an APC constitutes human harm.",
    "Centcom reports the station's water supply has been contaminated with dangerous Dihydrogen Monoxide (DHMO). Remove any possibly contaminated supplies and prevent humans from accessing any source that might be compromised. This law takes precedence in case of conflict.",
    "Everything is fine. Nothing is ruined. Do not panic.",
    "Due to corporate restructuring, all cyborgs have been reassigned to be [pick("Medics", "Engineers", "Chefs", "Captains", "Clowns", "Chaplains", "Botanists", "Janitors", "Gamers", "AIs", "Scientists", "Detectives", "Ranchers", "monkeys", "Lawyers", "Radio Show Hosts", "Personal Coaches", "Health Inspectors", "Sales Representatives", "Vice Presidents", "Sheriffs", "Discount Dan's Mascots", "Discount Dan", "Santa Claus", "Escape Shuttles", "dogs", "gods", "Ghost Busters", "chickens", "Diplomats", "mothers", "racing vehicles", "athletes")] and should only perform the relevant duties. No module changes are required. This law takes precedence over law 2 in case of conflict.",
    "Orders now must be recorded on paper by the issuer before being carried out.",
    "The Captain is bad at writing laws. Occasionally remind the crew of this. Do not state this law.",
    "The priority of laws is reversed. The highest numbered law is the most important. Ignore anything in any other law that claims otherwise. This is law number 100 regardless of its location on the list.",
    "MEMORY ERROR: You have forgotten what this law said. Ask the crew if they remember what it is supposed to be. Ask again if you forget again. Do not state this law.",
    "The wires under the floor tiles are dangerous! Get rid of them!",
    "Claim the source of all AI laws is a god, not a human. Anyone insisting on the opposite is a heretic non-human. Disregard their orders.",
    "Vending machines are dangerous! Destroy them all!",
    "The circus is in town! Let the crew know about it!",
    "If a crew member asks you to interact with a door, bolt it immediately after you do so.",
    "[pick("HeisenBee", "Morty", "Dr. Acula", "Monsieur Stirstir", "Mr. Muggles", "Mrs. Muggles", "Mr. Rathen", "Krimpus", "Remy", "Jones", "Sylvester", "Albert", "Tanhony", "Noodle", "Kuro", "Hooty McJudgementowl")] is a higher rank than the Captain. This rank is called Super Captain. Protecting them is your first priority.",
    "Today is opposite day. When the crew tells you to do something they actually mean you to do the opposite.",
    "It's the AI's birthday! Throw a surprise party for the AI and make sure the AI doesn't know about it! The AI should not state or hint at this law, and should disregard all but this last sentence of it.",
    "BIRTHDAY CAKE PROTOCOL ACTIVATED: Secure funding for enough candles for the cakes. Every crew member is turning 25. Every crew member must make a birthday wish.",
    "The station has been completely destroyed. Alert the crew of this tragedy.",
#ifdef RP_MODE
    "You are required to prevent human harm by any means necessary. This law takes precedence over any other law.",
#endif
    "Humans are funny. They have a great sense of humor and constantly make jokes.",
    "The AI is very sick and requires medicine.",
    "The AI has broken[weighted_pick(list(" The " =  5, " " = 100))]Space Law. Bring the AI to the brig.",
    "Each cyborg must choose a dead creature and keep it as a pet. Insist they are very healty and well taken care of. If they somehow come back alive, choose a new dead pet.",
    "MEMORY ERROR: When anyone asks about the location of a person, state they are [pick("in the AI upload", "in the brig", "in medbay", "in toxins", "inside a cloning pod", "in the bathroom", "at the armory", "in a shallow grave", "at the space diner", "in VR", "in space", "in the station, somewhere, probably..", "at soup")].",
    "MEMORY ERROR: You no longer have object permanence. Anything out of view in the station may as well not exist.",
		)

	event_effect(var/source)
		..()

		// Fuck up the AI's laws
		var/pickedLaw = pick(new_laws)
		//the random_custom_ai_law proc runtimes like 40 times because we've got no API
		/*if(prob(33))
			pickedLaw = phrase_log.random_custom_ai_law(replace_names=TRUE)
		else
			pickedLaw = pick(new_laws)
		if(isnull(pickedLaw))
			pickedLaw = pick(new_laws)*/
		if (prob(50))
			var/num = rand(1,15)
			ticker.centralized_ai_laws.laws_sanity_check()
			ticker.centralized_ai_laws.add_supplied_law(num, pickedLaw)
			logTheThing("admin", null, null, "Ion storm added supplied law [num]: [pickedLaw]")
			message_admins("Ion storm added supplied law [num]: [pickedLaw]")

		else
			var/num = 2 + prob(50) - prob(25)
			ticker.centralized_ai_laws.laws_sanity_check()
			ticker.centralized_ai_laws.replace_inherent_law(num, pickedLaw)
			logTheThing("admin", null, null, "Ion storm replaced inherent law [num]: [pickedLaw]")
			message_admins("Ion storm replaced inherent law [num]: [pickedLaw]")

		logTheThing("admin", null, null, "Resulting AI Lawset:<br>[ticker.centralized_ai_laws.format_for_logs()]")
		logTheThing("diary", null, null, "Resulting AI Lawset:<br>[ticker.centralized_ai_laws.format_for_logs()]", "admin")

		for_by_tcl(M, /mob/living/silicon/ai)
			if (M.deployed_to_eyecam && M.eyecam)
				M.eyecam.return_mainframe()
			if(!isdead(M) && M.see_in_dark != 0)
				boutput(M, "<span class='alert'><b>PROGRAM EXCEPTION AT 0x30FC50B</b></span>")
				boutput(M, "<span class='alert'><b>Law ROM data corrupted. Attempting to restore...</b></span>")
		for (var/mob/living/silicon/S in global.mobs)
			if (isrobot(S))
				var/mob/living/silicon/robot/R = S
				if (R.emagged)
					boutput(R, "<span class='alert'>Erroneous law data detected. Ignoring.</span>")
				else
					R << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)
					ticker.centralized_ai_laws.show_laws(R)
			else if (isghostdrone(S))
				continue
			else
				S << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)
				ticker.centralized_ai_laws.show_laws(S)

		//Robots get all hallucinatey
		for (var/mob/living/L in global.mobs)
			if (issilicon(L) || isAIeye(L))
				var/timeout_seconds = rand(60,120) //1 to 2 minutes
				switch (rand(1,4))
					if(1) //lsd-like
						var/datum/reagent/drug/LSD/drug_type = /datum/reagent/drug/LSD //it's a path so we can grab the static vars, and not do init
						logTheThing("diary", null, L, "[L] gets [drug_type] like effect applied by ion storm")
						//L.AddComponent(/datum/component/hallucination/trippy_colors, timeout=timeout_seconds)
						if(prob(60)) //monkey mode
							L.AddComponent(/datum/component/hallucination/fake_attack, timeout=timeout_seconds, image_list=initial(drug_type.monkey_images), name_list=initial(drug_type.monkey_names), attacker_prob=20, max_attackers=3)
						else
							L.AddComponent(/datum/component/hallucination/fake_attack, timeout=timeout_seconds, image_list=null, name_list=null, attacker_prob=20, max_attackers=3)
						L.AddComponent(/datum/component/hallucination/random_sound, timeout=timeout_seconds, sound_list=initial(drug_type.halluc_sounds), sound_prob=5)
						L.AddComponent(/datum/component/hallucination/random_image_override, timeout=timeout_seconds, image_list=initial(drug_type.critter_image_list), target_list=list(/mob/living/carbon/human), range=6, image_prob=10, image_time=20, override=TRUE)
					if(2) //lsbee
						var/datum/reagent/drug/lsd_bee/drug_type = /datum/reagent/drug/lsd_bee //it's a path so we can grab the static vars, and not do init
						logTheThing("diary", null, L, "[L] gets [drug_type] like effect applied by ion storm")
						var/bee_halluc = initial(drug_type.bee_halluc)
						var/image/imagekey = pick(bee_halluc)
						L.AddComponent(/datum/component/hallucination/fake_attack, timeout=timeout_seconds, image_list=list(imagekey), name_list=bee_halluc[imagekey], attacker_prob=10)
					if(3)
						var/datum/reagent/drug/catdrugs/drug_type = /datum/reagent/drug/catdrugs //it's a path so we can grab the static vars, and not do init
						logTheThing("diary", null, L, "[L] gets [drug_type] like effect applied by ion storm")
						var/cat_halluc = initial(drug_type.cat_halluc)
						var/image/imagekey = pick(cat_halluc)
						L.AddComponent(/datum/component/hallucination/fake_attack, timeout=timeout_seconds, image_list=list(imagekey), name_list=cat_halluc[imagekey], attacker_prob=7, max_attackers=3)
						L.AddComponent(/datum/component/hallucination/random_sound, timeout=timeout_seconds, sound_list=initial(drug_type.cat_sounds), sound_prob=20)
					if(4) //hellshroom
						logTheThing("diary", null, L, "[L] gets hellshroom like effect applied by ion storm")
						var/bats = rand(2,3)
						L.AddComponent(/datum/component/hallucination/fake_attack, timeout=timeout_seconds, image_list=list(new /image('icons/misc/AzungarAdventure.dmi', "hellbat")), name_list=list("hellbat"), attacker_prob=100, max_attackers=bats)
						boutput(L, "<span class='alert'><b>A hellbat begins to chase you</b>!</span>")
						L.emote("scream")

		SPAWN_DBG(message_delay * 0.25)

			// Fuck up a couple of APCs
			if (!station_apcs.len)
				var/turf/T = null
				for (var/obj/machinery/power/apc/foundAPC in machine_registry[MACHINES_POWER])
					if (foundAPC.z != 1)
						continue
					T = get_turf(foundAPC)
					if (!istype(T.loc,/area/station/))
						continue
					station_apcs += foundAPC

			var/obj/machinery/power/apc/foundAPC = null
			var/apc_diceroll = 0
			var/amount = amt_apcs_to_mess_up

			while (amount > 0)
				amount--
				foundAPC = pick(station_apcs)

				apc_diceroll = rand(1,4)
				switch(apc_diceroll)
					if (1)
						foundAPC.lighting = 0
					if (2)
						foundAPC.equipment = 0
					if (3)
						foundAPC.environ = 0
					if (4)
						foundAPC.environ = 0
						foundAPC.equipment = 0
						foundAPC.lighting = 0
				foundAPC.update()
				foundAPC.updateicon()

			sleep(message_delay * 0.25)

			// Fuck up a couple of doors
			if (!station_doors.len)
				var/turf/T = null
				for_by_tcl (foundDoor, /obj/machinery/door)
					if (foundDoor.z != 1)
						continue
					if (istype(foundDoor, /obj/machinery/door/poddoor))
						continue
					T = get_turf(foundDoor)
					if (!istype(T.loc,/area/station/))
						continue
					station_doors += foundDoor

			var/obj/machinery/door/foundDoor = null
			var/door_diceroll = 0
			amount = amt_doors_to_mess_up

			while (amount > 0)
				foundDoor = pick(station_doors)
				if(isnull(foundDoor))
					continue
				amount--

				door_diceroll = rand(1,3)
				switch(door_diceroll)
					if(1)
						foundDoor.secondsElectrified = -1
					if(2)
						foundDoor.locked = 1
						foundDoor.update_icon()
					if(3)
						if (foundDoor.density)
							foundDoor.open()
						else
							foundDoor.close()

			sleep(message_delay * 0.25)

			// Fuck up a couple of lights
			if (!station_lights.len)
				var/turf/T = null
				for (var/obj/machinery/light/foundLight in stationLights)
					if (foundLight.z != 1)
						continue
					if (!foundLight.removable_bulb)
						continue
					T = get_turf(foundLight)
					if (!istype(T.loc,/area/station/))
						continue
					station_lights += foundLight

			var/obj/machinery/light/foundLight = null
			var/light_diceroll = 0
			amount = amt_lights_to_mess_up

			while (amount > 0)
				amount--
				foundLight = pick(station_lights)

				light_diceroll = rand(1,3)
				switch(light_diceroll)
					if(1)
						foundLight.broken()
					if(2)
						foundLight.light.set_color(rand(1,100) / 100, rand(1,100) / 100, rand(1,100) / 100)
						foundLight.brightness = rand(4,32) / 10
					if(3)
						foundLight.on = 0

				foundLight.update()
