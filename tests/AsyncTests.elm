port module AsyncTest exposing (..)


import Dict
import Set
import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Process
import Task
import Time



--
-- Model
--


type Mode
  = Manual
  | Automatic


type alias Test =
  { name : String
  , task : Task.Task String ()
  }


type TestStatus
  = Pending
  | Successful
  | Failed String


type Message
  = StartAutomatedRun
  | StartTest Test
  | TestReportsSuccess Test
  | TestReportsFailure Test String
  | WindowError String


type alias Model =
  { tests : List Test
  , testStatusByName : Dict.Dict String TestStatus
  , currentTest : Maybe Test
  , mode : Mode
  }



--
-- Helpers
--
noCmd : Model -> (Model, Cmd Message)
noCmd m =
  (m, Cmd.none)


-- since Tests include Tasks, they are not comparable
isCurrentTest : Model -> Test -> Bool
isCurrentTest model test =
  case model.currentTest of
    Nothing -> False
    Just currentTest -> currentTest.name == test.name


startTest : Test -> Cmd Message
startTest test =
  Task.perform WindowError (\_ -> StartTest test) (Process.sleep <| 10 * Time.millisecond)



runNextTest : Model -> Cmd Message
runNextTest model =
  case List.head <| List.filter (\t -> Dict.get t.name model.testStatusByName == Just Pending) model.tests of
    Nothing -> Cmd.none
    Just test -> startTest test


reportTestResult : Test -> TestStatus -> Model -> (Model, Cmd Message)
reportTestResult test reportedStatus oldModel =
  let
    -- Ensure duplicate results are never successful
    finalStatus =
      if isCurrentTest oldModel test || reportedStatus /= Successful
      then reportedStatus
      else Failed "Test Task reports success after a result has been provided already"

    newModel =
      { oldModel
      | currentTest = Nothing
      , testStatusByName = Dict.insert test.name finalStatus oldModel.testStatusByName
      }

    backendCmd = sendUpdateToBackend newModel (Just test) finalStatus

    automationCmd = if newModel.mode /= Automatic then Cmd.none else runNextTest newModel

    -- TODO: what if test /= current test AND current test is still running?

  in
    (newModel, Cmd.batch [backendCmd, automationCmd])


--
-- Update
--
update : Message -> Model -> (Model, Cmd Message)
update message oldModel =
  case message of


    StartAutomatedRun ->

      case List.head oldModel.tests of
        Nothing ->
          (oldModel, sendUpdateToBackend oldModel Nothing <| Failed "Nothing to do")
        Just test0 ->
          let
            newModel = { oldModel | mode = Automatic }
            cmd = startTest test0
          in
            (newModel, cmd)


    StartTest test ->

      case oldModel.currentTest of
        Just currentTest ->
          Debug.crash <| "Attempt to start test '" ++ test.name ++ "' while test '" ++ currentTest.name ++ "' is still running"
        Nothing ->
          let
             newModel = { oldModel | currentTest = Just test }
             testCmd = Task.perform (TestReportsFailure test) (\_ -> TestReportsSuccess test) test.task
             backendCmd = sendUpdateToBackend newModel (Just test) Pending
          in
             (newModel, Cmd.batch [backendCmd, testCmd])


    TestReportsSuccess test ->
      reportTestResult test Successful oldModel


    TestReportsFailure test error ->
      reportTestResult test (Failed error) oldModel


    WindowError error ->
      case oldModel.currentTest of
        Just test -> reportTestResult test (Failed error) oldModel
        Nothing -> (oldModel, sendUpdateToBackend oldModel Nothing (Failed error))



--
-- View
--
testView model test =
  let
    isDisabled = model.mode == Automatic || model.currentTest /= Nothing

    (message, clazz) =
      if isCurrentTest model test
      then ("Running...", "running")
      else case Maybe.withDefault (Failed "!!") <| Dict.get test.name model.testStatusByName of
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
        , onClick <| StartTest test
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
    , mode = Manual
    }

  in
    if namesAreUnique
    then noCmd model
    else Debug.crash "Tests have duplicate names"



--
-- Interop
--


port sendUpdateToBackendPort : (String, String, Int) -> Cmd msg

sendUpdateToBackend : Model -> Maybe Test -> TestStatus -> Cmd msg
sendUpdateToBackend model maybeTest status =
  let
    pendingCount = Dict.values model.testStatusByName |> List.filter ((==) Pending) |> List.length
    testName = case maybeTest of
      Nothing -> "Uncaught exception"
      Just test -> test.name
  in
    sendUpdateToBackendPort (testName, toString status, pendingCount)


port windowOnErrorPort : (String -> msg) -> Sub msg


port automatedRunPort : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Message
subscriptions model =
  Sub.batch
    [ windowOnErrorPort WindowError
    , automatedRunPort (\_ -> StartAutomatedRun)
    ]



--
-- Main
--
program : List Test -> Program Never
program tests =
  Html.App.program
  { init = init tests
  , update = update
  , view = view
  , subscriptions = subscriptions
  }
