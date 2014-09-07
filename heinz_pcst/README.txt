##########################################################################
One can solve the Max Weighted Connected Subgraph (MWCS) problem and the
Prize Collecting Steiner Tree (PCST) problem using this code package. 
##########################################################################

# EXAMPLE USAGE #
(For MWCS) >> python main.py -ptype 0 -e  graph_connections.txt -n graph_node_weights.txt
(For PCST) >> python main.py -ptype 1 -e  graph_connections_pcst.txt -n graph_node_weights_pcst.txt
# OUTPUT FILE - <name_of_connections_file_with_extension>_outputGraph.txt

(1) 	Run main.py to solve for MWCS or PCST problem.

(2) 	For solving the MWCS problem, the connections between nodes of the graph 
	and the node weights only need to be specified. There are no edge weights. 
	Specify node connections in a text file such as in 'graph_connections.txt'
	Specify node weights in a text file such as in 'graph_node_weights.txt'

(3) 	For solving the PCST problem, the connections between nodes of the graph 
	and the node weights need to be specified, along with the edge weights. 
	Specify node connections and edge weights such as in 'graph_connections_pcst.txt'
	Specify node weights in the same manner as with MWCS ('graph_node_weights_pcst.txt')

(4) 	The outputs of either the MWCS or the PCST is a graph showing the connections of the 
	nodes of the optimal subgraph. 

NOTE - PCST problem is solved by first converting the edge-weighted & node-weighted graph G to only a node-weighted graph Z, and solving the MWCS problem over Z. Z contains many auxiliary nodes over G. For an edge (u,v) of G with edge cost c, we create an auxiliary node w with weight -c, and two edges (u,w) and (w,v) in Z, with u and v retaining the same weights as in G. The output that we give finally for the PCST problem, only mentions the nodes of G, and not of Z.    

ACKNOWLEDGEMENTS - We thank Dr. Gunnar W. Klau and Mohammed El-Kebir of CWI (Centrum Wiskunde & Informatica) Life Sciences Group at Amsterdam, Netherlands for providing us the Heinz library, and for giving us the directions to solve the PCST problem using it.

