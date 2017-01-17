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
	'*' => :alien_boss,
	'4' => :transparent_wall,
	'5' => :acid_pond,
	'6' => :haunted_statue,
	'=' => :haunting_spirit_boss
}

# Gets entity value from its key
# (e.g. `LE.get_entity('+') # => :teleport`)
def self.get_entity(c)
	ENTITIES[c] || :unknown
end

# Gets entity key from its value
# (e.g. `LE.get_entity_symbol(:alien_boss) # => '*'`)
def self.get_entity_symbol(e) : Char
	ENTITIES.each { |k, v| return k if v == e }
	return '0'
end

# Gets the entity size in tiles
def self.get_entity_size(e)
	case e
	when :alien_boss
		{3, 3}
	when :haunting_spirit_boss
		{4, 4}
	when :haunted_statue
		{1, 2}
	else
		{1, 1}
	end
end

end # module LE
