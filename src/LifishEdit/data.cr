require "json"

module LE

# The data contained in levels.json
module Data

struct LevelSetData
	JSON.mapping(
		name:       String,
		author:     { type: String, nilable: true },
		difficulty: { type: String, nilable: true },
		created:    { type: String, nilable: true },
		comment:    { type: String, nilable: true },
		tracks:     Array(Track),
		enemies:    Array(Enemy),
		levels:     Array(Level),
	)
end

struct Enemy
	struct Attack
		JSON.mapping(
			type:      Array(String),
			id:        { type: UInt16,  nilable: true },
			fireRate:  { type: Float32, nilable: true },
			blockTime: { type: Float32, nilable: true },
			range:     { type: Float32, nilable: true },
			tileRange: { type: UInt16,  nilable: true }
		)
	end
	JSON.mapping(
		name:   String,
		ai:     UInt16,
		speed:  Float32,
		attack: Enemy::Attack,
	)
end

struct Track
	struct Loop
		JSON.mapping(
			start:  Float32,
			length: Float32,
		)
	end
	JSON.mapping(
		name:   { type: String, nilable: true },
		author: { type: String, nilable: true },
		loop:   Track::Loop,
	)
end

struct Level
	JSON.mapping(
		time:    Int32,
		music:   UInt16,
		width:   { type: UInt16, nilable: true },
		height:  { type: UInt16, nilable: true },
		tileIDs: TileIDs,
		tilemap: String,
		effects: { type: Array(String), nilable: true }
	)
end

struct TileIDs
	def initialize(@bg : UInt16 = 1_u16,
		       @border : UInt16 = 1_u16,
		       @fixed : UInt16 = 1_u16,
		       @breakable : UInt16 = 1_u16)
	end

	JSON.mapping(
		bg:        UInt16,
		border:    UInt16,
		fixed:     UInt16,
		breakable: UInt16,
	)
end

end # module Data

end # module LE
