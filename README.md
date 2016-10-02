# LifishEdit
LifishEdit is a small graphical level editor for [Lifish](https://github.com/silverweed/lifish).
It's currently work-in-progress and not fully working yet.

Currently working on:  
- Linux  
- MacOS 

**TODO**: fix walls; change RClick to something else on Mac.

## Installation

Building:

```
make
```

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

## Development
Building LifishEdit requires the [Crystal](http://crystal-lang.org) compiler, SFML and 
[crsfml](https://github.com/BlaXpirit/crsfml).

## Contributing

1. Fork it ( https://github.com/silverweed/lifish-edit/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [silverweed](https://github.com/silverweed) - creator, maintainer
