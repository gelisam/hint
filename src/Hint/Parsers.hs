module Hint.Parsers where

import Prelude hiding (span)

import Hint.Base

import Control.Monad.IO.Class (liftIO)

import qualified Hint.GHC as GHC

data ParseResult = ParseOk | ParseError GHC.SrcSpan GHC.Message

parseExpr :: MonadInterpreter m => String -> m ParseResult
parseExpr = runParser GHC.parseStmt

parseType :: MonadInterpreter m => String -> m ParseResult
parseType = runParser GHC.parseType

runParser :: MonadInterpreter m => GHC.P a -> String -> m ParseResult
runParser parser expr =
    do dyn_fl <- runGhc GHC.getSessionDynFlags
       --
       buf <- (return . GHC.stringToStringBuffer) expr
       --
       -- ghc >= 7 panics if noSrcLoc is given
       let srcLoc = GHC.mkRealSrcLoc (GHC.fsLit "<hint>") 1 1
       let parse_res = GHC.unP parser (GHC.mkPState dyn_fl buf srcLoc)
       --
       case parse_res of
           GHC.POk{}            -> return ParseOk
           --
#if __GLASGOW_HASKELL__ >= 810
           GHC.PFailed pst      -> let errMsgs = GHC.getErrorMessages pst dyn_fl
                                       span = foldr (GHC.combineSrcSpans . GHC.errMsgSpan) GHC.noSrcSpan errMsgs
                                       err = GHC.vcat $ GHC.pprErrMsgBagWithLoc errMsgs
                                   in pure (ParseError span err)
#else
           GHC.PFailed _ span err
                                -> return (ParseError span err)
#endif

failOnParseError :: MonadInterpreter m
                 => (String -> m ParseResult)
                 -> String
                 -> m ()
failOnParseError parser expr = mayFail go
    where go = parser expr >>= \ case
                      ParseOk             -> return (Just ())
                      -- If there was a parsing error,
                      -- do the "standard" error reporting
                      ParseError span err ->
                          do -- parsing failed, so we report it just as all
                             -- other errors get reported....
                             logger <- fromSession ghcErrLogger
                             dflags <- runGhc GHC.getSessionDynFlags
                             let logger'  = logger dflags
#if !MIN_VERSION_ghc(9,0,0)
                                 errStyle = GHC.defaultErrStyle dflags
#endif
                             liftIO $ logger'
                                              GHC.NoReason
                                              GHC.SevError
                                              span
#if !MIN_VERSION_ghc(9,0,0)
                                              errStyle
#endif
                                              err
                             --
                             -- behave like the rest of the GHC API functions
                             -- do on error...
                             return Nothing
