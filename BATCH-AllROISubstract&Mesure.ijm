//This section is choosing the input and output locations
//separate your files and ROIs into two separate folders and have a third folder for the output. First prompt will be for images folder, prompt 2 for ROIs, prompt 3 for where to save the results. Note that it will order your images and ROIs alphabetically to run them, so ideally your image file and their associated roi.zip should have the same name so they are opened at the same time. 
	
file1 = getDirectory("files");
list1 = getFileList(file1);
n1 = list1.length;
file2 = getDirectory("directory");
list2 = getFileList(file2);
n2 = list2.length;
file3 = getDirectory("Output");
file4 = getDirectory("Merged");
//These next steps order the lists to make sure that both the input folders run in the same order
Array.sort(list1);
 Array.sort(list2);

// Determine number of files to process (use smallest list)

small = n1;
if(small<n2){
small = n2;

} 

// Process each file

for (i=0; i<small; i++){
//for (fileIndex = 0; fileIndex < nFiles; fileIndex++) {
    roiManager("reset");
    run("Clear Results");

    // Open image and ROI
    open(file1 + File.separator + list1[i]);
    img_name = list1[i];
    img_split = getTitle();
    run("ROI Manager...");
    roiManager("Open", file2 + File.separator + list2[i]);

    // Process channels and substract background
    run("Split Channels");

 selectWindow("C1-" + img_split);
    imageTitle1 = getTitle();
    value = getNumber("Enter mean background:"+img_name, 0);
    for (j = 1; j <= nSlices; j++) {  // Changed variable to 'j'
        setSlice(j);
        run("Subtract...", "value=" + value);
    }
      		print(img_name + " C1: " + value);
      		
      		
    selectWindow("C2-" + img_split);
    imageTitle2 = getTitle();
    value = getNumber("Enter mean background:", 0);
    for (j = 1; j <= nSlices; j++) {  // Changed variable to 'j'
        setSlice(j);
        run("Subtract...", "value=" + value);
    }   
     		print(img_name + " C2: " + value);
     		
    selectWindow("C3-" + img_split);
    imageTitle3 = getTitle();
    value = getNumber("Enter mean background:", 0);
    for (j = 1; j <= nSlices; j++) {  // Changed variable to 'j'
        setSlice(j);
        run("Subtract...", "value=" + value);
    }   
    
    		print(img_name + " C3: " + value);
    		
        selectWindow("C4-" + img_split);
    close(); 
    
    run("Merge Channels...", "c1=[" + imageTitle1 +"] c2=[" + imageTitle2 +"] c3=[" + imageTitle3 +"] create");
    mergedTitle = img_name; // Store merged image title
       saveAs("tiff", file4+img_name);



//run the measurmenet macro

    Stack.getDimensions(width, height, channels, slices, frames);
    nrOfRois = roiManager("count");
    for(roi = 0; roi < nrOfRois; roi++) {
        roiManager("select", roi);
        Stack.getPosition(channel, slice, frame);
        for(channel = 1; channel<=3; channel++) { //if brightfield is on the last channel it's easy to keep it out by changing <=channels to <=3 
            Stack.setChannel(channel);
            run("Measure");
            Table.set("field", nResults-1, frame, "Results");
            Table.set("channel", nResults-1, channel, "Results")
     		   }
   		 }

//save results as txt
    selectWindow("Results");
    saveAs(".txt", file3 + img_name + "_res.txt");
    close(); // Close results table
    close(mergedTitle); // Close merged image
    
}
 selectWindow("Log");
 saveAs("log.txt");
//close();
close();
