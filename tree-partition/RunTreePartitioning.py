#!/usr/bin/python
from Edge import Edge
from GreedyEdgeSelection import GreedyEdgeSelection
from GreedyTreeGrowing import GreedyTreeGrowing

def loadGraphFrom(filename):
    f = open(filename, 'r')
    V = int(f.readline())
    #print V

    ELines = f.readlines()
    E = []
    for el in ELines:
        e = Edge(el)
        #print e.i, e.j, e.weight
        E.append(e)

    f.close()
    return V, E

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Tree Partition")
    parser.add_argument('algo', metavar='algo', type=str, help='GreedyTree/GreedyEdge')
    parser.add_argument('graphFileName', metavar='graphFile', type=str, help='Graph File Name')
    parser.add_argument('maxTreeSize', metavar='maxTreeSize', type=int, help='The max size of trees. Set to -1 if you do not want to control this.')
    parser.add_argument('--outputcolor', dest='outColor', action='store_true')
    args = parser.parse_args()
    V, E = loadGraphFrom(args.graphFileName)

    #print args.algo
    if args.algo == "GreedyTree":
        partition = GreedyTreeGrowing(V, E, args.maxTreeSize)
    else:
        if args.algo == "GreedyEdge":
            partition = GreedyEdgeSelection(V, E, args.maxTreeSize)
        else:
            print "ERROR! Unknown algorithm"
            return

    partition = sorted(partition, key=len, reverse=True)
    if args.outColor:
        treeid = 0
        color = [0] * V
        for tree in partition:
            treeid += 1
            for vertex in tree:
                color[vertex-1] = treeid
        print color 
    else:
        maxlen = len(partition[0])
        for tree in partition:
            tree.sort() 
            print tree + [0] * (maxlen - len(tree))
    #print partition

if __name__ == "__main__":
    main()
