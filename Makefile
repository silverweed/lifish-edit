FILES = src/nfd.cr src/consts.cr src/utils.cr src/entities.cr src/level.cr src/levelset.cr src/level_renderer.cr src/getopt.cr src/entity.cr src/mouse_utils.cr src/save.cr src/main.cr

build: $(FILES)
	crystal build $^ -o lifishedit

docs: $(FILES)
	crystal docs $^

