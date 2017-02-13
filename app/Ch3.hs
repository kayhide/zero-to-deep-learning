{-# LANGUAGE FlexibleContexts #-}
module Ch3 where

import Numeric.LinearAlgebra
import qualified Data.ByteString.Char8 as BS
import qualified Data.Yaml as Yaml

import NeuralNetwork

type ActivationFunction = [Double] -> [Double]
type Layer = (Matrix R, Vector R, ActivationFunction)
type Network = [Layer]

-- ch3_4
network :: Network
network = [ ( (2><3) [0.1, 0.3, 0.5, 0.2, 0.4, 0.6]
            , vector [0.1, 0.2, 0.3]
            , map sigmoidFunction
            )
          , ( (3><2) [0.1, 0.4, 0.2, 0.5, 0.3, 0.6]
            , vector [0.1, 0.2]
            , map sigmoidFunction
            )
          , ( (2><2) [0.1, 0.3, 0.2, 0.4]
            , vector [0.1, 0.2]
            , id
            )
          ]

forward :: Network -> Vector R -> Vector R
forward nw x = foldl propagate x nw
  where propagate x (w, b, f) = fromList . f . toList $ x <# w + b

x = vector [1.0, 0.5]
y = forward network x


-- ch3_6
readMatrix :: FilePath -> IO (Matrix R)
readMatrix file = do
  s <- BS.readFile file
  let Just m = Yaml.decode s :: Maybe [[Double]]
  return $ fromLists m

readVector :: FilePath -> IO (Vector R)
readVector file = do
  s <- BS.readFile file
  let Just v = Yaml.decode s :: Maybe [Double]
  return $ fromList v

readNetwork :: IO Network
readNetwork = do
  w1 <- readMatrix' "W1"
  b1 <- readVector' "b1"
  w2 <- readMatrix' "W2"
  b2 <- readVector' "b2"
  w3 <- readMatrix' "W3"
  b3 <- readVector' "b3"
  return [ (w1, b1, map sigmoidFunction)
         , (w2, b2, map sigmoidFunction)
         , (w3, b3, softmax)
         ]
  where readMatrix' f = readMatrix $ "data/mnist/" ++ f ++ ".yml"
        readVector' f = readVector $ "data/mnist/" ++ f ++ ".yml"
