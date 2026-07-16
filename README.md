# Ada-rate-monotonic

Ada implementation of the Rate-Monotonic Scheduling (RMS) algorithm with comprehensive test suite.

## Overview

This package provides an Ada implementation of Rate-Monotonic Scheduling (RMS), a static-priority scheduling algorithm for real-time systems. The implementation includes:

- **Priority Assignment**: Automatic assignment of static priorities based on task periods (shorter period = higher priority)
- **ISR Mitigation**: Correction of mis-prioritized Interrupt Service Routines
- **Schedulability Tests**: Multiple theoretical bounds for determining if a task set is schedulable:
  - Liu & Layland Least Upper Bound
  - Hyperbolic Bound (Bini et al.)
  - Harmonic Task Set Analysis
  - Harmonic Chains (Kuo & Mok)
  - Stochastic Bounds Approximation
- **Resource Sharing**: Priority Ceiling Protocol via Ada protected objects

## Project Structure

```
.
├── rate_monotonic.ads          # Package specification
├── rate_monotonic.adb          # Package implementation
├── rate_monotonic.gpr          # GPR project file for the library
├── tests/
│   ├── rate_monotonic_tests.adb  # Comprehensive test suite (42+ tests)
│   ├── tests.gpr                 # GPR project file for tests
│   ├── obj/                      # Object files directory (auto-created)
│   └── bin/                      # Executable files directory (auto-created)
├── obj/                         # Object files directory (auto-created)
├── run_tests.sh                # Shell script to run tests
├── Makefile                    # Makefile for building and testing
└── README.md                    # This file
```

## Compilation

### Prerequisites

- GNAT (GNU Ada Compiler) or GPRbuild
- Ada 2012 support

#### Installing on Ubuntu/Debian:
```bash
sudo apt-get install gnat gprbuild
```

#### Installing on Fedora:
```bash
sudo dnf install gcc-gnat gprbuild
```

#### Installing on macOS (with Homebrew):
```bash
brew install gnat
```

### Building the Library

```bash
# Using gprbuild
gprbuild -P rate_monotonic.gpr

# Using make
make compile
```

## Running Tests

The test suite contains **42+ comprehensive tests** organized into 10 test suites. All necessary directories (`tests/obj`, `tests/bin`, `obj`) are automatically created by the build scripts.

### Method 1: Using the shell script (recommended)
```bash
./run_tests.sh
```

### Method 2: Using make
```bash
make tests
# or
make run
```

### Method 3: Manual compilation
```bash
cd tests
gprbuild -P tests.gpr
./bin/rate_monotonic_tests
```

### Test Output Example:
```
[PASS] Test 1.1: Shortest period task first
[PASS] Test 1.2: Middle period task second
...
========================================================================
Test Summary:
  Total Tests:  42
  Passed:       42
  Failed:       0
  Success Rate:  100.0%
========================================================================
All tests PASSED!
```

## Usage Example

```ada
with Rate_Monotonic;

procedure Example is
   use Rate_Monotonic;

   -- Define a task set using named notation
   Tasks : Task_Array := (
      1 => (Id => 1, Computation_Time => 1.0, Period => 10.0),
      2 => (Id => 2, Computation_Time => 2.0, Period => 20.0),
      3 => (Id => 3, Computation_Time => 0.5, Period => 5.0, Is_ISR => True)
   );

   U : Float;
   Is_Schedulable : Boolean;
begin
   -- Assign priorities based on Rate-Monotonic principle
   Assign_Priorities (Tasks);

   -- Mitigate ISR priority issues
   Mitigate_ISRs (Tasks);

   -- Calculate utilization
   U := Calculate_Utilization (Tasks);

   -- Check schedulability using different tests
   Is_Schedulable := Is_Schedulable_Liu_Layland (Tasks);
   Is_Schedulable := Is_Schedulable_Hyperbolic (Tasks);
   Is_Schedulable := Is_Schedulable_Stochastic (Tasks);
end Example;
```

## Theory Background

### Rate-Monotonic Scheduling

Rate-Monotonic Scheduling (RMS) is a static-priority scheduling algorithm where priorities are assigned based on task periods: shorter period = higher priority.

### Schedulability Tests

1. **Liu & Layland Bound**: For n tasks, the system is schedulable if U ≤ n(2^(1/n) - 1)
   - For n=1: U ≤ 1.0 (100% utilization)
   - For n=2: U ≤ ~0.828 (82.8% utilization)
   - As n→∞: U ≤ ln(2) ≈ 0.693 (69.3% utilization)

2. **Hyperbolic Bound**: The system is schedulable if ∏(U_i + 1) ≤ 2
   - Tighter than Liu & Layland for many task sets

3. **Harmonic Task Set**: All task periods are exact integer multiples of all shorter periods
   - For harmonic sets, U ≤ 1.0 is achievable

4. **Stochastic Bound**: Most randomly generated systems are schedulable if U ≤ 0.88

## Test Design Philosophy

The tests follow these principles:

1. **Assumptions**: Each test makes explicit assumptions about what the code should do
2. **Different Assumptions**: Tests cover various scenarios (normal, edge, boundary cases)
3. **Proven False**: Tests will fail if the implementation is incorrect, proving the assumption false

This ensures the implementation is robust and correct across a wide range of inputs.

## Troubleshooting

### "exec directory 'bin' not found" error

This error occurs when the `bin` directory doesn't exist. The build scripts now automatically create all necessary directories. If you still see this error:

1. Make sure you're running the build from the project root
2. Run `mkdir -p tests/bin tests/obj obj` manually
3. Or use the provided scripts (`./run_tests.sh` or `make tests`) which create directories automatically

### "no value supplied for component Priority" error

This error occurs when using positional aggregate notation for Task_Record. Always use named notation:

```ada
-- Correct (named notation):
Tasks : Task_Array := (
   1 => (Id => 1, Computation_Time => 1.0, Period => 10.0)
);

-- Incorrect (positional notation - will fail):
Tasks : Task_Array := (
   1 => (1, 1.0, 10.0)  -- Missing Priority and Is_ISR
);
```

## License

This project is open source. See the repository for licensing details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run the test suite to ensure nothing breaks
5. Submit a pull request

## Version History

- **v1.1**: Fixed compilation issues, added directory placeholders, improved build scripts
- **v1.0**: Initial implementation with comprehensive test suite (42+ tests)
