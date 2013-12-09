package mahout.classifier;

import mahout.classifier.mapred.MapRed;
import mahout.classifier.mapred.MapRed.Reduce;
import mahout.classifier.mapred.MapRed.Map;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.mapred.FileOutputFormat;
import org.apache.hadoop.mapred.JobClient;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.TextInputFormat;
import org.apache.hadoop.mapred.TextOutputFormat;

public class WebsiteToSeq {
	public static void main(String args[]) throws Exception {
		String inputDirName = args[2];
		String outputDirName = args[4];
		String type = args[3];
		
    	System.out.println("Input dir: " + inputDirName);
    	System.out.println("Output dir: " + outputDirName);
		
		JobConf conf = new JobConf(MapRed.class);
	    conf.setJobName("sequencer");

	    conf.setOutputKeyClass(Text.class);
	    conf.setOutputValueClass(Text.class);

	    conf.setMapperClass(Map.class);
	    conf.setCombinerClass(Reduce.class);
	    conf.setReducerClass(Reduce.class);

	    conf.setInputFormat(TextInputFormat.class);
	    conf.setOutputFormat(TextOutputFormat.class);
	    
	    conf.set("outputDir", outputDirName);
	    conf.set("type", type);
		
	    try {
			ArrayList<File> files = new ArrayList<File>();
			
			listFiles(new File(inputDirName), files);
			for (File file : files) {
		    	FileInputFormat.addInputPath(conf, new Path(file.getPath()));
		    }
			
		    FileOutputFormat.setOutputPath(conf, new Path(outputDirName));
		    
		    JobClient.runJob(conf);
		    
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void listFiles(File f, ArrayList<File> filesArray) {
		for (File file : f.listFiles()) {
			if (file.isDirectory())
				listFiles(file, filesArray);
			else
				filesArray.add(file);
		}
	}
}
