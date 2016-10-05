port module Main exposing (main)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (class)
import Html.Events exposing (onInput, onClick)
import String
import Time
import GigasetElements exposing (..)
import Messages exposing (..)
import Shutdown exposing (..)


type alias Model =
    { countdown : Int
    , countdownActive : Bool
    , mode : Mode
    , inputPassword : String
    , inputUsername : String
    , credentials : Credentials
    , shutdownCountdown : Int
    , shutdownCountdownActive : Bool
    }

init =
    ( Model 0 False Pending "" "" (Credentials Nothing Nothing) 0 False, requestCredentials Nothing )

view model =
    div [ class "pure-g" ]
        [ div [ class "pure-u-1-3" ]
            [ viewAlarmMode model
            ]
        , div [ class "pure-u-1-3" ]
            [ viewShutdown model
            ]
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

        ShutdownCountdownTick time ->
            case model.shutdownCountdownActive of
                True ->
                    if model.shutdownCountdown > 1 then
                        ( { model | shutdownCountdown = model.shutdownCountdown - 1 }, Cmd.none )
                    else
                        ( { model | shutdownCountdown = 0, shutdownCountdownActive = False }, shutdown "" )
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

        StartShutdownCountdown ->
            ( { model | shutdownCountdown = 10, shutdownCountdownActive = True }, Cmd.none )

        CancelShutdownCountdown ->
            ( { model | shutdownCountdown = 0, shutdownCountdownActive = False }, Cmd.none )

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
        , Time.every Time.second ShutdownCountdownTick
        , getCredentials GetCredentials
        ]

port changeMode : ChangeModeAttributes -> Cmd msg
port requestMode : Credentials -> Cmd msg
port requestCredentials : Maybe String -> Cmd msg
port saveCredentials : Credentials -> Cmd msg
port shutdown : String -> Cmd msg

port getMode : (String -> msg) -> Sub msg
port getCredentials : (Credentials -> msg) -> Sub msg
