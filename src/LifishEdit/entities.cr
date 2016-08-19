module LE

# All possible entities in a level. Used to
# create `LE::Entity`.
ENTITIES = {
	'0' => :empty,
	'1' => :fixed,
	'2' => :breakable,
	'3' => :coin,
	'X' => :player1,
	'Y' => :player2,
	'+' => :teleport,
	'A' => :enemy1,
	'B' => :enemy2,
	'C' => :enemy3,
	'D' => :enemy4,
	'E' => :enemy5,
	'F' => :enemy6,
	'G' => :enemy7,
	'H' => :enemy8,
	'I' => :enemy9,
	'J' => :enemy10,
	'*' => :boss,
	'4' => :transparent_wall
}

# Gets entity value from its key
# (e.g. `LE.get_entity('+') # => :teleport`)
def self.get_entity(c)
	ENTITIES[c] || :unknown
end

# Gets entity key from its value
# (e.g. `LE.get_entity_symbol(:boss) # => '*'`)
def self.get_entity_symbol(e) : Char
	ENTITIES.each { |k, v| return k if v == e }
	return '0'
end

end # module LE
