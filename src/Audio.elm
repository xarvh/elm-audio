module Audio where

{-| Stuff..

@docs Sound

@docs PlaybackOption

@docs loadSound, playSound, stopSound

-}

import Task
import Native.Audio

{-| It's a sound -}
type Sound = Sound

{-| All options for sound playing -}
type PlaybackOption
    = Loop

{-| load -}
loadSound : String -> Task.Task String Sound
loadSound url = Native.Audio.loadSound url

{-| play -}
playSound : List PlaybackOption -> Sound -> Task.Task () ()
playSound = Native.Audio.playSound

{-| stop -}
stopSound : Sound -> Task.Task () ()
stopSound sound = Native.Audio.stopSound sound
