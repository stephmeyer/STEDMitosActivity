/*
 * Macro to process multiple Mitos images in a folder
 * Input folder contains segmented STED images
 * Output folder will be where final data is saved
 * 
 */
//create folders for your output mitos images and masks, but not inside the folder where the images you need to process live
close("*");
#@ File (label = "Segmented Mitos Folder", style = "directory") input
#@ File (label = "TStorm Output Folder", style = "directory") output
#@ String (label = "File suffix", value = "_segmented.tif") suffix

processFolder(input);
// function to scan folders/subfolders/files to find files with correct suffix, then run processFile on each tif file
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output ,list[i]);
	}
}


function processFile(input, output,file) {
	run("Close All");
	filename = file.substring(0, file.lastIndexOf("_"));
	open(input + File.separator + file);
	//run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 fitradius=3 method=[Weighted Least squares] full_image_fitting=false mfaenabled=false renderer=[Averaged shifted histograms] magnification=5.0 colorizez=false threed=false shifts=2 repaint=50");
	run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=10 estimator=[PSF: Integrated Gaussian] sigma=1.6 fitradius=3 method=[Maximum likelihood] full_image_fitting=false mfaenabled=false renderer=Histograms magnification=5.0 avg=0 colorizez=false threed=false repaint=50");
	
	while(!isOpen("Averaged shifted histograms")){
		wait(3000);
	}
	wait(3000);
	run("Show results table", "action=duplicates distformula=uncertainty");
	wait(1000);
	run("Export results", "filepath=["+output+File.separator+filename+"-Tstorm.csv] fileformat=[CSV (comma separated)] sigma=true intensity=true chi2=true offset=true saveprotocol=true x=true y=true bkgstd=true id=false uncertainty=true frame=true");
	wait(3000);
	selectImage(file);
	run("Enhance Contrast", "saturated=3");
	wait(1000);
	run("Flatten");
	wait(1000);
	saveAs("Tiff",output+File.separator+filename+"-TStorm.tif");
	close();
	selectImage("Averaged shifted histograms");
	close();

}


