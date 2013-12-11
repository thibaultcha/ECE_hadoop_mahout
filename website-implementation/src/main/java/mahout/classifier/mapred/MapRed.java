package mahout.classifier.mapred;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;

import org.apache.hadoop.io.BytesWritable;
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

	public static class Map extends MapReduceBase implements Mapper<Text, BytesWritable, NullWritable, Text> {
		private FrenchAnalyzer analyzer = new FrenchAnalyzer(Version.LUCENE_43);
				
		@Override
		public void map(Text key, BytesWritable value, OutputCollector<NullWritable, Text> output, Reporter reporter) throws IOException { 
			// Reading bytes from WholeInputFile
			byte[] raw = value.getBytes();
		    int size = raw.length;
		    InputStream is = null;
		    byte[] b = new byte[size];
		    is = new ByteArrayInputStream(raw);
		    is.read(b);
		    
		    // Parsing HTML
		    Document doc = Jsoup.parse(new String(b));
		    String content = doc.text();
		    
		    // Tokenizing content
		    StringReader sr = new StringReader(content);
		    StringBuffer sw = new StringBuffer();
		    
	    	TokenStream stream = analyzer.tokenStream("text", sr);
	    	CharTermAttribute cattr = stream.addAttribute(CharTermAttribute.class);
	      
	        stream.reset();
	        while (stream.incrementToken()) {
	        	sw.append(cattr.toString() + " ");
	        }
	        
	        sr.close();
	        stream.close();
		    
	        // Writing output
	        output.collect(NullWritable.get(), new Text(sw.toString()));
		}
	}
}
