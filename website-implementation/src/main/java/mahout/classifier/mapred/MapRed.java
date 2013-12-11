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
		    //Document doc = Jsoup.parse(value.toString());
		    //doc.select("script").remove();
		    //String content = doc.text();
		    
		    /*StringReader sr = new StringReader(content);
		    StringBuffer sw = new StringBuffer();
		    
	    	TokenStream stream = analyzer.tokenStream("text", sr);
	    	CharTermAttribute cattr = stream.addAttribute(CharTermAttribute.class);
	      
	        stream.reset();
	        while (stream.incrementToken()) {
	        	sw.append(cattr.toString() + " ");
	        }
	        
	        sr.close();
	        stream.close();*/
	        output.collect(NullWritable.get(), new Text(value.toString() + "\n\n\n\n\n\n\n\n\n ~~~~~~~======== END OF THIS MAP ========~~~~~~~~ \n\n\n\n\n\n\n\n"));
		}
	}
}
