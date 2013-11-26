class X_COM_MusicManager extends Info
	config(XCom);

//=============================================================================
// Variables: General
//=============================================================================
var float	MusicStartTime;			/** Time at which current track started playing */
var	int		LastBeat;				/** Count of beats since MusicStartTime */

/** This is the temp (in Beats Per Minutes) of the track that is currently playing **/
var private float CurrTempo;
var private float CurrFadeFactor;				/** Pre-computed MusicVolume/CrossFadeTime deltatime multiplier for cross-fading */

var X_COM_PlayerController PlayerOwner;	/** Owner of this MusicManager */

var globalconfig float MusicVolume;	/** Maximum volume for music audiocomponents (max value for VolumeMultiplier). */

enum EMusicState
{
	EMST_music_MainMenu,

	EMST_music_Geo_MainTheme,
	EMST_music_Geo_Fight,
	EMST_music_Geo_inBase,
	EMST_music_Geo_inUfopaedia,

	EMST_music_Tactics_MainTheme,
	EMST_music_Tactics_Action,
	EMST_music_Tactics_Mission_Win,
	EMST_music_Tactics_Mission_Fail,
};
var EMusicState                         CurrentState;		/** Current Music state (reflects which track is active). */

var AudioComponent CurrentTrack;	/** Track being ramped up, rather than faded out */
var AudioComponent  MusicTracks[8]; /** Music Tracks - see ChangeTrack() for definition of slots. */

//=============================================================================
// Functions:
//=============================================================================
/* CreateNewTrack()
* Create a new AudioComponent to play MusicCue.
* @param MusicCue:  the sound cue to play
* @returns the new audio component
*/
function AudioComponent CreateNewTrack(SoundCue MusicCue)
{
	local AudioComponent AC;

	AC = CreateAudioComponent( MusicCue, false, true );

	// AC will be none if -nosound option used
	if ( AC != None )
	{
		AC.bAllowSpatialization = false;
		AC.bShouldRemainActiveIfDropped = true;
	}
	return AC;
}

function Tick(float DeltaTime)
{
	local float NumBeats;
	local int i;

	// Cross-fade
	if ( CurrentTrack != None && CurrentTrack.VolumeMultiplier < MusicVolume )
	{
		// ramp up current track
		CurrentTrack.VolumeMultiplier = FMin(MusicVolume, CurrentTrack.VolumeMultiplier + CurrFadeFactor*DeltaTime);
	}

	for ( i=0; i<6; i++ )
	{
		// ramp down other tracks
		if ( (MusicTracks[i] != None) && (MusicTracks[i] != CurrentTrack) && (MusicTracks[i].VolumeMultiplier > 0.f) )
		{
			MusicTracks[i].VolumeMultiplier = MusicTracks[i].VolumeMultiplier - CurrFadeFactor*DeltaTime;
			if ( MusicTracks[i].VolumeMultiplier <= 0.f )
			{
				//`log( "fading out in tick" );
				MusicTracks[i].VolumeMultiplier = 0.f;
				MusicTracks[i].Stop();
			}
		}
	}

	NumBeats = (WorldInfo.TimeSeconds - MusicStartTime) * CurrTempo/60;
	if ( NumBeats - LastBeat < 1 )
	{
		return;
	}

	LastBeat = int(NumBeats);
	if ( LastBeat % 2 != 0 )
	{
		return;
	}
}

/** ChangeTrack()
* @param NewState  New music state (track to ramp up).
*/
function ChangeTrack(EMusicState NewState)
{
	local AudioComponent NewTrack;

	//`log( "MusicManager:  ChangeTrack: " $ NewState );

	if ( CurrentState == NewState )
	{
		//`log( "MusicManager:  ChangeTrack:  new and current state are the same" );
		return;
	}

	CurrentState = NewState;

	// select appropriate track
	Switch( NewState )
	{
		case EMST_music_MainMenu:
			if ( MusicTracks[0] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == class'X_COM_Settings'.default.music_MainMenu) )
				{
					MusicTracks[0] = CurrentTrack;
				}
				else
				{
					MusicTracks[0] = CreateNewTrack(class'X_COM_Settings'.default.music_MainMenu);
				}
			}
			NewTrack = MusicTracks[0];
			CurrTempo = class'X_COM_Settings'.default.music_Tempo;
			CurrFadeFactor = MusicVolume/class'X_COM_Settings'.default.CrossfadeToMeNumMeasuresDuration;
		break;

		case EMST_music_Geo_MainTheme:
			if ( MusicTracks[1] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == class'X_COM_Settings'.default.music_Geo_MainTheme) )
				{
					MusicTracks[1] = CurrentTrack;
				}
				else
				{
					MusicTracks[1] = CreateNewTrack(class'X_COM_Settings'.default.music_Geo_MainTheme);
				}
			}
			NewTrack = MusicTracks[1];
			CurrTempo = class'X_COM_Settings'.default.music_Tempo;
			CurrFadeFactor = MusicVolume/class'X_COM_Settings'.default.CrossfadeToMeNumMeasuresDuration;
		break;

		case EMST_music_Geo_Fight:
			if ( MusicTracks[2] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == class'X_COM_Settings'.default.music_Geo_Fight) )
				{
					MusicTracks[2] = CurrentTrack;
				}
				else
				{
					MusicTracks[2] = CreateNewTrack(class'X_COM_Settings'.default.music_Geo_Fight);
				}
			}
			NewTrack = MusicTracks[2];
			CurrTempo = class'X_COM_Settings'.default.music_Tempo;
			CurrFadeFactor = MusicVolume/class'X_COM_Settings'.default.CrossfadeToMeNumMeasuresDuration;
		break;

		case EMST_music_Geo_inBase:
			if ( MusicTracks[3] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == class'X_COM_Settings'.default.music_Geo_inBase) )
				{
					MusicTracks[3] = CurrentTrack;
				}
				else
				{
					MusicTracks[3] = CreateNewTrack(class'X_COM_Settings'.default.music_Geo_inBase);
				}
			}
			NewTrack = MusicTracks[3];
			CurrTempo = class'X_COM_Settings'.default.music_Tempo;
			CurrFadeFactor = MusicVolume/class'X_COM_Settings'.default.CrossfadeToMeNumMeasuresDuration;
		break;

		case EMST_music_Geo_inUfopaedia:
			if ( MusicTracks[4] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == class'X_COM_Settings'.default.music_Geo_inUfopaedia) )
				{
					MusicTracks[4] = CurrentTrack;
				}
				else
				{
					MusicTracks[4] = CreateNewTrack(class'X_COM_Settings'.default.music_Geo_inUfopaedia);
				}
			}
			NewTrack = MusicTracks[4];
			CurrTempo = class'X_COM_Settings'.default.music_Tempo;
			CurrFadeFactor = MusicVolume/class'X_COM_Settings'.default.CrossfadeToMeNumMeasuresDuration;
		break;

		case EMST_music_Tactics_MainTheme:
			if ( MusicTracks[5] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == class'X_COM_Settings'.default.music_Tactics_MainTheme) )
				{
					MusicTracks[5] = CurrentTrack;
				}
				else
				{
					MusicTracks[5] = CreateNewTrack(class'X_COM_Settings'.default.music_Tactics_MainTheme);
				}
			}
			NewTrack = MusicTracks[5];
			CurrTempo = class'X_COM_Settings'.default.music_Tempo;
			CurrFadeFactor = MusicVolume/class'X_COM_Settings'.default.CrossfadeToMeNumMeasuresDuration;
		break;

		case EMST_music_Tactics_Action:
			if ( MusicTracks[6] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == class'X_COM_Settings'.default.music_Tactics_Action) )
				{
					MusicTracks[6] = CurrentTrack;
				}
				else
				{
					MusicTracks[6] = CreateNewTrack(class'X_COM_Settings'.default.music_Tactics_Action);
				}
			}
			NewTrack = MusicTracks[6];
			CurrTempo = class'X_COM_Settings'.default.music_Tempo;
			CurrFadeFactor = MusicVolume/class'X_COM_Settings'.default.CrossfadeToMeNumMeasuresDuration;
		break;

		case EMST_music_Tactics_Mission_Win:
			if ( MusicTracks[7] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == class'X_COM_Settings'.default.music_Tactics_Mission_Win) )
				{
					MusicTracks[7] = CurrentTrack;
				}
				else
				{
					MusicTracks[7] = CreateNewTrack(class'X_COM_Settings'.default.music_Tactics_Mission_Win);
				}
			}
			NewTrack = MusicTracks[7];
			CurrTempo = class'X_COM_Settings'.default.music_Tempo;
			CurrFadeFactor = MusicVolume/class'X_COM_Settings'.default.CrossfadeToMeNumMeasuresDuration;
		break;

		case EMST_music_Tactics_Mission_Fail:
			if ( MusicTracks[8] == None ) 
			{
				if ( (CurrentTrack != None) && (CurrentTrack.SoundCue == class'X_COM_Settings'.default.music_Tactics_Mission_Fail) )
				{
					MusicTracks[8] = CurrentTrack;
				}
				else
				{
					MusicTracks[8] = CreateNewTrack(class'X_COM_Settings'.default.music_Tactics_Mission_Fail);
				}
			}
			NewTrack = MusicTracks[8];
			CurrTempo = class'X_COM_Settings'.default.music_Tempo;
			CurrFadeFactor = MusicVolume/class'X_COM_Settings'.default.CrossfadeToMeNumMeasuresDuration;
		break;
	}

	if ( (CurrentTrack == NewTrack) && (CurrentTrack != None) && CurrentTrack.bWasPlaying )
		return;

	// play selected track
	CurrentTrack = NewTrack;
	MusicStartTime = WorldInfo.TimeSeconds;
	LastBeat = 0;
	if ( CurrentTrack != None )
	{
		CurrentTrack.VolumeMultiplier = 0.0;
		CurrentTrack.Play();
	}
}

defaultproperties
{
}
