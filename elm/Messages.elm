module Messages exposing (..)

import Time


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
    | StartShutdownCountdown
    | CancelShutdownCountdown
    | ShutdownCountdownTick Time.Time
    | GetIpAddress String
    | ChangeDisplay Display
    | StartRebootCountdown
    | CancelRebootCountdown
    | RebootCountdownTick Time.Time


type alias ChangeModeAttributes =
    { credentials : Credentials
    , mode : String
    }


type alias Credentials =
    { username : Maybe String
    , password : Maybe String
    }


type Display
    = Dashboard
    | System
