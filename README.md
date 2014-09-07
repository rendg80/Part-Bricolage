Part-Bricolage - Flow-assisted Part-based Graphs for Detecting Activities in Videos
====================================================================================

In the spirit of reproducible research, this package is intended to contain the complete code, datasets and all intermediate results' files for the ECCV 2014 paper entitled 'Part Bricolage:  Flow-assited Part-based Graphs for Detecting Activities in Videos'. In case, you use this code, please use the following bibTeX entry for citation / reference - 

@incollection{shankar2014part,
  title={Part Bricolage: Flow-Assisted Part-Based Graphs for Detecting Activities in Videos},
  author={Shankar, Sukrit and Badrinarayanan, Vijay and Cipolla, Roberto},
  booktitle={Computer Vision--ECCV 2014},
  pages={586--601},
  year={2014},
  publisher={Springer}
}

The entire code is released under the GPL License. Please view the LICENSE.md file for the same. 

=================================================================================================
The release contains the following:

(1) Files for part estimation using Poselets and FMP (Flexible Mixture of Parts) - For the full model, you will require to use both of them. Thus, following citations should be added:

@inproceedings{bourdev2009poselets,
title={Poselets: Body part detectors trained using 3d human pose annotations},
author={Bourdev, Lubomir and Malik, Jitendra},
booktitle={Computer Vision, 2009 IEEE 12th International Conference on},
pages={1365--1372},
year={2009},
organization={IEEE}
}

@inproceedings{yang2011articulated,
title={Articulated pose estimation with flexible mixtures-of-parts},
author={Yang, Yi and Ramanan, Deva},
booktitle={Computer Vision and Pattern Recognition (CVPR), 2011 IEEE Conference on},
pages={1385--1392},
year={2011},
organization={IEEE}
}

Note that the poselets code has been modified to make the threshold adaptive. This generally detects a far more number of torsos with an acceptable false positive rate. False positives are resolved during our ambiguity resolving process.

(2) Estimation of optical and streak flow - The code package can run both the optical and streak flow on the videos. Files for visualization of the same are also present. For our purpose, we have not made the use of streak flow. However, in case you make use of it, please add the following citation:

@incollection{mehran2010streakline,
title={A streakline representation of flow in crowded scenes},
author={Mehran, Ramin and Moore, Brian E and Shah, Mubarak},
booktitle={Computer Vision--ECCV 2010},
pages={439--452},
year={2010},
publisher={Springer}
}

(3) Dataset of Images (dataset_learning_classifiers) used to learn classifiers for FMP, the annotations generated for this dataset for FMP (FMP_annotations.mat), and the learned SVM Model (trained_FMP_model). For learning this model and checking on the accuracy of this model, please run learnSVMForPartAnnotations.m. In case you use these FMP related things, please add the following LIBSVM citation:

@article{chang2011libsvm,
title={LIBSVM: a library for support vector machines},
author={Chang, Chih-Chung and Lin, Chih-Jen},
journal={ACM Transactions on Intelligent Systems and Technology (TIST)},
volume={2},
number={3},
pages={27},
year={2011},
publisher={ACM}
}

(4) Files for combining multiple part detections (from Poselets and FMPs) and resolving ambiguities to minimize the false positives. The configuration variables serving various permutations regarding the same, and visualization routines are also available.

(5) Package for the graph optimization utility (heinz_pcst). This is the code package for Linux. The code can solve both the Max-Weighted-Connected-Subgraph (MWCS) problem as well as the Prize-Collecting-Steiner-Tree (PCST) problem. The modes for specifying the inputs and the format in which one gets the output can clearly be understood by going through the README file within the package. In case, you use this code, please add the following citation:

@article{dittrich2008identifying,
title={Identifying functional modules in protein--protein interaction networks: an integrated exact approach},
author={Dittrich, Marcus T and Klau, Gunnar W and Rosenwald, Andreas and Dandekar, Thomas and M{\"u}ller, Tobias},
journal={Bioinformatics},
volume={24},
number={13},
pages={i223--i231},
year={2008},
publisher={Oxford Univ Press}
}

(6) Files for Tracking of Ambiguity Resolved Parts using the flow information. Visualization of the tracked parts can also be done. The file for computing Histogram of Oriented Gradients is also available. All these files make the computation of final descriptors fairly straightforward.

=================================================================================================
RUNNING THE CODE

(a) The code is for MATLAB. We used the 2014a version to run it. 
(b) Standard compiler dependencies are there for running the FMP Code. 
(c) The graph optimization package is to be run on Linux. 
(d) The main.m file should give a clear indication of the code flow. 
(e) The paths to the datasets and the other relative paths should also be clear from main.m. 
(f) One might get errors owing to the getFiles function dependent on the platform one is running on. There are subtle differences for Mac, Windows and Linux. Please make changes in the first line of the file accordingly.

=================================================================================================
THINGS BEING WORKED ON 


(A) MORE CONFIGURATION VARIABLES - The code currently runs both the optical flow and streak flow for the videos. The future releases shall contain a configuration variable which can help to decide whether to do only optical flow, only streak flow, or both.

(B) MORE CONFIGURATION VARIABLES - The code currently always runs in the mode where the threshold for poselets is adaptive. The future releases shall contain a global configuration variable which will enable to run poselets in a non-adaptive mode as well.

(C) COMPLETE PIPELINE WITH ADDITIONAL CONFIGURATION VARIABLES - The code currently does not contain all files for generating final descriptors once the flow information has been computed and the human body part estimations have been resolved and tracked. The reason is that there happen to be a lot of permutations and combinations associated with the same. We are working on adding some configuration variables appropriately, using which one can generate all sorts of descriptor variants.

(D) COMPLETE PIPELINE WITH ADDITIONAL CONFIGURATION VARIABLES - The code currently does not contain all files for forming a graph out of descriptors. There again need to be some configuration variables which can cater to the the different graphical connections and node- and edge-weighting. We are working on the same and all this will be available in future releases.

(E) DATASETS AND INTERMEDIATE RESUTLS - The associated datasets (MSR Action Dataset, Hollywood Dataset, KTH dataset (used to train for MSR Action Dataset)) are standard activity recognition datasets, and can be downloaded from the web by Googling. The future releases shall contain the folders for all videos in all of these datasets, which shall contain video frames, and all sorts of possible intermediate results along with their visualizations (wherever possible).

(F) MORE ROBUSTNESS - The Part Tracking Code currently in place is not very robust. We are working to make it more robust, which should then hopefully yield even better results. An enhanced version of the tracking code will be available in future releases.

========================================================================================================================
The release contains the critical portions of the code as outlined in points (1-6). The missing pieces as mentioned in (A-F) are fairly straightforward to reproduce from the paper, and can be coded easily. We shall however, make these missing pieces available as soon as possible with future releases.
 
========================================================================================================================
In case of any queries, please feel free to email ss965@cam.ac.uk or sukritshankar@gmail.com.  We shall strive our best to make the software amenable and useful for your cause. 



