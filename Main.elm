port module Main exposing (main)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (class)
import Html.Events exposing (onInput, onClick)
import String
import Time

type alias Model =
    { countdown : Int
    , countdownActive : Bool
    , mode : Mode
    , inputPassword : String
    , inputUsername : String
    , credentials : Credentials
    }

type Mode
    = Pending
    | Home
    | Away

type Msg
    = ChangePassword String
    | ChangeUsername String
    | SavePassword
    | ToggleMode
    | SaveMode String
    | Tick Time.Time
    | CancelCountdown
    | GetCredentials Credentials
    | ResetCredentials

type alias ChangeModeAttributes =
    { credentials : Credentials
    , mode : String
    }

type alias Credentials =
    { username : Maybe String
    , password : Maybe String
    }

init =
    ( Model 0 False Pending "" "" (Credentials Nothing Nothing), requestCredentials Nothing )

view model =
    div []
        [ button [ onClick ResetCredentials ] [ text "Reset" ]
        , case model.countdownActive of
            True ->
                viewCountdown model

            False ->
                case model.credentials.username of
                    Just username ->
                        case model.mode of
                            Home ->
                                viewHomeOrAway model
                            Away ->
                                viewHomeOrAway model
                            Pending ->
                                viewPending model

                    Nothing ->
                        div []
                            [ input [ onInput ChangeUsername ] []
                            , input [ onInput ChangePassword ] []
                        , button [ onClick SavePassword ] [ text "Save" ]
                        ]
        ]

viewCountdown model =
    div [ class "box countdown", onClick CancelCountdown ]
        [ button [] [ text "Cancel" ]
        , p []
            [ i [ class "fa fa-lock fa-spin" ] []
            , text (toString model.countdown)
            ]
        ]

viewHomeOrAway model =
    div [ class "box", onClick ToggleMode ]
        [ button [ onClick ToggleMode ] [ text "Toggle" ]
        , p []
            [ viewIcon model
            , text (toString model.mode)
            ]
        ]

viewIcon model =
    case model.mode of
        Home ->
            i [ class "fa fa-unlock" ] []
        Away ->
            i [ class "fa fa-lock" ] []
        Pending ->
            i [ class "fa fa-question" ] []

viewPending model =
    div [ class "box" ]
        [ i [ class "fa fa-spinner fa-spin" ] []
        ]

update message model =
    case message of
        ChangePassword input ->
            ( { model | inputPassword = input }, Cmd.none )

        ChangeUsername input ->
            ( { model | inputUsername = input }, Cmd.none )

        SavePassword ->
            ( { model | credentials = { username = Just model.inputUsername, password = Just model.inputPassword } }, Cmd.batch [ saveCredentials (Credentials (Just model.inputUsername) (Just model.inputPassword)), requestMode model.credentials ] )

        ToggleMode ->
            case model.credentials.password of
                Just pass ->
                    case model.mode of
                        Home ->
                            ( { model | countdown = 20, countdownActive = True }, Cmd.none )
                        Pending ->
                            ( model, Cmd.none )
                        Away ->
                            ( { model | mode = Pending }, changeMode (ChangeModeAttributes model.credentials "home") )


                Nothing ->
                    ( model, Cmd.none )

        SaveMode mode ->
            if String.startsWith "HOME" mode then
                ( { model | mode = Home }, Cmd.none )
            else if String.startsWith "AWAY" mode then
                ( { model | mode = Away }, Cmd.none )
            else
                ( { model | mode = Pending }, Cmd.none )

        Tick time ->
            case model.countdownActive of
                True ->
                    if model.countdown > 1 then
                        ( { model | countdown = model.countdown - 1 }, Cmd.none )
                    else
                        case model.credentials.password of
                            Nothing ->
                                ( { model | countdown = 0, countdownActive = False }, Cmd.none )
                            Just pass ->
                                ( { model | mode = Pending, countdown = 0, countdownActive = False }, changeMode (ChangeModeAttributes model.credentials "away") )
                False ->
                    ( model, Cmd.none )

        CancelCountdown ->
            ( { model | countdownActive = False }, Cmd.none )

        GetCredentials credentials ->
            case credentials.password of
                Just pass ->
                    ( { model | credentials = credentials, mode = Pending }, requestMode credentials )
                Nothing ->
                    ( { model | credentials = credentials }, Cmd.none )

        ResetCredentials ->
            ( { model | credentials = Credentials Nothing Nothing }, Cmd.none )

main =
  Html.App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

subscriptions model =
    Sub.batch
        [ getMode SaveMode
        , Time.every Time.second Tick
        , getCredentials GetCredentials
        ]

port changeMode : ChangeModeAttributes -> Cmd msg
port requestMode : Credentials -> Cmd msg
port getMode : (String -> msg) -> Sub msg
port requestCredentials : Maybe String -> Cmd msg
port getCredentials : (Credentials -> msg) -> Sub msg
port saveCredentials : Credentials -> Cmd msg