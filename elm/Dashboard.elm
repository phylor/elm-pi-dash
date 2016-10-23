module Dashboard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (..)


viewCountdown : Msg -> Int -> String -> Html Msg
viewCountdown cancelMessage countdown iconClass =
    div [ class "status", onClick cancelMessage ]
        [ div [ class "centered" ]
            [ div [ class "icon active" ]
                [ div []
                    [ i [ class ("fa-spin " ++ iconClass) ] []
                    ]
                ]
            , div [] [ text (toString countdown) ]
            ]
        ]


viewAction label onClickMessage iconClasses =
    div [ class "pure-u-1-3" ]
        [ div [ class "box", onClick onClickMessage ]
            [ div [ class "fa" ] []
            , div [ class "title" ] [ text label ]
            , div [ class "icon" ]
                [ div []
                    [ i [ class iconClasses ] []
                    ]
                ]
            ]
        ]


viewCountdownAction label countdownActive countdownSeconds cancelMessage startMessage iconClasses =
    div [ class "box" ]
        [ div [ class "fa" ] []
        , div [ class "title" ] [ text label ]
        , viewCountdownContent countdownActive countdownSeconds cancelMessage startMessage iconClasses
        ]


viewCountdownContent countdownActive countdownSeconds cancelMessage startMessage iconClasses =
    if countdownActive then
        viewCountdown cancelMessage countdownSeconds iconClasses
    else
        div [ class "status", onClick startMessage ]
            [ div [ class "centered" ]
                [ div [ class "icon inactive" ]
                    [ div []
                        [ i [ class iconClasses ] []
                        ]
                    ]
                ]
            ]
