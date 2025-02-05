# Life-Machine
Life Machine: Blazing-Fast Evolution Simulator
A high-performance artificial life simulator that combines raw C processing power with LÖVE's visualization framework. Watch cells evolve, compete, and develop complex behaviors through accelerated natural selection.
Show Image
Overview
Life Machine simulates cellular life at extreme speeds by splitting computation between optimized C code and a Lua/LÖVE interface. Cells live, die, mutate, and interact in a rich chemical environment that shapes their evolution.
Core Features

Turbocharged Backend: SIMD-optimized C core simulates millions of cells
Genetic Evolution: Cells run evolved programs that control their behavior
Chemical World: Complex diffusion system creates environmental challenges
Real-time Viewing: Watch evolution happen or fast-forward through generations
Data Tracking: Monitor populations, genetics, and environmental changes

Getting Started
bashCopy# Clone it
git clone https://github.com/yourusername/life-machine.git

# Build the core
cd life-machine/core
make

# Fire it up
cd ..
love .
How it Ticks
The simulation runs on three engines:
Chemical Engine

Giant grid tracking nutrients and waste
Lightning-fast diffusion calculations
Cell signaling and environmental gradients

Cell Engine

Manages all cell behaviors and interactions
Efficient memory pooling for cell lifecycle
Fast spatial lookup for cell neighbors

Gene Engine

Compact genetic programs control cells
Mutations create new behaviors
Natural selection drives evolution
Genetic sharing between cells

Speed Matters

Handles 1M+ cells at 60fps
Multi-threaded chemical processing
SIMD-powered calculations
Smooth C/Lua communication
Smart memory management


License
MIT - See LICENSE

Built with LÖVE, LuaJIT, and raw computation power.
