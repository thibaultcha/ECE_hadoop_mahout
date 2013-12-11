package mahout.classifier.mapred;

import java.io.IOException;
import java.io.StringReader;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.Mapper;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reporter;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.fr.FrenchAnalyzer;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;
import org.apache.lucene.util.Version;
import org.jsoup.*;
import org.jsoup.nodes.Document;

public class MapRed {

	public static class Map extends MapReduceBase implements Mapper<LongWritable, Text, NullWritable, Text> {
		private FrenchAnalyzer analyzer = new FrenchAnalyzer(Version.LUCENE_43);
				
		@Override
		public void map(LongWritable key, Text value, OutputCollector<NullWritable, Text> output, Reporter reporter) throws IOException {
			// ok back to this then (was trying something else on a local branch)
		    Document doc = Jsoup.parse(value.toString());
		    doc.body().select("script, jscript, style").remove();
		    String line = doc.body().text();
		    
		    /*StringTokenizer tokenizer = new StringTokenizer(line);
		    while (tokenizer.hasMoreTokens()) {
		    	word = new Text(tokenizer.nextToken());
				//System.out.println(value);
				output.collect(NullWritable.get(), word);
		    }*/
		    
	    	TokenStream stream = analyzer.tokenStream("text", new StringReader(line));
	        stream.reset();
	        stream.addAttribute(CharTermAttribute.class);
	        StringBuffer str = new StringBuffer();
	        while (stream.incrementToken()) {
	        	str.append(stream.getAttribute(CharTermAttribute.class).toString());
	        }
	        output.collect(NullWritable.get(), new Text(str.toString()));
		}
	}
}
