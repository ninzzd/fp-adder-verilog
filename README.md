# Floating-Point Adder and Subtractor
A project implementing variable-precision floating-point arithmetic units, specifically for addition and subtraction, in accordance with the IEEE 754 floating-point standards.
## Micro-Architecture
![Microarchtiectural Diagram](/docs/microarch_diag.jpg)

## Hierarchy

A quick overview of the directory tree and the purpose of each file/folder:

```text
├── src/                # Source files (.v)
│   ├── datapath/       # Specific to this project, build the datapath
│   ├── utils/          # Modules for general circuits (add, mux, inc, etc.)
│   └── fpadd.v         # Main module source file (.v)
├── tb/                 # Test-bench files (.v)
│   ├── datapath_tb/    # Test-benches for datapath-specific modules
│   ├── utils_tb/       # Test-benches for general modules
│   └── fpadd.v         # Main test-bench file (.v)
├── docs/               # Technical documentation and diagrams
│   ├── README.md       # Documentation
│   └── logs/           # Waveform images and logs of test runs
└── README.md           # You are here
```

## Documentation
Refer to [this page](/docs/README.md) for detailed documentation regarding implementation details, architecture, testbenches and analyses.

## RoadMap
- [x] Handles additions/subtractions of normalized numbers.
- [ ] Accounts for sub-normal numbers.
- [ ] Handles +0, -0
- [ ] Handles $+\infty$, $-\infty$
- [ ] Handles NaN propagation
- [ ] Extensive testing with SoftFloat
- [ ] Pipelining and multi-cycle design
- [ ] Testing on FPGA hardware and benchmarking