module LE

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
	'4' => :transparent
}

def self.get_entity(c)
	ENTITIES[c] || :unknown
end

end # module LE
