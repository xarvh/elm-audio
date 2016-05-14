[![Build Status](https://secure.travis-ci.org/xarvh/elm-audio.png?branch=master)](http://travis-ci.org/xarvh/elm-audio)


# elm-audio
Basic interface for HTML5 Audio object.


## Example
```elm
import Audio exposing (defaultPlaybackOptions)
import Dict
import Task


loadAndPlaySound : String -> Task.Task String ()
loadAndPlaySound soundUrl =
  Audio.loadSound soundUrl
  `Task.andThen`
  (Task.mapError (\_ -> "") << Audio.playSound Audio.defaultPlaybackOptions)


playSoundLoop : Audio.Sound -> Task.Task () ()
playSoundLoop =
  Audio.playSound { defaultPlaybackOptions | loop = True }
```


## Managing multiple sounds
If an application uses several different sounds, they can be loaded together into a dictionary:
```elm
import Audio
import Dict
import Task


type alias SoundsDict comparable =
  Dict.Dict comparable Audio.Sound


loadSoundsIntoDictionary : List ( comparable, String ) -> Task.Task String (SoundsDict comparable)
loadSoundsIntoDictionary namesAndUris =
  let
    nameAndUriToTask ( name, uri ) =
      Task.map ((,) name) (Audio.loadSound uri)
  in
    Task.map Dict.fromList <| Task.sequence <| List.map nameAndUriToTask namesAndUris


loadAllSounds : Task.Task String (SoundsDict String)
loadAllSounds =
  loadSoundsIntoDictionary
    [ ( "Kaboom", "/assets/sounds/kaboom.ogg" )
    , ( "Crash", "/assets/sounds/crash.ogg" )
    ]


playSound : SoundsDict String -> String -> Task.Task String ()
playSound soundDictionary soundId =
  case Dict.get soundId soundDictionary of
    Just sound ->
      Task.mapError (\_ -> "") <| Audio.playSound Audio.defaultPlaybackOptions sound

    Nothing ->
      Task.fail <| soundId ++ " not loaded!"
```
