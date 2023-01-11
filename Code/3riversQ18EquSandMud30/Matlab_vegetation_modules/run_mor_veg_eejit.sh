#!/bin/bash
#SBATCH --job-name=FL1.5_3Q18mud10
#SBATCH --ntasks=5
#SBATCH --nodes=1
#SBATCH --time=10-00:00:00
#SBATCH -o job_Matlab.out #STDOUT
#SBATCH -e job_Matlab.err #STDERR

# load all required modules
module purge
module load userspace/all userspace/custom opt/all
module load intel-compiler/64/2018.0.128
module load intel-runtime/64/2018.0.128
module load matlab/R2019a

matlab -nodisplay -nosplash -nodesktop -r "run('general_input.m');exit;"
