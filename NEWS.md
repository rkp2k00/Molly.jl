# Molly.jl release notes

## v0.14.3 - Feb 2023

### Bug fixes

- A bug introduced by a new version of ForwardDiff.jl is fixed.

## v0.14.2 - Feb 2023

### New features
- The Müller-Brown potential is added as `MullerBrown`.

## v0.14.1 - Jan 2023

### New features
- The Buckingham potential is added as `Buckingham`.
- Polymer melt and density functional theory examples are added to the documentation.

### Bug fixes
- A bug introduced by a new version of AtomsBase.jl is fixed. In addition, atoms in systems without `atoms_data` defined now return `:unknown` from `AtomsBase.atomic_symbol`.
- A bug in the export of `OpenMMResidueType` is fixed.

## v0.14.0 - Dec 2022

### Breaking changes
- The type parameters and fields of `System`, `ReplicaSystem`, `ImplicitSolventOBC` and `ImplicitSolventGBN2` are changed.
- The type parameters of `TemperatureREMD` are changed.

### Non-breaking changes
- The `mass` function falls back to accessing the `mass` field, making it easier to define custom atom types.

### New features
- A Monte Carlo simulator that uses the Metropolis algorithm is added as `MetropolisMonteCarlo`. `MonteCarloLogger` is added to record acceptance information. `random_uniform_translation!` and `random_normal_translation!` are added to generate trial moves.
- `HamiltonianREMD` is added to allow REMD with different interactions for each replica. `remd_exchange!` and `simulate_remd!` are added to allow custom REMD simulators to be defined by giving the exchange function. `replica_pairwise_inters`, `replica_specific_inter_lists` and `replica_general_inters` can now be given when constructing a `ReplicaSystem` to allow different interactions for each replica.
- Soft core versions of the Lennard-Jones and Coulomb interactions are added as `LennardJonesSoftCore` and `CoulombSoftCore`.
- Preliminary support for bonded constraints using the SHAKE algorithm is added via `SHAKE` and `apply_constraints!`. `constraints` can be used to define the constraints when constructing a `System`, with corresponding arguments for a `ReplicaSystem`. This feature is still under development and is not fully documented yet.
- Additional keyword arguments can now be used in `log_property!`, making the logging of properties in custom simulators easier.
- A section on related software is added to the documentation.

### Performance improvements
- Implicit solvent force and energy calculation are made faster and more memory efficient.

### Bug fixes
- A bug when constructing the `Mie` potential with certain parameters is fixed.

## v0.13.0 - Aug 2022

### Breaking changes
- The minimum distance argument to `place_atoms` and `place_diatomics` is now the keyword argument `min_dist` with a default value of no distance. `place_diatomics` now places the molecules facing random directions, with the old behaviour available by setting `aligned=true`. `place_diatomics` now checks for sensible inputs and terminates after a certain number of failed attempts like `place_atoms`.
- The argument order in `apply_coupling!` is switched from `apply_coupling!(system, simulator, coupling)` to `apply_coupling!(system, coupling, simulator)`.
- The default mass of an `Atom` is changed from `0.0u"u"` to `1.0u"u"`.
- The `AbstractNeighborFinder` abstract type is removed.
- The `centre_coords` keyword argument when constructing a `System` from files is renamed to `center_coords`.
- Center of mass motion is now removed before loggers are run at step zero of a simulation, matching the behaviour during the simulation steps.

### Non-breaking changes
- `visualize` shows the boundary as lines by default and has the `show_boundary`, `boundary_linewidth` and `boundary_color` keyword arguments added.

### New features
- Temperature replica exchange MD (REMD) can now be run in parallel. The `ReplicaSystem` struct is added to act as a container for multiple `System`s. The `TemperatureREMD` simulator and `ReplicaExchangeLogger` are added to set up and run replica exchange simulations.
- `TriclinicBoundary` is added and can be used to simulate periodic boundary conditions in a triclinic box. A `TriclinicBoundary` can be constructed from either 3 basis vectors or 3 basis vector lengths and angles α/β/γ. The `box_center` function is added.

### Bug fixes
- Coordinates are now moved back inside the boundary before the first step of the simulation.

## v0.12.1 - Aug 2022

- Updates are made to support the latest Zygote.jl and UnitfulChainRules.jl versions.
- A bug in implicit solvent gradient setup is fixed.

## v0.12.0 - Jul 2022

- The `parallel` keyword argument is renamed to `n_threads` throughout, allowing an exact number of threads to be specified with the default remaining `Threads.nthreads()`.
- Arguments for bonded interactions are made more consistent: `HarmonicBond` has `kb` renamed to `k` and `b0` to `r0`, `HarmonicAngle` has `cth` renamed to `k` and `th0` to `θ0`, and `MorseBond` has `α` renamed to `a`.
- An additional type parameter is added to `System` that records whether it is on the GPU. The `is_on_gpu` function is added to access this property.
- The `Interaction` abstract type is removed.
- The `HarmonicPositionRestraint` interaction for restraining atomic positions, commonly used during equilibration of biomolecular systems, is added. `InteractionList1Atoms` and `SpecificForce1Atoms` are added to allow the definition of interactions that apply a force to one atom. The `add_position_restraints` function is added to apply position restraints to a `System`, along with the atom selector functions `is_any_atom` and `is_heavy_atom`.
- The `CosineAngle` interaction for the cosine bond angle between three atoms is added.
- The `FENEBond` interaction for the finitely extensible non-linear elastic (FENE) bond between two atoms is added.
- The `masses` function to access the mass of each atom in a `System` is added.
- `AndersenThermostat` is made differentiable.
- `DistanceNeighborFinder` and `TreeNeighborFinder` now use FLoops.jl and show improved performance on multiple threads.
- Inconsistent `System` setup now throws an error.
- Equations are added to some docstrings.

## v0.11.0 - Jun 2022

- `box_size` is renamed to `boundary` throughout. Boundaries of the form `SVector(1.0, 2.0, 3.0)` should be replaced by `CubicBoundary(1.0, 2.0, 3.0)`, allowing non-cubic boundaries to be added in future. Setting one or more values to `Inf` gives no boundary in that dimension. `RectangularBoundary` should be used for 2D simulations. `float_type`, `box_volume` and `AtomsBase.n_dimensions` are defined for boundaries.
- The recorded values in loggers are now accessed with `Base.values`. Loggers are now given to the `System` as a named tuple rather than as a `Dict` for performance reasons.
- `wrap_coords_vec` is renamed to `wrap_coords`, `wrap_coords` is renamed to `wrap_coord_1D`, `vector1D` is renamed to `vector_1D`, the `cutoff` argument to the implicit solvent models is renamed to `dist_cutoff`, and the `nl_dist` argument to `System` is renamed to `dist_neighbors`.
- The general `LangevinSplitting` simulator is added to allow a variety of integrators to be defined such as velocity Verlet (splitting `"BAB"`), the Langevin implementation in `Langevin` (`"BAOA"`), and symplectic Euler integrators (`"AB"` and `"BA"`).
- `GeneralObservableLogger` is added to periodically record a given observable throughout the simulation. Most existing loggers are changed to be cases of `GeneralObservableLogger`. `AverageObservableLogger` is also added and records a running average rather than storing observations.
- `TimeCorrelationLogger` is added to calculate correlations between observables. `AutoCorrelationLogger` corresponds to the case when the two observables are the same.
- The keyword argument `k` to `System`, `velocity` and `maxwell_boltzmann` allows a custom Boltzmann constant to be used.
- More of the package is made differentiable due to the use of UnitfulChainRules.jl.

## v0.10.4 - Jun 2022

- Visualisation is updated to use GLMakie.jl v0.6.

## v0.10.3 - Jun 2022

- `place_atoms` now checks for sensible inputs and terminates after a certain number of failed attempts.
- A bug in precompilation is fixed.

## v0.10.2 - May 2022

- `ForceLogger` is added.
- The `parallel` keyword argument is now available in the `log_property!` function.
- More examples are added to the documentation.
- A bug in the `Mie` potential energy is fixed.

## v0.10.1 - May 2022

- A bug in the `Gravity` force and potential energy is fixed.

## v0.10.0 - Apr 2022

- Loggers now also run before the first simulation step, i.e. at step 0, allowing the starting state to be recorded.
- `inject_gradients` now returns general interactions in addition to atoms, pairwise interactions and specific interaction lists.
- Steepest descent energy minimization is added via `SteepestDescentMinimizer`.
- GPU support is added for `potential_energy`.
- The `radius_gyration` function is added.
- A kappa value for ionic screening may be given to `ImplicitSolventOBC` and `ImplicitSolventGBN2`.
- Improvements are made to simulation setup such as allowing multiple macromolecular chains.
- A random number generator can now be passed to `Langevin`, allowing reproducible simulations.
- Gradients through the GB-Neck2 interaction are made to work on the GPU.
- Bugs in `StormerVerlet` are fixed.
- The possibility of a NaN value for the `HarmonicAngle` force when the angle is π is fixed.
- A bug causing `random_velocities` to run slowly is fixed.

## v0.9.0 - Mar 2022

- The arguments to `forces` and `accelerations` are made consistent across implementations.
- Centre of mass motion is removed by default during simulation using `remove_CM_motion!`.
- Coordinates are centred in the simulation box by default during setup.
- The `Langevin` integrator and `Verlet` integrator are added.
- The `MorseBond` potential is added.
- The GB-Neck2 implicit solvent model is added via `ImplicitSolventGBN2`.
- The `CubicSplineCutoff` is added.
- The `rmsd` function is added.
- The AtomsBase.jl interface is made more complete.
- The progress bar is removed from simulations.
- The out-of-place neighbor list type `NeighborListVec` is changed.

## v0.8.0 - Feb 2022

- General interactions are renamed to pairwise interactions throughout to better reflect their nature. The abstract type is now `PairwiseInteraction` and the keyword argument to `System` is now `pairwise_inters`. General interaction now refers to a new type of interaction that takes in the whole system and returns forces for all atoms, allowing interactions such as neural network potentials acting on the whole system. This is available via the keyword argument `general_inters` to `System`.
- Implicit solvent models are added via the `ImplicitSolventOBC` general interaction type and the `implicit_solvent` keyword argument when setting up a `System` from a file. The Onufriev-Bashford-Case GBSA model with parameter sets I and II is provided.
- `charge` is added to access the partial charge of an `Atom`.
- The `box_size` keyword argument may be given when setting up a `System` from a file.
- A bug in `KineticEnergyLogger` is fixed.

## v0.7.0 - Jan 2022

- The `force` and `potential_energy` functions for general interactions now take the vector between atom i and atom j as an argument in order to save on computation.
- Differentiable simulations are made faster and more memory-efficient.
- The AtomsBase.jl interface is updated to v0.2 of AtomsBase.jl.
- `extract_parameters` and `inject_gradients` are added to assist in taking gradients through simulations.
- `bond_angle` and `torsion_angle` are added.
- `random_velocities` is added.
- A `solute` field is added to `Atom` allowing solute-solvent weighting in interactions. This is added to the `LennardJones` interaction.
- A `proper` field is added to `PeriodicTorsion`.
- The float type is added as a type parameter to `System`. `float_type` and `is_gpu_diff_safe` are added to access the type parameters of a `System`.
- A `types` field is added to types such as `InteractionList2Atoms` to record interaction types.
- `find_neighbors` can now be given just the system as an argument.
- Visualisation is updated to use GLMakie.jl v0.5.
- Bugs in velocity generation and temperature calculation with no units are fixed.

## v0.6.0 - Jan 2022

- Differentiable simulation works with Zygote reverse and forward mode AD on both CPU and GPU. General and specific interactions are supported along with neighbor lists. It does not currently work with units, user-defined types and some components of the package.
- Significant API changes are made including a number of functions being renamed, thermostats being renamed to couplers and the removal of some types.
- `Simulation` is renamed to `System` and the time step and coupling are passed to the simulator, which is passed to the `simulate!` function.
- `System` is a sub-type of `AbstractSystem` from AtomsBase.jl and the relevant interface is implemented, allowing interoperability with the wider ecosystem.
- Specific interactions are changed to store indices and parameters as part of types such as `InteractionList2Atoms`. Specific interaction force functions now return types such as `SpecificForce4Atoms`. Specific interactions can now run on the GPU.
- Some abstract types are removed. `NeighborFinder` is renamed to `AbstractNeighborFinder`.
- The `potential_energy` function arguments match the `force` function arguments.
- File reader setup functions are called using `System` and return a `System` directly.
- `find_neighbors!` is renamed to `find_neighbors` and returns the neighbors, which are no longer stored as part of the simulation.
- `VelocityFreeVerlet` is renamed to `StormerVerlet`.
- `RescaleThermostat` and `BerendsenThermostat` are added.
- `random_velocities!` and `velocity_autocorr` are added.
- `VelocityLogger`, `KineticEnergyLogger` and `PotentialEnergyLogger` are added.
- `DistanceVecNeighborFinder` is added for use on the GPU.
- Atomic charges are now dimensionless, i.e 1.0 is an atomic charge of +1.
- `HarmonicAngle` now works in 2D.
- Support for Julia versions before 1.7 is dropped.

## v0.5.0 - Oct 2021

- Readers are added for OpenMM XML force field files and coordinate files supported by Chemfiles.jl. Forces, energies and the results of a short simulation exactly match the OpenMM reference implementation for a standard protein in the a99SB-ILDN force field.
- A cell neighbor list is added using CellListMap.jl.
- `CoulombReactionField` is added to calculate long-range electrostatic interactions.
- The `PeriodicTorsion` interaction is added and the previous Ryckaert-Bellemans `Torsion` is renamed to `RBTorsion`.
- Support for weighting non-bonded interactions between atoms in a 1-4 interaction is added.
- The box size is changed from one value to three, allowing a larger variety of periodic box shapes.
- Support for different mixing rules is added for the Lennard-Jones interaction, with the default being Lorentz-Bertelot mixing.
- A simple `DistanceCutoff` is added.
- Excluded residue names can now be defined for a `StructureWriter`.
- The `placediatomics` and `ustripvec` functions are added.
- The `AtomMin` type is removed, with `Atom` now being a bits type and `AtomData` used to store atom data.
- Visualisation now uses GLMakie.jl.
- `adjust_bounds` is renamed to `wrapcoords`.

## v0.4.0 - Sep 2021

- Unitful.jl support is added and recommended for use, meaning numbers have physical meaning and many errors are caught. More type parameters have been added to various types to allow this. It is still possible to run simulations without units by specifying the `force_unit` and `energy_unit` arguments to `Simulation`.
- Interaction constructors with keyword arguments are added or improved.
- The maximum force for non-bonded interactions is removed.

## v0.3.0 - May 2021

- The spelling of "neighbour" is changed to "neighbor" throughout the package. This affects `NoNeighborFinder`, `DistanceNeighborFinder`, `TreeNeighborFinder`, `find_neighbors!` and the `neighbor_finder` argument to `Simulation`.
- Torsion angle force calculation is improved.
- A bug in force calculation for specific interactions is fixed.
- Support for Julia versions before 1.6 is dropped.

## v0.2.2 - Feb 2021

- The `TreeNeighbourFinder` is added for faster distance neighbour finding using NearestNeighbors.jl.

## v0.2.1 - Dec 2020

- Documentation is added for cutoffs.
- Compatibility bounds are updated for various packages, including requiring CUDA.jl version 2.
- Support for Julia versions before 1.5 is dropped.

## v0.2.0 - Sep 2020

- Shifted potential and shifted force cutoff approaches for non-bonded interactions are introduced.
- An `EnergyLogger` is added and the potential energy for existing interactions defined.
- Simulations can now be run with the `CuArray` type from CUDA.jl, allowing GPU acceleration.
- The in-place `force!` functions are changed to out-of-place `force` functions with different arguments.
- The i-i self-interaction is no longer computed for `force` functions.
- The Mie potential is added.
- The list of neighbours is now stored in the `Simulation` type.
- Documentation is added for experimental differentiable molecular simulation.
- Optimisations are implemented throughout the package.
- Support for Julia versions before 1.3 is dropped.

## v0.1.0 - Jun 2020

Initial release of Molly.jl, a Julia package for molecular simulation.

Features:
- Interface to allow definition of new forces, simulators, thermostats, neighbour finders, loggers etc.
- Read in pre-computed Gromacs topology and coordinate files with the OPLS-AA forcefield and run MD on proteins with given parameters. In theory it can do this for any regular protein, but in practice this is untested.
- Non-bonded interactions - Lennard-Jones Van der Waals/repulsion force, electrostatic Coulomb potential, gravitational potential, soft sphere potential.
- Bonded interactions - covalent bonds, bond angles, torsion angles.
- Andersen thermostat.
- Velocity Verlet and velocity-free Verlet integration.
- Explicit solvent.
- Periodic boundary conditions in a cubic box.
- Neighbour list to speed up calculation of non-bonded forces.
- Automatic multithreading.
- Some analysis functions, e.g. RDF.
- Run with Float64 or Float32.
- Physical agent-based modelling.
- Visualise simulations as animations.
