module AsyncTest exposing (..)


import Dict
import Set
import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task



type alias Test =
  { name : String
  , task : Task.Task String ()
  }


type TestStatus
  = Pending
  | Successful
  | Failed String



type Message
  = Noop

  | UserStartsTest Test
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

testFinished : TestStatus -> Model -> Model
testFinished status model =
  case model.currentTest of
    Nothing -> Debug.crash "Test finished, but currentStatus is unset"
    Just test ->
      { model
      | currentTest = Nothing
      , testStatusByName = Dict.insert test.name status model.testStatusByName
      }



--
-- Update
--
update : Message -> Model -> (Model, Cmd Message)
update message oldModel =
  case message of
    Noop ->
      noCmd oldModel

    UserStartsTest test ->
      if oldModel.currentTest /= Nothing
      then noCmd oldModel
      else
        let
           newModel = { oldModel | currentTest = Just test }
           cmd = Task.perform TestFails (\_ -> TestSucceeds) test.task
        in
           (newModel, cmd)

    TestSucceeds ->
      noCmd <| testFinished Successful oldModel

    TestFails error ->
      noCmd <| testFinished (Failed error) oldModel




--
-- View
--
testView model test =
  let
    isDisabled = model.currentTest /= Nothing

    (message, clazz) = case Maybe.withDefault (Failed "!!") <| Dict.get test.name model.testStatusByName of
      Pending -> ("Pending", "pending")
      Successful -> ("Passed", "success")
      Failed message -> ("Failed: " ++ message, "error")

  in
    div
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
  div [] <| List.map (testView model) model.tests




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

