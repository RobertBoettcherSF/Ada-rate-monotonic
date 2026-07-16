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
│   ├── rate_monotonic_tests.adb  # Comprehensive test suite (12+ tests)
│   └── tests.gpr                 # GPR project file for tests
├── run_tests.sh                # Shell script to run tests
└── Makefile                    # Makefile for building and testing
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

The test suite contains **12+ comprehensive tests** organized into 10 test suites:

### Test Suite 1: Priority Assignment (6 tests)
- Verifies tasks are sorted by period (shortest first)
- Verifies priorities are assigned correctly (higher priority = higher integer value)
- Tests edge cases: single task, already sorted tasks, equal periods

### Test Suite 2: ISR Mitigation (4 tests)
- Verifies ISR periods are capped to the shortest non-ISR period
- Tests ISRs with shorter periods than non-ISR tasks
- Tests all-ISR task sets
- Tests multiple ISRs with varying periods

### Test Suite 3: Utilization Calculation (4 tests)
- Tests simple utilization calculation
- Tests zero utilization
- Tests full utilization (100%)
- Tests over-utilization (>100%)

### Test Suite 4: Liu & Layland Schedulability (4 tests)
- Tests empty task set
- Tests single task with low utilization
- Tests task sets within the Liu & Layland bound
- Tests task sets exceeding the Liu & Layland bound

### Test Suite 5: Hyperbolic Bound Schedulability (4 tests)
- Tests empty task set
- Tests task sets where product (U_i + 1) <= 2
- Tests task sets where product (U_i + 1) > 2
- Tests single task

### Test Suite 6: Harmonic Task Set (4 tests)
- Tests harmonic task sets (periods are integer multiples)
- Tests non-harmonic task sets
- Tests single task (trivially harmonic)
- Tests empty task set (trivially harmonic)

### Test Suite 7: Harmonic Chains Schedulability (3 tests)
- Tests empty task set
- Tests pure harmonic sets
- Tests non-harmonic sets with multiple chains

### Test Suite 8: Stochastic Schedulability (4 tests)
- Tests empty task set
- Tests utilization well below 0.88
- Tests utilization exactly at 0.88
- Tests utilization above 0.88

### Test Suite 9: Edge Cases (5 tests)
- Tests very small computation times
- Tests very large periods
- Tests computation time equals period
- Tests mixed ISR and non-ISR with priority assignment

### Test Suite 10: Integration Tests (2 tests)
- Tests complete workflow: assign priorities, mitigate ISRs, check schedulability
- Tests all schedulability tests on the same task set

### Running Tests

#### Method 1: Using the shell script
```bash
./run_tests.sh
```

#### Method 2: Using make
```bash
make tests
# or
make run
```

#### Method 3: Manual compilation
```bash
cd tests
gprbuild -P tests.gpr
./bin/rate_monotonic_tests
```

### Test Output

The test suite produces output like:
```
[PASS] Test 1.1: Shortest period task first
[PASS] Test 1.2: Middle period task second
[FAIL] Test 1.3: Longest period task last
...

========================================================================
Test Summary:
  Total Tests:  42
  Passed:       41
  Failed:       1
  Success Rate:  97.619048%
========================================================================
```

## Usage Example

```ada
with Rate_Monotonic;

procedure Example is
   use Rate_Monotonic;

   -- Define a task set
   Tasks : Task_Array := (
      (Id => 1, Computation_Time => 1.0, Period => 10.0, Is_ISR => False),
      (Id => 2, Computation_Time => 2.0, Period => 20.0, Is_ISR => False),
      (Id => 3, Computation_Time => 0.5, Period => 5.0, Is_ISR => True)
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

## License

This project is open source. See the repository for licensing details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run the test suite to ensure nothing breaks
5. Submit a pull request

## Version History

- **v1.0**: Initial implementation with comprehensive test suite (12+ tests)
