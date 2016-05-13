port module AsyncTest exposing (..)


import Dict
import Set
import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task



--
-- Model
--


type alias Test =
  { name : String
  , task : Task.Task String ()
  }


type TestStatus
  = Pending
  | Successful
  | Failed String



type Message
  = UserStartsTest Test
  | TestSucceeds
  | TestFails String


type alias Model =
  { tests : List Test
  , testStatusByName : Dict.Dict String TestStatus
  , currentTest : Maybe Test
  }



--
-- Helpers
--
noCmd : Model -> (Model, Cmd Message)
noCmd m =
  (m, Cmd.none)


testFinished : TestStatus -> Model -> (Model, Cmd Message)
testFinished status oldModel =
  case oldModel.currentTest of
    Nothing -> Debug.crash "** library error ** Test finished, but currentStatus is unset"
    Just test ->
      let
        newModel =
          { oldModel
          | currentTest = Nothing
          , testStatusByName = Dict.insert test.name status oldModel.testStatusByName
          }
      in
        ( newModel, sendTestStatusToBackend newModel test status )


--
-- Update
--
update : Message -> Model -> (Model, Cmd Message)
update message oldModel =
  case message of

    UserStartsTest test ->
      if oldModel.currentTest /= Nothing
      then noCmd oldModel
      else
        let
           newModel = { oldModel | currentTest = Just test }
           testCmd = Task.perform TestFails (\_ -> TestSucceeds) test.task
           backendCmd = sendTestStatusToBackend newModel test Pending
        in
           (newModel, Cmd.batch [backendCmd, testCmd])

    TestSucceeds ->
      testFinished Successful oldModel

    TestFails error ->
      testFinished (Failed error) oldModel




--
-- View
--
testView model test =
  let
    isDisabled = False --model.currentTest /= Nothing

    (message, clazz) = case Maybe.withDefault (Failed "!!") <| Dict.get test.name model.testStatusByName of
      Pending -> ("Pending", "pending")
      Successful -> ("Passed", "passed")
      Failed message -> ("Failed: " ++ message, "failed")

  in
    li
      []
      [ button
        [ class "test-button"
        , id test.name
        , disabled isDisabled
        , onClick <| UserStartsTest test
        ]
        [ text test.name ]
      , span
        [ class <| "test-status test-status-" ++ clazz]
        [ text message]
      ]


view : Model -> Html Message
view model =
  ol [] <| List.map (testView model) model.tests




--
-- Init
--
init : List Test -> (Model, Cmd Message)
init tests =
  let
    namesAreUnique = List.length tests == (Set.size <| Set.fromList <| List.map .name tests)

    model =
    { tests = tests
    , testStatusByName = Dict.fromList <| List.map (\t -> (t.name, Pending)) tests
    , currentTest = Nothing
    }

  in
    if namesAreUnique
    then noCmd model
    else Debug.crash "Tests have duplicate names"



--
-- Ports
--

port sendTestStatusToBackendPort : (String, String, Int) -> Cmd msg

sendTestStatusToBackend : Model -> Test -> TestStatus -> Cmd msg
sendTestStatusToBackend model test status =
  let
    pendingCount = Dict.values model.testStatusByName |> List.filter ((==) Pending) |> List.length
  in
    sendTestStatusToBackendPort (test.name, toString status, pendingCount)


--
-- Main
--
program : List Test -> Program Never
program tests =
  Html.App.program
  { init = init tests
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }
