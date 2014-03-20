#!/usr/bin/python
from Edge import Edge
from GreedyEdgeSelection import GreedyEdgeSelection
from GreedyTreeGrowing import GreedyTreeGrowing

def loadGraphFrom(filename):
    f = open(filename, 'r')
    V = int(f.readline())
    print V

    ELines = f.readlines()
    E = []
    for el in ELines:
        e = Edge(el)
        print e.i, e.j, e.weight
        E.append(e)

    f.close()
    return V, E

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Tree Partition")
    parser.add_argument('algo', metavar='algo', type=str, help='GreedyTree/GreedyEdge')
    parser.add_argument('graphFileName', metavar='graphFile', type=str, help='Graph File Name')
    args = parser.parse_args()
    V, E = loadGraphFrom(args.graphFileName)

    print args.algo
    if args.algo == "GreedyTree":
        partition = GreedyTreeGrowing(V, E)
    else:
        if args.algo == "GreedyEdge":
            partition = GreedyEdgeSelection(V, E)
        else:
             print "ERROR!"

    print partition

if __name__ == "__main__":
    main()
