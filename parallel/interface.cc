#include <mpi.h>
#include <iostream>
#include <sstream>
#include <cstdlib>
#include <cassert>

int main(int argc, char **argv)
{
    MPI_Init(NULL, NULL);

    int numProcs;
    MPI_Comm_size(MPI_COMM_WORLD, &numProcs);

    int pid;
    MPI_Comm_rank(MPI_COMM_WORLD, &pid);

    std::string threads = "1";
    if (argc == 2)
        threads = argv[1];

    std::stringstream command;
    command << "./" << argv[1] << " " <<  pid << " " << numProcs;

    MPI_Barrier(MPI_COMM_WORLD);
    std::cout << command.str() << std::endl;
    std::system(command.str().c_str());

    MPI_Barrier(MPI_COMM_WORLD);
    std::cout << command.str() << " (done)" << std::endl;
    MPI_Finalize();

    return 0;
}
