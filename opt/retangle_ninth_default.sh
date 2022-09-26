#!/bin/bash
#
# Modifier Key  Integer Value
# cmd           1048576
# option        524288
# ctrl          262144
# shift         131072
# fn            8388608

# Ninth grid, 3x3
# p [ ]
# l ; '
# , . /
defaults write com.knollsoft.Rectangle topLeftNinth -dict-add keyCode -float 35 modifierFlags -float 786432
defaults write com.knollsoft.Rectangle topCenterNinth -dict-add keyCode -float 33 modifierFlags -float 786432
defaults write com.knollsoft.Rectangle topRightNinth -dict-add keyCode -float 30 modifierFlags -float 786432
defaults write com.knollsoft.Rectangle middleRightNinth -dict-add keyCode -float 39 modifierFlags -float 786432
defaults write com.knollsoft.Rectangle middleCenterNinth -dict-add keyCode -float 41 modifierFlags -float 786432
defaults write com.knollsoft.Rectangle middleLeftNinth -dict-add keyCode -float 37 modifierFlags -float 786432
defaults write com.knollsoft.Rectangle bottomRightNinth -dict-add keyCode -float 44 modifierFlags -float 786432
defaults write com.knollsoft.Rectangle bottomLeftNinth -dict-add keyCode -float 43 modifierFlags -float 786432
defaults write com.knollsoft.Rectangle bottomCenterNinth -dict-add keyCode -float 47 modifierFlags -float 786432

