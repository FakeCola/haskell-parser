{-# LANGUAGE OverloadedStrings #-}

module StmtEvaluator where

import qualified Data.Map as Map
import Lib
import ExprEvaluator (evalBool, eval)

-- Evaluation function
-- Given an initial memory, execute program and return the memory afterwards
evalProg :: Prog -> Mem -> Mem
evalProg (StmtList (p:ps)) m = evalProg (StmtList ps) m' where
    m' = evalProg p m

evalProg (VarSet var expr) m = Map.insert var (eval m expr) m

evalProg (If expr stmt1 stmt2) m =
    if evalBool m expr
        then evalProg stmt1 m
        else evalProg stmt2 m

evalProg (While expr stmt) m =
    if evalBool m expr
        then if stmt /= Skip
            then let m' = evalProg stmt m
                in evalProg (While expr stmt) m'
            else m
        else m

evalProg Skip m = errorWithoutStackTrace "Evaluator.evalProg: skip failed, not in a loop"
