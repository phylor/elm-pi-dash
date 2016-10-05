module Shutdown exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Dashboard exposing (..)


viewShutdown model =
    div [ class "box" ]
        [ div [ class "fa" ] []
        , div [ class "title" ] [ text "System" ]
        , viewContent model
        ]

viewContent model =
    if model.shutdownCountdownActive then
        p [ class "status" ]
            [ viewCountdown CancelShutdownCountdown model.shutdownCountdown
            ]
    else
        p [ class "status", onClick StartShutdownCountdown ]
            [ div [ class "status-icon inactive" ]
                [ div []
                    [ i [ class "fa fa-power-off" ] []
                    ]
                ]
            ]
