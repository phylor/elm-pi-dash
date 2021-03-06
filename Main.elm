port module Main exposing (main)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (class)
import Html.Events exposing (onInput, onClick)
import String
import Time
import GigasetElements exposing (..)
import Messages exposing (..)
import Dashboard exposing (..)
import Task
import Date


type alias Model =
    { countdown : Int
    , countdownActive : Bool
    , mode : Mode
    , inputPassword : String
    , inputUsername : String
    , credentials : Credentials
    , shutdownCountdown : Int
    , shutdownCountdownActive : Bool
    , ipAddress : String
    , display : Display
    , rebootCountdown : Int
    , rebootCountdownActive : Bool
    , currentTime : Time.Time
    }


init =
    ( Model 0 False Pending "" "" (Credentials Nothing Nothing) 0 False "" Dashboard 0 False 0, requestCredentials Nothing )

view model =
    case model.display of
        Dashboard ->
            div [ class "pure-g" ]
                [ div [ class "pure-u-1-3" ]
                    [ viewAlarmMode model
                    ]
                , viewAction "System" (ChangeDisplay System) "icon-raspberrypi"
                ]

        System ->
            div [ class "pure-g" ]
                [ viewAction "back" (ChangeDisplay Dashboard) "fa fa-chevron-left"
                , div [ class "pure-u-1-3" ]
                    [ viewCountdownAction "Power off" model.shutdownCountdownActive model.shutdownCountdown CancelShutdownCountdown StartShutdownCountdown "fa fa-power-off"
                    ]
                , div [ class "pure-u-1-3" ]
                    [ viewCountdownAction "Reboot" model.rebootCountdownActive model.rebootCountdown CancelRebootCountdown StartRebootCountdown "fa fa-repeat"
                    ]
                , div [ class "pure-u-1-3" ]
                    [ div [ class "box" ]
                        [ div [ class "fa" ] []
                        , div [ class "title" ] [ text "IP Address" ]
                        , div [ class "centered content" ] [ text model.ipAddress ]
                        ]
                    ]
                , div [ class "pure-u-1-3" ]
                    [ div [ class "box" ]
                        [ div [ class "fa" ] []
                        , div [ class "title" ] [ text "Time" ]
                        , div [ class "centered content" ] [ text <| viewTime <| model.currentTime ]
                        ]
                    ]
                ]


viewTime time =
    let
        date = Date.fromTime time
        hour = fillWithZeros 2 <| toString <| Date.hour date
        minute = fillWithZeros 2 <| toString <| Date.minute date
        second = fillWithZeros 2 <| toString <| Date.second date
    in
        hour ++ ":" ++ minute ++ ":" ++ second


fillWithZeros totalDigits number =
    if String.length number < totalDigits then
        fillWithZeros totalDigits ("0" ++ number)
    else
        number


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

        RebootCountdownTick time ->
            case model.rebootCountdownActive of
                True ->
                    if model.rebootCountdown > 1 then
                        ( { model | rebootCountdown = model.rebootCountdown - 1 }, Cmd.none )
                    else
                        ( { model | rebootCountdown = 0, rebootCountdownActive = False }, reboot "" )

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

        GetIpAddress ip ->
            ( { model | ipAddress = ip }, Cmd.none )

        ChangeDisplay display ->
            ( { model | display = display }, Cmd.none )

        StartRebootCountdown ->
            ( { model | rebootCountdown = 10, rebootCountdownActive = True }, Cmd.none )

        CancelRebootCountdown ->
            ( { model | rebootCountdown = 0, rebootCountdownActive = False }, Cmd.none )

        UpdateTime time ->
            ( { model | currentTime = time }, Cmd.none )

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
        , Time.every Time.second RebootCountdownTick
        , Time.every Time.second UpdateTime
        , getCredentials GetCredentials
        , getIpAddress GetIpAddress
        ]

port changeMode : ChangeModeAttributes -> Cmd msg
port requestMode : Credentials -> Cmd msg
port requestCredentials : Maybe String -> Cmd msg
port saveCredentials : Credentials -> Cmd msg
port shutdown : String -> Cmd msg
port reboot : String -> Cmd msg

port getMode : (String -> msg) -> Sub msg
port getCredentials : (Credentials -> msg) -> Sub msg
port getIpAddress : (String -> msg) -> Sub msg
