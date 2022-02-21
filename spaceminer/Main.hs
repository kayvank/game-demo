module Main  where
import Protolude
import Core.Geometry

area :: Area
area  =  ( (3,5) , (4,8))

corn :: Corners Pos
corn = corners area

main :: IO ()
main = do
  putStrLn $ show corn <> ("  corn" :: Text)
