# LifishEdit
<img src="https://i.imgur.com/2TjPlxl.png" alt="Lifish-Edit Preview" height="400px">

LifishEdit is a small graphical level editor for [Lifish](https://github.com/silverweed/lifish).
It's currently work-in-progress but usable.

Currently working on:
- Linux
- MacOS

## Installation

A Crystal compiler **with version >= 0.20 && < 0.24** is required. Latest Crystal won't be able to build this program due to a bug in the compiler.

Install the dependencies:

```
shards install
```

Then follow [the instructions for installing CrSFML](https://github.com/oprypin/crsfml/blob/master/README.md) to
have it working.

Once you're done setting up CrSFML, build the program:

```
make
```

**IMPORTANT**: currently, due to a bug of the Crystal compiler, you cannot build in release mode. Just build
in debug mode (the default).

If you're on OSX and wish to have the executable packaged as an App bundle, run `./makeapp_osx.sh` *after* you've
successfully compiled the program. The script belongs to the "works for me" family, so it may not work out of the
box on your machine -- in that case, ensure you have the developer tools, SFML and all its dependencies installed.
If it still doesn't work and you can't get to tweak it right, just use `./run.sh` instead (see next paragraph).

## Usage

Running:

```
./run.sh [lifish directory]
```

On Mac, you may need to specify the location of CSFML if it isn't in `rpath` already.
In this case, use:

```
LD_LIBRARY_PATH=/path/to/CSFML ./run.sh [opts]
```

## Contributing

1. Fork it ( https://github.com/silverweed/lifish-edit/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [silverweed](https://github.com/silverweed) - creator, maintainer
