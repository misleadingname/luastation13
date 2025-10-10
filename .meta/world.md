# Worlds and you.

A World is just an ECS world, with the first entity having a World component and any amount of extra world specific components

## World component
The World component, for now, stores the Tilemap, a minimum Z Level, and a maximum Z Level

## Z Level
A Z Level is like a floor on a building, you can only be on a specific Z Level and you can move between them

## Tilemap
A Tilemap stores the tiles at each level, each tile being either a string id or nil. It's stored in 8x8x1 chunks
