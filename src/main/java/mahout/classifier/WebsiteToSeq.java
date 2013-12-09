package mahout.classifier;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.SequenceFile.Writer;
import org.apache.hadoop.io.Text;
import org.jsoup.*;

public class WebsiteToSeq {
	public static void main(String args[]) throws Exception {
		if (args.length != 3) {
			System.err.println("Arguments: [input website directory] [type] [output sequence file]");
			return;
		}
		String inputDirName = args[0];
		String outputDirName = args[2];
		String type = args[1];
		
		
		
		
		
		
		
		
		
		
		
		Configuration configuration = new Configuration();
		FileSystem fs = FileSystem.get(configuration);
		Writer writer = new SequenceFile.Writer(fs, configuration, new Path(outputDirName + "/chunk-0"),
				Text.class, Text.class);
		
		ArrayList<File> files = new ArrayList<File>();
		listFiles(new File(inputDirName), files);
		
		long count = 0;
		Text key = new Text();
		Text value = new Text();
		for (File file : files) {
			BufferedReader reader = new BufferedReader(new FileReader(file));
			while(true) {
				String line = reader.readLine();
				if (line == null) {
					break;
				}
				line = Jsoup.parse(line).text();
				StringTokenizer tokenizer = new StringTokenizer(line);
			    while (tokenizer.hasMoreTokens()) {
			    	key.set("/" + args[1]);
					value.set(tokenizer.nextToken());
					System.out.println(value);
					writer.append(key, value);
					count++;
			    }
			}
			reader.close();
		}
		
		writer.close();
		System.out.println("Wrote " + count + " entries.");
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
