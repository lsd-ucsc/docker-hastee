{-# LANGUAGE CPP #-}
module SecureCounter (main) where

-- copy and paste this program into the Main.hs file

import Control.Monad.IO.Class(liftIO)

import App

#ifdef ENCLAVE
import Enclave
#else
import Client
#endif


app :: App Done
app = do
  remoteRef <- liftNewRef 0 :: App (Enclave (Ref Int))
  count <- inEnclave $ do
    r <- remoteRef
    v <- readRef r
    writeRef r (v + 1)
    return v
  runClient $ do
    visitors <- gateway count
    liftIO $ putStrLn $ "You are visitor number #" ++ show visitors


main :: IO ()
main = do
  res <- runApp app
  return $ res `seq` ()
