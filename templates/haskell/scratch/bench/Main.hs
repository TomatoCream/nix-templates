module Main where

import Test.Tasty.Bench
import MyLib (someFunc) -- Assuming MyLib has something to test

main :: IO ()
main = defaultMain [
  bgroup "MyLib" [
    bench "someFunc execution" $ nfIO someFunc
  ]
 ]