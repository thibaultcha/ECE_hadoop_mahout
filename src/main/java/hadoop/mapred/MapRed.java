package hadoop.mapred;

import java.io.IOException;
import java.util.Iterator;
import java.util.StringTokenizer;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.Mapper;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reducer;
import org.apache.hadoop.mapred.Reporter;
import org.jsoup.*;

public class MapRed {

	public static class Map extends MapReduceBase implements Mapper<LongWritable, Text, Text, NullWritable> {
	    private Text word = new Text();

		public void map(LongWritable key, Text value, OutputCollector<Text, NullWritable> output, Reporter arg3) throws IOException {
			String line = value.toString();
		      
		    line = Jsoup.parse(line).text();
		      
		    StringTokenizer tokenizer = new StringTokenizer(line);
		    while (tokenizer.hasMoreTokens()) {
		        word.set(tokenizer.nextToken());
		        output.collect(word, NullWritable.get());
		    }
		}
	}

	public static class Reduce extends MapReduceBase implements Reducer<Text, IntWritable, Text, NullWritable> {

		public void reduce(Text key, Iterator<IntWritable> values, OutputCollector<Text, NullWritable> output, Reporter reporter) throws IOException {
			output.collect(key, NullWritable.get());
		}
	}
}
