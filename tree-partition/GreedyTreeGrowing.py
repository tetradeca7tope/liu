#!/usr/bin/python

import Queue


def getNeighbors(V, E):

    #Initialize
    N=[]
    W=[]
    for i in range(V+1):
        N.append([])
        W.append([])

    #Bug Fix
    #The following don't work
    #Would be V+1 pointers pointing to the same list :(
    #N = [[]] * (V+1)
    #W = [[]] * (V+1)
    for e in E:
        #print "e", e
        N[e.i].append(e.j)
        W[e.i].append(e.weight)

        N[e.j].append(e.i)
        W[e.j].append(e.weight)
        #print "N", N
        #print "W", W

    #print "N[2]", N[2]
    #print "W[2]", W[2]
    #print "Done generating neighbors"
    return N, W

def GreedyTreeGrowing(V, E, maxVperTree = -1):
    N, W = getNeighbors(V, E) # N[v] is a list of all v's neighbors TODO

    V = range(1, V+1) # 1, 2, ... V

    i = 0
    T = []
    while len(V) > 0:
        #print "New Tree"
        v = V[0]
        Ti = []
        maxQueueSize = V
        Q = Queue.PriorityQueue(maxQueueSize)
        Q.put((0, v)) #The priority here doen't matter
        while Q.qsize() > 0: #? Can we use qsize() here? Said to be unreliable? 
            u = Q.get()[1]
            #print "Trying vertex #", u
            
            neighborsInT = set(N[u]) & set(Ti)
            #print "neighborsInT", neighborsInT
            if len(neighborsInT) <= 1:
                #Add u to the tree Ti
                Ti.append(u)
                #Remove u from V
                V.remove(u)
                #Do we need to remove u form E and N???

                if (maxVperTree > 0) and (len(Ti) >= maxVperTree):
                    break; #End of this tree
                
                #Prepare for next round
                for i in range(len(N[u])):
                    k = N[u][i]
                    if k in V:
                        w = W[u][i] #Weight(u, k)
                        Q.put((-w, k)) 
                        #Minus sign: make the largest weight comes out first 
            #print "Q.qsize()", Q.qsize()    
        T.append(Ti)
        #print T
    return T
