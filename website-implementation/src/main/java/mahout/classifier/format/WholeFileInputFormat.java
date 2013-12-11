package mahout.classifier.format;

import java.io.IOException;

import mahout.classifier.format.WholeFileRecordReader;

import org.apache.hadoop.mapred.RecordReader;
import org.apache.hadoop.mapred.InputSplit;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.Reporter;
import org.apache.hadoop.mapred.FileSplit;
import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

public class WholeFileInputFormat extends FileInputFormat<Text, BytesWritable> {
    @Override
    protected boolean isSplitable(FileSystem fs, Path file) {
        return false;
    }
    
    @Override
    public RecordReader<Text, BytesWritable> getRecordReader(
      InputSplit split, JobConf job, Reporter reporter) throws IOException {
        return new WholeFileRecordReader((FileSplit) split, job);
    }
}