% Purpose: File reads MACOS optical prescriptions, creates a cell array
%          of structures which contains all elements in the prescription 
%          with their respective parameters as fields, and corresponding 
%          field values. We use a class definition script, labeled 
%          OptNodeDlList, to input the cell array and create a "doubly
%          linked list".
%
% Record:
%       Date                 Author                      Description
% =================     =======================      ====================
%  June 25th, 2008         Luis F. Marchen               Original Code
%
% Define Variables and Constants:
% OpticalData --cell array of structure containing optical data              
% num_Elt     --number of elements in read Rx includes Source and Tout
% vstr        --variable string to name each node as it is built and linked
% macos_fname --name of the MACOS prescription to be read

clear all
clc
%==========================================================================
% We read the Rx file created by converting Code V sequence file to MACOS; 
% otherwise, we choose the basic file to create the desired Rx file. After 
% reading file we build a cell array of structures containg all optics and 
% parameters in the variable OpticalData.
%==========================================================================
%macos_fname='most2prc_allseg_v3.in';
macos_fname='ISSTest_most3f1sprcdbl_v6.in';
[OpticalData,num_Elt,List_EltNames]=ReadRxFile(macos_fname);

%Create list of element names for macos_fname prescription
%New_EltNames=new_EltNames(OpticalData);
%==========================================================================
% Here we use OpticalData to create a doubly linked list of optical
% elements for current prescription. 
%==========================================================================
create_dbl_list%uses OpticalData and creates doubly linked list 
%==========================================================================
% Create gridded surfaces
%==========================================================================
gridelt=[15]';
[row col]=size(gridelt);
load('beamSize.txt');

for jj=1:row;
    ii=gridelt(jj,1);
    %creates Element string variable and assigns values of element to be 
    %converted to a gridded surface
    %vstrg = genvarname(sprintf(['Element' num2str(ii)]));
    vstrg = genvarname(sprintf(['Element']));
    eval(sprintf([vstrg '= Optic' num2str(ii) ';']))
    
    %Creates the xMon variable needed for creating the gridded surface and 
    %assigns the values of the corresponding element
    vstrg2 = genvarname(sprintf(['xMon']));                      
    eval(sprintf([vstrg2 '= Optic' num2str(ii) '.Data.TElt(1:3,1)''' ';' ]));
    
    ngrid=99;
    diameter=beamSize(ii,:);
    psiElt=[];
    RptElt=[];
    lMon=diameter/2;
    
    %creates Grid_optic and computes the gridded surface
    vstrg3 = genvarname(sprintf(['Grid_Optic' num2str(ii)]));     
    eval(sprintf([vstrg3 ' = create_grid_srf(Element,xMon,ngrid,diameter,lMon);']));
    help
    %Creates new optic data
    eval(sprintf(['Optic' num2str(ii) '.Data = ' vstrg3]));     
end
                  
%==========================================================================
% convert doubly linked list to cell array of structures after making all
% necessary updates
%==========================================================================
dblist2cell %command with no inputs to convert doubly linked list
            %to  cell array of structures
%--------------------------------------------------------------------------
% After converting doubly linked list back to a cell array of structures we
% use the WriteRxFile function to write prescription to write_fname
%--------------------------------------------------------------------------
write_fname='ISSTest_most3f1sprcdbl_v8.in';
credits=strvcat('author: Luis Marchen','Description: Contains gridded surfaces for entering optical deformations');
WriteRxFile(write_fname,ElementData,credits)


