module Core.EngineConfig  where

import Protolude
import Core.Texture
import Core.Geometry
import Core.EngineState
import Core.Event

data EngineConfig = EngineConfig
  { ecStepGameState :: EngineState -> Event -> IO (),
    ecVisualize :: EngineState -> IO [Sprite],
    ecDim :: Dim,
    ecScale :: Double,
    ecCheckIfContinue :: EngineState -> IO Bool,
    ecGameDebugInfo :: EngineState -> IO [[Char]]
  }
