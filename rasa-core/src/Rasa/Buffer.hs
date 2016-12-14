{-# LANGUAGE Rank2Types, TemplateHaskell, OverloadedStrings, ExistentialQuantification, ScopedTypeVariables,
   GeneralizedNewtypeDeriving, FlexibleInstances,
   StandaloneDeriving #-}

module Rasa.Buffer
  ( Buffer
  , Coord
  , Ext(..)
  , bufExts
  , attrs
  , text
  , newBuffer
  , useCountFor
  ) where

import qualified Data.Text as T
import Control.Lens hiding (matching)
import Data.Text.Lens (packed)
import Data.Default
import Data.Dynamic
import Data.Map

import Rasa.Attributes

type Coord = (Int, Int)
data Ext = forall a. Show a => Ext a

instance Show Ext where
  show (Ext a) = show a

data Buffer = Buffer
  { _text :: T.Text
  , _bufExts :: Map TypeRep Ext
  -- This list must always remain sorted by offset
  , _attrs :: [IAttr]
  }

makeLenses ''Buffer

instance Show Buffer where
  show b = "<Buffer {text:" ++ show (b^..text.from packed.taking 30 traverse) ++ "...,\n"
           ++ "attrs: " ++ show (b^.attrs) ++ "\n"
           ++ "exts: " ++ show (b^.bufExts) ++ "}>\n"

newBuffer :: T.Text -> Buffer
newBuffer txt =
  Buffer
  { _text = txt
  , _bufExts = empty
  , _attrs = def
  }

useCountFor :: Lens' Buffer  T.Text
            -> (Int -> Buffer  -> Buffer )
            -> Buffer 
            -> Buffer 
useCountFor l f buf = f curs buf
  where
    curs = buf ^. l . to T.length