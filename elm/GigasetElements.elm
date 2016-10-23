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
                viewCountdown CancelCountdown model.countdown "fa fa-lock"

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
    div [ class "status", onClick ToggleMode ]
        [ div [ class "centered" ]
            [ viewIcon model
            , div [] [ text (toString model.mode) ]
            ]
        ]


viewIcon model =
    case model.mode of
        Home ->
            div [ class "icon inactive" ]
                [ div []
                    [ i [ class "fa fa-unlock" ] []
                    ]
                ]

        Away ->
            div [ class "icon active" ]
                [ div []
                    [ i [ class "fa fa-lock" ] []
                    ]
                ]

        Pending ->
            div [ class "icon inactive" ]
                [ div []
                    [ i [ class "fa fa-question" ] []
                    ]
                ]


viewPending model =
    div [ class "status" ]
        [ div [ class "centered" ]
            [ div [ class "icon active" ]
                [ div []
                    [ i [ class "fa fa-spinner fa-spin" ] []
                    ]
                ]
            ]
        ]
