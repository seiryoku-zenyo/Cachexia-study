/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MTOR & Lysossomes colocalization analysis
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

start = getTime(); 

//Cleaning all
 if (isOpen("Results")) { 
       selectWindow("Results"); 
       run("Close"); 
   } 

while (nImages>0) { 
         selectImage(nImages); 
         close(); 
   				  }


print("Opening data file...");
input = getDirectory("Select the folder containing the images for analysis");
output = input;


//MEMBRANE (included) ANALYSIS
list = getFileList(input);
setBatchMode("hide");
for (l=0; l<list.length; l++) {
 showProgress(l+1, list.length);

filename = input + list[l];
 if (matches(filename, ".*TA_.*"+".lsm")) {


open(filename);

nome=getInfo("image.filename");
sample=substring(nome,0,4);
image=substring(nome,5,lengthOf(nome)-4);

imageTitle=getTitle();//returns a string with the image title
print(nome);
print(sample);
print(image);
print(substring(nome,0,2));

//Displaying progress for monitoring
subject_number= sample;
//print("\nProcessing...  " + brain_part +" of "+subject_number+"\n");


//Open images and retrieve metadata for later controls (laser power, Gain, Offset etc)
//run("Bio-Formats Importer", "open=filename display_metadata view=[Metadata only] stack_order=Default");
//animal_code=substring(imageTitle, 0, 6);
//selectWindow("Original Metadata - "+nome);  
//saveAs("Text", output+nome_tsv+"_metadata");
//run("Close");

selectWindow(imageTitle);
getDimensions(width, height, channels, slices, frames);

run("Split Channels");
selectWindow("C2-"+nome);
run("Subtract Background...", "rolling=3");
selectWindow("C3-"+nome);
run("Subtract Background...", "rolling=3");
selectWindow("C1-"+nome);
run("Subtract Background...", "rolling=10");
setAutoThreshold("Otsu");
//setThreshold(0, 51);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Invert");
run("Dilate");
run("Duplicate...", " ");
run("Dilate");
run("Dilate");
run("Remove Outliers...", "radius=10 threshold=50 which=Dark");
run("16-bit");
setMinAndMax(0, 4095);
run("Apply LUT");
imageCalculator("Subtract create", "C3-"+nome, "C1-"+sample+"_"+image+"-1.lsm");
rename("NO_memb_C3-"+nome);
run("Duplicate...", "title=binarized_C3-"+nome); //making binarized images for particle analyzes with Cell Analyzer (ImageJ)
setThreshold(0, 50);
run("Convert to Mask");
run("Invert");
run("Fill Holes");
imageCalculator("Subtract create", "C2-"+nome, "C1-"+sample+"_"+image+"-1.lsm");
rename("NO_memb_C2-"+nome);
run("Duplicate...", "title=binarized_C2-"+nome); //making binarized images for particle analyzes with Cell Analyzer (ImageJ)
setThreshold(0, 50);
run("Convert to Mask");
run("Invert");
run("Fill Holes");

//Creating images without extracelluar space
selectWindow("C1-"+sample+"_"+image+"-1.lsm");
run("Invert");
run("Cell Segmentation", "minimun=5 grayvalue=2");
selectWindow("Result");
setThreshold(0, 1);
setOption("BlackBackground", false);
run("Convert to Mask");
run("16-bit");
setMinAndMax(0, 4095);
imageCalculator("Subtract create", "C2-"+nome, "Result");
rename("NO_ExtraCellular_Space_C2-"+nome);
imageCalculator("Subtract create", "C1-"+nome, "Result");
rename("NO_ExtraCellular_Space_C1-"+nome);


 //COLOCALIZATION ANALYSIS
 //with membrane (about 2.5 micrometers thick)
run("Colocalization Threshold", "channel_1=C3-"+nome+" channel_2=C2-"+nome+" use=None channel=[Red : Green] show show set show show pearson's pearson's pearson's mander's mander's number % % % %");
selectWindow("Colocalized Pixel Map RGB Image");
saveAs("Tiff", input+"with_membrane//"+sample+"_"+image+"_coloc.tif");
selectWindow("C3-"+nome+" & C2-"+nome+" Freq. CP");
saveAs("Tiff", input+"with_membrane//"+sample+"_"+image+"_scatterplot.tif");


selectWindow("Results");
saveAs("Text", input+"with_membrane//"+sample+"_"+image+"_results.tsv");
selectWindow("Results"); 
run("Close"); 





//MEMBRANE (excluded) ANALYSIS
//without membrane (about 2.5 micrometers thick)
run("Colocalization Threshold", "channel_1=NO_memb_C3-"+nome+" channel_2=NO_memb_C2-"+nome+" use=None channel=[Red : Green] show show set show show pearson's pearson's pearson's mander's mander's number % % % %");
selectWindow("Colocalized Pixel Map RGB Image");
saveAs("Tiff", input+"without_membrane//"+sample+"_"+image+"_coloc.tif");
selectWindow("NO_memb_C3-"+nome+" & NO_memb_C2-"+nome+" Freq. CP");
saveAs("Tiff", input+"without_membrane//"+sample+"_"+image+"_scatterplot.tif");
selectWindow("Results");
saveAs("Text", input+"without_membrane//"+sample+"_"+image+"_results.tsv");

while (nImages>0) { 
         selectImage(nImages); 
         close(); 
   				  }

   				  selectWindow("Results"); 
run("Close"); 
 }  
}
