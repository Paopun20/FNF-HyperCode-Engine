/**
 * # Custom Menu Creation Guide
 * 
 * This document explains how to create and implement custom menus in the HyPsych Engine.
 * 
 * ## Directory Structure
 * - Required folder: `custom_stages`
 * - Subfolder naming: Name after the state to override (e.g., `MainMenuState`)
 * - File placement: Place Haxe files in the appropriate subfolder
 * 
 * ## Implementation
 * 
 * ### Switching Menus
 * - To switch to custom menu:
 *   `MusicBeatState.switchCustomStage("Stage_name")`
 * - To switch to vanilla menu:
 *   `MusicBeatState.switchStage(new StageInstance())`
 * 
 * ### Vanilla Mod Stages
 * Available vanilla stages for modification:
 * - MainMenuState
 * - FreeplayState
 * - StoryMenuState
 * - CreditsState
 * 
 * ### Fallback Behavior
 * - If custom stage not found: Loads vanilla state
 * - If vanilla stage not found: Loads vanilla MainMenuState
 * 
 * ### Debug/Testing
 * Quick reload combination:
 * 1. Hold '7' key
 * 2. Press 'RESET' for 0.5s
 * 
 * ### Additional Notes
 * - Multiple files can be included in the same custom stage folder
 * - Custom menu code must be written from scratch
 */