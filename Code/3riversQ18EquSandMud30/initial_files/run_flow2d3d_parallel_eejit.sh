#!/bin/bash
#SBATCH --job-name=FL1.5mOff100m
#SBATCH --ntasks=4
#SBATCH --time=10-00:00:00
#SBATCH -o job_D3D.out #STDOUT
#SBATCH -e job_D3D.err #STDERR

set NHOSTS manually here:
export NHOSTS=4
NPART=$NHOSTS

    # Running D3D at Eejit

    # load all required modules
    module purge
    module load userspace/all userspace/custom
    module load intel-compiler/64/2018.0.128
    module load intel-runtime/64/2018.0.128
#    module load intel-mkl/64/2018.0.128
#    module load intel-mpi/64/2018.0.128
#    module load cmake/3.11.2


    #
    # This script starts a single-domain Delft3D-FLOW computation on Linux in parallel mode
    # asuming nodes are allocated manually
    # Specify the config file to be used here
    # 
argfile=config_flow2d3d.xml

    #
    # Set the directory containing delftflow.exe here
    #
export ARCH=lnx64
export D3D_HOME=/scratch/depfg/dangh001/Delft3d_tag7545_20210512
exedir=$D3D_HOME/$ARCH/flow2d3d/bin
 
    #
    # No adaptions needed below
    #

    # Set some (environment) parameters
export LD_LIBRARY_PATH=$exedir:$LD_LIBRARY_PATH 


    ### General, start delftflow in parallel by means of mpirun.
    ### The machines in the h4 cluster are dual core; start 2*NHOSTS parallel processes

#mpirun -np 4 $NHOSTS $exedir/d_hydro.exe $argfile
mpiexec -n $NHOSTS $exedir/d_hydro.exe $argfile

rm -f log*.irlog

    ### General for MPICH2, finish your MPICH2 communication network.
#mpdallexit 

