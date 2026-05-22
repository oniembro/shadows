//setBatchMode(true);
    roiManager("reset");
    run("Clear Results");
   if (isOpen("Log")) { selectWindow("Log"); close(); }
// This section is choosing the input and output locations
// separate your files and ROIs into two separate folders,have a third folder for the output and a last one for the merged, substracted images.
// First prompt will be for images folder, prompt 2 for ROIs, prompt 3 for where to save the results, prompt 4 to save tifs.
// Note that it will order your images and ROIs alphabetically to run them, so ideally your image file and their associated roi.zip should have the same name so they are opened at the same time.

file1 = getDirectory("files");
list1 = getFileList(file1);
n1 = list1.length;
file2 = getDirectory("directory");
list2 = getFileList(file2);
n2 = list2.length;
file3 = getDirectory("Output");
file4 = getDirectory("Merged");

// Load background values from CSV
csvFile = File.openDialog("Select background values CSV");
csvContent = File.openAsString(csvFile);
csvLines = split(csvContent, "\n");

// Parse into arrays (skip header row at index 0)
bgNames = newArray(csvLines.length - 1);
bgC1    = newArray(csvLines.length - 1);
bgC2    = newArray(csvLines.length - 1);
bgC3    = newArray(csvLines.length - 1);

for (k = 1; k < csvLines.length; k++) {
    cols = split(csvLines[k], ",");
    bgNames[k-1] = cols[0];
    bgC1[k-1]    = parseFloat(cols[1]);
    bgC2[k-1]    = parseFloat(cols[2]);
    bgC3[k-1]    = parseFloat(cols[3]);
}

// These next steps order the lists to make sure that both the input folders run in the same order
Array.sort(list1);
Array.sort(list2);

// Determine number of files to process (use smallest list)
small = n1;
if (small < n2) {
    small = n2;
}

// Process each file
for (i = 0; i < small; i++) {
// clear
    roiManager("reset");
    run("Clear Results");

    // Open image and ROI
    open(file1 + File.separator + list1[i]);
    img_name = list1[i];
    img_split = getTitle();
    run("ROI Manager...");
    roiManager("Open", file2 + File.separator + list2[i]);

    // Process channels and subtract background
    run("Split Channels");

    // Look up background values for this image from CSV
    valC1 = getBackground(img_name, bgNames, bgC1);
    valC2 = getBackground(img_name, bgNames, bgC2);
    valC3 = getBackground(img_name, bgNames, bgC3);

    // Channel 1
    selectWindow("C1-" + img_split);
    imageTitle1 = getTitle();
    for (j = 1; j <= nSlices; j++) {
        setSlice(j);
        run("Subtract...", "value=" + valC1);
    }
    print(img_name + " C1: " + valC1);

    // Channel 2
    selectWindow("C2-" + img_split);
    imageTitle2 = getTitle();
    for (j = 1; j <= nSlices; j++) {
        setSlice(j);
        run("Subtract...", "value=" + valC2);
    }
    print(img_name + " C2: " + valC2);

    // Channel 3
    selectWindow("C3-" + img_split);
    imageTitle3 = getTitle();
    for (j = 1; j <= nSlices; j++) {
        setSlice(j);
        run("Subtract...", "value=" + valC3);
    }
    print(img_name + " C3: " + valC3);

    selectWindow("C4-" + img_split);
    close();

    run("Merge Channels...", "c1=[" + imageTitle1 + "] c2=[" + imageTitle2 + "] c3=[" + imageTitle3 + "] create");
    mergedTitle = img_name;
    saveAs("tiff", file4 + img_name);

    // Run the measurement macro
    Stack.getDimensions(width, height, channels, slices, frames);
    nrOfRois = roiManager("count");
    for (roi = 0; roi < nrOfRois; roi++) {
        roiManager("select", roi);
        Stack.getPosition(channel, slice, frame);
        for (channel = 1; channel <= 3; channel++) {
            Stack.setChannel(channel);
            run("Measure");
            Table.set("field", nResults-1, frame, "Results");
            Table.set("channel", nResults-1, channel, "Results");
        }
    }

    // Save results as txt
    selectWindow("Results");
    saveAs(".txt", file3 + img_name + "_res.txt");
    close(); // Close results table
    close(mergedTitle); // Close merged image
}
//ending and closing everything after the loop
selectWindow("Log");
saveAs(".txt", file4 + "log.txt");
run("Clear Results"); 
if (isOpen("Results")) { selectWindow("Results"); run("Close"); };
if (isOpen("Log")) { selectWindow("Log"); run("Close"); };
showMessage("done", "    |\\__/,|   (`\\\n  _.|o o  |_   ) )\n-(((---(((--------\n\n\n");

// Helper function to look up background value by filename
function getBackground(name, bgNames, bgValues) {
    for (k = 0; k < bgNames.length; k++) {
        if (bgNames[k] == name) return bgValues[k];
    }
    print("WARNING: No background value found for " + name + " — defaulting to 0");
    return 0;
}