all: src/consts.cr src/utils.cr src/entities.cr src/level.cr src/levelset.cr src/level_renderer.cr src/getopt.cr src/entity.cr src/main.cr
	crystal build $^ -o lifishedit
