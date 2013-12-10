package mahout.classifier;

import mahout.classifier.mapred.MapRed;
import mahout.classifier.mapred.MapRed.Map;

import java.io.IOException;
import java.util.ArrayList;

import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.mapred.FileOutputFormat;
import org.apache.hadoop.mapred.JobClient;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.TextInputFormat;
import org.apache.hadoop.mapred.TextOutputFormat;

public class WebsiteToSeq {
	public static void main(String args[]) throws Exception {
		if (args.length != 2) {
			System.out.println("Usage: [input website dir] [output dir]");
		}
		String inputDirName = args[0];
		String outputDirName = args[1];
		
    	System.out.println("Input dir: " + inputDirName);
    	System.out.println("Output dir: " + outputDirName);
		
		JobConf conf = new JobConf(MapRed.class);
	    conf.setJobName("sequencer");
	    
	    conf.setMapperClass(Map.class);
	    // using the method 2 to create sequence files (see run.sh and WordsToSeq), we only want a single output file
	    // so this becomes 1 and not 0
	    //conf.setNumReduceTasks(1);
	    conf.setNumReduceTasks(0);

	    conf.setInputFormat(TextInputFormat.class);
	    conf.setOutputKeyClass(NullWritable.class);
	    conf.setOutputValueClass(Text.class);
	    //conf.setOutputFormat(MultipleTextOutputFormat.class);
	    conf.setOutputFormat(TextOutputFormat.class);
	
	    try {
			ArrayList<FileStatus> files = new ArrayList<FileStatus>();
			
			listFiles(new Path(inputDirName), files, FileSystem.get(conf));
			for (FileStatus file : files) {
		    	FileInputFormat.addInputPath(conf, file.getPath());
		    }
			
		    FileOutputFormat.setOutputPath(conf, new Path(outputDirName));
		    
		    JobClient.runJob(conf);
		    
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void listFiles(Path f, ArrayList<FileStatus> filesArray, FileSystem fs) throws IOException {
		for (FileStatus file : fs.listStatus(f)) {
			if (file.isDir())
				listFiles(file.getPath(), filesArray, fs);
			else
				filesArray.add(file);
		}
	}
}
