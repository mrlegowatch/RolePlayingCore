# RolePlayingCore  [![Build Status](https://travis-ci.org/mrlegowatch/RolePlayingCore.svg?branch=master)](https://travis-ci.org/mrlegowatch/RolePlayingCore)

This framework provides reusable role playing game core logic in the Swift language. It is a work-in-progress. Capabilities will be provided incrementally over time.

The short-term goal for this project is to provide core logic for implementing a role playing game on macOS, iOS and Linux. The architecture is intended to be flexible enough to support Open Game Content in addition to similar kinds of games, and nimble enough to minimize upstream dependencies. The iOS platform in framework library format is being targeted first because this provides the most restrictive environment for implementing a library intended for reuse. The longer-term goal is to leverage this as a framework or library for implementing role playing games and utilities on the desktop and web.

## Organization

The current organizational groupings include:

* **Common**: common utilities such as height and weight, and a runtime error enum
* **Currency**: currency types, conversion and parsing
* **Dice**: dice types and parsing
* **Player**: the player, races, classes and related types

### Coming Soon...

In addition to fleshing out the Player grouping with types for classes, races, etc., the following additional groupings are currently being prototyped:

* **Items**: Item, Container, Ammunition, Armor, Equipment, Weapon, ...
* **Map**: Map, Geometry, Room, Door, Segment, Hallway, ...
* **Dungeon**: Document wrapper for Map instances

## What is currently implemented

The following types have an initial implementation with unit tests and full code coverage:

* **Player**: The base player class.
* **Ability**: An Ability type and nested Scores type for managing ability scores. Default ability types are provided.
* **Alignment**: Enumerations for Ethics and Morals, with a Kind and associated Double values.
* **ClassTraits**: Properties describing a class, that can be created from dictionary traits.
* **Classes**: A factory for managing ClassTraits.
* **RacialTraits**: Properties describing a race, that can be created from dictionary traits, and a parent race (for defining subraces).
* **Races**: A factory for managing RacialTraits.
* **UnitCurrency**: A subclass of Foundation.Dimension that can convert between different types of currency (e.g., gp, cp, pp). A DefaultCurrencies.json file is provided.
* **Money**: A Foundation.Measurement for UnitCurrency.
* **Dice**: Includes a Dice protocol, a Die type, and several implementations of the Dice protocol for simple dice rolls, modifiers, dropping and composition of dice rolls.
* **DiceParser**: Free functions and extensions for converting from string representations of dice rolls into Dice types.
* **RandomNumberGenerator**: An open class for use by the Die type. Can be modified as required.
* **Height** and **Weight**: Typealiases and free functions for parsing strings representing height and weight into Foundation.Measurement of types Foundation.UnitLength and Foundation.UnitMass.

Since this is still in the very early stages, I welcome feedback regarding organization and the current implementation.
