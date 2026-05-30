# App

# Robert Lerner Final Project: D&D Campaign Hub

## Overview

This project is a Phoenix LiveView **D&D Campaign Hub**. It gives a Dungeon Master and players tools for managing a campaign, including characters, portraits, inventory, quests, dice rolling, initiative tracking, role-based notes, and JSON API routes.

Public site: `https://eg.bucknell.edu/csci379f`

Main project route: `/dnd`

## Main Features and Locations

### D&D Dashboard

Route: `/dnd`

File: `lib/app_web/live/dnd_live/dashboard.ex`

The dashboard links to the major final project features: Dice Roller, Characters, Initiative Tracker, Inventory, Quest Board, and Notes.

### Character Sheets and Portrait Uploads

Routes: `/dnd/characters`, `/dnd/characters/new`, `/dnd/characters/:id`, `/dnd/characters/:id/edit`

Files: `lib/app/dnd/character.ex`, `lib/app_web/live/character_live/index.ex`, `lib/app_web/live/character_live/show.ex`, `lib/app_web/live/character_live/form.ex`

Users can create characters with stats, notes, and uploaded portrait images. Portraits display on the character index and show pages.

### Inventory System

Routes: `/dnd/inventory`, `/dnd/inventory/new`, `/dnd/inventory/:id`, `/dnd/inventory/:id/edit`

Files: `lib/app/dnd/inventory_item.ex`, `lib/app_web/live/dnd_live/inventory_item_live/index.ex`, `lib/app_web/live/dnd_live/inventory_item_live/show.ex`, `lib/app_web/live/dnd_live/inventory_item_live/form.ex`

Inventory items track name, owner, quantity, category, description, and character assignment.

### Character and Inventory Association

Files: `lib/app/dnd.ex`, `lib/app/dnd/character.ex`, `lib/app/dnd/inventory_item.ex`, `lib/app_web/live/character_live/show.ex`, `lib/app_web/live/dnd_live/inventory_item_live/form.ex`

Inventory items can be assigned to characters, and the character show page displays the items carried by that character.

### Quest Board

Route: `/dnd/quests`

Files: `lib/app/dnd/quest.ex`, `lib/app_web/live/dnd_live/quests.ex`

The quest board tracks quests by status: Available, In Progress, Completed, and Failed. Quests include title, giver, location, reward, difficulty, due date, description, and status.

### Real-Time Dice Roller

Route: `/dnd/dice`

File: `lib/app_web/live/dnd_live/dice.ex`

The dice roller supports player names, multiple dice, modifiers, advantage, disadvantage, and a live roll log.

### Initiative Tracker

Route: `/dnd/initiative`

File: `lib/app_web/live/dnd_live/initiative.ex`

The initiative tracker supports saved characters, custom monsters, turn order, damage, healing, conditions, removing combatants, and clearing combat.

### Role-Based Campaign Notes

Routes: `/dnd/notes`, `/dnd/notes/new`, `/dnd/notes/:id`, `/dnd/notes/:id/edit`

Files: `lib/app/dnd/note.ex`, `lib/app_web/live/dnd_live/note_live/index.ex`, `lib/app_web/live/dnd_live/note_live/show.ex`, `lib/app_web/live/dnd_live/note_live/form.ex`, `lib/app/accounts/user.ex`

The notes system uses authentication and role-based visibility. DM users can see DM-only notes, shared notes, their own private notes, and player private notes. Player users can see shared notes and their own private notes, but not DM-only notes or other players' private notes.

### JSON API

Routes: `/api/dnd/characters`, `/api/dnd/inventory`, `/api/dnd/quests`, `/api/dnd/notes`, `/api/dnd/summary`

File: `lib/app_web/controllers/dnd_api_controller.ex`

These routes return JSON data for the D&D project.

## Required Rubric Items Completed

### LiveView-Based Authentication

Files: `lib/app/accounts/user.ex`, `lib/app_web/live/dnd_live/note_live/index.ex`, `lib/app_web/live/dnd_live/note_live/show.ex`, `lib/app_web/live/dnd_live/note_live/form.ex`

Authentication is used for the notes system, where users see different notes depending on whether they are a DM or player.

### LiveView Real-Time Events and Page Updates

Files: `lib/app_web/live/dnd_live/dice.ex`, `lib/app_web/live/dnd_live/initiative.ex`, `lib/app_web/live/dnd_live/quests.ex`

LiveView events update dice rolls, initiative order, HP, conditions, combatants, and quest status.

### Layout, Menus, and Functional Components

Files: `lib/app_web/live/dnd_live/dashboard.ex`, `lib/app_web/components/ui/navbar.ex`, `lib/app_web/components/ui/button.ex`, `lib/app_web/components/ui/card.ex`, `lib/app_web/components/ui/modal.ex`, `lib/app_web/components/ui/badge.ex`

The project includes a dashboard, navigation, styled cards, buttons, badges, modals, and consistent page layouts.

### Transition Animations

Files: `lib/app_web/live/dnd_live/dashboard.ex`, `lib/app_web/live/character_live/index.ex`, `lib/app_web/live/dnd_live/quests.ex`, `lib/app_web/live/dnd_live/note_live/index.ex`, `lib/app_web/components/ui/modal.ex`

The UI uses hover effects, button transitions, card transitions, and modal styling.

### Dark Mode

Files: `lib/app_web/live/dnd_live/dashboard.ex`, `lib/app_web/live/character_live/index.ex`, `lib/app_web/live/character_live/show.ex`, `lib/app_web/live/dnd_live/dice.ex`, `lib/app_web/live/dnd_live/initiative.ex`, `lib/app_web/live/dnd_live/quests.ex`, `lib/app_web/live/dnd_live/note_live/index.ex`

The D&D project uses a consistent dark theme with slate backgrounds, red accents, and readable text.

### Breakpoints and Mobile-First Design

Files: `lib/app_web/live/dnd_live/dashboard.ex`, `lib/app_web/live/character_live/index.ex`, `lib/app_web/live/dnd_live/inventory_item_live/index.ex`, `lib/app_web/live/dnd_live/note_live/index.ex`, `lib/app_web/live/dnd_live/quests.ex`

The project uses responsive Tailwind layouts like `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3`.

### Test Coverage

Current result: `158 tests, 0 failures, 66.7% coverage`

This satisfies the required 40% coverage item and earns the 50% and 65% coverage bonus tiers.

## Optional Rubric Items Chosen

### 1. Associative Schemas

Files: `lib/app/dnd.ex`, `lib/app/dnd/character.ex`, `lib/app/dnd/inventory_item.ex`, `lib/app_web/live/character_live/show.ex`

Characters can have assigned inventory items.

### 2. JSON API

File: `lib/app_web/controllers/dnd_api_controller.ex`

Routes: `/api/dnd/characters`, `/api/dnd/inventory`, `/api/dnd/quests`, `/api/dnd/notes`, `/api/dnd/summary`

### 3. Associate Forms

File: `lib/app_web/live/dnd_live/inventory_item_live/form.ex`

The inventory form lets users assign an item to a character.

### 4. File Uploads

File: `lib/app_web/live/character_live/form.ex`

The character form supports portrait uploads.

### 5. Embedded Schemas / Custom Ecto Datatypes

File: `lib/app/games/minesweeper.ex`

Minesweeper uses an embedded schema for game state.

### 6. Displaying Fancy Charts

File: `lib/app_web/live/charts_live.ex`

The application includes a Chart.js LiveView page.

### 7. YAML / JSON ETS Database

Files: `lib/app/ets.ex`, `lib/app_web/live/minesweeper_live.ex`, `lib/app_web/live/rock_paper_scissors_live.ex`

The app uses ETS-backed in-memory game state for Minesweeper and Rock Paper Scissors.
