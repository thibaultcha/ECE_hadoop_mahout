package hadoop;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapred.*;

import hadoop.mapred.*;
import hadoop.mapred.MapRed.Map;
import hadoop.mapred.MapRed.Reduce;

public class Main {

	public static void main(String[] args) {
		JobConf conf = new JobConf(MapRed.class);
	    conf.setJobName("crawler");

	    conf.setOutputKeyClass(Text.class);
	    conf.setOutputValueClass(IntWritable.class);

	    conf.setMapperClass(Map.class);
	    conf.setCombinerClass(Reduce.class);
	    conf.setReducerClass(Reduce.class);

	    conf.setInputFormat(TextInputFormat.class);
	    conf.setOutputFormat(TextOutputFormat.class);

	    try {
			FileSystem fs = FileSystem.get(conf);
			
			ArrayList<FileStatus> files = new ArrayList<FileStatus>();
			listFiles(new Path(args[0]), files, fs);
			for (FileStatus file : files) {
				//System.out.println(file.getPath());
		    	FileInputFormat.addInputPath(conf, file.getPath());
		    }
			
		    FileOutputFormat.setOutputPath(conf, new Path(args[1]));
		    JobClient.runJob(conf);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	  }
	  
	  public static void listFiles(Path path, ArrayList<FileStatus> filesArray, FileSystem fs) throws IOException {
		  for (FileStatus file : fs.listStatus(path)) {
			  if (file.isDir())
				  listFiles(file.getPath(), filesArray, fs);
			  else
				  filesArray.add(file);
		  }
	  }
}
