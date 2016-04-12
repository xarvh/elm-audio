module Audio where

{-| Stuff..

@docs Sound

@docs PlaybackOption

@docs loadSound, playSound, stopSound

-}

import Dict
import Task
import Time
import Native.Audio


{-| It's a sound -}
type Sound = Sound


{-| All options for sound playing -}
type alias PlaybackOptions =
  { volume : Float
  , startAt : Maybe Time.Time
  , loop : Bool
  }

{-| defaultopts -}
defaultPlaybackOptions =
  PlaybackOptions 1.0 (Just 0.0) False


-- Task Interface
{-| load -}
loadSound : String -> Task.Task String Sound
loadSound = Native.Audio.loadSound

{-| play -}
playSound : PlaybackOptions -> Sound -> Task.Task () ()
playSound = Native.Audio.playSound

{-| stop -}
stopSound : Sound -> Task.Task () ()
stopSound = Native.Audio.stopSound
