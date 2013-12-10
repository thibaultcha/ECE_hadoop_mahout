package mahout.classifier;

import java.io.BufferedReader;
import java.io.FileReader;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.SequenceFile.Writer;

public class WordsToSeq {
	public static void main(String args[]) throws Exception {
		if (args.length != 3) {
			System.err.println("Arguments: [input edf dir] [input soccer dir] [output sequence file]");
			return;
		}
		String inputFileEdf = args[0];
		String inputFileSoccer = args[1];
		String outputDirName = args[2];
		Configuration configuration = new Configuration();
		FileSystem fs = FileSystem.get(configuration);
		Writer writer = new SequenceFile.Writer(fs, configuration, new Path(outputDirName + "/chunk-0"),
				Text.class, Text.class);
		
		int count = 0;
		BufferedReader reader = new BufferedReader(new FileReader(inputFileEdf));
		Text key = new Text();
		Text value = new Text();
		while(true) {
			String line = reader.readLine();
			if (line == null) {
				break;
			}
			String message = line;
			key.set("/edf/" + Integer.toString(count));
			value.set(message);
			writer.append(key, value);
			count++;
		}
		reader.close();
		
		reader = new BufferedReader(new FileReader(inputFileSoccer));
		while(true) {
			String line = reader.readLine();
			if (line == null) {
				break;
			}
			String message = line;
			key.set("/soccer/" + Integer.toString(count));
			value.set(message);
			writer.append(key, value);
			count++;
		}
		reader.close();
		
		writer.close();
		System.out.println("Wrote " + count + " entries.");
	}
}