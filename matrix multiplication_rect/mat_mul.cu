#include <stdio.h>




/* A,B input arrays and C is the output and they all have the same size*/
__global__ void matrix_multiplication(int* A,int* B, int* C,
									  int Arow, int Acol,
									  int Brow, int Bcol)
{
	// get the flattened index
	int row = blockIdx.x * blockDim.x+ threadIdx.x;
	int col = blockIdx.y * blockDim.y+ threadIdx.y;
	// dimension mismatch!
	if (Acol != Brow)
		return;

	int val = 0;
	// boundry check for dimensions
 	if (row < Arow && col < Bcol)
	{
		for (int k = 0; k <Acol ; k++)
		{
			// this is the tricky part...
			// you probably need a pen a paper to get it right
			// fix row of the A and fix the col of B (Hint)
			// A[row*N + k]  --> fix row then travese its elements
			// B[col + k * N]--> fix column and traverse its elements
			val += A[row*Arow + k] * B[col + k * Bcol];
			C[row*Arow +col] += val;
			if (row==0 && col ==1)
			{
				printf("\n");
				printf("A[row*Arow + k]   = A[%i * %i + %i] = %i\n",row,Arow,k, A[row*Arow + k]);
				printf("B[col + k * Bcol] = B[%i + %i * %i] = %i\n",col,k,Bcol, B[col + k * Bcol]);
				printf("\n");
				// printf("C[row*Arow +col]  = C[%i * %i + %i] = %i\n",row,Arow,col, C[row*Arow +col]);
			}
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
	// int N = (1<<2);
	int Arow = 4;
	int Acol = 3;
	int Brow = 3;
	int Bcol = 2;
	cudaError_t syncE, asyncE;
	// create a pointer and allocate memory for it
	printf("starting things\n");
	int * arrA,*arrB, *arrC;
	// for a 2D array size will be N * N * size of int
	int sizeA = Arow * Acol * sizeof(int);
	int sizeB = Brow * Bcol * sizeof(int);
	int sizeC = Arow * Bcol * sizeof(int);
	cudaMallocManaged(&arrA, sizeA);
	cudaMallocManaged(&arrB, sizeB);
	cudaMallocManaged(&arrC, sizeC);
	// initialization A
	for(int row = 0; row < Arow; row++)
	{
		for(int col = 0; col < Acol; col++)
		{
			arrA[row*Arow+col]=row;
		}
	}
	// initialization B
	for(int row = 0; row < Brow; row++)
	{
		for(int col = 0; col < Bcol; col++)
		{
			arrB[row*Bcol+col]=1;
		}
	}
	printf("sizeA=%i, sizeB=%i, sizeC=%i\n",sizeA,sizeB,sizeC);
	// define the dimention struct
	dim3 threads_per_block (8,8,1);
	dim3 no_block (8,8,1);
	//  run the cuda kernel;
	matrix_multiplication<<<no_block,threads_per_block>>>(arrA,arrB,arrC,Arow,Acol,Brow,Bcol);// setting lower threads and blocks than actual data
	syncE = cudaGetLastError();
	asyncE = cudaDeviceSynchronize();
	printf("%s",syncE != cudaSuccess? "synchronous Error occured\n":"Great!...No synchronous Error\n");
	printf("%s",asyncE != cudaSuccess? "asynchronous Error occured\n":"Great!...No asynchronous Error\n");

	print_matrix(arrA,Arow,Acol);
	print_matrix(arrB,Brow,Bcol);
	print_matrix(arrC,Arow,Bcol);
	// free allocated memory
	cudaFree(arrA);
	cudaFree(arrB);
	cudaFree(arrC);
}
