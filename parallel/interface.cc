#include <mpi.h>
#include <iostream>
#include <sstream>
#include <cstdlib>

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

    std::cout << command.str() << std::endl;
    std::system(command.str().c_str());

    MPI_Finalize();

    return 0;
}
