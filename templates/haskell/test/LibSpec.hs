module LibSpec (runTests) where

import Test.Hspec
import Test.QuickCheck
import Lib

runTests :: IO ()
runTests = hspec $ do
  describe "Lib" $ do
    it "should work" $ do
      True `shouldBe` True 