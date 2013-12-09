package mahout.classifier.mapred;

import java.io.IOException;
import java.util.Iterator;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.SequenceFile;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.SequenceFile.Writer;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.Mapper;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reducer;
import org.apache.hadoop.mapred.Reporter;
import org.jsoup.*;

public class MapRed {

	public static class Map extends MapReduceBase implements Mapper<Text, Text, Text, Text> {
	    private Text type = new Text();
	    private Text word = new Text();
		
		public void configure(JobConf job) {
		    type = new Text(job.get("type"));
		}
		
		@Override
		public void map(Text key, Text value, OutputCollector<Text, Text> output, Reporter reporter) throws IOException { 
			String line = value.toString();
		      
		    line = Jsoup.parse(line).text();
		    
		    StringTokenizer tokenizer = new StringTokenizer(line);
		    while (tokenizer.hasMoreTokens()) {
		        word.set(tokenizer.nextToken());
		        output.collect(type, word);
		    }
		}
	}

	public static class Reduce extends MapReduceBase implements Reducer<Text, Text, Text, Text> {
		private static String outputDir;
		
		public void configure(JobConf job) {
			outputDir = job.get("outputDir");
		}
		
		@Override
		public void reduce(Text key, Iterator<Text> values, OutputCollector<Text, Text> output, Reporter reporter) throws IOException {
			System.out.println(outputDir);
			
			Configuration conf = new Configuration();
			FileSystem fs = FileSystem.get(conf);
			Writer writer = new SequenceFile.Writer(fs, conf, new Path(outputDir + "/chunk-0"), Text.class, Text.class);
			while (values.hasNext()) {
				Text value = values.next();
				//System.out.println(value);
				writer.append(key, value);
				output.collect(key, value);
			}
			writer.close();
		}
	}
}
