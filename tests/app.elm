
-- import Audio
import Html exposing (button, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)
import Signal
import Task

-- type Task = Task.Task () ()

noTask m = (m, Task.succeed ())


--
-- Model
--
type alias Model = {}

type Action
  = Fail


--
-- Update
--
actionsMailbox : Signal.Mailbox Action
actionsMailbox = Signal.mailbox <| Fail


update : Action -> Model -> (Model, Task.Task () ())
update action oldModel =
  case action of
    Fail ->
      let
        q = snd == fst
        s = Debug.log "qqq" q
      in
        noTask oldModel


--
-- View
--
view address model =
  let
    actionButton action = button [ id <| toString action, onClick address action] [ text <| toString action ]
  in
    actionButton Fail


--
-- Main
--
modelAndTasksSignal =
  Signal.foldp (\action modelAndTask -> update action <| fst modelAndTask) (noTask {}) actionsMailbox.signal


main =
  Signal.map ((view actionsMailbox.address) << fst) modelAndTasksSignal


port tasks : Signal.Signal (Task.Task () ())
port tasks =
  Signal.map (Task.map (\_ -> ()) << snd) modelAndTasksSignal
