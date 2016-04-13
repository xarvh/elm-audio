module Audio (..) where

{-|

# Sounds
@docs Sound, loadSound

# Playback
@docs PlaybackOptions, defaultPlaybackOptions, playSound, stopSound

-}

import Task
import Time
import Native.Audio


{-| An identifier to a sound sample. Under the hood, it's just a HTML5 Audio
tag.
-}
type Sound
  = Sound


{-| The options available for sound playback.

  * `volume` is the relative playback volume, from 0 to 1.

  * `startAt` controls the starting time offset for the sound.
    Use `Just 0` to start from the beginning or `Nothing` to start from the
    previous position.

  * `loop` continuously repeats the sound when set to `True`.

-}
type alias PlaybackOptions =
  { volume : Float
  , startAt : Maybe Time.Time
  , loop : Bool
  }


{-| Default options to play the sound once, at full volume and from the
beginning.
-}
defaultPlaybackOptions : PlaybackOptions
defaultPlaybackOptions =
  PlaybackOptions 1.0 (Just 0.0) False


{-| Loads a sound from the given URL.
Once the sound resource has been transferred completely, the Task will provide
a new [Sound] object ready to play.
On error, the error message will be provided as a `String`.
-}
loadSound : String -> Task.Task String Sound
loadSound =
  Native.Audio.loadSound


{-| Play a `Sound` with the specified options.
The `Task` will complete when the sound has finished playing.
-}
playSound : PlaybackOptions -> Sound -> Task.Task () ()
playSound =
  Native.Audio.playSound


{-| Stop/Pause a `Sound`.
-}
stopSound : Sound -> Task.Task () ()
stopSound =
  Native.Audio.stopSound
