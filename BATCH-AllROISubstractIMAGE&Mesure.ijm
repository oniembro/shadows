// SECTION 1: Choose input/output locations
// Folder 1: images, Folder 2: ROIs, Folder 3: results output
// Folder 4: merged output, Folder 5: background images

file1 = getDirectory("Select Images Folder");
list1 = getFileList(file1);
n1 = list1.length;

file2 = getDirectory("Select ROIs Folder");
list2 = getFileList(file2);
n2 = list2.length;

file3 = getDirectory("Select Results Output Folder");
file4 = getDirectory("Select Merged Output Folder");
file5 = getDirectory("Select Background Images Folder"); // NEW

Array.sort(list1);
Array.sort(list2);

// Determine number of files to process
small = n1;
if (n2 < small) { small = n2; }

// SECTION 2: Process each file
for (i = 0; i < small; i++) {
    roiManager("reset");
    run("Clear Results");

    // Open image and ROI
    open(file1 + File.separator + list1[i]);
    img_name = list1[i];
    img_split = getTitle();
    run("ROI Manager...");
    roiManager("Open", file2 + File.separator + list2[i]);

    // Split channels
    run("Split Channels");

    // --- CHANNEL 1: subtract background image ---
 
    selectWindow("C1-" + img_split);
	imageTitle1 = "C1-" + img_split;

    // Build background filename — ADJUST SUFFIX TO MATCH YOUR FILES
    baseName = replace(img_name, ".nd2", ""); // strip extension
    bgName_C1 = baseName + "_C1-bg.tiff";
	//substract
    open(file5 + File.separator + bgName_C1);
    imageCalculator("Subtract stack", imageTitle1, bgName_C1);
    selectWindow(bgName_C1);
    close(); // close background image after subtraction
   // print(imageTitle1 + " C1: background image subtracted");

    // --- CHANNEL 2: subtract background image ---
     selectWindow("C2-" + img_split);
	imageTitle2 = "C2-" + img_split;

    // Build background filename — ADJUST SUFFIX TO MATCH YOUR FILES
   // baseName = replace(img_name, ".nd2", ""); // strip extension
    bgName_C2 = baseName + "_C2-bg.tiff";
	//substract
    open(file5 + File.separator + bgName_C2);
    imageCalculator("Subtract stack", imageTitle2, bgName_C2);
    selectWindow(bgName_C2);
    close();
    // --- CHANNEL 3: manual background value (no background image) ---
 
    selectWindow("C3-" + img_split);
	imageTitle3 = "C3-" + img_split;

    // Build background filename — ADJUST SUFFIX TO MATCH YOUR FILES
   // baseName = replace(img_name, ".nd2", ""); // strip extension
    bgName_C3 = baseName + "_C3-bg.tiff";
	//substract
    open(file5 + File.separator + bgName_C3);
    imageCalculator("Subtract stack", imageTitle3, bgName_C3);
    selectWindow(bgName_C3);
    close();
 
    // Close C4 (e.g. brightfield)
    selectWindow("C4-" + img_split);
    close();

    // Merge channels 1–3
    run("Merge Channels...", "c1=[" + imageTitle1 + "] c2=[" + imageTitle2 + "] c3=[" + imageTitle3 + "] create");
    mergedTitle = getTitle();
    saveAs("tiff", file4 + img_name);

    // SECTION 3: Measurements across ROIs and channels
    Stack.getDimensions(width, height, channels, slices, frames);
    nrOfRois = roiManager("count");
    for (roi = 0; roi < nrOfRois; roi++) {
        roiManager("select", roi);
        Stack.getPosition(channel, slice, frame);
        for (channel = 1; channel <= 3; channel++) {
            Stack.setChannel(channel);
            run("Measure");
            Table.set("field", nResults - 1, frame, "Results");
            Table.set("channel", nResults - 1, channel, "Results");
        }
    }

    // Save results
    selectWindow("Results");
    saveAs(".txt", file3 + img_name + "_res.txt");
    close();
    close(mergedTitle);
}
