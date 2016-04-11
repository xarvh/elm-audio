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


{-| load -}
loadSound : String -> Task.Task String Sound
loadSound = Native.Audio.loadSound

{-| play -}
playSound : PlaybackOptions -> Sound -> Task.Task () ()
playSound = Native.Audio.playSound

{-| stop -}
stopSound : Sound -> Task.Task () ()
stopSound = Native.Audio.stopSound

--
-- TODO Is there a way to make this run in parallel?
--
{-| loadSoundsDict -}
loadSoundsDict : List (comparable, String) -> Task.Task String (Dict.Dict comparable Sound)
loadSoundsDict namesAndUris =
  let
    nameAndUriToTask (name, uri) =
      Task.map ((,) name) (loadSound uri)
  in
    Task.map Dict.fromList <| Task.sequence <| List.map nameAndUriToTask namesAndUris
