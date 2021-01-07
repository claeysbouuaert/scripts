//run("ImageJ2...", "scijavaio=true");
run("Options...", "iterations=5 count=1 black edm=8-bit");
run("Input/Output...", "jpeg=85 gif=-1 file=.xlsx use_file copy_row save_column save_row");
run("Colors...", "foreground=white background=black selection=cyan");
run("Line Width...", "line=3");
run("Set Measurements...", "area standard median integrated area_fraction limit redirect=None decimal=2");
run("Clear Results");
roiManager("Reset");
run("Close All");

Dialog.create("Image Folder");
Dialog.addMessage("You'll be asked to select the folder with the images.");
Dialog.show();
ImagePath=getDirectory("Choose the folder with images");
list = getFileList(ImagePath);
list = Array.sort (list);

print("Image Name","	","Threshold-Ch1","	","Foci Count-Ch1","	","Foci Intensity-Ch1","	","Outside Intensity-Ch1","	","Foci/Outside-Ch1","	","Threshold-CH2","	","Foci Count-Ch2","	","Foci Intensity-Ch2","	","Outside Intensity-Ch2","	","Foci/Outside-Ch2", "	","Double Foci Count");

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
			run("Colors...", "foreground=white background=black selection=cyan");
			getDimensions(width, height, a,b,c);
			
			//Measuring Intensity and Counts of Foci in first channel
			setSlice(1); 
			run("Median...","size=2 stack");
			run("Measure");
			BKmean1=getResult("Median",0);
			BKsd1=getResult("StdDev",0);
	
			TH1=BKmean1+(3*BKsd1); //Threshold set
			
			setThreshold(0,TH1);  //*****Absolute value here
			run("Measure");
			OutInt1=getResult("RawIntDen",1);
					
			setThreshold (TH1,65535);   //*****Absolute value here
			run("Measure");
			FociInt1=getResult("RawIntDen",2);
			run("Analyze Particles...", "size=0-10 clear add");
			FociCount1=roiManager("Count");

			newImage("total","8-bit black", width, height,1);
			roiManager("Fill");
			
			//Measuring Intensity and Counts of Foci in second channel
			selectWindow(ImageName);
			roiManager("Reset");
			setSlice(2); 
			resetThreshold();
			run("Measure");
			BKmean2=getResult("Median",0);
			BKsd2=getResult("StdDev",0);
	
			TH2=BKmean2+(3*BKsd2); //Threshold set
			
			setThreshold(0,TH2);  //*****Absolute value here
			run("Measure");
			OutInt2=getResult("RawIntDen",1);
					
			setThreshold (TH2,65535);   //*****Absolute value here
			run("Measure");
			FociInt2=getResult("RawIntDen",2);
			run("Analyze Particles...", "size=0-10 clear add");
			FociCount2=roiManager("Count");

			//Calculating the double positive foci
			selectWindow("total");
			roiManager("Measure");

			DoubleCount=0;
			for (p=0;p<nResults;p++) {
				data=getResult("%Area",p);
				if (data>10) {  //****** Overlap percentage
					DoubleCount=DoubleCount+1;
				}  
			}
			
			roiManager("Reset");
			run("Select None");

			
			print(ImageName,"	",TH1,"	",FociCount1,"	",FociInt1,"	",OutInt1,"	",FociInt1/OutInt1,"	",TH2,"	",FociCount2,"	",FociInt2,"	",OutInt2,"	",FociInt2/OutInt2, "	",DoubleCount);
			run("Close All");
			run("Clear Results");
			roiManager("Reset");	
		}	
	}
}
