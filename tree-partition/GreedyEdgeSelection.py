#!/usr/bin/python
from Edge import Edge
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

def GreedyEdgeSelection(V, E, maxVperTree = -1): #TODO abort after maxVperTree

    colors = [-1] * (V+1)
    #Sort Edges by weight
    #print "Sorting" 
    import operator
    E.sort(key=operator.attrgetter('weight'), reverse=True)
    #print E

    #Initialize
    unusedColor = 0
    T = [] #indexed by color

    #Select
    for e in E:
        #print "Current colors", colors
        #print "Current trees", T
        #print "*" * 10
        #print "Trying to add", e
        Vi = colors[e.i]
        Vj = colors[e.j]
        if (Vi == -1) and (Vj == -1):
            #Assum maxVperTree >= 2, Don't need to check tree size here
            colors[e.i] = unusedColor
            colors[e.j] = unusedColor
            T.append([e.i, e.j])
            #print "Added", e
            unusedColor += 1
            continue
        if (Vi == -1): 
            if not Vj in getOtherNeighborColors([e.i], e, E, colors):
                if (maxVperTree == -1) or (len(T[Vj]) < maxVperTree):
                    colors[e.i] = Vj
                    T[Vj].append(e.i)
                    #print "Added", e
            continue
        if (Vj == -1):
            if (not Vi in getOtherNeighborColors([e.j], e, E, colors)):
                if (maxVperTree == -1) or (len(T[Vi]) < maxVperTree):
                    colors[e.j] = Vi
                    T[Vi].append(e.j)
                    #print "Added", e
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
            if (maxVperTree == -1) or (len(T[Vi]) + len(T[Vj]) <= maxVperTree):
                for k in T[Vj]:
                    colors[k] = Vi
                T[Vi].extend(T[Vj])
                T[Vj] = []         
                #print "Added", e

    #Add disconnected nodes
    for i in range(1, V+1):
        if colors[i] == -1:
            T.append([i])

    return T
