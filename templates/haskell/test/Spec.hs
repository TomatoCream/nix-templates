module Main where

import qualified LibSpec

main :: IO ()
main = do
  putStrLn "Running tests..."
  LibSpec.runTests 