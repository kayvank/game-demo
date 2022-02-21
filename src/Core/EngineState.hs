{-# LANGUAGE PackageImports #-}

module Core.EngineState where

import Core.Event
import Core.Geometry
import Core.Texture
import Core.Utils
import Data.Set
  ( delete,
    difference,
    fromList,
    insert,
    union,
  )
import Data.Time.Clock.System ( SystemTime )
import Data.Tuple.Extra (dupe)
import "GLFW-b" Graphics.UI.GLFW
  ( Key (..),
    KeyState (..),
    MouseButton (..),
    MouseButtonState (..),
  )
import Protolude
    ( ($),
      Functor(fmap),
      Num((*)),
      Ord((>)),
      Show,
      Foldable(toList, elem),
      Generic,
      Monoid(mempty),
      Bool,
      Double,
      Integer,
      NFData,
      catMaybes,
      undefined,
      sum,
      Set )
import Protolude.Debug (undefined)

data EngineState = EngineState
  { esCursorPos :: Pos,
    esFps :: Double,
    esDimensions :: Dim,
    esKeysPressed :: Set Key,
    esMousePressed :: Set MouseButton,
    esLastLoopTime :: SystemTime,
    esActions :: Set Action,
    esTimes :: [Integer],
    esTimePassed :: Double,
    esWindowSize :: Dim
  }
  deriving (Show, Generic, NFData)

makeInitialEngineState :: Double -> Dim -> SystemTime -> EngineState
makeInitialEngineState scale dim time =
  EngineState
    { esCursorPos = 0,
      esFps = 0,
      esKeysPressed = mempty,
      esMousePressed = mempty,
      esLastLoopTime = time,
      esDimensions = dim,
      esActions = mempty,
      esTimes = [],
      esTimePassed = 0,
      esWindowSize = dupe scale * dim
    }

gameExitRequested :: EngineState -> Bool
gameExitRequested es = Exit `elem` (esActions es)

clearOneTimeEffects :: EngineState -> EngineState
clearOneTimeEffects es =
  es
    { esActions =
        -- clear triggers for one time side effects
        esActions es `difference` (Data.Set.fromList $ fmap OneTimeEffect $ catMaybes $ fmap oneTimeEffectMay $ toList $ esActions es)
    }

stepEngineState :: EngineState -> Event -> EngineState
stepEngineState (clearOneTimeEffects -> gs@EngineState {..}) =
  \case
    WindowSizeEvent width height -> undefined
    CursorPosEvent pos -> undefined
    KeyEvent key KeyState'Pressed -> undefined
    KeyEvent key KeyState'Released -> undefined
    MouseEvent mb MouseButtonState'Pressed ->
        gs
          { esMousePressed = Data.Set.insert mb esMousePressed
          }
    MouseEvent mb MouseButtonState'Released ->
      gs
        { esMousePressed = Data.Set.delete mb esMousePressed
        }
    WindowCloseEvent ->
      gs
        { esActions = Data.Set.fromList [Exit, OneTimeEffect Save] `Data.Set.union` esActions
        }
    RenderEvent time ->
      let picosecs = timeDiffPico esLastLoopTime time
          halfsec = 500 * 1000 * 1000 * 1000
       in gs
            { esLastLoopTime = time,
              esTimePassed = pico2Double picosecs,
              esTimes = if sum esTimes > halfsec then [] else picosecs : esTimes,
              esFps = if sum esTimes > halfsec then avg esTimes else esFps
            }
    _ -> gs
