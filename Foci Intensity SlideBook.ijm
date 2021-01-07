//run("ImageJ2...", "scijavaio=true");
run("Options...", "iterations=5 count=1 black edm=8-bit");
run("Input/Output...", "jpeg=85 gif=-1 file=.xlsx use_file copy_row save_column save_row");
run("Colors...", "foreground=white background=black selection=cyan");
run("Line Width...", "line=2");
run("Set Measurements...", "area standard median integrated limit redirect=None decimal=2");
run("Clear Results");
roiManager("Reset");
run("Close All");

Dialog.create("Image Folder");
Dialog.addMessage("You'll be asked to select the folder with the images.");
Dialog.show();
ImagePath=getDirectory("Choose the folder with images");
list = getFileList(ImagePath);
list = Array.sort (list);

print("Image Name","	","Threshold Value","	","Foci Count","	","Total Intensity of Foci","	","Total Intensity Outside of Foci","	","Inside/Outside Ratio");

setBatchMode(true);
for (NumImages=0; NumImages<list.length; NumImages++) {
	if (endsWith(list[NumImages],"sld")) {
		run("Bio-Formats Importer", "open=["+ImagePath+list[NumImages]+"] view=Hyperstack open_all_series stack_order=XYCZT");
		//open(ImagePath+list[NumImages]);
		n=nImages;
		//Your macro here
		run("Close All");
		for (i=0;i<n;i++) {
			run("Bio-Formats Importer", "open=["+ImagePath+list[NumImages]+"] view=Hyperstack stack_order=XYCZT series_"+(i+1));
			ImageName = getTitle();
			run("Median...","size=2");
			run("Measure");
			BKmean=getResult("Median",0);
			BKsd=getResult("StdDev",0);
	
			TH=BKmean+(3*BKsd); //Threshold set
			
			setThreshold(0,TH);
			run("Measure");
			OutInt=getResult("RawIntDen",1);
					
			setThreshold (TH,65535);
			run("Measure");
			FociInt=getResult("RawIntDen",2);
			run("Analyze Particles...", "size=0-10 clear add");
			FociCount=roiManager("Count");
			setMinAndMax(200, 9000);
			resetThreshold();
			roiManager("Draw");
			run("RGB Color");
			saveAs("jpeg","C:\\Users\\fujisaws\\Desktop\\Corentin\\"+ImageName+"_foci.jpg");
			
			print(ImageName,"	",TH,"	",FociCount,"	",FociInt,"	",OutInt,"	",FociInt/OutInt);
			run("Close All");
			run("Clear Results");
			roiManager("Reset");	
		}	
	}
}
