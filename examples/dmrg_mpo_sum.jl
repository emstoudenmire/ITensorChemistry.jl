using ITensors
using ITensorChemistry

molecule = "methane"
basis = "sto-3g"

@show molecule
@show basis

println("\nRunning Hartree-Fock")
(; hamiltonian, state, hartree_fock_energy) = @time molecular_orbital_hamiltonian(; molecule, basis, nsub_hamiltonians=2)
println("Hartree-Fock complete")

println("Basis set size = ", length(state))

s = siteinds("Electron", length(state); conserve_qns=true)

println("\nConstruct MPO")

H = @time [MPO(h, s) for h in hamiltonian]
println("MPO constructed")

@show maxlinkdim.(H)

ψhf = MPS(s, state)

@show sum(h -> inner(ψhf, h, ψhf), H)
@show hartree_fock_energy

sweeps = Sweeps(10)
setmaxdim!(sweeps, 100, 200)
setcutoff!(sweeps, 1e-6)
setnoise!(sweeps, 1e-6, 1e-7, 1e-8, 0.0)

println("\nRunning DMRG")
@show sweeps

e, ψ = dmrg(H, ψhf, sweeps)
println("DMRG complete")