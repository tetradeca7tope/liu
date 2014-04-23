#!/usr/bin/python
from random import random
import math

def PrintEdgeWithRandomWeight(f, node_i, node_j, V):
    #Fault Tolerent
    if node_i > V:
        return
    if node_j > V:
        return
    weight = random()
    f.write( str(node_i) + ' ' + str(node_j) + ' ' + str(weight) + '\n')
    #f.write( str(node_i) + ' ' + str(node_j) + '\n')

def GenerateGraph_Grid(N, fileID):
    print "Generating a grid graph %d * %d..." % (N, N)
    # Generate a N * N Grid
    # Nodes are numbered with
    # 1, 2, ... N
    # N+1, ... 2N
    # ...
    # N(k-1)+1, ... N*k
    # ...
    # N(N-1)+1, ... N*N

    f=open('DATA/' + str(N)  + '/grid_' + str(N) + '_' + str(fileID) + '.in','w')
    V = N*N
    f.write(str(V) + '\n')
    # Generate edge = (i, j, w)
    # Only consider i < j
    for row in range(1, N+1):
        for column in range(1, N):
            # 2 edges per starting node
            node_i = N*(row-1) + column
            node_j = node_i+1
            PrintEdgeWithRandomWeight(f, node_i, node_j, V)
            node_j = node_i+N
            PrintEdgeWithRandomWeight(f, node_i, node_j, V)

        # last edge in this row
        # N*k to N*(k+1)
        column = N
        node_i = N*(row-1) + column
        node_j = node_i+N
        PrintEdgeWithRandomWeight(f, node_i, node_j, V)
    
    
    f.close()        
    print "[Done] Generated a grid graph."

def main():
    for i in range(2,12):
        N = 64; fileID = i
        #N = pow(2,i); fileID = 0
        
        GenerateGraph_Grid(N, fileID)

if __name__ == "__main__":
    main()
