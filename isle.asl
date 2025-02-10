// LEGO Island (Mindscape, 1997)
// Autosplitter by Ramen2X

// Supports Danish v1.1 (speedrunning standard)

state("ISLE", "Danish")
{
	// LegoGameState members

	// https://github.com/isledecomp/isle/blob/master/LEGO1/lego/legoomni/include/legogamestate.h#L246
	short playerCount: "LEGO1.DLL", 0x001015D0, 0xE4, 0x50, 0x96C, 0x30, 0x788;
	// https://github.com/isledecomp/isle/blob/master/LEGO1/lego/legoomni/include/legogamestate.h#L252
	byte currentArea: "LEGO1.DLL", 0x001015D0, 0xF8, 0x3C, 0x958, 0x10, 0x72C;

	// CarRace members

	// https://github.com/isledecomp/isle/blob/master/LEGO1/lego/legoomni/include/carrace.h#L82
	int firstPlaceAction: "LEGO1.DLL", 0x001015D0, 0x70, 0x84, 0x44, 0x90;

	// TowTrackMissionState members

	// https://github.com/isledecomp/isle/blob/master/LEGO1/lego/legoomni/include/towtrack.h#L137
	short towHighScore: "LEGO1.DLL", 0x001015D0, 0x7C, 0x40, 0xC0, 0x40, 0x74, 0xA8, 0x1C;

	// HospitalState members

	// https://github.com/isledecomp/isle/blob/master/LEGO1/lego/legoomni/include/hospital.h#L43
	short hospMissionState: "LEGO1.DLL", 0x001015D0, 0x9C, 0x08, 0x1C, 0x08;

	// MxTransitionManager members

	// https://github.com/isledecomp/isle/blob/master/LEGO1/lego/legoomni/include/mxtransitionmanager.h#L75
	byte mode: "LEGO1.DLL", 0x001015D0, 0x138, 0x2C;

	// IsleApp members

	// https://github.com/isledecomp/isle/blob/master/ISLE/isleapp.h#L76
	int cursorCurrent : "ISLE.EXE", 0x00010030, 0x88;
}

init
{
	if (modules.First().ModuleMemorySize == 106496)
		version = "Danish";

	// Keep track of our past splits so we don't infinitely split
	vars.splitIndex = new List<bool>()
	{
		false, // Act 2 entered
		false, // Act 2 complete, Act 3 entered
		false, // Act 3 complete
		false, // Hospital mission complete
		false, // Jetski race complete
		false, // Gas Station mission complete
		false, // Racetrack race complete
	};
}

startup
{
	// FIXME: Add support for 100% and
	// add settings to switch between them
}

start
{
	// If player count in regbook was incremented,
	// a new player was created, start the timer
	return old.playerCount + 1 == current.playerCount;
}

split
{
	// If going into Act 2 from pizza delivery mission
	if (old.currentArea == 1 && current.currentArea == 46 && !vars.splitIndex[0])
	{
		vars.splitIndex[0] = true;
		return true;
	}

	// If going into Act 3 from Helicopter rebuild
	if (old.currentArea == 36 && current.currentArea == 47 && !vars.splitIndex[1])
	{
		vars.splitIndex[1] = true;
		return true;
	}

	// If going back to the Information Center from Act 3
	if (old.currentArea == 47 && current.currentArea == 2 && !vars.splitIndex[2])
	{
		vars.splitIndex[2] = true;
		return true;
	}

	// If completed the Hospital mission
	//
	// This variable is a member of HospitalState that appears to be set
	// to 2 when a cutscene starts; this is why we check the previous area
	if (old.hospMissionState == 0 && current.hospMissionState == 2 && old.currentArea == 66 && !vars.splitIndex[3])
	{
		vars.splitIndex[3] = true;
		return true;
	}

	// If returning from the Jetski race
	if (old.currentArea == 14 && current.currentArea == 15 && !vars.splitIndex[4])
	{
		vars.splitIndex[4] = true;
		return true;
	}

	// If completed the Gas Station mission
	//
	// This variable is a member of TowTrackState that holds the recorded
	// score as an enum; 0 represents no score and 3 represents a red brick
	if (old.towHighScore == 0 && current.towHighScore == 3 && !vars.splitIndex[5])
	{
		vars.splitIndex[5] = true;
		return true;
	}

	// If completed the racetrack race
	//
	// This variable is a member of CarRace holding action IDs;
	// a randomly selected one from a list of three is put into
	// this variable if the player achieves first place in the race
	if (old.firstPlaceAction == -1 && current.firstPlaceAction == 519 || current.firstPlaceAction == 520 || current.firstPlaceAction == 521 && !vars.splitIndex[6])
	{
		vars.splitIndex[6] = true;
		return true;
	}
}

isLoading
{
	// If current cursor is set to the Wait indicator and Mosaic transition is playing
	//
	// cursorCurrent is a member variable of IsleApp that holds the current cursor;
	// I didn't want to go through the effort of defining the HCURSOR struct here,
	// so I'm just using a hacky method to check if it's been updated
	// using the integer representation of its value
	//
	// mode is a member variable of MxTransitionManager that holds the transition animation type
	// The enum is here: https://github.com/isledecomp/isle/blob/master/LEGO1/lego/legoomni/include/mxtransitionmanager.h#L38
	// All of these values except for idle and mosaic go completely unused by the game
	//
	// We check the transition type in addtion to the cursor to make sure we're not pausing
	// in the potential case that the cursor gets updated in some other non-loading scenario
	if (current.cursorCurrent > old.cursorCurrent && current.mode == 3)
		return true;

	// If current cursor is set to the normal pointer and Mosaic transition has stopped
	if (old.cursorCurrent > current.cursorCurrent && current.mode == 0)
		return false;
}

