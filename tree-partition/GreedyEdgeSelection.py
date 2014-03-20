#!/usr/bin/python

def getOtherNeighborColors(fromNodes, excludeEdge, allEdges, colors):

    #TODO Use a not so brutal algo

    from sets import Set
    neighborColors = Set([])
    for e in allEdges:
        if (e.i in fromNodes) and (not e.j in fromNodes):
            if e != excludeEdge:
                neighborColors.add(colors[e.j])
                #print "#neighbor-%d, color-%d" % (e.j, colors[e.j])
        if (e.j in fromNodes) and (not e.i in fromNodes):
            if e != excludeEdge:
                neighborColors.add(colors[e.i])
                #print "#neighbor-%d, color-%d" % (e.i, colors[e.i])
    #print "fromNodes", fromNodes
    #print "excludeEdge", excludeEdge
    #print "neighborColors", neighborColors
    return neighborColors

def GreedyEdgeSelection(V, E):
    colors = [-1] * (V+1)
    #Sort Edges by weight
    print "Sorting" 
    import operator
    E.sort(key=operator.attrgetter('weight'), reverse=True)
    print E

    #Initialize
    unusedColor = 0
    T = [] #indexed by color

    #Select
    for e in E:
        print "Current colors", colors
        print "Current trees", T
        print "*" * 10
        print "Trying to add", e
        Vi = colors[e.i]
        Vj = colors[e.j]
        if (Vi == -1) and (Vj == -1):
            colors[e.i] = unusedColor
            colors[e.j] = unusedColor
            T.append([e.i, e.j])
            print "Added", e
            unusedColor += 1
            continue
        if (Vi == -1): 
            if not Vj in getOtherNeighborColors([e.i], e, E, colors):
                colors[e.i] = Vj
                T[Vj].append(e.i)
                print "Added", e
            continue
        if (Vj == -1):
            if (not Vi in getOtherNeighborColors([e.j], e, E, colors)):
                colors[e.j] = Vi
                T[Vi].append(e.j)
                print "Added", e
            continue
        #Now neither Vi nor Vj is 0
        #They must not be the same, or we have screwed up
        if Vi == Vj:
            print "Error!"
            print e.i, Vi
            print e.j, Vj
            import sys
            sys.exit()

        if not Vi in getOtherNeighborColors(T[Vj], e, E, colors):
            for k in T[Vj]:
                colors[k] = Vi
            T[Vi].extend(T[Vj])
            T[Vj] = []         
            print "Added", e

    #TODO

    return T

class Edge:
    def __init__(self, edgeline):
        args = edgeline.split(' ')
        #self.nodes = [int(args[0]), int(args[1])]
        self.i = int(args[0])
        self.j = int(args[1])
        self.weight = float(args[2])
    
    def __str__(self):
        #return "(%d, %d) %f", self.i, self.j, self.weight
        return "({0}, {1}) {2}".format(self.i, self.j, self.weight)

    def __repr__(self):
        return str(self)
'''
    def __eq__(self, other):
        print "Compare!"
        if self.i != other.i:
            return False
        if self.j != other.j:
            return False
        #if self.weight != other.weight:
        #    return false
        print "!!Equal", self, other
        return True
'''

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
    parser = argparse.ArgumentParser(description="Greedy Edge Selection")
    parser.add_argument('graphFileName', metavar='graphFile', type=str, help='Graph File Name')
    args = parser.parse_args()
    V, E = loadGraphFrom(args.graphFileName)

    partition = GreedyEdgeSelection(V, E)

    print partition

if __name__ == "__main__":
    main()
