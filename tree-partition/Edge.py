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



