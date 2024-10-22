#!/bin/bash

set -eufo pipefail

# No startup sound
sudo nvram SystemAudioVolume=" "

###############################################################################
# Finder
###############################################################################

# Show file extensions for all files
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show the path bar at the bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true

# Show the status bar at the bottom of Finder windows
defaults write com.apple.finder ShowStatusBar -bool true

# Hide hidden files in Finder
defaults write com.apple.finder "AppleShowAllFiles" -bool "false"

# Make the user's Library folder visible in Finder
chflags nohidden ~/Library

# Set the default Finder view style to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Sort folders before files in Finder
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Automatically remove items from the Trash after 30 days
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

###############################################################################
# Dock
###############################################################################
# Disable the recent applications section in the Dock
defaults write com.Apple.Dock show-recents -bool false

# Remove the animation delay when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float "0"

# Change the minimize effect to 'suck'
defaults write com.apple.dock mineffect -string suck

# Disable the animation when launching applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Remove the delay when hiding/showing the Dock
defaults write com.apple.Dock autohide-delay -float 0
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.5

###############################################################################
# Global
###############################################################################
# Enable the press-and-hold for keys feature globally
defaults write -g ApplePressAndHoldEnabled -bool false

# Disable automatic spelling correction globally
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable automatic capitalization globally
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable automatic quote substitution globally
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable automatic period substitution globally
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable automatic dash substitution globally
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Set the default size mode for table views to medium (conflicts with previous setting)
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
# Disable window animations globally
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Set the window resize time to a very short duration
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# VScode enable repeast
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate (were 2 and 15).
# Set the key repeat rate to the fastest setting
defaults write NSGlobalDomain KeyRepeat -float 2
# Set the initial key repeat delay to a very short duration
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write com.apple.terminal StringEncodings -array 4

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in \
	"Dock" \
	"Finder" \
	"SystemUIServer"; do
	killall ${app} &>/dev/null
done
echo "Done. Note that some of these changes require a logout/restart to take effect."