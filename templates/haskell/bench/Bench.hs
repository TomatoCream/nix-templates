module Main where

import Criterion.Main
import Lib

main :: IO ()
main = defaultMain [
  bgroup "Lib" [
    bench "someFunc" $ whnfIO someFunc
  ]
  ] 