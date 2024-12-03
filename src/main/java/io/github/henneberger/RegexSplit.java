package io.github.henneberger;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.flink.table.functions.ScalarFunction;

public class RegexSplit extends ScalarFunction {

  public List<List<String>> eval(String regex, String input) {
    Pattern p = Pattern.compile(regex);
    Matcher matcher = p.matcher(input);
    List<List<String>> matches = new ArrayList<>();
    while (matcher.find()) {
      String group = matcher.group();
      List<String> match = new ArrayList<>();
      match.add(group);
      for (int i = 0; i < matcher.groupCount(); i++) {
        match.add(matcher.group(i+1));
      }
      matches.add(match);
    }

    return matches;
  }
}