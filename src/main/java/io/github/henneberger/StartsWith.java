package io.github.henneberger;

import org.apache.flink.table.functions.ScalarFunction;

public class StartsWith extends ScalarFunction {

  public Boolean eval(String prefix, String input) {
    if (input == null) {
      return null;
    }
    return input.startsWith(prefix);
  }
}