# -----------------------------------------------------------------------------------------------------
# This is the MAIN file for solving MWCS or PCST through Heinz (later than 2012 versions) code. 
# -----------------------------------------------------------------------------------------------------

# Importing essential packages
import sys
import os

# DEFINING SUBROUTINES 
def refineHeinzOutput (strFile):
	fid = open('tempFile.txt', 'rw')
	fidFin = open(strFile + '_outputGraph.txt', 'w')

	str = fid.readlines(); 
	
	startLabelLine = 6; 
	k = startLabelLine;  # Labelling starts at 6th line in the Heinz output file 
	while str[k][1:21] != 'label="Total weight:':
		k =  k + 1;      

	c = k + 1; 
	while str[c][0] != '}':
		# Get the node connections in the original output file 
		nodes = str[c].split('--');
		startNode = nodes[0][1:len(nodes[0])];  
		endNode = nodes[1][1:len(nodes[1])-1];  

		# Get the labels from the lines above 
		for i in range (startLabelLine,k):
			nodeLabel = str[i].split(' ');  
			nodeNumber = nodeLabel[0][1:len(nodeLabel[0])]; 	
			temp = nodeLabel[1].split('\\');
			nodeNumberOrig = temp[0][8:len(temp[0])]; 

			if (int(nodeNumber) == int(startNode)):
				originalLabelStart = nodeNumberOrig; 

			if (int(nodeNumber) == int(endNode)):
				originalLabelEnd = nodeNumberOrig; 
		
		fidFin.write(originalLabelStart + ' -- ' + originalLabelEnd + '\n'); 
		c = c + 1; 
	
	# Just write the total weight of the optial subgraph at the end of the file 
	forWeights = str[k].split('"'); 
	fidFin.write(forWeights[1][14:len(forWeights[1])]);
	fid.close(); 
	fidFin.close(); 
	os.remove('tempFile.txt'); 


# ----------------------------------------------------------------------------------------------------
# Set the config variable for solving PCST (=1) or MWCS (=0)
configVar = 0; # By default, we run MWCS

if (sys.argv[1] == '-ptype'):
	if (sys.argv[2] == '1'):
		configVar = 1; 
	if (sys.argv[2] == '0'):
		configVar = 0; 

# Display the selected ConfigVar 
if (configVar == 0):  # MWCS
	print ('------------- Running Heinz for solving MWCS Problem ------------ '); 
if (configVar == 1): # PCST
	print ('------------- Running Heinz for solving PCST Problem ------------ ');  

# ----------------------------------------------------------------------------------------------------
# Run the Heinz code for the MWCS problem, and store the output in a text file (with proper node names) 
# Can incorporate Error Checks in the following 
if (configVar == 0): 
	os.system('./heinz-mc' + ' ' + sys.argv[3] + ' ' + sys.argv[4] + ' ' + sys.argv[5] + ' ' + sys.argv[6] + '>> tempFile.txt');
	refineHeinzOutput (sys.argv[4]); 
	 

if (configVar == 1):
	# Parse the graph connections file (containing the node connections and the edge weights)
	# Add extra node connections to this file, and extra node weights to the node weights file 
	# Intermediate files are temporary files that are later deleted 
	f = open(sys.argv[4], 'rw');
	g = open(sys.argv[6], 'rw');
	fid_1 = open('graph_connections_temp.txt', 'w');
	fid_2 = open('graph_node_weights_temp.txt', 'w');
	
	# Get the number of nodes
	str_g = g.readlines(); 

	# Copy the original node file to the temp node file
	for i in range(0,len(str_g)):
		fid_2.write(str_g[i]); 
	
	# Read the graph connections file 
	str_f = f.readlines();
	for i in range (0,len(str_f)):
		splitStr = str_f[i].split(' ');
		edgeWeight =  splitStr[2][0:len(splitStr[2])-1];

		# Write the new graph connections
		newNodeNumber = str(len(str_g) + 2 + i); # Assuming that the original nodes are in order. 
		fid_1.write(splitStr[0] + ' ' + newNodeNumber + '('+  newNodeNumber + ')\n'); 	
		fid_1.write(newNodeNumber + '('+  newNodeNumber + ')'+ ' ' + splitStr[1] + '\n'); 	
	 
		# Write the new node weight file 
		fid_2.write(newNodeNumber + '('+  newNodeNumber + ')' + ' ' + '-' + edgeWeight + '\n'); 
	
	
	f.close();
	g.close(); 
	fid_1.close();
	fid_2.close();

	# Run Heinz 
	os.system('./heinz-mc' + ' ' + sys.argv[3] + ' ' + 'graph_connections_temp.txt' + ' ' + sys.argv[5] + ' ' + 'graph_node_weights_temp.txt' + '>> tempFile.txt');
	refineHeinzOutput ('graph_connections_temp.txt');
	
	# Reomve Temp files 
	os.remove('graph_connections_temp.txt'); 
	os.remove('graph_node_weights_temp.txt'); 

	# Parse the Heinz Output File to put the output in original node terms
	newNodesStartNumber = len(str_g) + 2; 
	f = open('graph_connections_temp.txt' + '_outputGraph.txt', 'r') 
	fid = open(sys.argv[4] + '_outputGraph.txt', 'w')
	
	# Get the final weight 
	str_f = f.readlines()
	weightOfOptimalSubgraph = str_f[len(str_f)-1]; 
	
	for i in range(0,len(str_f)-1,2): 

		nodes = str_f[i].split('--'); 
		startNode = nodes[0][0:len(nodes[0])]; 
		startNodeSplit = startNode.split('('); 
		endNode = nodes[1][1:len(nodes[1])-1];
		endNodeSplit = endNode.split('(');  
  
		if (int(startNodeSplit[0]) >= newNodesStartNumber):
			node_1 = int(endNodeSplit[0]);  
		if (int(endNodeSplit[0]) >= newNodesStartNumber):
			node_1 = int(startNodeSplit[0]); 

		# Parse the next line - The edge will be present in consecutive lines 
		nodes = str_f[i+1].split('--'); 
		startNode = nodes[0][0:len(nodes[0])]; 
		startNodeSplit = startNode.split('('); 
		endNode = nodes[1][1:len(nodes[1])-1];
		endNodeSplit = endNode.split('(');  
  
		if (int(startNodeSplit[0]) >= newNodesStartNumber):
			node_2 = int(endNodeSplit[0]);  
		if (int(endNodeSplit[0]) >= newNodesStartNumber):
			node_2 = int(startNodeSplit[0]); 

		# Write the optimal subgraph connection in the final file 
		fid.write(str(node_1) + '(' + str(node_1) + ')' + ' -- ' + str(node_2) +  '(' + str(node_2) + ')\n'); 


	# Write the final weight 
	fid.write(weightOfOptimalSubgraph); 
	fid.close();  
	f.close(); 

	# Remove the temp Heinz Generated file 
	os.remove('graph_connections_temp.txt' + '_outputGraph.txt');



	 
	


