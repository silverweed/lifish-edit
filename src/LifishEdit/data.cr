require "json"

module LE

# The data contained in levels.json
module Data

class LevelSetData
	JSON.mapping({
		name:       String,
		author:     { type: String, nilable: true },
		difficulty: { type: String, nilable: true },
		tracks:     Array(Track),
		enemies:    Array(Enemy),
		levels:     Array(Level),
	})
end

class Enemy
	class Attack
		JSON.mapping({
			type:     Array(String),
			damage:   UInt16,
			id:       { type: UInt16, nilable: true },
			speed:    { type: Float32, nilable: true },
			fireRate: { type: Float32, nilable: true },
		})
	end
	JSON.mapping({
		name:   String,
		ai:     UInt16,
		speed:  Float32,
		attack: Enemy::Attack,
	})
end

class Track
	class Loop
		JSON.mapping({
			start:  Float32,
			length: Float32,
		})
	end
	JSON.mapping({
		name:   { type: String, nilable: true },
		author: { type: String, nilable: true },
		loop:   Track::Loop,
	})
end

class Level
	JSON.mapping({
		time:    Int32,
		music:   UInt16,
		tileIDs: TileIDs,
		tilemap: String,
	})
end

class TileIDs
	def initialize(@bg : UInt16 = 1_u16,
		       @border : UInt16 = 1_u16,
		       @fixed : UInt16 = 1_u16,
		       @breakable : UInt16 = 1_u16)
	end

	JSON.mapping({
		bg:        UInt16,
		border:    UInt16,
		fixed:     UInt16,
		breakable: UInt16,
	})
end

end # module Data

end # module LE
