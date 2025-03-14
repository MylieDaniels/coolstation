/datum/bioEffect/mutantrace
	name = "Saurian Genetics"
	desc = "Enables vestigal non-mammal traits in the subject's body."
	id = "lizard"
	mutantrace_option = "Lizard"
	effectType = EFFECT_TYPE_MUTANTRACE
	probability = 33
	msgGain = "Your skin feels oddly dry."
	msgLose = "Your scales fall off."
	mob_exclusive = /mob/living/carbon/human/
	var/mutantrace_path = /datum/mutantrace/lizard
	lockProb = 33
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("G","C")
	lockedTries = 8
	curable_by_mutadone = 0
	icon_state  = "lizard"

	OnAdd()
		..() // caaaaaaall yooooooour paaaareeeeents
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			for (var/ID in H.bioHolder.effects)
				// clear away any existing mutantraces first
				if (istype(H.bioHolder.GetEffect(ID), /datum/bioEffect/mutantrace) && ID != src.id)
					H.bioHolder.RemoveEffect(ID)
			if (!istype(H.mutantrace, src.mutantrace_path))
				H.set_mutantrace(src.mutantrace_path)
		return

	OnRemove()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (istype(H.mutantrace,src.mutantrace_path))
				H.set_mutantrace(null)
		return

	OnLife()
		if(..()) return
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (!istype(H.mutantrace, src.mutantrace_path))
				holder.RemoveEffect(id)
		return

/datum/bioEffect/mutantrace/flashy
	name = "Bioluminescent Overdrive"
	desc = "Enables highly bioluminescent cells in the subject's skin."
	id = "flashman"
	mutantrace_option = "Flashy"
	mutantrace_path = /datum/mutantrace/flashy
	msgGain = "Your skin begins flashing!"
	msgLose = "Your flashy glow fades away."
	icon_state  = "flashy"

/datum/bioEffect/mutantrace/skeleton
	name = "Ossification"
	desc = "Compacts the subject's living tissues into their skeleton. This is somehow not fatal."
	id = "skeleton"
	mutantrace_option = "Skeleton"
	mutantrace_path = /datum/mutantrace/skeleton
	msgGain = "You feel kinda thin."
	msgLose = "You've put on a bit more weight."
	icon_state  = "skeleton"
	isBad = 1

/datum/bioEffect/mutantrace/ithillid
	name = "Aquatic Genetics"
	desc = "Re-enables ancient vestigal genes in the subject's body."
	id = "ithillid"
	mutantrace_option = "Squid"
	mutantrace_path = /datum/mutantrace/ithillid
	msgGain = "You feel wet and squishy."
	msgLose = "You feel dry."
	icon_state  = "squid"

/datum/bioEffect/mutantrace/roach
	name = "Blattodean Genetics"
	desc = "Re-enables ancient vestigal genes in the subject's body."
	id = "roach"
	mutantrace_option = "Roach"
	mutantrace_path = /datum/mutantrace/roach
	msgGain = "You feel like crawling into somewhere nice and dark."
	msgLose = "You shed your roachy skin!"
	icon_state  = "roach"

/datum/bioEffect/mutantrace/monkey
	name = "Primal Genetics"
	desc = "Enables and exaggerates vestigal ape traits."
	id = "monkey"
	mutantrace_option = "Monkey"
	mutantrace_path = /datum/mutantrace/monkey
	research_level = EFFECT_RESEARCH_ACTIVATED
	msgGain = "You go bananas!"
	msgLose = "You do the evolution."
	icon_state  = "monkey"

/datum/bioEffect/mutantrace/seamonkey
	name = "Aquatic Primal Genetics"
	desc = "Enables and exaggerates vestigal aquatic ape traits."
	id = "seamonkey"
	mutantrace_option = "Seamonkey"
	mutantrace_path = /datum/mutantrace/monkey/seamonkey
	msgGain = "You go bananas!"
	msgLose = "You do the evolution."
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	reclaim_fail = 100
	icon_state  = "monkey"

/datum/bioEffect/mutantrace/cat
	name = "Feline Genetics"
	desc = "Morphs the subject's traits to appear more feline in nature."
	id = "cat"
	mutantrace_option = "Cat"
	mutantrace_path = /datum/mutantrace/cat
	msgGain = "You feel especially hairy."
	msgLose = "You fur fall out."
	icon_state  = "cat"


/datum/bioEffect/mutantrace/cow
	name = "Bovine Genetics"
	desc = "The subject takes on the appearance of a domesticated space cow and gains milk production."
	id = "cow"
	mutantrace_option = "Cow"
	mutantrace_path = /datum/mutantrace/cow
	msgGain = "You feel like you're ready for some Cow RP."
	msgLose = "Your udders fall off!"
	icon_state  = "cow"

/datum/bioEffect/mutantrace/birb
	name = "Avian Genetics"
	desc = "The subject birds up."
	id = "birb"
	mutantrace_option = "Birb"
	mutantrace_path = /datum/mutantrace/birb
	msgGain = "You feel the need to collect sticks and yell swears at tourists."
	msgLose = "Your beautiful feathers start to fall out!"
	icon_state = "bird"

/datum/bioEffect/mutantrace/fert
	name = "Musteline Genetics"
	desc = "The subject gets \'slinky and stinky\', whatever that means."
	id = "fert"
	mutantrace_option = "Ferret"
	mutantrace_path = /datum/mutantrace/fert
	msgGain = "You feel REALLY EXCITED and want to jump around a bit."
	msgLose = "You calm down a lot, but for some reason you still stink???"
	icon_state  = "fert"



/datum/bioEffect/mutantrace/chicken
	name = "Experimental Strain Epsilon Gamma Gamma #5"
	desc = "For exclusive use under the supervision of Dr. Cox MD. Unauthorized modification, replication, and distribution prohibited."
	id = "chicken"
	mutantrace_option = "Chicken"
	mutantrace_path = /datum/mutantrace/chicken
	msgGain = "bwah...bwah..bwah...BWAHCAWCK!"
	msgLose = "Well that clucks."
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	reclaim_fail = 100
