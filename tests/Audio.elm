
import AsyncTest exposing (Test)
import Process
import Task
import Time


--
-- Test Target
--
import Audio exposing (defaultPlaybackOptions)


--
-- Helpers
--
(&>) = Task.andThen
infixl 9 &>


--
-- Test Cases
--
main = AsyncTest.program <|

  [ Test "Basic playback works" <|
      Audio.loadSound "short.ogg" &> \sound ->
      Time.now &> \startTime ->
      Audio.playSound defaultPlaybackOptions sound &> \_ ->
      Time.now &> \endTime ->
        let
            expectedDuration = 1.974 * Time.second
            actualDuration = endTime - startTime
        in
           if abs (expectedDuration - actualDuration) < 0.2 * Time.second then Task.succeed ()
           else Task.fail <| "Expected playback of " ++ (toString expectedDuration) ++ " but task lasted " ++ (toString actualDuration)


  , Test "Load inexistent sound produces an error" <|
      Task.toResult (Audio.loadSound "garblegarble.wav") &> \result ->
        case result of
          Ok sound -> Task.fail "loadSound should not succeed"
          Err message -> Task.succeed ()


  , Test "Stopping a sound works" <|
      Audio.loadSound "short.ogg" &> \sound ->
      Process.spawn (
        Process.sleep (0.1 * Time.second) &> \_ ->
        Audio.playSound defaultPlaybackOptions sound &> \_ ->
        Debug.crash "Stopped sound should not complete"
      ) &> \_ ->
        Process.sleep (0.5 * Time.second) &> \_ ->
        (Task.mapError (\_ -> "") <| Audio.stopSound sound) &> \_ ->
        Process.sleep (2.0 * Time.second) &> \_ ->
        Task.succeed ()


  , Test "Playback can be looped" <|
      Audio.loadSound "short.ogg" &> \sound ->
      Process.spawn (
        Process.sleep (0.1 * Time.second) &> \_ ->
        Audio.playSound { defaultPlaybackOptions | loop = True } sound &> \_ ->
        Debug.crash "Looping sound should not complete"
      ) &> \_ ->
        Process.sleep (4 * Time.second) &> \_ ->
        (Task.mapError (\_ -> "") <| Audio.stopSound sound) &> \_ ->
        Task.succeed ()


  , Test "Sound objects are comparable" <|
      Audio.loadSound "short.ogg" &> \a ->
      Audio.loadSound "short.ogg" &> \b ->
        if a == b
        then Task.succeed ()
        else  Task.fail "Sound with same source should compare equal"


  , Test "Sound objects are stringifyable" <|
      Audio.loadSound "short.ogg" &> \sound ->
      let
          expected = "Sound \"short.ogg\""
          actual = toString sound
      in
        if actual == expected
        then Task.succeed ()
        else Task.fail <| "Expected stringification to be `" ++ expected ++ "` but instead got `" ++ actual ++ "`"
  ]

  ++

  let
    test volume =
      Test ("Playback rejects volume = " ++ toString volume) <|

        Audio.loadSound "short.ogg" &> \sound ->
        Task.toResult (Audio.playSound { defaultPlaybackOptions | volume = volume } sound) &> \result ->
        case result of
          Ok sound -> Task.fail <| "playSound should reject volume = " ++ (toString volume)
          Err message -> Task.succeed ()
  in
    List.map test [0/0, 1/0, -1, 1.1]

  ++

  let
    test startAt =
      Test ("Playback rejects startAt = " ++ toString startAt) <|

        Audio.loadSound "short.ogg" &> \sound ->
        Task.toResult (Audio.playSound { defaultPlaybackOptions | startAt = Just startAt } sound) &> \result ->
        case result of
          Ok sound -> Task.fail <| "playSound should reject startAt = " ++ (toString startAt)
          Err message -> Task.succeed ()
  in
    List.map test [0/0, 1/0, -1]
