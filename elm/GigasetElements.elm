module GigasetElements exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Messages exposing (..)
import Dashboard exposing (..)


type Mode
    = Pending
    | Home
    | Away


viewAlarmMode model =
    div [ class "box" ]
        [ div [ onClick ResetCredentials ]
            [ i [ class "fa fa-cog" ] []
            ]
        , div [ class "title" ] [ text "Security Mode" ]
        , case model.countdownActive of
            True ->
                viewCountdown CancelCountdown model.countdown

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


viewHomeOrAway model =
    div [ onClick ToggleMode ]
        [ p [ class "status" ]
            [ viewIcon model
            , text (toString model.mode)
            ]
        ]


viewIcon model =
    case model.mode of
        Home ->
            div [ class "status-icon inactive" ]
                [ div []
                    [ i [ class "fa fa-unlock" ] []
                    ]
                ]

        Away ->
            div [ class "status-icon active" ]
                [ div []
                    [ i [ class "fa fa-lock" ] []
                    ]
                ]

        Pending ->
            div [ class "status-icon inactive" ]
                [ div []
                    [ i [ class "fa fa-question" ] []
                    ]
                ]


viewPending model =
    p [ class "status" ]
        [ div [ class "status-icon active" ]
            [ div []
                [ i [ class "fa fa-spinner fa-spin" ] []
                ]
            ]
        ]
