{-# LANGUAGE OverloadedStrings #-}

import Control.Monad
import Control.Concurrent
import Network.HTTP.Types
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Helics
import Network.Helics.Wai
import Data.Vault.Lazy as V
import qualified Data.ByteString.Char8 as S8
import System.Environment

main :: IO ()
main = do
    key:_ <- getArgs
    withHelics def { licenseKey = S8.pack key, appName = "Test3" } $ do
        forkIO . void $ sampler 20
        v <- newKey
        putStrLn "start"
        run 3000 $ helics app

app req send = case pathInfo req of
    []      -> threadDelay (10^5) >> send (responseLBS status200 [] "root")
    ["foo"] -> threadDelay (2 * 10^5) >> send (responseLBS status200 [] "foo")
    ["bar"] -> datastoreSegment autoScope (DatastoreSegment "bar" "select" "SELECT * FROM bar WHERE key =  'baz'" "select bars" Nothing) (threadDelay (3 * 10^5) >> send (responseLBS status200 [] "bar")) (transactionId req)
    _       -> send (responseLBS status404 [] "not found")
