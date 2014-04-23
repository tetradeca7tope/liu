#!/usr/bin/python
from GreedyEdgeSelection import GreedyEdgeSelection
from GreedyTreeGrowing import GreedyTreeGrowing
from RunTreePartitioning import loadGraphFrom
import math
from datetime import datetime
def getStatistics(partition):
    totalTrees = 0
    treeSizes = []
    for tree in partition:
        tree.sort()
        if tree:
            totalTrees += 1
            treeSizes.append(len(tree))
        #print tree
    treeSizes.sort()
    print "totalTrees", totalTrees
    #print "treeSizes", treeSizes
    medianTreeSize = treeSizes[totalTrees / 2]

    return totalTrees, medianTreeSize

def testGrid(datadir, outputFileName):

    outputFileName = datadir + '/' + outputFileName

    f = open(outputFileName, 'w')
    f.write("inFileName totalTrees_TreeGrowing medianTreeSize_TreeGrowing totalTrees_EdgeSelection medianTreeSize_EdgeSelection\n")
    f.close()

    import glob
    import os
    #os.chdir(datadir)

#    for i in range(2, 12):
    for inFileName in glob.glob(datadir + "/*.in"): 
        #inFileName = datadir + '/grid_' + str(pow(2,i)) + '.in'
        print 'Processing', inFileName

        V, E = loadGraphFrom(inFileName)
        print 'Done reading'

        starttime = datetime.now()
        print "[%s] Greedy Tree Growing..." % str(starttime.time())
        partition = GreedyTreeGrowing(V, E)
        endtime = datetime.now()
        print "[%s] Done Greedy Tree Growing" % (endtime - starttime)
        #print partition
        totalTrees_TreeGrowing, medianTreeSize_TreeGrowing = getStatistics(partition)

        starttime = datetime.now()
        print "[%s] Greedy Edge Selection..." % str(starttime.time())
        partition = GreedyEdgeSelection(V, E)
        endtime = datetime.now()
        print "[%s] Done Greedy Edge Selection" % (endtime - starttime)
        #print partition
        totalTrees_EdgeSelection, medianTreeSize_EdgeSelection = getStatistics(partition)

        f = open(outputFileName, 'a')
        f.write(inFileName + ' ' + str(totalTrees_TreeGrowing) + ' ' + str(medianTreeSize_TreeGrowing) +  ' ' + str(totalTrees_EdgeSelection) + ' ' + str(medianTreeSize_EdgeSelection) + '\n')
        f.close()

if __name__ == "__main__":
    print "Hello World"
    import argparse
    parser = argparse.ArgumentParser(description="Tree Partition Experiments") 
    parser.add_argument('datadir', metavar='datadir', type=str, help='The directory for the input and output data') 

    args = parser.parse_args()
    testGrid(args.datadir, 'grid_test.out')
