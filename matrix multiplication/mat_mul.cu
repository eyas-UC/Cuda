#include <stdio.h>




/* A,B input arrays and C is the output and they all have the same size*/
__global__ void matrix_multiplication(int* A,int* B, int* C, int N)
{
	// get the flattened index
	int val = 0;
	int row = blockIdx.x * blockDim.x+ threadIdx.x;
	int col = blockIdx.y * blockDim.y+ threadIdx.y;

	// boundry check for dimensions
 	if (row < N && col < N)
	{
		for (int k = 0; k <N ; k++)
		{
			// this is the tricky part...
			// you probably need a pen a paper to get it right
			// fix row of the A and fix the col of B (Hint)
			// A[row*N + k]  --> fix row then travese its elements
			// B[col + k * N]--> fix column and traverse its elements
			C[row*N +col] += A[row*N + k] * B[col + k * N];
		}
	}
}

void print_matrix(int * A, int row, int col)
{
	for(int i =0; i <(row*3+2);i++)
		printf("-");
	printf("\n");
	for(int i =0; i< row; i++)
	{
		printf("|");
		for(int j =0; j<col; j++)
		{
			printf(" %i ",A[i*row+j]);
		}
		printf("|\n");
	}
	for(int i =0; i <(row*3+2);i++)
		printf("-");
	printf("\n");

}
int main()
{
	int N = (1<<3) +1;
	cudaError_t syncE, asyncE;
	// create a pointer and allocate memory for it
	printf("starting things\n");
	int * arrA,*arrB, *arrC;
	// for a 2D array size will be N * N * size of int
	size_t size = N * N * sizeof(int);
	cudaMallocManaged(&arrA, size);
	cudaMallocManaged(&arrB, size);
	cudaMallocManaged(&arrC, size);
	// initialization
	for(int row = 0; row < N; row++)
	{
		for(int col = 0; col < N; col++)
		{
			arrA[row*N+col]=row;
			arrB[row*N+col]=row;
			arrC[row*N+col]= 0;
		}
	}
	printf("N=%i and size=%i\n",(int)N,(int)size);
	// define the dimention struct
	dim3 threads_per_block (8,8,1);
	dim3 no_block (8,8,1);
	//  run the cuda kernel;
	matrix_multiplication<<<no_block,threads_per_block>>>(arrA,arrB,arrC,N);// setting lower threads and blocks than actual data
	syncE = cudaGetLastError();
	asyncE = cudaDeviceSynchronize();
	printf("%s",syncE != cudaSuccess? "synchronous Error occured\n":"Great!...No synchronous Error\n");
	printf("%s",asyncE != cudaSuccess? "asynchronous Error occured\n":"Great!...No asynchronous Error\n");

	print_matrix(arrA,N,N);
	print_matrix(arrB,N,N);
	print_matrix(arrC,N,N);
	// free allocated memory
	cudaFree(arrA);
	cudaFree(arrB);
	cudaFree(arrC);
}
