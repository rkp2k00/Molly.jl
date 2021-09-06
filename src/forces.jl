# See https://udel.edu/~arthij/MD.pdf for information on forces
# See https://arxiv.org/pdf/1401.1181.pdf for applying forces to atoms
# See Gromacs manual for other aspects of forces

export
    force,
    accelerations,
    LennardJones,
    SoftSphere,
    Mie,
    Coulomb,
    Gravity,
    HarmonicBond,
    HarmonicAngle,
    Torsion

function checkforcetype(fdr, force_type)
    if unit(first(fdr)) != force_type
        error("Simulation force type is ", force_type,
                " but encountered force type ", unit(first(fdr)))
    end
end

"""
    force(inter, coord_i, coord_j, atom_i, atom_j, box_size)

Calculate the force between a pair of atoms due to a given interation type.
Custom interaction types should implement this function.
"""
function force end

# Allow 2D broadcasting whilst eliminating the diagonal corresponding to self interaction
@inline @inbounds function force(inter, coord_i, coord_j, atom_i, atom_j, box_size, self_interaction, force_type)
    if isone(self_interaction)
        return ustrip.(zero(coord_i))
    else
        fdr = force(inter, coord_i, coord_j, atom_i, atom_j, box_size)
        checkforcetype(fdr, force_type)
        return ustrip.(fdr)
    end
end

@inline @inbounds function force!(forces, inter, s::Simulation, i::Integer, j::Integer, force_type)
    fdr = force(inter, s.coords[i], s.coords[j], s.atoms[i], s.atoms[j], s.box_size)
    checkforcetype(fdr, force_type)
    fdr_ustrip = ustrip.(fdr)
    forces[i] -= fdr_ustrip
    forces[j] += fdr_ustrip
    return nothing
end

mass(atom::Atom) = atom.mass
mass(atom::AtomMin) = atom.mass

"""
    accelerations(simulation; parallel=true)

Calculate the accelerations of all atoms using the general and specific
interactions and Newton's second law.
"""
function accelerations(s::Simulation; parallel::Bool=true)
    n_atoms = length(s.coords)

    if parallel && nthreads() > 1 && n_atoms >= 100
        forces_threads = [ustrip.(zero(s.coords)) for i in 1:nthreads()]

        # Loop over interactions and calculate the acceleration due to each
        for inter in values(s.general_inters)
            if inter.nl_only
                neighbors = s.neighbors
                @threads for ni in 1:length(neighbors)
                    i, j = neighbors[ni]
                    force!(forces_threads[threadid()], inter, s, i, j, s.force_unit)
                end
            else
                @threads for i in 1:n_atoms
                    for j in 1:(i - 1)
                        force!(forces_threads[threadid()], inter, s, i, j, s.force_unit)
                    end
                end
            end
        end

        forces = sum(forces_threads)
    else
        forces = ustrip.(zero(s.coords))

        for inter in values(s.general_inters)
            if inter.nl_only
                neighbors = s.neighbors
                for ni in 1:length(neighbors)
                    i, j = neighbors[ni]
                    force!(forces, inter, s, i, j, s.force_unit)
                end
            else
                for i in 1:n_atoms
                    for j in 1:(i - 1)
                        force!(forces, inter, s, i, j, s.force_unit)
                    end
                end
            end
        end
    end

    for inter_list in values(s.specific_inter_lists)
        sparse_forces = force.(inter_list, (s.coords,), (s,))
        ge1, ge2 = getindex.(sparse_forces, 1), getindex.(sparse_forces, 2)
        checkforcetype(first(first(ge2)), s.force_unit)
        sparse_vec = sparsevec(reduce(vcat, ge1), reduce(vcat, ge2), n_atoms)
        forces += ustrip.(Array(sparse_vec))
    end

    return (forces * s.force_unit) ./ mass.(s.atoms)
end

ustripvec(x) = ustrip.(x)

function accelerations(s::Simulation, coords, coords_is, coords_js, atoms_is, atoms_js, self_interactions)
    n_atoms = length(coords)
    forces = ustripvec.(zero(coords))

    for inter in values(s.general_inters)
        # Currently the neighbor list is not used for this implementation
        forces -= reshape(sum(force.((inter,), coords_is, coords_js, atoms_is, atoms_js,
                                        s.box_size, self_interactions, s.force_unit);
                                        dims=2), n_atoms)
    end

    for inter_list in values(s.specific_inter_lists)
        # Take coords off the GPU if they are on there
        coords_cpu = Array(coords)
        sparse_forces = force.(inter_list, (coords_cpu,), (s,))
        ge1, ge2 = getindex.(sparse_forces, 1), getindex.(sparse_forces, 2)
        checkforcetype(first(first(ge2)), s.force_unit)
        sparse_vec = sparsevec(reduce(vcat, ge1), reduce(vcat, ge2), n_atoms)
        # Move back to GPU if required
        forces += convert(typeof(forces), ustrip.(Array(sparse_vec)))
    end

    return (forces * s.force_unit) ./ mass.(s.atoms)
end

include("interactions/lennard_jones.jl")
include("interactions/soft_sphere.jl")
include("interactions/mie.jl")
include("interactions/coulomb.jl")
include("interactions/gravity.jl")
include("interactions/harmonic_bond.jl")
include("interactions/harmonic_angle.jl")
include("interactions/torsion.jl")
