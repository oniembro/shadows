//This section is choosing the input and output locations
//separate your nd2 files and your ROIs into two separate folders and have a third folder for the output
//First prompt will be for images folder, prompt 2 for ROIs, prompt 3 for where to save the results. Note that it will order your images and ROIs alphabetically to run them, so ideally your image file and their associated roi.zip should have the same name so they are opened at the same time. 
//for this to work ND2 import on bioformats has to be windowless (plugins>Bio-Formats>Configuration>Formats>Nikon ND2>tick windowless)
setBatchMode(true); //this will hide the images as it measures, it's kind of like going into silent mode.
file1 = getDirectory("files");
list1 = getFileList(file1);
n1 = list1.length;
file2 = getDirectory("directory");
list2 = getFileList(file2);
n2 = list2.length;
file3 = getDirectory("Output");
//These next steps order the lists to make sure that both the inout folders run in the same order
Array.sort(list1);
 Array.sort(list2);
small = n1;
if(small<n2){
small = n2;

} 

for (i=0; i<small; i++){

//this next section makes sure that there are no existing ROI or results as this will mess up the cell counting for the outline maps
if (roiManager("count") > 0)
{
roiManager("reset");
}
if (getValue("results.count") > 0)
{
run("Clear Results");
}

//this section opens the image from the channel one folder                
open(file1 + File.separator + list1[i]);
//run("Subtract...", "value=430 stack");

//this section opens the corresponding ROI   
run("ROI Manager...");
roiManager("Open", file2 + File.separator + list2[i]);

//run the measurmenet macro

    Stack.getDimensions(width, height, channels, slices, frames);
    nrOfRois = roiManager("count");
    for(roi = 0; roi < nrOfRois; roi++) {
        roiManager("select", roi);
        Stack.getPosition(channel, slice, frame);
        for(channel = 1; channel<=channels; channel++) { //if brightfield is on the last channel it's easy to keep it out of the measurements by changing <=channels to <=3 
            Stack.setChannel(channel);
            run("Measure");
            Table.set("field", nResults-1, frame, "Results");
            Table.set("channel", nResults-1, channel, "Results")
     		   }
   		 }

//save results as txt
selectWindow("Results");
saveAs(".txt", file3 + list1[i] + "res" + ".txt");
roiManager("deselect");
run("Close");
}
close("*");
print("done! :-D");

