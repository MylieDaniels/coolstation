var/global/datum/controller/gameticker/ticker
var/global/current_state = GAME_STATE_WORLD_INIT
/* -- moved to _setup.dm
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4
*/
/datum/controller/gameticker
	//var/current_state = GAME_STATE_PREGAME
	//replaced with global

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/list/datum/mind/minds = list()
	var/last_readd_lost_minds_to_ticker = 1 // In relation to world time.

	var/pregame_timeleft = 0
	#ifdef IM_REALLY_IN_A_FUCKING_HURRY_HERE
	var/did_lobbymusic = 1
	#else
	var/did_lobbymusic = 0
	#endif

	// this is actually round_elapsed_deciseconds
	var/round_elapsed_ticks = 0

	var/click_delay = 3

	var/datum/ai_laws/centralized_ai_laws

	var/skull_key_assigned = 0

	var/tmp/last_try_dilate = 0
	var/tmp/useTimeDilation = TIME_DILATION_ENABLED
	var/tmp/timeDilationLowerBound = MIN_TICKLAG
	var/tmp/timeDilationUpperBound = OVERLOADED_WORLD_TICKLAG
	var/tmp/highMapCpuCount = 0 // how many times in a row has the map_cpu been high

	var/list/lobby_music = list('sound/radio_station/lobby/opus_number_null.ogg','sound/radio_station/lobby/tv_girl.ogg','sound/radio_station/lobby/tane_lobby.ogg','sound/radio_station/lobby/muzak_lobby.ogg','sound/radio_station/lobby/say_you_will.ogg','sound/radio_station/lobby/two_of_them.ogg','sound/radio_station/lobby/ultimatum_low.ogg', 'sound/radio_station/lobby/onn105.ogg')
	var/picked_music = null



/datum/controller/gameticker/proc/pregame()

	did_lobbymusic = initial(did_lobbymusic) //well now this will play it anew each ti

	pregame_timeleft = PREGAME_LOBBY_TICKS
	boutput(world, "<b>Welcome to the pre-game lobby!</b><br>Please, setup your character and select ready. Game will start in [pregame_timeleft] seconds.")

	// let's try doing this here, yoloooo
	// zamu 20200823: idk if this is even getting called...
	//if (mining_controls?.mining_z && mining_controls.mining_z_asteroids_max)
	//	mining_controls.spawn_mining_z_asteroids()

	if(master_mode == "battle_royale")
		lobby_titlecard = new /datum/titlecard/battleroyale()
		lobby_titlecard.set_pregame_html()

	#ifdef I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
	for(var/mob/new_player/C in world)
		C.ready = 1
	pregame_timeleft = 1
	#endif

	var/did_mapvote = 0
	if (!player_capa)
		new /obj/overlay/zamujasa/round_start_countdown/encourage()
	var/obj/overlay/zamujasa/round_start_countdown/timer/title_countdown = new()
	while (current_state <= GAME_STATE_PREGAME)
		sleep(1 SECOND)
		// Start the countdown as normal, but hold it at 30 seconds until setup is complete
		if (!game_start_delayed && (pregame_timeleft > 30 || current_state == GAME_STATE_PREGAME))
			#ifndef I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO
			if(total_clients() <= 0)
				continue
			#endif
			pregame_timeleft--

			if (pregame_timeleft <= PREGAME_MUSIC_START && !did_lobbymusic) //do this to clients, for all already connected
				lobby_music()
				did_lobbymusic = 1
				//latecomers should be handled by client.dm in the sound section

			if (pregame_timeleft <= 60 && !did_mapvote)
				// do it here now instead of before the countdown
				// as part of the early start most people might not even see it at 150
				// so this makes it show up a minute before the game starts
				handle_mapvote()
				did_mapvote = 1

			if (title_countdown)
				title_countdown.update_time(pregame_timeleft)
		else if(title_countdown)
			title_countdown.update_time(-1)


		if(pregame_timeleft <= 0)
			current_state = GAME_STATE_SETTING_UP
			qdel(title_countdown)
			qdel(game_start_countdown)

#ifdef SERVER_SIDE_PROFILING
#ifdef SERVER_SIDE_PROFILING_PREGAME
#warn Profiler will output at pregame stage
	var/profile_out = file("data/profile/[time2text(world.realtime, "YYYY-MM-DD hh-mm-ss")]-pregame.log")
	profile_out << world.Profile(PROFILE_START | PROFILE_AVERAGE, "sendmaps", "json")
	world.log << "Dumped profiler data."
#endif

#if defined(SERVER_SIDE_PROFILING_INGAME_ONLY)
#warn Profiler reset for ingame stage
	// We're in game now, so reset profiler data
	world.Profile(PROFILE_RESTART | PROFILE_AVERAGE, "sendmaps", "json")
#elif !defined(SERVER_SIDE_PROFILING_FULL_ROUND)
#warn Profiler disabled after init
	// If we aren't doing ingame or full round then we're done with the profiler
	world.Profile(PROFILE_STOP | PROFILE_AVERAGE, "sendmaps", "json")
#endif
#endif


	SPAWN_DBG(0) setup()

/datum/controller/gameticker/proc/setup()
	set background = 1
	//Create and announce mode
	if(master_mode in list("secret","action","intrigue","wizard","alien"))
		src.hide_mode = 1

	switch(master_mode)
		if("random","secret") src.mode = config.pick_random_mode()
		if("action") src.mode = config.pick_mode(pick("nuclear","wizard","blob"))
		if("intrigue") src.mode = config.pick_mode(pick("mixed_rp", "traitor","changeling","vampire","conspiracy","spy_theft", prob(50); "extended"))
		if("pod_wars") src.mode = config.pick_mode("pod_wars")
		else src.mode = config.pick_mode(master_mode)

#if defined(MAP_OVERRIDE_POD_WARS)
	src.mode = config.pick_mode("pod_wars")
#endif

	if(hide_mode)
		#ifdef RP_MODE
		boutput(world, "<B>Have fun and RP!</B>")

		#else
		var/modes = sortList(config.get_used_mode_names())
		boutput(world, "<B>The current game mode is a secret!</B>")
		boutput(world, "<B>Possibilities:</B> [english_list(modes)]")

		#endif
	else
		src.mode.announce()

	// uhh is this where this goes??
	src.centralized_ai_laws = new /datum/ai_laws/asimov()

	//Configure mode and assign player to special mode stuff
	var/can_continue = src.mode.pre_setup()

	if(!can_continue)
		qdel(mode)

		current_state = GAME_STATE_PREGAME
		boutput(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")

		SPAWN_DBG(0) pregame()

		return 0

	logTheThing("debug", null, null, "Chosen game mode: [mode] ([master_mode]) on map [getMapNameFromID(map_setting)].")

	#if (defined(I_DONT_WANNA_WAIT_FOR_THIS_PREGAME_SHIT_JUST_GO)) || (DYNAMIC_ARRIVAL_SHUTTLE_TIME == 0)
	if (map_settings.arrivals_type == MAP_SPAWN_SHUTTLE_DYNAMIC)
		transit_controls.move_vehicle("arrivals_shuttle", "arrivals_dock", "(shuttle start skipped)")
	#else
	if (map_settings.arrivals_type == MAP_SPAWN_SHUTTLE_DYNAMIC)
		var/area/A = locate(/area/shuttle/arrival/pre_game)
		for (var/obj/machinery/door/airlock/an_door in A.machines)
			if (istype(an_door, /obj/machinery/door/airlock/external/shuttle_connect) || istype(an_door, /obj/machinery/door/airlock/pyro/external/shuttle_connect))
				if (!an_door.locked)
					an_door.toggle_bolt()
	#endif

	//Tell the participation recorder to queue player data while the round starts up
	participationRecorder.setHold()

	//initiliase this fucker in case we get spies (hard to say at this stage, since they also show up in mixed modes)
	ALL_ACCESS_CARD = new /obj/item/card/id/captains_spare()

#ifdef RP_MODE
	looc_allowed = 1
	boutput(world, "<B>LOOC has been automatically enabled.</B>")
	ooc_allowed = 0
	boutput(world, "<B>OOC has been automatically disabled until the round ends.</B>")
#else
	if (ASS_JAM || istype(src.mode, /datum/game_mode/construction))
		looc_allowed = 1
		boutput(world, "<B>LOOC has been automatically enabled.</B>")
	if (config.env == "dev")
		ooc_allowed = 1
		boutput(world, "<B>OOC enabled on dev server.</B>")
	else
		ooc_allowed = 0
		boutput(world, "<B>OOC has been automatically disabled until the round ends.</B>")
#endif

	Z_LOG_DEBUG("Game Start", "Animating client colors to black now")
	var/list/animateclients = list()
	for (var/client/C)
		if (!istype(C.mob,/mob/new_player))
			continue
		var/mob/new_player/P = C.mob
		if (P.ready)
			Z_LOG_DEBUG("Game Start/Ani", "Animating [P.client]")
			animateclients += P.client
			animate(P.client, color = "#000000", time = 5, easing = QUAD_EASING | EASE_IN)

	// Give said clients time to animate the fadeout before we do this...
	sleep(0.5 SECONDS)

	//Distribute jobs
	distribute_jobs()

	//Create player characters and transfer them
	create_characters()

	add_minds()

	// rip collar key, nerds murdered people for you as non-antags and it was annoying
	//implant_skull_key() //Solarium

#ifdef CREW_OBJECTIVES
	//Create objectives for the non-traitor/nogoodnik crew.
	generate_crew_objectives()
#endif

	//Equip characters
	equip_characters()

	if (!random_events.maintenance_event.disabled)
		//functionally start the maintenance system by populating the unmaintained crap list
		//2 machines per player at roundstart capped at 30 machines (15 players), plus 5-10 more
		random_events.force_event("Maintenance Arrears", "Round-Start ", min(2 * length(ticker.minds), 30) + rand(5, 10), TRUE)

	Z_LOG_DEBUG("Game Start", "Animating client colors to normal")
	for (var/client/C in animateclients)
		if (C)
			Z_LOG_DEBUG("Game Start/A", "Animating client [C]")
			var/target_color = "#FFFFFF"
			if(C.color != "#000000")
				target_color = C.color
			animate(C, color = "#000000", time = 0, flags = ANIMATION_END_NOW)
			animate(color = "#000000", time = 10, easing = QUAD_EASING | EASE_IN)
			animate(color = target_color, time = 10, easing = QUAD_EASING | EASE_IN)


	current_state = GAME_STATE_PLAYING
	round_time_check = world.timeofday

	SPAWN_DBG(0)
		ircbot.event("roundstart")
		mode.post_setup()

		event_wormhole_buildturflist()

		mode.post_post_setup()

		for(var/turf/T in landmarks[LANDMARK_ARTIFACT_SPAWN])
			var/spawnchance = landmarks[LANDMARK_ARTIFACT_SPAWN][T]
			if (prob(spawnchance))
				Artifact_Spawn(T)

		//moved out of initialize_worldgen now that that's called more than once
		var/obj/item/storage/toilet/Terlet = pick(by_type[/obj/item/storage/toilet])
		Terlet?.curse()

		shippingmarket.get_market_timeleft()

		logTheThing("ooc", null, null, "<b>Current round begins</b>")
		boutput(world, "<FONT class='notice'><B>Enjoy the game!</B></FONT>")
		boutput(world, "<span class='notice'><b>[prob(10)?"Pro ":"Cool "]Tip:</b> [pick(dd_file2list("strings/roundstart_hints.txt"))]</span>")
		// keywords -  pro tip: cool tip: protips roundstart tips roundstart hints

		//Setup the hub site logging
		var hublog_filename = "data/stats/data.txt"
		if (fexists(hublog_filename))
			fdel(hublog_filename)

		hublog = file(hublog_filename)
		hublog << ""

		//Tell the participation recorder that we're done FAFFING ABOUT
		participationRecorder.releaseHold()

	#if DYNAMIC_ARRIVAL_SHUTTLE_TIME > 0
	if (map_settings.arrivals_type == MAP_SPAWN_SHUTTLE_DYNAMIC)
		SPAWN_DBG (DYNAMIC_ARRIVAL_SHUTTLE_TIME)
			var/area/A = locate(/area/shuttle/arrival/pre_game)
			for (var/obj/machinery/door/airlock/an_door in A.machines)
				if (istype(an_door, /obj/machinery/door/airlock/external/shuttle_connect) || istype(an_door, /obj/machinery/door/airlock/pyro/external/shuttle_connect))
					if (an_door.locked)
						an_door.toggle_bolt()
			transit_controls.move_vehicle("arrivals_shuttle", "arrivals_dock", "(shuttle start normal)")
		SPAWN_DBG (DYNAMIC_ARRIVAL_SHUTTLE_TIME - (5 SECONDS))
			playsound(pick(get_area_turfs(/area/shuttle/arrival/pre_game)), "sound/effects/ship_engage.ogg", 100, 1)
	#endif

	SPAWN_DBG ((map_settings.arrivals_type == MAP_SPAWN_SHUTTLE_DYNAMIC) ? (10 MINUTES + DYNAMIC_ARRIVAL_SHUTTLE_TIME) : (10 MINUTES)) // 10 minutes in
		for(var/obj/machinery/power/monitor/smes/E in machine_registry[MACHINES_POWER])
			LAGCHECK(LAG_LOW)
			if(E.powernet?.avail <= 0)
				command_alert("Reports indicate that the engine on-board [station_name()] has not yet been started. Setting up the engine is strongly recommended, or else stationwide power failures may occur.", "Power Grid Warning")
			break

	processScheduler.start()

	if (total_clients() >= OVERLOAD_PLAYERCOUNT)
		world.tick_lag = OVERLOADED_WORLD_TICKLAG

//Okay this is kinda stupid, but mapSwitcher.autoVoteDelay which is now set to 30 seconds, (used to be 5 min).
//The voting will happen 30 seconds into the pre-game lobby. This is probably fine to leave. But if someone changes that var then it might start before the lobby timer ends.
/datum/controller/gameticker/proc/handle_mapvote()
	var/bustedMapSwitcher = isMapSwitcherBusted()
	if (!bustedMapSwitcher)
		SPAWN_DBG (mapSwitcher.autoVoteDelay)
			//Trigger the automatic map vote
			try
				mapSwitcher.startMapVote(duration = mapSwitcher.autoVoteDuration)
			catch (var/exception/e)
				logTheThing("admin", usr ? usr : src, null, "the automated map switch vote couldn't run because: [e.name]")
				logTheThing("diary", usr ? usr : src, null, "the automated map switch vote couldn't run because: [e.name]", "admin")
				message_admins("[key_name(usr ? usr : src)] the automated map switch vote couldn't run because: [e.name]")

/datum/controller/gameticker/proc/lobby_music()

	var/sound/music_sound = new()
	ticker.picked_music = pick(lobby_music) //collapse the waveform for the entire round
	music_sound.file = picked_music
	music_sound.wait = 0
	music_sound.repeat = 0
	music_sound.priority = 254
	music_sound.channel = admin_sound_channel //having this set to 999 removed layering music functionality -ZeWaka

	music_sound.frequency = 1

	music_sound.environment = -1
	music_sound.echo = -1

	SPAWN_DBG(0)
		for (var/client/C in clients)

			if (C.preferences?.skip_lobby_music)
				continue

			var/client_vol = C.getVolume(VOLUME_CHANNEL_ADMIN)

			if (!client_vol)
				continue

			C.sound_playing[ admin_sound_channel ][1] = 1
			C.sound_playing[ admin_sound_channel ][2] = VOLUME_CHANNEL_ADMIN

			music_sound.volume = client_vol
			C << music_sound

/datum/controller/gameticker
	proc/distribute_jobs()
		DivideOccupations()

	proc/create_characters()
		for (var/mob/new_player/player in mobs)
#ifdef TWITCH_BOT_ALLOWED
			if (player.twitch_bill_spawn)
				player.try_force_into_bill()
				continue
#endif

			if (player.ready)
				if (player.mind && player.mind.ckey)
					//Record player participation in this round via the goonhub API
					participationRecorder.record(player.mind.ckey)

				if (player.mind && player.mind.assigned_role == "AI")
					player.close_spawn_windows()
					player.AIize()
				//	var/mob/living/silicon/ai/A = player.AIize()
					//A.Equip_Bank_Purchase(A.mind.purchased_bank_item)

				else if (player.mind && player.mind.special_role == ROLE_WRAITH)
					player.close_spawn_windows()
					var/mob/wraith/W = player.make_wraith()
					if (W)
						W.set_loc(pick_landmark(LANDMARK_OBSERVER))
						logTheThing("debug", W, null, "<b>Late join</b>: assigned antagonist role: wraith.")
						antagWeighter.record(role = ROLE_WRAITH, ckey = W.ckey)

				else if (player.mind && player.mind.special_role == ROLE_BLOB)
					player.close_spawn_windows()
					var/mob/living/intangible/blob_overmind/B = player.make_blob()
					if (B)
						B.set_loc(pick_landmark(LANDMARK_OBSERVER))
						logTheThing("debug", B, null, "<b>Late join</b>: assigned antagonist role: blob.")
						antagWeighter.record(role = ROLE_BLOB, ckey = B.ckey)

				else if (player.mind && player.mind.special_role == ROLE_FLOCKMIND)
					player.close_spawn_windows()
					var/mob/living/intangible/flock/flockmind/F = player.make_flockmind()
					if (F)
						F.set_loc(pick_landmark(LANDMARK_OBSERVER))
						logTheThing("debug", F, null, "<b>Late join</b>: assigned antagonist role: flockmind.")
						antagWeighter.record(role = ROLE_FLOCKMIND, ckey = F.ckey)

				else if (player.mind)
					if (player.client.using_antag_token)
						player.client.use_antag_token()	//Removes a token from the player
					player.create_character()
					qdel(player)

	proc/add_minds(var/periodic_check = 0)
		for (var/mob/player in mobs)
			// Who cares about NPCs? Adding them here breaks all antagonist objectives
			// that attempt to scale with total player count (Convair880).
			if (player.mind && !istype(player, /mob/new_player) && player.client)
				if (!(player.mind in ticker.minds))
					if (periodic_check == 1)
						logTheThing("debug", player, null, "<b>Gameticker fallback:</b> re-added player to ticker.minds.")
					else
						logTheThing("debug", player, null, "<b>Gameticker setup:</b> added player to ticker.minds.")
					ticker.minds.Add(player.mind)

	proc/implant_skull_key()
		//Hello, I will sneak in a solarium thing here.
		if(!skull_key_assigned && ticker.minds.len > 5) //Okay enough gaming the system you pricks
			var/list/HL = list()
			for (var/mob/living/carbon/human/human in mobs)
				if (human.client)
					HL += human

			if(HL.len > 5)
				var/mob/living/carbon/human/H = pick(HL)
				if(istype(H))
					skull_key_assigned = 1
					SPAWN_DBG(5 SECONDS)
						if(H.organHolder && H.organHolder.skull)
							H.organHolder.skull.key = new /obj/item/device/key/skull (H.organHolder.skull)
							logTheThing("debug", H, null, "has the dubious pleasure of having a key embedded in their skull.")
						else
							skull_key_assigned = 0
		else if(!skull_key_assigned)
			logTheThing("debug", null, null, "<B>SpyGuy/collar key:</B> Did not implant a key because there was not enough players.")

	proc/equip_characters()
		for(var/mob/living/carbon/human/player in mobs)
			if(player.mind && player.mind.assigned_role)
				if(player.mind.assigned_role != "MODE")
					SPAWN_DBG(0)
						player.Equip_Rank(player.mind.assigned_role)

	proc/process()
		if(current_state != GAME_STATE_PLAYING)
			return 0

		updateRoundTime()

		mode.process()
#ifdef HALLOWEEN
		spooktober_GH.update()
#endif

		emergency_shuttle.process()

		#if DM_VERSION >= 514
		if (useTimeDilation)//TIME_DILATION_ENABLED set this
			if (world.time > last_try_dilate + TICKLAG_DILATE_INTERVAL) //interval separate from the process loop. maybe consider moving this for cleanup later (its own process loop with diff. interval?)
				last_try_dilate = world.time

				// adjust the counter up or down and keep it within the set boundaries
				if (world.map_cpu >= TICKLAG_MAPCPU_MAX)
					if (highMapCpuCount < TICKLAG_INCREASE_THRESHOLD)
						highMapCpuCount++
				else if (world.map_cpu <= TICKLAG_MAPCPU_MIN)
					if (highMapCpuCount > -TICKLAG_DECREASE_THRESHOLD)
						highMapCpuCount--

				// adjust the tick_lag, if needed
				var/dilated_tick_lag = world.tick_lag
				if (highMapCpuCount >= TICKLAG_INCREASE_THRESHOLD)
					dilated_tick_lag = min(world.tick_lag + TICKLAG_DILATION_INC,	timeDilationUpperBound)
				else if (highMapCpuCount <= -TICKLAG_DECREASE_THRESHOLD)
					dilated_tick_lag = max(world.tick_lag - TICKLAG_DILATION_DEC, timeDilationLowerBound)

				// only set the value if it changed! earlier iteration of this was
				// setting world.tick_lag very often, which caused instability with
				// the networking. do not spam change world.tick_lag! you will regret it!
				if (world.tick_lag != dilated_tick_lag)
					world.tick_lag = dilated_tick_lag
					highMapCpuCount = 0
		#endif

		// Minds are sometimes kicked out of the global list, hence the fallback (Convair880).
		if (src.last_readd_lost_minds_to_ticker && world.time > src.last_readd_lost_minds_to_ticker + 1800)
			src.add_minds(1)
			src.last_readd_lost_minds_to_ticker = world.time

		if(mode.check_finished())
			current_state = GAME_STATE_FINISHED

			// This does a little more than just declare - it handles all end of round processing
			//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] Starting declare_completion.")
			try
				declare_completion()
			catch(var/exception/e)
				logTheThing("debug", null, null, "Game Completion Runtime: [e.file]:[e.line] - [e.name] - [e.desc]")
				logTheThing("diary", null, null, "Game Completion Runtime: [e.file]:[e.line] - [e.name] - [e.desc]", "debug")

			//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] Finished declare_completion. The round is now over.")

			// Official go-ahead to be an end-of-round asshole
			boutput(world, "<h3>The round has ended!</h3><strong style='color: #393;'>Further actions will have no impact on round results. Go hog wild!</strong>")

			SPAWN_DBG(0)
				change_ghost_invisibility(INVIS_NONE)

			// i feel like this should probably be a proc call somewhere instead but w/e
			if (!ooc_allowed)
				ooc_allowed = 1
				boutput(world, "<B>OOC is now enabled.</B>")

			SPAWN_DBG(5 SECONDS)
				//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] game-ending spawn happening")

				boutput(world, "<span class='bold notice'>A new round will begin soon.</span>")

				var/datum/hud/roundend/roundend_countdown = new()

				for (var/client/C in clients)
					roundend_countdown.add_client(C)
					C.save_misc_skin_settings_to_cloud() //congrats 4 making it to end of round lets save some shit while we have you

				var/roundend_time = 90
				while (roundend_time >= 0)
					roundend_countdown.update_time(roundend_time)
					sleep(1 SECONDS)
					roundend_time--

				//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] one minute delay, game should restart now")
				if (game_end_delayed == 1)
					roundend_countdown.update_delayed()

					message_admins("<span class='internal'>Server would have restarted now, but the restart has been delayed[game_end_delayer ? " by [game_end_delayer]" : null]. Remove the delay for an immediate restart.</span>")
					game_end_delayed = 2
					var/ircmsg[] = new()
					ircmsg["msg"] = "Server would have restarted now, but the restart has been delayed[game_end_delayer ? " by [game_end_delayer]" : null]."
					ircbot.export("admin", ircmsg)
				else
					// Put together a package of score data that we can hand off to the discord bot
					var/list/roundend_score = list(
						"map" = getMapNameFromID(map_setting),
						"survival" = score_tracker.score_crew_survival_rate,
						"sec_scr"  = score_tracker.final_score_sec,
						"eng_scr"  = score_tracker.final_score_eng,
						"civ_scr"  = score_tracker.final_score_civ,
						"res_scr"  = score_tracker.final_score_res,
						"grade"    = score_tracker.grade,
						"m_damaged" = score_tracker.most_damaged_escapee,
						"r_escaped" = score_tracker.richest_escapee,
						"r_total"  = score_tracker.richest_total,
						"beepsky"  = score_tracker.beepsky_alive,
						"farts"    = fartcount,
						"wead"     = weadegrowne,
						"doinks"   = doinkssparked,
						"clowns"   = clownabuse
						)
					ircbot.event("roundend", list("score" = roundend_score))
					//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] REBOOTING THE SERVER!!!!!!!!!!!!!!!!!")
					Reboot_server()

		return 1

	proc/updateRoundTime()
		if (round_time_check)
			var/elapsed = world.timeofday - round_time_check
			round_time_check = world.timeofday

			if (round_time_check == 0) // on the slim chance that this happens exactly on a timeofday rollover
				round_time_check = 1   // make it nonzero so it doesn't quit updating

			if (elapsed > 0)
				ticker.round_elapsed_ticks += elapsed

/datum/controller/gameticker/proc/declare_completion()
	//End of round statistic collection for goonhub

	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] statlog_traitors")
	statlog_traitors()
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] statlog_ailaws")
	statlog_ailaws(0)
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] round_end_data")
	round_end_data(1) //Export round end packet (normal completion)

	var/pets_rescued = 0
	for(var/pet in by_cat[TR_CAT_PETS])
		if(iscritter(pet))
			var/obj/critter/P = pet
			if(P.alive && in_centcom(P)) pets_rescued++
		else if(ismobcritter(pet))
			var/mob/living/critter/P = pet
			if(isalive(P) && in_centcom(P)) pets_rescued++

	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] Processing end-of-round generic medals")
	//var/list/all_the_baddies = ticker.mode.traitors + ticker.mode.token_players + ticker.mode.Agimmicks + ticker.mode.former_antagonists
	for(var/mob/living/player in mobs)
		if (player.client)
			if (!isdead(player))
				if (in_centcom(player))
					player.unlock_medal("100M dash", 1)
					if (pets_rescued >= 7)
						player.unlock_medal("Noah's Shuttle", 1)
				player.unlock_medal("Survivor", 1)

				if (player.check_contents_for(/obj/item/gnomechompski))
					player.unlock_medal("Guardin' gnome", 1)

				if (player.mind.assigned_role == "Security Assistant")
					player.unlock_medal("I helped!", 1)

				if (ishuman(player))
					var/mob/living/carbon/human/H = player
					if (H && istype(H) && H.implant && H.implant.len > 0)
						var/bullets = 0
						for (var/obj/item/implant/I in H)
							if (istype(I, /obj/item/implant/projectile))
								bullets = 1
								break
						if (bullets > 0)
							H.unlock_medal("It's just a flesh wound!", 1)
					if (H.limbs && (!H.limbs.l_arm && !H.limbs.r_arm))
						H.unlock_medal("Mostly Armless", 1)

#ifdef CREW_OBJECTIVES
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] Processing crew objectives")
	var/list/successfulCrew = list()
	for (var/datum/mind/crewMind in minds)
		if (!crewMind.current || !length(crewMind.objectives))
			continue

		var/count = 0
		var/allComplete = 1
		crewMind.all_objs = 1
		for (var/datum/objective/crew/CO in crewMind.objectives)
			count++
			switch(CO.check_completion())
				if (SUCCEEDED)
					crewMind.completed_objs++
					boutput(crewMind.current, "<B>Objective #[count]</B>: [CO.explanation_text] <span class='success'><B>Success</B></span>")
					logTheThing("diary",crewMind,null,"completed objective: [CO.explanation_text]")
					if (!isnull(CO.medal_name) && !isnull(crewMind.current))
						crewMind.current.unlock_medal(CO.medal_name, CO.medal_announce)
				if (FAILED)
					boutput(crewMind.current, "<B>Objective #[count]</B>: [CO.explanation_text] <span class='alert'>Failed</span>")
					logTheThing("diary",crewMind,null,"failed objective: [CO.explanation_text]. Bummer!")
					allComplete = 0
					crewMind.all_objs = 0
				if (NO_OPPORTUNITY)
					crewMind.completed_objs++
					boutput(crewMind.current, "<B>Objective #[count]</B>: [CO.explanation_text] <span class='success'><B>N/A</B></span>")
					logTheThing("diary",crewMind,null,"uncompletable objective: [CO.explanation_text]")
					//no medal

		if (allComplete && count)
			successfulCrew += "[crewMind.current.real_name] ([crewMind.key])"
#endif

	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] mode.declare_completion()")
	mode.declare_completion()
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] mode.declare_completion() done - calculating score")

	score_tracker.calculate_score()
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] score calculated")

	var/final_score = score_tracker.final_score_all
	if (final_score > 200)
		final_score = 200
	else if (final_score <= 0)
		final_score = 0
	else
		final_score = 100

	if(!score_tracker.score_calculated)
		final_score = 100

	boutput(world, score_tracker.escapee_facts())
	//boutput(world, score_tracker.heisenhat_stats())
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] ai law display")
	boutput(world, "<b>AIs and Cyborgs had the following laws at the end of the game:</b><br>[ticker.centralized_ai_laws.format_for_logs()]")


	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] resetting gauntlet (why? who cares! the game is over!)")
	if (gauntlet_controller.state)
		gauntlet_controller.resetArena()
#ifdef CREW_OBJECTIVES
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] displaying completed crew objectives")
	if (successfulCrew.len)
		boutput(world, "<B>The following crewmembers completed all of their Crew Objectives:</B><br>[successfulCrew.Join("<br>")]<br>Good job!")
	else
		boutput(world, "<B>Nobody completed all of their Crew Objectives!</B>")
#endif
#ifdef MISCREANTS
	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] displaying miscreants")
	boutput(world, "<B>Miscreants:</B>")
	if(miscreants.len == 0) boutput(world, "None!")
	for(var/datum/mind/miscreantMind in miscreants)
		if(!miscreantMind.objectives.len)
			continue

		var/miscreant_info = "[miscreantMind.key]"
		if(miscreantMind.current) miscreant_info = "[miscreantMind.current.real_name] ([miscreantMind.key])"

		boutput(world, "<B>[miscreant_info] was a miscreant!</B>")
		for (var/datum/objective/miscreant/O in miscreantMind.objectives)
			boutput(world, "Objective: [O.explanation_text] <B>Maybe</B>")
#endif

	for_by_tcl(P, /obj/bookshelf/persistent) //make the bookshelf save its contents
		P.build_curr_contents()

	global.save_noticeboards()



	logTheThing("debug", null, null, "Done with books")

	award_archived_round_xp()

	logTheThing("debug", null, null, "Spawned XP")

	SPAWN_DBG(0)
		//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] creds/new")
		var/chui/window/crew_credits/creds = new
		//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] displaying tickets and scores")
		for(var/mob/E in mobs)
			if(E.client)
				if (E.client.preferences.view_tickets)
					//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] sending tickets to [E.ckey]")
					E.showtickets()
					//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] done sending tickets to [E.ckey]")

				if (E.client.preferences.view_score)
					//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] sending crew credits to [E.ckey]")
					creds.Subscribe(E.client)
					//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] done crew credits to [E.ckey]")
				SPAWN_DBG(0) show_xp_summary(E.key, E)

		//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] done showing tickets/scores")

	logTheThing("debug", null, null, "Did credits")

	//logTheThing("debug", null, null, "Zamujasa: [world.timeofday] finished spacebux updates")

	var/list/playtimes = list() //associative list with the format list("ckeys\[[player_ckey]]" = playtime_in_seconds)
	for_by_tcl(P, /datum/player)
		if (!P.ckey)
			continue
		P.log_leave_time() //get our final playtime for the round (wont cause errors with people who already d/ced bc of smart code)
		if (!P.current_playtime)
			continue
		playtimes["ckeys\[[P.ckey]]"] = floor(P.current_playtime / (1 SECOND)) //rounds 1/10th seconds to seconds
	try
		apiHandler.queryAPI("playtime/record-multiple", playtimes)
	catch(var/exception/e)
		logTheThing("debug", null, null, "playtime was unable to be logged because of: [e.name]")
		logTheThing("diary", null, null, "playtime was unable to be logged because of: [e.name]", "debug")
	return 1

/////
/////SETTING UP THE GAME
/////

/////
/////MAIN PROCESS PART
/////
/*
/datum/controller/gameticker/proc/game_process()

	switch(mode.name)
		if("deathmatch","monkey","nuclear emergency","Corporate Restructuring","revolution","traitor",
		"wizard","extended")
			do
				if (!( shuttle_frozen ))
					if (src.timing == 1)
						src.timeleft -= 10
					else
						if (src.timing == -1.0)
							src.timeleft += 10
							if (src.timeleft >= shuttle_time_to_arrive)
								src.timeleft = null
								src.timing = 0
				if (prob(0.5))
					spawn_meteors()
				if (src.timeleft <= 0 && src.timing)
					src.timeup()
				sleep(1 SECOND)
			while(src.processing)
			return
//Standard extended process (incorporates most game modes).
//Put yours in here if you don't know where else to put it.
		if("AI malfunction")
			do
				check_win()
				ticker.AItime += 10
				sleep(1 SECOND)
				if (ticker.AItime == 6000)
					boutput(world, "<FONT size = 3><B>Cent. Com. Update</B> AI Malfunction Detected</FONT>")
					boutput(world, "<span class='alert'>It seems we have provided you with a malfunctioning AI. We're very sorry.</span>")
			while(src.processing)
			return
//malfunction process
		if("meteor")
			do
				if (!( shuttle_frozen ))
					if (src.timing == 1)
						src.timeleft -= 10
					else
						if (src.timing == -1.0)
							src.timeleft += 10
							if (src.timeleft >= shuttle_time_to_arrive)
								src.timeleft = null
								src.timing = 0
				for(var/i = 0; i < 10; i++)
					spawn_meteors()
				if (src.timeleft <= 0 && src.timing)
					src.timeup()
				sleep(1 SECOND)
			while(src.processing)
			return
//meteor mode!!! MORE METEORS!!!
		else
			return
//Anything else, like sandbox, return.
*/
